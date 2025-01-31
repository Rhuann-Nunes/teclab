-- Adicionar coluna de espessura da camada
ALTER TABLE ambientes_compactacao_aterro
ADD COLUMN espessura_camada DECIMAL(5,3) NOT NULL DEFAULT 0.20;

-- Adicionar constraint de validação
ALTER TABLE ambientes_compactacao_aterro
ADD CONSTRAINT check_espessura_camada 
CHECK (espessura_camada >= 0 AND espessura_camada <= 0.80);

-- Remover o valor default após a migração
ALTER TABLE ambientes_compactacao_aterro
ALTER COLUMN espessura_camada DROP DEFAULT; 