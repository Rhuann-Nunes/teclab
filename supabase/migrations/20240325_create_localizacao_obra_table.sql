create type tipo_localizacao as enum ('trecho', 'pontual');

create table localizacao_obra (
  id uuid default uuid_generate_v4() primary key,
  obra_id uuid not null,
  tipo tipo_localizacao not null,
  nome varchar(255) not null,
  -- Para trechos estaqueados
  estaca_inicial numeric(10,3),
  estaca_final numeric(10,3),
  -- Para pontos específicos
  descricao text,
  data_cadastro timestamp with time zone default timezone('utc'::text, now()) not null,
  usuario_cadastro varchar(255) not null,
  
  -- Chaves estrangeiras
  constraint fk_obra
    foreign key (obra_id)
    references obras (id)
    on delete cascade,
    
  -- Validações
  constraint check_trecho_estacas
    check (
      (tipo = 'trecho' and estaca_inicial is not null and estaca_final is not null) or
      (tipo = 'pontual' and estaca_inicial is null and estaca_final is null)
    )
);

-- Criar índices para melhor performance
create index localizacao_obra_obra_id_idx on localizacao_obra(obra_id); 