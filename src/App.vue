<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/auth'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { supabase } from '@/lib/supabase'

const router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()
const leftDrawerOpen = ref(false)
const availableObras = ref([])

const { selectedObra, loadSelectedObra } = useSelectedObra()

// Computed property para verificar se o usuário está autenticado
const isAuthenticated = computed(() => !!authStore.user)

const currentUserRole = computed(() => 
  authStore.user?.user_metadata?.role || 'produtor'
)

const canAccessUsers = computed(() => {
  const role = currentUserRole.value
  return role === 'master' || role === 'administrador'
})

const toggleLeftDrawer = () => {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

const handleLogout = async () => {
  try {
    await authStore.logout()
    router.push('/login')
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Erro ao fazer logout.'
    })
  }
}

// Load user's obras
const loadUserObras = async () => {
  try {
    const isMaster = authStore.user?.user_metadata?.role === 'master'
    
    const { data: obras, error } = await supabase
      .from('obras')
      .select(isMaster ? '*' : '*, usuarios_obras!inner(*)')
      .eq(isMaster ? '' : 'usuarios_obras.usuario_id', isMaster ? '' : authStore.user?.id)
      .order('nome')

    if (error) throw error
    availableObras.value = obras
  } catch (error) {
    console.error('Error loading obras:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar obras'
    })
  }
}

// Handle obra selection
const handleObraSelection = async (obra) => {
  try {
    if (!obra) {
      // Remove selected obra
      await supabase
        .from('obra_selecionada')
        .delete()
        .eq('usuario_id', authStore.user?.id)
      
      selectedObra.value = null
      return
    }

    // Upsert selected obra
    const { error } = await supabase
      .from('obra_selecionada')
      .upsert({
        usuario_id: authStore.user?.id,
        obra_id: obra.id,
        data_selecao: new Date().toISOString()
      })

    if (error) throw error

    await loadSelectedObra()

    $q.notify({
      type: 'positive',
      message: 'Obra selecionada com sucesso'
    })
  } catch (error) {
    console.error('Error selecting obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao selecionar obra'
    })
  }
}

// Add to onMounted
onMounted(() => {
  if (authStore.user) {
    loadUserObras()
    loadSelectedObra()
  }
})
</script>

<template>
  <router-view />
</template>

<style>
:root {
  --animate-duration: 200ms;
}

body {
  font-family: 'Inter', sans-serif;
  background: #f8fafc;
  color: #1e293b;
  margin: 0;
}

.q-drawer {
  border-right: 1px solid rgba(0, 0, 0, 0.05) !important;
}

.q-header {
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.q-item {
  border-radius: 8px;
  margin: 0 8px;
}

.q-item.q-router-link--active {
  background: rgba(25, 118, 210, 0.1);
}

.q-card {
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  transition: all 0.3s ease;
}

.q-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.q-btn {
  border-radius: 8px;
  font-weight: 500;
}

.q-table {
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.q-table th {
  font-weight: 600;
}

.dashboard-card {
  transition: all 0.3s ease;
}

.dashboard-card:hover {
  transform: translateY(-2px);
}
</style>
