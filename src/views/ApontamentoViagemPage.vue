<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" to="/" class="q-mr-sm" />
          <h5 class="q-my-none">Apontamento de Viagens</h5>
        </div>
      </div>
    </div>

    <!-- Lista de Dias Produtivos -->
    <q-card class="q-mb-md">
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Dias Produtivos</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="showAddDialog = true">
              <q-tooltip>Adicionar Dia Produtivo</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando dias produtivos...</div>
        </div>

        <div v-else-if="!diasProdutivos.length" class="text-center q-pa-lg">
          <q-icon name="assignment" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhum dia produtivo cadastrado</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item
            v-for="dia in diasProdutivos"
            :key="dia.id"
            clickable
            v-ripple
            @click="navigateToDiaProdutivo(dia)"
          >
            <q-item-section>
              <q-item-label class="text-weight-medium">
                {{ formatDate(dia.data) }} - {{ dia.medicao.label }}
              </q-item-label>
              <q-item-label caption>
                {{ dia.viagens_count || 0 }} viagens registradas
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-icon name="chevron_right" color="grey-6" />
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar dia produtivo -->
    <q-dialog v-model="showAddDialog">
      <q-card class="dialog-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Novo Dia Produtivo</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-md">
          <q-form @submit="onSubmit" class="q-gutter-md">
            <div class="row justify-center">
              <div class="col-12">
                <q-input 
                  v-model="formData.data" 
                  type="date" 
                  outlined
                  label="Data" 
                  class="full-width" 
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              
              <div class="col-12">
                <q-select 
                  v-model="formData.medicao" 
                  :options="medicaoOptions" 
                  outlined
                  label="Medição" 
                  class="full-width"
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>

            <div class="row justify-end q-gutter-sm q-pt-md">
              <q-btn 
                label="Cancelar" 
                color="negative" 
                flat 
                v-close-popup 
              />
              <q-btn 
                label="Adicionar" 
                type="submit" 
                color="primary" 
                :disable="!isFormValid"
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/auth'
import { useSelectedObra } from '@/composables/useSelectedObra'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { supabase } from '@/lib/supabase'

const $q = useQuasar()
const router = useRouter()
const authStore = useAuthStore()
const { selectedObra } = useSelectedObra()

// Estado para o ambiente selecionado
const diasProdutivos = ref([])
const formData = ref({
  data: new Date().toISOString().substring(0, 10),
  medicao: null
})

// Variáveis para o diálogo
const showAddDialog = ref(false)
const loading = ref(false)

// Opções para os campos select
const medicaoOptions = ref([])

// Dados mockados temporários
const mockDiasProdutivos = [
  {
    id: '1',
    data: '2024-03-20',
    medicao: {
      numero: 1,
      data_inicio: '2024-03-01',
      data_fim: '2024-03-31',
      id: '1'
    },
    viagens_count: 5
  },
  {
    id: '2',
    data: '2024-03-19',
    medicao: {
      numero: 1,
      data_inicio: '2024-03-01',
      data_fim: '2024-03-31',
      id: '1'
    },
    viagens_count: 3
  }
]

// Carregar dias produtivos
const loadDiasProdutivos = async () => {
  if (!selectedObra.value?.id) return
  
  try {
    loading.value = true
    // Simular delay de carregamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Usar dados mockados
    diasProdutivos.value = mockDiasProdutivos.map(dia => ({
      ...dia,
      medicao: {
        label: `Medição ${dia.medicao.numero} (${new Date(dia.medicao.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(dia.medicao.data_fim).toLocaleDateString('pt-BR')})`,
        value: dia.medicao.id
      }
    }))
  } catch (error) {
    console.error('Erro ao carregar dias produtivos:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dias produtivos'
    })
  } finally {
    loading.value = false
  }
}

// Carregar medições da obra
const loadMedicoes = async () => {
  if (!selectedObra.value?.id) return
  
  try {
    // Simular delay de carregamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Dados mockados de medições
    const mockMedicoes = [
      {
        id: '1',
        numero: 1,
        data_inicio: '2024-03-01',
        data_fim: '2024-03-31',
        status: 'aberto'
      },
      {
        id: '2',
        numero: 2,
        data_inicio: '2024-04-01',
        data_fim: '2024-04-30',
        status: 'aberto'
      }
    ]
    
    medicaoOptions.value = mockMedicoes.map(medicao => ({
      label: `Medição ${medicao.numero} (${new Date(medicao.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(medicao.data_fim).toLocaleDateString('pt-BR')})`,
      value: medicao.id
    }))
  } catch (error) {
    console.error('Erro ao carregar medições:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar medições'
    })
  }
}

// Observar mudanças na obra selecionada
watch(() => selectedObra.value?.id, (newObraId) => {
  if (newObraId) {
    loadMedicoes()
    loadDiasProdutivos()
  }
})

// Verificar se o formulário é válido
const isFormValid = computed(() => {
  return formData.value.data && formData.value.medicao
})

// Formatar data
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return format(date, 'dd/MM/yyyy', { locale: ptBR })
}

// Navegar para o dia produtivo
const navigateToDiaProdutivo = (diaProdutivo) => {
  router.push(`/apontamentos/dia-produtivo/${diaProdutivo.id}`)
}

// Salvar novo dia produtivo
const onSubmit = async () => {
  if (!isFormValid.value) return
  
  try {
    // Simular delay de salvamento
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Criar novo dia produtivo com ID temporário
    const novoDia = {
      id: String(mockDiasProdutivos.length + 1),
      data: formData.value.data,
      medicao: {
        numero: parseInt(formData.value.medicao.value),
        data_inicio: '2024-03-01', // Dados mockados
        data_fim: '2024-03-31',    // Dados mockados
        id: formData.value.medicao.value
      },
      viagens_count: 0
    }
    
    // Adicionar à lista mockada
    mockDiasProdutivos.unshift(novoDia)

    $q.notify({
      message: 'Dia produtivo criado com sucesso!',
      color: 'positive'
    })

    showAddDialog.value = false
    formData.value = {
      data: new Date().toISOString().substring(0, 10),
      medicao: null
    }
    loadDiasProdutivos()
  } catch (error) {
    console.error('Erro ao criar dia produtivo:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao criar dia produtivo'
    })
  }
}

// Inicialização
onMounted(() => {
  if (selectedObra.value?.id) {
    loadMedicoes()
    loadDiasProdutivos()
  }
})
</script>

<style scoped>
.ensaio-card {
  height: 100%;
  transition: all 0.2s ease-in-out;
}

.ensaio-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dialog-card {
  width: 100%;
  max-width: 400px;
  margin: 20px;
}

@media (max-width: 599px) {
  .dialog-card {
    margin: 10px;
  }
}
</style> 