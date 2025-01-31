-- Create the set_updated_at() function if it doesn't exist
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create CBR and Expansion test tables
CREATE TABLE cbr_entradas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ambiente_id UUID REFERENCES ambientes_compactacao_aterro(id) ON DELETE CASCADE,
    compactacao_id UUID REFERENCES compactacao_entradas(id) ON DELETE CASCADE,
    data_ensaio DATE NOT NULL,
    hora_ensaio TIME WITHOUT TIME ZONE NOT NULL,
    nome_amostra TEXT NOT NULL,
    numero_golpes INTEGER NOT NULL,
    altura_cilindro DECIMAL(10, 2) NOT NULL DEFAULT 11.40,
    constante_prensa DECIMAL(10, 4) NOT NULL DEFAULT 0.0921,
    observacoes TEXT
);

CREATE TABLE cbr_leituras_expansao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cbr_entrada_id UUID REFERENCES cbr_entradas(id) ON DELETE CASCADE,
    compactacao_ponto_id UUID REFERENCES compactacao_pontos(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    hora TIME WITHOUT TIME ZONE NOT NULL,
    leitura_extensometro DECIMAL(10, 3),
    ordem INTEGER NOT NULL
);

CREATE TABLE cbr_leituras_penetracao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cbr_entrada_id UUID REFERENCES cbr_entradas(id) ON DELETE CASCADE,
    compactacao_ponto_id UUID REFERENCES compactacao_pontos(id) ON DELETE CASCADE,
    tempo_penetracao DECIMAL(10, 2) NOT NULL,
    penetracao_mm DECIMAL(10, 2) NOT NULL,
    leitura_extensometro DECIMAL(10, 3),
    pressao_calculada DECIMAL(10, 3),
    pressao_padrao DECIMAL(10, 2) NOT NULL,
    isc DECIMAL(10, 2),
    isc_referencia BOOLEAN DEFAULT FALSE,
    ordem INTEGER NOT NULL
);

CREATE TABLE cbr_resultados (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cbr_entrada_id UUID REFERENCES cbr_entradas(id) ON DELETE CASCADE,
    compactacao_ponto_id UUID REFERENCES compactacao_pontos(id) ON DELETE CASCADE,
    diferenca_expansao DECIMAL(10, 3),
    expansao_percentual DECIMAL(10, 2),
    isc_2_54 DECIMAL(10, 2),
    isc_5_08 DECIMAL(10, 2),
    isc_escolhido DECIMAL(10, 2)
);

-- Create trigger to update updated_at
CREATE TRIGGER set_updated_at_cbr_entradas
    BEFORE UPDATE ON cbr_entradas
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_cbr_leituras_expansao
    BEFORE UPDATE ON cbr_leituras_expansao
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_cbr_leituras_penetracao
    BEFORE UPDATE ON cbr_leituras_penetracao
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_cbr_resultados
    BEFORE UPDATE ON cbr_resultados
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at(); 