<template>
  <q-page padding>
    <div class="row q-col-gutter-md">
      <div class="col-12">
        <div class="text-h5 q-mb-md">
          <q-btn
            flat
            round
            icon="arrow_back"
            color="primary"
            class="q-mr-sm"
            :to="`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/lista?ambiente=${route.query.ambiente}`"
          />
          {{ isNew ? 'Novo Ensaio' : 'Visualizar Ensaio' }} de Limites de Atterberg
        </div>

        <q-form @submit="onSubmit" class="q-gutter-md">
          <!-- Informações Gerais -->
          <q-card>
            <q-card-section>
              <div class="text-subtitle1 q-mb-md">Informações Gerais</div>
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-6 col-md-3">
                  <q-input
                    v-model="form.data_ensaio"
                    type="date"
                    label="Data do Ensaio"
                    :rules="[val => !!val || 'Campo obrigatório']"
                    :readonly="!isNew"
                  />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                  <q-input
                    v-model="form.numero_ensaio"
                    label="Número do Ensaio"
                    :readonly="!isNew"
                  />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                  <q-input
                    v-model="form.nome_amostra"
                    label="Nome da Amostra"
                    :rules="[val => !!val || 'Campo obrigatório']"
                    :readonly="!isNew"
                  />
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Dados do Ensaio -->
          <q-card>
            <q-card-section>
              <div class="text-subtitle1 q-mb-md">Dados do Ensaio</div>
              <div class="row q-col-gutter-md">
                <!-- Limite de Liquidez -->
                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Limite de Liquidez</div>
                  <q-table
                    :rows="form.dados_especificos?.pontos_ll || []"
                    :columns="columnsLL"
                    row-key="golpes"
                    :rows-per-page-options="[0]"
                    hide-bottom
                    :readonly="!isNew"
                  >
                    <template v-slot:body="props">
                      <q-tr :props="props">
                        <q-td key="capsula" :props="props">
                          <q-select
                            v-model="props.row.capsula"
                            :options="capsulasLLOptions"
                            dense
                            options-dense
                            emit-value
                            map-options
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="golpes" :props="props">
                          <q-input
                            v-model.number="props.row.golpes"
                            type="number"
                            dense
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="peso_umido_capsula" :props="props">
                          <q-input
                            v-model.number="props.row.peso_umido_capsula"
                            type="number"
                            dense
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="peso_seco_capsula" :props="props">
                          <q-input
                            v-model.number="props.row.peso_seco_capsula"
                            type="number"
                            dense
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="umidade" :props="props">
                          {{ calcularUmidade(props.row, 'LL') }}
                        </q-td>
                      </q-tr>
                    </template>
                  </q-table>
                  <div class="row justify-end q-mt-sm" v-if="isNew">
                    <q-btn
                      color="primary"
                      label="Adicionar Ponto"
                      @click="adicionarPontoLL"
                      icon="add"
                      flat
                    />
                  </div>
                </div>

                <!-- Limite de Plasticidade -->
                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Limite de Plasticidade</div>
                  <q-table
                    :rows="form.dados_especificos?.pontos_lp || []"
                    :columns="columnsLP"
                    row-key="numero"
                    :rows-per-page-options="[0]"
                    hide-bottom
                    :readonly="!isNew"
                  >
                    <template v-slot:body="props">
                      <q-tr :props="props">
                        <q-td key="capsula" :props="props">
                          <q-select
                            v-model="props.row.capsula"
                            :options="capsulasLPOptions"
                            dense
                            options-dense
                            emit-value
                            map-options
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="peso_umido_capsula" :props="props">
                          <q-input
                            v-model.number="props.row.peso_umido_capsula"
                            type="number"
                            dense
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="peso_seco_capsula" :props="props">
                          <q-input
                            v-model.number="props.row.peso_seco_capsula"
                            type="number"
                            dense
                            :readonly="!isNew"
                          />
                        </q-td>
                        <q-td key="umidade" :props="props">
                          {{ calcularUmidade(props.row, 'LP') }}
                        </q-td>
                      </q-tr>
                    </template>
                  </q-table>
                  <div class="row justify-end q-mt-sm" v-if="isNew">
                    <q-btn
                      color="primary"
                      label="Adicionar Ponto"
                      @click="adicionarPontoLP"
                      icon="add"
                      flat
                    />
                  </div>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Resultados -->
          <q-card>
            <q-card-section>
              <div class="text-subtitle1 q-mb-md">Resultados</div>
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-4">
                  <q-input
                    v-model.number="resultados.limite_liquidez"
                    type="number"
                    label="Limite de Liquidez (%)"
                    readonly
                  />
                </div>
                <div class="col-12 col-sm-4">
                  <q-input
                    v-model.number="resultados.limite_plasticidade"
                    type="number"
                    label="Limite de Plasticidade (%)"
                    readonly
                  />
                </div>
                <div class="col-12 col-sm-4">
                  <q-input
                    v-model.number="resultados.indice_plasticidade"
                    type="number"
                    label="Índice de Plasticidade (%)"
                    readonly
                  />
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Observações -->
          <q-card>
            <q-card-section>
              <div class="text-subtitle1 q-mb-md">Observações</div>
              <q-input
                v-model="form.observacoes"
                type="textarea"
                :readonly="!isNew"
              />
            </q-card-section>
          </q-card>

          <div class="row justify-end q-gutter-sm" v-if="isNew">
            <q-btn
              label="Cancelar"
              color="negative"
              flat
              :to="`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/lista?ambiente=${route.query.ambiente}`"
            />
            <q-btn
              label="Salvar"
              color="primary"
              type="submit"
            />
          </div>
        </q-form>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabaseClient'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()

const isNew = computed(() => !route.params.id)

const form = ref({
  data_ensaio: new Date().toISOString().split('T')[0],
  numero_ensaio: '',
  nome_amostra: '',
  observacoes: '',
  dados_especificos: {
    pontos_ll: [],
    pontos_lp: []
  }
})

const resultados = ref({
  limite_liquidez: null,
  limite_plasticidade: null,
  indice_plasticidade: null
})

// Definir as capsulas disponíveis
const capsulasLL = {
  1: 7.25, 2: 7.43, 3: 5.50, 4: 7.33, 5: 7.52, 6: 7.23, 7: 7.41, 8: 7.27, 9: 6.89,
  10: 7.23, 11: 7.76, 12: 7.97, 13: 7.33, 14: 7.38, 15: 8.99, 16: 7.73, 17: 7.81,
  18: 5.09, 19: 5.92, 20: 6.63, 21: 10.37, 22: 6.05, 23: 5.87, 24: 7.73, 25: 7.56,
  26: 8.61, 27: 9.08, 28: 7.51, 29: 7.15, 30: 7.21, 31: 6.99, 32: 7.18, 33: 7.17,
  34: 7.37, 35: 7.27, 36: 6.73, 37: 7.09, 38: 6.97, 39: 7.18, 40: 6.55, 41: 7.26,
  42: 6.59, 43: 7.15, 44: 7.23, 45: 6.20, 46: 7.10, 47: 6.55, 48: 7.15
}

const capsulasLP = {
  1: 3.62, 2: 3.68, 3: 3.58, 4: 3.69, 5: 3.88, 6: 4.23, 7: 4.38, 8: 3.73, 9: 4.37,
  10: 4.35, 11: 5.82, 12: 4.12, 13: 8.51, 14: 3.79, 15: 4.45, 16: 3.96, 17: 3.73,
  18: 4.53, 19: 7.81, 20: 8.08, 21: 3.30, 22: 3.54, 23: 3.65, 24: 3.85, 25: 4.10,
  26: 3.50, 27: 3.87, 28: 13.77, 29: 9.79, 30: 10.90, 31: 11.38, 32: 5.96, 33: 6.49,
  40: 4.15, 41: 3.09, 42: 3.77, 43: 4.10, 44: 3.89, 45: 3.20, 46: 4.15, 47: 3.88, 48: 3.74
}

const capsulasLLOptions = Object.keys(capsulasLL).map(num => ({
  label: `Cápsula ${num} (${capsulasLL[num]}g)`,
  value: num
}))

const capsulasLPOptions = Object.keys(capsulasLP).map(num => ({
  label: `Cápsula ${num} (${capsulasLP[num]}g)`,
  value: num
}))

const columnsLL = [
  {
    name: 'capsula',
    required: true,
    label: 'Cápsula',
    align: 'center',
    field: 'capsula'
  },
  {
    name: 'golpes',
    required: true,
    label: 'Golpes',
    align: 'center',
    field: 'golpes'
  },
  {
    name: 'peso_umido_capsula',
    required: true,
    label: 'Peso Úmido + Cápsula (g)',
    align: 'center',
    field: 'peso_umido_capsula'
  },
  {
    name: 'peso_seco_capsula',
    required: true,
    label: 'Peso Seco + Cápsula (g)',
    align: 'center',
    field: 'peso_seco_capsula'
  },
  {
    name: 'umidade',
    required: true,
    label: 'Umidade (%)',
    align: 'center',
    field: 'umidade'
  }
]

const columnsLP = [
  {
    name: 'capsula',
    required: true,
    label: 'Cápsula',
    align: 'center',
    field: 'capsula'
  },
  {
    name: 'peso_umido_capsula',
    required: true,
    label: 'Peso Úmido + Cápsula (g)',
    align: 'center',
    field: 'peso_umido_capsula'
  },
  {
    name: 'peso_seco_capsula',
    required: true,
    label: 'Peso Seco + Cápsula (g)',
    align: 'center',
    field: 'peso_seco_capsula'
  },
  {
    name: 'umidade',
    required: true,
    label: 'Umidade (%)',
    align: 'center',
    field: 'umidade'
  }
]

const calcularUmidade = (ponto, tipo) => {
  if (!ponto.peso_umido_capsula || !ponto.peso_seco_capsula || !ponto.capsula) return null
  
  const pesoCapsulas = tipo === 'LL' ? capsulasLL : capsulasLP
  const pesoCap = pesoCapsulas[ponto.capsula]
  
  const pesoUmido = ponto.peso_umido_capsula - pesoCap
  const pesoSeco = ponto.peso_seco_capsula - pesoCap
  
  if (pesoSeco <= 0) return null
  
  const umidade = ((pesoUmido - pesoSeco) / pesoSeco) * 100
  return umidade.toFixed(1)
}

const adicionarPontoLL = () => {
  if (!form.value.dados_especificos.pontos_ll) {
    form.value.dados_especificos.pontos_ll = []
  }
  form.value.dados_especificos.pontos_ll.push({
    capsula: null,
    golpes: null,
    peso_umido_capsula: null,
    peso_seco_capsula: null
  })
}

const adicionarPontoLP = () => {
  if (!form.value.dados_especificos.pontos_lp) {
    form.value.dados_especificos.pontos_lp = []
  }
  form.value.dados_especificos.pontos_lp.push({
    capsula: null,
    peso_umido_capsula: null,
    peso_seco_capsula: null
  })
}

const calcularResultados = () => {
  // Calcular LL usando o método de Casagrande
  const pontosLL = form.value.dados_especificos.pontos_ll
    .filter(p => p.peso_umido_capsula && p.peso_seco_capsula && p.golpes && p.capsula)
    .map(p => ({
      golpes: Math.log10(p.golpes),
      umidade: parseFloat(calcularUmidade(p, 'LL'))
    }))

  if (pontosLL.length >= 3) {
    // Regressão linear
    const n = pontosLL.length
    const sumX = pontosLL.reduce((acc, p) => acc + p.golpes, 0)
    const sumY = pontosLL.reduce((acc, p) => acc + p.umidade, 0)
    const sumXY = pontosLL.reduce((acc, p) => acc + p.golpes * p.umidade, 0)
    const sumX2 = pontosLL.reduce((acc, p) => acc + p.golpes * p.golpes, 0)

    const a = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
    const b = (sumY - a * sumX) / n

    // LL é a umidade correspondente a 25 golpes
    resultados.value.limite_liquidez = parseFloat((a * Math.log10(25) + b).toFixed(1))
  }

  // Calcular LP como média das umidades
  const pontosLP = form.value.dados_especificos.pontos_lp
    .filter(p => p.peso_umido_capsula && p.peso_seco_capsula && p.capsula)
    .map(p => parseFloat(calcularUmidade(p, 'LP')))

  if (pontosLP.length > 0) {
    const media = pontosLP.reduce((acc, val) => acc + val, 0) / pontosLP.length
    resultados.value.limite_plasticidade = parseFloat(media.toFixed(1))
  }

  // Calcular IP
  if (resultados.value.limite_liquidez && resultados.value.limite_plasticidade) {
    resultados.value.indice_plasticidade = parseFloat(
      (resultados.value.limite_liquidez - resultados.value.limite_plasticidade).toFixed(1)
    )
  }
}

// Observar mudanças nos dados para recalcular resultados
watch(
  () => form.value.dados_especificos,
  () => calcularResultados(),
  { deep: true }
)

const loadEnsaio = async () => {
  try {
    const { data: ensaio, error } = await supabase
      .from('limite_consistencia_entradas')
      .select(`
        *,
        limite_consistencia_resultados (
          limite_liquidez,
          limite_plasticidade,
          indice_plasticidade
        )
      `)
      .eq('id', route.params.id)
      .single()

    if (error) throw error

    form.value = {
      ...ensaio,
      dados_especificos: ensaio.dados_especificos || { pontos_ll: [], pontos_lp: [] }
    }

    if (ensaio.limite_consistencia_resultados) {
      resultados.value = ensaio.limite_consistencia_resultados
    }
  } catch (error) {
    console.error('Erro ao carregar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dados do ensaio'
    })
  }
}

const onSubmit = async () => {
  try {
    const dados = {
      ...form.value,
      ambiente_id: route.query.ambiente,
      usuario_cadastro: authStore.user.email
    }

    // Inserir entrada
    const { data: entrada, error: entradaError } = await supabase
      .from('limite_consistencia_entradas')
      .insert(dados)
      .select()
      .single()

    if (entradaError) throw entradaError

    // Inserir resultados
    const { error: resultadosError } = await supabase
      .from('limite_consistencia_resultados')
      .insert({
        id_entrada: entrada.id,
        ...resultados.value
      })

    if (resultadosError) throw resultadosError

    $q.notify({
      type: 'positive',
      message: 'Ensaio salvo com sucesso'
    })

    router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/lista?ambiente=${route.query.ambiente}`)
  } catch (error) {
    console.error('Erro ao salvar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao salvar ensaio'
    })
  }
}

onMounted(async () => {
  if (!isNew.value) {
    await loadEnsaio()
  } else {
    // Adicionar pontos iniciais para LL e LP
    for (let i = 0; i < 5; i++) adicionarPontoLL()
    for (let i = 0; i < 3; i++) adicionarPontoLP()
  }
})
</script> 