<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Serviços da Obra</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Serviços -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Serviços Cadastrados</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="showAddDialog = true">
              <q-tooltip>Adicionar Serviço</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando serviços...</div>
        </div>

        <div v-else-if="!servicos.length" class="text-center q-pa-lg">
          <q-icon name="build" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhum serviço cadastrado</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item v-for="servico in servicos" :key="servico.id">
            <q-item-section>
              <q-item-label class="text-weight-medium">{{ servico.nome }}</q-item-label>
              <q-item-label caption>
                {{ servico.quantidade_total }} {{ servico.unidade }}
              </q-item-label>
              <q-item-label caption>
                <q-icon name="place" size="xs" class="q-mr-xs" />
                {{ servico.localizacao_obra?.nome }}
                <template v-if="servico.localizacao_obra?.tipo === 'trecho'">
                  ({{ formatEstacaDisplay(servico.estaca_inicial) }} até {{ formatEstacaDisplay(servico.estaca_final) }})
                </template>
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn flat round color="negative" icon="delete" @click="confirmDelete(servico)">
                <q-tooltip>Excluir serviço</q-tooltip>
              </q-btn>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar serviço -->
    <q-dialog v-model="showAddDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Novo Serviço</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="novoServico.nome"
              :options="servicos_disponiveis"
              label="Nome do Serviço"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <div class="row q-col-gutter-sm">
              <div class="col-8">
                <q-input
                  v-model.number="novoServico.quantidade_total"
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
                <q-select
                  v-model="novoServico.unidade"
                  :options="unidades"
                  label="Unidade"
                  outlined
                  emit-value
                  map-options
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>

            <q-select
              v-model="novoServico.localizacao_obra_id"
              :options="localizacoes"
              label="Localização"
              outlined
              option-label="nome"
              option-value="id"
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <template v-if="selectedLocalizacao?.tipo === 'trecho'">
              <div class="row justify-center">
                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Estaca Inicial</div>
                  <div class="row items-center justify-center q-col-gutter-sm">
                    <div class="col-4">
                      <q-input
                        v-model="novoServico.estaca_inicial_inteiro"
                        type="number"
                        outlined
                        dense
                        placeholder="0"
                        :rules="[
                          val => !!val || 'Campo obrigatório',
                          val => val >= 0 || 'Valor deve ser positivo'
                        ]"
                      />
                    </div>
                    <div class="col-auto">
                      <span class="text-h6">+</span>
                    </div>
                    <div class="col-2">
                      <q-input
                        v-model="novoServico.estaca_inicial_decimal"
                        type="number"
                        outlined
                        dense
                        placeholder="0"
                        :rules="[
                          val => !val || (val >= 0 && val <= 19) || 'Valor deve estar entre 0 e 19'
                        ]"
                      />
                    </div>
                  </div>
                </div>

                <div class="col-12 q-mt-md">
                  <div class="text-subtitle2 q-mb-sm">Estaca Final</div>
                  <div class="row items-center justify-center q-col-gutter-sm">
                    <div class="col-4">
                      <q-input
                        v-model="novoServico.estaca_final_inteiro"
                        type="number"
                        outlined
                        dense
                        placeholder="0"
                        :rules="[
                          val => !!val || 'Campo obrigatório',
                          val => val >= 0 || 'Valor deve ser positivo'
                        ]"
                      />
                    </div>
                    <div class="col-auto">
                      <span class="text-h6">+</span>
                    </div>
                    <div class="col-2">
                      <q-input
                        v-model="novoServico.estaca_final_decimal"
                        type="number"
                        outlined
                        dense
                        placeholder="0"
                        :rules="[
                          val => !val || (val >= 0 && val <= 19) || 'Valor deve estar entre 0 e 19'
                        ]"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </template>

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
const authStore = useAuthStore()

const obraId = route.params.id
const obra = ref(null)
const servicos = ref([])
const localizacoes = ref([])
const loading = ref(true)
const saving = ref(false)
const showAddDialog = ref(false)

const novoServico = ref({
  nome: '',
  quantidade_total: null,
  unidade: '',
  localizacao_obra_id: null,
  estaca_inicial_inteiro: '',
  estaca_inicial_decimal: '',
  estaca_final_inteiro: '',
  estaca_final_decimal: ''
})

const selectedLocalizacao = computed(() => {
  return localizacoes.value.find(loc => loc.id === novoServico.value.localizacao_obra_id)
})

const servicos_disponiveis = [
  { label: 'COMPACTAÇÃO A 95% DO PROCTOR NORMAL', value: 'COMPACTAÇÃO A 95% DO PROCTOR NORMAL' },
  { label: 'COMPACTAÇÃO A 100% DO PROCTOR NORMAL', value: 'COMPACTAÇÃO A 100% DO PROCTOR NORMAL' }
]

const unidades = [
  { label: 'Metro (m)', value: 'm' },
  { label: 'Metro Quadrado (m²)', value: 'm²' },
  { label: 'Metro Cúbico (m³)', value: 'm³' },
  { label: 'Quilograma (kg)', value: 'kg' },
  { label: 'Tonelada (t)', value: 't' },
  { label: 'Unidade (un)', value: 'un' },
  { label: 'Hora (h)', value: 'h' }
]

const formatEstaca = (inteiro, decimal = 0) => {
  return parseFloat(`${inteiro}.${decimal.toString().padStart(3, '0')}`)
}

const parseEstaca = (valor) => {
  if (!valor) return { inteiro: '', decimal: '' }
  const [inteiro, decimal] = valor.toString().split('.')
  return {
    inteiro: inteiro || '',
    decimal: decimal ? parseInt(decimal) : ''
  }
}

const formatEstacaDisplay = (valor) => {
  if (!valor) return ''
  const [inteiro, decimal] = valor.toString().split('.')
  const decimalValue = decimal ? parseInt(decimal) : 0
  return decimalValue > 0 ? `${inteiro}+${decimalValue}` : inteiro
}

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

const loadServicos = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('servicos_obra')
      .select('*, localizacao_obra(*)')
      .eq('obra_id', obraId)
    
    if (error) throw error
    servicos.value = data
  } catch (error) {
    console.error('Erro ao carregar serviços:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar serviços'
    })
  } finally {
    loading.value = false
  }
}

const loadLocalizacoes = async () => {
  try {
    const { data, error } = await supabase
      .from('localizacao_obra')
      .select('*')
      .eq('obra_id', obraId)
    
    if (error) throw error
    localizacoes.value = data
  } catch (error) {
    console.error('Erro ao carregar localizações:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar localizações'
    })
  }
}

const onSubmit = async () => {
  try {
    saving.value = true

    // Format stakes if location is trecho
    let servicoData = { ...novoServico.value }
    if (selectedLocalizacao.value?.tipo === 'trecho') {
      servicoData.estaca_inicial = formatEstaca(servicoData.estaca_inicial_inteiro, servicoData.estaca_inicial_decimal)
      servicoData.estaca_final = formatEstaca(servicoData.estaca_final_inteiro, servicoData.estaca_final_decimal)
    }

    // Remove temporary fields
    delete servicoData.estaca_inicial_inteiro
    delete servicoData.estaca_inicial_decimal
    delete servicoData.estaca_final_inteiro
    delete servicoData.estaca_final_decimal

    const { error } = await supabase
      .from('servicos_obra')
      .insert({
        ...servicoData,
        obra_id: obraId,
        usuario_cadastro: authStore.user.user_metadata.display_name
      })
    
    if (error) throw error
    
    await loadServicos()
    showAddDialog.value = false
    
    $q.notify({
      type: 'positive',
      message: 'Serviço cadastrado com sucesso!'
    })

    // Reset form
    novoServico.value = {
      nome: '',
      quantidade_total: null,
      unidade: '',
      localizacao_obra_id: null,
      estaca_inicial_inteiro: '',
      estaca_inicial_decimal: '',
      estaca_final_inteiro: '',
      estaca_final_decimal: ''
    }
  } catch (error) {
    console.error('Erro ao cadastrar serviço:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao cadastrar serviço'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = (servico) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: 'Deseja realmente excluir este serviço?',
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('servicos_obra')
        .delete()
        .eq('id', servico.id)
      
      if (error) throw error
      
      await loadServicos()
      
      $q.notify({
        type: 'positive',
        message: 'Serviço excluído com sucesso!'
      })
    } catch (error) {
      console.error('Erro ao excluir serviço:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir serviço'
      })
    }
  })
}

onMounted(() => {
  loadObra()
  loadServicos()
  loadLocalizacoes()
})
</script> 