create table obra_selecionada (
  id uuid default uuid_generate_v4() primary key,
  usuario_id uuid not null,
  obra_id uuid not null,
  data_selecao timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Chaves estrangeiras
  constraint fk_usuario
    foreign key (usuario_id)
    references auth.users (id)
    on delete cascade,
    
  constraint fk_obra
    foreign key (obra_id)
    references obras (id)
    on delete cascade,
    
  -- Garantir que cada usuário só tenha uma obra selecionada
  constraint unique_usuario_obra_selecionada
    unique (usuario_id)
);

-- Criar índice para melhor performance
create index obra_selecionada_usuario_id_idx on obra_selecionada(usuario_id); 