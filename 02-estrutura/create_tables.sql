-- ============================================================
-- TG - Etapa 02: criação das tabelas (estrutura)
-- Executar como: ADMIN (SQL Worksheet, Database Actions)
-- Executar UMA vez.
--
-- dados_cadastrais            <- Training_Set (45.000 registros)
-- dados_cadastrais_validacao  <- Testing_Set  (30 registros)
--
-- texto e true_predictions são CLOB (o texto chega a 5.610 caracteres).
-- Os demais campos têm folga de ~1,5x a 2x sobre o maior valor observado.
-- ============================================================

CREATE TABLE dados_cadastrais (
    id                 NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome               VARCHAR2(60),
    cartao_credito     VARCHAR2(150),
    email              VARCHAR2(80),
    url                VARCHAR2(100),
    telefone           VARCHAR2(30),
    endereco           VARCHAR2(150),
    empresa            VARCHAR2(80),
    ssn                VARCHAR2(20),
    cpf                VARCHAR2(20),
    cep                VARCHAR2(15),
    texto              CLOB,
    true_predictions   CLOB
);

CREATE TABLE dados_cadastrais_validacao (
    id                 NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome               VARCHAR2(60),
    cartao_credito     VARCHAR2(150),
    email              VARCHAR2(80),
    url                VARCHAR2(100),
    telefone           VARCHAR2(30),
    endereco           VARCHAR2(150),
    empresa            VARCHAR2(80),
    ssn                VARCHAR2(20),
    cpf                VARCHAR2(20),
    cep                VARCHAR2(15),
    texto              CLOB,
    true_predictions   CLOB
);
