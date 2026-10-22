-- ============================================================
-- TG - Etapa 03: migra a tabela temporária (Training_Set) para dados_cadastrais
-- Executar como: ADMIN
-- Pré-requisito: Data Load do Training_Set_com_CPF_CEP.xlsx concluído
--                (ver README desta pasta).
--
-- Tabela temporária criada pelo Data Load: SHEET1
-- (Text e True Predictions carregados como VARCHAR2, não CLOB, para contornar
--  o ORA-00904 do processo de carga; o INSERT converte para o CLOB da tabela final.)
-- ============================================================

INSERT INTO dados_cadastrais (
    nome, cartao_credito, email, url, telefone,
    endereco, empresa, ssn, cpf, cep, texto, true_predictions
)
SELECT
    NAME, CREDIT_CARD, EMAIL, URL, PHONE,
    ADDRESS, COMPANY, SSN, CPF, CEP, TEXT, TRUE_PREDICTIONS
FROM SHEET1;

COMMIT;

-- Conferência: esperado 45000
SELECT COUNT(*) FROM dados_cadastrais;

-- Após confirmar, remover a tabela temporária:
-- DROP TABLE SHEET1;
