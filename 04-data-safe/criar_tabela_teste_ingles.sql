-- ============================================================
-- TG - Etapa 04: tabela de teste com colunas em INGLÊS
-- Executar como: ADMIN (depois da carga de dados_cadastrais)
--
-- Objetivo: isolar o efeito do idioma da nomenclatura na descoberta
-- automática do Oracle Data Safe (comparar com a tabela em português).
-- Tabela ADICIONAL: não altera dados_cadastrais nem dados_cadastrais_validacao.
-- ============================================================

CREATE TABLE dados_cadastrais_en (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         VARCHAR2(60),
    credit_card  VARCHAR2(150),
    email        VARCHAR2(80),
    url          VARCHAR2(100),
    phone        VARCHAR2(30),
    address      VARCHAR2(150),
    company      VARCHAR2(80),
    ssn          VARCHAR2(20),
    cpf          VARCHAR2(20),
    cep          VARCHAR2(15)
);

-- Amostra de 200 registros (texto e true_predictions não são necessários aqui)
INSERT INTO dados_cadastrais_en (
    name, credit_card, email, url, phone,
    address, company, ssn, cpf, cep
)
SELECT
    nome, cartao_credito, email, url, telefone,
    endereco, empresa, ssn, cpf, cep
FROM dados_cadastrais
FETCH FIRST 200 ROWS ONLY;

COMMIT;

-- Conferência: esperado 200
SELECT COUNT(*) FROM dados_cadastrais_en;
