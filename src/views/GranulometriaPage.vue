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
            :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/lista?ambiente=' + route.query.ambiente"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">Ensaio de Granulometria</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Form de Entrada de Dados -->
    <q-form @submit.prevent="onCalcular" class="row q-col-gutter-md">
      <div class="col-12 col-md-6">
        <!-- Dados Básicos -->
        <q-card>
          <q-card-section>
            <div class="text-h6 q-mb-md">Dados do Ensaio</div>
            
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.data_ensaio"
                  type="date"
                  label="Data do Ensaio"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.nome_amostra"
                  label="Material da Amostra"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>

        <!-- Umidade Higroscópica -->
        <q-card class="q-mt-md">
          <q-card-section>
            <div class="text-h6 q-mb-md">Umidade Higroscópica</div>
            <div class="text-caption q-mb-sm text-grey-8">
              Determinação da umidade higroscópica em duas amostras.
            </div>
            <div class="row q-col-gutter-md">
              <!-- Primeira Amostra -->
              <div class="col-12 col-sm-6">
                <q-card>
                  <q-card-section>
                    <div class="text-subtitle2 q-mb-sm">Amostra 1</div>
                    <div class="row q-col-gutter-sm">
                      <div class="col-12">
                        <q-select
                          v-model="form.umidade_higroscopica.amostra1.capsula_id"
                          :options="Object.keys(capsulas)"
                          label="Cápsula *"
                          emit-value
                          map-options
                          :disable="isVisualizacao"
                          :rules="[val => !!val || 'Campo obrigatório']"
                          @update:model-value="() => onCapsulaHigroscopicaChange(1)"
                        >
                          <template v-slot:option="scope">
                            <q-item v-bind="scope.itemProps">
                              <q-item-section>
                                <q-item-label>Cápsula {{ scope.opt }}</q-item-label>
                                <q-item-label caption>
                                  Peso: {{ capsulas[scope.opt] }}g
                                </q-item-label>
                              </q-item-section>
                            </q-item>
                          </template>
                        </q-select>
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.peso_bruto_umido"
                          label="Peso Bruto Úmido (g) *"
                          type="number"
                          step="0.01"
                          :disable="isVisualizacao"
                          :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                          @update:model-value="calcularUmidadeHigroscopica"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.peso_bruto_seco"
                          label="Peso Bruto Seco (g) *"
                          type="number"
                          step="0.01"
                          :disable="isVisualizacao"
                          :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                          @update:model-value="calcularUmidadeHigroscopica"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.peso_capsula"
                          label="Peso da Cápsula (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.peso_agua"
                          label="Peso da Água (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.peso_solo_seco"
                          label="Peso do Solo Seco (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra1.umidade"
                          label="Umidade (%)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <!-- Segunda Amostra -->
              <div class="col-12 col-sm-6">
                <q-card>
                  <q-card-section>
                    <div class="text-subtitle2 q-mb-sm">Amostra 2</div>
                    <div class="row q-col-gutter-sm">
                      <div class="col-12">
                        <q-select
                          v-model="form.umidade_higroscopica.amostra2.capsula_id"
                          :options="Object.keys(capsulas)"
                          label="Cápsula *"
                          emit-value
                          map-options
                          :disable="isVisualizacao"
                          :rules="[val => !!val || 'Campo obrigatório']"
                          @update:model-value="() => onCapsulaHigroscopicaChange(2)"
                        >
                          <template v-slot:option="scope">
                            <q-item v-bind="scope.itemProps">
                              <q-item-section>
                                <q-item-label>Cápsula {{ scope.opt }}</q-item-label>
                                <q-item-label caption>
                                  Peso: {{ capsulas[scope.opt] }}g
                                </q-item-label>
                              </q-item-section>
                            </q-item>
                          </template>
                        </q-select>
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.peso_bruto_umido"
                          label="Peso Bruto Úmido (g) *"
                          type="number"
                          step="0.01"
                          :disable="isVisualizacao"
                          :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                          @update:model-value="calcularUmidadeHigroscopica"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.peso_bruto_seco"
                          label="Peso Bruto Seco (g) *"
                          type="number"
                          step="0.01"
                          :disable="isVisualizacao"
                          :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                          @update:model-value="calcularUmidadeHigroscopica"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.peso_capsula"
                          label="Peso da Cápsula (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.peso_agua"
                          label="Peso da Água (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.peso_solo_seco"
                          label="Peso do Solo Seco (g)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                      <div class="col-12">
                        <q-input
                          v-model.number="form.umidade_higroscopica.amostra2.umidade"
                          label="Umidade (%)"
                          type="number"
                          step="0.01"
                          readonly
                          class="bg-blue-1"
                        />
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <!-- Umidade Média -->
              <div class="col-12">
                <q-input
                  v-model.number="form.umidade_higroscopica.umidade_media"
                  label="Umidade Média (%)"
                  type="number"
                  step="0.01"
                  readonly
                  class="bg-blue-1"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>

        <!-- Preparação da Amostra -->
        <q-card class="q-mt-md">
          <q-card-section>
            <div class="text-h6 q-mb-md">Preparação da Amostra</div>
            
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.massa_total_umida"
                  type="text"
                  label="Amostra Total Úmida (g)"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.massa_total_umida = val.replace(/[^0-9,]/g, '')"
                  :rules="[
                    val => !!val || 'Campo obrigatório',
                    val => parseNumber(val) > 0 || 'Valor deve ser maior que 0',
                    val => !val || parseNumber(val) <= 0 || validarMassaTotal(parseNumber(val))
                  ]"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.massa_menor_10_umida"
                  type="text"
                  label="Amostra Menor N. 10 Úmida (g)"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.massa_menor_10_umida = val.replace(/[^0-9,]/g, '')"
                  :rules="[
                    val => !!val || 'Campo obrigatório',
                    val => parseNumber(val) > 0 || 'Valor deve ser maior que 0'
                  ]"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>

        <!-- Peneiramento Grosso -->
        <q-card class="q-mt-md">
          <q-card-section>
            <div class="text-h6 q-mb-md">Peneiramento Grosso (> 2,0 mm)</div>
            
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_50mm"
                  type="text"
                  label='2" - 50 mm'
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_50mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_38mm"
                  type="text"
                  label='1 1/2" - 38 mm'
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_38mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_25mm"
                  type="text"
                  label='1" - 25 mm'
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_25mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_19mm"
                  type="text"
                  label='3/4" - 19 mm'
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_19mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_9_5mm"
                  type="text"
                  label='3/8" - 9,5 mm'
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_9_5mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_4_8mm"
                  type="text"
                  label="N° 4 - 4,8 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_4_8mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_2_0mm"
                  type="text"
                  label="N° 10 - 2,0 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_2_0mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>

        <!-- Peneiramento Fino -->
        <q-card class="q-mt-md">
          <q-card-section>
            <div class="text-h6 q-mb-md">Peneiramento Fino (< 2,0 mm)</div>
            
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_1_2mm"
                  type="text"
                  label="N° 16 - 1,2 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_1_2mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_0_6mm"
                  type="text"
                  label="N° 30 - 0,6 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_0_6mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_0_42mm"
                  type="text"
                  label="N° 40 - 0,42 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_0_42mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_0_30mm"
                  type="text"
                  label="N° 50 - 0,30 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_0_30mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_0_15mm"
                  type="text"
                  label="N° 100 - 0,15 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_0_15mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="form.peneira_0_075mm"
                  type="text"
                  label="N° 200 - 0,075 mm"
                  outlined
                  dense
                  :disable="isVisualizacao"
                  @input="val => form.peneira_0_075mm = val.replace(/[^0-9,]/g, '')"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="calcularFundo"
                  type="text"
                  label="Fundo (g)"
                  outlined
                  dense
                  readonly
                  :value="formatNumber(calcularFundo)"
                />
              </div>
            </div>
          </q-card-section>

          <q-card-section>
            <q-input
              v-model="form.observacoes"
              type="textarea"
              label="Observações"
              outlined
              dense
              :disable="isVisualizacao"
            />
          </q-card-section>

          <q-card-actions align="right">
            <q-btn
              v-if="!isVisualizacao"
              label="Calcular"
              color="primary"
              type="submit"
            />
          </q-card-actions>
        </q-card>
      </div>

      <!-- Resultados -->
      <div class="col-12 col-md-6 resultados">
        <q-card v-if="resultados">
          <q-card-section>
            <div class="text-h6 q-mb-md">Resultados</div>

            <!-- Umidade Higroscópica -->
            <div class="row q-col-gutter-md q-mb-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="resultados.umidade_higroscopica"
                  type="text"
                  label="Umidade Higroscópica (%)"
                  outlined
                  dense
                  readonly
                  :value="formatNumber(resultados.umidade_higroscopica)"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="resultados.massa_total_seca"
                  type="text"
                  label="Massa Total Seca (g)"
                  outlined
                  dense
                  readonly
                  :value="formatNumber(Number(resultados.massa_total_seca).toFixed(2))"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="resultados.massa_menor_10_seca"
                  type="text"
                  label="Amostra Menor N° 10 Seca (g)"
                  outlined
                  dense
                  readonly
                  :value="formatNumber(Number(resultados.massa_menor_10_seca).toFixed(2))"
                />
              </div>
            </div>

            <q-table
              :rows="tabelaResultados"
              :columns="columns"
              row-key="peneira"
              dense
              flat
              hide-pagination
              :pagination="{
                rowsPerPage: 0,
                sortBy: null
              }"
            >
              <template v-slot:body-cell-massa="props">
                <q-td :props="props">
                  {{ formatNumber(props.value) }}
                </q-td>
              </template>
              <template v-slot:body-cell-percentagem="props">
                <q-td :props="props">
                  {{ formatNumber(props.value) }}
                </q-td>
              </template>
              <template v-slot:body-cell-percentagem_amostra_menor="props">
                <q-td :props="props">
                  {{ formatNumber(props.value) }}
                </q-td>
              </template>
              <template v-slot:body-cell-percentagem_acumulada="props">
                <q-td :props="props">
                  {{ formatNumber(props.value) }}
                </q-td>
              </template>
              <template v-slot:body-cell-percentagem_passando="props">
                <q-td :props="props">
                  {{ formatNumber(props.value) }}
                </q-td>
              </template>
            </q-table>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn
              v-if="!isVisualizacao"
              label="Salvar"
              color="primary"
              @click="onSalvar"
              :loading="salvando"
            />
          </q-card-actions>
        </q-card>
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const isVisualizacao = computed(() => !!route.params.id)

const ambiente = ref(null)
const salvando = ref(false)
const umidadeHigroscopica = ref(null)

const form = ref({
  data_ensaio: '',
  nome_amostra: '',
  umidade_higroscopica: {
    amostra1: {
      capsula_id: null,
      peso_capsula: null,
      peso_bruto_umido: null,
      peso_bruto_seco: null,
      peso_agua: null,
      peso_solo_seco: null,
      umidade: null
    },
    amostra2: {
      capsula_id: null,
      peso_capsula: null,
      peso_bruto_umido: null,
      peso_bruto_seco: null,
      peso_agua: null,
      peso_solo_seco: null,
      umidade: null
    },
    umidade_media: null
  },
  massa_total_umida: null,
  massa_menor_10_umida: null,
  peneira_50mm: null,
  peneira_38mm: null,
  peneira_25mm: null,
  peneira_19mm: null,
  peneira_9_5mm: null,
  peneira_4_8mm: null,
  peneira_2_0mm: null,
  peneira_1_2mm: null,
  peneira_0_6mm: null,
  peneira_0_42mm: null,
  peneira_0_30mm: null,
  peneira_0_15mm: null,
  peneira_0_075mm: null,
  fundo: null,
  observacoes: ''
})

const resultados = ref(null)

const columns = [
  { name: 'peneira', label: 'Peneira (mm)', field: 'peneira', align: 'left' },
  { name: 'massa', label: 'Massa Retida (g)', field: 'massa', format: val => Number(val).toFixed(2) },
  { name: 'percentagem', label: '% Retida', field: 'percentagem', format: val => Number(val).toFixed(2) },
  { name: 'percentagem_amostra_menor', label: '% Retida (< N° 10)', field: 'percentagem_amostra_menor', format: val => Number(val).toFixed(2) },
  { name: 'percentagem_acumulada', label: '% Retida Acumulada', field: 'percentagem_acumulada', format: val => Number(val).toFixed(2) },
  { name: 'percentagem_passando', label: '% Passando', field: 'percentagem_passando', format: val => Number(val).toFixed(2) }
]

const tabelaResultados = computed(() => {
  if (!resultados.value) return []

  return [
    { peneira: '2" - 50', ...getPeneiraData('50mm') },
    { peneira: '1 1/2" - 38', ...getPeneiraData('38mm') },
    { peneira: '1" - 25', ...getPeneiraData('25mm') },
    { peneira: '3/4" - 19', ...getPeneiraData('19mm') },
    { peneira: '3/8" - 9,5', ...getPeneiraData('9_5mm') },
    { peneira: 'N° 4 - 4,8', ...getPeneiraData('4_8mm') },
    { peneira: 'N° 10 - 2,0', ...getPeneiraData('2_0mm') },
    { peneira: 'N° 16 - 1,2', ...getPeneiraData('1_2mm') },
    { peneira: 'N° 30 - 0,6', ...getPeneiraData('0_6mm') },
    { peneira: 'N° 40 - 0,42', ...getPeneiraData('0_42mm') },
    { peneira: 'N° 50 - 0,30', ...getPeneiraData('0_30mm') },
    { peneira: 'N° 100 - 0,15', ...getPeneiraData('0_15mm') },
    { peneira: 'N° 200 - 0,075', ...getPeneiraData('0_075mm') },
    { peneira: 'Fundo', ...getPeneiraData('fundo') }
  ]
})

const getPeneiraData = (peneira) => {
  const r = resultados.value
  return {
    massa: r['massa_fracao_' + peneira],
    percentagem: r['percentagem_retida_' + peneira],
    percentagem_amostra_menor: r['percentagem_retida_amostra_menor_' + peneira] || null,
    percentagem_acumulada: r['percentagem_acumulada_retida_' + peneira],
    percentagem_passando: r['percentagem_passando_' + peneira]
  }
}

// Função para formatar números no padrão brasileiro
const formatNumber = (value) => {
  if (!value) return ''
  return value.toString().replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.')
}

// Função para converter número do formato brasileiro para o formato do JS
const parseNumber = (value) => {
  if (!value || value === '') return 0
  // Remover todos os pontos de milhar e substituir a vírgula decimal por ponto
  return Number(value.toString().replace(/\./g, '').replace(',', '.'))
}

// Calcula o fundo automaticamente
const calcularFundo = computed(() => {
  if (!form.value.massa_menor_10_umida) return 0
  
  const somaRetido = [
    form.value.peneira_1_2mm,
    form.value.peneira_0_6mm,
    form.value.peneira_0_42mm,
    form.value.peneira_0_30mm,
    form.value.peneira_0_15mm,
    form.value.peneira_0_075mm
  ].reduce((sum, value) => sum + (parseNumber(value) || 0), 0)
  
  return Number((parseNumber(form.value.massa_menor_10_umida) - somaRetido).toFixed(2))
})

const loadAmbiente = async (ambienteId) => {
  try {
    const { data, error } = await supabase
      .from('ambientes_compactacao_aterro')
      .select(`
        *,
        localizacao:localizacao_id (nome)
      `)
      .eq('id', ambienteId)
      .single()

    if (error) throw error
    ambiente.value = data
    
    form.value.data_ensaio = data.data_prevista
  } catch (error) {
    console.error('Erro ao carregar ambiente:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ambiente'
    })
  }
}

// Função para calcular a umidade higroscópica
const calcularUmidadeHigroscopica = () => {
  const amostra1 = form.value.umidade_higroscopica.amostra1
  const amostra2 = form.value.umidade_higroscopica.amostra2

  // Calcular para amostra 1
  if (amostra1.peso_bruto_umido && amostra1.peso_bruto_seco && amostra1.peso_capsula) {
    amostra1.peso_agua = Number((amostra1.peso_bruto_umido - amostra1.peso_bruto_seco).toFixed(2))
    amostra1.peso_solo_seco = Number((amostra1.peso_bruto_seco - amostra1.peso_capsula).toFixed(2))
    amostra1.umidade = Number(((amostra1.peso_agua / amostra1.peso_solo_seco) * 100).toFixed(2))
  }

  // Calcular para amostra 2
  if (amostra2.peso_bruto_umido && amostra2.peso_bruto_seco && amostra2.peso_capsula) {
    amostra2.peso_agua = Number((amostra2.peso_bruto_umido - amostra2.peso_bruto_seco).toFixed(2))
    amostra2.peso_solo_seco = Number((amostra2.peso_bruto_seco - amostra2.peso_capsula).toFixed(2))
    amostra2.umidade = Number(((amostra2.peso_agua / amostra2.peso_solo_seco) * 100).toFixed(2))
  }

  // Calcular umidade média
  if (amostra1.umidade && amostra2.umidade) {
    form.value.umidade_higroscopica.umidade_media = Number(((amostra1.umidade + amostra2.umidade) / 2).toFixed(2))
    umidadeHigroscopica.value = form.value.umidade_higroscopica.umidade_media.toString().replace('.', ',')
  }
}

// Função para atualizar cápsula da umidade higroscópica
const onCapsulaHigroscopicaChange = (amostra) => {
  const amostraKey = `amostra${amostra}`
  if (form.value.umidade_higroscopica[amostraKey].capsula_id) {
    form.value.umidade_higroscopica[amostraKey].peso_capsula = 
      capsulas[form.value.umidade_higroscopica[amostraKey].capsula_id]
    calcularUmidadeHigroscopica()
  }
}

const validarMassaTotal = (massa) => {
  if (!massa) return true
  const isArgilaOuSilte = form.value.nome_amostra.toLowerCase().includes('argil') || 
                         form.value.nome_amostra.toLowerCase().includes('silt')
  const massaMinima = isArgilaOuSilte ? 1500 : 2000
  return massa >= massaMinima || `Massa mínima deve ser ${massaMinima}g`
}

const calcularResultados = () => {
  const f = form.value
  
  // 1. Calcular massas secas
  const umidade = parseNumber(umidadeHigroscopica.value)
  const fator_correcao = 1 + (umidade / 100) // Umidade já está em porcentagem
  const massa_total_seca = parseNumber(f.massa_total_umida) / fator_correcao
  const massa_menor_10_seca = parseNumber(f.massa_menor_10_umida) / fator_correcao

  const resultados = {
    umidade_higroscopica: umidade,
    fator_correcao,
    massa_total_seca: Number(massa_total_seca.toFixed(2)),
    massa_menor_10_seca: Number(massa_menor_10_seca.toFixed(2))
  }

  // 2. Calcular percentagens para peneiras grossas
  const peneirasGrossas = ['50mm', '38mm', '25mm', '19mm', '9_5mm', '4_8mm', '2_0mm']
  let acumuladoGrosso = 0
  let somaPercentagensGrossas = 0
  
  peneirasGrossas.forEach(peneira => {
    const massa = parseNumber(f['peneira_' + peneira])
    const percentagem = (massa / massa_total_seca) * 100
    somaPercentagensGrossas += percentagem
    acumuladoGrosso += percentagem
    
    resultados['massa_fracao_' + peneira] = Number(massa.toFixed(2))
    resultados['percentagem_retida_' + peneira] = Number(percentagem.toFixed(2))
    resultados['percentagem_acumulada_retida_' + peneira] = Number(acumuladoGrosso.toFixed(2))
    resultados['percentagem_passando_' + peneira] = Number((100 - acumuladoGrosso).toFixed(2))
  })
  
  // 3. Calcular percentagens para peneiras finas
  const peineirasFinas = ['1_2mm', '0_6mm', '0_42mm', '0_30mm', '0_15mm', '0_075mm']
  let acumuladoFino = acumuladoGrosso
  let somaPercentagensFinas = 0
  
  // Calcular o percentual que passa na peneira N° 10 (2,0 mm)
  const percentual_passando_2mm = 100 - acumuladoGrosso
  
  peineirasFinas.forEach(peneira => {
    const massa_retida = parseNumber(f['peneira_' + peneira])
    // Calcular a percentagem em relação à amostra menor que 2,0 mm
    const percentagem_amostra_menor = (massa_retida / massa_menor_10_seca) * 100
    // Ajustar a percentagem para a amostra total
    const percentagem = (percentagem_amostra_menor * percentual_passando_2mm) / 100
    somaPercentagensFinas += percentagem
    acumuladoFino += percentagem
    
    resultados['massa_fracao_' + peneira] = Number(massa_retida.toFixed(2))
    resultados['percentagem_retida_' + peneira] = Number(percentagem.toFixed(2))
    resultados['percentagem_retida_amostra_menor_' + peneira] = Number(percentagem_amostra_menor.toFixed(2))
    resultados['percentagem_acumulada_retida_' + peneira] = Number(acumuladoFino.toFixed(2))
    resultados['percentagem_passando_' + peneira] = Number((100 - acumuladoFino).toFixed(2))
  })

  // Adicionar resultados do fundo
  const massa_fundo = calcularFundo.value
  // Calcular a percentagem do fundo em relação à amostra menor que 2,0 mm
  const percentagem_fundo_amostra_menor = (massa_fundo / massa_menor_10_seca) * 100
  // Ajustar a percentagem para a amostra total
  const percentagem_fundo = percentual_passando_2mm - somaPercentagensFinas // Ajuste para garantir 100%
  acumuladoFino += percentagem_fundo

  resultados['massa_fracao_fundo'] = Number(massa_fundo.toFixed(2))
  resultados['percentagem_retida_fundo'] = Number(percentagem_fundo.toFixed(2))
  resultados['percentagem_retida_amostra_menor_fundo'] = Number(percentagem_fundo_amostra_menor.toFixed(2))
  resultados['percentagem_acumulada_retida_fundo'] = 100 // Garante que o acumulado termine em 100%
  resultados['percentagem_passando_fundo'] = 0 // Garante que o passando termine em 0%

  // 4. Validar soma das percentagens
  const somaPercentagens = somaPercentagensGrossas + somaPercentagensFinas + percentagem_fundo

  if (Math.abs(100 - somaPercentagens) > 0.3) {
    $q.notify({
      type: 'warning',
      message: 'A soma das percentagens retidas difere de 100% em mais de 0,3%'
    })
  }
  
  return resultados
}

const onCalcular = () => {
  // Validar se todos os campos obrigatórios estão preenchidos
  if (!form.value.data_ensaio || !form.value.nome_amostra || 
      !form.value.massa_total_umida || !form.value.massa_menor_10_umida) {
    $q.notify({
      type: 'warning',
      message: 'Preencha todos os campos obrigatórios'
    })
    return
  }

  try {
    resultados.value = calcularResultados()
    
    // Rolar até a seção de resultados
    const resultadosElement = document.querySelector('.resultados')
    if (resultadosElement) {
      resultadosElement.scrollIntoView({ behavior: 'smooth' })
    }
  } catch (error) {
    console.error('Erro ao calcular resultados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao calcular resultados'
    })
  }
}

// Dados das cápsulas
const capsulas = {
  1: 14.02,
  2: 20.03,
  3: 15.94,
  4: 12.88,
  5: 15.30,
  6: 13.57,
  7: 15.01,
  8: 13.88,
  9: 19.53,
  10: 14.44,
  // ... rest of capsulas data ...
}

const onSalvar = async () => {
  try {
    salvando.value = true

    const dadosEntrada = {
      data_ensaio: form.value.data_ensaio,
      nome_amostra: form.value.nome_amostra,
      // Dados da umidade higroscópica - Amostra 1
      capsula_id_1: form.value.umidade_higroscopica.amostra1.capsula_id,
      peso_capsula_1: form.value.umidade_higroscopica.amostra1.peso_capsula,
      peso_bruto_umido_1: form.value.umidade_higroscopica.amostra1.peso_bruto_umido,
      peso_bruto_seco_1: form.value.umidade_higroscopica.amostra1.peso_bruto_seco,
      peso_agua_1: form.value.umidade_higroscopica.amostra1.peso_agua,
      peso_solo_seco_1: form.value.umidade_higroscopica.amostra1.peso_solo_seco,
      umidade_1: form.value.umidade_higroscopica.amostra1.umidade,
      // Dados da umidade higroscópica - Amostra 2
      capsula_id_2: form.value.umidade_higroscopica.amostra2.capsula_id,
      peso_capsula_2: form.value.umidade_higroscopica.amostra2.peso_capsula,
      peso_bruto_umido_2: form.value.umidade_higroscopica.amostra2.peso_bruto_umido,
      peso_bruto_seco_2: form.value.umidade_higroscopica.amostra2.peso_bruto_seco,
      peso_agua_2: form.value.umidade_higroscopica.amostra2.peso_agua,
      peso_solo_seco_2: form.value.umidade_higroscopica.amostra2.peso_solo_seco,
      umidade_2: form.value.umidade_higroscopica.amostra2.umidade,
      // Umidade média
      umidade_media: form.value.umidade_higroscopica.umidade_media,
      // Resto dos dados
      massa_total_umida: parseNumber(form.value.massa_total_umida),
      massa_menor_10_umida: parseNumber(form.value.massa_menor_10_umida),
      peneira_50mm: parseNumber(form.value.peneira_50mm),
      peneira_38mm: parseNumber(form.value.peneira_38mm),
      peneira_25mm: parseNumber(form.value.peneira_25mm),
      peneira_19mm: parseNumber(form.value.peneira_19mm),
      peneira_9_5mm: parseNumber(form.value.peneira_9_5mm),
      peneira_4_8mm: parseNumber(form.value.peneira_4_8mm),
      peneira_2_0mm: parseNumber(form.value.peneira_2_0mm),
      peneira_1_2mm: parseNumber(form.value.peneira_1_2mm),
      peneira_0_6mm: parseNumber(form.value.peneira_0_6mm),
      peneira_0_42mm: parseNumber(form.value.peneira_0_42mm),
      peneira_0_30mm: parseNumber(form.value.peneira_0_30mm),
      peneira_0_15mm: parseNumber(form.value.peneira_0_15mm),
      peneira_0_075mm: parseNumber(form.value.peneira_0_075mm),
      observacoes: form.value.observacoes,
      ambiente_id: route.query.ambiente,
      usuario_cadastro: authStore.user.user_metadata.display_name
    }

    // Inserir entrada
    const { data: entrada, error: entradaError } = await supabase
      .from('granulometria_entradas')
      .insert(dadosEntrada)
      .select()
      .single()

    if (entradaError) throw entradaError

    // Inserir resultados (já estão no formato correto pois foram calculados)
    const { error: resultadosError } = await supabase
      .from('granulometria_resultados')
      .insert({
        ...resultados.value,
        id_entrada: entrada.id
      })

    if (resultadosError) throw resultadosError

    $q.notify({
      type: 'positive',
      message: 'Ensaio salvo com sucesso!'
    })

    // Voltar para a página anterior
    router.push('/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/lista?ambiente=' + route.query.ambiente)
  } catch (error) {
    console.error('Erro ao salvar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao salvar ensaio'
    })
  } finally {
    salvando.value = false
  }
}

const loadEnsaio = async (ensaioId) => {
  try {
    const { data: entrada, error: entradaError } = await supabase
      .from('granulometria_entradas')
      .select('*')
      .eq('id', ensaioId)
      .single()

    if (entradaError) throw entradaError

    const { data: resultado, error: resultadoError } = await supabase
      .from('granulometria_resultados')
      .select('*')
      .eq('id_entrada', ensaioId)
      .single()

    if (resultadoError) throw resultadoError

    // Preencher o formulário com os dados da entrada
    form.value = {
      data_ensaio: entrada.data_ensaio,
      nome_amostra: entrada.nome_amostra,
      umidade_higroscopica: {
        amostra1: {
          capsula_id: entrada.capsula_id_1,
          peso_capsula: entrada.peso_capsula_1,
          peso_bruto_umido: entrada.peso_bruto_umido_1,
          peso_bruto_seco: entrada.peso_bruto_seco_1,
          peso_agua: entrada.peso_agua_1,
          peso_solo_seco: entrada.peso_solo_seco_1,
          umidade: entrada.umidade_1
        },
        amostra2: {
          capsula_id: entrada.capsula_id_2,
          peso_capsula: entrada.peso_capsula_2,
          peso_bruto_umido: entrada.peso_bruto_umido_2,
          peso_bruto_seco: entrada.peso_bruto_seco_2,
          peso_agua: entrada.peso_agua_2,
          peso_solo_seco: entrada.peso_solo_seco_2,
          umidade: entrada.umidade_2
        },
        umidade_media: entrada.umidade_media
      },
      massa_total_umida: entrada.massa_total_umida.toString().replace('.', ','),
      massa_menor_10_umida: entrada.massa_menor_10_umida.toString().replace('.', ','),
      peneira_50mm: entrada.peneira_50mm.toString().replace('.', ','),
      peneira_38mm: entrada.peneira_38mm.toString().replace('.', ','),
      peneira_25mm: entrada.peneira_25mm.toString().replace('.', ','),
      peneira_19mm: entrada.peneira_19mm.toString().replace('.', ','),
      peneira_9_5mm: entrada.peneira_9_5mm.toString().replace('.', ','),
      peneira_4_8mm: entrada.peneira_4_8mm.toString().replace('.', ','),
      peneira_2_0mm: entrada.peneira_2_0mm.toString().replace('.', ','),
      peneira_1_2mm: entrada.peneira_1_2mm.toString().replace('.', ','),
      peneira_0_6mm: entrada.peneira_0_6mm.toString().replace('.', ','),
      peneira_0_42mm: entrada.peneira_0_42mm.toString().replace('.', ','),
      peneira_0_30mm: entrada.peneira_0_30mm.toString().replace('.', ','),
      peneira_0_15mm: entrada.peneira_0_15mm.toString().replace('.', ','),
      peneira_0_075mm: entrada.peneira_0_075mm.toString().replace('.', ','),
      observacoes: entrada.observacoes
    }

    // Calcular e mostrar os resultados
    resultados.value = resultado
  } catch (error) {
    console.error('Erro ao carregar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaio'
    })
  }
}

onMounted(async () => {
  const ambienteId = route.query.ambiente
  if (!ambienteId) {
    router.push('/ensaios/terraplenagem/compactacao-aterro')
    return
  }
  
  await loadAmbiente(ambienteId)

  // Se tiver um ID na rota, carregar o ensaio
  const ensaioId = route.params.id
  if (ensaioId) {
    await loadEnsaio(ensaioId)
  }
})
</script> 