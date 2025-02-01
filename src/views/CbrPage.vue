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
            :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/lista?ambiente=' + route.query.ambiente"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">Ensaio de CBR e Expansão</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <q-form @submit="salvarEnsaio" class="q-gutter-md">
      <!-- Informações Gerais -->
      <q-card>
        <q-card-section>
          <div class="text-h6">Informações Gerais</div>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <q-select
                v-model="form.ensaio_selecionado"
                :options="ensaiosCompactacao"
                label="Ensaio de Compactação *"
                :rules="[val => !!val || 'Campo obrigatório']"
                @update:model-value="onCompactacaoChange"
                :readonly="isVisualizacao"
                emit-value
                map-options
              >
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps">
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                      <q-item-label caption>
                        Data: {{ formatarData(scope.opt.data_ensaio) }}
                      </q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
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
              <q-input
                v-model="form.nome_amostra"
                label="Nome da Amostra *"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model.number="form.numero_golpes"
                label="Número de Golpes *"
                type="number"
                :readonly="isVisualizacao"
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model.number="form.altura_cilindro"
                label="Altura do Cilindro (cm) *"
                type="number"
                :rules="[val => !!val || 'Campo obrigatório']"
                hint="Altura padrão do cilindro CBR"
              />
            </div>
            <div class="col-12 col-sm-6">
              <q-input
                v-model.number="form.constante_prensa"
                label="Constante da Prensa *"
                type="number"
                :rules="[val => !!val || 'Campo obrigatório']"
                hint="Constante para cálculo da pressão"
              />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Corpos de Prova -->
      <q-card class="q-mt-md" v-if="form.ensaio_selecionado">
        <q-card-section>
          <div class="text-h6">Corpos de Prova</div>
          <div class="text-caption q-mb-sm text-grey-8">
            Os 3 corpos de prova com maior massa específica aparente seca do ensaio de compactação selecionado.
          </div>
          <div class="row q-col-gutter-md">
            <div v-for="(cilindro, index) in form.cilindros_disponiveis" :key="cilindro.id" class="col-12 col-sm-4">
              <q-card>
                <q-card-section>
                  <div class="text-subtitle1">Corpo de Prova {{ index + 1 }}</div>
                  <div class="q-gutter-y-sm">
                    <div>Cilindro: {{ cilindro.cilindro_id }}</div>
                    <div>MEA Seca: {{ formatarNumero(cilindro.densidade_solo_seco, 3) }} g/cm³</div>
                    <div>Teor de Umidade: {{ formatarNumero(cilindro.teor_umidade, 2) }}%</div>
                  </div>
                </q-card-section>
              </q-card>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Dados de Expansão -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Dados de Expansão</div>
          <div v-for="(cilindro, cilindroIndex) in form.cilindros_disponiveis" :key="cilindro.id" class="q-mb-lg">
            <div class="text-subtitle1 q-mb-sm">Cilindro Nº {{ cilindro.cilindro_id }}</div>
            <q-table
              :rows="form.leituras_expansao[cilindroIndex]"
              :columns="[
                { name: 'data', label: 'Data', field: 'data', align: 'left' },
                { name: 'hora', label: 'Hora', field: 'hora', align: 'left' },
                { name: 'leitura', label: 'Leitura', field: 'leitura_extensometro', align: 'left' }
              ]"
              row-key="data"
              flat
              bordered
              hide-bottom
              :rows-per-page-options="[0]"
            >
              <template v-slot:body="props">
                <q-tr :props="props">
                  <q-td key="data" :props="props">
                    <q-input
                      v-model="props.row.data"
                      type="date"
                      dense
                      :readonly="isVisualizacao"
                    />
                  </q-td>
                  <q-td key="hora" :props="props">
                    <q-input
                      v-model="props.row.hora"
                      type="time"
                      dense
                      :readonly="isVisualizacao"
                    />
                  </q-td>
                  <q-td key="leitura" :props="props">
                    <q-input
                      v-model.number="props.row.leitura_extensometro"
                      type="number"
                      dense
                      :readonly="isVisualizacao"
                    />
                  </q-td>
                </q-tr>
              </template>
            </q-table>
            <div class="row q-mt-sm">
              <div class="col">
                <div class="text-caption">
                  Diferença: {{ calcularDiferencaExpansao(cilindroIndex).toFixed(2) }}
                </div>
                <div class="text-caption">
                  Expansão: {{ calcularExpansao(cilindro.cilindro_id).toFixed(2) }}%
                </div>
              </div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Dados de Penetração -->
      <q-card>
        <q-card-section>
          <div class="text-h6 q-mb-md">Dados de Penetração</div>
          <div class="row q-col-gutter-md">
            <div v-for="(cilindro, cilindroIndex) in form.cilindros_disponiveis" :key="cilindro.id" class="col-12">
              <div class="text-subtitle1 q-mb-sm">Cilindro Nº {{ cilindro.cilindro_id }}</div>
              <q-table
                :rows="form.leituras_penetracao[cilindroIndex]"
                :columns="[
                  { name: 'penetracao', label: 'Penet. (mm)', field: 'penetracao_mm', align: 'left' },
                  { name: 'tempo', label: 'Tempo (min)', field: 'tempo_penetracao', align: 'left' },
                  { name: 'leitura', label: 'Leitura', field: 'leitura_extensometro', align: 'left' },
                  { name: 'pressao', label: 'Pressão (kgf/cm²)', field: 'pressao_calculada', align: 'left' },
                  { name: 'isc', label: 'I.S.C.', field: 'isc', align: 'left' }
                ]"
                row-key="penetracao_mm"
                flat
                bordered
                hide-bottom
                :rows-per-page-options="[0]"
              >
                <template v-slot:body="props">
                  <q-tr :props="props">
                    <q-td key="penetracao" :props="props">
                      {{ props.row.penetracao_mm.toFixed(2) }}
                    </q-td>
                    <q-td key="tempo" :props="props">
                      <q-input
                        v-model.number="props.row.tempo_penetracao"
                        type="number"
                        dense
                        :readonly="isVisualizacao"
                      />
                    </q-td>
                    <q-td key="leitura" :props="props">
                      <q-input
                        v-model.number="props.row.leitura_extensometro"
                        type="number"
                        dense
                        :readonly="isVisualizacao"
                        @update:model-value="calcularPressaoEIsc(cilindroIndex, props.rowIndex)"
                      />
                    </q-td>
                    <q-td key="pressao" :props="props">
                      {{ formatarNumero(props.row.pressao_calculada, 3) || '-' }}
                    </q-td>
                    <q-td key="isc" :props="props">
                      <span v-if="props.row.isc" :class="{ 'text-primary': props.row.isc_referencia }">
                        {{ formatarNumero(props.row.isc, 1) }}%
                      </span>
                    </q-td>
                  </q-tr>
                </template>
              </q-table>
            </div>
          </div>
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

      <!-- Botões de Ação -->
      <div class="row justify-end q-gutter-sm">
        <q-btn
          v-if="!isVisualizacao"
          label="Salvar"
          type="submit"
          color="primary"
          :loading="salvando"
        />
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const isVisualizacao = computed(() => !!route.params.id)
const ambiente = ref(null)
const salvando = ref(false)

const form = ref({
  ambiente_id: route.query.ambiente,
  data_ensaio: '',
  hora_ensaio: '',
  nome_amostra: '',
  ensaio_selecionado: null,
  numero_golpes: null,
  altura_cilindro: 11.40,
  constante_prensa: 0.0921,
  cilindros_disponiveis: [],
  leituras_expansao: [],
  leituras_penetracao: [],
  observacoes: ''
})

// Lista de ensaios de compactação disponíveis
const ensaiosCompactacao = ref([])

// Função para formatar a data no padrão brasileiro
const formatarData = (data) => {
  if (!data) return ''
  const [ano, mes, dia] = data.split('-')
  return `${dia}/${mes}/${ano}`
}

const adicionarLeituraExpansao = () => {
  form.value.leituras_expansao.push({
    tempo_leitura: null,
    leitura_extensometro: null
  })
}

const removerLeituraExpansao = (index) => {
  form.value.leituras_expansao.splice(index, 1)
}

const adicionarLeituraPenetracao = () => {
  form.value.leituras_penetracao.push({
    tempo_penetracao: null,
    penetracao_mm: null,
    leitura_extensometro: null
  })
}

const removerLeituraPenetracao = (index) => {
  form.value.leituras_penetracao.splice(index, 1)
}

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
    console.log('Iniciando loadEnsaio com ID:', ensaioId)
    
    const { data: ensaio, error: ensaioError } = await supabase
      .from('cbr_entradas')
      .select(`
        *,
        compactacao:compactacao_id (
          id,
          nome_amostra,
          data_ensaio,
          hora_ensaio,
          golpes_por_camada,
          compactacao_pontos!inner (
            id,
            ponto,
            cilindro_id,
            densidade_solo_umido,
            densidade_solo_seco,
            volume_molde,
            umidade_media
          )
        ),
        leituras_expansao:cbr_leituras_expansao (
          id,
          compactacao_ponto_id,
          data,
          hora,
          leitura_extensometro,
          ordem
        ),
        leituras_penetracao:cbr_leituras_penetracao (
          id,
          compactacao_ponto_id,
          tempo_penetracao,
          penetracao_mm,
          leitura_extensometro,
          pressao_calculada,
          pressao_padrao,
          isc,
          isc_referencia,
          ordem
        ),
        resultados:cbr_resultados (
          id,
          compactacao_ponto_id,
          diferenca_expansao,
          expansao_percentual,
          isc_2_54,
          isc_5_08,
          isc_escolhido
        )
      `)
      .eq('id', ensaioId)
      .single()

    if (ensaioError) throw ensaioError
    
    console.log('Dados do ensaio carregados:', ensaio)
    console.log('ID do ensaio de compactação:', ensaio.compactacao_id)

    // Ordenar as leituras por ordem
    if (ensaio.leituras_expansao) {
      ensaio.leituras_expansao.sort((a, b) => a.ordem - b.ordem)
    }
    if (ensaio.leituras_penetracao) {
      ensaio.leituras_penetracao.sort((a, b) => a.ordem - b.ordem)
    }

    // Agrupar leituras por ponto de compactação
    const leituras_expansao_por_ponto = {}
    const leituras_penetracao_por_ponto = {}

    ensaio.leituras_expansao?.forEach(leitura => {
      if (!leituras_expansao_por_ponto[leitura.compactacao_ponto_id]) {
        leituras_expansao_por_ponto[leitura.compactacao_ponto_id] = []
      }
      leituras_expansao_por_ponto[leitura.compactacao_ponto_id].push(leitura)
    })

    ensaio.leituras_penetracao?.forEach(leitura => {
      if (!leituras_penetracao_por_ponto[leitura.compactacao_ponto_id]) {
        leituras_penetracao_por_ponto[leitura.compactacao_ponto_id] = []
      }
      leituras_penetracao_por_ponto[leitura.compactacao_ponto_id].push(leitura)
    })

    // Organizar os dados no formato esperado pelo formulário
    form.value = {
      ...ensaio,
      ambiente_id: ensaio.ambiente_id,
      data_ensaio: ensaio.data_ensaio,
      hora_ensaio: ensaio.hora_ensaio,
      nome_amostra: ensaio.compactacao.nome_amostra,
      ensaio_selecionado: ensaio.compactacao_id,
      numero_golpes: ensaio.numero_golpes,
      altura_cilindro: ensaio.altura_cilindro,
      constante_prensa: ensaio.constante_prensa,
      observacoes: ensaio.observacoes,
      cilindros_disponiveis: ensaio.compactacao.compactacao_pontos
        .sort((a, b) => b.densidade_solo_seco - a.densidade_solo_seco)
        .slice(0, 3)
        .map(ponto => ({
          id: ponto.id,
          cilindro_id: ponto.cilindro_id,
          ponto: ponto.ponto,
          densidade_solo_seco: Number(ponto.densidade_solo_seco),
          teor_umidade: Number(ponto.umidade_media),
          volume_molde: ponto.volume_molde
        })),
      leituras_expansao: Object.values(leituras_expansao_por_ponto),
      leituras_penetracao: Object.values(leituras_penetracao_por_ponto)
    }

    // Log após organizar os dados no form
    console.log('Dados organizados no form:', {
      compactacao_id: form.value.compactacao_id,
      ensaio_selecionado: form.value.ensaio_selecionado,
      cilindros_disponiveis: form.value.cilindros_disponiveis
    })
  } catch (error) {
    console.error('Erro ao carregar ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaio'
    })
  }
}

const calcularResultados = () => {
  // Cálculo do teor de umidade
  const teor_umidade = ((form.value.massa_amostra_umida - form.value.massa_amostra_seca) / form.value.massa_amostra_seca) * 100

  // Cálculo da massa específica aparente úmida
  const massa_especifica_aparente_umida = form.value.massa_solo_umido / form.value.volume_solo_compactado

  // Cálculo da massa específica aparente seca
  const massa_especifica_aparente_seca = massa_especifica_aparente_umida / (1 + (teor_umidade / 100))

  // Cálculo da expansão
  const leituraInicial = form.value.leituras_expansao[0]?.leitura_extensometro || 0
  const leituraFinal = form.value.leituras_expansao[form.value.leituras_expansao.length - 1]?.leitura_extensometro || 0
  const expansao_percentual = ((leituraFinal - leituraInicial) / form.value.altura_inicial_corpo_prova) * 100

  // Cálculo do ISC (considerando a maior relação entre pressão aplicada e pressão padrão)
  // Pressões padrão: 70 kgf/cm² para 2,54mm e 105 kgf/cm² para 5,08mm
  const pressoes = form.value.leituras_penetracao.map(leitura => ({
    penetracao: leitura.penetracao_mm,
    pressao: leitura.leitura_extensometro * 0.7 // Fator de calibração do anel (exemplo)
  }))

  let isc_percentual = 0
  pressoes.forEach(p => {
    if (Math.abs(p.penetracao - 2.54) < 0.1) {
      const isc_254 = (p.pressao / 70) * 100
      isc_percentual = Math.max(isc_percentual, isc_254)
    }
    if (Math.abs(p.penetracao - 5.08) < 0.1) {
      const isc_508 = (p.pressao / 105) * 100
      isc_percentual = Math.max(isc_percentual, isc_508)
    }
  })

  // Valores estimados para exemplo
  const massa_especifica_aparente_seca_maxima = massa_especifica_aparente_seca
  const umidade_otima = teor_umidade

  return {
    teor_umidade,
    massa_especifica_aparente_umida,
    massa_especifica_aparente_seca,
    expansao_percentual,
    isc_percentual,
    massa_especifica_aparente_seca_maxima,
    umidade_otima
  }
}

const salvarEnsaio = async () => {
  try {
    salvando.value = true

    // Inserir entrada do ensaio
    const { data: ensaio, error: ensaioError } = await supabase
      .from('cbr_entradas')
      .insert({
        ambiente_id: route.query.ambiente,
        compactacao_id: form.value.ensaio_selecionado,
        data_ensaio: form.value.data_ensaio,
        hora_ensaio: form.value.hora_ensaio,
        nome_amostra: form.value.nome_amostra,
        numero_golpes: form.value.numero_golpes,
        altura_cilindro: form.value.altura_cilindro,
        constante_prensa: form.value.constante_prensa,
        observacoes: form.value.observacoes
      })
      .select()
      .single()

    if (ensaioError) throw ensaioError

    // Inserir leituras de expansão
    const leiturasExpansaoParaInserir = form.value.cilindros_disponiveis.flatMap((cilindro, cilindroIndex) =>
      form.value.leituras_expansao[cilindroIndex].map((leitura, ordem) => ({
        cbr_entrada_id: ensaio.id,
        compactacao_ponto_id: cilindro.id,
        data: leitura.data,
        hora: leitura.hora,
        leitura_extensometro: leitura.leitura_extensometro,
        ordem: ordem + 1
      }))
    )

    const { error: expansaoError } = await supabase
      .from('cbr_leituras_expansao')
      .insert(leiturasExpansaoParaInserir)

    if (expansaoError) throw expansaoError

    // Inserir leituras de penetração
    const leiturasEPenetracaoParaInserir = form.value.cilindros_disponiveis.flatMap((cilindro, cilindroIndex) =>
      form.value.leituras_penetracao[cilindroIndex].map((leitura, ordem) => ({
        cbr_entrada_id: ensaio.id,
        compactacao_ponto_id: cilindro.id,
        tempo_penetracao: leitura.tempo_penetracao,
        penetracao_mm: leitura.penetracao_mm,
        leitura_extensometro: leitura.leitura_extensometro,
        pressao_calculada: leitura.pressao_calculada,
        pressao_padrao: leitura.pressao_padrao,
        isc: leitura.isc,
        isc_referencia: leitura.isc_referencia || false,
        ordem: ordem + 1
      }))
    )

    const { error: penetracaoError } = await supabase
      .from('cbr_leituras_penetracao')
      .insert(leiturasEPenetracaoParaInserir)

    if (penetracaoError) throw penetracaoError

    // Inserir resultados
    const resultadosParaInserir = form.value.cilindros_disponiveis.map(cilindro => {
      const cilindroIndex = form.value.cilindros_disponiveis.findIndex(c => c.id === cilindro.id)
      return {
        cbr_entrada_id: ensaio.id,
        compactacao_ponto_id: cilindro.id,
        diferenca_expansao: calcularDiferencaExpansao(cilindroIndex),
        expansao_percentual: calcularExpansao(cilindro.cilindro_id),
        isc_2_54: form.value.leituras_penetracao[cilindroIndex].find(l => l.penetracao_mm === 2.54)?.isc || null,
        isc_5_08: form.value.leituras_penetracao[cilindroIndex].find(l => l.penetracao_mm === 5.08)?.isc || null,
        isc_escolhido: Math.max(
          form.value.leituras_penetracao[cilindroIndex].find(l => l.penetracao_mm === 2.54)?.isc || 0,
          form.value.leituras_penetracao[cilindroIndex].find(l => l.penetracao_mm === 5.08)?.isc || 0
        ),
        cilindro_num: cilindro.cilindro_id.toString(),
        massa_especifica_aparente_seca: cilindro.densidade_solo_seco,
        teor_umidade: cilindro.teor_umidade
      }
    })

    const { error: resultadosError } = await supabase
      .from('cbr_resultados')
      .insert(resultadosParaInserir)

    if (resultadosError) throw resultadosError

    $q.notify({
      type: 'positive',
      message: 'Ensaio salvo com sucesso!'
    })

    router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/lista?ambiente=${route.query.ambiente}`)
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

const loadEnsaiosCompactacao = async () => {
  try {
    console.log('Iniciando loadEnsaiosCompactacao')
    console.log('Modo visualização:', isVisualizacao.value)
    console.log('ID do ensaio de compactação no form:', form.value.compactacao_id)
    console.log('Ensaio selecionado no form:', form.value.ensaio_selecionado)

    // Buscar todos os ensaios de compactação
    const { data: ensaios, error: ensaiosError } = await supabase
      .from('compactacao_entradas')
      .select(`
        id,
        data_ensaio,
        hora_ensaio,
        nome_amostra,
        golpes_por_camada,
        compactacao_pontos!inner (
          id,
          ponto,
          cilindro_id,
          densidade_solo_umido,
          densidade_solo_seco,
          volume_molde,
          umidade_media
        ),
        compactacao_resultados_finais (
          umidade_otima,
          massa_especifica_aparente_seca_maxima
        )
      `)
      .eq('ambiente_id', route.query.ambiente)
      .order('data_ensaio', { ascending: false })

    if (ensaiosError) throw ensaiosError
    
    console.log('Ensaios de compactação carregados:', ensaios)

    let ensaiosDisponiveis = []

    if (isVisualizacao.value) {
      console.log('Modo visualização: usando todos os ensaios')
      // Em modo de visualização, usar todos os ensaios
      ensaiosDisponiveis = ensaios
    } else {
      console.log('Modo criação: filtrando ensaios não utilizados')
      // Se não estiver em modo de visualização, filtrar os ensaios já utilizados
      const { data: ensaiosCbrExistentes, error: errorCbr } = await supabase
        .from('cbr_entradas')
        .select('compactacao_id')
        .eq('ambiente_id', route.query.ambiente)

      if (errorCbr) throw errorCbr

      const ensaiosUtilizados = new Set(ensaiosCbrExistentes?.map(e => e.compactacao_id) || [])
      console.log('Ensaios já utilizados:', Array.from(ensaiosUtilizados))
      
      ensaiosDisponiveis = ensaios.filter(ensaio => !ensaiosUtilizados.has(ensaio.id))

      // Restaurando o alerta quando não houver ensaios disponíveis
      if (ensaiosDisponiveis.length === 0) {
        $q.notify({
          type: 'warning',
          message: 'Não há ensaios de compactação disponíveis. Todos já foram utilizados em ensaios CBR.',
          timeout: 5000,
          position: 'bottom'
        })
      }
    }

    console.log('Ensaios disponíveis antes da formatação:', ensaiosDisponiveis)

    // Formatar os ensaios para exibição
    ensaiosCompactacao.value = ensaiosDisponiveis.map(ensaio => ({
      label: `${ensaio.nome_amostra} - ${formatarData(ensaio.data_ensaio)}`,
      value: ensaio.id,
      data_ensaio: ensaio.data_ensaio,
      hora_ensaio: ensaio.hora_ensaio,
      nome_amostra: ensaio.nome_amostra,
      golpes_por_camada: ensaio.golpes_por_camada,
      pontos: [...ensaio.compactacao_pontos]
        .sort((a, b) => b.densidade_solo_seco - a.densidade_solo_seco)
        .map(ponto => ({
          ...ponto,
          densidade_solo_seco: Number(ponto.densidade_solo_seco),
          teor_umidade: Number(ponto.umidade_media),
          umidade_media: Number(ponto.umidade_media)
        })),
      resultados: ensaio.compactacao_resultados_finais?.[0] || null
    }))

    console.log('Ensaios formatados para exibição:', ensaiosCompactacao.value)
  } catch (error) {
    console.error('Erro ao carregar ensaios de compactação:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar ensaios de compactação'
    })
  }
}

// Quando um ensaio de compactação é selecionado
const onCompactacaoChange = (ensaioId) => {
  console.log('Ensaio selecionado ID:', ensaioId)
  
  if (!ensaioId) {
    form.value.cilindros_disponiveis = []
    return
  }

  // Encontrar o ensaio pelo ID
  const ensaioSelecionado = ensaiosCompactacao.value.find(e => e.value === ensaioId)
  if (!ensaioSelecionado) {
    console.error('Ensaio não encontrado:', ensaioId)
    console.log('Ensaios disponíveis:', ensaiosCompactacao.value.map(e => e.value))
    return
  }

  // Usar a data exata do ensaio de compactação
  const dataCompactacao = new Date(ensaioSelecionado.data_ensaio)
  const dataCbr = new Date(dataCompactacao)
  dataCbr.setDate(dataCompactacao.getDate() + 4)

  // Definir hora do ensaio CBR usando a hora do ensaio de compactação
  const [horaCompactacao, minutoCompactacao] = ensaioSelecionado.hora_ensaio.split(':')
  const horaCbr = new Date()
  horaCbr.setHours(Number(horaCompactacao), Number(minutoCompactacao), 0)
  form.value.hora_ensaio = horaCbr.toTimeString().slice(0, 5)

  // Preencher dados automáticos
  form.value.data_ensaio = dataCbr.toISOString().split('T')[0]
  form.value.nome_amostra = ensaioSelecionado.nome_amostra
  form.value.numero_golpes = ensaioSelecionado.golpes_por_camada
  form.value.compactacao_id = ensaioId

  // Pegar os 3 pontos com maior densidade
  form.value.cilindros_disponiveis = ensaioSelecionado.pontos.slice(0, 3).map(ponto => ({
    id: ponto.id,
    cilindro_id: ponto.cilindro_id,
    ponto: ponto.ponto,
    densidade_solo_seco: ponto.densidade_solo_seco,
    teor_umidade: ponto.teor_umidade,
    volume_molde: ponto.volume_molde
  }))

  // Inicializar arrays de leituras para cada cilindro
  form.value.leituras_expansao = []
  form.value.leituras_penetracao = []

  // Função auxiliar para gerar variação aleatória de minutos
  const gerarVariacaoMinutos = () => {
    return Math.floor(Math.random() * 101) - 50 // Gera número entre -50 e +50
  }

  // Gerar horários aleatórios uma única vez
  const horariosLeituras = []
  for (let i = 0; i < 5; i++) {
    const dataLeitura = new Date(dataCompactacao) // Usar a data de compactação como base
    const horaLeitura = new Date(horaCbr)
    
    if (i === 0) {
      // Primeira leitura: na data do ensaio de compactação, 2 horas após o início
      horaLeitura.setHours(horaLeitura.getHours() + 2)
    } else {
      // Demais leituras: incrementar 24 horas na data e adicionar variação aleatória
      dataLeitura.setDate(dataCompactacao.getDate() + i) // Incrementar i dias a partir da data de compactação
      horaLeitura.setHours(horaLeitura.getHours() + 2)
      // Adicionar variação aleatória de ±50 minutos
      horaLeitura.setMinutes(horaLeitura.getMinutes() + gerarVariacaoMinutos())
    }
    
    horariosLeituras.push({
      data: dataLeitura.toISOString().split('T')[0],
      hora: horaLeitura.toTimeString().slice(0, 5)
    })
  }

  // Adicionar leituras iniciais para cada cilindro usando os mesmos horários
  form.value.cilindros_disponiveis.forEach(cilindro => {
    const leituras_expansao_cilindro = horariosLeituras.map(horario => ({
      data: horario.data,
      hora: horario.hora,
      leitura_extensometro: null,
      cilindro_id: cilindro.cilindro_id
    }))
    
    form.value.leituras_expansao.push(leituras_expansao_cilindro)

    // Adicionar 8 leituras de penetração padrão
    const leituras_penetracao_cilindro = []
    const temposPenetracao = [0.50, 1.00, 1.50, 2.00, 3.00, 4.00, 5.00, 6.00]
    const penetracoesPadrao = [
      { penetracao: 0.63, pressao_padrao: 17.5, tempo: temposPenetracao[0] },
      { penetracao: 1.27, pressao_padrao: 35.0, tempo: temposPenetracao[1] },
      { penetracao: 1.90, pressao_padrao: 52.5, tempo: temposPenetracao[2] },
      { penetracao: 2.54, pressao_padrao: 70.0, tempo: temposPenetracao[3] }, // Ponto de referência 1 (100% CBR)
      { penetracao: 3.81, pressao_padrao: 87.5, tempo: temposPenetracao[4] },
      { penetracao: 5.08, pressao_padrao: 105.0, tempo: temposPenetracao[5] }, // Ponto de referência 2 (100% CBR)
      { penetracao: 6.35, pressao_padrao: 102.5, tempo: temposPenetracao[6] },
      { penetracao: 7.62, pressao_padrao: 105.0, tempo: temposPenetracao[7] }
    ]

    penetracoesPadrao.forEach(({ penetracao, pressao_padrao, tempo }) => {
      leituras_penetracao_cilindro.push({
        tempo_penetracao: tempo,
        penetracao_mm: penetracao,
        leitura_extensometro: null,
        pressao_padrao,
        cilindro_id: cilindro.cilindro_id
      })
    })
    form.value.leituras_penetracao.push(leituras_penetracao_cilindro)
  })

  console.log('Cilindros disponíveis:', form.value.cilindros_disponiveis)
}

// Função para calcular a expansão de um cilindro
const calcularExpansao = (cilindroId) => {
  const cilindroIndex = form.value.cilindros_disponiveis.findIndex(c => c.cilindro_id === cilindroId)
  if (cilindroIndex === -1) return 0

  const leituras = form.value.leituras_expansao[cilindroIndex]
  if (!leituras || leituras.length < 2) return 0

  const leituraInicial = leituras[0].leitura_extensometro || 0
  const leituraFinal = leituras[leituras.length - 1].leitura_extensometro || 0
  const altura = form.value.altura_cilindro * 10 // Converter de cm para mm

  return ((leituraFinal - leituraInicial) / altura) * 100
}

// Função para calcular o índice de suporte de um cilindro
const calcularIndiceSuporte = (cilindroId) => {
  const cilindroIndex = form.value.cilindros_disponiveis.findIndex(c => c.cilindro_id === cilindroId)
  if (cilindroIndex === -1) return 0

  const leituras = form.value.leituras_penetracao[cilindroIndex]
  if (!leituras || !leituras.length) return 0

  let isc = 0
  leituras.forEach(leitura => {
    if (leitura.penetracao_mm === 2.54 || leitura.penetracao_mm === 5.08) {
      const pressaoCalculada = leitura.leitura_extensometro * 0.7 // Fator de calibração do anel
      const isc_ponto = (pressaoCalculada / leitura.pressao_padrao) * 100
      isc = Math.max(isc, isc_ponto)
    }
  })

  return isc
}

const calcularDiferencaExpansao = (cilindroIndex) => {
  const leituras = form.value.leituras_expansao[cilindroIndex]
  if (!leituras || leituras.length < 2) return 0
  
  const leituraInicial = leituras[0].leitura_extensometro || 0
  const leituraFinal = leituras[leituras.length - 1].leitura_extensometro || 0
  return leituraFinal - leituraInicial
}

const calcularPressaoEIsc = (cilindroIndex, rowIndex) => {
  const leitura = form.value.leituras_penetracao[cilindroIndex][rowIndex]
  if (!leitura.leitura_extensometro) return

  // Usar a constante da prensa do form
  const constantePrensaAtual = form.value.constante_prensa

  // Calcular pressão
  leitura.pressao_calculada = Number((leitura.leitura_extensometro * constantePrensaAtual).toFixed(3))

  // Calcular ISC
  if (leitura.penetracao_mm === 2.54 || leitura.penetracao_mm === 5.08) {
    leitura.isc = Number(((leitura.pressao_calculada / leitura.pressao_padrao) * 100).toFixed(2))
    leitura.isc_referencia = true
  }
}

const formatarNumero = (valor, decimais = 2) => {
  if (valor === null || valor === undefined) return '-'
  return valor.toLocaleString('pt-BR', {
    minimumFractionDigits: decimais,
    maximumFractionDigits: decimais
  })
}

onMounted(async () => {
  const ambienteId = route.query.ambiente
  if (!ambienteId) {
    router.push('/ensaios/terraplenagem/compactacao-aterro')
    return
  }
  
  console.log('onMounted - Iniciando carregamento')
  console.log('Ambiente ID:', ambienteId)
  console.log('Modo visualização:', isVisualizacao.value)
  console.log('Route params:', route.params)
  
  await loadAmbiente(ambienteId)
  
  // Carregar ensaios de compactação primeiro
  await loadEnsaiosCompactacao()
  
  if (isVisualizacao.value) {
    console.log('Carregando ensaio:', route.params.id)
    await loadEnsaio(route.params.id)
    
    // Recarregar ensaios de compactação após carregar o ensaio
    // para garantir que o ensaio atual esteja na lista
    await loadEnsaiosCompactacao()
  }
})
</script> 