DROP TABLE IF EXISTS ensaios_granulometria CASCADE; DROP TABLE IF EXISTS ensaios_grau_compactacao CASCADE; DELETE FROM tipos_ensaios WHERE codigo IN ('GRANULOMETRIA', 'GRAU_COMPACTACAO');
