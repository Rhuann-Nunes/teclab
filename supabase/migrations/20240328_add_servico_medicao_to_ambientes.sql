-- Add new columns for service and measurement references
-- Note: Only measurements with status 'aberto' should be available for selection
ALTER TABLE ambientes_compactacao_aterro
ADD COLUMN servico_id UUID NOT NULL,
ADD COLUMN medicao_id UUID NOT NULL;

-- Add foreign key constraints
ALTER TABLE ambientes_compactacao_aterro
ADD CONSTRAINT ambientes_compactacao_aterro_servico_id_fkey 
FOREIGN KEY (servico_id) 
REFERENCES servicos_obra(id) 
ON DELETE RESTRICT;

ALTER TABLE ambientes_compactacao_aterro
ADD CONSTRAINT ambientes_compactacao_aterro_medicao_id_fkey 
FOREIGN KEY (medicao_id) 
REFERENCES medicoes_obra(id) 
ON DELETE RESTRICT;

-- Add new indexes for better query performance
CREATE INDEX idx_ambientes_compactacao_servico 
ON ambientes_compactacao_aterro(servico_id);

CREATE INDEX idx_ambientes_compactacao_medicao 
ON ambientes_compactacao_aterro(medicao_id);

-- Create a function to validate that the measurement is open
CREATE OR REPLACE FUNCTION validate_ambiente_medicao()
RETURNS TRIGGER AS $$
DECLARE
  medicao_status VARCHAR(20);
BEGIN
  -- Get the measurement status
  SELECT status INTO medicao_status
  FROM medicoes_obra
  WHERE id = NEW.medicao_id;

  -- Validate that the measurement is open
  IF medicao_status != 'aberto' THEN
    RAISE EXCEPTION 'A medição deve estar com status aberto';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a function to validate location constraints based on service location
CREATE OR REPLACE FUNCTION validate_ambiente_localizacao_servico()
RETURNS TRIGGER AS $$
DECLARE
  servico_loc RECORD;
  loc_tipo tipo_localizacao;
BEGIN
  -- Get service location data
  SELECT s.localizacao_obra_id, s.estaca_inicial as servico_estaca_inicial, 
         s.estaca_final as servico_estaca_final, l.tipo
  INTO servico_loc
  FROM servicos_obra s
  JOIN localizacao_obra l ON l.id = s.localizacao_obra_id
  WHERE s.id = NEW.servico_id;

  -- Validate that the ambiente's location matches the service's location
  IF NEW.localizacao_id != servico_loc.localizacao_obra_id THEN
    RAISE EXCEPTION 'A localização do ambiente deve ser a mesma do serviço';
  END IF;

  -- For trecho type locations, validate that the ambiente's segment is within the service's segment
  IF servico_loc.tipo = 'trecho' THEN
    IF NEW.estaca_inicial < servico_loc.servico_estaca_inicial OR 
       NEW.estaca_final > servico_loc.servico_estaca_final THEN
      RAISE EXCEPTION 'O trecho do ambiente deve estar contido no trecho do serviço';
    END IF;
  ELSIF servico_loc.tipo = 'pontual' AND 
        (NEW.estaca_inicial IS NOT NULL OR NEW.estaca_final IS NOT NULL) THEN
    RAISE EXCEPTION 'Ambientes em localização pontual não devem ter estacas';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for validation
CREATE TRIGGER validate_ambiente_medicao_trigger
BEFORE INSERT OR UPDATE ON ambientes_compactacao_aterro
FOR EACH ROW
EXECUTE FUNCTION validate_ambiente_medicao();

CREATE TRIGGER validate_ambiente_localizacao_servico_trigger
BEFORE INSERT OR UPDATE ON ambientes_compactacao_aterro
FOR EACH ROW
EXECUTE FUNCTION validate_ambiente_localizacao_servico(); 