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
          <h5 class="q-my-none">Serviços de Terraplenagem</h5>
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Card para Compactação de Aterro -->
      <div class="col-12 col-sm-6 col-md-4">
        <q-card class="ensaio-card cursor-pointer" @click="$router.push('/ensaios/terraplenagem/compactacao-aterro')">
          <q-card-section class="bg-primary text-white">
            <div class="row items-center no-wrap">
              <div class="col">
                <div class="text-h6 ellipsis">Compactação de Aterro</div>
                <div class="text-subtitle2">Controle de Compactação</div>
              </div>
              <div class="col-auto">
                <q-icon name="terrain" size="32px" />
              </div>
            </div>
          </q-card-section>
          
          <q-card-section class="q-pt-sm">
            <div class="text-caption text-grey-8">
              Controle tecnológico da compactação de aterros, incluindo ensaios de massa específica,
              umidade ótima e grau de compactação.
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat color="primary" icon-right="arrow_forward" label="Acessar" />
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