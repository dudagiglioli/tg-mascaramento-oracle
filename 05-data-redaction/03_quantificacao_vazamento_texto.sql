-- ============================================================
-- TG - Etapa 05.3: quantificação do vazamento no texto livre (Tabela 5 do TG)
-- Executar como: ADMIN (precisa ler os valores reais das colunas).
-- Tabela principal, 45.000 registros. Tempo observado: ~16 s.
--
-- Conta em quantos registros o valor da coluna aparece (correspondência
-- EXATA) dentro do campo texto. É um piso: variações de formato não entram.
--
-- Resultado observado:
--   total 45000 | nome 43560 (96,8%) | email 33705 (74,9%) | telefone 43750 (97,2%)
--   ssn 43750 (97,2%) | cpf 0 (0,0%)
-- O CPF dá 0 porque foi gerado depois e nunca foi inserido no texto (controle).
-- ============================================================
SELECT COUNT(*) AS total,
       SUM(CASE WHEN DBMS_LOB.INSTR(texto, nome)     > 0 THEN 1 ELSE 0 END) AS nome_no_texto,
       SUM(CASE WHEN DBMS_LOB.INSTR(texto, email)    > 0 THEN 1 ELSE 0 END) AS email_no_texto,
       SUM(CASE WHEN DBMS_LOB.INSTR(texto, telefone) > 0 THEN 1 ELSE 0 END) AS telefone_no_texto,
       SUM(CASE WHEN DBMS_LOB.INSTR(texto, ssn)      > 0 THEN 1 ELSE 0 END) AS ssn_no_texto,
       SUM(CASE WHEN DBMS_LOB.INSTR(texto, cpf)      > 0 THEN 1 ELSE 0 END) AS cpf_no_texto
  FROM admin.dados_cadastrais;
