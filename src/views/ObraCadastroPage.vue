<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" :to="`/obras/${obraId}`" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">Cadastro da Obra</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.nome }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulário de Cadastro -->
    <q-card>
      <q-card-section>
        <div class="row items-center">
          <div class="text-h6 col">Informações do Cadastro</div>
          <div class="col-auto">
            <q-btn round color="primary" icon="edit" size="sm" @click="editMode = true" v-if="!editMode">
              <q-tooltip>Editar Cadastro</q-tooltip>
            </q-btn>
          </div>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="loading" class="text-center q-pa-md">
          <q-spinner color="primary" size="2em" />
          <div class="text-grey q-mt-sm">Carregando informações...</div>
        </div>

        <div v-else>
          <!-- Modo Visualização -->
          <div v-if="!editMode">
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <div class="text-subtitle2 text-grey-8">Código da Obra</div>
                <div class="text-h6">{{ obra?.codigo }}</div>
              </div>
              <div class="col-12 col-sm-6">
                <div class="text-subtitle2 text-grey-8">Nome da Obra</div>
                <div class="text-h6">{{ obra?.nome }}</div>
              </div>
              <div class="col-12 col-sm-6">
                <div class="text-subtitle2 text-grey-8">Estado</div>
                <div class="text-h6">{{ obra?.estado }}</div>
              </div>
              <div class="col-12 col-sm-6">
                <div class="text-subtitle2 text-grey-8">Cidade</div>
                <div class="text-h6">{{ obra?.cidade }}</div>
              </div>
            </div>
          </div>

          <!-- Modo Edição -->
          <q-form v-else @submit="onSubmit" class="q-gutter-md">
            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="editingObra.codigo"
                  label="Código da Obra"
                  outlined
                  mask="#.###"
                  fill-mask
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="editingObra.nome"
                  label="Nome da Obra"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-select
                  v-model="editingObra.estado"
                  :options="estados"
                  label="Estado"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                  @update:model-value="loadCidades"
                  option-value="sigla"
                  option-label="nome"
                  emit-value
                  map-options
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-select
                  v-model="editingObra.cidade"
                  :options="cidades"
                  label="Cidade"
                  outlined
                  :rules="[val => !!val || 'Campo obrigatório']"
                  :disable="!editingObra.estado"
                  option-value="nome"
                  option-label="nome"
                  emit-value
                  map-options
                />
              </div>
            </div>

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat @click="cancelEdit" />
              <q-btn label="Salvar" type="submit" color="primary" :loading="saving" />
            </div>
          </q-form>
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from '@/lib/supabase'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const obraId = route.params.id
const obra = ref(null)
const loading = ref(true)
const saving = ref(false)
const editMode = ref(false)
const estados = ref([])
const cidades = ref([])

const editingObra = ref({
  codigo: '',
  nome: '',
  estado: null,
  cidade: null
})

const loadObra = async () => {
  try {
    loading.value = true
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
  } finally {
    loading.value = false
  }
}

const loadEstados = async () => {
  try {
    const response = await fetch('https://servicodados.ibge.gov.br/api/v1/localidades/estados')
    const data = await response.json()
    estados.value = data.sort((a, b) => a.nome.localeCompare(b.nome))
  } catch (error) {
    console.error('Erro ao carregar estados:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar estados'
    })
  }
}

const loadCidades = async () => {
  if (!editingObra.value.estado) return
  
  try {
    const response = await fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${editingObra.value.estado}/municipios`)
    const data = await response.json()
    cidades.value = data.sort((a, b) => a.nome.localeCompare(b.nome))
  } catch (error) {
    console.error('Erro ao carregar cidades:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao carregar cidades'
    })
  }
}

const startEdit = () => {
  editMode.value = true
  editingObra.value = {
    codigo: obra.value.codigo,
    nome: obra.value.nome,
    estado: obra.value.estado,
    cidade: obra.value.cidade
  }
  loadCidades()
}

const cancelEdit = () => {
  editMode.value = false
  editingObra.value = {
    codigo: '',
    nome: '',
    estado: null,
    cidade: null
  }
}

const onSubmit = async () => {
  try {
    saving.value = true
    
    const { error } = await supabase
      .from('obras')
      .update({
        codigo: editingObra.value.codigo,
        nome: editingObra.value.nome,
        estado: editingObra.value.estado,
        cidade: editingObra.value.cidade
      })
      .eq('id', obraId)
    
    if (error) throw error
    
    await loadObra()
    editMode.value = false
    
    $q.notify({
      type: 'positive',
      message: 'Obra atualizada com sucesso!'
    })
  } catch (error) {
    console.error('Erro ao atualizar obra:', error)
    $q.notify({
      type: 'negative',
      message: 'Erro ao atualizar obra'
    })
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await loadEstados()
  await loadObra()
})

// Watch para iniciar edição quando o botão é clicado
watch(editMode, (newValue) => {
  if (newValue) {
    startEdit()
  }
})
</script> 