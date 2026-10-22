-- ============================================================
-- TG - Etapa 03 (diagnóstico): colunas da tabela temporária criada pelo Data Load
-- Executar como: ADMIN
--
-- O Data Load renomeia as colunas: MAIÚSCULAS, sem espaço
-- (NAME, CREDIT_CARD, ..., TEXT, TRUE_PREDICTIONS).
-- Por isso "True Predictions" (com aspas e espaço) dá ORA-00904.
-- Troque SHEET1 pelo nome real da tabela temporária, se for outro.
-- ============================================================
SELECT column_name, data_type, data_length
  FROM user_tab_columns
 WHERE table_name = 'SHEET1'
 ORDER BY column_id;

-- Para descobrir o nome da tabela temporária mais recente:
-- SELECT object_name, created FROM user_objects
--  WHERE object_type = 'TABLE' ORDER BY created DESC;
