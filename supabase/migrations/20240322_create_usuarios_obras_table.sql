create table usuarios_obras (
  id uuid default uuid_generate_v4() primary key,
  usuario_id uuid not null,
  obra_id uuid not null,
  data_vinculo timestamp with time zone default timezone('utc'::text, now()) not null,
  usuario_cadastro varchar(255) not null,
  
  -- Chaves estrangeiras
  constraint fk_obra
    foreign key (obra_id)
    references obras (id)
    on delete cascade,
    
  -- Garantir que não haja duplicatas de vínculos
  constraint unique_usuario_obra
    unique (usuario_id, obra_id)
);

-- Criar índices para melhor performance
create index usuarios_obras_usuario_id_idx on usuarios_obras(usuario_id);
create index usuarios_obras_obra_id_idx on usuarios_obras(obra_id); 