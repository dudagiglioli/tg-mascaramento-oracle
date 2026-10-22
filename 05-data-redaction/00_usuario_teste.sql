-- ============================================================
-- TG - Etapa 05.0: usuário de teste, sem privilégios de exceção
-- Executar como: ADMIN. Executar UMA vez.
--
-- Papel: representa o usuário comum que NÃO deve ver os dados reais
-- nem reverter os tokens.
--
-- SENHA: o Autonomous Database exige 12 a 30 caracteres, com pelo menos
-- uma maiúscula, uma minúscula e um número, sem aspas duplas e sem o nome
-- do usuário. Senha curta dá ORA-28003 / ORA-20000.
-- NUNCA coloque a senha real no Git.
-- ============================================================

CREATE USER usuario_teste IDENTIFIED BY "TROQUE_POR_SENHA_FORTE_12+";

GRANT CREATE SESSION TO usuario_teste;
GRANT SELECT ON admin.dados_cadastrais TO usuario_teste;
GRANT SELECT ON admin.dados_cadastrais_validacao TO usuario_teste;

-- Permite o login do usuario_teste no Database Actions (SQL Worksheet).
-- Sem isto, só o ADMIN consegue abrir o SQL Worksheet.
BEGIN
  ORDS_ADMIN.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => 'USUARIO_TESTE',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'usuario_teste',
    p_auto_rest_auth      => TRUE
  );
  COMMIT;
END;
/

-- IMPORTANTE: propositalmente NÃO se concede nenhum privilégio sobre a
-- tabela de mapeamento do CPF (etapa 07). É isso que gera o ORA-00942
-- no teste de reversão do token.
--
-- Para logar como usuario_teste, abra uma janela anônima do navegador e use a
-- URL do Database Actions do banco, trocando /ords/admin/ por /ords/usuario_teste/.
