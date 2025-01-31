CREATE TABLE medicoes_obra (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    obra_id UUID NOT NULL REFERENCES obras(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto',
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    usuario_cadastro VARCHAR(255) NOT NULL,
    CONSTRAINT check_status CHECK (status IN ('aberto', 'fechado')),
    CONSTRAINT check_periodo CHECK (data_fim >= data_inicio),
    CONSTRAINT unique_medicao_numero UNIQUE (obra_id, numero)
);

CREATE INDEX idx_medicoes_obra_id ON medicoes_obra(obra_id); 