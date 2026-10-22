-- ============================================================
-- TG - Etapa 03: migra a tabela temporária (Testing_Set) para dados_cadastrais_validacao
-- Executar como: ADMIN
-- Pré-requisito: Data Load do Testing_Set_com_CPF_CEP.xlsx concluído.
--
-- ATENÇÃO: este arquivo é um MODELO. O nome da tabela temporária desta carga
-- pode ser diferente de SHEET1 (a primeira já pode ter sido removida ou estar
-- em uso). Descubra o nome real e troque NOME_DA_TABELA_TEMP abaixo:
--   SELECT object_name, created FROM user_objects
--    WHERE object_type = 'TABLE' ORDER BY created DESC;
-- ============================================================

INSERT INTO dados_cadastrais_validacao (
    nome, cartao_credito, email, url, telefone,
    endereco, empresa, ssn, cpf, cep, texto, true_predictions
)
SELECT
    NAME, CREDIT_CARD, EMAIL, URL, PHONE,
    ADDRESS, COMPANY, SSN, CPF, CEP, TEXT, TRUE_PREDICTIONS
FROM NOME_DA_TABELA_TEMP;

COMMIT;

-- Conferência: esperado 30
SELECT COUNT(*) FROM dados_cadastrais_validacao;

-- Após confirmar:
-- DROP TABLE NOME_DA_TABELA_TEMP;
