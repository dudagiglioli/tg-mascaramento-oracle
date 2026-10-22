-- ============================================================
-- TG - Etapa 05.1: mascaramento dinâmico (Oracle Data Redaction)
-- Executar como: ADMIN (partes 1 e 2). Os testes B a D rodam como USUARIO_TESTE.
-- Executar UMA vez (criar a mesma política duas vezes dá erro).
-- ============================================================

-- ------------------------------------------------------------
-- 1) Políticas de redação (uma por tabela; o Oracle só admite uma por tabela)
-- Regra: todo usuário diferente de ADMIN vê o dado redigido.
-- Colunas: NOME e TELEFONE (total), EMAIL (parte do nome),
--          CPF (mantém só os 2 dígitos finais), CEP (oculta os 3 últimos).
-- ------------------------------------------------------------
BEGIN
  FOR t IN (SELECT 'DADOS_CADASTRAIS' AS tab FROM dual
            UNION ALL
            SELECT 'DADOS_CADASTRAIS_VALIDACAO' FROM dual) LOOP

    DBMS_REDACT.ADD_POLICY(
      object_schema => 'ADMIN',
      object_name   => t.tab,
      policy_name   => 'POL_REDACT_' || t.tab,
      column_name   => 'NOME',
      function_type => DBMS_REDACT.FULL,
      expression    => q'[SYS_CONTEXT('USERENV','SESSION_USER') != 'ADMIN']'
    );

    DBMS_REDACT.ALTER_POLICY(
      object_schema => 'ADMIN',
      object_name   => t.tab,
      policy_name   => 'POL_REDACT_' || t.tab,
      action        => DBMS_REDACT.ADD_COLUMN,
      column_name   => 'TELEFONE',
      function_type => DBMS_REDACT.FULL
    );

    DBMS_REDACT.ALTER_POLICY(
      object_schema         => 'ADMIN',
      object_name           => t.tab,
      policy_name           => 'POL_REDACT_' || t.tab,
      action                => DBMS_REDACT.ADD_COLUMN,
      column_name           => 'EMAIL',
      function_type         => DBMS_REDACT.REGEXP,
      regexp_pattern        => DBMS_REDACT.RE_PATTERN_EMAIL_ADDRESS,
      regexp_replace_string => DBMS_REDACT.RE_REDACT_EMAIL_NAME
    );

    DBMS_REDACT.ALTER_POLICY(
      object_schema         => 'ADMIN',
      object_name           => t.tab,
      policy_name           => 'POL_REDACT_' || t.tab,
      action                => DBMS_REDACT.ADD_COLUMN,
      column_name           => 'CPF',
      function_type         => DBMS_REDACT.REGEXP,
      regexp_pattern        => '(\d{3})\.(\d{3})\.(\d{3})-(\d{2})',
      regexp_replace_string => '***.***.***-\4',
      regexp_position       => DBMS_REDACT.RE_BEGINNING,
      regexp_occurrence     => DBMS_REDACT.RE_FIRST
    );

    DBMS_REDACT.ALTER_POLICY(
      object_schema         => 'ADMIN',
      object_name           => t.tab,
      policy_name           => 'POL_REDACT_' || t.tab,
      action                => DBMS_REDACT.ADD_COLUMN,
      column_name           => 'CEP',
      function_type         => DBMS_REDACT.REGEXP,
      regexp_pattern        => '(\d{5})-(\d{3})',
      regexp_replace_string => '\1-***',
      regexp_position       => DBMS_REDACT.RE_BEGINNING,
      regexp_occurrence     => DBMS_REDACT.RE_FIRST
    );
  END LOOP;
END;
/

-- ------------------------------------------------------------
-- 2) Conferir (ADMIN). Esperado: 10 linhas (5 colunas x 2 tabelas)
-- ------------------------------------------------------------
SELECT object_name, policy_name, enable FROM redaction_policies;
SELECT object_name, column_name, function_type
  FROM redaction_columns
 ORDER BY object_name, column_name;

-- ============================================================
-- 3) TESTES (tabela de validação, 30 registros)
-- ============================================================

-- Teste A (ADMIN): dado real. Esta é a linha de base ("antes").
SELECT id, nome, cpf, cep, email, telefone
  FROM admin.dados_cadastrais_validacao
 ORDER BY id
 FETCH FIRST 5 ROWS ONLY;

-- >>>>>>>> A PARTIR DAQUI, LOGAR COMO USUARIO_TESTE <<<<<<<<

-- Teste B: a MESMA consulta. Esperado: nome e telefone em branco,
-- cpf ***.***.***-NN, cep NNNNN-***, e-mail com a parte do nome oculta (xxxx@dominio).
SELECT id, nome, cpf, cep, email, telefone
  FROM admin.dados_cadastrais_validacao
 ORDER BY id
 FETCH FIRST 5 ROWS ONLY;

-- Teste C: vazamento no texto livre (antes de proteger o TEXTO, etapa 05.2).
-- Esperado: a coluna nome vem em branco, mas o nome aparece em claro no texto.
SELECT id, nome, DBMS_LOB.SUBSTR(texto, 400, 1) AS trecho_texto
  FROM admin.dados_cadastrais_validacao
 ORDER BY id
 FETCH FIRST 3 ROWS ONLY;

-- Teste D: inferência pelo filtro. Usa o CPF da linha 4 (anotado no Teste A).
-- Para outra base, troque pelo CPF real anotado no Teste A.
-- Observado: 1 (o filtro enxerga o valor original mesmo com a exibição redigida).
SELECT COUNT(*) AS achou
  FROM admin.dados_cadastrais_validacao
 WHERE cpf = '547.621.893-91';
