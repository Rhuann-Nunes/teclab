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
            @click="$router.push('/ensaios/terraplenagem/compactacao-aterro')"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">{{ ambiente?.nome || 'Ambiente' }}</h5>
            <div class="text-subtitle2 text-grey-7">{{ selectedObra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Card de Informações Gerais -->
    <q-card class="q-mb-md">
      <q-card-section>
        <div class="text-h6 q-mb-md">Informações Gerais</div>
        <div class="row q-col-gutter-md">
          <div class="col-12 col-sm-6">
            <div class="text-subtitle2">Localização</div>
            <div>{{ ambiente?.localizacao?.nome || '-' }}</div>
          </div>
          <div class="col-12 col-sm-6">
            <div class="text-subtitle2">Data Prevista</div>
            <div>{{ formatDate(ambiente?.data_prevista) }}</div>
          </div>
          <div class="col-12 col-sm-6">
            <div class="text-subtitle2">Espessura da Camada</div>
            <div>{{ ambiente?.espessura_camada || '-' }} m</div>
          </div>
          <div class="col-12 col-sm-6">
            <div class="text-subtitle2">Volume Previsto</div>
            <div>{{ ambiente?.volume_previsto || '-' }} m³</div>
          </div>
          <div v-if="ambiente?.estaca_inicial && ambiente?.estaca_final" class="col-12">
            <div class="text-subtitle2">Estacas</div>
            <div>{{ ambiente.estaca_inicial }} até {{ ambiente.estaca_final }}</div>
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- Cards de Ensaios -->
    <div class="row q-col-gutter-md">
      <!-- Granulometria -->
      <div class="col-12 col-sm-6">
        <q-card class="menu-card cursor-pointer" @click="router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/lista?ambiente=${route.query.ambiente}`)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6">
                  <q-icon name="science" color="primary" size="32px" class="q-mr-sm" />
                  Granulometria
                </div>
                <div class="text-subtitle2">DNER-ME 080/94</div>
                <div class="text-caption q-mt-sm">
                  <template v-if="!ensaiosInfo.error">
                    <q-linear-progress
                      :value="Math.min(ensaiosInfo.necessarios ? ensaiosInfo.realizados / ensaiosInfo.necessarios : 0, 1)"
                      :color="ensaiosInfo.realizados > ensaiosInfo.necessarios ? 'warning' : 'primary'"
                      class="q-mt-sm"
                    />
                    <div class="row justify-between q-mt-xs">
                      <span>{{ ensaiosInfo.realizados }} realizados</span>
                      <span>{{ ensaiosInfo.necessarios }} necessários</span>
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-grey-7 text-italic">
                      {{ ensaiosInfo.error }}
                    </div>
                  </template>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Limites de Consistência -->
      <div class="col-12 col-sm-6">
        <q-card class="menu-card cursor-pointer" @click="router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/lista?ambiente=${route.query.ambiente}`)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6">
                  <q-icon name="science" color="primary" size="32px" class="q-mr-sm" />
                  Limites de Atterberg
                </div>
                <div class="text-subtitle2">DNIT - ME-122/94 e DNIT - ME-082/94</div>
                <div class="text-caption q-mt-sm">
                  <template v-if="!limitesConsistenciaInfo.error">
                    <q-linear-progress
                      :value="Math.min(limitesConsistenciaInfo.necessarios ? limitesConsistenciaInfo.realizados / limitesConsistenciaInfo.necessarios : 0, 1)"
                      :color="limitesConsistenciaInfo.realizados > limitesConsistenciaInfo.necessarios ? 'warning' : 'primary'"
                      class="q-mt-sm"
                    />
                    <div class="row justify-between q-mt-xs">
                      <span>{{ limitesConsistenciaInfo.realizados }} realizados</span>
                      <span>{{ limitesConsistenciaInfo.necessarios }} necessários</span>
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-grey-7 text-italic">
                      {{ limitesConsistenciaInfo.error }}
                    </div>
                  </template>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Compactação -->
      <div class="col-12 col-sm-6">
        <q-card class="menu-card cursor-pointer" @click="router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/lista?ambiente=${route.query.ambiente}`)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6">
                  <q-icon name="science" color="primary" size="32px" class="q-mr-sm" />
                  Compactação
                </div>
                <div class="text-subtitle2">DNIT 164/2013-ME</div>
                <div class="text-caption q-mt-sm">
                  <template v-if="!compactacaoInfo.error">
                    <q-linear-progress
                      :value="Math.min(compactacaoInfo.necessarios ? compactacaoInfo.realizados / compactacaoInfo.necessarios : 0, 1)"
                      :color="compactacaoInfo.realizados > compactacaoInfo.necessarios ? 'warning' : 'primary'"
                      class="q-mt-sm"
                    />
                    <div class="row justify-between q-mt-xs">
                      <span>{{ compactacaoInfo.realizados }} realizados</span>
                      <span>{{ compactacaoInfo.necessarios }} necessários</span>
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-grey-7 text-italic">
                      {{ compactacaoInfo.error }}
                    </div>
                  </template>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- CBR e Expansão -->
      <div class="col-12 col-sm-6">
        <q-card class="menu-card cursor-pointer" @click="router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/lista?ambiente=${route.query.ambiente}`)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6">
                  <q-icon name="science" color="primary" size="32px" class="q-mr-sm" />
                  CBR e Expansão
                </div>
                <div class="text-subtitle2">DNIT 172/2016-ME</div>
                <div class="text-caption q-mt-sm">
                  <template v-if="!cbrInfo.error">
                    <q-linear-progress
                      :value="Math.min(cbrInfo.necessarios ? cbrInfo.realizados / cbrInfo.necessarios : 0, 1)"
                      :color="cbrInfo.realizados > cbrInfo.necessarios ? 'warning' : 'primary'"
                      class="q-mt-sm"
                    />
                    <div class="row justify-between q-mt-xs">
                      <span>{{ cbrInfo.realizados }} realizados</span>
                      <span>{{ cbrInfo.necessarios }} necessários</span>
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-grey-7 text-italic">
                      {{ cbrInfo.error }}
                    </div>
                  </template>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Densidade "In Situ" -->
      <div class="col-12 col-sm-6">
        <q-card class="menu-card cursor-pointer" @click="router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/lista?ambiente=${route.query.ambiente}`)">
          <q-card-section>
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6">
                  <q-icon name="science" color="primary" size="32px" class="q-mr-sm" />
                  Densidade "In Situ"
                </div>
                <div class="text-subtitle2">DNIT 092/94-ME</div>
                <div class="text-caption q-mt-sm">
                  <template v-if="!densidadeInsituInfo.error">
                    <q-linear-progress
                      :value="Math.min(densidadeInsituInfo.necessarios ? densidadeInsituInfo.realizados / densidadeInsituInfo.necessarios : 0, 1)"
                      :color="densidadeInsituInfo.realizados > densidadeInsituInfo.necessarios ? 'warning' : 'primary'"
                      class="q-mt-sm"
                    />
                    <div class="row justify-between q-mt-xs">
                      <span>{{ densidadeInsituInfo.realizados }} realizados</span>
                      <span>{{ densidadeInsituInfo.necessarios }} necessários</span>
                    </div>
                  </template>
                  <template v-else>
                    <div class="text-grey-7 text-italic">
                      {{ densidadeInsituInfo.error }}
                    </div>
                  </template>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { supabase } from '@/lib/supabase'

const router = useRouter()
const route = useRoute()
const { selectedObra } = useSelectedObra()
const ambiente = ref(null)
const ensaiosInfo = ref({
  realizados: 0,
  necessarios: 0,
  error: null
})

const limitesConsistenciaInfo = ref({
  realizados: 0,
  necessarios: 0,
  error: null
})

const cbrInfo = ref({
  realizados: 0,
  necessarios: 0,
  error: null
})

const compactacaoInfo = ref({
  realizados: 0,
  necessarios: 0,
  error: null
})

const densidadeInsituInfo = ref({
  realizados: 0,
  necessarios: 0,
  error: null
})

const formatDate = (dateString) => {
  if (!dateString) return '-'
  const [year, month, day] = dateString.split('-')
  return `${day}/${month}/${year}`
}

const loadEnsaiosInfo = async (ambienteId, servicoId, volumePrevisto) => {
  try {
    // Buscar regras de ensaio
    const { data: regras, error: regraError } = await supabase
      .from('regras_ensaios_obra')
      .select('quantidade_regra, tabela_ensaio')
      .eq('servico_obra_id', servicoId)
      .in('tabela_ensaio', ['granulometria_resultados', 'limite_consistencia_resultados', 'cbr_resultados', 'compactacao_resultados', 'densidade_insitu_furos'])

    if (regraError) throw regraError

    // Processar regras e contar ensaios para cada tipo
    for (const regra of regras) {
      if (regra.tabela_ensaio === 'granulometria_resultados') {
        await processarRegra(regra, 'granulometria_entradas', ensaiosInfo, ambienteId, volumePrevisto)
      } else if (regra.tabela_ensaio === 'limite_consistencia_resultados') {
        await processarRegra(regra, 'limite_consistencia_entradas', limitesConsistenciaInfo, ambienteId, volumePrevisto)
      } else if (regra.tabela_ensaio === 'cbr_resultados') {
        await processarRegra(regra, 'cbr_entradas', cbrInfo, ambienteId, volumePrevisto)
      } else if (regra.tabela_ensaio === 'compactacao_resultados') {
        await processarRegra(regra, 'compactacao_entradas', compactacaoInfo, ambienteId, volumePrevisto)
      } else if (regra.tabela_ensaio === 'densidade_insitu_furos') {
        await processarRegra(regra, 'densidade_insitu_entradas', densidadeInsituInfo, ambienteId, volumePrevisto)
      }
    }
  } catch (error) {
    console.error('Erro ao carregar informações dos ensaios:', error)
    const errorInfo = {
      realizados: 0,
      necessarios: 0,
      error: 'Erro ao carregar informações'
    }
    ensaiosInfo.value = errorInfo
    limitesConsistenciaInfo.value = errorInfo
    cbrInfo.value = errorInfo
    compactacaoInfo.value = errorInfo
    densidadeInsituInfo.value = errorInfo
  }
}

const processarRegra = async (regra, tabelaEntradas, infoRef, ambienteId, volumePrevisto) => {
  if (!regra) {
    infoRef.value = {
      realizados: 0,
      necessarios: 0,
      error: 'Nenhuma regra de ensaio cadastrada'
    }
    return
  }

  // Calcular quantidade necessária
  infoRef.value.necessarios = Math.ceil(volumePrevisto / regra.quantidade_regra)

  try {
    // Para densidade in-situ, contar furos ao invés de entradas
    if (tabelaEntradas === 'densidade_insitu_entradas') {
      const { data: entradas } = await supabase
        .from('densidade_insitu_entradas')
        .select('id')
        .eq('ambiente_id', ambienteId)

      if (entradas?.length) {
        const { count, error: countError } = await supabase
          .from('densidade_insitu_furos')
          .select('id', { count: 'exact', head: true })
          .in('densidade_insitu_id', entradas.map(e => e.id))

        if (countError) throw countError

        infoRef.value = {
          realizados: count || 0,
          necessarios: infoRef.value.necessarios,
          error: null
        }
        return
      }

      infoRef.value = {
        realizados: 0,
        necessarios: infoRef.value.necessarios,
        error: null
      }
      return
    }

    // Para outros ensaios, manter a contagem por entrada
    const { count, error: countError } = await supabase
      .from(tabelaEntradas)
      .select('id', { count: 'exact', head: true })
      .eq('ambiente_id', ambienteId)

    if (countError) throw countError

    infoRef.value = {
      realizados: count || 0,
      necessarios: infoRef.value.necessarios,
      error: null
    }
  } catch (error) {
    console.error('Erro ao processar regra:', error)
    infoRef.value = {
      realizados: 0,
      necessarios: 0,
      error: 'Erro ao carregar informações'
    }
  }
}

const loadAmbiente = async (ambienteId) => {
  try {
    const { data, error } = await supabase
      .from('ambientes_compactacao_aterro')
      .select(`
        *,
        localizacao:localizacao_id (
          nome
        ),
        servico:servico_id (
          id,
          nome
        )
      `)
      .eq('id', ambienteId)
      .single()

    if (error) throw error
    ambiente.value = data

    // Carregar informações dos ensaios
    await loadEnsaiosInfo(data.id, data.servico.id, data.volume_previsto)
  } catch (error) {
    console.error('Erro ao carregar ambiente:', error)
  }
}

onMounted(async () => {
  const ambienteId = route.query.ambiente
  if (!ambienteId) {
    router.push('/ensaios/terraplenagem/compactacao-aterro')
    return
  }
  
  await loadAmbiente(ambienteId)
})
</script>

<style scoped>
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

.menu-card {
  transition: all 0.2s ease;
}

.menu-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 25px 0 rgba(0, 0, 0, 0.1);
}
</style> 