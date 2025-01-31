-- Tabela de entradas dos ensaios de LL e LP
create table limite_consistencia_entradas (
  id uuid default uuid_generate_v4() primary key,
  ambiente_id uuid references ambientes_compactacao_aterro(id),
  data_ensaio date not null,
  numero_ensaio text,
  nome_amostra text,
  observacoes text,
  usuario_cadastro text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  dados_especificos jsonb
);

-- Tabela de resultados dos ensaios de LL e LP
create table limite_consistencia_resultados (
  id uuid default uuid_generate_v4() primary key,
  id_entrada uuid references limite_consistencia_entradas(id),
  limite_liquidez numeric,
  limite_plasticidade numeric,
  indice_plasticidade numeric,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
); 