<template>
  <div class="q-pa-md">
    <div class="row q-col-gutter-md">
      <div class="col-12">
        <div class="text-h6">Informações Básicas</div>
        <q-list>
          <q-item>
            <q-item-section>
              <q-item-label caption>Número do Ensaio</q-item-label>
              <q-item-label>{{ ensaio.numero_ensaio }}</q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label caption>Data do Ensaio</q-item-label>
              <q-item-label>{{ new Date(ensaio.data_ensaio).toLocaleDateString('pt-BR') }}</q-item-label>
            </q-item-section>
          </q-item>
          <q-item>
            <q-item-section>
              <q-item-label caption>Tipo de Localização</q-item-label>
              <q-item-label>{{ ensaio.tipo_localizacao === 'pontual' ? 'Pontual' : 'Trecho' }}</q-item-label>
            </q-item-section>
          </q-item>
          <template v-if="ensaio.tipo_localizacao === 'pontual'">
            <q-item>
              <q-item-section>
                <q-item-label caption>Estaca</q-item-label>
                <q-item-label>{{ ensaio.estaca }}</q-item-label>
              </q-item-section>
            </q-item>
          </template>
          <template v-else>
            <q-item>
              <q-item-section>
                <q-item-label caption>Estaca Inicial</q-item-label>
                <q-item-label>{{ ensaio.estaca_inicial }}</q-item-label>
              </q-item-section>
            </q-item>
            <q-item>
              <q-item-section>
                <q-item-label caption>Estaca Final</q-item-label>
                <q-item-label>{{ ensaio.estaca_final }}</q-item-label>
              </q-item-section>
            </q-item>
          </template>
        </q-list>
      </div>

      <div class="col-12">
        <div class="text-h6">Dados do Ensaio</div>
        <q-list>
          <q-item>
            <q-item-section>
              <q-item-label caption>Limite de Plasticidade</q-item-label>
              <q-item-label>{{ ensaio.dados_especificos?.limite_plasticidade }}%</q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  ensaio: {
    type: Object,
    required: true
  }
})
</script> 