<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn
            flat
            round
            icon="arrow_back"
            color="primary"
            @click="$router.push('/ensaios/terraplenagem')"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">Compactação de Aterro</h5>
            <div class="text-subtitle2 text-grey-7">{{ selectedObra.value?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Ambientes -->
    <q-card class="full-height">
      <q-card-section class="fixed-header">
        <div class="row items-center">
          <div class="text-h6 col">Registros Cadastrados</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="showNewAmbienteDialog = true">
              <q-tooltip>Adicionar Registro</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section class="scroll-container q-px-none">
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando registros...</div>
        </div>

        <div v-else-if="ambientes.length === 0" class="text-center q-pa-lg">
          <q-icon name="assignment" size="4em" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-md">Nenhum registro cadastrado</div>
          <div class="text-grey-7">Clique no botão "+" para adicionar um registro</div>
        </div>

        <div v-else>
          <q-list separator class="q-px-md">
            <q-item v-for="ambiente in sortedAmbientes" :key="ambiente.id" class="q-py-md">
              <q-item-section>
                <q-item-label class="text-subtitle1">
                  {{ ambiente.servico.nome }}
                </q-item-label>
                <q-item-label caption lines="2">
                  <template v-if="ambiente.localizacao_obra.tipo === 'trecho'">
                    <div class="text-body2">
                      {{ ambiente.localizacao_obra.nome }} - Estaca {{ formatEstacaDisplay(ambiente.estaca_inicial) }} a {{ formatEstacaDisplay(ambiente.estaca_final) }}
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-body2">
                      {{ ambiente.localizacao_obra.nome }}
                    </div>
                  </template>
                  <div class="row items-center text-body2 q-gutter-x-md">
                    <div>
                      <q-icon name="event" size="xs" class="q-mr-xs" />
                      {{ formatDate(ambiente.data_prevista) }}
                    </div>
                    <div>
                      <q-icon name="straighten" size="xs" class="q-mr-xs" />
                      {{ (ambiente.espessura_camada * 100).toFixed(0) }} cm
                    </div>
                    <div>
                      <q-icon name="inventory_2" size="xs" class="q-mr-xs" />
                      {{ ambiente.volume_previsto }} m³
                    </div>
                  </div>
                </q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-btn
                  flat
                  round
                  color="primary"
                  icon="science"
                  @click="$router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod?ambiente=${ambiente.id}`)"
                >
                  <q-tooltip>Ver Ensaios</q-tooltip>
                </q-btn>
              </q-item-section>
            </q-item>
          </q-list>
        </div>
      </q-card-section>
    </q-card>

    <!-- Dialog para novo ambiente -->
    <q-dialog v-model="showNewAmbienteDialog" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center fixed-dialog-header">
          <div class="text-h6">Novo Registro</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="dialog-form-section">
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="newAmbiente.servico_id"
              :options="servicos"
              label="Serviço *"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Serviço é obrigatório']"
              @update:model-value="onServicoChange"
            />

            <q-select
              v-model="newAmbiente.localizacao"
              :options="localizacoes"
              label="Localização *"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Localização é obrigatória']"
              :disable="!newAmbiente.servico_id"
              :hint="!newAmbiente.servico_id ? 'Selecione um serviço primeiro' : ''"
            />

            <q-select
              v-model="newAmbiente.medicao_id"
              :options="medicoes"
              label="Medição *"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Medição é obrigatória']"
              :hint="medicoes.length === 0 ? 'Não há medições em aberto' : ''"
            />

            <q-input
              v-model="newAmbiente.data_prevista"
              type="date"
              label="Data Prevista *"
              outlined
              :rules="[val => !!val || 'Data é obrigatória']"
            />

            <q-input
              v-model.number="newAmbiente.volume_previsto"
              type="number"
              label="Volume Previsto (m³) *"
              outlined
              :rules="[
                val => !!val || 'Volume é obrigatório',
                val => val > 0 || 'Volume deve ser maior que zero'
              ]"
            />

            <q-input
              v-model.number="newAmbiente.espessura_camada"
              type="number"
              label="Espessura da Camada (cm) *"
              outlined
              :rules="[
                val => !!val || 'Espessura é obrigatória',
                val => val >= 0 && val <= 80 || 'Valor deve estar entre 0 e 80 cm'
              ]"
            />

            <template v-if="selectedLocalizacaoTipo === 'trecho'">
              <div class="col-12">
                <div class="text-subtitle2 q-mb-sm">Estaca Inicial</div>
                <div class="row items-center justify-center q-col-gutter-sm">
                  <div class="col-4">
                    <q-input
                      v-model="newAmbiente.estaca_inicial_inteiro"
                      type="number"
                      outlined
                      dense
                      placeholder="0"
                      :rules="[
                        val => !!val || 'Campo obrigatório',
                        val => val >= 0 || 'Valor deve ser positivo'
                      ]"
                    />
                  </div>
                  <div class="col-auto">
                    <span class="text-h6">+</span>
                  </div>
                  <div class="col-2">
                    <q-input
                      v-model="newAmbiente.estaca_inicial_decimal"
                      type="number"
                      outlined
                      dense
                      placeholder="0"
                      :rules="[
                        val => !val || (val >= 0 && val <= 19) || 'Valor deve estar entre 0 e 19'
                      ]"
                    />
                  </div>
                </div>
              </div>

              <div class="col-12 q-mt-md">
                <div class="text-subtitle2 q-mb-sm">Estaca Final</div>
                <div class="row items-center justify-center q-col-gutter-sm">
                  <div class="col-4">
                    <q-input
                      v-model="newAmbiente.estaca_final_inteiro"
                      type="number"
                      outlined
                      dense
                      placeholder="0"
                      :rules="[
                        val => !!val || 'Campo obrigatório',
                        val => val >= 0 || 'Valor deve ser positivo'
                      ]"
                    />
                  </div>
                  <div class="col-auto">
                    <span class="text-h6">+</span>
                  </div>
                  <div class="col-2">
                    <q-input
                      v-model="newAmbiente.estaca_final_decimal"
                      type="number"
                      outlined
                      dense
                      placeholder="0"
                      :rules="[
                        val => !val || (val >= 0 && val <= 19) || 'Valor deve estar entre 0 e 19'
                      ]"
                    />
                  </div>
                </div>
              </div>
            </template>

            <div class="row justify-end q-gutter-sm">
              <q-btn flat label="Cancelar" color="primary" v-close-popup />
              <q-btn flat label="Salvar" color="primary" type="submit" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { supabase } from '@/lib/supabaseClient'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const router = useRouter()
const { selectedObra } = useSelectedObra()
const authStore = useAuthStore()

// Estado
const loading = ref(false)
const ambientes = ref([])
const localizacoes = ref([])
const servicos = ref([])
const medicoes = ref([])
const showNewAmbienteDialog = ref(false)
const filters = ref({
  search: '',
  date: null
})

// Novo ambiente
const newAmbiente = ref({
  localizacao: null,
  servico_id: null,
  medicao_id: null,
  data_prevista: '',
  volume_previsto: null,
  espessura_camada: null,
  estaca_inicial_inteiro: '',
  estaca_inicial_decimal: '',
  estaca_final_inteiro: '',
  estaca_final_decimal: ''
})

// Computed
const selectedLocalizacaoTipo = computed(() => {
  const loc = localizacoes.value.find(l => l.value === newAmbiente.value.localizacao)
  return loc?.tipo
})

const sortedAmbientes = computed(() => {
  return [...ambientes.value].sort((a, b) => {
    return new Date(b.data_prevista) - new Date(a.data_prevista)
  })
})

// Funções de formatação de estaca
const formatEstaca = (inteiro, decimal = 0) => {
  return parseFloat(`${inteiro}.${decimal.toString().padStart(3, '0')}`)
}

const parseEstaca = (valor) => {
  if (!valor) return { inteiro: '', decimal: '' }
  const [inteiro, decimal] = valor.toString().split('.')
  return {
    inteiro: inteiro || '',
    decimal: decimal ? parseInt(decimal) : ''
  }
}

const formatEstacaDisplay = (valor) => {
  if (!valor) return ''
  const [inteiro, decimal] = valor.toString().split('.')
  const decimalValue = decimal ? parseInt(decimal) : 0
  return decimalValue > 0 ? `${inteiro}+${decimalValue}` : inteiro
}

// Métodos
const loadAmbientes = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('ambientes_compactacao_aterro')
      .select(`
        *,
        localizacao_obra(*),
        servico:servico_id (
          nome,
          unidade
        )
      `)
      .eq('obra_id', selectedObra.value?.id)
      .order('data_prevista', { ascending: false })

    if (error) throw error
    ambientes.value = data
  } catch (error) {
    console.error('Erro ao carregar ambientes:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ambientes de trabalho'
    })
  } finally {
    loading.value = false
  }
}

const loadLocalizacoes = async (servicoId) => {
  try {
    if (!servicoId) {
      localizacoes.value = []
      return
    }

    // Primeiro, buscar o serviço selecionado para obter sua localização
    const { data: servico, error: servicoError } = await supabase
      .from('servicos_obra')
      .select('*, localizacao_obra(*)')
      .eq('id', servicoId)
      .single()

    if (servicoError) throw servicoError

    // Se o serviço for em um trecho, precisamos garantir que o ambiente esteja contido nele
    if (servico.localizacao_obra.tipo === 'trecho') {
      localizacoes.value = [{
        label: `${servico.localizacao_obra.nome} (${servico.localizacao_obra.estaca_inicial} a ${servico.localizacao_obra.estaca_final})`,
        value: servico.localizacao_obra.id,
        tipo: 'trecho',
        estaca_inicial: servico.localizacao_obra.estaca_inicial,
        estaca_final: servico.localizacao_obra.estaca_final
      }]
    } else {
      // Para localizações pontuais, usar a mesma localização do serviço
      localizacoes.value = [{
        label: servico.localizacao_obra.nome,
        value: servico.localizacao_obra.id,
        tipo: 'pontual'
      }]
    }
  } catch (error) {
    console.error('Erro ao carregar localizações:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar localizações'
    })
  }
}

const onServicoChange = async (servicoId) => {
  // Limpar localização selecionada
  newAmbiente.value.localizacao = null
  
  // Carregar localizações baseadas no serviço
  await loadLocalizacoes(servicoId)
}

const loadServicos = async () => {
  try {
    const { data, error } = await supabase
      .from('servicos_obra')
      .select('*')
      .eq('obra_id', selectedObra.value?.id)

    if (error) throw error
    servicos.value = data.map(servico => ({
      label: `${servico.nome} (${servico.unidade})`,
      value: servico.id
    }))
  } catch (error) {
    console.error('Erro ao carregar serviços:', error)
  }
}

const loadMedicoes = async () => {
  try {
    const { data, error } = await supabase
      .from('medicoes_obra')
      .select('*')
      .eq('obra_id', selectedObra.value?.id)
      .eq('status', 'aberto')
      .order('numero', { ascending: false })

    if (error) throw error
    medicoes.value = data.map(medicao => ({
      label: `Medição ${medicao.numero} (${new Date(medicao.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(medicao.data_fim).toLocaleDateString('pt-BR')})`,
      value: medicao.id
    }))
  } catch (error) {
    console.error('Erro ao carregar medições:', error)
  }
}

const onSubmit = async () => {
  try {
    const { 
      estaca_inicial_inteiro,
      estaca_inicial_decimal,
      estaca_final_inteiro,
      estaca_final_decimal,
      espessura_camada,
      localizacao,
      servico_id,
      medicao_id,
      ...ambienteData 
    } = newAmbiente.value

    // Adicionar usuário de cadastro
    ambienteData.usuario_cadastro = authStore.user.email
    
    // Converter estacas para o formato do banco
    if (selectedLocalizacaoTipo.value === 'trecho') {
      ambienteData.estaca_inicial = formatEstaca(estaca_inicial_inteiro, estaca_inicial_decimal)
      ambienteData.estaca_final = formatEstaca(estaca_final_inteiro, estaca_final_decimal)
    }

    // Converter espessura de cm para metros
    ambienteData.espessura_camada = espessura_camada / 100

    const { error } = await supabase
      .from('ambientes_compactacao_aterro')
      .insert({
        obra_id: selectedObra.value?.id,
        localizacao_id: localizacao,
        servico_id,
        medicao_id,
        ...ambienteData
      })

    if (error) throw error

    $q.notify({
      type: 'positive',
      message: 'Registro criado com sucesso'
    })
    
    showNewAmbienteDialog.value = false
    await loadAmbientes()
  } catch (error) {
    console.error('Erro ao criar registro:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao criar registro'
    })
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('pt-BR')
}

// Lifecycle
onMounted(async () => {
  if (!selectedObra.value?.id) {
    router.push('/obras')
    return
  }
  await Promise.all([
    loadAmbientes(), 
    loadServicos(),
    loadMedicoes()
  ])
})
</script>

<style scoped>
.dialog-card {
  width: 100%;
  max-width: 500px;
  margin: 20px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
}

.fixed-dialog-header {
  position: sticky;
  top: 0;
  z-index: 1;
  background-color: white;
  padding: 16px 16px 4px 16px;
}

.dialog-form-section {
  flex: 1;
  overflow-y: auto;
  padding-top: 4px;
}

.fixed-header {
  position: sticky;
  top: 0;
  z-index: 1;
  background-color: white;
}

.scroll-container {
  max-height: calc(100vh - 200px);
  overflow-y: auto;
}

@media (max-width: 599px) {
  .dialog-card {
    margin: 10px;
  }
}
</style> 