# 05 Mascaramento dinâmico (Oracle Data Redaction)

Execute na ordem. **Cada script uma vez.**

| Ordem | Script | Executa como | Resultado |
|---|---|---|---|
| 1 | `00_usuario_teste.sql` | ADMIN | usuário sem privilégio de exceção, com login no Database Actions |
| 2 | `01_politicas_redacao.sql` | ADMIN (testes B a D como `usuario_teste`) | políticas em 5 colunas por tabela |
| 3 | `02_redacao_texto.sql` | ADMIN (testes E, F, D2 como `usuario_teste`) | `TEXTO` entra com redação total |
| 4 | `03_quantificacao_vazamento_texto.sql` | ADMIN | % de registros com o dado legível no texto |
| 5 | `04_teste_negativo_view.sql` | opcional | resultado negativo documentado (`ORA-28094`) |

## O que a política faz

- Uma política por tabela (limite do Oracle). A expressão aplica a redação a todos os
  usuários **exceto o ADMIN**: `SYS_CONTEXT('USERENV','SESSION_USER') != 'ADMIN'`.
- `NOME`, `TELEFONE`, `TEXTO`: redação total (em CLOB só existe a total).
- `EMAIL`: troca a parte local por `xxxx`. `CPF`: `***.***.***-NN`. `CEP`: `NNNNN-***`.

## Resultados observados

| Teste | Quem | Resultado |
|---|---|---|
| A | ADMIN | dados reais (linha de base) |
| B | `usuario_teste` | colunas redigidas conforme a política |
| C | `usuario_teste` | nome legível dentro do `texto` |
| D, D2 | `usuario_teste` | `COUNT` = 1: o filtro enxerga o valor original (CPF completo e prefixo) |
| E | `usuario_teste` | `texto` = `[redacted]` |
| F | `usuario_teste` | `COUNT` = 1: o conteúdo do texto continua pesquisável |
| view | `usuario_teste` | `ORA-28094` (teste negativo) |

Os testes de `usuario_teste` exigem **janela anônima** do navegador, com a URL do
Database Actions trocando `/ords/admin/` por `/ords/usuario_teste/`.
