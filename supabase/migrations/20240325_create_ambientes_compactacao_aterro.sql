-- Criar enum para tipo de localização (se não existir)
DO $$ BEGIN
    CREATE TYPE tipo_localizacao AS ENUM ('trecho', 'pontual');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Criar tabela de ambientes de compactação de aterro
CREATE TABLE IF NOT EXISTS ambientes_compactacao_aterro (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  obra_id UUID NOT NULL REFERENCES obras(id) ON DELETE CASCADE,
  localizacao_id UUID NOT NULL REFERENCES localizacao_obra(id) ON DELETE RESTRICT,
  data_prevista DATE NOT NULL,
  volume_previsto DECIMAL(10,2) NOT NULL, -- em metros cúbicos
  espessura_camada DECIMAL(5,3) NOT NULL, -- em metros (0.00 a 0.80)
  estaca_inicial NUMERIC(10,3),
  estaca_final NUMERIC(10,3),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
  usuario_cadastro VARCHAR(255) NOT NULL,
  CONSTRAINT check_ambiente_estacas CHECK (
    (estaca_inicial IS NOT NULL AND estaca_final IS NOT NULL) OR
    (estaca_inicial IS NULL AND estaca_final IS NULL)
  ),
  CONSTRAINT check_espessura_camada CHECK (
    espessura_camada >= 0 AND espessura_camada <= 0.80
  )
);

-- Criar função para validar estacas do ambiente dentro da localização
CREATE OR REPLACE FUNCTION validate_ambiente_localizacao()
RETURNS TRIGGER AS $$
DECLARE
  loc_tipo tipo_localizacao;
  loc_estaca_inicial NUMERIC(10,3);
  loc_estaca_final NUMERIC(10,3);
BEGIN
  -- Buscar dados da localização
  SELECT tipo, estaca_inicial, estaca_final
  INTO loc_tipo, loc_estaca_inicial, loc_estaca_final
  FROM localizacao_obra
  WHERE id = NEW.localizacao_id;

  -- Validar baseado no tipo de localização
  IF loc_tipo = 'trecho' THEN
    -- Verificar se as estacas do ambiente estão dentro do intervalo da localização
    IF NEW.estaca_inicial < loc_estaca_inicial OR NEW.estaca_final > loc_estaca_final THEN
      RAISE EXCEPTION 'As estacas do ambiente devem estar dentro do intervalo da localização';
    END IF;
  ELSIF loc_tipo = 'pontual' THEN
    -- Para localização pontual, não deve ter estacas
    IF NEW.estaca_inicial IS NOT NULL OR NEW.estaca_final IS NOT NULL THEN
      RAISE EXCEPTION 'Ambientes em localização pontual não devem ter estacas';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para validação
CREATE TRIGGER validate_ambiente_localizacao_trigger
BEFORE INSERT OR UPDATE ON ambientes_compactacao_aterro
FOR EACH ROW
EXECUTE FUNCTION validate_ambiente_localizacao();

-- Criar índices
CREATE INDEX idx_ambientes_compactacao_obra ON ambientes_compactacao_aterro(obra_id);
CREATE INDEX idx_ambientes_compactacao_localizacao ON ambientes_compactacao_aterro(localizacao_id);
CREATE INDEX idx_ambientes_compactacao_data ON ambientes_compactacao_aterro(data_prevista); 