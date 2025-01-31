<template>
  <q-page padding>
    <div class="row items-center q-mb-lg">
      <div class="text-h5 text-weight-bold">Usuários</div>
      <q-space />
      <q-btn
        color="primary"
        icon="refresh"
        flat
        round
        @click="loadUsers"
        :loading="loading"
      />
    </div>

    <q-card>
      <q-table
        :rows="users"
        :columns="columns"
        row-key="id"
        :loading="loading"
        :pagination="{ rowsPerPage: 10 }"
      >
        <template v-slot:body-cell-status="props">
          <q-td :props="props">
            <q-chip
              :color="props.row.email_confirmed_at ? 'positive' : 'warning'"
              text-color="white"
              size="sm"
            >
              {{ props.row.email_confirmed_at ? 'Confirmado' : 'Pendente' }}
            </q-chip>
          </q-td>
        </template>

        <template v-slot:body-cell-role="props">
          <q-td :props="props">
            <q-select
              v-model="props.row.user_metadata.role"
              :options="roleOptions"
              dense
              outlined
              @update:model-value="(val) => updateUserRole(props.row, val)"
              :disable="!canEditRole(props.row)"
            />
          </q-td>
        </template>

        <template v-slot:body-cell-actions="props">
          <q-td :props="props" class="q-gutter-sm">
            <q-btn
              flat
              round
              color="negative"
              icon="delete"
              size="sm"
              @click="confirmDelete(props.row)"
              :disable="!canDeleteUser(props.row)"
            />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- Dialog de confirmação de exclusão -->
    <q-dialog v-model="showDeleteDialog" persistent>
      <q-card style="min-width: 300px">
        <q-card-section class="row items-center">
          <q-avatar icon="warning" color="negative" text-color="white" />
          <span class="q-ml-sm">Deseja realmente excluir este usuário?</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn
            flat
            label="Excluir"
            color="negative"
            @click="deleteUser"
            :loading="deletingUser"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const authStore = useAuthStore()
const loading = ref(false)
const users = ref([])
const showDeleteDialog = ref(false)
const deletingUser = ref(false)
const userToDelete = ref(null)

const roleOptions = ['master', 'administrador', 'produtor']

const currentUserRole = computed(() => 
  authStore.user?.user_metadata?.role || 'produtor'
)

const columns = [
  {
    name: 'display_name',
    required: true,
    label: 'Nome',
    align: 'left',
    field: row => row.user_metadata?.display_name || 'N/A',
    sortable: true
  },
  {
    name: 'email',
    required: true,
    label: 'E-mail',
    align: 'left',
    field: 'email',
    sortable: true
  },
  {
    name: 'phone',
    required: true,
    label: 'Telefone',
    align: 'left',
    field: row => row.user_metadata?.phone || 'N/A',
    sortable: true
  },
  {
    name: 'role',
    required: true,
    label: 'Perfil',
    align: 'left',
    field: row => row.user_metadata?.role || 'produtor'
  },
  {
    name: 'status',
    required: true,
    label: 'Status',
    align: 'left',
    field: 'email_confirmed_at'
  },
  {
    name: 'created_at',
    required: true,
    label: 'Data de Cadastro',
    align: 'left',
    field: row => new Date(row.created_at).toLocaleDateString('pt-BR'),
    sortable: true
  },
  {
    name: 'actions',
    required: true,
    label: 'Ações',
    align: 'center'
  }
]

const canEditRole = (user) => {
  if (currentUserRole.value === 'master') return true
  if (currentUserRole.value === 'administrador') {
    return user.user_metadata?.role !== 'master' && 
           user.user_metadata?.role !== 'administrador'
  }
  return false
}

const canDeleteUser = (user) => {
  if (currentUserRole.value === 'master') return true
  if (currentUserRole.value === 'administrador') {
    return user.user_metadata?.role !== 'master' && 
           user.user_metadata?.role !== 'administrador'
  }
  return false
}

const updateUserRole = async (user, newRole) => {
  try {
    const { error } = await supabase.functions.invoke('update-user-role', {
      body: { 
        userId: user.id,
        role: newRole
      }
    })
    
    if (error) throw error
    
    $q.notify({
      type: 'positive',
      message: 'Perfil atualizado com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao atualizar perfil:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao atualizar perfil. Tente novamente.'
    })
  }
}

const loadUsers = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase.functions.invoke('list-users')
    
    if (error) throw error
    
    users.value = data.users
  } catch (error) {
    console.error('Erro ao carregar usuários:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar usuários. Tente novamente.'
    })
  } finally {
    loading.value = false
  }
}

const confirmDelete = (user) => {
  userToDelete.value = user
  showDeleteDialog.value = true
}

const deleteUser = async () => {
  if (!userToDelete.value) return

  try {
    deletingUser.value = true
    const { error } = await supabase.functions.invoke('delete-user', {
      body: { userId: userToDelete.value.id }
    })
    
    if (error) throw error

    users.value = users.value.filter(u => u.id !== userToDelete.value.id)
    showDeleteDialog.value = false
    
    $q.notify({
      type: 'positive',
      message: 'Usuário excluído com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao excluir usuário:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao excluir usuário. Tente novamente.'
    })
  } finally {
    deletingUser.value = false
    userToDelete.value = null
  }
}

onMounted(() => {
  loadUsers()
})
</script> 