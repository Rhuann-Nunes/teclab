<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn
            flat
            round
            icon="arrow_back"
            color="primary"
            @click="$router.push('/ensaios')"
            class="q-mr-sm"
          />
          <h5 class="q-my-none">Ensaios de Pavimentação</h5>
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Granulometria -->
      <div class="col-12 col-sm-6 col-md-4">
        <q-card class="ensaio-card cursor-pointer">
          <q-card-section class="bg-secondary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">Granulometria</div>
                <div class="text-subtitle2">NBR 7181</div>
              </div>
              <div class="col-auto">
                <q-icon name="grain" size="32px" />
              </div>
            </div>
          </q-card-section>
          
          <q-card-section class="q-pt-sm">
            <div class="text-caption text-grey-8">
              Ensaio para determinação da distribuição granulométrica dos materiais.
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="secondary" icon-right="add" label="Novo Ensaio" />
          </q-card-actions>
        </q-card>
      </div>

      <!-- ISC -->
      <div class="col-12 col-sm-6 col-md-4">
        <q-card class="ensaio-card cursor-pointer">
          <q-card-section class="bg-secondary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">ISC</div>
                <div class="text-subtitle2">NBR 9895</div>
              </div>
              <div class="col-auto">
                <q-icon name="speed" size="32px" />
              </div>
            </div>
          </q-card-section>
          
          <q-card-section class="q-pt-sm">
            <div class="text-caption text-grey-8">
              Índice de Suporte Califórnia (CBR) para avaliação da resistência do solo.
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="secondary" icon-right="add" label="Novo Ensaio" />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<style scoped>
.ensaio-card {
  height: 100%;
  transition: transform 0.2s;
}

.ensaio-card:hover {
  transform: translateY(-4px);
}
</style> 