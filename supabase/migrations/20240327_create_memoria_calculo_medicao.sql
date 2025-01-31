create table
  public.memoria_calculo_medicao (
    id uuid not null default extensions.uuid_generate_v4 (),
    obra_id uuid not null,
    medicao_id uuid not null,
    servico_id uuid not null,
    localizacao_obra_id uuid not null,
    estaca_inicial numeric(10, 3) null,
    estaca_final numeric(10, 3) null,
    quantidade numeric(12, 2) not null,
    data_execucao date not null,
    data_cadastro timestamp with time zone null default current_timestamp,
    usuario_cadastro character varying(255) not null,
    constraint memoria_calculo_medicao_pkey primary key (id),
    constraint memoria_calculo_medicao_localizacao_obra_id_fkey foreign key (localizacao_obra_id) references localizacao_obra (id),
    constraint memoria_calculo_medicao_medicao_id_fkey foreign key (medicao_id) references medicoes_obra (id) on delete cascade,
    constraint memoria_calculo_medicao_obra_id_fkey foreign key (obra_id) references obras (id) on delete cascade,
    constraint memoria_calculo_medicao_servico_id_fkey foreign key (servico_id) references servicos_obra (id) on delete cascade
  ) tablespace pg_default;

create index if not exists idx_memoria_calculo_obra on public.memoria_calculo_medicao using btree (obra_id) tablespace pg_default;

create index if not exists idx_memoria_calculo_medicao on public.memoria_calculo_medicao using btree (medicao_id) tablespace pg_default;

create index if not exists idx_memoria_calculo_servico on public.memoria_calculo_medicao using btree (servico_id) tablespace pg_default;

create index if not exists idx_memoria_calculo_localizacao on public.memoria_calculo_medicao using btree (localizacao_obra_id) tablespace pg_default;

create trigger validate_memoria_calculo_trigger before insert
or
update on memoria_calculo_medicao for each row
execute function validate_memoria_calculo (); 