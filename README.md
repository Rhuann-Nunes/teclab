# TecLab - Sistema de Gestão de Ensaios Laboratoriais

Sistema PWA (Progressive Web App) para gestão de ensaios laboratoriais de engenharia, desenvolvido com Vue 3 + Vite.

## Tecnologias Principais

- Vue 3 + Vite
- Quasar Framework
- Vue Router
- Pinia (Gerenciamento de Estado)
- ECharts (Gráficos)
- Leaflet (Mapas)
- Supabase (Backend)

## Funcionalidades

- Gestão de ensaios laboratoriais
- Dashboard com indicadores
- Relatórios e gráficos
- Suporte offline
- Interface responsiva
- Exportação de dados

## Pré-requisitos

- Node.js 18+
- NPM ou Yarn

## Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/teclab.git
cd teclab
```

2. Instale as dependências:
```bash
npm install
# ou
yarn
```

3. Configure as variáveis de ambiente:
```bash
cp .env.example .env
```
Edite o arquivo `.env` com suas configurações.

4. Inicie o servidor de desenvolvimento:
```bash
npm run dev
# ou
yarn dev
```

5. Para build de produção:
```bash
npm run build
# ou
yarn build
```

## Estrutura do Projeto

```
src/
  ├── assets/        # Recursos estáticos
  ├── components/    # Componentes Vue
  ├── composables/   # Composables Vue
  ├── router/        # Configuração de rotas
  ├── stores/        # Stores Pinia
  ├── utils/         # Utilitários
  └── views/         # Páginas/Views
```

## Contribuindo

1. Faça o fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## Contato

Seu Nome - [@seutwitter](https://twitter.com/seutwitter) - email@exemplo.com

Link do Projeto: [https://github.com/seu-usuario/teclab](https://github.com/seu-usuario/teclab)
