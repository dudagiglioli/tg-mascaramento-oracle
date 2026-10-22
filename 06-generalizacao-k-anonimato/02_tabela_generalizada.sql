-- ============================================================
-- TG - Etapa 06.2: tabela generalizada (estática)
-- Parte 1: executar como ADMIN. Executar UMA vez
-- (repetir o CREATE TABLE dá ORA-00955).
--
-- Nível adotado: CEP com 3 dígitos (k = 26 em 06.1).
-- Identificadores diretos suprimidos (não entram na tabela).
-- O CPF entra na etapa 07, como token.
-- ============================================================
CREATE TABLE admin.dados_cadastrais_generalizada AS
SELECT id,
       SUBSTR(REPLACE(cep, '-', ''), 1, 3) AS cep_3
  FROM admin.dados_cadastrais;

ALTER TABLE admin.dados_cadastrais_generalizada ADD PRIMARY KEY (id);

-- Conferência (ADMIN): esperado 45000 registros, 1000 grupos, k = 26, maior grupo = 65
SELECT SUM(n)   AS registros,
       COUNT(*) AS grupos,
       MIN(n)   AS k,
       MAX(n)   AS maior_grupo
  FROM (SELECT cep_3, COUNT(*) AS n
          FROM admin.dados_cadastrais_generalizada
         GROUP BY cep_3);

-- ============================================================
-- Parte 2: acesso do usuario_teste (ADMIN)
-- ============================================================
GRANT SELECT ON admin.dados_cadastrais_generalizada TO usuario_teste;

-- ============================================================
-- Parte 3: testes, logado como USUARIO_TESTE
-- ============================================================

-- H1: colunas que existem na tabela. Esperado: ID e CEP_3 (o CEP original não existe).
SELECT column_name
  FROM all_tab_columns
 WHERE owner = 'ADMIN' AND table_name = 'DADOS_CADASTRAIS_GENERALIZADA'
 ORDER BY column_id;

-- H2: as regiões mais raras. Observado: 722 (26), 585 (29), 982 (29) => k = 26.
SELECT cep_3, COUNT(*) AS tamanho
  FROM admin.dados_cadastrais_generalizada
 GROUP BY cep_3
 ORDER BY tamanho
 FETCH FIRST 3 ROWS ONLY;

-- ============================================================
-- Parte 4: controle de acesso às tabelas base (Figura 5 do TG: antes e depois)
--
-- 1) USUARIO_TESTE: SELECT COUNT(*) FROM admin.dados_cadastrais;
--      -> 45000                      (print "antes")
-- 2) ADMIN, SOMENTE depois de ter todos os prints dos testes da etapa 05:
-- REVOKE SELECT ON admin.dados_cadastrais FROM usuario_teste;
-- REVOKE SELECT ON admin.dados_cadastrais_validacao FROM usuario_teste;
-- 3) USUARIO_TESTE: SELECT COUNT(*) FROM admin.dados_cadastrais;
--      -> ORA-00942                  (print "depois")
--
-- Para refazer os testes da etapa 05, devolva o acesso (ADMIN):
-- GRANT SELECT ON admin.dados_cadastrais TO usuario_teste;
-- GRANT SELECT ON admin.dados_cadastrais_validacao TO usuario_teste;
-- ============================================================
