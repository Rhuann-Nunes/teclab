<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <div class="row items-center">
          <q-btn flat round icon="arrow_back" color="primary" to="/obras" class="q-mr-sm" />
          <div>
            <h5 class="q-my-none">{{ obra?.nome }}</h5>
            <div class="text-subtitle2 text-grey-7">{{ obra?.codigo }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Informações Gerais -->
      <div class="col-12 col-md-4">
        <q-card>
          <q-card-section>
            <div class="text-h6">Informações Gerais</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <q-list>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Localização</q-item-label>
                  <q-item-label>{{ obra?.cidade }} - {{ obra?.estado }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Data de Cadastro</q-item-label>
                  <q-item-label>{{ obra?.data_cadastro ? new Date(obra.data_cadastro).toLocaleDateString('pt-BR') : '' }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label caption>Usuário Cadastro</q-item-label>
                  <q-item-label>{{ obra?.usuario_cadastro }}</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>

      <!-- Menu de Gerenciamento -->
      <div class="col-12 col-md-8">
        <div class="row q-col-gutter-md">
          <!-- Usuários da Obra -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageUsers">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="group" color="info" size="32px" class="q-mr-sm" />
                      Usuários da Obra
                    </div>
                    <div class="text-subtitle2">Gerenciar usuários</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Cadastro da Obra -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="editObra">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="edit" color="warning" size="32px" class="q-mr-sm" />
                      Cadastro da Obra
                    </div>
                    <div class="text-subtitle2">Gerenciar Cadastro</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Trechos da Obra -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageSections">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="map" color="positive" size="32px" class="q-mr-sm" />
                      Trechos da Obra
                    </div>
                    <div class="text-subtitle2">Gerenciar localizações</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Serviços da Obra -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageServices">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="build" color="secondary" size="32px" class="q-mr-sm" />
                      Serviços da Obra
                    </div>
                    <div class="text-subtitle2">Gerenciar serviços</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Check-List de Ensaios -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageTestRules">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="rule" color="info" size="32px" class="q-mr-sm" />
                      Check-List de Ensaios
                    </div>
                    <div class="text-subtitle2">Gerenciar regras</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Medições da Obra -->
          <div class="col-12 col-sm-6">
            <q-card class="menu-card cursor-pointer" @click="manageMedicoes">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="assignment" color="primary" size="32px" class="q-mr-sm" />
                      Medições da Obra
                    </div>
                    <div class="text-subtitle2">Gerenciar medições</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Excluir Obra -->
          <div class="col-12">
            <q-card class="menu-card cursor-pointer bg-negative text-white" @click="confirmDelete">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">
                      <q-icon name="delete" size="32px" class="q-mr-sm" />
                      Excluir Obra
                    </div>
                    <div class="text-subtitle2">Remover permanentemente</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </div>
    </div>

    <!-- Manter os diálogos existentes -->
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabase'
import { useQuasar, Dialog } from 'quasar'
import { metrosParaEstaca } from '@/utils/estacas'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()
const obra = ref(null)

const loadObra = async () => {
  try {
    const { data, error } = await supabase
      .from('obras')
      .select('*, localizacao_obra(*)')
      .eq('id', route.params.id)
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

const manageUsers = () => {
  router.push(`/obras/${route.params.id}/usuarios`)
}

const editObra = () => {
  router.push(`/obras/${route.params.id}/cadastro`)
}

const manageSections = () => {
  router.push(`/obras/${route.params.id}/trechos`)
}

const manageServices = () => {
  router.push(`/obras/${route.params.id}/servicos`)
}

const manageTestRules = () => {
  router.push(`/obras/${route.params.id}/regras-ensaios`)
}

const manageMedicoes = () => {
  router.push(`/obras/${route.params.id}/medicoes`)
}

const confirmDelete = () => {
  $q.dialog({
    title: 'Confirmar Exclusão',
    message: 'Esta ação não pode ser desfeita. Digite "EXCLUIR" para confirmar.',
    prompt: {
      model: '',
      type: 'text'
    },
    cancel: true,
    persistent: true,
    ok: {
      label: 'Excluir',
      color: 'negative',
      flat: true,
      disable: true
    },
    cancel: {
      label: 'Cancelar',
      flat: true
    },
    style: 'max-width: 400px',
    onInput: (value) => {
      const okBtn = document.querySelector('.q-dialog .q-btn--ok')
      if (okBtn) {
        okBtn.disabled = value !== 'EXCLUIR'
      }
    }
  }).onOk(async (data) => {
    if (data !== 'EXCLUIR') {
      $q.notify({
        type: 'warning',
        message: 'Confirmação inválida'
      })
      return
    }

    try {
      const { error } = await supabase
        .from('obras')
        .delete()
        .eq('id', obra.value.id)
      
      if (error) throw error
      
      $q.notify({
        type: 'positive',
        message: 'Obra excluída com sucesso!'
      })
      
      router.push('/obras')
    } catch (error) {
      console.error('Erro ao excluir obra:', error)
      $q.notify({
        type: 'negative',
        message: 'Erro ao excluir obra'
      })
    }
  })
}

onMounted(() => {
  loadObra()
})
</script>

<style scoped>
.menu-card {
  transition: all 0.2s ease;
}

.menu-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 25px 0 rgba(0, 0, 0, 0.1);
}
</style> 