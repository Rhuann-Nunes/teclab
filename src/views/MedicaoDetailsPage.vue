<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}/medicoes`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">
              Medição nº {{ medicao?.numero }}
              <q-badge
                :color="medicao?.status === 'aberto' ? 'grey' : 'positive'"
                class="q-ml-sm"
                :label="medicao?.status === 'aberto' ? 'Em Aberto' : 'Fechada'"
                size="sm"
              />
            </h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Informações Gerais -->
      <div class="col-12 col-md-4">
        <q-card>
          <q-card-section>
            <div class="row items-center">
              <div class="text-h6 col">Informações Gerais</div>
              <div class="col-auto">
                <q-btn flat round color="primary" icon="edit" size="sm" @click="showEditDialog = true">
                  <q-tooltip>Editar medição</q-tooltip>
                </q-btn>
                <q-btn flat round color="negative" icon="delete" size="sm" @click="confirmDelete">
                  <q-tooltip>Excluir medição</q-tooltip>
                </q-btn>
              </div>
            </div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <q-list>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Período</q-item-label>
                  <q-item-label>
                    {{ medicao?.data_inicio ? new Date(medicao.data_inicio).toLocaleDateString('pt-BR') : '' }}
                    até
                    {{ medicao?.data_fim ? new Date(medicao.data_fim).toLocaleDateString('pt-BR') : '' }}
                  </q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Data de Cadastro</q-item-label>
                  <q-item-label>
                    {{ medicao?.data_cadastro ? new Date(medicao.data_cadastro).toLocaleDateString('pt-BR') : '' }}
                  </q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Usuário Cadastro</q-item-label>
                  <q-item-label>{{ medicao?.usuario_cadastro }}</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>

      <!-- Menu de Gerenciamento -->
      <div class="col-12 col-md-8">
        <div class="row q-col-gutter-md">
          <!-- Serviços Executados -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageServicosExecutados">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="engineering" color="primary" size="32px" class="q-mr-sm" />
                      Serviços Executados
                    </div>
                    <div class="text-subtitle2">Gerenciar serviços</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Ensaios Realizados -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageEnsaiosRealizados">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="science" color="secondary" size="32px" class="q-mr-sm" />
                      Ensaios Realizados
                    </div>
                    <div class="text-subtitle2">Gerenciar ensaios</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Relatório da Medição -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="generateReport">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="description" color="info" size="32px" class="q-mr-sm" />
                      Relatório da Medição
                    </div>
                    <div class="text-subtitle2">Gerar relatório</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </div>
    </div>

    <!-- Dialog para editar medição -->
    <q-dialog v-model="showEditDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Editar Medição</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-input
              v-model.number="editingMedicao.numero"
              type="number"
              label="Número da Medição"
              outlined
              disable
              :rules="[
                val => !!val || 'Campo obrigatório',
                val => val > 0 || 'Deve ser maior que zero',
                val => val < 1000 || 'Número deve ser menor que 1000'
              ]"
              maxlength="3"
            />

            <div class="row q-col-gutter-sm">
              <div class="col-6">
                <q-input
                  v-model="editingMedicao.data_inicio"
                  type="date"
                  label="Data Inicial"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              <div class="col-6">
                <q-input
                  v-model="editingMedicao.data_fim"
                  type="date"
                  label="Data Final"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>

            <q-checkbox
              v-model="editingMedicao.status"
              :true-value="'fechado'"
              :false-value="'aberto'"
              label="Medição Fechada"
              color="primary"
            />

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn 
                label="Salvar"
                type="submit" 
                color="primary" 
                :loading="saving" 
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const obraId = route.params.obraId
const medicaoId = route.params.medicaoId
const obra = ref(null)
const medicao = ref(null)
const loading = ref(true)
const saving = ref(false)
const showEditDialog = ref(false)

const editingMedicao = ref({
  numero: null,
  data_inicio: '',
  data_fim: '',
  status: 'aberto'
})

const loadData = async () => {
  try {
    loading.value = true
    
    // Carregar obra
    const { data: obraData, error: obraError } = await supabase
      .from('obras')
      .select('*')
      .eq('id', obraId)
      .single()
    
    if (obraError) throw obraError
    obra.value = obraData

    // Carregar medição
    const { data: medicaoData, error: medicaoError } = await supabase
      .from('medicoes_obra')
      .select('*')
      .eq('id', medicaoId)
      .single()
    
    if (medicaoError) throw medicaoError
    medicao.value = medicaoData
  } catch (error) {
    console.error('Erro ao carregar dados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar dados'
    })
  } finally {
    loading.value = false
  }
}

const manageServicosExecutados = () => {
  router.push(`/obras/${obraId}/medicoes/${medicaoId}/servicos`)
}

const manageEnsaiosRealizados = () => {
  router.push(`/obras/${obraId}/medicoes/${medicaoId}/ensaios`)
}

const generateReport = () => {
  // TODO: Implementar geração de relatório
  $q.notify({
    type: 'info',
    message: 'Funcionalidade em desenvolvimento'
  })
}

const onSubmit = async () => {
  try {
    saving.value = true

    // Validar período
    if (new Date(editingMedicao.value.data_fim) < new Date(editingMedicao.value.data_inicio)) {
      throw new Error('A data final deve ser maior ou igual à data inicial')
    }

    // Se estiver alterando o status para aberto
    if (editingMedicao.value.status === 'aberto' && medicao.value.status === 'fechado') {
      // Verificar se existem outras medições abertas
      const { data: medicoesAbertas } = await supabase
        .from('medicoes_obra')
        .select('numero')
        .eq('obra_id', obraId)
        .eq('status', 'aberto')

      if (medicoesAbertas?.length > 0) {
        // Mostrar diálogo de confirmação
        const confirm = await new Promise(resolve => {
          $q.dialog({
            title: 'Atenção',
            message: 'Ao abrir esta medição, todas as outras medições serão fechadas automaticamente. Deseja continuar?',
            cancel: true,
            persistent: true
          }).onOk(() => resolve(true))
            .onCancel(() => resolve(false))
        })

        if (!confirm) {
          editingMedicao.value.status = 'fechado'
          return
        }

        // Fechar todas as outras medições
        const { error: updateError } = await supabase
          .from('medicoes_obra')
          .update({ status: 'fechado' })
          .eq('obra_id', obraId)
          .eq('status', 'aberto')

        if (updateError) throw updateError
      }
    }

    const medicaoData = {
      ...editingMedicao.value,
      obra_id: obraId
    }

    const { error } = await supabase
      .from('medicoes_obra')
      .update(medicaoData)
      .eq('id', medicaoId)

    if (error) throw error

    $q.notify({
      type: 'positive',
      message: 'Medição atualizada com sucesso!'
    })

    showEditDialog.value = false
    loadData()
  } catch (error) {
    console.error('Erro ao salvar medição:', error)
    $q.notify({
      type: 'negative',
      message: error.message || 'Erro ao salvar medição'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = () => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: `Tem certeza que deseja excluir a medição nº ${medicao.value?.numero}?`,
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('medicoes_obra')
        .delete()
        .eq('id', medicaoId)
      
      if (error) throw error

      $q.notify({
        type: 'positive',
        message: 'Medição excluída com sucesso!'
      })

      router.push(`/obras/${obraId}/medicoes`)
    } catch (error) {
      console.error('Erro ao excluir medição:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir medição'
      })
    }
  })
}

onMounted(() => {
  loadData()
})

// Watch para atualizar o formulário quando a medição for carregada
watch(() => medicao.value, (newMedicao) => {
  if (newMedicao) {
    editingMedicao.value = { ...newMedicao }
  }
})
</script>

<style scoped>
.menu-card {
  transition: all 0.2s ease;
}

.menu-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 25px 0 rgba(0, 0, 0, 0.1);
}
</style> 