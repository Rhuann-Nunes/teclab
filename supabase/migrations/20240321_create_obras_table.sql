create table obras (
  id uuid default uuid_generate_v4() primary key,
  codigo varchar(6) not null,
  nome varchar(255) not null,
  estado varchar(2) not null,
  cidade varchar(255) not null,
  data_cadastro timestamp with time zone default timezone('utc'::text, now()) not null,
  usuario_cadastro varchar(255) not null
);

-- Criar índices para melhor performance
create index obras_codigo_idx on obras(codigo);
create index obras_data_cadastro_idx on obras(data_cadastro); 