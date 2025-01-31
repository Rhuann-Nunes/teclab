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
            :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/lista?ambiente=' + route.query.ambiente"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">Ensaio de Compactação</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <q-form @submit="salvarEnsaio" class="q-gutter-md">
      <!-- Informações Gerais -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Informações Gerais</div>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <q-input
                v-model="form.nome_amostra"
                label="Nome da Amostra *"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model="form.data_ensaio"
                label="Data do Ensaio *"
                type="date"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model="form.hora_ensaio"
                label="Hora do Ensaio *"
                type="time"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-select
                v-model="form.metodo_compactacao"
                :options="[
                  { label: 'Método A - Normal (12 golpes/camada)', value: 'A', desc: 'Energia normal - 12 golpes por camada' },
                  { label: 'Método B - Intermediário (26 golpes/camada)', value: 'B', desc: 'Energia intermediária - 26 golpes por camada' },
                  { label: 'Método C - Modificado (55 golpes/camada)', value: 'C', desc: 'Energia modificada - 55 golpes por camada' }
                ]"
                label="Método de Compactação *"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
                @update:model-value="onMetodoChange"
              >
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps">
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                      <q-item-label caption>{{ scope.opt.desc }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model.number="form.golpes_por_camada"
                label="Número de Golpes por Camada"
                type="number"
                readonly
                :hint="getGolpesHint(form.metodo_compactacao)"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model.number="form.numero_camadas"
                label="Número de Camadas"
                type="number"
                readonly
                :value="5"
                hint="Conforme DNIT 164/2013-ME, seção 5.2"
              />
            </div>
            <div class="col-12 col-sm-4">
              <q-input
                v-model.number="form.intervalo_percentual"
                label="Intervalo de Umidade (%)"
                type="number"
                :rules="[
                  val => val !== null && val !== '' || 'Campo obrigatório',
                  val => val >= 0 && val <= 10 || 'Valor deve estar entre 0 e 10%'
                ]"
                hint="Incremento percentual entre os pontos (0-10%)"
              />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Após as Informações Gerais e antes da Amostra Base -->
      <q-card>
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
                        :rules="[val => !!val || 'Campo obrigatório']"
                        @update:model-value="onCapsulaHigroscopicaChange(1)"
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
                        :rules="[val => !!val || 'Campo obrigatório']"
                        @update:model-value="onCapsulaHigroscopicaChange(2)"
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

      <!-- Dados da Amostra Base (Modificado) -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Dados da Amostra Base</div>
          <div class="text-caption q-mb-sm text-grey-8">
            Amostra inicial de 6.000g que será usada como base para os pontos da curva.
            Os valores são calculados automaticamente com base na umidade higroscópica média.
          </div>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-4">
              <q-input
                v-model.number="form.amostra_base.peso_total"
                label="Peso Total da Amostra (g)"
                type="number"
                readonly
                :value="6000"
              />
            </div>
            <div class="col-12 col-sm-4">
              <q-input
                v-model.number="form.amostra_base.peso_solo_seco"
                label="Peso do Solo Seco (g)"
                type="number"
                readonly
                class="bg-blue-1"
              />
            </div>
            <div class="col-12 col-sm-4">
              <q-input
                v-model.number="form.amostra_base.peso_agua"
                label="Peso da Água (g)"
                type="number"
                readonly
                class="bg-blue-1"
              />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Pontos da Curva de Compactação -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Pontos da Curva de Compactação</div>
          <div class="text-caption q-mb-sm text-grey-8">
            Cada ponto da curva requer um novo corpo de prova em um molde separado.
            Os campos em azul são calculados automaticamente.
          </div>
          <q-table
            :rows="form.pontos"
            :columns="columnsPontos"
            row-key="ponto"
            :rows-per-page-options="[0]"
            hide-bottom
            :readonly="isVisualizacao"
            class="q-mt-sm"
          >
            <template v-slot:body="props">
              <q-tr :props="props">
                <q-td key="ponto" :props="props" class="text-center">
                  {{ props.row.ponto }}
                </q-td>
                <q-td key="cilindro" :props="props">
                  <q-select
                    v-model="props.row.cilindro_id"
                    :options="Object.keys(cilindros)"
                    emit-value
                    map-options
                    dense
                    options-dense
                    @update:model-value="() => {
                      onCilindroChange(props.row)
                      calcularPontos()
                    }"
                  >
                    <template v-slot:option="scope">
                      <q-item v-bind="scope.itemProps">
                        <q-item-section>
                          <q-item-label>Cilindro {{ scope.opt }}</q-item-label>
                          <q-item-label caption>
                            Peso: {{ cilindros[scope.opt].peso }}g | Volume: {{ cilindros[scope.opt].volume }}mm³
                          </q-item-label>
                        </q-item-section>
                      </q-item>
                    </template>
                  </q-select>
                </q-td>
                <q-td key="peso_bruto_umido" :props="props">
                  <q-input
                    v-model.number="props.row.peso_bruto_umido"
                    type="number"
                    dense
                    step="0.1"
                    :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                    @update:model-value="calcularPontos"
                  />
                </q-td>
                <q-td key="peso_solo_umido" :props="props" class="text-center bg-blue-1">
                  {{ props.row.peso_solo_umido }}
                </q-td>
                <q-td key="agua_adicionada" :props="props">
                  <template v-if="props.row.ponto === 1">
                    <q-input
                      v-model.number="props.row.agua_adicionada"
                      type="number"
                      dense
                      step="0.1"
                      :rules="[val => val !== null && val !== '' || 'Campo obrigatório']"
                      @update:model-value="calcularPontos"
                    />
                  </template>
                  <template v-else>
                    <div class="text-center bg-blue-1">
                      {{ props.row.agua_adicionada }}
                    </div>
                  </template>
                </q-td>
                <q-td key="agua_total" :props="props" class="text-center bg-blue-1">
                  {{ props.row.agua_total }}
                </q-td>
                <q-td key="umidade_media" :props="props" class="text-center bg-blue-1">
                  {{ props.row.umidade_media }}
                </q-td>
                <q-td key="densidade_solo_umido" :props="props" class="text-center bg-blue-1">
                  {{ props.row.densidade_solo_umido }}
                </q-td>
                <q-td key="densidade_solo_seco" :props="props" class="text-center bg-blue-1">
                  {{ props.row.densidade_solo_seco }}
                </q-td>
              </q-tr>
            </template>
          </q-table>
        </q-card-section>
      </q-card>

      <!-- Observações -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Observações</div>
          <q-input
            v-model="form.observacoes"
            type="textarea"
            label="Observações"
            :readonly="isVisualizacao"
          />
        </q-card-section>
      </q-card>

      <!-- Resultados Finais -->
      <q-card v-if="isVisualizacao">
        <q-card-section>
          <div class="text-h6 q-mb-md">Resultados Finais</div>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <q-input
                v-model="resultadosFinais.massa_especifica_aparente_seca_maxima"
                label="MEA Seca Máxima (g/cm³)"
                type="number"
                readonly
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model="resultadosFinais.umidade_otima"
                label="Umidade Ótima (%)"
                type="number"
                readonly
              />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Resultados -->
      <q-card class="q-mt-md">
        <q-card-section>
          <div class="text-h6">Resultados</div>
          <div class="row q-col-gutter-md">
            <div v-for="(ponto, index) in form.pontos" :key="index" class="col-12">
              <q-card>
                <q-card-section>
                  <div class="text-subtitle1">Ponto {{ index + 1 }}</div>
                  <div class="row q-col-gutter-md">
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="ponto.teor_umidade"
                        type="number"
                        label="Teor de Umidade (%)"
                        readonly
                        dense
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="ponto.massa_especifica_aparente_umida"
                        type="number"
                        label="MEA Úmida (g/cm³)"
                        readonly
                        dense
                      />
                    </div>
                    <div class="col-12 col-sm-4">
                      <q-input
                        v-model="ponto.massa_especifica_aparente_seca"
                        type="number"
                        label="MEA Seca (g/cm³)"
                        readonly
                        dense
                      />
                    </div>
                  </div>
                </q-card-section>
              </q-card>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Botões de Ação -->
      <div class="row justify-end q-gutter-sm">
        <q-btn
          v-if="!isVisualizacao"
          label="Salvar"
          type="submit"
          color="primary"
          :loading="salvando"
          :disable="form.pontos.length === 0"
        />
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const isVisualizacao = computed(() => route.name === 'ensaios-compactacao-visualizar')
const ambiente = ref(null)
const salvando = ref(false)

// Inicializar form com a estrutura correta
const form = ref({
  ambiente_id: route.query.ambiente,
  data_ensaio: '',
  hora_ensaio: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }),
  nome_amostra: '',
  metodo_compactacao: '',
  golpes_por_camada: null,
  numero_camadas: 5, // Fixo em 5 camadas
  observacoes: '',
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
  amostra_base: {
    peso_total: 6000,
    peso_solo_seco: null,
    peso_agua: null
  },
  intervalo_percentual: null,
  pontos: []
})

const resultados = ref([])
const resultadosFinais = ref({
  massa_especifica_aparente_seca_maxima: null,
  umidade_otima: null
})

// Dados dos cilindros
const cilindros = {
  1: { peso: 4916.0, volume: 2078.0, altura: 11.43 },
  2: { peso: 5496.0, volume: 2091.0, altura: 11.48 },
  3: { peso: 4948.0, volume: 2080.0, altura: 11.46 },
  4: { peso: 4256.0, volume: 2054.0, altura: 11.43 },
  5: { peso: 4894.0, volume: 2078.0, altura: 11.41 },
  6: { peso: 3930.0, volume: 2067.0, altura: 11.31 },
  7: { peso: 4900.0, volume: 2085.0, altura: 11.45 },
  8: { peso: 5526.0, volume: 2079.0, altura: 11.46 },
  9: { peso: 4174.0, volume: 2050.0, altura: 11.37 },
  10: { peso: 4158.0, volume: 2024.0, altura: 11.25 },
  11: { peso: 4682.0, volume: 2068.0, altura: 11.40 },
  12: { peso: 4418.0, volume: 2084.0, altura: 11.48 },
  13: { peso: 4944.0, volume: 2070.0, altura: 11.41 },
  14: { peso: 3998.0, volume: 2090.0, altura: 11.41 },
  15: { peso: 4160.0, volume: 2058.0, altura: 11.34 },
  16: { peso: 4030.0, volume: 2079.0, altura: 11.38 },
  17: { peso: 3804.0, volume: 2061.0, altura: 11.24 },
  18: { peso: 4086.0, volume: 2074.0, altura: 11.31 },
  19: { peso: 4156.0, volume: 2074.0, altura: 11.43 },
  20: { peso: 4934.0, volume: 2077.0, altura: 11.50 },
  21: { peso: 4074.0, volume: 2074.0, altura: 11.00 },
  22: { peso: 4600.0, volume: 2083.0, altura: 11.00 },
  23: { peso: 4923.0, volume: 2089.0, altura: 11.00 },
  24: { peso: 4350.0, volume: 2066.0, altura: 11.00 },
  25: { peso: 4700.0, volume: 2077.0, altura: 11.00 },
  26: { peso: 4046.0, volume: 2088.0, altura: 11.00 },
  27: { peso: 4914.0, volume: 2086.0, altura: 11.00 },
  28: { peso: 4918.0, volume: 2075.0, altura: 11.00 },
  29: { peso: 4348.0, volume: 2088.0, altura: 11.00 },
  30: { peso: 4916.0, volume: 2076.0, altura: 11.00 },
  31: { peso: 4674.0, volume: 2092.0, altura: 11.00 },
  32: { peso: 4608.0, volume: 2071.0, altura: 11.00 },
  33: { peso: 4100.0, volume: 2050.0, altura: 11.00 },
  34: { peso: 4872.0, volume: 2179.0, altura: 12.00 },
  35: { peso: 4114.0, volume: 2087.0, altura: 11.00 },
  36: { peso: 4378.0, volume: 2065.0, altura: 11.00 }
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
  11: 17.17,
  12: 14.14,
  13: 15.11,
  14: 16.27,
  15: 14.92,
  16: 13.16,
  17: 15.75,
  18: 13.16,
  19: 15.40,
  20: 13.79,
  21: 15.45,
  22: 13.78,
  23: 15.78,
  24: 14.23,
  25: 15.10,
  26: 14.23,
  27: 15.40,
  28: 14.23,
  29: 13.44,
  30: 14.23,
  31: 15.41,
  32: 14.23,
  33: 13.24,
  34: 12.78,
  35: 13.47,
  36: 15.44,
  37: 14.21,
  38: 13.44,
  39: 14.78,
  40: 15.23,
  41: 13.78,
  42: 14.25,
  43: 13.78,
  44: 14.98,
  45: 15.10,
  46: 13.44,
  47: 14.87,
  48: 15.02,
  49: 14.55,
  50: 13.99,
  51: 12.55,
  52: 14.10,
  53: 13.47,
  54: 14.58,
  55: 15.36,
  56: 14.98,
  57: 15.66,
  58: 14.10,
  59: 13.98,
  60: 14.22
}

// Opções para os selects
const cilindrosOptions = Object.entries(cilindros).map(([num, dados]) => ({
  label: `Cilindro ${num} (${dados.peso}g - ${dados.volume}mm³)`,
  value: num,
  ...dados
}))

const capsulasOptions = Object.entries(capsulas).map(([num, peso]) => ({
  label: `Cápsula ${num} (${peso}g)`,
  value: num,
  peso
}))

// Atualizar columnsPontos
const columnsPontos = [
  {
    name: 'ponto',
    label: 'Ponto',
    field: 'ponto',
    align: 'center',
    style: 'width: 70px'
  },
  {
    name: 'cilindro',
    label: 'Cilindro',
    field: 'cilindro_id',
    align: 'left',
    style: 'width: 180px'
  },
  {
    name: 'peso_bruto_umido',
    label: 'Peso Bruto Úmido (g)',
    field: 'peso_bruto_umido',
    align: 'center',
    style: 'width: 150px'
  },
  {
    name: 'peso_solo_umido',
    label: 'Peso Solo Úmido (g)',
    field: 'peso_solo_umido',
    align: 'center',
    style: 'width: 150px; background: #E3F2FD'
  },
  {
    name: 'agua_adicionada',
    label: 'Água Adicionada (g)',
    field: 'agua_adicionada',
    align: 'center',
    style: 'width: 120px'
  },
  {
    name: 'agua_total',
    label: 'Água Total (g)',
    field: 'agua_total',
    align: 'center',
    style: 'width: 120px; background: #E3F2FD'
  },
  {
    name: 'umidade_media',
    label: 'Umidade Média (%)',
    field: 'umidade_media',
    align: 'center',
    style: 'width: 120px; background: #E3F2FD'
  },
  {
    name: 'densidade_solo_umido',
    label: 'Dens. Solo Úmido (g/cm³)',
    field: 'densidade_solo_umido',
    align: 'center',
    style: 'width: 150px; background: #E3F2FD'
  },
  {
    name: 'densidade_solo_seco',
    label: 'Dens. Solo Seco (g/cm³)',
    field: 'densidade_solo_seco',
    align: 'center',
    style: 'width: 150px; background: #E3F2FD'
  }
]

const getGolpesHint = (metodo) => {
  switch (metodo) {
    case 'A':
      return 'Energia normal - DNIT 164/2013-ME, seção 6.1'
    case 'B':
      return 'Energia intermediária - DNIT 164/2013-ME, seção 6.2'
    case 'C':
      return 'Energia modificada - DNIT 164/2013-ME, seção 6.3'
    default:
      return ''
  }
}

const onMetodoChange = (value) => {
  const metodo = value?.value || value
  switch (metodo) {
    case 'A':
      form.value.golpes_por_camada = 12 // Método A - Normal (DNIT 164/2013-ME, seção 6.1)
      break
    case 'B':
      form.value.golpes_por_camada = 26 // Método B - Intermediário (DNIT 164/2013-ME, seção 6.2)
      break
    case 'C':
      form.value.golpes_por_camada = 55 // Método C - Modificado (DNIT 164/2013-ME, seção 6.3)
      break
    default:
      form.value.golpes_por_camada = null
  }
}

const calcularTeorUmidade = (ponto) => {
  if (!ponto.peso_capsula_umida || !ponto.peso_capsula_seca || !ponto.peso_capsula) {
    return null
  }

  const pesoAguaTotal = ponto.peso_capsula_umida - ponto.peso_capsula_seca
  const pesoSoloSeco = ponto.peso_capsula_seca - ponto.peso_capsula

  if (pesoSoloSeco === 0) {
    return null
  }

  return Number(((pesoAguaTotal / pesoSoloSeco) * 100).toFixed(2))
}

const calcularMassaEspecificaUmida = (ponto) => {
  if (!ponto.peso_solo_umido_comp || !ponto.massa_molde || !ponto.volume_molde) {
    return null
  }

  const pesoSoloUmido = ponto.peso_solo_umido_comp - ponto.massa_molde
  return Number((pesoSoloUmido / ponto.volume_molde).toFixed(3))
}

const calcularMassaEspecificaSeca = (ponto) => {
  const teor_umidade = calcularTeorUmidade(ponto)
  const massa_especifica_umida = calcularMassaEspecificaUmida(ponto)

  if (!teor_umidade || !massa_especifica_umida) {
    return null
  }

  return Number((massa_especifica_umida / (1 + teor_umidade / 100)).toFixed(3))
}

// Funções para atualizar dados ao selecionar cilindro/cápsula
const onCilindroChange = (ponto) => {
  if (ponto.cilindro_id) {
    const cilindro = cilindros[ponto.cilindro_id]
    ponto.massa_molde = cilindro.peso
    ponto.volume_molde = cilindro.volume
  } else {
    ponto.massa_molde = null
    ponto.volume_molde = null
  }
}

const onCapsulaChange = (ponto) => {
  if (ponto.capsula_id) {
    ponto.peso_capsula = capsulas[ponto.capsula_id]
  } else {
    ponto.peso_capsula = null
  }
}

// Função para calcular os dados dos pontos
const calcularPontos = () => {
  if (!form.value.amostra_base.peso_agua || 
      !form.value.amostra_base.peso_solo_seco || 
      !form.value.intervalo_percentual) {
    console.log('Dados da amostra base incompletos')
    return
  }

  form.value.pontos.forEach((ponto, index) => {
    if (!ponto.peso_bruto_umido || !ponto.massa_molde || !ponto.volume_molde) return

    // Calcular peso do solo úmido = peso bruto úmido - peso do cilindro
    ponto.peso_solo_umido = Number((ponto.peso_bruto_umido - ponto.massa_molde).toFixed(2))

    // Calcular água adicionada e água total
    if (index === 0) {
      // Para o primeiro ponto, usar o valor inserido pelo usuário
      ponto.agua_total = Number((ponto.agua_adicionada + form.value.amostra_base.peso_agua).toFixed(2))
    } else {
      // Para os demais pontos, calcular baseado no intervalo percentual
      const incremento = form.value.amostra_base.peso_solo_seco * (form.value.intervalo_percentual / 100)
      ponto.agua_adicionada = Number((form.value.pontos[0].agua_adicionada + (incremento * index)).toFixed(2))
      ponto.agua_total = Number((ponto.agua_adicionada + form.value.amostra_base.peso_agua).toFixed(2))
    }

    // Calcular umidade média
    ponto.umidade_media = Number(((ponto.agua_total / form.value.amostra_base.peso_solo_seco) * 100).toFixed(2))

    // Calcular densidade do solo úmido (g/cm³) = (peso solo úmido * 1000) / volume do cilindro
    ponto.densidade_solo_umido = Number(((ponto.peso_solo_umido * 1000) / ponto.volume_molde).toFixed(3))

    // Calcular densidade do solo seco (g/cm³)
    ponto.densidade_solo_seco = Number((ponto.densidade_solo_umido / (1 + ponto.umidade_media / 100)).toFixed(3))
  })
}

// Inicializar pontos
const inicializarPontos = () => {
  form.value.pontos = Array.from({ length: 5 }, (_, i) => ({
    ponto: i + 1,
    cilindro_id: null,
    peso_bruto_umido: null,
    peso_solo_umido: null,
    agua_adicionada: null,
    agua_total: null,
    umidade_media: null,
    densidade_solo_umido: null,
    densidade_solo_seco: null,
    massa_molde: null,
    volume_molde: null
  }))
}

// Inicializar pontos ao criar o componente
inicializarPontos()

// Observar mudanças nos pontos
watch(() => form.value.pontos, () => {
  if (!form.value.pontos) return

  form.value.pontos.forEach(ponto => {
    // Atualizar os campos de resultado com os valores já calculados
    ponto.teor_umidade = ponto.umidade_media
    ponto.massa_especifica_aparente_umida = ponto.densidade_solo_umido
    ponto.massa_especifica_aparente_seca = ponto.densidade_solo_seco
  })
}, { deep: true })

const loadAmbiente = async (ambienteId) => {
  try {
    const { data, error } = await supabase
      .from('ambientes_compactacao_aterro')
      .select('*, localizacao:localizacao_id (nome)')
      .eq('id', ambienteId)
      .single()

    if (error) throw error
    ambiente.value = data
  } catch (error) {
    console.error('Erro ao carregar ambiente:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ambiente'
    })
  }
}

const loadEnsaio = async (ensaioId) => {
  try {
    // Carregar dados do ensaio
    const { data: ensaio, error: ensaioError } = await supabase
      .from('compactacao_entradas')
      .select('*')
      .eq('id', ensaioId)
      .single()

    if (ensaioError) throw ensaioError

    // Carregar pontos
    const { data: pontos, error: pontosError } = await supabase
      .from('compactacao_pontos')
      .select('*')
      .eq('compactacao_id', ensaioId)
      .order('ponto')

    if (pontosError) throw pontosError

    // Carregar resultados finais
    const { data: resultadoFinal, error: resultadoFinalError } = await supabase
      .from('compactacao_resultados_finais')
      .select('*')
      .eq('compactacao_id', ensaioId)
      .single()

    if (resultadoFinalError && resultadoFinalError.code !== 'PGRST116') throw resultadoFinalError

    // Mapear dados do ensaio para o form
    form.value = {
      ambiente_id: ensaio.ambiente_id,
      data_ensaio: ensaio.data_ensaio,
      hora_ensaio: ensaio.hora_ensaio,
      nome_amostra: ensaio.nome_amostra,
      metodo_compactacao: ensaio.metodo_compactacao,
      golpes_por_camada: ensaio.golpes_por_camada,
      numero_camadas: ensaio.numero_camadas,
      observacoes: ensaio.observacoes,
      umidade_higroscopica: {
        amostra1: {
          capsula_id: ensaio.capsula_id_1,
          peso_capsula: ensaio.peso_capsula_1,
          peso_bruto_umido: ensaio.peso_bruto_umido_1,
          peso_bruto_seco: ensaio.peso_bruto_seco_1,
          peso_agua: ensaio.peso_agua_1,
          peso_solo_seco: ensaio.peso_solo_seco_1,
          umidade: ensaio.umidade_1
        },
        amostra2: {
          capsula_id: ensaio.capsula_id_2,
          peso_capsula: ensaio.peso_capsula_2,
          peso_bruto_umido: ensaio.peso_bruto_umido_2,
          peso_bruto_seco: ensaio.peso_bruto_seco_2,
          peso_agua: ensaio.peso_agua_2,
          peso_solo_seco: ensaio.peso_solo_seco_2,
          umidade: ensaio.umidade_2
        },
        umidade_media: ensaio.umidade_media
      },
      amostra_base: {
        peso_total: ensaio.peso_total_amostra,
        peso_solo_seco: ensaio.peso_solo_seco_amostra,
        peso_agua: ensaio.peso_agua_amostra
      },
      intervalo_percentual: ensaio.intervalo_percentual,
      pontos: pontos.map(ponto => ({
        ponto: ponto.ponto,
        cilindro_id: ponto.cilindro_id,
        peso_bruto_umido: ponto.peso_bruto_umido,
        peso_solo_umido: ponto.peso_solo_umido,
        agua_adicionada: ponto.agua_adicionada,
        agua_total: ponto.agua_total,
        umidade_media: ponto.umidade_media,
        densidade_solo_umido: ponto.densidade_solo_umido,
        densidade_solo_seco: ponto.densidade_solo_seco,
        massa_molde: ponto.massa_molde,
        volume_molde: ponto.volume_molde,
        teor_umidade: ponto.umidade_media,
        massa_especifica_aparente_umida: ponto.densidade_solo_umido,
        massa_especifica_aparente_seca: ponto.densidade_solo_seco
      }))
    }

    // Atualizar resultados finais
    resultadosFinais.value = resultadoFinal || {
      umidade_otima: null,
      massa_especifica_aparente_seca_maxima: null
    }

    // Chamar onMetodoChange para atualizar o número de golpes
    onMetodoChange(form.value.metodo_compactacao)

  } catch (error) {
    console.error('Erro ao carregar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaio'
    })
  }
}

const salvarEnsaio = async () => {
  try {
    salvando.value = true

    // Garantir que a hora do ensaio está definida
    if (!form.value.hora_ensaio) {
      form.value.hora_ensaio = new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
    }

    // Extrair o valor do método de compactação (A, B ou C)
    const metodoCompactacao = form.value.metodo_compactacao?.value || form.value.metodo_compactacao

    // Inserir entrada do ensaio
    const { data: entrada, error: entradaError } = await supabase
      .from('compactacao_entradas')
      .insert({
        ambiente_id: route.query.ambiente,
        data_ensaio: form.value.data_ensaio,
        hora_ensaio: form.value.hora_ensaio,
        nome_amostra: form.value.nome_amostra,
        metodo_compactacao: metodoCompactacao,
        golpes_por_camada: form.value.golpes_por_camada,
        numero_camadas: form.value.numero_camadas,
        observacoes: form.value.observacoes,
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
        // Umidade média e dados da amostra base
        umidade_media: form.value.umidade_higroscopica.umidade_media,
        peso_total_amostra: form.value.amostra_base.peso_total,
        peso_solo_seco_amostra: form.value.amostra_base.peso_solo_seco,
        peso_agua_amostra: form.value.amostra_base.peso_agua,
        intervalo_percentual: form.value.intervalo_percentual
      })
      .select()
      .single()

    if (entradaError) throw entradaError

    // Inserir pontos
    const pontosParaInserir = form.value.pontos.map(ponto => ({
      compactacao_id: entrada.id,
      ponto: ponto.ponto,
      cilindro_id: ponto.cilindro_id,
      peso_bruto_umido: ponto.peso_bruto_umido,
      peso_solo_umido: ponto.peso_solo_umido,
      agua_adicionada: ponto.agua_adicionada,
      agua_total: ponto.agua_total,
      umidade_media: ponto.umidade_media,
      densidade_solo_umido: ponto.densidade_solo_umido,
      densidade_solo_seco: ponto.densidade_solo_seco,
      massa_molde: ponto.massa_molde,
      volume_molde: ponto.volume_molde
    }))

    const { error: pontosError } = await supabase
      .from('compactacao_pontos')
      .insert(pontosParaInserir)

    if (pontosError) throw pontosError

    // Inserir resultados
    const resultadosParaInserir = form.value.pontos.map(ponto => ({
      compactacao_id: entrada.id,
      ponto: ponto.ponto,
      teor_umidade: ponto.umidade_media,
      massa_especifica_aparente_umida: ponto.densidade_solo_umido,
      massa_especifica_aparente_seca: ponto.densidade_solo_seco
    }))

    const { error: resultadosError } = await supabase
      .from('compactacao_resultados')
      .insert(resultadosParaInserir)

    if (resultadosError) throw resultadosError

    // Inserir resultado final
    const { error: resultadoFinalError } = await supabase
      .from('compactacao_resultados_finais')
      .insert({
        compactacao_id: entrada.id,
        umidade_otima: calcularUmidadeOtima(),
        massa_especifica_aparente_seca_maxima: calcularMassaEspecificaSecaMaxima()
      })

    if (resultadoFinalError) throw resultadoFinalError

    $q.notify({
      type: 'positive',
      message: 'Ensaio salvo com sucesso!'
    })

    router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/lista?ambiente=${route.query.ambiente}`)
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

// Função para atualizar cápsula da umidade higroscópica
const onCapsulaHigroscopicaChange = (amostra) => {
  const amostraKey = `amostra${amostra}`
  if (form.value.umidade_higroscopica[amostraKey].capsula_id) {
    form.value.umidade_higroscopica[amostraKey].peso_capsula = 
      capsulas[form.value.umidade_higroscopica[amostraKey].capsula_id]
    calcularUmidadeHigroscopica()
  }
}

// Função para calcular umidade higroscópica
const calcularUmidadeHigroscopica = () => {
  // Calcular para amostra 1
  const amostra1 = form.value.umidade_higroscopica.amostra1
  if (amostra1.peso_bruto_umido && amostra1.peso_bruto_seco && amostra1.peso_capsula) {
    amostra1.peso_agua = Number((amostra1.peso_bruto_umido - amostra1.peso_bruto_seco).toFixed(2))
    amostra1.peso_solo_seco = Number((amostra1.peso_bruto_seco - amostra1.peso_capsula).toFixed(2))
    amostra1.umidade = Number(((amostra1.peso_agua / amostra1.peso_solo_seco) * 100).toFixed(2))
  }

  // Calcular para amostra 2
  const amostra2 = form.value.umidade_higroscopica.amostra2
  if (amostra2.peso_bruto_umido && amostra2.peso_bruto_seco && amostra2.peso_capsula) {
    amostra2.peso_agua = Number((amostra2.peso_bruto_umido - amostra2.peso_bruto_seco).toFixed(2))
    amostra2.peso_solo_seco = Number((amostra2.peso_bruto_seco - amostra2.peso_capsula).toFixed(2))
    amostra2.umidade = Number(((amostra2.peso_agua / amostra2.peso_solo_seco) * 100).toFixed(2))
  }

  // Calcular umidade média
  if (amostra1.umidade && amostra2.umidade) {
    form.value.umidade_higroscopica.umidade_media = 
      Number(((amostra1.umidade + amostra2.umidade) / 2).toFixed(2))
    
    // Calcular peso do solo seco e água da amostra base
    const pesoTotal = form.value.amostra_base.peso_total
    form.value.amostra_base.peso_solo_seco = 
      Number((pesoTotal / (1 + form.value.umidade_higroscopica.umidade_media/100)).toFixed(2))
    form.value.amostra_base.peso_agua = 
      Number((pesoTotal - form.value.amostra_base.peso_solo_seco).toFixed(2))
    
    // Recalcular os pontos da curva com os novos valores
    calcularPontos()
  }
}

// Função para calcular umidade ótima
const calcularUmidadeOtima = () => {
  if (!form.value.pontos.length) return null

  // Encontrar o ponto com maior densidade seca
  const pontoOtimo = form.value.pontos.reduce((prev, current) => {
    return (current.densidade_solo_seco > prev.densidade_solo_seco) ? current : prev
  })

  return pontoOtimo.umidade_media
}

// Função para calcular massa específica aparente seca máxima
const calcularMassaEspecificaSecaMaxima = () => {
  if (!form.value.pontos.length) return null

  // Encontrar a maior densidade seca entre os pontos
  return Math.max(...form.value.pontos.map(p => p.densidade_solo_seco))
}

onMounted(async () => {
  const ambienteId = route.query.ambiente
  if (!ambienteId) {
    router.push('/ensaios/terraplenagem/compactacao-aterro')
    return
  }
  
  await loadAmbiente(ambienteId)
  
  // Se estiver no modo de visualização, carregar o ensaio
  if (route.params.id) {
    await loadEnsaio(route.params.id)
  }
})
</script> 