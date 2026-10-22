-- ============================================================
-- TG - Etapa 06.1: k-anonimato por nível de generalização do CEP (Tabela 7 do TG)
-- Executar como: ADMIN (a consulta lê o CEP real). Somente leitura.
--
-- Quase-identificador: CEP (único campo da base passível de generalização).
-- Níveis: 8 dígitos (CEP completo), 5, 3 e 2 primeiros dígitos.
--
-- Atenção: os CEPs são sintéticos e aleatórios (Faker). O valor de k reflete
-- uma distribuição uniforme, não a geografia real, e tende a ser otimista.
--
-- Resultado observado (45.000 registros):
--   digitos | grupos | reducao_pct |  k | media | maior | unicos | pct_unicos | pct_<5
--         8 | 44987  |     0       |  1 |  1    |   2   | 44974  |   99,94    | 100
--         5 | 36126  |    19,7     |  1 |  1,2  |   5   | 28484  |   63,3     | 99,86
--         3 |  1000  |    97,78    | 26 | 45    |  65   |   0    |    0       | 0
--         2 |   100  |    99,78    |408 | 450   | 507   |   0    |    0       | 0
-- ============================================================
WITH niveis AS (
  SELECT 8 AS digitos FROM dual UNION ALL
  SELECT 5 FROM dual UNION ALL
  SELECT 3 FROM dual UNION ALL
  SELECT 2 FROM dual
),
grupos AS (
  SELECT n.digitos,
         SUBSTR(REPLACE(d.cep, '-', ''), 1, n.digitos) AS chave,
         COUNT(*) AS tamanho
    FROM admin.dados_cadastrais d
   CROSS JOIN niveis n
   GROUP BY n.digitos, SUBSTR(REPLACE(d.cep, '-', ''), 1, n.digitos)
)
SELECT digitos,
       COUNT(*) AS grupos,
       ROUND(100 * (1 - COUNT(*) / MAX(COUNT(*)) OVER ()), 2) AS reducao_pct,
       MIN(tamanho) AS k,
       ROUND(AVG(tamanho), 1) AS media_grupo,
       MAX(tamanho) AS maior_grupo,
       SUM(CASE WHEN tamanho = 1 THEN 1 ELSE 0 END) AS registros_unicos,
       ROUND(100 * SUM(CASE WHEN tamanho = 1 THEN 1 ELSE 0 END) / SUM(tamanho), 2) AS pct_unicos,
       ROUND(100 * SUM(CASE WHEN tamanho < 5 THEN tamanho ELSE 0 END) / SUM(tamanho), 2) AS pct_em_grupos_menores_que_5
  FROM grupos
 GROUP BY digitos
 ORDER BY digitos DESC;
