<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Usuários da Obra</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Usuários -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Usuários Vinculados</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="person_add" size="sm" @click="showAddUserDialog = true">
              <q-tooltip>Vincular Usuário</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando usuários...</div>
        </div>

        <div v-else-if="!vinculatedUsers.length" class="text-center q-pa-lg">
          <q-icon name="group_off" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhum usuário vinculado</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item v-for="user in vinculatedUsers" :key="user.id">
            <q-item-section>
              <q-item-label class="text-weight-medium">{{ user.user_metadata?.display_name }}</q-item-label>
              <q-item-label caption>{{ user.email }}</q-item-label>
              <q-item-label caption class="text-primary">{{ user.user_metadata?.role || 'Sem perfil' }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn flat round color="negative" icon="person_remove" @click="confirmRemoveUser(user)">
                <q-tooltip>Remover usuário</q-tooltip>
              </q-btn>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar usuário -->
    <q-dialog v-model="showAddUserDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Vincular Usuário</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-select
            v-model="selectedUsers"
            :options="availableUsers"
            label="Selecionar Usuários"
            outlined
            multiple
            use-chips
            option-value="id"
            :option-label="opt => opt.user_metadata?.display_name || opt.email"
            class="q-mb-md"
          >
            <template v-slot:option="{ itemProps, opt, selected, toggleOption }">
              <q-item v-bind="itemProps">
                <q-item-section>
                  <q-item-label>{{ opt.user_metadata?.display_name || opt.email }}</q-item-label>
                  <q-item-label caption>{{ opt.user_metadata?.role || 'Sem perfil' }}</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-checkbox :model-value="selected" @update:model-value="toggleOption" />
                </q-item-section>
              </q-item>
            </template>
          </q-select>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Vincular" color="primary" @click="addUsers" :loading="saving" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const route = useRoute()
const authStore = useAuthStore()

const obraId = route.params.id
const obra = ref(null)
const loading = ref(true)
const saving = ref(false)
const showAddUserDialog = ref(false)
const vinculatedUsers = ref([])
const availableUsers = ref([])
const selectedUsers = ref([])

const loadObra = async () => {
  try {
    const { data, error } = await supabase
      .from('obras')
      .select('*')
      .eq('id', obraId)
      .single()
    
    if (error) throw error
    obra.value = data
  } catch (error) {
    console.error('Erro ao carregar obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar obra'
    })
  }
}

const loadVinculatedUsers = async () => {
  try {
    loading.value = true
    
    const { data: vinculos, error: vinculosError } = await supabase
      .from('usuarios_obras')
      .select('usuario_id')
      .eq('obra_id', obraId)
    
    if (vinculosError) throw vinculosError

    const { data: users, error: usersError } = await supabase.functions.invoke('list-users')
    if (usersError) throw usersError

    vinculatedUsers.value = users.users.filter(user => 
      vinculos.some(vinculo => vinculo.usuario_id === user.id)
    )
  } catch (error) {
    console.error('Erro ao carregar usuários vinculados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar usuários vinculados'
    })
  } finally {
    loading.value = false
  }
}

const loadAvailableUsers = async () => {
  try {
    const { data: users, error } = await supabase.functions.invoke('list-users')
    if (error) throw error
    
    // Filtra usuários que já não estão vinculados e não são master
    availableUsers.value = users.users.filter(user => 
      user.user_metadata?.role !== 'master' &&
      !vinculatedUsers.value.some(vu => vu.id === user.id)
    )
  } catch (error) {
    console.error('Erro ao carregar usuários disponíveis:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar usuários disponíveis'
    })
  }
}

const addUsers = async () => {
  if (!selectedUsers.value.length) return

  try {
    saving.value = true
    
    const vinculos = selectedUsers.value.map(user => ({
      obra_id: obraId,
      usuario_id: user.id,
      usuario_cadastro: authStore.user.user_metadata.display_name
    }))
    
    const { error } = await supabase
      .from('usuarios_obras')
      .insert(vinculos)
    
    if (error) throw error
    
    showAddUserDialog.value = false
    selectedUsers.value = []
    await loadVinculatedUsers()
    
    $q.notify({
      type: 'positive',
      message: 'Usuários vinculados com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao vincular usuários:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao vincular usuários'
    })
  } finally {
    saving.value = false
  }
}

const confirmRemoveUser = (user) => {
  $q.dialog({
    title: 'Confirmar Remoção',
    message: `Tem certeza que deseja remover o usuário "${user.user_metadata?.display_name || user.email}" da obra?`,
    ok: {
      label: 'Remover',
      color: 'negative'
    },
    cancel: {
      label: 'Cancelar',
      flat: true
    },
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('usuarios_obras')
        .delete()
        .eq('obra_id', obraId)
        .eq('usuario_id', user.id)
      
      if (error) throw error
      
      await loadVinculatedUsers()
      await loadAvailableUsers()
      
      $q.notify({
        type: 'positive',
        message: 'Usuário removido com sucesso!'
      })
    } catch (error) {
      console.error('Erro ao remover usuário:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao remover usuário'
      })
    }
  })
}

onMounted(async () => {
  await loadObra()
  await loadVinculatedUsers()
})

// Watch para carregar usuários disponíveis quando o diálogo é aberto
watch(showAddUserDialog, async (newValue) => {
  if (newValue) {
    await loadAvailableUsers()
  }
})
</script> 