<template>
  <div>
    <q-form @submit="onSubmit" class="q-gutter-md">
      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <q-input
            v-model.number="formData.indice_suporte_california"
            label="Índice de Suporte Califórnia (%)"
            type="number"
            outlined
            :rules="[val => val !== null && val !== undefined || 'Campo obrigatório']"
          />
        </div>
        <div class="col-12 col-md-6">
          <q-input
            v-model.number="formData.expansao"
            label="Expansão (%)"
            type="number"
            outlined
            :rules="[val => val !== null && val !== undefined || 'Campo obrigatório']"
          />
        </div>
      </div>

      <div class="row justify-end q-mt-md">
        <q-btn label="Voltar" color="negative" flat @click="$emit('back')" />
        <q-btn label="Salvar" type="submit" color="primary" class="q-ml-sm" />
      </div>
    </q-form>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue', 'submit', 'back'])

const formData = ref({
  indice_suporte_california: null,
  expansao: null,
  ...props.modelValue
})

watch(formData, (newValue) => {
  emit('update:modelValue', newValue)
}, { deep: true })

const onSubmit = () => {
  emit('submit')
}
</script> 