<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" :to="`/apontamentos/dia-produtivo/${route.params.diaProdutivoId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Registrar Produção</h5>
            <div class="text-subtitle2 text-grey-7">
              {{ origem?.escavadeira }} / {{ origem?.nome }} / {{ origem?.material }} / {{ origem?.disciplina }}
            </div>
          </div>
        </div>
      </div>
      <div class="col-auto">
        <q-btn round color="primary" icon="add" size="sm" @click="openDialog()">
          <q-tooltip>Adicionar Caminhão</q-tooltip>
        </q-btn>
      </div>
    </div>

    <!-- Lista de Caminhões -->
    <q-card>
      <q-card-section>
        <div class="text-h6">Caminhões em Operação</div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando caminhões...</div>
        </div>

        <div v-else-if="caminhoes.length === 0" class="text-center q-pa-lg">
          <q-icon name="local_shipping" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhum caminhão em operação</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item v-for="caminhao in caminhoes" :key="caminhao.id">
            <q-item-section>
              <!-- Restructured layout with header, content, and footer -->
              <div class="column full-width">
                <!-- Header with truck info -->
                <div class="row items-center q-mb-md">
                  <q-icon name="local_shipping" size="sm" class="q-mr-sm" />
                  <div class="text-weight-medium">{{ caminhao.prefixo }}</div>
                  <div class="text-caption q-ml-sm">{{ caminhao.placa }}</div>
                </div>
                
                <!-- Main content with inputs -->
                <div class="row q-col-gutter-sm">
                  <div class="col-12 col-sm-6">
                    <q-input
                      v-model="caminhao.estaca_origem"
                      label="Origem"
                      dense
                      outlined
                      :disable="caminhao.loading"
                      :hint="caminhao.ultima_origem ? `Último: ${caminhao.ultima_origem}` : ''"
                    />
                  </div>
                  <div class="col-12 col-sm-6">
                    <q-input
                      v-model="caminhao.estaca_destino"
                      label="Destino"
                      dense
                      outlined
                      :disable="caminhao.loading"
                    />
                  </div>
                  
                  <!-- Campos complementares -->
                  <template v-if="origem.camposComplementares">
                    <div class="col-12 col-sm-6 q-mt-sm">
                      <q-input
                        v-model="caminhao.numero_nf"
                        label="Número NF"
                        dense
                        outlined
                        :disable="caminhao.loading"
                      />
                    </div>
                    <div class="col-12 col-sm-6 q-mt-sm">
                      <q-input
                        v-model="caminhao.peso"
                        type="number"
                        label="Peso (ton)"
                        dense
                        outlined
                        :disable="caminhao.loading"
                        step="0.01"
                      />
                    </div>
                    <div class="col-12 col-sm-6 q-mt-sm">
                      <q-input
                        v-model="caminhao.comprimento_pista"
                        type="number"
                        label="Comprimento (m)"
                        dense
                        outlined
                        :disable="caminhao.loading"
                        step="0.1"
                      />
                    </div>
                    <div class="col-12 col-sm-6 q-mt-sm">
                      <q-input
                        v-model="caminhao.largura_pista"
                        type="number"
                        label="Largura (m)"
                        dense
                        outlined
                        :disable="caminhao.loading"
                        step="0.1"
                      />
                    </div>
                  </template>
                </div>
                
                <!-- Footer with trip count and actions -->
                <div class="row justify-between items-center q-mt-md">
                  <div class="text-h6 text-primary">
                    {{ caminhao.viagens || 0 }} viagens
                  </div>
                  <div class="row items-center q-gutter-sm">
                    <q-btn flat round color="primary" icon="visibility" size="sm" 
                      @click="verViagens(caminhao)"
                      :disable="!caminhao.viagens"
                    >
                      <q-tooltip>Ver Viagens</q-tooltip>
                    </q-btn>
                    <q-btn round color="positive" icon="add" size="sm" 
                      class="register-btn"
                      @click="registrarViagem(caminhao)"
                      :disable="!isValidViagem(caminhao)"
                      :loading="caminhao.loading"
                    >
                      <q-tooltip>Registrar Viagem</q-tooltip>
                    </q-btn>
                  </div>
                </div>
              </div>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog de Visualização de Viagens -->
    <q-dialog v-model="showViagensDialog" maximized>
      <q-card>
        <q-card-section class="row items-center">
          <div class="text-h6">Viagens do Caminhão {{ caminhaoSelecionado?.prefixo }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section class="q-pa-none">
          <q-table
            :rows="viagensCaminhao"
            :columns="getTableColumns()"
            row-key="id"
            flat
            :pagination="{ rowsPerPage: 10 }"
          >
            <template v-slot:body="props">
              <q-tr :props="props">
                <q-td key="data_hora" :props="props">
                  {{ new Date(props.row.data_hora).toLocaleString() }}
                </q-td>
                <q-td key="origem" :props="props">{{ props.row.origem }}</q-td>
                <q-td key="destino" :props="props">{{ props.row.destino }}</q-td>
                <q-td v-if="origem.camposComplementares" key="numero_nf" :props="props">{{ props.row.numero_nf || '-' }}</q-td>
                <q-td v-if="origem.camposComplementares" key="peso" :props="props">
                  {{ props.row.peso ? `${Number(props.row.peso).toFixed(2)} ton` : '-' }}
                </q-td>
                <q-td v-if="origem.camposComplementares" key="comprimento_pista" :props="props">
                  {{ props.row.comprimento_pista ? `${Number(props.row.comprimento_pista).toFixed(1)} m` : '-' }}
                </q-td>
                <q-td v-if="origem.camposComplementares" key="largura_pista" :props="props">
                  {{ props.row.largura_pista ? `${Number(props.row.largura_pista).toFixed(1)} m` : '-' }}
                </q-td>
              </q-tr>
            </template>
          </q-table>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog de Seleção de Caminhão -->
    <q-dialog
      v-model="showDialog"
      persistent
      transition-show="scale"
      transition-hide="scale"
    >
      <q-card class="dialog-card">
        <q-card-section class="row items-center">
          <div class="text-h6">Adicionar Caminhão</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="selectedCaminhao"
              :options="caminhoesDisponiveis"
              label="Selecionar Caminhão"
              outlined
              use-input
              input-debounce="0"
              @filter="filterCaminhoes"
              :rules="[val => !!val || 'Campo obrigatório']"
              option-label="prefixo"
            >
              <template v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    Nenhum caminhão encontrado
                  </q-item-section>
                </q-item>
              </template>
              <template v-slot:option="{ itemProps, opt }">
                <q-item v-bind="itemProps">
                  <q-item-section>
                    <q-item-label>{{ opt.prefixo }}</q-item-label>
                    <q-item-label caption>
                      Placa: {{ opt.placa }}
                    </q-item-label>
                  </q-item-section>
                </q-item>
              </template>
            </q-select>

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn 
                label="Adicionar" 
                type="submit" 
                color="primary" 
                :loading="saving"
                :disable="!selectedCaminhao"
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const origem = ref(null)
const loading = ref(true)
const saving = ref(false)
const showDialog = ref(false)
const selectedCaminhao = ref(null)
const caminhoes = ref([])
const showViagensDialog = ref(false)
const caminhaoSelecionado = ref(null)
const viagensCaminhao = ref([])

// Dados mockados de caminhões disponíveis
const caminhoesDisponiveis = ref([
  {
    id: '1',
    prefixo: '6.880',
    placa: 'ABC-1234',
    motorista: 'João Silva'
  },
  {
    id: '2',
    prefixo: '6.750',
    placa: 'DEF-5678',
    motorista: 'Pedro Santos'
  },
  {
    id: '3',
    prefixo: '6.820',
    placa: 'GHI-9012',
    motorista: 'Carlos Oliveira'
  }
])

// Função para carregar dados do localStorage
const loadCachedData = () => {
  const cachedData = localStorage.getItem('viagensCache')
  if (cachedData) {
    return JSON.parse(cachedData)
  }
  return {}
}

// Função para salvar dados no localStorage
const saveCachedData = (data) => {
  localStorage.setItem('viagensCache', JSON.stringify(data))
}

const loadOrigem = async () => {
  try {
    loading.value = true
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // In a real implementation, this would come from the API or a store
    // based on the route.params.origemId
    // For now, we get values properly from DiaProdutivoPage query parameters
    origem.value = {
      id: route.params.origemId,
      nome: 'Jazida 1', // In a real app, we would fetch this from an API
      escavadeira: route.query.escavadeira || '',
      disciplina: route.query.disciplina || '',
      descricao: 'Jazida principal de material', // This would come from the API
      material: route.query.material || '',
      tipo: 'rodoviario', // This would come from the API
      dt_fixo: 2.5, // This would come from the API
      // Read the camposComplementares flag from the route query
      camposComplementares: route.query.campos_complementares === '1'
    }
    
    // Carregar dados do cache
    const cachedData = loadCachedData()

    caminhoes.value = [
      {
        id: '1',
        prefixo: '6.880',
        placa: 'ABC-1234',
        motorista: 'João Silva',
        estaca_origem: '',
        estaca_destino: '',
        numero_nf: '',
        peso: null,
        comprimento_pista: null,
        largura_pista: null,
        viagens: cachedData['1']?.viagens || 3,
        ultima_origem: cachedData['1']?.ultima_origem || '',
        loading: false,
        registros: cachedData['1']?.registros || []
      },
      {
        id: '2',
        prefixo: '6.750',
        placa: 'DEF-5678',
        motorista: 'Pedro Santos',
        estaca_origem: '',
        estaca_destino: '',
        numero_nf: '',
        peso: null,
        comprimento_pista: null,
        largura_pista: null,
        viagens: cachedData['2']?.viagens || 5,
        ultima_origem: cachedData['2']?.ultima_origem || '',
        loading: false,
        registros: cachedData['2']?.registros || []
      },
      {
        id: '3',
        prefixo: '6.820',
        placa: 'GHI-9012',
        motorista: 'Carlos Oliveira',
        estaca_origem: '',
        estaca_destino: '',
        numero_nf: '',
        peso: null,
        comprimento_pista: null,
        largura_pista: null,
        viagens: cachedData['3']?.viagens || 2,
        ultima_origem: cachedData['3']?.ultima_origem || '',
        loading: false,
        registros: cachedData['3']?.registros || []
      }
    ]

    // Atualizar lista de caminhões disponíveis removendo os que já estão em operação
    caminhoesDisponiveis.value = [
      {
        id: '4',
        prefixo: '6.840',
        placa: 'JKL-3456',
        motorista: 'Antonio Ferreira'
      },
      {
        id: '5',
        prefixo: '6.760',
        placa: 'MNO-7890',
        motorista: 'José Pereira'
      },
      {
        id: '6',
        prefixo: '6.830',
        placa: 'PQR-1234',
        motorista: 'Francisco Santos'
      }
    ]
  } catch (error) {
    console.error('Erro ao carregar origem:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar origem'
    })
  } finally {
    loading.value = false
  }
}

const openDialog = () => {
  selectedCaminhao.value = null
  showDialog.value = true
}

const filterCaminhoes = (val, update) => {
  if (val === '') {
    update(() => {
      caminhoesDisponiveis.value = caminhoesDisponiveis.value
    })
    return
  }

  update(() => {
    const needle = val.toLowerCase()
    caminhoesDisponiveis.value = caminhoesDisponiveis.value.filter(v => 
      v.prefixo.toLowerCase().indexOf(needle) > -1 ||
      v.placa.toLowerCase().indexOf(needle) > -1 ||
      v.motorista.toLowerCase().indexOf(needle) > -1
    )
  })
}

const onSubmit = async () => {
  if (!selectedCaminhao.value) return
  
  try {
    saving.value = true
    
    // Simular delay de salvamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Adicionar caminhão à lista com campos para viagens
    const novoCaminhao = {
      ...selectedCaminhao.value,
      estaca_origem: '',
      estaca_destino: '',
      numero_nf: '',
      peso: null,
      comprimento_pista: null,
      largura_pista: null,
      viagens: 0,
      ultima_origem: '',
      loading: false
    }
    
    caminhoes.value.push(novoCaminhao)

    $q.notify({
      message: 'Caminhão adicionado com sucesso!',
      color: 'positive'
    })

    showDialog.value = false
    selectedCaminhao.value = null
  } catch (error) {
    console.error('Erro ao adicionar caminhão:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao adicionar caminhão'
    })
  } finally {
    saving.value = false
  }
}

const isValidViagem = (caminhao) => {
  // Base validation - origin and destination are always required
  let isValid = caminhao.estaca_origem && caminhao.estaca_destino && !caminhao.loading;
  
  // Additional validation for complementary fields if enabled
  if (isValid && origem.value.camposComplementares) {
    // If we have complementary fields enabled, we need to check if NF is filled
    // Other numeric fields can be optional
    isValid = !!caminhao.numero_nf;
  }
  
  return isValid;
}

const verViagens = (caminhao) => {
  caminhaoSelecionado.value = caminhao
  viagensCaminhao.value = caminhao.registros || []
  showViagensDialog.value = true
}

const registrarViagem = async (caminhao) => {
  if (!isValidViagem(caminhao)) return
  
  try {
    caminhao.loading = true
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Criar registro da viagem
    const novaViagem = {
      id: Date.now(),
      data_hora: new Date().toISOString(),
      origem: caminhao.estaca_origem,
      destino: caminhao.estaca_destino
    }

    // Adicionar campos complementares se habilitados
    if (origem.value.camposComplementares) {
      novaViagem.numero_nf = caminhao.numero_nf || '';
      novaViagem.peso = caminhao.peso ? Number(caminhao.peso) : null;
      novaViagem.comprimento_pista = caminhao.comprimento_pista ? Number(caminhao.comprimento_pista) : null;
      novaViagem.largura_pista = caminhao.largura_pista ? Number(caminhao.largura_pista) : null;
    }

    // Atualizar registros do caminhão
    if (!caminhao.registros) caminhao.registros = []
    caminhao.registros.unshift(novaViagem)
    
    // Incrementar contador e salvar última origem
    caminhao.viagens = (caminhao.viagens || 0) + 1
    caminhao.ultima_origem = caminhao.estaca_origem

    // Salvar no cache
    const cachedData = loadCachedData()
    cachedData[caminhao.id] = {
      viagens: caminhao.viagens,
      ultima_origem: caminhao.ultima_origem,
      registros: caminhao.registros
    }
    saveCachedData(cachedData)
    
    // Limpar campos
    caminhao.estaca_destino = ''
    // Manter a origem preenchida com o último valor
    
    // Clear complementary fields if they are enabled
    if (origem.value.camposComplementares) {
      caminhao.numero_nf = ''
      caminhao.peso = null
      caminhao.comprimento_pista = null
      caminhao.largura_pista = null
    }

    $q.notify({
      message: 'Viagem registrada com sucesso!',
      color: 'positive'
    })
  } catch (error) {
    console.error('Erro ao registrar viagem:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao registrar viagem'
    })
  } finally {
    caminhao.loading = false
  }
}

// Adicionar uma função para obter colunas dinamicamente com base nos campos complementares
const getTableColumns = () => {
  const columns = [
    { name: 'data_hora', label: 'Data/Hora', field: 'data_hora', sortable: true },
    { name: 'origem', label: 'Origem', field: 'origem', sortable: true },
    { name: 'destino', label: 'Destino', field: 'destino', sortable: true }
  ]
  
  if (origem.value?.camposComplementares) {
    columns.push(
      { name: 'numero_nf', label: 'NF', field: 'numero_nf', sortable: true },
      { name: 'peso', label: 'Peso (ton)', field: 'peso', sortable: true },
      { name: 'comprimento_pista', label: 'Comprimento (m)', field: 'comprimento_pista', sortable: true },
      { name: 'largura_pista', label: 'Largura (m)', field: 'largura_pista', sortable: true }
    )
  }
  
  return columns
}

onMounted(() => {
  loadOrigem()
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

.register-btn {
  border: 2px solid var(--q-positive);
}
</style> 