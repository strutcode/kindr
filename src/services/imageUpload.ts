import { createLogger } from '@/lib/logger'
import { supabase } from '@/lib/supabase'

const { log, debug, info, warn, error } = createLogger('ImageUpload')

export interface ImageFile {
  id: string
  file: File
  preview: string
  uploading: boolean
  uploaded: boolean
  error?: string
  url?: string
}

export interface UploadProgress {
  loaded: number
  total: number
  percentage: number
}

export class ImageUploadService {
  private static readonly MAX_FILE_SIZE = 2 * 1024 * 1024 // 2MB
  private static readonly MAX_IMAGES = 8
  private static readonly ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
  private static readonly COMPRESSION_QUALITY = 0.9
  private static readonly MAX_DIMENSION = 1920

  /**
   * Validates image files before upload
   */
  static validateFiles(files: FileList | File[]): { valid: File[]; errors: string[] } {
    const fileArray = Array.from(files)
    const valid: File[] = []
    const errors: string[] = []

    for (const file of fileArray) {
      // Check file type
      if (!this.ALLOWED_TYPES.includes(file.type)) {
        errors.push(`${file.name}: Invalid file type. Only JPG, PNG, and GIF files are allowed.`)
        continue
      }

      // Check file size
      if (file.size > this.MAX_FILE_SIZE) {
        errors.push(`${file.name}: File too large. Maximum size is 2MB.`)
        continue
      }

      valid.push(file)
    }

    return { valid, errors }
  }

  /**
   * Validates total number of images
   */
  static validateImageCount(currentCount: number, newCount: number): string | null {
    const totalCount = currentCount + newCount
    if (totalCount > this.MAX_IMAGES) {
      return `Maximum ${this.MAX_IMAGES} images allowed. You can add ${
        this.MAX_IMAGES - currentCount
      } more.`
    }
    return null
  }

  /**
   * Compresses and converts image to JPEG
   */
  static async compressImage(file: File): Promise<Blob> {
    return new Promise((resolve, reject) => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      const img = new Image()

      const timeout = setTimeout(() => {
        reject(new Error('Image compression timed out'))
      }, 30000) // 30 second timeout

      img.onload = () => {
        try {
          clearTimeout(timeout)

          // Calculate new dimensions while maintaining aspect ratio
          let { width, height } = img

          if (width > this.MAX_DIMENSION || height > this.MAX_DIMENSION) {
            const ratio = Math.min(this.MAX_DIMENSION / width, this.MAX_DIMENSION / height)
            width *= ratio
            height *= ratio
          }

          canvas.width = width
          canvas.height = height

          // Draw and compress
          ctx!.drawImage(img, 0, 0, width, height)

          canvas.toBlob(
            blob => {
              if (blob) {
                resolve(blob)
              } else {
                reject(new Error('Failed to compress image'))
              }
            },
            'image/jpeg',
            this.COMPRESSION_QUALITY,
          )
        } catch (error) {
          clearTimeout(timeout)
          reject(error)
        }
      }

      img.onerror = () => {
        clearTimeout(timeout)
        reject(new Error('Failed to load image'))
      }

      img.src = URL.createObjectURL(file)
    })
  }

  /**
   * Generates a unique filename for the image
   */
  static generateFileName(userId: string, originalName: string): string {
    const timestamp = Date.now()
    const random = Math.random().toString(36).substring(2, 8)
    const extension = 'jpg' // Always use jpg after compression
    return `${userId}/${timestamp}_${random}.${extension}`
  }

  /**
   * Uploads a single image to Supabase storage with enhanced error handling
   */
  static async uploadImage(
    file: File,
    userId: string,
    onProgress?: (progress: UploadProgress) => void,
  ): Promise<{ url: string; path: string }> {
    try {
      info('Starting image upload for file:', file.name)

      if (!userId) {
        throw new Error('User ID is required for image upload')
      }

      // Compress the image with timeout
      const compressedBlob = await Promise.race([
        this.compressImage(file),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error('Image compression timed out')), 30000),
        ),
      ])

      info('Image compressed successfully, size:', compressedBlob.size)

      // Generate unique filename
      const fileName = this.generateFileName(userId, file.name)
      debug('Generated filename:', fileName)

      // Upload to Supabase storage with retry logic
      const uploadResult = await supabase.storage
        .from('listing-images')
        .upload(fileName, compressedBlob, {
          cacheControl: '3600',
          upsert: false,
        })

      debug('Supabase upload successful:', uploadResult)

      if (!uploadResult || uploadResult.error) {
        throw new Error('Upload failed: No data returned from Supabase')
      }

      const { data: urlData } = await supabase.storage
        .from('listing-images')
        .getPublicUrl(uploadResult.data.path)

      const result = {
        url: urlData.publicUrl,
        path: uploadResult.data.path,
      }

      info('Upload completed successfully:', result)
      return result
    } catch (err) {
      error('Image upload error:', err)

      if (err instanceof Error) {
        throw err
      }

      // Handle specific error types
      if (err instanceof Error) {
        if (err.message.includes('timed out')) {
          throw new Error('Upload timed out. Please try again.')
        }
        if (err.message.includes('network') || err.message.includes('fetch')) {
          throw new Error('Network error during upload. Please check your connection.')
        }
      }

      throw new Error(err instanceof Error ? err.message : 'Upload failed')
    }
  }

  /**
   * Uploads multiple images with enhanced error handling and progress tracking
   */
  static async uploadImages(
    files: File[],
    userId: string,
    onProgress?: (imageId: string, progress: UploadProgress) => void,
    onComplete?: (imageId: string, result: { url: string; path: string }) => void,
    onError?: (imageId: string, error: string) => void,
  ): Promise<{ url: string; path: string }[]> {
    const results: { url: string; path: string }[] = []

    info(`Starting upload of ${files.length} images for user ${userId}`)

    if (!userId) {
      throw new Error('User ID is required for image upload')
    }

    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      const imageId = `upload_${Date.now()}_${i}_${Math.random().toString(36).substring(2, 8)}`

      debug(`Processing image ${i + 1}/${files.length}:`, file.name)

      try {
        // Report progress start
        onProgress?.(imageId, { loaded: 0, total: 100, percentage: 0 })

        const result = await this.uploadImage(file, userId, progress =>
          onProgress?.(imageId, progress),
        )

        info(`Image ${i + 1} uploaded successfully:`, result)
        results.push(result)
        onComplete?.(imageId, result)

        // Report progress complete
        onProgress?.(imageId, { loaded: 100, total: 100, percentage: 100 })
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Upload failed'
        error(`Image ${i + 1} upload failed:`, errorMessage)
        onError?.(imageId, errorMessage)
      }
    }

    info(`Upload process completed. ${results.length}/${files.length} images uploaded successfully`)
    return results
  }

  /**
   * Deletes an image from Supabase storage
   */
  static async deleteImage(path: string): Promise<void> {
    if (!path) {
      throw new Error('Image path is required for deletion')
    }

    await supabase.storage.from('listing-images').remove([path])
  }

  /**
   * Deletes multiple images
   */
  static async deleteImages(paths: string[]): Promise<void> {
    if (paths.length === 0) return

    await supabase.storage.from('listing-images').remove(paths)
  }

  /**
   * Creates a preview URL for a file
   */
  static createPreviewUrl(file: File): string {
    return URL.createObjectURL(file)
  }

  /**
   * Revokes a preview URL to free memory
   */
  static revokePreviewUrl(url: string): void {
    try {
      URL.revokeObjectURL(url)
    } catch (error) {
      console.warn('Failed to revoke preview URL:', error)
    }
  }

  /**
   * Cleanup orphaned images (to be called periodically)
   */
  static async cleanupOrphanedImages(userId: string, validPaths: string[]): Promise<void> {
    try {
      if (!userId) {
        throw new Error('User ID is required for cleanup')
      }

      // List all images for the user
      const { data: files } = await supabase.storage.from('listing-images').list(userId)

      // Find orphaned files
      const orphanedPaths =
        files
          ?.filter(file => !validPaths.includes(`${userId}/${file.name}`))
          .map(file => `${userId}/${file.name}`) || []

      // Delete orphaned files
      if (orphanedPaths.length > 0) {
        await this.deleteImages(orphanedPaths)
        info(`Cleaned up ${orphanedPaths.length} orphaned images`)
      }
    } catch (err) {
      error('Failed to cleanup orphaned images:', err)
      // Don't throw here - cleanup is not critical
    }
  }
}
