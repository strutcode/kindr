import { supabase } from '@/lib/supabase'

/**
 * Security service for input validation, rate limiting, and XSS protection
 */
export class SecurityService {
  private static readonly MAX_REQUESTS_PER_MINUTE = 60
  private static readonly MAX_REQUESTS_PER_HOUR = 1000
  private static requestCounts = new Map<string, { count: number; resetTime: number }>()

  /**
   * Rate limiting based on user ID or IP address
   */
  static checkRateLimit(identifier: string, maxRequests: number = this.MAX_REQUESTS_PER_MINUTE): boolean {
    const now = Date.now()
    const windowMs = 60 * 1000 // 1 minute window
    
    const userRequests = this.requestCounts.get(identifier)
    
    if (!userRequests || now > userRequests.resetTime) {
      // Reset or initialize counter
      this.requestCounts.set(identifier, {
        count: 1,
        resetTime: now + windowMs
      })
      return true
    }
    
    if (userRequests.count >= maxRequests) {
      return false // Rate limit exceeded
    }
    
    userRequests.count++
    return true
  }

  /**
   * Sanitize HTML content to prevent XSS attacks
   */
  static sanitizeHtml(input: string): string {
    // Basic HTML sanitization - remove script tags and dangerous attributes
    return input
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/javascript:/gi, '')
      .replace(/on\w+\s*=/gi, '')
      .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
      .replace(/<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi, '')
      .replace(/<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi, '')
      .trim()
  }

  /**
   * Validate and sanitize text input
   */
  static validateTextInput(input: string, maxLength: number = 1000): { valid: boolean; sanitized: string; errors: string[] } {
    const errors: string[] = []
    
    if (!input || typeof input !== 'string') {
      errors.push('Input must be a non-empty string')
      return { valid: false, sanitized: '', errors }
    }
    
    if (input.length > maxLength) {
      errors.push(`Input must be ${maxLength} characters or less`)
    }
    
    // Check for suspicious patterns
    const suspiciousPatterns = [
      /<script/i,
      /javascript:/i,
      /vbscript:/i,
      /data:text\/html/i,
      /onclick/i,
      /onerror/i,
      /onload/i
    ]
    
    for (const pattern of suspiciousPatterns) {
      if (pattern.test(input)) {
        errors.push('Input contains potentially dangerous content')
        break
      }
    }
    
    const sanitized = this.sanitizeHtml(input)
    
    return {
      valid: errors.length === 0,
      sanitized,
      errors
    }
  }

  /**
   * Validate email format
   */
  static validateEmail(email: string): { valid: boolean; errors: string[] } {
    const errors: string[] = []
    
    if (!email || typeof email !== 'string') {
      errors.push('Email is required')
      return { valid: false, errors }
    }
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      errors.push('Invalid email format')
    }
    
    if (email.length > 254) {
      errors.push('Email is too long')
    }
    
    return {
      valid: errors.length === 0,
      errors
    }
  }

  /**
   * Validate phone number format
   */
  static validatePhone(phone: string): { valid: boolean; errors: string[] } {
    const errors: string[] = []
    
    if (!phone || typeof phone !== 'string') {
      return { valid: true, errors } // Phone is optional
    }
    
    // Remove all non-digit characters for validation
    const digitsOnly = phone.replace(/\D/g, '')
    
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      errors.push('Phone number must be between 10 and 15 digits')
    }
    
    // Check for valid international format
    const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/
    const cleanPhone = phone.replace(/[\s\-\(\)]/g, '')
    
    if (!phoneRegex.test(cleanPhone)) {
      errors.push('Invalid phone number format')
    }
    
    return {
      valid: errors.length === 0,
      errors
    }
  }

  /**
   * Validate coordinates
   */
  static validateCoordinates(lat: number, lng: number): { valid: boolean; errors: string[] } {
    const errors: string[] = []
    
    if (typeof lat !== 'number' || typeof lng !== 'number') {
      errors.push('Coordinates must be numbers')
      return { valid: false, errors }
    }
    
    if (isNaN(lat) || isNaN(lng)) {
      errors.push('Coordinates cannot be NaN')
      return { valid: false, errors }
    }
    
    if (lat < -90 || lat > 90) {
      errors.push('Latitude must be between -90 and 90')
    }
    
    if (lng < -180 || lng > 180) {
      errors.push('Longitude must be between -180 and 180')
    }
    
    return {
      valid: errors.length === 0,
      errors
    }
  }

  /**
   * Generate CSRF token
   */
  static generateCSRFToken(): string {
    const array = new Uint8Array(32)
    crypto.getRandomValues(array)
    return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('')
  }

  /**
   * Validate CSRF token
   */
  static validateCSRFToken(token: string, expectedToken: string): boolean {
    if (!token || !expectedToken) return false
    return token === expectedToken
  }

  /**
   * Check if user has permission to perform action
   */
  static async validateUserPermission(
    userId: string, 
    action: 'create' | 'read' | 'update' | 'delete',
    resourceType: 'request' | 'review' | 'reputation',
    resourceId?: string
  ): Promise<{ valid: boolean; message?: string }> {
    try {
      // Get current user session
      const { data: { session }, error } = await supabase.auth.getSession()
      
      if (error || !session) {
        return { valid: false, message: 'Not authenticated' }
      }
      
      // Check if user ID matches session
      if (session.user.id !== userId) {
        return { valid: false, message: 'User ID mismatch' }
      }
      
      // For resource-specific actions, check ownership
      if (resourceId && (action === 'update' || action === 'delete')) {
        let ownershipQuery
        
        switch (resourceType) {
          case 'request':
            ownershipQuery = supabase
              .from('requests')
              .select('user_id')
              .eq('id', resourceId)
              .single()
            break
          case 'review':
            ownershipQuery = supabase
              .from('reviews')
              .select('reviewer_id')
              .eq('id', resourceId)
              .single()
            break
          case 'reputation':
            ownershipQuery = supabase
              .from('reputation')
              .select('user_id')
              .eq('id', resourceId)
              .single()
            break
          default:
            return { valid: false, message: 'Invalid resource type' }
        }
        
        const { data, error: queryError } = await ownershipQuery
        
        if (queryError || !data) {
          return { valid: false, message: 'Resource not found' }
        }
        
        const ownerField = resourceType === 'review' ? 'reviewer_id' : 'user_id'
        if (data[ownerField] !== userId) {
          return { valid: false, message: 'Not authorized to modify this resource' }
        }
      }
      
      return { valid: true }
    } catch (error) {
      console.error('Permission validation error:', error)
      return { valid: false, message: 'Permission validation failed' }
    }
  }

  /**
   * Log security event
   */
  static logSecurityEvent(
    event: 'rate_limit_exceeded' | 'xss_attempt' | 'unauthorized_access' | 'invalid_input',
    details: Record<string, any>
  ): void {
    console.warn(`Security Event: ${event}`, {
      timestamp: new Date().toISOString(),
      ...details
    })
    
    // In production, you might want to send this to a security monitoring service
    // or store in a security events table
  }

  /**
   * Clean up old rate limit entries
   */
  static cleanupRateLimits(): void {
    const now = Date.now()
    for (const [key, value] of this.requestCounts.entries()) {
      if (now > value.resetTime) {
        this.requestCounts.delete(key)
      }
    }
  }
}

// Cleanup rate limits every 5 minutes
if (typeof window !== 'undefined') {
  setInterval(() => {
    SecurityService.cleanupRateLimits()
  }, 5 * 60 * 1000)
}