<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <h5 class="q-my-none">Disciplinas</h5>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Card para Terraplenagem -->
      <div class="col-12 col-sm-6 col-md-4">
        <q-card class="ensaio-card cursor-pointer" @click="$router.push('/ensaios/terraplenagem')">
          <q-card-section class="bg-primary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">Terraplenagem</div>
                <div class="text-subtitle2">Ensaios de Controle</div>
              </div>
              <div class="col-auto">
                <q-icon name="terrain" size="32px" />
              </div>
            </div>
          </q-card-section>
          
          <q-card-section class="q-pt-sm">
            <div class="text-caption text-grey-8">
              Conjunto de ensaios para controle de terraplenagem, incluindo compactação, 
              massa específica, umidade ótima e outros ensaios relacionados.
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="primary" icon-right="arrow_forward" label="Ver Ensaios" />
          </q-card-actions>
        </q-card>
      </div>

      <!-- Card para Pavimentação -->
      <div class="col-12 col-sm-6 col-md-4">
        <q-card class="ensaio-card cursor-pointer" @click="$router.push('/ensaios/pavimentacao')">
          <q-card-section class="bg-secondary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">Pavimentação</div>
                <div class="text-subtitle2">Ensaios de Controle</div>
              </div>
              <div class="col-auto">
                <q-icon name="layers" size="32px" />
              </div>
            </div>
          </q-card-section>
          
          <q-card-section class="q-pt-sm">
            <div class="text-caption text-grey-8">
              Conjunto de ensaios para controle de pavimentação, incluindo granulometria,
              compactação, ISC e outros ensaios relacionados.
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="secondary" icon-right="arrow_forward" label="Ver Ensaios" />
          </q-card-actions>
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
  transition: transform 0.2s;
}

.ensaio-card:hover {
  transform: translateY(-4px);
}

.ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style> 