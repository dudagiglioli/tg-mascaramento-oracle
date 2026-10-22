-- ============================================================
-- TG - Etapa 07: tokenização reversível do CPF
-- Parte 1: executar como ADMIN. Executar UMA vez, depois da etapa 06.
--
-- A tabela de mapeamento (token <-> CPF original) fica só com o ADMIN.
-- O mesmo CPF recebe sempre o mesmo token (preserva integridade referencial).
-- Reversível = pseudonimização (LGPD, art. 13, par. 4).
-- ============================================================
CREATE TABLE admin.mapeamento_cpf_token (
  token        VARCHAR2(32) PRIMARY KEY,
  cpf_original VARCHAR2(20) NOT NULL UNIQUE
);

-- Token aleatório, sem relação com o CPF (TK + 16 caracteres hexadecimais).
-- Se der PLS-00201 em DBMS_CRYPTO, troque por: 'TK' || DBMS_RANDOM.STRING('X', 16)
-- (aceitável no laboratório; em produção use gerador criptográfico).
INSERT INTO admin.mapeamento_cpf_token (token, cpf_original)
SELECT 'TK' || RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(8)), cpf
  FROM (SELECT DISTINCT cpf FROM admin.dados_cadastrais);
COMMIT;

ALTER TABLE admin.dados_cadastrais_generalizada ADD (cpf_token VARCHAR2(32));

UPDATE admin.dados_cadastrais_generalizada g
   SET g.cpf_token = (SELECT m.token
                        FROM admin.mapeamento_cpf_token m
                        JOIN admin.dados_cadastrais d ON d.cpf = m.cpf_original
                       WHERE d.id = g.id);
COMMIT;

-- ============================================================
-- Conferência (ADMIN)
-- ============================================================

-- Observado: linhas = com_token = 45000; tokens_unicos = 44712 (= CPFs distintos).
-- As 288 repetições vêm do gerador de CPF sintético (ver README, "Limitações").
SELECT COUNT(*)                  AS linhas,
       COUNT(cpf_token)          AS com_token,
       COUNT(DISTINCT cpf_token) AS tokens_unicos
  FROM admin.dados_cadastrais_generalizada;

SELECT COUNT(DISTINCT cpf) AS cpfs_distintos FROM admin.dados_cadastrais;

-- Reversão pelo ADMIN (o token é reversível)
SELECT g.id, g.cpf_token, m.cpf_original
  FROM admin.dados_cadastrais_generalizada g
  JOIN admin.mapeamento_cpf_token m ON m.token = g.cpf_token
 ORDER BY g.id
 FETCH FIRST 3 ROWS ONLY;

-- ============================================================
-- Parte 2: testes, logado como USUARIO_TESTE
-- (ele já tem SELECT na tabela generalizada; NÃO recebe nada no mapeamento)
-- ============================================================

-- I1: o usuario_teste vê o token, não o CPF.
SELECT id, cep_3, cpf_token
  FROM admin.dados_cadastrais_generalizada
 ORDER BY id
 FETCH FIRST 5 ROWS ONLY;

-- I2: tentativa de reverter o token pela junção. Observado: ORA-00942.
SELECT g.cpf_token, m.cpf_original
  FROM admin.dados_cadastrais_generalizada g
  JOIN admin.mapeamento_cpf_token m ON m.token = g.cpf_token
 FETCH FIRST 3 ROWS ONLY;

-- I3: consulta direta ao mapeamento. Observado: ORA-00942.
-- ORA-00942 não distingue "não existe" de "sem privilégio". A prova do controle
-- de acesso é o par: o ADMIN reverte os tokens (acima) e o usuario_teste não.
SELECT COUNT(*) FROM admin.mapeamento_cpf_token;
