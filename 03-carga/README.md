# 03 Carga dos dados (Data Load + migração)

A carga usa uma **tabela temporária** criada pelo Data Load e depois migrada por SQL
para as tabelas definitivas. O caminho direto ("Inserir na Tabela" com mapeamento
manual por lista suspensa) não funcionou: as listas de coluna não carregaram.

## Passo a passo (Database Actions, no navegador)

1. **Carga de Dados > Carregar Dados > Arquivo Local** e selecione
   `Training_Set_com_CPF_CEP.xlsx` (gerado na etapa 01).
2. Em **Revisar Definições**, deixe **Opção = Criar Tabela** (nome sugerido: `SHEET1`).
3. Na lista de colunas, troque o tipo de **Text** e **True Predictions** de `CLOB` para
   **`VARCHAR2`**. Com `CLOB`, a carga falha com
   `ORA-00904: "CLOB": invalid identifier` (em `DBMS_INGEST`) e deixa a tabela criada e
   vazia. Se isso acontecer, `DROP TABLE SHEET1;` e refaça.
4. **Fechar** e depois **Início**.
5. Rode `verificar_colunas_temp.sql`: as colunas ficam em MAIÚSCULAS e sem espaço
   (`NAME`, `CREDIT_CARD`, ..., `TEXT`, `TRUE_PREDICTIONS`).
6. Rode `migrar_treinamento.sql`. Conferência: **45.000** linhas em `dados_cadastrais`.
7. `DROP TABLE SHEET1;`
8. Repita 1 a 4 com `Testing_Set_com_CPF_CEP.xlsx` e rode `migrar_validacao.sql`
   (**modelo**: troque `NOME_DA_TABELA_TEMP` pelo nome real). Conferência: **30** linhas
   em `dados_cadastrais_validacao`.

## Limpeza

Cargas com erro deixam tabelas residuais (por exemplo `ADP$ERR$SHEET1_41`). Apague-as
antes da etapa 04: o Data Safe as varre e elas aparecem nos resultados.
