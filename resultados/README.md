# Resultados exportados

Saídas das consultas, exportadas do SQL Worksheet. Todos os dados são **sintéticos**.

| Arquivo | Script de origem | Executado como | Alimenta no TG |
|---|---|---|---|
| `vazamento_texto_45000.csv` | `05-data-redaction/03_quantificacao_vazamento_texto.sql` | ADMIN | Tabela 5 |
| `k_anonimato_cep.csv` | `06-.../01_k_anonimato_cep.sql` | ADMIN | Tabela 7 |
| `generalizada_conferencia.csv` | `06-.../02_tabela_generalizada.sql` (conferência) | ADMIN | seção 4.5 |
| `generalizada_H1_colunas.csv` | `06-.../02_tabela_generalizada.sql` (H1) | `usuario_teste` | seção 4.5 |
| `generalizada_H2_menores_regioes.csv` | `06-.../02_tabela_generalizada.sql` (H2) | `usuario_teste` | seção 4.5 |
| `tokenizacao_conferencia.csv` | `07-tokenizacao/tokenizacao_cpf.sql` (conferência) | ADMIN | seção 4.6 |
| `tokenizacao_cpfs_distintos.csv` | `07-tokenizacao/tokenizacao_cpf.sql` | ADMIN | seção 4.6 |
| `tokenizacao_reversao_admin.csv` | `07-tokenizacao/tokenizacao_cpf.sql` (reversão) | ADMIN | Tabela 8 |

`vazamento_texto_45000.csv` foi **transcrito do print** da consulta (ela foi exibida na tela,
não exportada). Os CPFs de `tokenizacao_reversao_admin.csv` são sintéticos.
