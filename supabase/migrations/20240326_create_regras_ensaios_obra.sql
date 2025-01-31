-- Tabela de Regras de Ensaios
CREATE TABLE regras_ensaios_obra (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    obra_id UUID NOT NULL REFERENCES obras(id) ON DELETE CASCADE,
    nome_ensaio VARCHAR(255) NOT NULL,
    tabela_ensaio VARCHAR(255) NOT NULL,
    quantidade_regra DECIMAL(10,2) NOT NULL,
    unidade_servico VARCHAR(10) NOT NULL,
    servico_obra_id UUID NOT NULL REFERENCES servicos_obra(id) ON DELETE CASCADE,
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    usuario_cadastro VARCHAR(255) NOT NULL
);

-- Índices
CREATE INDEX idx_regras_ensaios_obra_id ON regras_ensaios_obra(obra_id);
CREATE INDEX idx_regras_ensaios_servico ON regras_ensaios_obra(servico_obra_id); 