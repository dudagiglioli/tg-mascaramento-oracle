# Técnicas de Mascaramento e Anonimização de Dados em Bancos Relacionais Oracle

Trabalho de Graduação (TG), Tecnologia em Banco de Dados, FATEC Bauru.
Autoras: Maria Eduarda Giglioli Guilice e Maria Luiza Busatto Truijo.
Orientador: Prof. Luis Alexandre da Silva.

Este repositório reúne os scripts e os resultados da parte experimental do TG
(capítulos 3 e 4): descoberta de dados sensíveis (Oracle Data Safe), mascaramento
dinâmico (Oracle Data Redaction), generalização do CEP com k-anonimato e tokenização
reversível do CPF. **Todos os dados são sintéticos.**

## Ambiente

| Item | Valor |
|---|---|
| Banco | Oracle Autonomous Database Serverless, camada Always Free, versão 19c, workload Transaction Processing |
| Região | Brazil East (São Paulo) |
| Acesso de rede | "Secure access from everywhere" |
| Interface | Database Actions (SQL Worksheet e Data Load), no navegador |
| Segurança | Oracle Data Safe (serviço da OCI) e Oracle Data Redaction (nativo do banco) |
| Preparação dos dados | Python 3.12, Faker 40.43.0 (pt_BR), pandas, openpyxl |

## Estrutura e ordem de execução

Execute as pastas na ordem numérica, **cada script uma vez**.

| Pasta | Executa como | O que faz | Conferência esperada |
|---|---|---|---|
| `01-preparacao-dados/` | máquina local (Python) | acrescenta CPF e CEP sintéticos às duas bases | Training: 45.000 CPFs válidos, 44.712 distintos. Testing: 30 válidos, 30 distintos |
| `02-estrutura/` | ADMIN | cria `dados_cadastrais` e `dados_cadastrais_validacao` | tabelas criadas |
| `03-carga/` | navegador + ADMIN | carrega os dados por tabela temporária e migra | 45.000 e 30 linhas |
| `04-data-safe/` | Console OCI + ADMIN | registra o banco, descobre dados sensíveis, teste em inglês | português: 4 linhas (EMAIL e SSN nas 2 tabelas). Inglês: 5 colunas |
| `05-data-redaction/` | ADMIN e `usuario_teste` | usuário de teste, políticas de redação, texto livre, quantificação | 10 linhas em `redaction_columns` (depois 12, com `TEXTO`). Vazamento: 43.560 / 33.705 / 43.750 / 43.750 / 0 |
| `06-generalizacao-k-anonimato/` | ADMIN e `usuario_teste` | mede k por nível do CEP e cria a tabela generalizada (3 dígitos) | k = 1, 1, 26, 408. Tabela: 45.000 registros, 1.000 grupos, k = 26, maior grupo 65 |
| `07-tokenizacao/` | ADMIN e `usuario_teste` | tokeniza o CPF (reversível) com mapeamento restrito ao ADMIN | 45.000 com token, 44.712 tokens únicos. `usuario_teste`: `ORA-00942` |

`resultados/` guarda as saídas exportadas e `docs/` guarda as figuras do TG.

## Convenção de usuários

- **ADMIN** cria tudo, tem acesso aos dados reais e é o único com acesso à tabela de mapeamento.
- **`usuario_teste`** representa o usuário comum, sem privilégio de exceção. Use janela anônima do
  navegador, trocando `/ords/admin/` por `/ords/usuario_teste/` na URL do Database Actions.
- O cabeçalho de cada script indica **quem executa** e o que é esperado.

## Como reproduzir

1. Crie uma conta na Oracle Cloud e um Autonomous Database com **Always Free** ligado,
   workload Transaction Processing e acesso "Secure access from everywhere". A senha do
   ADMIN tem 12 caracteres ou mais.
2. Obtenha os dados originais (ver "Dados") e coloque em `dados/`.
3. `pip install -r requirements.txt` e
   `python 01-preparacao-dados/gerar_cpf_cep.py --entrada dados --saida saida`.
4. Siga as pastas `02` a `07`.

Verificado: o script de preparação, com semente 42 e Faker 40.43.0, reproduz exatamente
os arquivos carregados no banco (os dados originais foram gerados com Faker 40.38.0, com
resultado idêntico).

## Dados

Os arquivos de dados **não são versionados** (volume e licença de terceiros).

- Fonte: **[PREENCHER: nome do conjunto de dados, URL e licença]**
- Arquivos: `Training_Set.xlsx` (45.000 registros) e `Testing_Set.xlsx` (30 registros),
  com as colunas Name, Credit Card, Email, URL, Phone, Address, Company, SSN, Text e True Predictions.
- CPF e CEP foram acrescentados pelo script da etapa 01, pois a base original traz SSN e ZIP code
  norte-americanos.

## Problemas conhecidos

| Sintoma | Causa | Solução |
|---|---|---|
| `ORA-28003` com `ORA-20000: password length less than 12 bytes` | senha do usuário curta | 12 a 30 caracteres, com maiúscula, minúscula e número, sem aspas duplas nem o nome do usuário |
| `ORA-00904: "CLOB"` (em `DBMS_INGEST`) no Data Load | tipo CLOB na carga | carregar `Text` e `True Predictions` como VARCHAR2 (`03-carga/`) |
| `ORA-00904: "True Predictions"` na migração | colunas da tabela temporária ficam em maiúsculas e sem espaço | usar `TRUE_PREDICTIONS` |
| `ORA-00937` na conferência da generalização | subconsulta escalar misturada com agregação (versão antiga do script) | já corrigido (`SUM(n)`) |
| `ORA-28094` ao consultar uma view | view com expressão sobre coluna com política de redação (19c) | usar tabela estática (`06-`); ver `05-.../04_teste_negativo_view.sql` |
| `ORA-00942` | sem privilégio, ou tabela inexistente (a mensagem é a mesma) | esperado nos testes de acesso |
| `usuario_teste` não abre o SQL Worksheet | schema sem ORDS habilitado | `ORDS_ADMIN.ENABLE_SCHEMA` (`05-.../00_usuario_teste.sql`) |
| Tabela nova não aparece no Data Safe | metadados desatualizados | **Refresh database schemas** |
| Banco em `Stopped` | o Always Free para após 7 dias sem conexão | **Start** no Console OCI |


## Limitações

- **Dados sintéticos.** Os CEPs são aleatórios e uniformes, o que torna o k otimista. O Faker sorteia os 9 primeiros dígitos do CPF sem repetição (3.628.800 valores possíveis), por isso há 288 CPFs repetidos entre 45.000 registros.
- O k foi medido apenas sobre o CEP. Não houve teste de reidentificação por cruzamento com fontes externas.
- O comportamento foi observado em uma versão do banco (19c) e na camada gratuita.
- O texto livre foi apenas ocultado na exibição (redação total) ou suprimido da tabela generalizada, não sanitizado.
- A tokenização é reversível: caracteriza pseudonimização, não anonimização.

## Segurança do repositório

- Nunca versione o **wallet** do banco nem senhas. O `.gitignore` cobre o wallet, e os scripts trazem apenas senhas de exemplo.
- Recorte os prints antes de versionar: a barra de endereço mostra o host do banco.
- CPFs, e-mails e tokens que aparecem nos resultados são sintéticos.
