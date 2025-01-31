<template>
  <!-- Layout autenticado -->
  <q-layout v-if="isAuthenticated" view="hHh lpR fFf">
    <q-header elevated class="bg-white text-dark" style="height: 64px">
      <q-toolbar class="q-px-lg" style="height: 64px">
        <q-btn
          flat
          dense
          round
          icon="menu"
          size="md"
          color="primary"
          aria-label="Menu"
          @click="toggleLeftDrawer"
        />

        <q-toolbar-title class="text-primary q-ml-md">
          <div class="text-h5 text-weight-bold">TECLAB</div>
        </q-toolbar-title>

        <q-space />

        <q-btn-dropdown flat color="primary" class="q-ml-sm">
          <template v-slot:label>
            <q-icon name="person" size="sm" />
          </template>

          <q-list>
            <q-item>
              <q-item-section>
                <div class="text-subtitle1">{{ authStore.user?.user_metadata?.display_name }}</div>
                <div class="text-caption text-grey-7">{{ authStore.user?.email }}</div>
              </q-item-section>
            </q-item>
            
            <q-separator class="q-my-sm" />
            
            <q-item>
              <q-item-section>
                <q-select
                  v-model="selectedObra"
                  :options="availableObras"
                  label="Selecionar Obra"
                  option-label="nome"
                  dense
                  outlined
                  emit-value
                  map-options
                  clearable
                  class="full-width"
                  @update:model-value="handleObraSelection"
                >
                  <template v-slot:option="{ itemProps, opt }">
                    <q-item v-bind="itemProps">
                      <q-item-section>
                        <q-item-label>{{ opt.nome }}</q-item-label>
                        <q-item-label caption>{{ opt.codigo }}</q-item-label>
                      </q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </q-item-section>
            </q-item>
            
            <q-separator class="q-my-sm" />
            
            <q-item clickable v-close-popup @click="handleLogout" class="text-negative">
              <q-item-section avatar>
                <q-icon name="logout" color="negative" />
              </q-item-section>
              <q-item-section>Sair</q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      :width="280"
      class="bg-grey-1"
    >
      <q-scroll-area class="fit">
        <q-list padding>
          <q-item-label header class="text-grey-8 text-weight-bold">Menu</q-item-label>

          <q-item to="/" exact clickable v-ripple class="q-mb-sm">
            <q-item-section avatar>
              <q-icon name="home" color="primary" size="md" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">Início</q-item-label>
            </q-item-section>
          </q-item>

          <q-item to="/ensaios" exact clickable v-ripple class="q-mb-sm">
            <q-item-section avatar>
              <q-icon name="science" color="primary" size="md" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">Ensaios</q-item-label>
            </q-item-section>
          </q-item>

          <q-item to="/relatorios" exact clickable v-ripple class="q-mb-sm">
            <q-item-section avatar>
              <q-icon name="description" color="primary" size="md" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">Relatórios</q-item-label>
            </q-item-section>
          </q-item>

          <q-item to="/obras" exact clickable v-ripple class="q-mb-sm">
            <q-item-section avatar>
              <q-icon name="business" color="primary" size="md" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">Obras</q-item-label>
            </q-item-section>
          </q-item>

          <q-item 
            v-if="canAccessUsers"
            to="/usuarios" 
            exact 
            clickable 
            v-ripple 
            class="q-mb-sm"
          >
            <q-item-section avatar>
              <q-icon name="group" color="primary" size="md" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">Usuários</q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </q-scroll-area>
    </q-drawer>

    <q-page-container class="bg-grey-1">
      <router-view v-slot="{ Component }">
        <transition
          enter-active-class="animate__animated animate__fadeIn"
          leave-active-class="animate__animated animate__fadeOut"
          mode="out-in"
        >
          <component :is="Component" />
        </transition>
      </router-view>
    </q-page-container>
  </q-layout>

  <!-- Layout não autenticado -->
  <q-layout v-else view="hHh lpR fFf">
    <q-page-container>
      <router-view v-slot="{ Component }">
        <transition
          enter-active-class="animate__animated animate__fadeIn"
          leave-active-class="animate__animated animate__fadeOut"
          mode="out-in"
        >
          <component :is="Component" />
        </transition>
      </router-view>
    </q-page-container>
  </q-layout>
</template>

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

const { selectedObra, handleObraSelection, loadSelectedObra } = useSelectedObra()

const isAuthenticated = computed(() => !!authStore.user)

const currentUserRole = computed(() => 
  authStore.user?.user_metadata?.role || 'produtor'
)

const canAccessUsers = computed(() => {
  const role = currentUserRole.value
  return role === 'master' || role === 'administrador'
})

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

onMounted(() => {
  if (authStore.user) {
    loadUserObras()
    loadSelectedObra()
  }
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
</script> 