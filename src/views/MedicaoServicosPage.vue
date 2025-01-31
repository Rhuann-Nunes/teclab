<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}/medicoes/${medicaoId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">
              Serviços Executados
              <q-badge
                :color="medicao?.status === 'aberto' ? 'grey' : 'positive'"
                class="q-ml-sm"
                :label="medicao?.status === 'aberto' ? 'Em Aberto' : 'Fechada'"
                size="sm"
              />
            </h5>
            <div class="text-subtitle2 text-grey-7">Medição nº {{ medicao?.numero }} - {{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Serviços -->
    <q-card>
      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando serviços...</div>
        </div>

        <div v-else-if="!servicos.length" class="text-center q-pa-lg">
          <q-icon name="engineering" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhum serviço executado</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <div v-else>
          <div class="row items-center justify-between q-mb-md">
            <div class="text-h6">Serviços Lançados</div>
            <q-btn round color="primary" icon="add" size="sm" @click="showDialog = true">
              <q-tooltip>Adicionar Serviço</q-tooltip>
            </q-btn>
          </div>

          <q-list bordered separator>
            <q-item v-for="servico in servicos" :key="servico.id">
              <q-item-section>
                <q-item-label class="text-primary text-weight-medium text-body2">
                  {{ servicosDisponiveis.find(s => s.id === servico.servico_id)?.nome }}
                </q-item-label>
                <q-item-label caption class="text-caption">
                  <div class="row items-center q-gutter-x-sm">
                    <div>
                      <q-icon name="place" size="xs" class="q-mr-xs" />
                      {{ localizacoes.find(l => l.id === servico.localizacao_obra_id)?.nome }}
                    </div>
                    <div v-if="servico.estaca_inicial && servico.estaca_final">
                      <q-icon name="timeline" size="xs" class="q-mr-xs" />
                      {{ servico.estaca_inicial }} a {{ servico.estaca_final }}
                    </div>
                    <div>
                      <q-icon name="straighten" size="xs" class="q-mr-xs" />
                      {{ Number(servico.quantidade).toFixed(2) }}
                      {{ servicosDisponiveis.find(s => s.id === servico.servico_id)?.unidade }}
                    </div>
                    <div>
                      <q-icon name="event" size="xs" class="q-mr-xs" />
                      {{ new Date(servico.data_execucao).toLocaleDateString('pt-BR') }}
                    </div>
                  </div>
                </q-item-label>
              </q-item-section>

              <q-item-section side>
                <div class="row items-center q-gutter-sm">
                  <q-btn flat round color="primary" icon="edit" size="sm" @click="editServico(servico)">
                    <q-tooltip>Editar serviço</q-tooltip>
                  </q-btn>
                  <q-btn flat round color="negative" icon="delete" size="sm" @click="confirmDelete(servico)">
                    <q-tooltip>Excluir serviço</q-tooltip>
                  </q-btn>
                </div>
              </q-item-section>
            </q-item>
          </q-list>
        </div>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar/editar serviço -->
    <q-dialog v-model="showDialog" persistent>
      <q-card style="width: 500px; max-width: 95vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">{{ editMode ? 'Editar' : 'Novo' }} Serviço</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <q-form @submit="onSubmit">
            <div class="row q-col-gutter-md">
              <div class="col-12">
                <q-select
                  v-model="form.servico_id"
                  :options="servicosDisponiveis"
                  option-label="nome"
                  option-value="id"
                  label="Serviço"
                  outlined
                  emit-value
                  map-options
                  :rules="[val => !!val || 'Campo obrigatório']"
                  @update:model-value="onServicoChange"
                >
                  <template v-slot:option="scope">
                    <q-item v-bind="scope.itemProps">
                      <q-item-section>
                        <q-item-label>{{ scope.opt.nome }}</q-item-label>
                        <q-item-label caption>
                          Quantidade Total: {{ Number(scope.opt.quantidade_total).toFixed(2) }} {{ scope.opt.unidade }}
                        </q-item-label>
                      </q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </div>

              <div class="col-12">
                <q-select
                  v-model="form.localizacao_obra_id"
                  :options="localizacoes"
                  option-label="nome"
                  option-value="id"
                  label="Localização"
                  outlined
                  emit-value
                  map-options
                  :rules="[val => !!val || 'Campo obrigatório']"
                  @update:model-value="onLocalizacaoChange"
                />
              </div>

              <template v-if="selectedLocalizacao?.tipo === 'trecho'">
                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Estaca Inicial</div>
                  <div class="row items-center q-col-gutter-sm">
                    <div class="col-6">
                      <q-input
                        v-model="form.estaca_inicial_inteiro"
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
                    <div class="col-4">
                      <q-input
                        v-model="form.estaca_inicial_decimal"
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

                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Estaca Final</div>
                  <div class="row items-center q-col-gutter-sm">
                    <div class="col-6">
                      <q-input
                        v-model="form.estaca_final_inteiro"
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
                    <div class="col-4">
                      <q-input
                        v-model="form.estaca_final_decimal"
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

              <div class="col-12">
                <q-input
                  v-model.number="form.quantidade"
                  type="number"
                  label="Quantidade"
                  outlined
                  step="0.01"
                  :rules="[validateQuantidade]"
                >
                  <template v-slot:append>
                    <q-badge
                      v-if="quantidadeDisponivel !== null"
                      :color="quantidadeDisponivel > 0 ? 'positive' : 'negative'"
                      :label="'Disponível: ' + quantidadeDisponivel.toFixed(2)"
                    />
                  </template>
                </q-input>
              </div>

              <div class="col-12">
                <q-input
                  v-model="form.data_execucao"
                  type="date"
                  label="Data de Execução"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>

            <div class="row justify-end q-gutter-sm q-mt-lg">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn 
                :label="editMode ? 'Salvar' : 'Adicionar'" 
                type="submit" 
                color="primary" 
                :loading="saving" 
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const obraId = route.params.obraId
const medicaoId = route.params.medicaoId
const obra = ref(null)
const medicao = ref(null)
const servicos = ref([])
const servicosDisponiveis = ref([])
const localizacoes = ref([])
const loading = ref(true)
const saving = ref(false)
const showDialog = ref(false)
const editMode = ref(false)

const columns = [
  {
    name: 'servico',
    label: 'Serviço',
    field: row => servicosDisponiveis.value.find(s => s.id === row.servico_id)?.nome,
    align: 'left',
  },
  {
    name: 'localizacao',
    label: 'Localização',
    field: row => localizacoes.value.find(l => l.id === row.localizacao_obra_id)?.nome,
    align: 'left',
  },
  {
    name: 'estacas',
    label: 'Estacas',
    field: row => row.estaca_inicial && row.estaca_final ? `${row.estaca_inicial} a ${row.estaca_final}` : '-',
    align: 'left',
  },
  {
    name: 'quantidade',
    label: 'Quantidade',
    field: 'quantidade',
    format: val => Number(val).toFixed(2),
    align: 'right',
  },
  {
    name: 'data_execucao',
    label: 'Data de Execução',
    field: row => new Date(row.data_execucao).toLocaleDateString('pt-BR'),
    align: 'left',
  },
  {
    name: 'acoes',
    label: 'Ações',
    field: 'acoes',
    align: 'center',
  }
]

const form = ref({
  id: null,
  servico_id: null,
  localizacao_obra_id: null,
  estaca_inicial_inteiro: '',
  estaca_inicial_decimal: '',
  estaca_final_inteiro: '',
  estaca_final_decimal: '',
  quantidade: null,
  data_execucao: null,
  obra_id: obraId,
  medicao_id: medicaoId
})

const selectedLocalizacao = ref(null)
const selectedServico = ref(null)
const quantidadeDisponivel = ref(null)

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

const onLocalizacaoChange = async (localizacaoId) => {
  if (!localizacaoId) {
    selectedLocalizacao.value = null
    return
  }

  const { data } = await supabase
    .from('localizacao_obra')
    .select('*')
    .eq('id', localizacaoId)
    .single()

  selectedLocalizacao.value = data
}

const loadData = async () => {
  try {
    loading.value = true
    
    // Carregar obra
    const { data: obraData, error: obraError } = await supabase
      .from('obras')
      .select('*')
      .eq('id', obraId)
      .single()
    
    if (obraError) throw obraError
    obra.value = obraData

    // Carregar medição
    const { data: medicaoData, error: medicaoError } = await supabase
      .from('medicoes_obra')
      .select('*')
      .eq('id', medicaoId)
      .single()
    
    if (medicaoError) throw medicaoError
    medicao.value = medicaoData

    // Carregar serviços disponíveis
    const { data: servicosData, error: servicosError } = await supabase
      .from('servicos_obra')
      .select('*')
      .eq('obra_id', obraId)
      .order('nome')
    
    if (servicosError) throw servicosError
    servicosDisponiveis.value = servicosData

    // Carregar localizações
    const { data: localizacoesData, error: localizacoesError } = await supabase
      .from('localizacao_obra')
      .select('*')
      .eq('obra_id', obraId)
      .order('nome')
    
    if (localizacoesError) throw localizacoesError
    localizacoes.value = localizacoesData

    // Carregar serviços executados
    const { data: servicosExecutadosData, error: servicosExecutadosError } = await supabase
      .from('memoria_calculo_medicao')
      .select('*')
      .eq('medicao_id', medicaoId)
      .order('data_execucao', { ascending: false })
    
    if (servicosExecutadosError) throw servicosExecutadosError
    servicos.value = servicosExecutadosData
  } catch (error) {
    console.error('Erro ao carregar dados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dados'
    })
  } finally {
    loading.value = false
  }
}

const editServico = (servico) => {
  const estacaInicial = parseEstaca(servico.estaca_inicial)
  const estacaFinal = parseEstaca(servico.estaca_final)
  
  form.value = {
    ...servico,
    estaca_inicial_inteiro: estacaInicial.inteiro,
    estaca_inicial_decimal: estacaInicial.decimal,
    estaca_final_inteiro: estacaFinal.inteiro,
    estaca_final_decimal: estacaFinal.decimal
  }
  
  showDialog.value = true
}

const onSubmit = async () => {
  try {
    saving.value = true
    
    const { 
      id, 
      estaca_inicial_inteiro,
      estaca_inicial_decimal,
      estaca_final_inteiro,
      estaca_final_decimal,
      ...servicoData 
    } = form.value
    
    // Adicionar usuário de cadastro
    const { data: { user } } = await supabase.auth.getUser()
    servicoData.usuario_cadastro = user.email
    
    // Processar estacas apenas se for trecho
    if (selectedLocalizacao.value?.tipo === 'trecho') {
      servicoData.estaca_inicial = formatEstaca(estaca_inicial_inteiro, estaca_inicial_decimal)
      servicoData.estaca_final = formatEstaca(estaca_final_inteiro, estaca_final_decimal)
    } else {
      servicoData.estaca_inicial = null
      servicoData.estaca_final = null
    }
    
    let error
    if (id) {
      const { error: updateError } = await supabase
        .from('memoria_calculo_medicao')
        .update(servicoData)
        .eq('id', id)
      error = updateError
    } else {
      const { error: insertError } = await supabase
        .from('memoria_calculo_medicao')
        .insert([servicoData])
      error = insertError
    }
    
    if (error) throw error
    
    await loadData()
    showDialog.value = false
    
    $q.notify({
      type: 'positive',
      message: `Serviço ${id ? 'atualizado' : 'cadastrado'} com sucesso!`
    })
  } catch (error) {
    console.error('Erro ao salvar serviço:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao salvar serviço'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = (servico) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: 'Tem certeza que deseja excluir este serviço?',
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('memoria_calculo_medicao')
        .delete()
        .eq('id', servico.id)
      
      if (error) throw error

      $q.notify({
        type: 'positive',
        message: 'Serviço excluído com sucesso!'
      })

      loadData()
    } catch (error) {
      console.error('Erro ao excluir serviço:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir serviço'
      })
    }
  })
}

// Função para carregar a quantidade já utilizada do serviço
const loadQuantidadeUtilizada = async (servicoId) => {
  if (!servicoId) return 0

  let query = supabase
    .from('memoria_calculo_medicao')
    .select('quantidade')
    .eq('servico_id', servicoId)
  
  // Só adiciona o filtro neq se houver um ID no formulário
  if (form.value.id) {
    query = query.neq('id', form.value.id)
  }

  const { data, error } = await query

  if (error) {
    console.error('Erro ao carregar quantidade utilizada:', error)
    return 0
  }

  return data.reduce((total, item) => total + Number(item.quantidade), 0)
}

// Função para atualizar a quantidade disponível
const updateQuantidadeDisponivel = async () => {
  if (!form.value.servico_id) {
    quantidadeDisponivel.value = null
    return
  }

  const servico = servicosDisponiveis.value.find(s => s.id === form.value.servico_id)
  if (!servico) {
    quantidadeDisponivel.value = null
    return
  }

  const quantidadeUtilizada = await loadQuantidadeUtilizada(form.value.servico_id)
  quantidadeDisponivel.value = Number(servico.quantidade_total) - quantidadeUtilizada
}

// Atualizar quando o serviço for selecionado
const onServicoChange = async (servicoId) => {
  if (!servicoId) {
    selectedServico.value = null
    quantidadeDisponivel.value = null
    return
  }

  selectedServico.value = servicosDisponiveis.value.find(s => s.id === servicoId)
  await updateQuantidadeDisponivel()
}

const validateQuantidade = (val) => {
  if (!val) return 'Campo obrigatório'
  if (val <= 0) return 'Deve ser maior que zero'
  if (quantidadeDisponivel.value !== null && val > quantidadeDisponivel.value) {
    return `Quantidade excede o disponível (${quantidadeDisponivel.value.toFixed(2)})`
  }
  return true
}

onMounted(() => {
  loadData()
})
</script> 