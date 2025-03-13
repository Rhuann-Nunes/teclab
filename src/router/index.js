import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

// Função para verificar permissões de perfil
const checkRole = (requiredRoles, userRole) => {
  if (!requiredRoles) return true
  if (!userRole) return false
  
  const roleHierarchy = {
    master: 3,
    administrador: 2,
    produtor: 1
  }

  const userRoleLevel = roleHierarchy[userRole]
  const requiredRoleLevel = Math.max(...requiredRoles.map(role => roleHierarchy[role] || 0))

  return userRoleLevel >= requiredRoleLevel
}

const routes = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'home',
        component: () => import('@/views/HomePage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios',
        name: 'ensaios',
        component: () => import('@/views/EnsaiosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem',
        name: 'ensaios-terraplenagem',
        component: () => import('@/views/EnsaiosTerraplenagemPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro',
        name: 'ensaios-compactacao-aterro',
        component: () => import('@/views/CompactacaoAterroPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod',
        name: 'ensaios-compactacao-aterro-prod',
        component: () => import('@/views/EnsaiosCompactacaoAterroProdPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/lista',
        name: 'ensaios-granulometria-lista',
        component: () => import('@/views/GranulometriaListPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/novo',
        name: 'ensaios-granulometria-novo',
        component: () => import('@/views/GranulometriaPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/granulometria/visualizar/:id',
        name: 'ensaios-granulometria-visualizar',
        component: () => import('@/views/GranulometriaPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/lista',
        name: 'ensaios-limite-consistencia-lista',
        component: () => import('@/views/LimiteConsistenciaListPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/novo',
        name: 'ensaios-limite-consistencia-novo',
        component: () => import('@/views/LimiteConsistenciaPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/limite-consistencia/visualizar/:id',
        name: 'ensaios-limite-consistencia-visualizar',
        component: () => import('@/views/LimiteConsistenciaPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/lista',
        name: 'ensaios-cbr-lista',
        component: () => import('@/views/CbrListPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/novo',
        name: 'ensaios-cbr-novo',
        component: () => import('@/views/CbrPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/cbr/visualizar/:id',
        name: 'ensaios-cbr-visualizar',
        component: () => import('@/views/CbrPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/lista',
        name: 'ensaios-compactacao-lista',
        component: () => import('@/views/CompactacaoListPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/novo',
        name: 'ensaios-compactacao-novo',
        component: () => import('@/views/CompactacaoPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/compactacao/visualizar/:id',
        name: 'ensaios-compactacao-visualizar',
        component: () => import('@/views/CompactacaoPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/lista',
        name: 'ensaios-densidade-insitu-lista',
        component: () => import('@/views/DensidadeInsituListPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/novo',
        name: 'ensaios-densidade-insitu-novo',
        component: () => import('@/views/DensidadeInsituPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/terraplenagem/compactacao-aterro/ensaios-prod/densidade-insitu/:id',
        name: 'ensaios-densidade-insitu-visualizar',
        component: () => import('@/views/DensidadeInsituPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ensaios/pavimentacao',
        name: 'ensaios-pavimentacao',
        component: () => import('@/views/EnsaiosPavimentacaoPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/login',
        name: 'login',
        component: () => import('@/views/LoginPage.vue'),
        meta: { requiresAuth: false }
      },
      {
        path: '/relatorios',
        name: 'relatorios',
        component: () => import('@/views/RelatoriosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/usuarios',
        component: () => import('@/views/UsuariosPage.vue'),
        meta: { 
          requiresAuth: true,
          roles: ['master', 'administrador']
        }
      },
      {
        path: '/obras',
        name: 'obras',
        component: () => import('@/views/ObrasPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id',
        name: 'obra-details',
        component: () => import('@/views/ObraDetailsPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/usuarios',
        name: 'obra-users',
        component: () => import('@/views/ObraUsersPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/cadastro',
        name: 'obra-cadastro',
        component: () => import('@/views/ObraCadastroPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/trechos',
        name: 'obra-trechos',
        component: () => import('@/views/ObraTrechosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/servicos',
        name: 'obra-servicos',
        component: () => import('@/views/ObraServicosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/regras-ensaios',
        name: 'obra-regras-ensaios',
        component: () => import('@/views/ObraRegrasEnsaiosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:id/medicoes',
        name: 'obra-medicoes',
        component: () => import('@/views/ObraMedicoesPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:obraId/medicoes/:medicaoId',
        name: 'medicao-details',
        component: () => import('@/views/MedicaoDetailsPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/obras/:obraId/medicoes/:medicaoId/servicos',
        name: 'medicao-servicos',
        component: () => import('@/views/MedicaoServicosPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'apontamentos',
        name: 'apontamentos',
        component: () => import('@/views/ApontamentoViagemPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'apontamentos/dia-produtivo/:id',
        name: 'dia-produtivo',
        component: () => import('@/views/DiaProdutivoPage.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'apontamentos/dia-produtivo/:diaProdutivoId/origem/:origemId/producao',
        name: 'producao',
        component: () => import('@/views/ProducaoPage.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  await authStore.checkUser()
  
  const userRole = authStore.user?.user_metadata?.role || 'produtor'
  
  if (to.meta.requiresAuth && !authStore.user) {
    next('/login')
  } else if (to.meta.roles && !checkRole(to.meta.roles, userRole)) {
    next('/')
  } else if (to.path === '/login' && authStore.user) {
    next('/')
  } else {
    next()
  }
})

export default router 