import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function login(email, password) {
    try {
      loading.value = true
      error.value = null
      
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (authError) throw authError

      user.value = data.user
      return data
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function register(email, password, displayName, phone, role = 'produtor') {
    try {
      loading.value = true
      error.value = null
      
      const { data, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            display_name: displayName,
            phone: phone,
            role: role
          }
        }
      })

      if (authError) throw authError

      return data
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    try {
      loading.value = true
      error.value = null
      
      console.log('Verificando sessão atual...')
      const { data: { session } } = await supabase.auth.getSession()
      
      // Only attempt signOut if there's an active session
      if (session) {
        console.log('Sessão ativa encontrada, realizando signOut')
        const { error: authError } = await supabase.auth.signOut()
        if (authError) throw authError
      } else {
        console.log('Nenhuma sessão ativa encontrada')
      }

      console.log('Limpando dados do usuário')
      user.value = null
      
      return true
    } catch (err) {
      console.error('Erro completo no logout:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function checkUser() {
    try {
      loading.value = true
      const { data: { session } } = await supabase.auth.getSession()
      user.value = session?.user || null
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    loading,
    error,
    login,
    register,
    logout,
    checkUser
  }
}) 