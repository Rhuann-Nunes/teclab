<template>
  <div class="row justify-center items-center" style="min-height: 100vh; background: #f5f5f5;">
    <!-- Dialog de transição -->
    <q-dialog v-model="showSuccessDialog" persistent>
      <q-card class="text-center" style="min-width: 300px">
        <q-card-section>
          <q-avatar icon="check_circle" color="positive" text-color="white" size="48px" />
        </q-card-section>

        <q-card-section>
          <div class="text-h6">Cadastro realizado com sucesso!</div>
          <div class="text-subtitle2 q-mt-sm">Confirme seu e-mail e faça o login</div>
          <div class="text-subtitle1 text-primary q-mt-md">
            Redirecionando em {{ countdown }}s
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>

    <div class="col-12 col-sm-8 col-md-6 col-lg-4">
      <q-card class="login-card">
        <q-card-section class="text-center q-pt-xl">
          <h4 class="text-h3 text-weight-bold text-primary q-mb-sm">TECLAB</h4>
          <p class="text-subtitle1 text-grey-8">Sistema de Gestão de Ensaios Laboratoriais</p>
        </q-card-section>

        <q-card-section>
          <q-tabs
            v-model="tab"
            dense
            class="text-grey-8"
            active-color="primary"
            indicator-color="primary"
            align="justify"
            narrow-indicator
          >
            <q-tab name="login" label="Login" />
            <q-tab name="register" label="Cadastro" />
          </q-tabs>

          <q-tab-panels v-model="tab" animated class="q-mt-md">
            <q-tab-panel name="login">
              <q-form @submit="handleLogin" class="q-gutter-md">
                <q-input
                  v-model="loginForm.email"
                  label="E-mail"
                  type="email"
                  outlined
                  :rules="[val => !!val || 'E-mail é obrigatório']"
                />

                <q-input
                  v-model="loginForm.password"
                  label="Senha"
                  :type="isPwd ? 'password' : 'text'"
                  outlined
                  :rules="[val => !!val || 'Senha é obrigatória']"
                >
                  <template v-slot:append>
                    <q-icon
                      :name="isPwd ? 'visibility_off' : 'visibility'"
                      class="cursor-pointer"
                      @click="isPwd = !isPwd"
                    />
                  </template>
                </q-input>

                <div>
                  <q-btn
                    label="Entrar"
                    type="submit"
                    color="primary"
                    class="full-width"
                    :loading="authStore.loading"
                  />
                </div>
              </q-form>
            </q-tab-panel>

            <q-tab-panel name="register">
              <q-form @submit="handleRegister" class="q-gutter-md">
                <q-input
                  v-model="registerForm.displayName"
                  label="Nome"
                  outlined
                  :rules="[val => !!val || 'Nome é obrigatório']"
                />

                <q-input
                  v-model="registerForm.email"
                  label="E-mail"
                  type="email"
                  outlined
                  :rules="[val => !!val || 'E-mail é obrigatório']"
                />

                <q-input
                  v-model="registerForm.phone"
                  label="Telefone"
                  outlined
                  mask="(##) #####-####"
                  :rules="[val => !!val || 'Telefone é obrigatório']"
                />

                <q-input
                  v-model="registerForm.password"
                  label="Senha"
                  :type="isPwd ? 'password' : 'text'"
                  outlined
                  :rules="[
                    val => !!val || 'Senha é obrigatória',
                    val => val.length >= 6 || 'Mínimo de 6 caracteres'
                  ]"
                >
                  <template v-slot:append>
                    <q-icon
                      :name="isPwd ? 'visibility_off' : 'visibility'"
                      class="cursor-pointer"
                      @click="isPwd = !isPwd"
                    />
                  </template>
                </q-input>

                <div>
                  <q-btn
                    label="Cadastrar"
                    type="submit"
                    color="primary"
                    class="full-width"
                    :loading="authStore.loading"
                  />
                </div>
              </q-form>
            </q-tab-panel>
          </q-tab-panels>
        </q-card-section>
      </q-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()

const tab = ref('login')
const isPwd = ref(true)
const showSuccessDialog = ref(false)
const countdown = ref(5)
let countdownTimer = null

const loginForm = reactive({
  email: '',
  password: ''
})

const registerForm = reactive({
  displayName: '',
  email: '',
  phone: '',
  password: ''
})

const startCountdown = () => {
  countdown.value = 5
  showSuccessDialog.value = true
  
  countdownTimer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(countdownTimer)
      showSuccessDialog.value = false
      tab.value = 'login'
    }
  }, 1000)
}

const handleLogin = async () => {
  try {
    await authStore.login(loginForm.email, loginForm.password)
    router.push('/')
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: error.message || 'Erro ao fazer login. Verifique suas credenciais.'
    })
  }
}

const handleRegister = async () => {
  try {
    await authStore.register(
      registerForm.email,
      registerForm.password,
      registerForm.displayName,
      registerForm.phone
    )
    startCountdown()
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: error.message || 'Erro ao realizar cadastro.'
    })
  }
}

// Limpar o timer quando o componente for destruído
onBeforeUnmount(() => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
})
</script>

<style scoped>
.login-card {
  width: 100%;
  max-width: 480px;
  margin: 2rem auto;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 25px rgba(0, 0, 0, 0.05);
}

.q-input {
  margin-bottom: 1.5rem;
}

.q-btn {
  height: 48px;
  font-size: 16px;
  text-transform: none;
}

:deep(.q-field) {
  height: 56px;
}

:deep(.q-field__control) {
  height: 56px;
}

:deep(.q-field__marginal) {
  height: 56px;
}
</style> 