-- ============================================================
-- TG - Etapa 05.2: proteger o campo TEXTO (CLOB)
-- Parte 1: executar como ADMIN. Executar UMA vez, depois da 05.1.
--
-- O TEXTO entra nas políticas já existentes (uma política por tabela).
-- Em CLOB a documentação da Oracle (26ai) indica apenas redação total (FULL).
-- ============================================================
BEGIN
  FOR t IN (SELECT 'DADOS_CADASTRAIS' AS tab FROM dual
            UNION ALL
            SELECT 'DADOS_CADASTRAIS_VALIDACAO' FROM dual) LOOP
    DBMS_REDACT.ALTER_POLICY(
      object_schema => 'ADMIN',
      object_name   => t.tab,
      policy_name   => 'POL_REDACT_' || t.tab,
      action        => DBMS_REDACT.ADD_COLUMN,
      column_name   => 'TEXTO',
      function_type => DBMS_REDACT.FULL
    );
  END LOOP;
END;
/

-- Conferir (ADMIN): devem aparecer 2 linhas com TEXTO
SELECT object_name, column_name, function_type
  FROM redaction_columns
 WHERE column_name = 'TEXTO';

-- ============================================================
-- Parte 2: testes, logado como USUARIO_TESTE
-- ============================================================

-- Teste E: esperado [redacted] em todas as linhas (valor padrão da redação
-- total em CLOB) e nome em branco.
SELECT id, nome, DBMS_LOB.SUBSTR(texto, 400, 1) AS trecho_texto
  FROM admin.dados_cadastrais_validacao
 ORDER BY id
 FETCH FIRST 3 ROWS ONLY;

-- Teste F: o filtro enxerga o conteúdo do texto mesmo exibido como [redacted]?
-- Observado: 1.
SELECT COUNT(*) AS achou
  FROM admin.dados_cadastrais_validacao
 WHERE DBMS_LOB.INSTR(texto, 'Madison Brooks') > 0;

-- Teste D2: o prefixo do CPF da linha 4 é confirmável pelo filtro?
-- Observado: 1.
SELECT COUNT(*) AS achou
  FROM admin.dados_cadastrais_validacao
 WHERE id = 4 AND cpf LIKE '547.%';
