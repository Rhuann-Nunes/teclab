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

      // Primeiro, limpa o estado local
      user.value = null
      
      try {
        // Tenta fazer o signOut do Supabase
        await supabase.auth.signOut()
      } catch (signOutError) {
        console.log('Erro ao fazer signOut do Supabase (ignorando):', signOutError)
      }

      // Força limpeza do localStorage
      localStorage.removeItem('sb-' + import.meta.env.VITE_SUPABASE_URL + '-auth-token')
      
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