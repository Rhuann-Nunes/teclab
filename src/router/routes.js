export default [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/HomePage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Início'
    }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginPage.vue'),
    meta: {
      requiresAuth: false,
      title: 'Login'
    }
  },
  {
    path: '/obras',
    name: 'Obras',
    component: () => import('@/views/ObrasPage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Obras'
    }
  },
  {
    path: '/apontamentos',
    name: 'Apontamentos',
    component: () => import('@/views/ApontamentosPage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Apontamentos'
    }
  },
  {
    path: '/apontamentos/dia-produtivo/:id',
    name: 'DiaProdutivo',
    component: () => import('@/views/DiaProdutivoPage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Dia Produtivo'
    }
  },
  {
    path: '/apontamentos/dia-produtivo/:diaProdutivoId/origem/:origemId/producao',
    name: 'Producao',
    component: () => import('@/views/ProducaoPage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Registrar Produção'
    }
  },
  {
    path: '/apontamentos/dia-produtivo/:diaProdutivoId/origem/:origemId/producao/:caminhaoId/viagens',
    name: 'ViagensProducao',
    component: () => import('@/views/ViagensProducaoPage.vue'),
    meta: {
      requiresAuth: true,
      title: 'Viagens do Caminhão'
    }
  }
]; 