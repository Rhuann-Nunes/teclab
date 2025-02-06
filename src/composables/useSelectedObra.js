import { ref, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabaseClient'

const selectedObra = ref(null)

export function useSelectedObra() {
  const authStore = useAuthStore()

  const loadSelectedObra = async () => {
    try {
      // Only proceed if we have a user
      if (!authStore.user?.id) {
        selectedObra.value = null
        return
      }

      const { data: obraSelecionada, error } = await supabase
        .from('obra_selecionada')
        .select('*, obras(*)')
        .eq('usuario_id', authStore.user.id)
        .single()

      if (error && error.code !== 'PGRST116') throw error
      
      selectedObra.value = obraSelecionada?.obras || null
    } catch (error) {
      console.error('Error loading selected obra:', error)
      selectedObra.value = null
    }
  }

  const handleObraSelection = async (obra) => {
    try {
      if (!authStore.user?.id) {
        console.error('No authenticated user found')
        return
      }

      if (!obra) {
        // If no obra is selected, delete the current selection
        const { error: deleteError } = await supabase
          .from('obra_selecionada')
          .delete()
          .eq('usuario_id', authStore.user.id)

        if (deleteError) throw deleteError
        selectedObra.value = null
        return
      }

      // Upsert the obra selection
      const { error: upsertError } = await supabase
        .from('obra_selecionada')
        .upsert({
          usuario_id: authStore.user.id,
          obra_id: obra.id
        })

      if (upsertError) throw upsertError
      selectedObra.value = obra
    } catch (error) {
      console.error('Error handling obra selection:', error)
      // Revert the local state in case of error
      await loadSelectedObra()
    }
  }

  // Watch for changes in the auth user
  watch(() => authStore.user, (newUser) => {
    if (newUser) {
      loadSelectedObra()
    } else {
      selectedObra.value = null
    }
  }, { immediate: true }) // immediate: true ensures it runs on component mount

  return {
    selectedObra,
    handleObraSelection,
    loadSelectedObra
  }
} 