<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <h5 class="q-my-none">Obras</h5>
      </div>
      <div class="col-auto" v-if="isMaster">
        <q-btn color="primary" icon="add" label="Nova Obra" @click="showNewObraDialog = true" />
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Search input -->
      <div class="col-12">
        <q-input
          v-model="filters.search"
          label="Buscar obra"
          outlined
          dense
          clearable
          @update:model-value="onSearch"
        >
          <template v-slot:append>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <!-- Obra cards -->
      <div v-for="obra in obras" :key="obra.id" class="col-12 col-sm-6 col-md-4">
        <q-card class="obra-card cursor-pointer" @click="navigateToObra(obra)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">{{ obra.nome }}</div>
                <div class="text-subtitle2 text-grey-7">{{ obra.codigo }}</div>
              </div>
            </div>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <div class="row q-col-gutter-sm">
              <div class="col-12">
                <q-icon name="location_on" size="xs" class="q-mr-xs" />
                {{ obra.cidade }} - {{ obra.estado }}
              </div>
              <div class="col-12">
                <q-icon name="event" size="xs" class="q-mr-xs" />
                {{ obra.data_cadastro ? new Date(obra.data_cadastro).toLocaleDateString('pt-BR') : '' }}
              </div>
              <div class="col-12">
                <q-icon name="person" size="xs" class="q-mr-xs" />
                {{ obra.usuario_cadastro }}
              </div>
            </div>
          </q-card-section>

          <q-card-actions align="right" class="q-px-md">
            <div class="text-primary text-weight-medium">
              CADASTRO DA OBRA <q-icon name="arrow_forward" />
            </div>
          </q-card-actions>
        </q-card>
      </div>
    </div>

    <!-- Dialog para nova obra -->
    <q-dialog v-model="showNewObraDialog" persistent>
      <q-card class="q-pa-none" style="width: 100%; max-width: 500px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Nova Obra</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <q-form @submit="onSubmitNewObra" class="q-gutter-md">
            <q-input
              v-model="newObra.codigo"
              label="Código da Obra"
              outlined
              mask="#.###"
              fill-mask
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-input
              v-model="newObra.nome"
              label="Nome da Obra"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-select
              v-model="newObra.estado"
              :options="estados"
              label="Estado"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              @update:model-value="loadCidades"
              option-value="sigla"
              option-label="nome"
              emit-value
              map-options
            />

            <q-select
              v-model="newObra.cidade"
              :options="cidades"
              label="Cidade"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              :disable="!newObra.estado"
              option-value="nome"
              option-label="nome"
              emit-value
              map-options
            />

            <div class="row justify-end q-mt-md">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn label="Salvar" type="submit" color="primary" class="q-ml-sm" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog para gerenciar vínculos -->
    <q-dialog v-model="showVinculosDialogFlag" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6 text-weight-medium">{{ selectedObra?.nome }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <div class="text-subtitle2 q-mb-sm">Gerenciar Usuários</div>
          <q-select
            v-model="selectedUsers"
            :options="availableUsers"
            label="Selecionar Usuários"
            outlined
            multiple
            use-chips
            option-value="id"
            option-label="email"
            @update:model-value="updateVinculos"
            class="full-width"
            popup-content-class="dialog-select-popup"
          />
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog para visualizar obra -->
    <q-dialog v-model="showViewDialog" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6 text-weight-medium">{{ selectedObra?.nome }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <div class="text-subtitle2">Código</div>
              <div>{{ selectedObra?.codigo }}</div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="text-subtitle2">Data de Cadastro</div>
              <div>{{ selectedObra?.data_cadastro ? new Date(selectedObra.data_cadastro).toLocaleDateString('pt-BR') : '' }}</div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="text-subtitle2">Estado</div>
              <div>{{ selectedObra?.estado }}</div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="text-subtitle2">Cidade</div>
              <div>{{ selectedObra?.cidade }}</div>
            </div>
            <div class="col-12">
              <div class="text-subtitle2">Usuário Cadastro</div>
              <div>{{ selectedObra?.usuario_cadastro }}</div>
            </div>
          </div>

          <q-separator class="q-my-md" />

          <div class="text-subtitle2 q-mb-sm">Localizações</div>
          <q-list separator>
            <q-item v-for="loc in selectedObra?.localizacoes" :key="loc.id">
              <q-item-section>
                <q-item-label>{{ loc.nome }}</q-item-label>
                <q-item-label caption>
                  {{ loc.tipo === 'trecho' ? `Estaca ${metrosParaEstaca(loc.estaca_inicial)} até ${metrosParaEstaca(loc.estaca_final)}` : loc.descricao }}
                </q-item-label>
              </q-item-section>
            </q-item>
          </q-list>

          <q-separator class="q-my-md" />

          <div class="text-subtitle2 q-mb-sm">Usuários Vinculados</div>
          <q-list separator>
            <q-item v-for="user in vinculatedUsers" :key="user.id">
              <q-item-section>
                <q-item-label>{{ user.email }}</q-item-label>
                <q-item-label caption>{{ user.user_metadata?.role || 'Sem perfil' }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog para editar obra -->
    <q-dialog v-model="showEditDialog" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Editar Obra</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <q-form @submit="onSubmitEditObra" class="q-gutter-md">
            <q-input
              v-model="editingObra.codigo"
              label="Código da Obra"
              outlined
              mask="#.###"
              fill-mask
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-input
              v-model="editingObra.nome"
              label="Nome da Obra"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-select
              v-model="editingObra.estado"
              :options="estados"
              label="Estado"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              @update:model-value="loadCidadesEdit"
              option-value="sigla"
              option-label="nome"
              emit-value
              map-options
            />

            <q-select
              v-model="editingObra.cidade"
              :options="cidadesEdit"
              label="Cidade"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              :disable="!editingObra.estado"
              option-value="nome"
              option-label="nome"
              emit-value
              map-options
            />

            <div class="row justify-end q-mt-md">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn label="Salvar" type="submit" color="primary" class="q-ml-sm" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog de confirmação de exclusão -->
    <q-dialog v-model="showDeleteDialog" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center">
          <div class="text-h6">Confirmar Exclusão</div>
        </q-card-section>

        <q-card-section>
          <p class="text-body1">
            Tem certeza que deseja excluir a obra "{{ selectedObra?.nome }}"?
          </p>
          <p class="text-caption text-negative">
            Esta ação não pode ser desfeita.
          </p>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Excluir" color="negative" @click="confirmDelete" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import { estacaParaMetros, metrosParaEstaca } from '@/utils/estacas'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const $q = useQuasar()
const authStore = useAuthStore()
const router = useRouter()
const userStore = useUserStore()

// Estado
const loading = ref(false)
const showNewObraDialog = ref(false)
const showViewDialog = ref(false)
const showEditDialog = ref(false)
const showDeleteDialog = ref(false)
const showVinculosDialogFlag = ref(false)
const selectedObra = ref(null)
const vinculatedUsers = ref([])
const selectedUsers = ref([])
const availableUsers = ref([])
const obras = ref([])
const estados = ref([])
const cidades = ref([])
const cidadesEdit = ref([])
const filters = reactive({
  search: ''
})

const newObra = ref({
  codigo: '',
  nome: '',
  estado: null,
  cidade: null
})

const editingObra = reactive({
  id: null,
  codigo: '',
  nome: '',
  estado: null,
  cidade: null,
  localizacoes: []
})

const columns = [
  {
    name: 'codigo',
    required: true,
    label: 'Código',
    align: 'left',
    field: row => row.codigo,
    sortable: true
  },
  {
    name: 'nome',
    required: true,
    label: 'Nome',
    align: 'left',
    field: row => row.nome,
    sortable: true
  },
  {
    name: 'estado',
    required: true,
    label: 'Estado',
    align: 'left',
    field: row => row.estado,
    sortable: true
  },
  {
    name: 'cidade',
    required: true,
    label: 'Cidade',
    align: 'left',
    field: row => row.cidade,
    sortable: true
  },
  {
    name: 'data_cadastro',
    required: true,
    label: 'Data de Cadastro',
    align: 'left',
    field: row => new Date(row.data_cadastro).toLocaleDateString('pt-BR'),
    sortable: true
  },
  {
    name: 'usuario_cadastro',
    required: true,
    label: 'Usuário',
    align: 'left',
    field: row => row.usuario_cadastro,
    sortable: true
  },
  {
    name: 'actions',
    required: true,
    label: 'Ações',
    align: 'center'
  }
]

const pagination = ref({
  sortBy: 'desc',
  descending: false,
  page: 1,
  rowsPerPage: 10,
  rowsNumber: 0
})

// Computed
const isMaster = computed(() => authStore.user?.user_metadata?.role === 'master')

// Métodos
const loadEstados = async () => {
  try {
    const response = await fetch('https://servicodados.ibge.gov.br/api/v1/localidades/estados')
    const data = await response.json()
    estados.value = data.sort((a, b) => a.nome.localeCompare(b.nome))
  } catch (error) {
    console.error('Erro ao carregar estados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar estados'
    })
  }
}

const loadCidades = async () => {
  if (!newObra.value.estado) return
  
  try {
    const response = await fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${newObra.value.estado}/municipios`)
    const data = await response.json()
    cidades.value = data.sort((a, b) => a.nome.localeCompare(b.nome))
  } catch (error) {
    console.error('Erro ao carregar cidades:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar cidades'
    })
  }
}

const loadObras = async () => {
  try {
    loading.value = true
    let query = supabase.from('obras').select('*')
    
    // Se não for master, filtra apenas obras vinculadas ao usuário
    if (authStore.user?.user_metadata?.role !== 'master') {
      query = query
        .select('*, usuarios_obras!inner(*)')
        .eq('usuarios_obras.usuario_id', authStore.user?.id)
    }
    
    const { data, error } = await query.order('data_cadastro', { ascending: false })
    
    if (error) throw error
    
    obras.value = data
  } catch (error) {
    console.error('Erro ao carregar obras:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar obras'
    })
  } finally {
    loading.value = false
  }
}

const onSubmitNewObra = async () => {
  try {
    // First insert the obra
    const { data: obra, error: obraError } = await supabase
      .from('obras')
      .insert([{
        codigo: newObra.value.codigo,
        nome: newObra.value.nome,
        estado: newObra.value.estado,
        cidade: newObra.value.cidade,
        usuario_cadastro: authStore.user.user_metadata.display_name,
        data_cadastro: new Date().toISOString()
      }])
      .select()
      .single()
    
    if (obraError) throw obraError

    showNewObraDialog.value = false
    loadObras()
    
    $q.notify({
      type: 'positive',
      message: 'Obra cadastrada com sucesso!'
    })

    // Reset form
    newObra.value.codigo = ''
    newObra.value.nome = ''
    newObra.value.estado = null
    newObra.value.cidade = null
  } catch (error) {
    console.error('Erro ao cadastrar obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao cadastrar obra'
    })
  }
}

const onSearch = () => {
  // TODO: Implementar busca
  console.log('Searching with filters:', filters)
}

const onPaginationChange = (newPagination) => {
  pagination.value = newPagination
}

const viewObra = async (obra) => {
  selectedObra.value = obra
  await Promise.all([
    loadVinculatedUsers(obra.id),
    loadLocalizacoes(obra.id)
  ])
  showViewDialog.value = true
}

const loadVinculatedUsers = async (obraId) => {
  try {
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
  }
}

const loadLocalizacoes = async (obraId) => {
  try {
    const { data, error } = await supabase
      .from('localizacao_obra')
      .select('*')
      .eq('obra_id', obraId)
      .order('nome')
    
    if (error) throw error
    
    selectedObra.value.localizacoes = data
  } catch (error) {
    console.error('Erro ao carregar localizações:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar localizações'
    })
  }
}

const editObra = async (obra) => {
  selectedObra.value = obra
  Object.assign(editingObra, {
    id: obra.id,
    codigo: obra.codigo,
    nome: obra.nome,
    estado: obra.estado,
    cidade: obra.cidade
  })
  
  // Load existing locations
  const { data: localizacoes, error } = await supabase
    .from('localizacao_obra')
    .select('*')
    .eq('obra_id', obra.id)
    .order('nome')
  
  if (!error) {
    editingObra.localizacoes = localizacoes.map(loc => ({
      ...loc,
      estaca_inicial: loc.tipo === 'trecho' ? metrosParaEstaca(loc.estaca_inicial) : null,
      estaca_final: loc.tipo === 'trecho' ? metrosParaEstaca(loc.estaca_final) : null
    }))
  }
  
  loadCidadesEdit()
  showEditDialog.value = true
}

const loadCidadesEdit = async () => {
  if (!editingObra.estado) return
  
  try {
    const response = await fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${editingObra.estado}/municipios`)
    const data = await response.json()
    cidadesEdit.value = data.sort((a, b) => a.nome.localeCompare(b.nome))
  } catch (error) {
    console.error('Erro ao carregar cidades:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar cidades'
    })
  }
}

const onSubmitEditObra = async () => {
  try {
    // Update obra
    const { error: obraError } = await supabase
      .from('obras')
      .update({
        codigo: editingObra.codigo,
        nome: editingObra.nome,
        estado: editingObra.estado,
        cidade: editingObra.cidade
      })
      .eq('id', editingObra.id)
    
    if (obraError) throw obraError

    // Delete existing locations
    const { error: deleteError } = await supabase
      .from('localizacao_obra')
      .delete()
      .eq('obra_id', editingObra.id)
    
    if (deleteError) throw deleteError

    // Insert new locations
    if (editingObra.localizacoes.length > 0) {
      const localizacoes = editingObra.localizacoes.map(loc => ({
        obra_id: editingObra.id,
        tipo: loc.tipo,
        nome: loc.nome,
        estaca_inicial: loc.tipo === 'trecho' ? estacaParaMetros(loc.estaca_inicial) : null,
        estaca_final: loc.tipo === 'trecho' ? estacaParaMetros(loc.estaca_final) : null,
        descricao: loc.tipo === 'pontual' ? loc.descricao : null,
        usuario_cadastro: authStore.user.user_metadata.display_name
      }))

      const { error: locError } = await supabase
        .from('localizacao_obra')
        .insert(localizacoes)

      if (locError) throw locError
    }
    
    showEditDialog.value = false
    loadObras()
    
    $q.notify({
      type: 'positive',
      message: 'Obra atualizada com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao atualizar obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao atualizar obra'
    })
  }
}

const deleteObra = (obra) => {
  selectedObra.value = obra
  showDeleteDialog.value = true
}

const confirmDelete = async () => {
  try {
    const { error } = await supabase
      .from('obras')
      .delete()
      .eq('id', selectedObra.value.id)
    
    if (error) throw error
    
    showDeleteDialog.value = false
    loadObras()
    
    $q.notify({
      type: 'positive',
      message: 'Obra excluída com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao excluir obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao excluir obra'
    })
  }
}

const showVinculosDialog = async (obra) => {
  selectedObra.value = obra
  await loadUsers()
  await loadObrasVinculos(obra.id)
  showVinculosDialogFlag.value = true
}

const loadUsers = async () => {
  try {
    const { data: users, error } = await supabase.functions.invoke('list-users')
    if (error) throw error
    availableUsers.value = users.users.filter(u => u.user_metadata?.role !== 'master')
  } catch (error) {
    console.error('Erro ao carregar usuários:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar usuários'
    })
  }
}

const loadObrasVinculos = async (obraId) => {
  try {
    const { data, error } = await supabase
      .from('usuarios_obras')
      .select('usuario_id')
      .eq('obra_id', obraId)
    
    if (error) throw error
    
    selectedUsers.value = availableUsers.value.filter(user => 
      data.some(vinculo => vinculo.usuario_id === user.id)
    )
  } catch (error) {
    console.error('Erro ao carregar vínculos:', error)
  }
}

const updateVinculos = async () => {
  try {
    // Remove vínculos existentes
    await supabase
      .from('usuarios_obras')
      .delete()
      .eq('obra_id', selectedObra.value.id)
    
    // Insere novos vínculos
    if (selectedUsers.value.length > 0) {
      const vinculos = selectedUsers.value.map(user => ({
        obra_id: selectedObra.value.id,
        usuario_id: user.id,
        usuario_cadastro: authStore.user.user_metadata.display_name
      }))
      
      const { error } = await supabase
        .from('usuarios_obras')
        .insert(vinculos)
      
      if (error) throw error
    }
    
    $q.notify({
      type: 'positive',
      message: 'Vínculos atualizados com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao atualizar vínculos:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao atualizar vínculos'
    })
  }
}

const navigateToObra = (obra) => {
  router.push(`/obras/${obra.id}`)
}

const editLocalizacoes = async (obra) => {
  selectedObra.value = obra
  Object.assign(editingObra, {
    id: obra.id,
    codigo: obra.codigo,
    nome: obra.nome,
    estado: obra.estado,
    cidade: obra.cidade
  })
  
  // Load existing locations
  const { data: localizacoes, error } = await supabase
    .from('localizacao_obra')
    .select('*')
    .eq('obra_id', obra.id)
    .order('nome')
  
  if (!error) {
    editingObra.localizacoes = localizacoes.map(loc => ({
      ...loc,
      estaca_inicial: loc.tipo === 'trecho' ? metrosParaEstaca(loc.estaca_inicial) : null,
      estaca_final: loc.tipo === 'trecho' ? metrosParaEstaca(loc.estaca_final) : null
    }))
  }
  
  showEditDialog.value = true
}

onMounted(() => {
  loadEstados()
  loadObras()
})
</script>

<style scoped>
.obra-card {
  transition: all 0.2s ease;
}

.obra-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 25px 0 rgba(0, 0, 0, 0.1);
}

.ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.q-card-actions {
  border-top: 1px solid rgba(0, 0, 0, 0.12);
}

.dialog-card {
  width: 100%;
  max-width: 500px;
}

.dialog-select-popup {
  max-height: 300px;
}
</style> 