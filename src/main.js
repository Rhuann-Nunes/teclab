import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { Quasar, Notify, Dialog } from 'quasar'
import router from './router'
import { useAuthStore } from '@/stores/auth'

// Import icon libraries
import '@quasar/extras/material-icons/material-icons.css'

// Import Quasar css
import 'quasar/dist/quasar.css'

// Leaflet CSS
import 'leaflet/dist/leaflet.css'

import App from './App.vue'

// Ensaios Form Components
import EnsaioMassaEspecificaForm from '@/components/ensaios/EnsaioMassaEspecificaForm.vue'
import EnsaioUmidadeOtimaForm from '@/components/ensaios/EnsaioUmidadeOtimaForm.vue'
import EnsaioLimiteLiquidezForm from '@/components/ensaios/EnsaioLimiteLiquidezForm.vue'
import EnsaioLimitePlasticidadeForm from '@/components/ensaios/EnsaioLimitePlasticidadeForm.vue'
import EnsaioIscForm from '@/components/ensaios/EnsaioIscForm.vue'

// Ensaios View Components
import EnsaioMassaEspecificaView from '@/components/ensaios/EnsaioMassaEspecificaView.vue'
import EnsaioUmidadeOtimaView from '@/components/ensaios/EnsaioUmidadeOtimaView.vue'
import EnsaioLimiteLiquidezView from '@/components/ensaios/EnsaioLimiteLiquidezView.vue'
import EnsaioLimitePlasticidadeView from '@/components/ensaios/EnsaioLimitePlasticidadeView.vue'
import EnsaioIscView from '@/components/ensaios/EnsaioIscView.vue'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(Quasar, {
  plugins: {
    Notify,
    Dialog
  },
  config: {
    brand: {
      primary: '#1976D2',
      secondary: '#26A69A',
      accent: '#9C27B0',
      dark: '#1D1D1D',
      positive: '#21BA45',
      negative: '#C10015',
      info: '#31CCEC',
      warning: '#F2C037'
    },
    notify: {}
  }
})

// Register Ensaios Form Components
app.component('ensaio-massa-especifica-form', EnsaioMassaEspecificaForm)
app.component('ensaio-umidade-otima-form', EnsaioUmidadeOtimaForm)
app.component('ensaio-limite-liquidez-form', EnsaioLimiteLiquidezForm)
app.component('ensaio-limite-plasticidade-form', EnsaioLimitePlasticidadeForm)
app.component('ensaio-isc-form', EnsaioIscForm)

// Register Ensaios View Components
app.component('ensaio-massa-especifica-view', EnsaioMassaEspecificaView)
app.component('ensaio-umidade-otima-view', EnsaioUmidadeOtimaView)
app.component('ensaio-limite-liquidez-view', EnsaioLimiteLiquidezView)
app.component('ensaio-limite-plasticidade-view', EnsaioLimitePlasticidadeView)
app.component('ensaio-isc-view', EnsaioIscView)

// Função de inicialização
async function init() {
  const authStore = useAuthStore(pinia)
  await authStore.checkUser()
  
  app.mount('#app')
}

// Chamar a função de inicialização
init().catch(error => {
  console.error('Erro durante a inicialização:', error)
})
