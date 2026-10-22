-- ============================================================
-- TG - Etapa 05.4: TESTE NEGATIVO. Mitigação por view (não funcionou)
--
-- Hipótese: se o usuario_teste só enxergar uma view com CPF e CEP já
-- transformados, o filtro só alcançaria o valor mascarado.
--
-- RESULTADO: o G1 (consulta pela view, como USUARIO_TESTE) falhou com
--   ORA-28094: SQL construct not supported by data redaction
-- Na 19c, uma view com expressão SQL sobre coluna que tem política de redação
-- não é suportada para usuário sem isenção (Oracle Database Security Guide,
-- capítulo "Using Oracle Data Redaction with Oracle Database Features").
-- G2 e G3 não foram executados. A mitigação adotada foi a tabela estática
-- (pasta 06-generalizacao-k-anonimato).
--
-- Mantido no repositório como resultado documentado. Não é necessário executar.
-- ============================================================

-- Parte 1: ADMIN
CREATE OR REPLACE VIEW admin.v_validacao_mascarada AS
SELECT id,
       REGEXP_REPLACE(cpf, '^(\d{3})\.(\d{3})\.(\d{3})-(\d{2})$', '***.***.***-\4') AS cpf,
       REGEXP_REPLACE(cep, '-\d{3}$', '-***') AS cep
  FROM admin.dados_cadastrais_validacao;

GRANT SELECT ON admin.v_validacao_mascarada TO usuario_teste;
REVOKE SELECT ON admin.dados_cadastrais_validacao FROM usuario_teste;

-- Parte 2: USUARIO_TESTE
-- G1: resultado observado = ORA-28094
SELECT id, cpf, cep
  FROM admin.v_validacao_mascarada
 ORDER BY id
 FETCH FIRST 5 ROWS ONLY;

-- ============================================================
-- LIMPEZA (ADMIN): remove a view e devolve o acesso à tabela
-- ============================================================
-- DROP VIEW admin.v_validacao_mascarada;
-- GRANT SELECT ON admin.dados_cadastrais_validacao TO usuario_teste;
