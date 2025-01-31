-- Create the set_updated_at() function if it doesn't exist
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create compaction test tables
CREATE TABLE compactacao_entradas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ambiente_id UUID REFERENCES ambientes_compactacao_aterro(id) ON DELETE CASCADE,
    data_ensaio DATE NOT NULL,
    hora_ensaio TIME NOT NULL,
    nome_amostra TEXT NOT NULL,
    metodo_compactacao TEXT NOT NULL,
    golpes_por_camada INTEGER NOT NULL,
    numero_camadas INTEGER NOT NULL,
    observacoes TEXT,
    -- Dados da umidade higroscópica - Amostra 1
    capsula_id_1 INTEGER NOT NULL,
    peso_capsula_1 DECIMAL(10, 2) NOT NULL,
    peso_bruto_umido_1 DECIMAL(10, 2) NOT NULL,
    peso_bruto_seco_1 DECIMAL(10, 2) NOT NULL,
    peso_agua_1 DECIMAL(10, 2) NOT NULL,
    peso_solo_seco_1 DECIMAL(10, 2) NOT NULL,
    umidade_1 DECIMAL(10, 2) NOT NULL,
    -- Dados da umidade higroscópica - Amostra 2
    capsula_id_2 INTEGER NOT NULL,
    peso_capsula_2 DECIMAL(10, 2) NOT NULL,
    peso_bruto_umido_2 DECIMAL(10, 2) NOT NULL,
    peso_bruto_seco_2 DECIMAL(10, 2) NOT NULL,
    peso_agua_2 DECIMAL(10, 2) NOT NULL,
    peso_solo_seco_2 DECIMAL(10, 2) NOT NULL,
    umidade_2 DECIMAL(10, 2) NOT NULL,
    -- Umidade média e dados da amostra base
    umidade_media DECIMAL(10, 2) NOT NULL,
    peso_total_amostra DECIMAL(10, 2) NOT NULL,
    peso_solo_seco_amostra DECIMAL(10, 2) NOT NULL,
    peso_agua_amostra DECIMAL(10, 2) NOT NULL,
    intervalo_percentual DECIMAL(10, 2) NOT NULL
);

CREATE TABLE compactacao_pontos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    compactacao_id UUID REFERENCES compactacao_entradas(id) ON DELETE CASCADE,
    ponto INTEGER NOT NULL,
    cilindro_id INTEGER NOT NULL,
    peso_bruto_umido DECIMAL(10, 2) NOT NULL,
    peso_solo_umido DECIMAL(10, 2) NOT NULL,
    agua_adicionada DECIMAL(10, 2) NOT NULL,
    agua_total DECIMAL(10, 2) NOT NULL,
    umidade_media DECIMAL(10, 2) NOT NULL,
    densidade_solo_umido DECIMAL(10, 3) NOT NULL,
    densidade_solo_seco DECIMAL(10, 3) NOT NULL,
    massa_molde DECIMAL(10, 2) NOT NULL,
    volume_molde DECIMAL(10, 3) NOT NULL
);

CREATE TABLE compactacao_resultados (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    compactacao_id UUID REFERENCES compactacao_entradas(id) ON DELETE CASCADE,
    ponto INTEGER NOT NULL,
    teor_umidade DECIMAL(10, 2) NOT NULL,
    massa_especifica_aparente_umida DECIMAL(10, 3) NOT NULL,
    massa_especifica_aparente_seca DECIMAL(10, 3) NOT NULL
);

CREATE TABLE compactacao_resultados_finais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    compactacao_id UUID REFERENCES compactacao_entradas(id) ON DELETE CASCADE,
    umidade_otima DECIMAL(10, 2) NOT NULL,
    massa_especifica_aparente_seca_maxima DECIMAL(10, 3) NOT NULL
);

-- Create triggers to update updated_at
CREATE TRIGGER set_updated_at_compactacao_entradas
    BEFORE UPDATE ON compactacao_entradas
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_compactacao_pontos
    BEFORE UPDATE ON compactacao_pontos
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_compactacao_resultados
    BEFORE UPDATE ON compactacao_resultados
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_compactacao_resultados_finais
    BEFORE UPDATE ON compactacao_resultados_finais
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at(); 