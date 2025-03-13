# Documentação do Módulo de Apontamentos - TecLab

## Visão Geral
O módulo de apontamentos foi desenvolvido para gerenciar o registro de viagens de caminhões em obras, permitindo o controle de produção tanto em ambiente rodoviário quanto urbano. O sistema possui suporte para operação offline, mantendo os dados em cache até que haja conexão disponível.

## Estrutura do Frontend

### 1. Páginas Principais

#### ApontamentoViagemPage.vue
- Listagem de dias produtivos
- Criação de novos dias produtivos
- Filtros por medição
- Exibição do total de viagens por dia

#### DiaProdutivoPage.vue
- Listagem de origens cadastradas
- Adição de novas origens
- Exibição de informações como:
  - Nome da origem
  - Tipo (rodoviário/urbano)
  - Material
  - DT Fixo
  - Dados de cadastro

#### ProducaoPage.vue
- Registro de viagens por caminhão
- Listagem de caminhões em operação
- Adição de novos caminhões
- Campos para registro:
  - Estaca de origem
  - Estaca de destino
  - Contador de viagens
- Visualização do histórico de viagens

### 2. Componentes e Funcionalidades

#### Gestão de Cache
```javascript
// Funções para gerenciamento do cache local
const loadCachedData = () => {
  const cachedData = localStorage.getItem('viagensCache')
  return cachedData ? JSON.parse(cachedData) : {}
}

const saveCachedData = (data) => {
  localStorage.setItem('viagensCache', JSON.stringify(data))
}
```

#### Estratégia Offline
- Dados são armazenados no localStorage
- Sincronização automática quando houver conexão
- Manutenção do estado entre sessões
- Preservação de contadores e histórico

## Estrutura do Backend

### 1. Tabelas Principais

#### mvt_carreteiro
- Registro principal da movimentação
- Dados do dia produtivo
- Informações do chefe de equipe
- Valores e medições

#### mvt_carreteiro_rodoviario
- Registros específicos para obras rodoviárias
- Controle de estacas
- Posicionamento na pista
- Cálculos de DT

#### mvt_carreteiro_urbana
- Registros específicos para obras urbanas
- Controle por bairro/rua
- Posicionamento urbano
- Cálculos específicos

### 2. Campos Importantes para Sincronização

```sql
-- Campos de controle de sincronização
carreteiro_cadastrador_dh TIMESTAMP
carreteiro_alterador_dh TIMESTAMP
carreteiro_deletado ENUM('S','N')
```

## Implementação da Estratégia Offline

### 1. Estrutura de Cache
```javascript
{
  "viagensCache": {
    "caminhaoId": {
      "viagens": number,
      "ultima_origem": string,
      "registros": [
        {
          "id": number,
          "data_hora": string,
          "origem": string,
          "destino": string
        }
      ],
      "pendingSync": boolean
    }
  }
}
```

### 2. Processo de Sincronização

1. **Coleta de Dados**
   - Armazenar registros no cache local
   - Marcar registros como pendentes de sincronização

2. **Detecção de Conexão**
   ```javascript
   window.addEventListener('online', sincronizarDados)
   ```

3. **Envio ao Backend**
   - Identificar registros pendentes
   - Enviar em lote quando houver conexão
   - Atualizar status após confirmação

4. **Tratamento de Conflitos**
   - Verificar timestamps
   - Resolver conflitos por política de "último vence"
   - Manter log de sincronização

## Próximos Passos

1. **Backend**
   - Implementar APIs de sincronização
   - Criar endpoints para cada tipo de operação
   - Desenvolver lógica de resolução de conflitos

2. **Frontend**
   - Implementar service workers para offline
   - Melhorar feedback de sincronização
   - Adicionar indicadores de status offline/online

3. **Banco de Dados**
   - Criar índices para otimização
   - Implementar controle de versão de registros
   - Adicionar campos de controle de sincronização

## Considerações de Segurança

1. **Autenticação**
   - Manter tokens seguros no cache
   - Implementar renovação automática
   - Validar permissões offline

2. **Dados**
   - Criptografar dados sensíveis no cache
   - Limitar tamanho do cache
   - Implementar limpeza periódica

## Conclusão

O módulo de apontamentos foi projetado para funcionar de forma robusta tanto online quanto offline, priorizando a experiência do usuário e a integridade dos dados. A estratégia de cache permite operação contínua mesmo sem conexão, enquanto o processo de sincronização garante que todos os dados cheguem ao servidor quando houver conectividade.
