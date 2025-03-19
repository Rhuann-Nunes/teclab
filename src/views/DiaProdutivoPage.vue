<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" to="/apontamentos" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Dia Produtivo</h5>
            <div class="text-subtitle2 text-grey-7">
              {{ formatDate(diaProdutivo?.data) }} - {{ diaProdutivo?.medicao?.label }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Origens -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Origens Cadastradas</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="openDialog()">
              <q-tooltip>Adicionar Origem</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando origens...</div>
        </div>

        <div v-else-if="origens.length === 0" class="text-center q-pa-lg">
          <q-icon name="location_on" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhuma origem cadastrada</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item v-for="origem in origens" :key="origem.id">
            <q-item-section>
              <q-item-label class="text-weight-medium">
                <div class="text-primary text-weight-bold text-h6 q-mb-xs">
                  <q-icon name="engineering" size="sm" class="q-mr-xs" />
                  Escavadeira: {{ origem.escavadeira }}
                </div>
                <q-icon name="location_on" size="sm" class="q-mr-sm" />
                {{ origem.nome }}
                <q-badge :color="origem.tipo === 'rodoviario' ? 'primary' : 'secondary'" class="q-ml-sm">
                  {{ origem.tipo === 'rodoviario' ? 'Rodoviário' : 'Urbano' }}
                </q-badge>
                <q-badge :color="getDisciplinaColor(origem.disciplina)" class="q-ml-sm">
                  {{ origem.disciplina }}
                </q-badge>
              </q-item-label>
              <q-item-label caption class="text-grey-7">
                Serviço: {{ origem.material }}
              </q-item-label>
              <q-item-label caption class="text-grey-7">
                DT Fixo: {{ formatDtFixo(origem.dt_fixo) }}
              </q-item-label>
              <q-item-label caption class="text-grey-7">
                Cadastrado por {{ origem.usuario_cadastro }} em {{ new Date(origem.data_cadastro).toLocaleString() }}
              </q-item-label>
              <q-item-label v-if="origem.camposComplementares" caption class="text-positive">
                <q-icon name="check_circle" size="xs" class="q-mr-xs" />
                Campos complementares habilitados
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <div class="row items-center q-gutter-sm">
                <q-btn flat round color="negative" icon="delete" size="sm" @click="confirmDelete(origem)">
                  <q-tooltip>Excluir Origem</q-tooltip>
                </q-btn>
                <q-btn round color="positive" icon="login" size="sm" @click="navigateToProducao(origem)" class="enter-btn">
                  <q-tooltip>Entrar na Produção</q-tooltip>
                </q-btn>
              </div>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog de Seleção de Origem -->
    <q-dialog
      v-model="showDialog"
      persistent
      transition-show="scale"
      transition-hide="scale"
      @hide="onDialogHide"
    >
      <q-card class="dialog-card">
        <q-card-section class="row items-center">
          <div class="text-h6">Nova Origem</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="selectedEscavadeira"
              :options="escavadeiras"
              label="Selecionar Escavadeira"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              ref="escavadeiraSelect"
            >
              <template v-slot:option="{ itemProps, opt }">
                <q-item v-bind="itemProps">
                  <q-item-section>
                    <q-item-label>
                      <q-icon name="engineering" size="sm" class="q-mr-sm" />
                      {{ opt }}
                    </q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>

            <q-select
              v-model="selectedDisciplina"
              :options="disciplinas"
              label="Selecionar Disciplina"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              ref="disciplinaSelect"
            >
              <template v-slot:option="{ itemProps, opt }">
                <q-item v-bind="itemProps">
                  <q-item-section>
                    <q-item-label>
                      <q-icon name="category" size="sm" class="q-mr-sm" />
                      {{ opt }}
                    </q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>

            <q-select
              v-model="selectedOrigem"
              :options="origensPreCadastradas"
              label="Selecionar Origem"
              outlined
              use-input
              input-debounce="0"
              @filter="filterOrigens"
              :rules="[val => !!val || 'Campo obrigatório']"
              ref="origemSelect"
              option-label="nome"
              map-options
              emit-value
              :display-value="selectedOrigem ? selectedOrigem.nome : ''"
              @update:model-value="onOrigemChange"
            >
              <template v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    Nenhuma origem encontrada
                  </q-item-section>
                </q-item>
              </template>
              <template v-slot:option="{ itemProps, opt }">
                <q-item v-bind="itemProps">
                  <q-item-section>
                    <q-item-label>
                      {{ opt.nome }}
                      <q-badge :color="opt.tipo === 'rodoviario' ? 'primary' : 'secondary'" class="q-ml-sm">
                        {{ opt.tipo === 'rodoviario' ? 'Rodoviário' : 'Urbano' }}
                      </q-badge>
                    </q-item-label>
                    <q-item-label caption>{{ opt.descricao }}</q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>

            <q-select
              v-model="selectedMaterial"
              :options="servicos"
              label="Selecionar Serviço"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
              ref="materialSelect"
              :disable="!selectedOrigem"
              :hint="!selectedOrigem ? 'Selecione uma origem primeiro' : ''"
            >
              <template v-slot:option="{ itemProps, opt }">
                <q-item v-bind="itemProps">
                  <q-item-section>
                    <q-item-label>{{ opt }}</q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>

            <q-input
              v-model="dtFixo"
              type="number"
              label="DT Fixo (km)"
              outlined
              step="0.1"
              min="0"
              hint="Campo opcional. Deixe em branco para usar valor padrão (0 km)."
            >
              <template v-slot:append>
                <q-icon name="directions_car" />
              </template>
            </q-input>

            <q-toggle
              v-model="camposComplementares"
              label="Habilitar campos complementares"
              color="primary"
            >
              <template v-slot:append>
                <q-icon name="menu_open" class="q-ml-sm" />
              </template>
            </q-toggle>
            <div v-if="camposComplementares" class="text-caption text-grey-7 q-mt-n3 q-pl-md q-mb-md">
              Habilita campos para NF, peso, comprimento e largura da pista na tela de produção
            </div>

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn label="Adicionar" type="submit" color="primary" :loading="saving" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/auth'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const { selectedObra } = useSelectedObra()

const diaProdutivo = ref(null)
const origens = ref([])
const loading = ref(true)
const saving = ref(false)
const showDialog = ref(false)
const selectedOrigem = ref(null)
const selectedMaterial = ref(null)
const selectedEscavadeira = ref(null)
const selectedDisciplina = ref(null)
const dtFixo = ref(null)
const camposComplementares = ref(false)
const servicos = ref([])
const origemSelect = ref(null)
const materialSelect = ref(null)
const escavadeiraSelect = ref(null)
const disciplinaSelect = ref(null)

// Lista de escavadeiras por prefixo
const escavadeiras = ref([
  "6339", "6340", "6341", "6636", "6637", "6638", "6639", "6640"
])

// Lista de disciplinas
const disciplinas = ref([
  "Pavimentação", "Terraplenagem", "Obra de Arte Corrente", "Obra de Arte Especial", 
  "Drenagem", "Obras Complementares", "Indireto"
])

// Função para retornar cor com base na disciplina
const getDisciplinaColor = (disciplina) => {
  const colors = {
    "Pavimentação": "purple",
    "Terraplenagem": "brown",
    "Obra de Arte Corrente": "blue",
    "Obra de Arte Especial": "deep-blue",
    "Drenagem": "teal",
    "Obras Complementares": "green",
    "Indireto": "grey"
  }
  return colors[disciplina] || "grey"
}

// Dados mockados de origens pré-cadastradas
const origensPreCadastradas = ref([
  {
    id: '1',
    nome: 'Jazida 1',
    descricao: 'Jazida principal de material',
    materiais: ['Transporte de Cascalho'],
    tipo: 'rodoviario',
    dt_fixo: 2.5
  },
  {
    id: '2',
    nome: 'Jazida 2',
    descricao: 'Jazida secundária',
    materiais: ['Transporte de Cascalho'],
    tipo: 'rodoviario',
    dt_fixo: 3.7
  },
  {
    id: '3',
    nome: 'Bota-fora',
    descricao: 'Local de descarte',
    materiais: ['Transporte de Material de Descarte'],
    tipo: 'rodoviario',
    dt_fixo: 1.8
  },
  {
    id: '4',
    nome: 'Caixa de Empréstimo 1',
    descricao: 'Local de empréstimo principal',
    materiais: ['Transporte de Argila'],
    tipo: 'urbana',
    dt_fixo: 4.2
  },
  {
    id: '5',
    nome: 'Caixa de Empréstimo 2',
    descricao: 'Local de empréstimo secundário',
    materiais: ['Transporte de Argila'],
    tipo: 'urbana',
    dt_fixo: 5.1
  },
  {
    id: '6',
    nome: 'Caixa de Empréstimo 3',
    descricao: 'Local de empréstimo terciário',
    materiais: ['Transporte de Argila'],
    tipo: 'urbana',
    dt_fixo: 6.3
  },
  {
    id: '7',
    nome: 'Usina ABC Asfaltos',
    descricao: 'Usina de asfalto',
    materiais: ['Transporte de CBUQ Faixa B', 'Transporte de CBUQ Faixa C'],
    tipo: 'urbana',
    dt_fixo: 8.5
  }
])

const loadDiaProdutivo = async () => {
  try {
    loading.value = true
    // Simular delay de carregamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Dados mockados do dia produtivo
    const mockDiaProdutivo = {
      id: route.params.id,
      data: '2024-03-20',
      medicao: {
        numero: 1,
        data_inicio: '2024-03-01',
        data_fim: '2024-03-31',
        id: '1'
      }
    }
    
    diaProdutivo.value = {
      ...mockDiaProdutivo,
      medicao: {
        label: `Medição ${mockDiaProdutivo.medicao.numero} (${new Date(mockDiaProdutivo.medicao.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(mockDiaProdutivo.medicao.data_fim).toLocaleDateString('pt-BR')})`,
        value: mockDiaProdutivo.medicao.id
      }
    }

    // Dados mockados de origens já selecionadas
    origens.value = [
      {
        id: '1',
        nome: 'Jazida 1',
        descricao: 'Jazida principal de material',
        material: 'Transporte de Cascalho',
        escavadeira: '6339',
        tipo: 'rodoviario',
        disciplina: 'Terraplenagem',
        dt_fixo: 2.5,
        camposComplementares: true,
        dia_produtivo_id: route.params.id,
        usuario_cadastro: 'usuario@email.com',
        data_cadastro: '2024-03-20T10:00:00'
      },
      {
        id: '2',
        nome: 'Jazida 2',
        descricao: 'Jazida secundária',
        material: 'Transporte de Cascalho',
        escavadeira: '6340',
        tipo: 'rodoviario',
        disciplina: 'Pavimentação',
        dt_fixo: 3.7,
        camposComplementares: false,
        dia_produtivo_id: route.params.id,
        usuario_cadastro: 'usuario@email.com',
        data_cadastro: '2024-03-20T10:30:00'
      }
    ]
  } catch (error) {
    console.error('Erro ao carregar dia produtivo:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dia produtivo'
    })
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return format(date, 'dd/MM/yyyy', { locale: ptBR })
}

const onOrigemChange = (origId) => {
  if (!origId) {
    servicos.value = []
    selectedMaterial.value = null
    return
  }
  
  const origem = origensPreCadastradas.value.find(o => o.id === origId)
  if (origem) {
    servicos.value = origem.materiais
    selectedMaterial.value = null
  }
}

const openDialog = () => {
  selectedOrigem.value = null
  selectedMaterial.value = null
  selectedEscavadeira.value = null
  selectedDisciplina.value = null
  dtFixo.value = null
  camposComplementares.value = false
  servicos.value = []
  showDialog.value = true
  // Focar no primeiro select após o diálogo abrir
  nextTick(() => {
    escavadeiraSelect.value?.focus()
  })
}

const filterOrigens = (val, update, abort) => {
  update(() => {
    const needle = val.toLowerCase()
    const filtered = origensPreCadastradas.value.filter(v => 
      v.nome.toLowerCase().indexOf(needle) > -1 ||
      v.descricao.toLowerCase().indexOf(needle) > -1 ||
      v.materiais.some(m => m.toLowerCase().indexOf(needle) > -1)
    )
    origensPreCadastradas.value = filtered
  })
}

const onSubmit = async () => {
  if (!selectedOrigem.value || !selectedMaterial.value || !selectedEscavadeira.value || !selectedDisciplina.value) return
  
  try {
    saving.value = true
    
    // Adicionar usuário de cadastro
    const { data: { user } } = await authStore.getUser()
    
    // Simular delay de salvamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Encontrar a origem selecionada nos dados originais
    const origemSelecionada = origensPreCadastradas.value.find(o => o.id === selectedOrigem.value)
    
    if (!origemSelecionada) {
      throw new Error('Origem não encontrada')
    }
    
    // Criar nova origem com dados do usuário
    const novaOrigem = {
      ...origemSelecionada,
      material: selectedMaterial.value,
      escavadeira: selectedEscavadeira.value,
      disciplina: selectedDisciplina.value,
      dt_fixo: dtFixo.value !== null && !isNaN(dtFixo.value) ? Number(dtFixo.value) : 0,
      camposComplementares: camposComplementares.value,
      dia_produtivo_id: route.params.id,
      usuario_cadastro: user.email,
      data_cadastro: new Date().toISOString()
    }
    
    // Adicionar à lista de origens do dia produtivo
    origens.value.unshift(novaOrigem)

    $q.notify({
      message: 'Origem adicionada com sucesso!',
      color: 'positive'
    })

    showDialog.value = false
    selectedOrigem.value = null
    selectedMaterial.value = null
    selectedEscavadeira.value = null
    selectedDisciplina.value = null
    dtFixo.value = null
    camposComplementares.value = false
  } catch (error) {
    console.error('Erro ao adicionar origem:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao adicionar origem'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = (origem) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: `Tem certeza que deseja excluir a origem "${origem.nome}"?`,
    ok: {
      label: 'Excluir',
      color: 'negative'
    },
    cancel: {
      label: 'Cancelar',
      flat: true
    },
    persistent: true
  }).onOk(async () => {
    try {
      // Simular delay de exclusão
      await new Promise(resolve => setTimeout(resolve, 500))
      
      // Remover da lista
      const index = origens.value.findIndex(o => o.id === origem.id)
      if (index !== -1) {
        origens.value.splice(index, 1)
      }

      $q.notify({
        message: 'Origem excluída com sucesso!',
        color: 'positive'
      })
    } catch (error) {
      console.error('Erro ao excluir origem:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir origem'
      })
    }
  })
}

const navigateToProducao = (origem) => {
  router.push({
    path: `/apontamentos/dia-produtivo/${diaProdutivo.value.id}/origem/${origem.id}/producao`,
    query: {
      campos_complementares: origem.camposComplementares ? '1' : '0',
      escavadeira: origem.escavadeira,
      disciplina: origem.disciplina,
      material: origem.material
    }
  })
}

const onDialogHide = () => {
  // Limpar seleções quando o diálogo for fechado
  selectedOrigem.value = null
  selectedMaterial.value = null
  selectedEscavadeira.value = null
  selectedDisciplina.value = null
  dtFixo.value = null
  camposComplementares.value = false
}

const formatDtFixo = (value) => {
  if (typeof value !== 'number') return '0 km'
  return `${value.toFixed(1)} km`
}

onMounted(() => {
  loadDiaProdutivo()
})
</script>

<style scoped>
.dialog-card {
  width: 100%;
  max-width: 500px;
  margin: 20px;
}

@media (max-width: 599px) {
  .dialog-card {
    margin: 10px;
  }
}

.enter-btn {
  border: 2px solid var(--q-positive);
  background: linear-gradient(to bottom right, var(--q-positive), darken(var(--q-positive), 10%));
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.enter-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.3);
}
</style> 