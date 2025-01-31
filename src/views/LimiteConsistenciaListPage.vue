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
            :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod?ambiente=' + route.query.ambiente"
            class="q-mr-sm"
          />
          <div>
            <h5 class="q-my-none">Ensaios de Limites de Atterberg</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
      <div>
        <q-btn
          color="primary"
          icon="add"
          round
          :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/novo?ambiente=' + route.query.ambiente"
        >
          <q-tooltip>Novo Ensaio</q-tooltip>
        </q-btn>
      </div>
    </div>

    <!-- Lista de Ensaios -->
    <q-card>
      <q-card-section>
        <q-list separator dense>
          <q-item
            v-for="(ensaio, index) in ensaios"
            :key="ensaio.id"
            class="q-py-md"
            style="min-height: 60px"
          >
            <q-item-section side>
              <div class="text-weight-medium">{{ index + 1 }}</div>
            </q-item-section>
            <q-item-section>
              <q-item-label>
                <div class="row items-center">
                  <div class="col">
                    <div class="text-weight-medium">{{ ensaio.nome_amostra }}</div>
                    <div class="text-caption text-grey-7">
                      Data: {{ formatDate(ensaio.data_ensaio) }} | 
                      LL: {{ formatNumber(ensaio.limite_consistencia_resultados?.[0]?.limite_liquidez) }}% |
                      LP: {{ formatNumber(ensaio.limite_consistencia_resultados?.[0]?.limite_plasticidade) }}% |
                      IP: {{ formatNumber(ensaio.limite_consistencia_resultados?.[0]?.indice_plasticidade) }}%
                    </div>
                  </div>
                  <div class="col-auto">
                    <q-btn
                      flat
                      round
                      color="primary"
                      icon="visibility"
                      @click="visualizarEnsaio(ensaio.id)"
                    >
                      <q-tooltip>Visualizar</q-tooltip>
                    </q-btn>
                    <q-btn
                      flat
                      round
                      color="negative"
                      icon="delete"
                      @click="confirmarExclusao(ensaio)"
                    >
                      <q-tooltip>Excluir</q-tooltip>
                    </q-btn>
                  </div>
                </div>
              </q-item-label>
            </q-item-section>
          </q-item>

          <q-item v-if="!ensaios.length">
            <q-item-section>
              <q-item-label class="text-center text-grey-7">
                Nenhum ensaio cadastrado
              </q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog de Confirmação de Exclusão -->
    <q-dialog v-model="confirmDialog" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="warning" color="warning" text-color="white" />
          <span class="q-ml-sm">Deseja realmente excluir este ensaio?</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Excluir" color="negative" @click="excluirEnsaio" :loading="excluindo" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabaseClient'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const ambiente = ref(null)
const ensaios = ref([])
const confirmDialog = ref(false)
const ensaioParaExcluir = ref(null)
const excluindo = ref(false)

const formatDate = (dateString) => {
  if (!dateString) return '-'
  const [year, month, day] = dateString.split('-')
  return `${day}/${month}/${year}`
}

const formatNumber = (value) => {
  if (!value) return '-'
  return value.toString().replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.')
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

const loadEnsaios = async () => {
  try {
    const { data, error } = await supabase
      .from('limite_consistencia_entradas')
      .select(`
        *,
        limite_consistencia_resultados (
          limite_liquidez,
          limite_plasticidade,
          indice_plasticidade
        )
      `)
      .eq('ambiente_id', route.query.ambiente)
      .order('data_ensaio', { ascending: false })

    if (error) throw error
    ensaios.value = data
  } catch (error) {
    console.error('Erro ao carregar ensaios:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar lista de ensaios'
    })
  }
}

const visualizarEnsaio = (ensaioId) => {
  router.push(`/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/visualizar/${ensaioId}?ambiente=${route.query.ambiente}`)
}

const confirmarExclusao = (ensaio) => {
  ensaioParaExcluir.value = ensaio
  confirmDialog.value = true
}

const excluirEnsaio = async () => {
  try {
    excluindo.value = true
    const { error } = await supabase
      .from('limite_consistencia_entradas')
      .delete()
      .eq('id', ensaioParaExcluir.value.id)

    if (error) throw error

    $q.notify({
      type: 'positive',
      message: 'Ensaio excluído com sucesso!'
    })

    await loadEnsaios()
  } catch (error) {
    console.error('Erro ao excluir ensaio:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao excluir ensaio'
    })
  } finally {
    excluindo.value = false
    confirmDialog.value = false
    ensaioParaExcluir.value = null
  }
}

onMounted(async () => {
  const ambienteId = route.query.ambiente
  if (!ambienteId) {
    router.push('/ensaios/terraplenagem/compactacao-aterro')
    return
  }
  
  await loadAmbiente(ambienteId)
  await loadEnsaios()
})
</script> 