<!-- LocalizacaoObraForm.vue -->
<template>
  <div class="col-12">
    <div class="text-subtitle1 q-mb-sm">Localizações</div>
    <q-list bordered separator>
      <q-item v-for="(loc, index) in modelValue" :key="index">
        <q-item-section>
          <q-item-label>{{ loc.tipo === 'trecho' ? 'Trecho' : 'Ponto' }}</q-item-label>
          <q-item-label caption>
            {{ formatLocalizacao(loc) }}
          </q-item-label>
        </q-item-section>
        <q-item-section side>
          <q-btn flat round dense icon="delete" color="negative" @click="removeLocalizacao(index)" />
        </q-item-section>
      </q-item>
    </q-list>
    
    <q-btn 
      color="primary" 
      icon="add" 
      label="Adicionar Localização" 
      class="q-mt-sm"
      @click="showLocalizacaoDialog = true" 
    />

    <!-- Dialog para adicionar localização -->
    <q-dialog v-model="showLocalizacaoDialog">
      <q-card style="min-width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Nova Localização</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit="addLocalizacao" class="q-gutter-md">
            <q-select
              v-model="novaLocalizacao.tipo"
              :options="[
                { label: 'Trecho Estaqueado', value: 'trecho' },
                { label: 'Ponto Específico', value: 'pontual' }
              ]"
              label="Tipo"
              outlined
              emit-value
              map-options
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <q-input
              v-model="novaLocalizacao.nome"
              label="Nome"
              outlined
              :rules="[val => !!val || 'Campo obrigatório']"
            />

            <template v-if="novaLocalizacao.tipo === 'trecho'">
              <div class="row q-col-gutter-sm">
                <div class="col-6">
                  <q-input
                    v-model="novaLocalizacao.estaca_inicial"
                    label="Estaca Inicial"
                    outlined
                    mask="#####+ ##"
                    :rules="[val => !!val || 'Campo obrigatório']"
                  />
                </div>
                <div class="col-6">
                  <q-input
                    v-model="novaLocalizacao.estaca_final"
                    label="Estaca Final"
                    outlined
                    mask="#####+ ##"
                    :rules="[val => !!val || 'Campo obrigatório']"
                  />
                </div>
              </div>
            </template>

            <template v-else>
              <q-input
                v-model="novaLocalizacao.descricao"
                label="Descrição"
                type="textarea"
                outlined
                :rules="[val => !!val || 'Campo obrigatório']"
              />
            </template>

            <div class="row justify-end q-gutter-sm">
              <q-btn label="Cancelar" color="negative" flat v-close-popup />
              <q-btn label="Adicionar" type="submit" color="primary" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const showLocalizacaoDialog = ref(false)
const novaLocalizacao = ref({
  tipo: 'trecho',
  nome: '',
  estaca_inicial: '',
  estaca_final: '',
  descricao: ''
})

const formatLocalizacao = (loc) => {
  if (loc.tipo === 'trecho') {
    return `Estaca ${loc.estaca_inicial} até Estaca ${loc.estaca_final}`
  }
  return loc.descricao
}

const addLocalizacao = () => {
  const localizacoes = [...props.modelValue]
  localizacoes.push({...novaLocalizacao.value})
  emit('update:modelValue', localizacoes)
  
  showLocalizacaoDialog.value = false
  novaLocalizacao.value = {
    tipo: 'trecho',
    nome: '',
    estaca_inicial: '',
    estaca_final: '',
    descricao: ''
  }
}

const removeLocalizacao = (index) => {
  const localizacoes = [...props.modelValue]
  localizacoes.splice(index, 1)
  emit('update:modelValue', localizacoes)
}
</script> 