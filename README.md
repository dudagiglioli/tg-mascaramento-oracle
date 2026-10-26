# Técnicas de Mascaramento e Anonimização de Dados em Bancos Relacionais Oracle

Trabalho de Graduação (TG), Tecnologia em Banco de Dados, FATEC Bauru.

**Autoras:** Maria Eduarda Giglioli Guilice e Maria Luiza Busatto Truijo.  
**Orientador:** Prof. Luis Alexandre da Silva.

Este repositório reúne os scripts e os resultados da parte experimental do TG (capítulos 3 e 4): descoberta de dados sensíveis com Oracle Data Safe, mascaramento dinâmico com Oracle Data Redaction, generalização do CEP com k-anonimato e tokenização reversível do CPF.

**Todos os dados utilizados são sintéticos.**

## Conteúdo do repositório

```text
.
├── 01-preparacao-dados/
├── 02-estrutura/
├── 03-carga/
├── 04-data-safe/
├── 05-data-redaction/
├── 06-generalizacao-k-anonimato/
├── 07-tokenizacao/
├── resultados/
├── .gitattributes
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt
```

## Ambiente

| Item | Valor |
|---|---|
| Banco de dados | Oracle Autonomous Database Serverless, camada Always Free, versão 19c, workload Transaction Processing |
| Região | Brazil East (São Paulo) |
| Acesso de rede | Secure access from everywhere |
| Interface | Database Actions (SQL Worksheet e Data Load), no navegador |
| Segurança | Oracle Data Safe (serviço da OCI) e Oracle Data Redaction (nativo do banco) |
| Preparação dos dados | Python 3.12, Faker 40.43.0 (pt_BR), pandas e openpyxl |

## Estrutura e ordem de execução

Execute as pastas na ordem numérica, respeitando as instruções de cada script. Os scripts devem ser executados uma única vez, salvo indicação em contrário.

| Pasta | Executa como | O que faz | Conferência esperada |
|---|---|---|---|
| `01-preparacao-dados/` | Máquina local (Python) | Acrescenta CPF e CEP sintéticos às duas bases | Training: 45.000 CPFs válidos, 44.712 distintos. Testing: 30 válidos, 30 distintos |
| `02-estrutura/` | ADMIN | Cria `dados_cadastrais` e `dados_cadastrais_validacao` | Tabelas criadas |
| `03-carga/` | Navegador + ADMIN | Carrega os dados por tabela temporária e migra | 45.000 e 30 linhas |
| `04-data-safe/` | Console OCI + ADMIN | Registra o banco, descobre dados sensíveis e realiza teste em inglês | Português: 4 linhas (EMAIL e SSN nas duas tabelas). Inglês: 5 colunas identificadas |
| `05-data-redaction/` | ADMIN e `usuario_teste` | Cria usuário de teste, políticas de redação, testes com texto livre e quantificação | 10 linhas em `redaction_columns`, depois 12 com `TEXTO`. Valores de vazamento observados: 43.560 / 33.705 / 43.750 / 43.750 / 0 |
| `06-generalizacao-k-anonimato/` | ADMIN e `usuario_teste` | Mede k por nível do CEP e cria tabela generalizada com três dígitos | k = 1, 1, 26, 408. Tabela: 45.000 registros, 1.000 grupos, k = 26 e maior grupo com 65 registros |
| `07-tokenizacao/` | ADMIN e `usuario_teste` | Tokeniza o CPF de forma reversível, com mapeamento restrito ao ADMIN | 45.000 registros com token, 44.712 tokens únicos. Acesso de `usuario_teste` ao mapeamento negado com `ORA-00942` |

A pasta `resultados/` contém as saídas exportadas dos experimentos.

## Convenção de usuários

- **ADMIN:** cria os objetos do banco, tem acesso aos dados originais e é o único usuário autorizado a consultar a tabela de mapeamento da tokenização.
- **`usuario_teste`:** representa o usuário comum, sem privilégios de exceção. Para testar o acesso, utilize uma janela anônima do navegador, trocando `/ords/admin/` por `/ords/usuario_teste/` na URL do Database Actions.
- O cabeçalho de cada script informa qual usuário deve executá-lo e qual resultado é esperado.

## Como reproduzir

1. Crie uma conta na Oracle Cloud e um Autonomous Database com a camada Always Free habilitada, workload Transaction Processing e acesso de rede configurado como Secure access from everywhere.
2. Baixe os arquivos originais do conjunto de dados indicado na seção **Dados** e coloque-os em uma pasta `dados/`, criada localmente na raiz do projeto.
3. Instale as dependências Python:

   ```bash
   pip install -r requirements.txt
   ```

4. Execute a preparação dos dados:

   ```bash
   python 01-preparacao-dados/gerar_cpf_cep.py --entrada dados --saida saida
   ```

5. Siga as instruções das pastas `02-estrutura/` a `07-tokenizacao/`, utilizando o usuário indicado no cabeçalho de cada script.

A preparação dos dados foi verificada com semente 42 e Faker 40.43.0, reproduzindo os arquivos carregados no banco. Os dados originais haviam sido gerados com Faker 40.38.0, com resultado idêntico.

## Dados

O projeto utiliza o conjunto de dados **Synthetic Dataset for PII Detection and Anonymization in Financial Documents**, disponibilizado no Mendeley Data.

- **Autores da base:** Kushagra Mishra, Harsh Pagare, Ranjeet Bidwe e Sashikala Mishra.
- **Ano de publicação:** 2024.
- **Versão:** 1.
- **DOI:** [10.17632/tzrjx692jy.1](https://doi.org/10.17632/tzrjx692jy.1).
- **Página da base:** [Mendeley Data](https://data.mendeley.com/datasets/tzrjx692jy/1).
- **Licença da base original:** Creative Commons Attribution 4.0 International (CC BY 4.0).

Os arquivos de dados não são versionados neste repositório devido ao volume. Para reproduzir os experimentos, obtenha-os diretamente na fonte original e observe os termos da licença.

Os arquivos utilizados são:

- `Training_Set.xlsx`: 45.000 registros.
- `Testing_Set.xlsx`: 30 registros.

As colunas originais são `Name`, `Credit Card`, `Email`, `URL`, `Phone`, `Address`, `Company`, `SSN`, `Text` e `True Predictions`.

O conjunto de dados original contém informações sintéticas, incluindo SSN e códigos postais norte-americanos. O script da etapa 01 acrescenta CPF e CEP sintéticos para os experimentos realizados neste trabalho.

## Problemas conhecidos

| Sintoma | Causa | Solução |
|---|---|---|
| `ORA-28003` com `ORA-20000: password length less than 12 bytes` | Senha curta ou incompatível com a política do banco | Utilize uma senha de 12 a 30 caracteres, com maiúsculas, minúsculas e números, sem aspas duplas nem o nome do usuário |
| `ORA-00904: "CLOB"` no Data Load | Tipo CLOB incompatível com a carga utilizada | Carregue `Text` e `True Predictions` como `VARCHAR2`, conforme o script da pasta `03-carga/` |
| `ORA-00904: "True Predictions"` na migração | Nome da coluna normalizado para maiúsculas e sem espaços | Utilize `TRUE_PREDICTIONS` |
| `ORA-00937` na conferência da generalização | Subconsulta escalar misturada com agregação em uma versão anterior do script | Utilize a versão corrigida com `SUM(n)` |
| `ORA-28094` ao consultar uma view | Expressão sobre coluna com política de redação no Oracle 19c | Utilize a tabela estática da pasta `06-generalizacao-k-anonimato/` e consulte `05-data-redaction/04_teste_negativo_view.sql` |
| `ORA-00942` | Objeto inexistente ou falta de privilégios | Nos testes de tokenização, esse erro é esperado quando `usuario_teste` tenta acessar a tabela de mapeamento restrita |
| `usuario_teste` não abre o SQL Worksheet | Schema sem ORDS habilitado | Habilite o schema conforme o script `05-data-redaction/00_usuario_teste.sql` |
| Tabela nova não aparece no Data Safe | Metadados desatualizados | Execute *Refresh database schemas* |
| Banco aparece como `Stopped` | Instância parada (bancos Always Free podem ser parados após período de inatividade) | Inicie o banco pelo Console OCI |

## Limitações

- **Dados sintéticos:** os CEPs são aleatórios e uniformes, o que torna o k observado potencialmente otimista em relação a uma distribuição populacional real.
- **CPF:** o Faker sorteia os nove primeiros dígitos do CPF sem repetição dentro do espaço de 3.628.800 combinações possíveis. Por isso, há 288 CPFs repetidos entre 45.000 registros.
- **k-anonimato:** o k foi medido apenas sobre o CEP. Não houve teste de reidentificação por cruzamento com fontes externas.
- **Escopo do ambiente:** o comportamento foi observado em uma versão do banco (19c) e na camada gratuita.
- **Oracle Data Safe:** os resultados da descoberta automática foram observados entre setembro e outubro de 2026 e podem variar conforme atualizações da biblioteca de tipos sensíveis do serviço.
- **Texto livre:** o conteúdo foi ocultado na exibição por redação total ou suprimido da tabela generalizada; não foi realizada sanitização semântica completa do texto.
- **Tokenização:** como é reversível mediante o mapeamento restrito, caracteriza pseudonimização, não anonimização irreversível.

## Segurança do repositório

Os scripts utilizam apenas valores de exemplo; nenhuma credencial real deve ser versionada (wallet do banco, senhas, chaves ou arquivos de ambiente). Todos os CPFs, e-mails, tokens e demais valores exibidos nos resultados são sintéticos.

## Como citar

Se este material for útil ao seu trabalho, cite o TG e este repositório:

```bibtex
@misc{guilice_truijo2026,
  author = {Guilice, Maria Eduarda Giglioli and Truijo, Maria Luiza Busatto},
  title  = {Técnicas de Mascaramento e Anonimização de Dados em Bancos Relacionais Oracle},
  year   = {2026},
  note   = {Trabalho de Graduação, Fatec Bauru},
  url    = {https://github.com/dudagiglioli/tg-mascaramento-oracle}
}
```

## Licença

- **Scripts e documentação:** licença MIT (ver arquivo [LICENSE](LICENSE)).
- **Conjunto de dados original:** mantém a licença CC BY 4.0 de seus autores (Mishra et al., 2024) e não está incluído neste repositório.
