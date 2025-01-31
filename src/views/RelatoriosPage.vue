<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <div>
            <h5 class="q-my-none">Relatórios</h5>
            <div class="text-subtitle2 text-grey-7">
              {{ selectedObra?.nome }}
              <template v-if="medicaoAtual">
                - Medição Nº {{ medicaoAtual.numero }}
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabela de Resumo dos Ensaios -->
    <q-card class="q-mb-md">
      <q-card-section>
        <div class="row items-center q-mb-md">
          <div class="col">
            <div class="text-h6">Resumo dos Ensaios</div>
          </div>
          <div class="col-auto">
            <q-btn
              round
              color="primary"
              icon="description"
              :disable="!hasEnsaiosSelecionados"
              @click="gerarRelatorioGranulometria"
            >
              <q-tooltip>Gerar Relatório dos Ensaios Selecionados</q-tooltip>
            </q-btn>
          </div>
        </div>
        <q-table
          :rows="resumoEnsaios"
          :columns="columns"
          row-key="tipo"
          :loading="loading"
          flat
          bordered
          selection="multiple"
          v-model:selected="selectedRows"
        >
          <template v-slot:loading>
            <q-inner-loading showing color="primary" />
          </template>
        </q-table>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { supabase } from '@/lib/supabaseClient'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const { selectedObra } = useSelectedObra()
const medicaoAtual = ref(null)
const loading = ref(false)
const resumoEnsaios = ref([])
const selectedRows = ref([])

const columns = [
  {
    name: 'disciplina',
    label: 'Disciplina',
    field: 'disciplina',
    align: 'left',
  },
  {
    name: 'trecho',
    label: 'Trecho',
    field: 'trecho',
    align: 'left',
  },
  {
    name: 'tipo',
    label: 'Tipo de Ensaio',
    field: 'tipo',
    align: 'left',
  },
  {
    name: 'quantidade',
    label: 'Quantidade',
    field: 'quantidade',
    align: 'center',
  }
]

// Renomear a computed property para refletir que agora inclui ambos os tipos de ensaio
const hasEnsaiosSelecionados = computed(() => {
  return selectedRows.value.some(row => 
    (row.tipo === 'Granulometria' || row.tipo === 'Limites de Atterberg') && 
    row.quantidade > 0
  )
})

// Adicionar constantes no topo do script
const apiUrlGranulometria = 'https://api-htmlppdf.vercel.app/api/granulometria'
const apiUrlAtterberg = 'https://api-htmlppdf.vercel.app/api/atterberg'

// Adicionar as constantes das cápsulas no topo do script
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

// Função para calcular umidade
const calcularUmidade = (ponto, tipo) => {
  if (!ponto.peso_umido_capsula || !ponto.peso_seco_capsula || !ponto.capsula) return null
  
  const pesoCapsulas = tipo === 'LL' ? capsulasLL : capsulasLP
  const pesoCap = pesoCapsulas[ponto.capsula]
  
  const pesoUmido = ponto.peso_umido_capsula - pesoCap
  const pesoSeco = ponto.peso_seco_capsula - pesoCap
  
  if (pesoSeco <= 0) return null
  
  const umidade = ((pesoUmido - pesoSeco) / pesoSeco) * 100
  return Number(umidade.toFixed(1))
}

const gerarRelatorioGranulometria = async () => {
  try {
    // Verificar quais tipos de ensaios estão selecionados
    const granulometriaSelecionada = selectedRows.value.some(row => row.tipo === 'Granulometria' && row.quantidade > 0)
    const limitesSelecionados = selectedRows.value.some(row => row.tipo === 'Limites de Atterberg' && row.quantidade > 0)

    // Se nenhum ensaio estiver selecionado, retornar
    if (!granulometriaSelecionada && !limitesSelecionados) return

    loading.value = true
    
    // Array para armazenar as promises de busca
    const promises = []

    // Adicionar promise de granulometria se selecionada
    if (granulometriaSelecionada) {
      promises.push(
        supabase
          .from('granulometria_entradas')
          .select(`
            *,
            ambiente:ambiente_id (
              id,
              estaca_inicial,
              estaca_final,
              localizacao:localizacao_id (
                nome
              )
            ),
            resultado:granulometria_resultados!id(*)
          `)
          .eq('ambiente_id.obra_id', selectedObra.value.id)
          .gte('created_at', medicaoAtual.value.data_inicio)
          .lte('created_at', medicaoAtual.value.data_fim)
      )
    } else {
      promises.push(Promise.resolve({ data: [] }))
    }

    // Adicionar promise de limites se selecionados
    if (limitesSelecionados) {
      promises.push(
        supabase
          .from('limite_consistencia_entradas')
          .select(`
            *,
            ambiente:ambiente_id (
              id,
              estaca_inicial,
              estaca_final,
              localizacao:localizacao_id (
                nome
              )
            ),
            resultado:limite_consistencia_resultados!id(*),
            dados_especificos
          `)
          .eq('ambiente_id.obra_id', selectedObra.value.id)
          .gte('created_at', medicaoAtual.value.data_inicio)
          .lte('created_at', medicaoAtual.value.data_fim)
      )
    } else {
      promises.push(Promise.resolve({ data: [] }))
    }

    const [granulometriaResponse, limitesResponse] = await Promise.all(promises)

    if (granulometriaResponse.error) throw granulometriaResponse.error
    if (limitesResponse.error) throw limitesResponse.error

    // Formatar dados de granulometria se houver
    const dadosGranulometria = granulometriaSelecionada ? granulometriaResponse.data.map(ensaio => ({
      // Dados gerais
      rodovia: selectedObra.value.nome,
      trecho: ensaio.ambiente.localizacao.nome,
      sub_trecho: `SEGMENTO ${ensaio.ambiente.estaca_inicial} - ${ensaio.ambiente.estaca_final}`,
      material: ensaio.nome_amostra,
      data_ensaio: ensaio.data_ensaio,
      laboratorista: ensaio.usuario_cadastro,
      medicao: medicaoAtual.value ? `Medição Nº ${medicaoAtual.value.numero}` : '',

      // Dados da amostra
      amostra_total: {
        seca: ensaio.resultado[0].massa_total_seca,
        umida: ensaio.massa_total_umida,
        retido_peneira_10: ensaio.resultado[0].massa_fracao_2_0mm,
        passando_peneira_10: ensaio.resultado[0].massa_menor_10_seca
      },

      // Umidade higroscópica
      umidade_higroscopica: {
        capsula_1: {
          numero: ensaio.capsula_id_1,
          peso_capsula: ensaio.peso_capsula_1,
          peso_capsula_solo_umido: ensaio.peso_bruto_umido_1,
          peso_capsula_solo_seco: ensaio.peso_bruto_seco_1,
          peso_agua: ensaio.peso_agua_1,
          peso_solo_seco: ensaio.peso_solo_seco_1,
          umidade: ensaio.umidade_1
        },
        capsula_2: {
          numero: ensaio.capsula_id_2,
          peso_capsula: ensaio.peso_capsula_2,
          peso_capsula_solo_umido: ensaio.peso_bruto_umido_2,
          peso_capsula_solo_seco: ensaio.peso_bruto_seco_2,
          peso_agua: ensaio.peso_agua_2,
          peso_solo_seco: ensaio.peso_solo_seco_2,
          umidade: ensaio.umidade_2
        },
        umidade_media: ensaio.umidade_media,
        fator_correcao: ensaio.resultado[0].fator_correcao
      },

      // Peneiramento grosso
      peneiramento_grosso: {
        '3"': { peso: 0, porcentagem: 0 }, // Incluído para compatibilidade com o relatório
        '2"': {
          peso: ensaio.peneira_50mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_50mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_50mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_50mm
        },
        '1_1/2"': {
          peso: ensaio.peneira_38mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_38mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_38mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_38mm
        },
        '1"': {
          peso: ensaio.peneira_25mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_25mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_25mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_25mm
        },
        '3/4"': {
          peso: ensaio.peneira_19mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_19mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_19mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_19mm
        },
        '3/8"': {
          peso: ensaio.peneira_9_5mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_9_5mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_9_5mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_9_5mm
        },
        'N4': {
          peso: ensaio.peneira_4_8mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_4_8mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_4_8mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_4_8mm
        },
        'N10': {
          peso: ensaio.peneira_2_0mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_2_0mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_2_0mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_2_0mm
        }
      },

      // Peneiramento fino
      peneiramento_fino: {
        'N16': {
          peso: ensaio.peneira_1_2mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_1_2mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_1_2mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_1_2mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_1_2mm
        },
        'N30': {
          peso: ensaio.peneira_0_6mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_0_6mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_0_6mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_0_6mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_0_6mm
        },
        'N40': {
          peso: ensaio.peneira_0_42mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_0_42mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_0_42mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_0_42mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_0_42mm
        },
        'N50': {
          peso: ensaio.peneira_0_30mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_0_30mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_0_30mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_0_30mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_0_30mm
        },
        'N100': {
          peso: ensaio.peneira_0_15mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_0_15mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_0_15mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_0_15mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_0_15mm
        },
        'N200': {
          peso: ensaio.peneira_0_075mm,
          porcentagem: ensaio.resultado[0].percentagem_retida_0_075mm,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_0_075mm,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_0_075mm,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_0_075mm
        },
        'FUNDO': {
          peso: ensaio.resultado[0].massa_fracao_fundo,
          porcentagem: ensaio.resultado[0].percentagem_retida_fundo,
          porcentagem_amostra_menor: ensaio.resultado[0].percentagem_retida_amostra_menor_fundo,
          porcentagem_acumulada: ensaio.resultado[0].percentagem_acumulada_retida_fundo,
          porcentagem_passando: ensaio.resultado[0].percentagem_passando_fundo
        }
      },

      // Resumo
      resumo: {
        pedregulho: ensaio.resultado[0].percentagem_passando_4_8mm,
        areia_grossa: ensaio.resultado[0].percentagem_retida_2_0mm,
        areia_media: ensaio.resultado[0].percentagem_retida_0_42mm,
        areia_fina: ensaio.resultado[0].percentagem_retida_0_074mm,
        silte_argila: ensaio.resultado[0].percentagem_passando_0_075mm
      },

      observacoes: ensaio.observacoes
    })) : []

    // Formatar dados de limites de Atterberg se houver
    const dadosLimites = limitesSelecionados ? limitesResponse.data.map(ensaio => {
      // Parsear dados específicos do JSON se for string, ou usar direto se for objeto
      const dadosEspecificos = ensaio.dados_especificos ? 
        (typeof ensaio.dados_especificos === 'string' ? 
          JSON.parse(ensaio.dados_especificos) : 
          ensaio.dados_especificos
        ) : null

      // Adicionar umidade aos pontos de LL
      const pontosLL = dadosEspecificos?.pontos_ll?.map(ponto => ({
        golpes: ponto.golpes,
        capsula: ponto.capsula.toString(),
        peso_seco_capsula: ponto.peso_seco_capsula,
        peso_umido_capsula: ponto.peso_umido_capsula,
        umidade: calcularUmidade(ponto, 'LL')
      })) || []

      // Adicionar umidade aos pontos de LP
      const pontosLP = dadosEspecificos?.pontos_lp?.map(ponto => ({
        capsula: ponto.capsula.toString(),
        peso_seco_capsula: ponto.peso_seco_capsula,
        peso_umido_capsula: ponto.peso_umido_capsula,
        umidade: calcularUmidade(ponto, 'LP')
      })) || []

      return {
        // Dados gerais (mesmo formato da granulometria)
        rodovia: selectedObra.value.nome,
        trecho: ensaio.ambiente.localizacao.nome,
        sub_trecho: `SEGMENTO ${ensaio.ambiente.estaca_inicial} - ${ensaio.ambiente.estaca_final}`,
        material: ensaio.nome_amostra,
        data_ensaio: ensaio.data_ensaio,
        laboratorista: ensaio.usuario_cadastro,
        medicao: medicaoAtual.value ? `Medição Nº ${medicaoAtual.value.numero}` : '',

        // Dados do Limite de Liquidez
        limite_liquidez: {
          pontos: pontosLL
        },

        // Dados do Limite de Plasticidade
        limite_plasticidade: {
          pontos: pontosLP
        },

        // Resultados finais
        resultados: {
          limite_liquidez: ensaio.resultado[0].limite_liquidez,
          limite_plasticidade: ensaio.resultado[0].limite_plasticidade,
          indice_plasticidade: ensaio.resultado[0].indice_plasticidade
        },

        observacoes: ensaio.observacoes
      }
    }) : []

    // Remover o log dos dados de limites e adicionar chamada API
    if (limitesSelecionados) {
      fetch(apiUrlAtterberg, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(dadosLimites)
      })
      .then(response => {
        if (!response.ok) {
          return response.json().then(err => Promise.reject(err))
        }
        return response.blob()
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `limites-atterberg_${medicaoAtual.value.numero}.pdf`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        window.URL.revokeObjectURL(url)

        $q.notify({
          type: 'positive',
          message: 'Relatório de Limites de Atterberg gerado com sucesso!'
        })
      })
      .catch(error => {
        console.error('Erro ao gerar relatório de Limites:', error)
        $q.notify({
          type: 'negative',
          message: 'Erro ao gerar relatório de Limites: ' + (error.message || JSON.stringify(error))
        })
      })
    }

    // Fazer requisição para a API de granulometria se selecionada
    if (granulometriaSelecionada) {
      fetch(apiUrlGranulometria, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(dadosGranulometria)
      })
      .then(response => {
        if (!response.ok) {
          return response.json().then(err => Promise.reject(err))
        }
        return response.blob()
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `granulometria_${medicaoAtual.value.numero}.pdf`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        window.URL.revokeObjectURL(url)

        $q.notify({
          type: 'positive',
          message: 'Relatório de Granulometria gerado com sucesso!'
        })
      })
      .catch(error => {
        console.error('Erro ao gerar relatório de Granulometria:', error)
        $q.notify({
          type: 'negative',
          message: 'Erro ao gerar relatório de Granulometria: ' + (error.message || JSON.stringify(error))
        })
      })
    }
  } catch (error) {
    console.error('Erro ao gerar relatório:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao gerar relatório: ' + error.message
    })
  } finally {
    loading.value = false
  }
}

const buscarMedicaoAtual = async (obraId) => {
  if (!obraId) return

  try {
    const { data, error } = await supabase
      .from('medicoes_obra')
      .select('*')
      .eq('obra_id', obraId)
      .eq('status', 'aberto')
      .single()

    if (error) throw error
    medicaoAtual.value = data
    await buscarResumoEnsaios(obraId, data)
  } catch (error) {
    console.error('Erro ao buscar medição atual:', error)
    medicaoAtual.value = null
  }
}

const formatarTrecho = (ambiente) => {
  if (ambiente?.estaca_inicial && ambiente?.estaca_final) {
    return `${ambiente.estaca_inicial} até ${ambiente.estaca_final}`
  }
  return '-'
}

const buscarResumoEnsaios = async (obraId, medicao) => {
  if (!obraId || !medicao) return
  
  loading.value = true
  try {
    // Buscar contagem de cada tipo de ensaio junto com informações do ambiente
    const promises = [
      // Granulometria
      supabase
        .from('granulometria_resultados')
        .select(`
          id,
          id_entrada (
            ambiente_id (
              estaca_inicial,
              estaca_final
            )
          )
        `)
        .filter('id_entrada.ambiente_id.obra_id', 'eq', obraId)
        .gte('created_at', medicao.data_inicio)
        .lte('created_at', medicao.data_fim),

      // Limites de Consistência
      supabase
        .from('limite_consistencia_resultados')
        .select(`
          id,
          id_entrada (
            ambiente_id (
              estaca_inicial,
              estaca_final
            )
          )
        `)
        .filter('id_entrada.ambiente_id.obra_id', 'eq', obraId)
        .gte('created_at', medicao.data_inicio)
        .lte('created_at', medicao.data_fim),

      // Compactação
      supabase
        .from('compactacao_resultados')
        .select(`
          id,
          compactacao_id (
            ambiente_id (
              estaca_inicial,
              estaca_final
            )
          )
        `)
        .filter('compactacao_id.ambiente_id.obra_id', 'eq', obraId)
        .gte('created_at', medicao.data_inicio)
        .lte('created_at', medicao.data_fim),

      // CBR
      supabase
        .from('cbr_resultados')
        .select(`
          id,
          cbr_entrada_id (
            ambiente_id (
              estaca_inicial,
              estaca_final
            )
          )
        `)
        .filter('cbr_entrada_id.ambiente_id.obra_id', 'eq', obraId)
        .gte('created_at', medicao.data_inicio)
        .lte('created_at', medicao.data_fim),

      // Densidade In Situ
      supabase
        .from('densidade_insitu_furos')
        .select(`
          id,
          densidade_insitu_id (
            ambiente_id (
              estaca_inicial,
              estaca_final
            )
          )
        `)
        .filter('densidade_insitu_id.ambiente_id.obra_id', 'eq', obraId)
        .gte('created_at', medicao.data_inicio)
        .lte('created_at', medicao.data_fim),
    ]

    const [
      granulometria,
      limitesConsistencia,
      compactacao,
      cbr,
      densidadeInsitu
    ] = await Promise.all(promises)

    resumoEnsaios.value = [
      {
        tipo: 'Granulometria',
        quantidade: granulometria.data?.length || 0,
        disciplina: 'Terraplenagem',
        trecho: granulometria.data?.[0]?.id_entrada?.ambiente_id 
          ? formatarTrecho(granulometria.data[0].id_entrada.ambiente_id)
          : '-'
      },
      {
        tipo: 'Limites de Atterberg',
        quantidade: limitesConsistencia.data?.length || 0,
        disciplina: 'Terraplenagem',
        trecho: limitesConsistencia.data?.[0]?.id_entrada?.ambiente_id
          ? formatarTrecho(limitesConsistencia.data[0].id_entrada.ambiente_id)
          : '-'
      },
      {
        tipo: 'Compactação',
        quantidade: compactacao.data?.length || 0,
        disciplina: 'Terraplenagem',
        trecho: compactacao.data?.[0]?.compactacao_id?.ambiente_id
          ? formatarTrecho(compactacao.data[0].compactacao_id.ambiente_id)
          : '-'
      },
      {
        tipo: 'CBR e Expansão',
        quantidade: cbr.data?.length || 0,
        disciplina: 'Terraplenagem',
        trecho: cbr.data?.[0]?.cbr_entrada_id?.ambiente_id
          ? formatarTrecho(cbr.data[0].cbr_entrada_id.ambiente_id)
          : '-'
      },
      {
        tipo: 'Densidade "In Situ"',
        quantidade: densidadeInsitu.data?.length || 0,
        disciplina: 'Terraplenagem',
        trecho: densidadeInsitu.data?.[0]?.densidade_insitu_id?.ambiente_id
          ? formatarTrecho(densidadeInsitu.data[0].densidade_insitu_id.ambiente_id)
          : '-'
      }
    ]
  } catch (error) {
    console.error('Erro ao buscar resumo dos ensaios:', error)
    resumoEnsaios.value = []
  } finally {
    loading.value = false
  }
}

// Observar mudanças na obra selecionada
watch(() => selectedObra.value?.id, (newObraId) => {
  buscarMedicaoAtual(newObraId)
}, { immediate: true })
</script>

<style scoped>
</style> 