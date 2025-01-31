-- Create servicos_obra table
create table if not exists servicos_obra (
  id uuid default uuid_generate_v4() primary key,
  obra_id uuid references obras(id) on delete cascade not null,
  localizacao_obra_id uuid references localizacao_obra(id) on delete cascade not null,
  nome text not null,
  quantidade_total numeric not null,
  unidade text not null,
  estaca_inicial text,
  estaca_final text,
  usuario_cadastro text not null,
  data_cadastro timestamp with time zone default now() not null,
  created_at timestamp with time zone default now() not null
);

-- Add RLS policies
alter table servicos_obra enable row level security;

create policy "Usuários autenticados podem visualizar serviços das obras que têm acesso"
  on servicos_obra for select
  using (
    exists (
      select 1 from usuarios_obra uo
      where uo.obra_id = servicos_obra.obra_id
      and uo.user_id = auth.uid()
    )
  );

create policy "Usuários autenticados podem inserir serviços nas obras que têm acesso"
  on servicos_obra for insert
  with check (
    exists (
      select 1 from usuarios_obra uo
      where uo.obra_id = servicos_obra.obra_id
      and uo.user_id = auth.uid()
    )
  );

create policy "Usuários autenticados podem excluir serviços das obras que têm acesso"
  on servicos_obra for delete
  using (
    exists (
      select 1 from usuarios_obra uo
      where uo.obra_id = servicos_obra.obra_id
      and uo.user_id = auth.uid()
    )
  ); 