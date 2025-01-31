import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from './auth'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const authStore = useAuthStore()

  async function loadUser() {
    try {
      loading.value = true
      error.value = null
      
      if (!authStore.user) {
        user.value = null
        return
      }

      const { data, error: dbError } = await supabase
        .from('users')
        .select('*')
        .eq('id', authStore.user.id)
        .single()

      if (dbError) throw dbError

      user.value = {
        ...data,
        ...authStore.user
      }
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateUser(userData) {
    try {
      loading.value = true
      error.value = null

      const { data, error: dbError } = await supabase
        .from('users')
        .update(userData)
        .eq('id', authStore.user.id)
        .select()
        .single()

      if (dbError) throw dbError

      user.value = {
        ...user.value,
        ...data
      }

      return data
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    loading,
    error,
    loadUser,
    updateUser
  }
}) 