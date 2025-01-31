<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Check-List de Ensaios</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Regras -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Regras Cadastradas</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="showAddDialog = true">
              <q-tooltip>Adicionar Regra</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando regras...</div>
        </div>

        <div v-else-if="!regras.length" class="text-center q-pa-lg">
          <q-icon name="rule" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhuma regra cadastrada</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item v-for="regra in regras" :key="regra.id">
            <q-item-section>
              <q-item-label class="text-weight-medium">{{ regra.nome_ensaio }}</q-item-label>
              <q-item-label caption>
                1 ensaio a cada {{ regra.quantidade_regra }} {{ regra.unidade_servico }} 
                de {{ regra.servico_obra?.nome }}
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn flat round color="negative" icon="delete" @click="confirmDelete(regra)">
                <q-tooltip>Excluir regra</q-tooltip>
              </q-btn>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar regra -->
    <q-dialog v-model="showAddDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Nova Regra</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="novaRegra.nome_ensaio"
              :options="ensaios_disponiveis"
              label="Ensaio"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
              @update:model-value="onEnsaioChange"
            />

            <q-select
              v-model="novaRegra.servico_obra_id"
              :options="servicos"
              label="Serviço"
              outlined
              option-label="nome"
              option-value="id"
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
              @update:model-value="onServicoChange"
            />

            <div class="row q-col-gutter-sm">
              <div class="col-8">
                <q-input
                  v-model.number="novaRegra.quantidade_regra"
                  label="Quantidade"
                  type="number"
                  outlined
                  :rules="[
                    val => !!val || 'Campo obrigatório',
                    val => val > 0 || 'Deve ser maior que zero'
                  ]"
                />
              </div>
              <div class="col-4">
                <q-input
                  v-model="novaRegra.unidade_servico"
                  label="Unidade"
                  outlined
                  disable
                  :value="selectedServico?.unidade"
                />
              </div>
            </div>

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn label="Salvar" type="submit" color="primary" :loading="saving" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
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
const auth = useAuthStore()

const obraId = route.params.id
const obra = ref(null)
const regras = ref([])
const servicos = ref([])
const loading = ref(true)
const saving = ref(false)
const showAddDialog = ref(false)

const ensaios_disponiveis = [
  { label: 'Granulometria', value: 'granulometria', tabela: 'granulometria_resultados' },
  { label: 'Limites de Atterberg', value: 'limites_atterberg', tabela: 'limite_consistencia_resultados' },
  { label: 'Compactação', value: 'compactacao', tabela: 'compactacao_resultados' },
  { label: 'CBR e Expansão', value: 'cbr', tabela: 'cbr_resultados' },
  { label: 'Densidade "In Situ"', value: 'densidade_insitu', tabela: 'densidade_insitu_furos' }
]

const novaRegra = ref({
  obra_id: obraId,
  nome_ensaio: null,
  tabela_ensaio: null,
  quantidade_regra: null,
  unidade_servico: null,
  servico_obra_id: null
})

const selectedServico = computed(() => {
  return servicos.value.find(s => s.id === novaRegra.value.servico_obra_id)
})

const loadObra = async () => {
  try {
    const { data, error } = await supabase
      .from('obras')
      .select('*')
      .eq('id', obraId)
      .single()
    
    if (error) throw error
    obra.value = data
  } catch (error) {
    console.error('Erro ao carregar obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar obra'
    })
  }
}

const loadRegras = async () => {
  try {
    const { data, error } = await supabase
      .from('regras_ensaios_obra')
      .select('*, servico_obra:servicos_obra(nome)')
      .eq('obra_id', obraId)
    
    if (error) throw error
    regras.value = data
  } catch (error) {
    console.error('Erro ao carregar regras:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar regras'
    })
  }
}

const loadServicos = async () => {
  try {
    const { data, error } = await supabase
      .from('servicos_obra')
      .select('*')
      .eq('obra_id', obraId)
    
    if (error) throw error
    servicos.value = data
  } catch (error) {
    console.error('Erro ao carregar serviços:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar serviços'
    })
  }
}

const onEnsaioChange = (value) => {
  const ensaio = ensaios_disponiveis.find(e => e.value === value)
  if (ensaio) {
    novaRegra.value.tabela_ensaio = ensaio.tabela
  }
}

const onServicoChange = (value) => {
  const servico = servicos.value.find(s => s.id === value)
  if (servico) {
    novaRegra.value.unidade_servico = servico.unidade
  }
}

const onSubmit = async () => {
  try {
    saving.value = true
    const { data, error } = await supabase
      .from('regras_ensaios_obra')
      .insert({
        ...novaRegra.value,
        usuario_cadastro: auth.user.email
      })
    
    if (error) throw error

    await loadRegras()
    showAddDialog.value = false
    novaRegra.value = {
      obra_id: obraId,
      nome_ensaio: null,
      tabela_ensaio: null,
      quantidade_regra: null,
      unidade_servico: null,
      servico_obra_id: null
    }

    $q.notify({
      type: 'positive',
      message: 'Regra cadastrada com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao salvar regra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao salvar regra'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = (regra) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: 'Deseja realmente excluir esta regra?',
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('regras_ensaios_obra')
        .delete()
        .eq('id', regra.id)
      
      if (error) throw error

      await loadRegras()
      $q.notify({
        type: 'positive',
        message: 'Regra excluída com sucesso!'
      })
    } catch (error) {
      console.error('Erro ao excluir regra:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir regra'
      })
    }
  })
}

onMounted(async () => {
  try {
    loading.value = true
    await Promise.all([
      loadObra(),
      loadRegras(),
      loadServicos()
    ])
  } finally {
    loading.value = false
  }
})
</script> 