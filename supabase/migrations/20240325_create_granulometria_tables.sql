-- Create granulometria_entradas table
CREATE TABLE public.granulometria_entradas (
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    ambiente_id uuid NOT NULL,
    data_ensaio date NOT NULL,
    nome_amostra varchar(255) NOT NULL,
    
    -- Umidade Higroscópica - Amostra 1
    capsula_id_1 integer NOT NULL,
    peso_capsula_1 decimal(10,2) NOT NULL,
    peso_bruto_umido_1 decimal(10,2) NOT NULL,
    peso_bruto_seco_1 decimal(10,2) NOT NULL,
    peso_agua_1 decimal(10,2) NOT NULL,
    peso_solo_seco_1 decimal(10,2) NOT NULL,
    umidade_1 decimal(10,2) NOT NULL,
    
    -- Umidade Higroscópica - Amostra 2
    capsula_id_2 integer NOT NULL,
    peso_capsula_2 decimal(10,2) NOT NULL,
    peso_bruto_umido_2 decimal(10,2) NOT NULL,
    peso_bruto_seco_2 decimal(10,2) NOT NULL,
    peso_agua_2 decimal(10,2) NOT NULL,
    peso_solo_seco_2 decimal(10,2) NOT NULL,
    umidade_2 decimal(10,2) NOT NULL,
    
    -- Umidade Média
    umidade_media decimal(10,2) NOT NULL,
    
    -- Massas úmidas
    massa_total_umida decimal(10,2) NOT NULL,
    massa_menor_10_umida decimal(10,2) NOT NULL,
    
    -- Peneiramento grosso (> 2.0mm)
    peneira_50mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_38mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_25mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_19mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_9_5mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_4_8mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_2_0mm decimal(10,2) NOT NULL DEFAULT 0,
    
    -- Peneiramento fino (< 2.0mm)
    peneira_1_2mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_0_6mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_0_42mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_0_30mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_0_15mm decimal(10,2) NOT NULL DEFAULT 0,
    peneira_0_075mm decimal(10,2) NOT NULL DEFAULT 0,
    
    observacoes text,
    usuario_cadastro varchar(255) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT granulometria_entradas_pkey PRIMARY KEY (id),
    CONSTRAINT granulometria_entradas_ambiente_fkey FOREIGN KEY (ambiente_id)
        REFERENCES public.ambientes_compactacao_aterro (id) ON DELETE CASCADE
);

-- Create granulometria_resultados table
CREATE TABLE public.granulometria_resultados (
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    id_entrada uuid NOT NULL,
    
    -- Dados gerais
    umidade_higroscopica decimal(10,2) NOT NULL,
    fator_correcao decimal(10,4) NOT NULL,
    massa_total_seca decimal(10,2) NOT NULL,
    massa_menor_10_seca decimal(10,2) NOT NULL,
    
    -- Peneiramento grosso (> 2.0mm)
    -- Peneira 50mm
    massa_fracao_50mm decimal(10,2) NOT NULL,
    percentagem_retida_50mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_50mm decimal(10,2) NOT NULL,
    percentagem_passando_50mm decimal(10,2) NOT NULL,
    
    -- Peneira 38mm
    massa_fracao_38mm decimal(10,2) NOT NULL,
    percentagem_retida_38mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_38mm decimal(10,2) NOT NULL,
    percentagem_passando_38mm decimal(10,2) NOT NULL,
    
    -- Peneira 25mm
    massa_fracao_25mm decimal(10,2) NOT NULL,
    percentagem_retida_25mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_25mm decimal(10,2) NOT NULL,
    percentagem_passando_25mm decimal(10,2) NOT NULL,
    
    -- Peneira 19mm
    massa_fracao_19mm decimal(10,2) NOT NULL,
    percentagem_retida_19mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_19mm decimal(10,2) NOT NULL,
    percentagem_passando_19mm decimal(10,2) NOT NULL,
    
    -- Peneira 9.5mm
    massa_fracao_9_5mm decimal(10,2) NOT NULL,
    percentagem_retida_9_5mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_9_5mm decimal(10,2) NOT NULL,
    percentagem_passando_9_5mm decimal(10,2) NOT NULL,
    
    -- Peneira 4.8mm
    massa_fracao_4_8mm decimal(10,2) NOT NULL,
    percentagem_retida_4_8mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_4_8mm decimal(10,2) NOT NULL,
    percentagem_passando_4_8mm decimal(10,2) NOT NULL,
    
    -- Peneira 2.0mm
    massa_fracao_2_0mm decimal(10,2) NOT NULL,
    percentagem_retida_2_0mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_2_0mm decimal(10,2) NOT NULL,
    percentagem_passando_2_0mm decimal(10,2) NOT NULL,
    
    -- Peneiramento fino (< 2.0mm)
    -- Peneira 1.2mm
    massa_fracao_1_2mm decimal(10,2) NOT NULL,
    percentagem_retida_1_2mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_1_2mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_1_2mm decimal(10,2) NOT NULL,
    percentagem_passando_1_2mm decimal(10,2) NOT NULL,
    
    -- Peneira 0.6mm
    massa_fracao_0_6mm decimal(10,2) NOT NULL,
    percentagem_retida_0_6mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_0_6mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_0_6mm decimal(10,2) NOT NULL,
    percentagem_passando_0_6mm decimal(10,2) NOT NULL,
    
    -- Peneira 0.42mm
    massa_fracao_0_42mm decimal(10,2) NOT NULL,
    percentagem_retida_0_42mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_0_42mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_0_42mm decimal(10,2) NOT NULL,
    percentagem_passando_0_42mm decimal(10,2) NOT NULL,
    
    -- Peneira 0.30mm
    massa_fracao_0_30mm decimal(10,2) NOT NULL,
    percentagem_retida_0_30mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_0_30mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_0_30mm decimal(10,2) NOT NULL,
    percentagem_passando_0_30mm decimal(10,2) NOT NULL,
    
    -- Peneira 0.15mm
    massa_fracao_0_15mm decimal(10,2) NOT NULL,
    percentagem_retida_0_15mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_0_15mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_0_15mm decimal(10,2) NOT NULL,
    percentagem_passando_0_15mm decimal(10,2) NOT NULL,
    
    -- Peneira 0.075mm
    massa_fracao_0_075mm decimal(10,2) NOT NULL,
    percentagem_retida_0_075mm decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_0_075mm decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_0_075mm decimal(10,2) NOT NULL,
    percentagem_passando_0_075mm decimal(10,2) NOT NULL,
    
    -- Fundo
    massa_fracao_fundo decimal(10,2) NOT NULL,
    percentagem_retida_fundo decimal(10,2) NOT NULL,
    percentagem_retida_amostra_menor_fundo decimal(10,2) NOT NULL,
    percentagem_acumulada_retida_fundo decimal(10,2) NOT NULL,
    percentagem_passando_fundo decimal(10,2) NOT NULL,
    
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT granulometria_resultados_pkey PRIMARY KEY (id),
    CONSTRAINT granulometria_resultados_entrada_fkey FOREIGN KEY (id_entrada)
        REFERENCES public.granulometria_entradas (id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_granulometria_entradas_ambiente ON public.granulometria_entradas(ambiente_id);
CREATE INDEX idx_granulometria_resultados_entrada ON public.granulometria_resultados(id_entrada);
