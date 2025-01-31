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

      // First clear local state
      user.value = null
      
      // Get current session
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        console.log('Sessão encontrada, realizando signOut...')
        // Try to sign out from Supabase
        const { error: signOutError } = await supabase.auth.signOut()
        if (signOutError) {
          console.error('Erro no signOut do Supabase:', signOutError)
        }
      } else {
        console.log('Nenhuma sessão ativa encontrada')
      }

      // Clear any stored auth data
      console.log('Limpando dados de autenticação do localStorage...')
      localStorage.removeItem('teclab-auth')
      localStorage.removeItem(`sb-${import.meta.env.VITE_SUPABASE_URL}-auth-token`)
      
      // Clear any other app state if needed
      sessionStorage.clear()
      
      return true
    } catch (err) {
      console.error('Erro no logout:', err)
      error.value = err.message
      // Even if there's an error, we want to clear the state
      user.value = null
      return true
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