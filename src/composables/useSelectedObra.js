import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabaseClient'

const selectedObra = ref(null)

export function useSelectedObra() {
  const authStore = useAuthStore()

  const loadSelectedObra = async () => {
    try {
      const { data: obraSelecionada, error } = await supabase
        .from('obra_selecionada')
        .select('*, obras(*)')
        .eq('usuario_id', authStore.user?.id)
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
      if (!obra) {
        // If no obra is selected, delete the current selection
        const { error: deleteError } = await supabase
          .from('obra_selecionada')
          .delete()
          .eq('usuario_id', authStore.user?.id)

        if (deleteError) throw deleteError
        selectedObra.value = null
        return
      }

      // Upsert the obra selection
      const { error: upsertError } = await supabase
        .from('obra_selecionada')
        .upsert({
          usuario_id: authStore.user?.id,
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

  return {
    selectedObra,
    handleObraSelection,
    loadSelectedObra
  }
} 