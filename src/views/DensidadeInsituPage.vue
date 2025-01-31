<template>
  <q-page padding>
    <!-- Header com botão voltar e título -->
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn
            flat
            round
            icon="arrow_back"
            color="primary"
            :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/lista?ambiente=' + route.query.ambiente"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">{{ isNew ? 'Novo Ensaio de Densidade "In Situ"' : 'Ensaio de Densidade "In Situ"' }}</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <q-inner-loading :showing="loading">
      <q-spinner-dots size="50px" color="primary" />
    </q-inner-loading>

    <!-- Formulário -->
    <q-form @submit="salvarEnsaio" class="q-gutter-md">
      <!-- Dados Gerais -->
      <q-card flat bordered>
        <q-card-section>
          <div class="text-h6">Dados Gerais</div>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <q-input
                v-model="form.nome_amostra"
                label="Nome da Amostra"
                :rules="[val => !!val || 'Campo obrigatório']"
                outlined
                dense
                :readonly="isVisualizacao"
              />
            </div>
            <div class="col-12 col-sm-3">
              <q-input
                v-model="form.data_ensaio"
                label="Data do Ensaio"
                type="date"
                :rules="[val => !!val || 'Campo obrigatório']"
                outlined
                dense
                :readonly="isVisualizacao"
              />
            </div>
            <div class="col-12 col-sm-3">
              <q-input
                v-model="form.hora_ensaio"
                label="Hora do Ensaio"
                type="time"
                :rules="[val => !!val || 'Campo obrigatório']"
                outlined
                dense
                :readonly="isVisualizacao"
              />
            </div>
            <div class="col-12">
              <q-input
                v-model="form.observacoes"
                label="Observações"
                type="textarea"
                outlined
                dense
                :readonly="isVisualizacao"
              />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Dados dos Furos -->
      <q-card flat bordered>
        <q-card-section>
          <div class="row items-center justify-between q-mb-md">
            <div class="text-h6">Dados dos Furos</div>
            <q-btn
              v-if="!isVisualizacao"
              color="primary"
              icon="add"
              label="Adicionar Furo"
              @click="adicionarFuro"
            />
          </div>

          <!-- Tabs para cada furo -->
          <q-tabs
            v-model="selectedFuroTab"
            dense
            class="text-grey"
            active-color="primary"
            indicator-color="primary"
            align="justify"
            narrow-indicator
          >
            <q-tab
              v-for="(_, index) in form.furos"
              :key="index"
              :name="index"
              :label="'Furo ' + (index + 1)"
            />
          </q-tabs>

          <q-separator />

          <q-tab-panels v-model="selectedFuroTab" animated>
            <q-tab-panel v-for="(furo, furoIndex) in form.furos" :key="furoIndex" :name="furoIndex">
              <div class="row q-col-gutter-md">
                <!-- Seção 1: Identificação -->
                <div class="col-12">
                  <div class="text-subtitle2 text-weight-medium q-mb-sm">Identificação</div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-12 col-sm-6">
                      <q-select
                        v-model="furo.compactacao_id"
                        :options="ensaiosCompactacao"
                        label="Ensaio de Compactação *"
                        :rules="[val => !!val || 'Campo obrigatório']"
                        @update:model-value="(val) => onCompactacaoChange(val, furoIndex)"
                        :readonly="isVisualizacao"
                        emit-value
                        map-options
                        outlined
                        dense
                      >
                        <template v-slot:option="scope">
                          <q-item v-bind="scope.itemProps">
                            <q-item-section>
                              <q-item-label>{{ scope.opt.label }}</q-item-label>
                              <q-item-label caption>
                                Densidade Máxima: {{ formatarNumero(scope.opt.densidade_maxima, 3) }} g/cm³ |
                                Umidade Ótima: {{ formatarNumero(scope.opt.umidade_otima, 1) }}%
                              </q-item-label>
                            </q-item-section>
                          </q-item>
                        </template>
                      </q-select>
                    </div>
                    <div class="col-12 col-sm-6">
                      <q-input
                        v-model="furo.estaca"
                        label="Estaca"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                      />
                    </div>
                    <div class="col-12 col-sm-6">
                      <q-select
                        v-model="furo.lado"
                        :options="[
                          { label: 'Lado Esquerdo', value: 'LE' },
                          { label: 'Lado Direito', value: 'LD' },
                          { label: 'Eixo', value: 'EX' }
                        ]"
                        label="Lado"
                        outlined
                        dense
                        emit-value
                        map-options
                        :readonly="isVisualizacao"
                      />
                    </div>
                    <div class="col-12 col-sm-6">
                      <q-input
                        v-model.number="furo.profundidade"
                        label="Profundidade (cm)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                      />
                    </div>
                  </div>
                </div>

                <!-- Seção 2: Dados do Frasco -->
                <div class="col-12">
                  <div class="text-subtitle2 text-weight-medium q-mb-sm">Dados do Frasco</div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model.number="furo.peso_frasco_antes"
                        label="Peso Frasco Antes (gr)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model.number="furo.peso_frasco_depois"
                        label="Peso Frasco Depois (gr)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model.number="furo.peso_areia_cone"
                        label="Peso Areia Cone (gr)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model.number="furo.densidade_areia"
                        label="Densidade Areia (gr/cm³)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                  </div>
                </div>

                <!-- Seção 3: Dados Calculados -->
                <div class="col-12">
                  <div class="text-subtitle2 text-weight-medium q-mb-sm">Valores Calculados</div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="furo.peso_areia_furo"
                        label="Peso Areia Furo (gr)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="furo.volume_furo"
                        label="Volume Furo (cm³)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="furo.densidade_aparente_umida"
                        label="Densidade Aparente Úmida (g/cm³)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                  </div>
                </div>

                <!-- Seção 4: Dados do Solo -->
                <div class="col-12">
                  <div class="text-subtitle2 text-weight-medium q-mb-sm">Dados do Solo</div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model.number="furo.peso_solo_umido_tara"
                        label="Peso Solo Úmido + Tara (gr)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model.number="furo.tara"
                        label="Tara (gr)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model.number="furo.teor_umidade"
                        label="Teor de Umidade (%)"
                        type="number"
                        outlined
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="() => calcularValores(furoIndex)"
                      />
                    </div>
                  </div>
                </div>

                <!-- Seção 5: Resultados -->
                <div class="col-12">
                  <div class="text-subtitle2 text-weight-medium q-mb-sm">Resultados</div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model="furo.densidade_aparente_seca"
                        label="Densidade Aparente Seca (g/cm³)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model="furo.densidade_maxima_laboratorio"
                        label="Densidade Máxima Lab. (g/cm³)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model="furo.umidade_otima_laboratorio"
                        label="Umidade Ótima Lab. (%)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      />
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model="furo.desvio_umidade"
                        label="Desvio de Umidade (%)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      >
                        <template v-slot:append>
                          <q-icon
                            :name="Math.abs(furo.desvio_umidade) <= 2 ? 'check_circle' : 'warning'"
                            :color="Math.abs(furo.desvio_umidade) <= 2 ? 'positive' : 'warning'"
                          >
                            <q-tooltip>
                              {{ Math.abs(furo.desvio_umidade) <= 2 ? 'Aprovado' : 'Desvio superior a 2%' }}
                            </q-tooltip>
                          </q-icon>
                        </template>
                      </q-input>
                    </div>
                    <div class="col-12 col-sm-3">
                      <q-input
                        v-model="furo.grau_compactacao"
                        label="Grau de Compactação (%)"
                        outlined
                        dense
                        readonly
                        bg-color="blue-1"
                      >
                        <template v-slot:append>
                          <q-icon
                            :name="furo.grau_compactacao >= 95 ? 'check_circle' : 'warning'"
                            :color="furo.grau_compactacao >= 95 ? 'positive' : 'warning'"
                          >
                            <q-tooltip>
                              {{ furo.grau_compactacao >= 95 ? 'Aprovado' : 'Reprovado' }}
                            </q-tooltip>
                          </q-icon>
                        </template>
                      </q-input>
                    </div>
                  </div>
                </div>

                <!-- Botão para remover furo -->
                <div class="col-12 flex justify-end" v-if="!isVisualizacao">
                  <q-btn
                    flat
                    color="negative"
                    icon="delete"
                    label="Remover Furo"
                    @click="removerFuro(furoIndex)"
                  />
                </div>
              </div>
            </q-tab-panel>
          </q-tab-panels>
        </q-card-section>
      </q-card>

      <!-- Botões de Ação -->
      <div class="row justify-end q-gutter-sm">
        <q-btn
          v-if="!isVisualizacao"
          label="Salvar"
          type="submit"
          color="primary"
          :loading="saving"
        />
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabaseClient'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()

const isNew = computed(() => !route.params.id)
const isVisualizacao = computed(() => {
  // Verificar se tem ID (não é novo) e se está em modo visualização
  return !isNew.value && route.query.visualizar === 'true'
})

const ambiente = ref(null)
const loading = ref(false)
const saving = ref(false)
const selectedFuroTab = ref(0)

const form = ref({
  ambiente_id: route.query.ambiente,
  data_ensaio: new Date().toISOString().split('T')[0],
  hora_ensaio: new Date().toTimeString().split(':').slice(0, 2).join(':'),
  nome_amostra: '',
  metodo_umidade: 'speedy',
  observacoes: '',
  furos: []
})

// Lista de ensaios de compactação disponíveis
const ensaiosCompactacao = ref([])

onMounted(async () => {
  await carregarAmbiente()
  await loadEnsaiosCompactacao()
  if (!isNew.value) {
    await carregarEnsaio()
  }
})

async function carregarAmbiente() {
  const { data, error } = await supabase
    .from('ambientes_compactacao_aterro')
    .select(`
      *,
      localizacao:localizacao_obra(*)
    `)
    .eq('id', route.query.ambiente)
    .single()

  if (error) {
    console.error('Erro ao carregar ambiente:', error)
    return
  }

  ambiente.value = data
}

async function carregarEnsaio() {
  try {
    loading.value = true
    const { data: ensaio, error } = await supabase
      .from('densidade_insitu_entradas')
      .select(`
        *,
        densidade_insitu_furos (
          *,
          compactacao:compactacao_id (
            id,
            nome_amostra,
            compactacao_resultados_finais (
              umidade_otima,
              massa_especifica_aparente_seca_maxima
            )
          )
        )
      `)
      .eq('id', route.params.id)
      .single()

    if (error) throw error

    // Atualizar form com dados do ensaio
    form.value = {
      ambiente_id: ensaio.ambiente_id,
      data_ensaio: ensaio.data_ensaio,
      hora_ensaio: ensaio.hora_ensaio,
      nome_amostra: ensaio.nome_amostra,
      metodo_umidade: ensaio.metodo_umidade,
      observacoes: ensaio.observacoes,
      furos: ensaio.densidade_insitu_furos.map(furo => ({
        ...furo,
        compactacao_id: furo.compactacao?.id,
        nome_amostra: furo.compactacao?.nome_amostra,
        densidade_maxima_laboratorio: furo.compactacao?.compactacao_resultados_finais?.[0]?.massa_especifica_aparente_seca_maxima,
        umidade_otima_laboratorio: furo.compactacao?.compactacao_resultados_finais?.[0]?.umidade_otima
      }))
    }

    // Recarregar ensaios de compactação após carregar o ensaio
    await loadEnsaiosCompactacao()
  } catch (error) {
    console.error('Erro ao carregar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaio'
    })
  } finally {
    loading.value = false
  }
}

// Função para formatar números
function formatarNumero(valor, decimais = 3) {
  if (valor === null || valor === undefined) return '-'
  return Number(valor).toLocaleString('pt-BR', {
    minimumFractionDigits: decimais,
    maximumFractionDigits: decimais
  })
}

// Função para formatar data
function formatarData(data) {
  if (!data) return ''
  const [ano, mes, dia] = data.split('-')
  return `${dia}/${mes}/${ano}`
}

// Função para adicionar um novo furo
const adicionarFuro = () => {
  // Se estiver em modo visualização, não permitir adicionar furo
  if (isVisualizacao.value) {
    $q.notify({
      type: 'warning',
      message: 'Não é possível adicionar furos no modo visualização'
    })
    return
  }

  form.value.furos.push({
    estaca: '',
    lado: '',
    profundidade: 0.20,
    peso_frasco_antes: 6000,
    peso_frasco_depois: null,
    peso_areia_cone: 513,
    peso_areia_furo: null,
    densidade_areia: 1325,
    volume_furo: null,
    peso_solo_umido_tara: null,
    tara: 260,
    peso_solo_umido: null,
    teor_umidade: null,
    densidade_aparente_umida: null,
    densidade_aparente_seca: null,
    compactacao_id: null,
    densidade_maxima_laboratorio: null,
    umidade_otima_laboratorio: null,
    desvio_umidade: null,
    grau_compactacao: null
  })

  // Selecionar automaticamente o novo furo
  selectedFuroTab.value = form.value.furos.length - 1
}

// Função para remover um furo
function removerFuro(index) {
  form.value.furos.splice(index, 1)
  // Atualizar números dos frascos
  form.value.furos.forEach((furo, i) => {
    furo.numero_frasco = i + 1
  })
}

// Função para calcular valores automáticos
function calcularValores(furoIndex) {
  const furo = form.value.furos[furoIndex]
  
  // Calcular peso da areia no furo
  if (furo.peso_frasco_antes && furo.peso_frasco_depois && furo.peso_areia_cone) {
    furo.peso_areia_furo = Number((furo.peso_frasco_antes - furo.peso_frasco_depois - furo.peso_areia_cone).toFixed(3))
  }

  // Calcular volume do furo
  if (furo.peso_areia_furo && furo.densidade_areia) {
    furo.volume_furo = Number((furo.peso_areia_furo / furo.densidade_areia).toFixed(3))
  }

  // Calcular peso do solo úmido
  if (furo.peso_solo_umido_tara && furo.tara) {
    furo.peso_solo_umido = Number((furo.peso_solo_umido_tara - furo.tara).toFixed(3))
  }

  // Calcular densidade aparente úmida
  if (furo.peso_solo_umido && furo.volume_furo) {
    furo.densidade_aparente_umida = Number((furo.peso_solo_umido / furo.volume_furo).toFixed(3))
  }

  // Calcular densidade aparente seca
  if (furo.densidade_aparente_umida && furo.teor_umidade) {
    furo.densidade_aparente_seca = Number((furo.densidade_aparente_umida / (1 + furo.teor_umidade/100)).toFixed(3))
  }

  // Calcular desvio de umidade
  if (furo.teor_umidade && furo.umidade_otima_laboratorio) {
    furo.desvio_umidade = Number((furo.teor_umidade - furo.umidade_otima_laboratorio).toFixed(1))
  }

  // Calcular grau de compactação
  if (furo.densidade_aparente_seca && furo.densidade_maxima_laboratorio) {
    const gc = (furo.densidade_aparente_seca / furo.densidade_maxima_laboratorio) * 100
    furo.grau_compactacao = Number(gc.toFixed(1))
  }
}

// Observar mudanças nos valores para recalcular
watch(() => form.value.furos, (newFuros) => {
  newFuros.forEach((_, index) => calcularValores(index))
}, { deep: true })

// Função para carregar dados do ensaio de compactação
async function carregarDadosCompactacao(compactacaoId) {
  try {
    const { data, error } = await supabase
      .from('compactacao_resultados_finais')
      .select('*')
      .eq('compactacao_id', compactacaoId)
      .single()

    if (error) throw error

    // Atualizar os valores de laboratório para todos os furos
    form.value.furos.forEach(furo => {
      furo.densidade_maxima_laboratorio = data.massa_especifica_aparente_seca_maxima
      furo.umidade_otima_laboratorio = data.umidade_otima
    })
  } catch (error) {
    console.error('Erro ao carregar dados de compactação:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dados de compactação'
    })
  }
}

async function salvarEnsaio() {
  try {
    saving.value = true

    if (form.value.furos.length === 0) {
      throw new Error('Adicione pelo menos um furo')
    }

    // Verificar se todos os furos têm ensaio de compactação selecionado
    const furosSemCompactacao = form.value.furos.filter(f => !f.compactacao_id)
    if (furosSemCompactacao.length > 0) {
      throw new Error('Todos os furos devem ter um ensaio de compactação selecionado')
    }

    // Inserir entrada do ensaio
    const { data: ensaio, error: ensaioError } = await supabase
      .from('densidade_insitu_entradas')
      .insert({
        ambiente_id: form.value.ambiente_id,
        data_ensaio: form.value.data_ensaio,
        hora_ensaio: form.value.hora_ensaio,
        nome_amostra: form.value.nome_amostra,
        metodo_umidade: 'speedy',
        observacoes: form.value.observacoes
      })
      .select()
      .single()

    if (ensaioError) throw ensaioError

    // Inserir furos
    const furosParaInserir = form.value.furos.map(furo => ({
      densidade_insitu_id: ensaio.id,
      compactacao_id: furo.compactacao_id,
      estaca: furo.estaca,
      lado: furo.lado,
      profundidade: furo.profundidade,
      peso_frasco_antes: furo.peso_frasco_antes,
      peso_frasco_depois: furo.peso_frasco_depois,
      peso_areia_cone: furo.peso_areia_cone,
      peso_areia_furo: furo.peso_areia_furo,
      densidade_areia: furo.densidade_areia,
      volume_furo: furo.volume_furo,
      peso_solo_umido_tara: furo.peso_solo_umido_tara,
      tara: furo.tara,
      peso_solo_umido: furo.peso_solo_umido,
      teor_umidade: furo.teor_umidade,
      densidade_aparente_umida: furo.densidade_aparente_umida,
      densidade_aparente_seca: furo.densidade_aparente_seca,
      densidade_maxima_laboratorio: furo.densidade_maxima_laboratorio,
      umidade_otima_laboratorio: furo.umidade_otima_laboratorio,
      desvio_umidade: furo.desvio_umidade,
      grau_compactacao: furo.grau_compactacao
    }))

    // Validar dados antes de inserir
    for (const furo of furosParaInserir) {
      if (!furo.densidade_maxima_laboratorio || !furo.umidade_otima_laboratorio) {
        throw new Error('Dados do ensaio de compactação são obrigatórios')
      }
      if (!furo.volume_furo || !furo.densidade_aparente_seca || !furo.grau_compactacao) {
        throw new Error('Todos os cálculos devem ser realizados antes de salvar')
      }
    }

    const { error: furosError } = await supabase
      .from('densidade_insitu_furos')
      .insert(furosParaInserir)

    if (furosError) throw furosError

    $q.notify({
      type: 'positive',
      message: 'Ensaio salvo com sucesso!'
    })

    router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/lista?ambiente=${route.query.ambiente}`)
  } catch (error) {
    console.error('Erro ao salvar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: error.message || 'Erro ao salvar ensaio'
    })
  } finally {
    saving.value = false
  }
}

// Helper function to convert discriminacao to field name
function getFieldName(discriminacao) {
  const fieldMap = {
    'Estaca': 'estaca',
    'Posição (Lado)': 'lado',
    'Camada': 'profundidade',
    'Profundidade (cm)': 'profundidade',
    'Número do Frasco': 'numero_frasco',
    'Peso do Frasco Antes (gr)': 'peso_frasco_antes',
    'Peso do Frasco Depois (gr)': 'peso_frasco_depois',
    'Peso da Areia no Cone (gr)': 'peso_areia_cone',
    'Peso da Areia no Furo (gr)': 'peso_areia_furo',
    'Densidade da Areia (gr/cm³)': 'densidade_areia',
    'Volume do Furo (cm³)': 'volume_furo',
    'Peso do Solo Úmido + Tara (gr)': 'peso_solo_umido_tara',
    'Tara (gr)': 'tara',
    'Peso do Solo Úmido (gr)': 'peso_solo_umido',
    'Teor de Umidade (%)': 'teor_umidade',
    'Densidade Aparente Úmida (g/cm³)': 'densidade_aparente_umida',
    'Densidade Aparente Seca (g/cm³)': 'densidade_aparente_seca',
    'Densidade Máxima Laboratório (g/cm³)': 'densidade_maxima_laboratorio',
    'Umidade Ótima Laboratório (%)': 'umidade_otima_laboratorio',
    'Grau de Compactação (%)': 'grau_compactacao'
  }
  return fieldMap[discriminacao] || discriminacao.toLowerCase().replace(/[^a-z0-9]/g, '_')
}

// Função para carregar ensaios de compactação
const loadEnsaiosCompactacao = async () => {
  try {
    console.log('Iniciando loadEnsaiosCompactacao')
    console.log('Modo visualização:', isVisualizacao.value)

    // Buscar todos os ensaios de compactação
    const { data: ensaios, error: ensaiosError } = await supabase
      .from('compactacao_entradas')
      .select(`
        id,
        data_ensaio,
        hora_ensaio,
        nome_amostra,
        compactacao_resultados_finais (
          umidade_otima,
          massa_especifica_aparente_seca_maxima
        ),
        densidade_insitu_furos!compactacao_id (
          id,
          densidade_insitu_id
        )
      `)
      .eq('ambiente_id', route.query.ambiente)
      .order('data_ensaio', { ascending: false })

    if (ensaiosError) throw ensaiosError
    
    console.log('Ensaios de compactação carregados:', ensaios)

    let ensaiosDisponiveis = []

    if (isVisualizacao.value) {
      console.log('Modo visualização: usando todos os ensaios')
      ensaiosDisponiveis = ensaios
    } else {
      console.log('Modo criação: filtrando ensaios disponíveis')
      // Filtrar ensaios que já têm 5 furos
      ensaiosDisponiveis = ensaios.filter(ensaio => {
        const totalFuros = ensaio.densidade_insitu_furos?.length || 0
        return totalFuros < 5
      })
    }

    // Formatar os ensaios para exibição
    ensaiosCompactacao.value = ensaiosDisponiveis.map(ensaio => ({
      label: `${ensaio.nome_amostra} - ${formatarData(ensaio.data_ensaio)}`,
      value: ensaio.id,
      data_ensaio: ensaio.data_ensaio,
      hora_ensaio: ensaio.hora_ensaio,
      nome_amostra: ensaio.nome_amostra,
      densidade_maxima: ensaio.compactacao_resultados_finais?.[0]?.massa_especifica_aparente_seca_maxima,
      umidade_otima: ensaio.compactacao_resultados_finais?.[0]?.umidade_otima,
      furos_existentes: ensaio.densidade_insitu_furos?.length || 0
    }))

    if (ensaiosDisponiveis.length === 0 && !isVisualizacao.value) {
      $q.notify({
        type: 'warning',
        message: 'Não há ensaios de compactação disponíveis.',
        timeout: 5000
      })
    }

    console.log('Ensaios formatados para exibição:', ensaiosCompactacao.value)
  } catch (error) {
    console.error('Erro ao carregar ensaios de compactação:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaios de compactação'
    })
  }
}

// Quando um ensaio de compactação é selecionado para um furo
const onCompactacaoChange = (ensaioId, furoIndex) => {
  console.log('Ensaio selecionado ID:', ensaioId, 'para furo:', furoIndex)
  
  if (!ensaioId) {
    form.value.furos[furoIndex].compactacao_id = null
    form.value.furos[furoIndex].densidade_maxima_laboratorio = null
    form.value.furos[furoIndex].umidade_otima_laboratorio = null
    form.value.furos[furoIndex].nome_amostra = ''
    return
  }

  // Encontrar o ensaio pelo ID
  const ensaioSelecionado = ensaiosCompactacao.value.find(e => e.value === ensaioId)
  if (!ensaioSelecionado) {
    console.error('Ensaio não encontrado:', ensaioId)
    return
  }

  if (!isVisualizacao.value) {
    // Contar furos existentes no banco de dados
    const furosExistentes = ensaioSelecionado.furos_existentes || 0
    
    // Contar furos sendo criados para este mesmo ensaio (excluindo o furo atual)
    const furosEmCriacao = form.value.furos.filter((f, idx) => 
      f.compactacao_id === ensaioId && idx !== furoIndex
    ).length
    
    // Total de furos = furos existentes + furos em criação
    const totalFuros = furosExistentes + furosEmCriacao
    
    // Se já tiver 5 furos (somando existentes e em criação), não permitir
    if (totalFuros >= 5) {
      $q.notify({
        type: 'warning',
        message: 'Este ensaio de compactação já possui 5 furos (considerando furos existentes e em criação)'
      })
      // Limpar a seleção
      form.value.furos[furoIndex].compactacao_id = null
      form.value.furos[furoIndex].densidade_maxima_laboratorio = null
      form.value.furos[furoIndex].umidade_otima_laboratorio = null
      form.value.furos[furoIndex].nome_amostra = ''
      return
    }
  }

  // Atualizar dados do furo
  form.value.furos[furoIndex].compactacao_id = ensaioId
  form.value.furos[furoIndex].densidade_maxima_laboratorio = ensaioSelecionado.densidade_maxima
  form.value.furos[furoIndex].umidade_otima_laboratorio = ensaioSelecionado.umidade_otima
  form.value.furos[furoIndex].nome_amostra = ensaioSelecionado.nome_amostra
}
</script>

<style scoped>
.q-card {
  background: white;
  border-radius: 4px;
  box-shadow: 0 1px 5px rgb(0 0 0 / 20%);
}
</style> 