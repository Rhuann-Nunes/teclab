<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Trechos da Obra</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Trechos -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Trechos Cadastrados</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="add" size="sm" @click="openDialog()">
              <q-tooltip>Adicionar Trecho</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando trechos...</div>
        </div>

        <div v-else-if="trechos.length === 0" class="text-center q-pa-lg">
          <q-icon name="map" size="4em" color="grey-5" />
          <div class="text-h6 text-grey-7 q-mt-md">Nenhum trecho cadastrado</div>
          <div class="text-grey-7">Clique no botão "+" para adicionar um trecho</div>
        </div>

        <div v-else>
          <q-list separator>
            <q-item v-for="trecho in trechos" :key="trecho.id">
              <q-item-section>
                <q-item-label class="text-weight-medium">
                  <q-icon :name="trecho.tipo === 'trecho' ? 'timeline' : 'place'" size="sm" class="q-mr-sm" />
                  {{ trecho.nome }}
                </q-item-label>
                <template v-if="trecho.tipo === 'trecho'">
                  <q-item-label caption>
                    Estaca Inicial: {{ formatEstacaDisplay(trecho.estaca_inicial) }} | 
                    Estaca Final: {{ formatEstacaDisplay(trecho.estaca_final) }}
                  </q-item-label>
                </template>
                <template v-else>
                  <q-item-label caption>
                    {{ trecho.descricao }}
                  </q-item-label>
                </template>
                <q-item-label caption class="text-grey-7">
                  Cadastrado por {{ trecho.usuario_cadastro }} em {{ new Date(trecho.data_cadastro).toLocaleString() }}
                </q-item-label>
              </q-item-section>
              <q-item-section side>
                <div class="row items-center q-gutter-sm">
                  <q-btn flat round color="primary" icon="edit" size="sm" @click="openDialog(trecho)">
                    <q-tooltip>Editar Localização</q-tooltip>
                  </q-btn>
                  <q-btn flat round color="negative" icon="delete" size="sm" @click="confirmDelete(trecho)">
                    <q-tooltip>Excluir Localização</q-tooltip>
                  </q-btn>
                </div>
              </q-item-section>
            </q-item>
          </q-list>
        </div>
      </q-card-section>
    </q-card>

    <!-- Dialog de Cadastro/Edição -->
    <q-dialog v-model="showDialog" persistent>
      <q-card class="dialog-card">
        <q-card-section class="row items-center">
          <div class="text-h6">{{ editingTrecho.id ? 'Editar' : 'Nova' }} Localização</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="onSubmit" class="q-gutter-md">
            <q-select
              v-model="editingTrecho.tipo"
              :options="[
                { label: 'Trecho Estaqueado', value: 'trecho' },
                { label: 'Ponto Específico', value: 'pontual' }
              ]"
              label="Tipo de Localização"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-input
              v-model="editingTrecho.nome"
              label="Nome"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <template v-if="editingTrecho.tipo === 'trecho'">
              <div class="row justify-center">
                <div class="col-12">
                  <div class="text-subtitle2 q-mb-sm">Estaca Inicial</div>
                  <div class="row items-center justify-center q-col-gutter-sm">
                    <div class="col-4">
                      <q-input
                        v-model="editingTrecho.estaca_inicial_inteiro"
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
                        v-model="editingTrecho.estaca_inicial_decimal"
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
                        v-model="editingTrecho.estaca_final_inteiro"
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
                        v-model="editingTrecho.estaca_final_decimal"
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

            <template v-else>
              <q-input
                v-model="editingTrecho.descricao"
                label="Descrição do Ponto"
                type="textarea"
                outlined
                :rules="[val => editingTrecho.tipo !== 'pontual' || !!val || 'Campo obrigatório']"
              />
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
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const obraId = route.params.id
const obra = ref(null)
const trechos = ref([])
const loading = ref(true)
const saving = ref(false)
const showDialog = ref(false)

const editingTrecho = ref({
  id: null,
  tipo: 'trecho',
  nome: '',
  estaca_inicial_inteiro: '',
  estaca_inicial_decimal: '',
  estaca_final_inteiro: '',
  estaca_final_decimal: '',
  descricao: '',
  obra_id: obraId,
  usuario_cadastro: null
})

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

const loadTrechos = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('localizacao_obra')
      .select('*')
      .eq('obra_id', obraId)
    
    if (error) throw error
    trechos.value = data
  } catch (error) {
    console.error('Erro ao carregar trechos:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar trechos'
    })
  } finally {
    loading.value = false
  }
}

const openDialog = (trecho = null) => {
  if (trecho) {
    const estacaInicial = parseEstaca(trecho.estaca_inicial)
    const estacaFinal = parseEstaca(trecho.estaca_final)
    
    editingTrecho.value = {
      ...trecho,
      estaca_inicial_inteiro: estacaInicial.inteiro,
      estaca_inicial_decimal: estacaInicial.decimal,
      estaca_final_inteiro: estacaFinal.inteiro,
      estaca_final_decimal: estacaFinal.decimal
    }
  } else {
    editingTrecho.value = {
      id: null,
      tipo: 'trecho',
      nome: '',
      estaca_inicial_inteiro: '',
      estaca_inicial_decimal: '',
      estaca_final_inteiro: '',
      estaca_final_decimal: '',
      descricao: '',
      obra_id: obraId,
      usuario_cadastro: null
    }
  }
  showDialog.value = true
}

const onSubmit = async () => {
  try {
    saving.value = true
    
    const { 
      id, 
      estaca_inicial_inteiro,
      estaca_inicial_decimal,
      estaca_final_inteiro,
      estaca_final_decimal,
      ...trechoData 
    } = editingTrecho.value
    
    // Adicionar usuário de cadastro
    const { data: { user } } = await supabase.auth.getUser()
    trechoData.usuario_cadastro = user.email
    
    // Limpar campos não utilizados baseado no tipo
    if (trechoData.tipo === 'trecho') {
      trechoData.descricao = null
      trechoData.estaca_inicial = formatEstaca(estaca_inicial_inteiro, estaca_inicial_decimal)
      trechoData.estaca_final = formatEstaca(estaca_final_inteiro, estaca_final_decimal)
    } else {
      trechoData.estaca_inicial = null
      trechoData.estaca_final = null
    }
    
    let error
    if (id) {
      // Atualizar localização existente
      const { error: updateError } = await supabase
        .from('localizacao_obra')
        .update(trechoData)
        .eq('id', id)
      error = updateError
    } else {
      // Criar nova localização
      const { error: insertError } = await supabase
        .from('localizacao_obra')
        .insert([trechoData])
      error = insertError
    }
    
    if (error) throw error
    
    await loadTrechos()
    showDialog.value = false
    
    $q.notify({
      type: 'positive',
      message: `Localização ${id ? 'atualizada' : 'cadastrada'} com sucesso!`
    })
  } catch (error) {
    console.error('Erro ao salvar localização:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao salvar localização'
    })
  } finally {
    saving.value = false
  }
}

const confirmDelete = (trecho) => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: `Tem certeza que deseja excluir o trecho "${trecho.nome}"?`,
    ok: {
      label: 'Excluir',
      color: 'negative'
    },
    cancel: {
      label: 'Cancelar',
      flat: true
    },
    persistent: true
  }).onOk(async () => {
    try {
      const { error } = await supabase
        .from('localizacao_obra')
        .delete()
        .eq('id', trecho.id)
      
      if (error) throw error
      
      await loadTrechos()
      
      $q.notify({
        type: 'positive',
        message: 'Trecho excluído com sucesso!'
      })
    } catch (error) {
      console.error('Erro ao excluir trecho:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir trecho'
      })
    }
  })
}

onMounted(async () => {
  await loadObra()
  await loadTrechos()
})
</script>

<style scoped>
.dialog-card {
  width: 100%;
  max-width: 500px;
  margin: 20px;
}

@media (max-width: 599px) {
  .dialog-card {
    margin: 10px;
  }
}
</style> 