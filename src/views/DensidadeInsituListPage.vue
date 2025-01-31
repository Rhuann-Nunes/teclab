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
            <h5 class="q-my-none">Ensaios de Densidade "In Situ"</h5>
            <div class="text-subtitle2 text-grey-7">{{ ambiente?.localizacao?.nome }}</div>
          </div>
        </div>
      </div>
      <div>
        <q-btn
          color="primary"
          icon="add"
          round
          :to="'/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/novo?ambiente=' + route.query.ambiente"
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
                      Furos: {{ ensaio.furos?.length || 0 }} |
                      GC Médio: {{ calcularGCMedio(ensaio.furos) }}
                    </div>
                  </div>
                  <div class="col-auto">
                    <q-btn
                      flat
                      round
                      color="primary"
                      icon="visibility"
                      :to="{
                        path: `/ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/${ensaio.id}`,
                        query: {
                          ambiente: route.query.ambiente,
                          visualizar: 'true'
                        }
                      }"
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
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog de confirmação de exclusão -->
    <q-dialog v-model="dialogExclusao">
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="warning" color="negative" text-color="white" />
          <span class="q-ml-sm">Deseja realmente excluir este ensaio?</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Excluir" color="negative" @click="excluirEnsaio" v-close-popup />
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
import { formatDate, formatPercent } from '@/utils/format'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()

const ambiente = ref(null)
const ensaios = ref([])
const dialogExclusao = ref(false)
const ensaioParaExcluir = ref(null)

onMounted(async () => {
  await carregarAmbiente()
  await carregarEnsaios()
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

async function carregarEnsaios() {
  const { data, error } = await supabase
    .from('densidade_insitu_entradas')
    .select(`
      *,
      furos:densidade_insitu_furos(*)
    `)
    .eq('ambiente_id', route.query.ambiente)
    .order('data_ensaio', { ascending: false })

  if (error) {
    console.error('Erro ao carregar ensaios:', error)
    return
  }

  ensaios.value = data
}

function calcularGCMedio(furos) {
  if (!furos || furos.length === 0) return '-'
  const soma = furos.reduce((acc, furo) => acc + (furo.grau_compactacao || 0), 0)
  return formatPercent(soma / furos.length)
}

function confirmarExclusao(ensaio) {
  ensaioParaExcluir.value = ensaio
  dialogExclusao.value = true
}

async function excluirEnsaio() {
  const { error } = await supabase
    .from('densidade_insitu_entradas')
    .delete()
    .eq('id', ensaioParaExcluir.value.id)

  if (error) {
    $q.notify({
      type: 'negative',
      message: 'Erro ao excluir ensaio'
    })
    return
  }

  $q.notify({
    type: 'positive',
    message: 'Ensaio excluído com sucesso'
  })

  await carregarEnsaios()
}
</script> 