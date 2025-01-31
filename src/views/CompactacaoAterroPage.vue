<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" to="/ensaios" class="q-mr-sm" />
          <h5 class="q-my-none">Compactação Aterro 95%</h5>
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Card para Controle do Material -->
      <div class="col-12 col-sm-6">
        <q-card class="ensaio-card cursor-pointer" @click="$router.push('/ensaios/compactacao-aterro/controle-material')">
          <q-card-section class="bg-primary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">Controle do Material</div>
              </div>
              <div class="col-auto">
                <q-icon name="science" size="32px" />
              </div>
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="primary" icon-right="arrow_forward" label="Ver Ensaios" />
          </q-card-actions>
        </q-card>
      </div>

      <!-- Card para Controle da Produção -->
      <div class="col-12 col-sm-6">
        <q-card class="ensaio-card bg-grey-2">
          <q-card-section class="column items-center justify-center" style="min-height: 140px;">
            <q-icon name="construction" size="48px" color="grey-7" />
            <div class="text-h6 text-grey-7 q-mt-sm">Controle da Produção</div>
            <div class="text-caption text-grey q-mt-xs">Em breve</div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
// No additional logic needed for now
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
</style> 