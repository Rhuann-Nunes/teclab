<template>
  <q-page padding>
    <div class="row q-col-gutter-md">
      <div class="col-12 col-md-4">
        <q-card class="dashboard-card">
          <q-card-section>
            <div class="text-h6">Ensaios Pendentes</div>
            <div class="text-h4 q-mt-sm text-primary">0</div>
          </q-card-section>
        </q-card>
      </div>

      <div class="col-12 col-md-4">
        <q-card class="dashboard-card">
          <q-card-section>
            <div class="text-h6">Ensaios em Andamento</div>
            <div class="text-h4 q-mt-sm text-orange">0</div>
          </q-card-section>
        </q-card>
      </div>

      <div class="col-12 col-md-4">
        <q-card class="dashboard-card">
          <q-card-section>
            <div class="text-h6">Ensaios Concluídos</div>
            <div class="text-h4 q-mt-sm text-positive">0</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="row q-col-gutter-md q-mt-md">
      <div class="col-12 col-md-8">
        <q-card>
          <q-card-section>
            <div class="text-h6">Últimos Ensaios</div>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <div class="text-grey-6 text-center q-pa-lg">
              Nenhum ensaio registrado
            </div>
          </q-card-section>
        </q-card>
      </div>

      <div class="col-12 col-md-4">
        <q-card>
          <q-card-section>
            <div class="text-h6">Ações Rápidas</div>
          </q-card-section>

          <q-separator />

          <q-card-section>
            <div class="q-gutter-y-sm">
              <q-btn
                color="primary"
                icon="add"
                label="Novo Ensaio"
                class="full-width"
                to="/ensaios"
              />
              <q-btn
                color="secondary"
                icon="assessment"
                label="Ver Relatórios"
                class="full-width"
                to="/relatorios"
              />
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
// Component logic will be added as needed
</script>

<style scoped>
.dashboard-card {
  height: 100%;
}
</style> 