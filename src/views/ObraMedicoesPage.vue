<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Medições da Obra</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Medições -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Medições Cadastradas</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="showAddDialog = true">
              <q-tooltip>Adicionar Medição</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando medições...</div>
        </div>

        <div v-else-if="!medicoes.length" class="text-center q-pa-lg">
          <q-icon name="assignment" size="48px" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-sm">Nenhuma medição cadastrada</div>
          <div class="text-grey">Clique no botão + para adicionar</div>
        </div>

        <q-list v-else separator>
          <q-item
            v-for="medicao in medicoes"
            :key="medicao.id"
            clickable
            v-ripple
            @click="router.push(`/obras/${obraId}/medicoes/${medicao.id}`)"
          >
            <q-item-section>
              <q-item-label class="text-weight-medium">
                Medição nº {{ medicao.numero }}
                <q-badge
                  :color="medicao.status === 'aberto' ? 'grey' : 'positive'"
                  class="q-ml-sm"
                  :label="medicao.status === 'aberto' ? 'Em Aberto' : 'Fechada'"
                  size="sm"
                />
              </q-item-label>
              <q-item-label caption>
                Período: {{ new Date(medicao.data_inicio).toLocaleDateString('pt-BR') }} 
                até {{ new Date(medicao.data_fim).toLocaleDateString('pt-BR') }}
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-icon name="chevron_right" color="grey-6" />
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- Dialog para adicionar/editar medição -->
    <q-dialog v-model="showAddDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Nova Medição</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-input
              v-model.number="novaMedicao.numero"
              type="number"
              label="Número da Medição"
              outlined
              :disable="editMode"
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
                  v-model="novaMedicao.data_inicio"
                  type="date"
                  label="Data Inicial"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              <div class="col-6">
                <q-input
                  v-model="novaMedicao.data_fim"
                  type="date"
                  label="Data Final"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
            </div>

            <q-checkbox
              v-model="novaMedicao.status"
              :true-value="'fechado'"
              :false-value="'aberto'"
              label="Medição Fechada"
              color="primary"
            />

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn 
                :label="editMode ? 'Salvar' : 'Adicionar'" 
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
import { ref, onMounted } from 'vue'
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
const medicoes = ref([])
const loading = ref(true)
const saving = ref(false)
const showAddDialog = ref(false)
const editMode = ref(false)

const novaMedicao = ref({
  numero: null,
  data_inicio: '',
  data_fim: '',
  status: 'aberto'
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

const loadMedicoes = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('medicoes_obra')
      .select('*')
      .eq('obra_id', obraId)
      .order('numero', { ascending: true })
    
    if (error) throw error
    medicoes.value = data
  } catch (error) {
    console.error('Erro ao carregar medições:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar medições'
    })
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  novaMedicao.value = {
    numero: null,
    data_inicio: '',
    data_fim: '',
    status: 'aberto'
  }
}

const onSubmit = async () => {
  try {
    saving.value = true

    // Validar período
    if (new Date(novaMedicao.value.data_fim) < new Date(novaMedicao.value.data_inicio)) {
      throw new Error('A data final deve ser maior ou igual à data inicial')
    }

    // Se a medição estiver sendo criada como aberta, verificar outras medições
    if (novaMedicao.value.status === 'aberto') {
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
            message: 'Ao criar uma nova medição aberta, todas as outras medições serão fechadas automaticamente. Deseja continuar?',
            cancel: true,
            persistent: true
          }).onOk(() => resolve(true))
            .onCancel(() => resolve(false))
        })

        if (!confirm) {
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
      ...novaMedicao.value,
      obra_id: obraId,
      usuario_cadastro: auth.user.email
    }

    const { error: insertError } = await supabase
      .from('medicoes_obra')
      .insert(medicaoData)

    if (insertError) throw insertError

    $q.notify({
      type: 'positive',
      message: 'Medição adicionada com sucesso!'
    })

    showAddDialog.value = false
    resetForm()
    loadMedicoes()
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

const confirmDelete = (medicao) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: `Tem certeza que deseja excluir a medição nº ${medicao.numero}?`,
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('medicoes_obra')
        .delete()
        .eq('id', medicao.id)
      
      if (error) throw error

      $q.notify({
        type: 'positive',
        message: 'Medição excluída com sucesso!'
      })

      loadMedicoes()
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
  loadObra()
  loadMedicoes()
})
</script> 