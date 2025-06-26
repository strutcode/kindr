import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from './auth'
import type { Chat, ChatMessage, ChatState } from '@/types'
import type { RealtimeChannel } from '@supabase/supabase-js'

export const useChatStore = defineStore('chat', () => {
  const state = ref<ChatState>({
    chats: [],
    currentChatId: null,
    messages: {},
    loading: false,
    hasMore: {},
    unreadCount: 0,
  })

  let chatChannel: RealtimeChannel | null = null
  let messageChannels: Record<string, RealtimeChannel> = {}
  let isInitialized = false

  const authStore = useAuthStore()

  // Computed properties
  const currentChat = computed(() =>
    state.value.chats.find(chat => chat.id === state.value.currentChatId),
  )

  const currentMessages = computed(() =>
    state.value.currentChatId ? state.value.messages[state.value.currentChatId] || [] : [],
  )

  const sortedChats = computed(() =>
    [...state.value.chats].sort(
      (a, b) => new Date(b.last_message_at).getTime() - new Date(a.last_message_at).getTime(),
    ),
  )

  // Initialize realtime subscriptions
  const initializeRealtime = () => {
    if (!authStore.user || chatChannel) return // Prevent multiple subscriptions

    // Subscribe to chats changes
    chatChannel = supabase
      .channel(`user_chats_${authStore.user.id}`) // Make channel name unique per user
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'chats',
          filter: `requester_id=eq.${authStore.user.id},listing_owner_id=eq.${authStore.user.id}`,
        },
        payload => {
          handleChatChange(payload)
        },
      )
      .subscribe()
  }

  // Clean up realtime subscriptions
  const cleanupRealtime = () => {
    if (chatChannel) {
      supabase.removeChannel(chatChannel)
      chatChannel = null
    }

    Object.values(messageChannels).forEach(channel => {
      supabase.removeChannel(channel)
    })
    messageChannels = {}
  }

  // Handle chat changes from realtime
  const handleChatChange = (payload: any) => {
    const { eventType, new: newRecord, old: oldRecord } = payload

    switch (eventType) {
      case 'INSERT':
        if (newRecord && !state.value.chats.find(c => c.id === newRecord.id)) {
          fetchChatDetails(newRecord.id)
        }
        break
      case 'UPDATE':
        if (newRecord) {
          const chatIndex = state.value.chats.findIndex(c => c.id === newRecord.id)
          if (chatIndex >= 0) {
            state.value.chats[chatIndex] = { ...state.value.chats[chatIndex], ...newRecord }
            calculateUnreadCount()
          }
        }
        break
      case 'DELETE':
        if (oldRecord) {
          state.value.chats = state.value.chats.filter(c => c.id !== oldRecord.id)
          delete state.value.messages[oldRecord.id]
          delete state.value.hasMore[oldRecord.id]
          if (messageChannels[oldRecord.id]) {
            supabase.removeChannel(messageChannels[oldRecord.id])
            delete messageChannels[oldRecord.id]
          }
          calculateUnreadCount()
        }
        break
    }
  }

  // Subscribe to messages for a specific chat
  const subscribeToMessages = (chatId: string) => {
    if (messageChannels[chatId]) return // Prevent multiple subscriptions

    messageChannels[chatId] = supabase
      .channel(`chat_messages_${chatId}_${authStore.user?.id}`) // Make channel name unique
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
          filter: `chat_id=eq.${chatId}`,
        },
        payload => {
          handleMessageInsert(payload.new)
        },
      )
      .subscribe()
  }

  // Handle new message from realtime
  const handleMessageInsert = async (newMessage: any) => {
    // Fetch complete message with user info
    const { data: messageData } = await supabase.rpc('get_chat_messages', {
      p_chat_id: newMessage.chat_id,
      p_limit: 1,
    })

    if (messageData && messageData.length > 0) {
      const message = messageData[0] as ChatMessage

      if (!state.value.messages[newMessage.chat_id]) {
        state.value.messages[newMessage.chat_id] = []
      }

      // Add message if not already present (avoid duplicates)
      const existingIndex = state.value.messages[newMessage.chat_id].findIndex(
        m => m.id === message.id,
      )
      if (existingIndex === -1) {
        state.value.messages[newMessage.chat_id].unshift(message)
      }

      // Update chat last message info
      const chatIndex = state.value.chats.findIndex(c => c.id === newMessage.chat_id)
      if (chatIndex >= 0) {
        state.value.chats[chatIndex].last_message = message
        state.value.chats[chatIndex].last_message_at = message.created_at
      }
    }
  }

  // Fetch all chats for the current user
  const fetchChats = async () => {
    if (!authStore.user) return

    state.value.loading = true
    try {
      const { data: chatsData, error } = await supabase
        .from('chats')
        .select(
          `
          *,
          listing:listings(id, title, category),
          requester:users!chats_requester_id_fkey(id, full_name, avatar_url),
          owner:users!chats_listing_owner_id_fkey(id, full_name, avatar_url)
        `,
        )
        .or(`requester_id.eq.${authStore.user.id},listing_owner_id.eq.${authStore.user.id}`)
        .order('last_message_at', { ascending: false })

      if (error) throw error

      // Transform chats to include other_user info
      state.value.chats =
        chatsData?.map((chat: any) => ({
          ...chat,
          other_user: chat.requester_id === authStore.user?.id ? chat.owner : chat.requester,
        })) || []

      // Fetch last message for each chat
      await Promise.all(state.value.chats.map(chat => fetchLastMessage(chat.id)))

      calculateUnreadCount()
    } catch (error) {
      console.error('Error fetching chats:', error)
    } finally {
      state.value.loading = false
    }
  }

  // Fetch last message for a chat
  const fetchLastMessage = async (chatId: string) => {
    try {
      const { data: messagesData } = await supabase.rpc('get_chat_messages', {
        p_chat_id: chatId,
        p_limit: 1,
      })

      if (messagesData && messagesData.length > 0) {
        const chatIndex = state.value.chats.findIndex(c => c.id === chatId)
        if (chatIndex >= 0) {
          state.value.chats[chatIndex].last_message = messagesData[0] as ChatMessage
        }
      }
    } catch (error) {
      console.error('Error fetching last message:', error)
    }
  }

  // Fetch chat details by ID
  const fetchChatDetails = async (chatId: string) => {
    try {
      const { data: chatData, error } = await supabase
        .from('chats')
        .select(
          `
          *,
          listing:listings(id, title, category),
          requester:users!chats_requester_id_fkey(id, full_name, avatar_url),
          owner:users!chats_listing_owner_id_fkey(id, full_name, avatar_url)
        `,
        )
        .eq('id', chatId)
        .single()

      if (error) throw error

      const chat = {
        ...chatData,
        other_user:
          chatData.requester_id === authStore.user?.id ? chatData.owner : chatData.requester,
      }

      const existingIndex = state.value.chats.findIndex(c => c.id === chatId)
      if (existingIndex >= 0) {
        state.value.chats[existingIndex] = chat
      } else {
        state.value.chats.push(chat)
      }

      await fetchLastMessage(chatId)
      calculateUnreadCount()
    } catch (error) {
      console.error('Error fetching chat details:', error)
    }
  }

  // Load messages for a chat
  const loadMessages = async (chatId: string, beforeId?: string) => {
    try {
      const { data: messagesData, error } = await supabase.rpc('get_chat_messages', {
        p_chat_id: chatId,
        p_limit: 15,
        p_before_id: beforeId || null,
      })

      if (error) throw error

      if (!state.value.messages[chatId]) {
        state.value.messages[chatId] = []
      }

      const messages = (messagesData || []) as ChatMessage[]

      if (beforeId) {
        // Pagination - append older messages
        state.value.messages[chatId].push(...messages)
      } else {
        // Initial load - replace messages
        state.value.messages[chatId] = messages
      }

      // Check if there are more messages
      state.value.hasMore[chatId] = messages.length === 15

      // Subscribe to realtime updates for this chat
      subscribeToMessages(chatId)
    } catch (error) {
      console.error('Error loading messages:', error)
    }
  }

  // Send a message
  const sendMessage = async (
    chatId: string,
    content: string,
    messageType: 'text' | 'image' = 'text',
    imageUrl?: string,
  ) => {
    try {
      const { data: messageId, error } = await supabase.rpc('send_chat_message', {
        p_chat_id: chatId,
        p_message_type: messageType,
        p_content: messageType === 'text' ? content : null,
        p_image_url: imageUrl || null,
      })

      if (error) throw error

      return messageId
    } catch (error) {
      console.error('Error sending message:', error)
      throw error
    }
  }

  // Upload chat image
  const uploadChatImage = async (file: File, chatId: string): Promise<string> => {
    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${authStore.user?.id}/${chatId}/${Date.now()}.${fileExt}`

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('chat-images')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) throw uploadError

      const { data: urlData } = supabase.storage.from('chat-images').getPublicUrl(uploadData.path)

      return urlData.publicUrl
    } catch (error) {
      console.error('Error uploading chat image:', error)
      throw error
    }
  }

  // Get or create a chat for a listing
  const getOrCreateChat = async (listingId: string): Promise<string> => {
    try {
      const { data: chatId, error } = await supabase.rpc('get_or_create_chat', {
        p_listing_id: listingId,
      })

      if (error) throw error

      // Fetch the chat details if it's new
      await fetchChatDetails(chatId)

      return chatId
    } catch (error) {
      console.error('Error getting or creating chat:', error)
      throw error
    }
  }

  // Mark chat as read
  const markChatAsRead = async (chatId: string) => {
    try {
      const { error } = await supabase.rpc('mark_chat_as_read', {
        p_chat_id: chatId,
      })

      if (error) throw error

      // Update local state
      const chatIndex = state.value.chats.findIndex(c => c.id === chatId)
      if (chatIndex >= 0 && authStore.user) {
        const chat = state.value.chats[chatIndex]
        if (chat.requester_id === authStore.user.id) {
          chat.requester_unread_count = 0
        } else {
          chat.owner_unread_count = 0
        }
      }

      calculateUnreadCount()
    } catch (error) {
      console.error('Error marking chat as read:', error)
    }
  }

  // Calculate total unread count
  const calculateUnreadCount = () => {
    if (!authStore.user) {
      state.value.unreadCount = 0
      return
    }

    state.value.unreadCount = state.value.chats.reduce((total, chat) => {
      if (chat.requester_id === authStore.user?.id) {
        return total + chat.requester_unread_count
      } else {
        return total + chat.owner_unread_count
      }
    }, 0)
  }

  // Set current chat
  const setCurrentChat = (chatId: string | null) => {
    state.value.currentChatId = chatId
    if (chatId && !state.value.messages[chatId]) {
      loadMessages(chatId)
    }
    if (chatId) {
      markChatAsRead(chatId)
    }
  }

  // Load more messages (pagination)
  const loadMoreMessages = async (chatId: string) => {
    const messages = state.value.messages[chatId]
    if (!messages || messages.length === 0 || !state.value.hasMore[chatId]) return

    const oldestMessage = messages[messages.length - 1]
    await loadMessages(chatId, oldestMessage.id)
  }

  // Initialize store
  const initialize = () => {
    if (isInitialized || !authStore.user) return

    isInitialized = true
    fetchChats()
    initializeRealtime()
  }

  // Cleanup store
  const cleanup = () => {
    cleanupRealtime()
    state.value.chats = []
    state.value.messages = {}
    state.value.currentChatId = null
    state.value.hasMore = {}
    state.value.unreadCount = 0
    isInitialized = false
  }

  return {
    // State
    chats: computed(() => state.value.chats),
    currentChatId: computed(() => state.value.currentChatId),
    messages: computed(() => state.value.messages),
    loading: computed(() => state.value.loading),
    hasMore: computed(() => state.value.hasMore),
    unreadCount: computed(() => state.value.unreadCount),
    currentChat,
    currentMessages,
    sortedChats,

    // Actions
    initialize,
    cleanup,
    fetchChats,
    loadMessages,
    sendMessage,
    uploadChatImage,
    getOrCreateChat,
    markChatAsRead,
    setCurrentChat,
    loadMoreMessages,
  }
})
