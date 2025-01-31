-- Create the set_updated_at() function if it doesn't exist
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create tables for In Situ Density test
CREATE TABLE densidade_insitu_entradas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ambiente_id UUID REFERENCES ambientes_compactacao_aterro(id) ON DELETE CASCADE,
    data_ensaio DATE NOT NULL,
    hora_ensaio TIME WITHOUT TIME ZONE NOT NULL,
    nome_amostra TEXT NOT NULL,
    metodo_umidade TEXT NOT NULL DEFAULT 'speedy',
    observacoes TEXT
);

CREATE TABLE densidade_insitu_furos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    densidade_insitu_id UUID REFERENCES densidade_insitu_entradas(id) ON DELETE CASCADE,
    compactacao_id UUID REFERENCES compactacao_entradas(id) ON DELETE CASCADE,
    estaca TEXT NOT NULL,
    lado TEXT NOT NULL CHECK (lado IN ('LE', 'LD', 'EX')),
    profundidade DECIMAL(10, 2) NOT NULL,
    peso_frasco_antes DECIMAL(10, 3) NOT NULL,
    peso_frasco_depois DECIMAL(10, 3) NOT NULL,
    peso_areia_cone DECIMAL(10, 3) NOT NULL,
    peso_areia_furo DECIMAL(10, 3) NOT NULL,
    densidade_areia DECIMAL(10, 3) NOT NULL,
    volume_furo DECIMAL(10, 3) NOT NULL,
    peso_solo_umido_tara DECIMAL(10, 3) NOT NULL,
    tara DECIMAL(10, 3) NOT NULL,
    peso_solo_umido DECIMAL(10, 3) NOT NULL,
    teor_umidade DECIMAL(10, 2) NOT NULL,
    densidade_aparente_umida DECIMAL(10, 3) NOT NULL,
    densidade_aparente_seca DECIMAL(10, 3) NOT NULL,
    densidade_maxima_laboratorio DECIMAL(10, 3) NOT NULL,
    umidade_otima_laboratorio DECIMAL(10, 2) NOT NULL,
    desvio_umidade DECIMAL(10, 1) NOT NULL,
    grau_compactacao DECIMAL(10, 1) NOT NULL
);

-- Create triggers for updated_at
CREATE TRIGGER set_updated_at_densidade_insitu_entradas
    BEFORE UPDATE ON densidade_insitu_entradas
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_densidade_insitu_furos
    BEFORE UPDATE ON densidade_insitu_furos
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at(); 