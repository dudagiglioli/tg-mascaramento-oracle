# 04 Oracle Data Safe (descoberta de dados sensíveis)

Esta etapa é feita pela interface web do Console OCI, sem script de descoberta.
O Data Safe é um serviço da OCI: só funciona com banco hospedado na nuvem Oracle.

## 1. Registrar o banco

1. Console OCI > **Oracle AI Database > Data Safe - Database Security**
   (aba **General**, não "Documentation").
2. **Register Autonomous AI database** e selecione o banco. Com acesso de rede
   "Secure access from everywhere" o assistente avisa que **não precisa de private endpoint**.
3. Conclua o registro. O status passa de `Creating` para `Active` em alguns minutos
   e o Data Safe cria sozinho os recursos de auditoria e avaliação.

## 2. Modelo de dados sensíveis (base em português)

Na página do target database: **Discovery and masking > Sensitive data models > View list**
(ou menu lateral **Data discovery > Sensitive data models**) > **Create sensitive data model**:

| Passo | Escolha |
|---|---|
| Nome | `tg-mascaramento-modelo` |
| Schemas | "Select specific schemas only" > `ADMIN` |
| Tabelas | "All tables" |
| Tipos sensíveis | todos (caixa do cabeçalho da lista) |
| Opções | marcar "Collect, display and store sample data"; deixar desmarcada a descoberta de relacionamentos de aplicação |

A descoberta roda na própria criação. Resultados: abra o modelo > aba **Sensitive columns**.

**Esperado:** 4 linhas (`EMAIL` e `SSN` em `DADOS_CADASTRAIS` e em `DADOS_CADASTRAIS_VALIDACAO`).

## 3. Teste com colunas em inglês

1. Rode `criar_tabela_teste_ingles.sql` (ADMIN).
2. Crie um **segundo modelo** (`tg-mascaramento-modelo-en`) selecionando só `DADOS_CADASTRAIS_EN`.
   Se a tabela não aparecer na lista, use **Refresh database schemas** e aguarde 100%.
3. **Não** adicione a tabela ao modelo existente com "Add columns" e "Run discovery now":
   as colunas entram sem classificação ("Total new columns: 0", confiança `NONE`).

**Esperado:** 5 linhas, todas com confiança `HIGH`: `NAME` (Full Name), `PHONE` (Phone Number),
`ADDRESS` (Full Address), `EMAIL` (Email Address), `SSN` (US SSN).
`CPF`, `CEP`, `COMPANY` e `CREDIT_CARD` não são classificados.

## Observação

A faixa roxa "To use this service or resource, you must upgrade to a paid account" apareceu
durante o trabalho e não impediu nenhuma das ações realizadas na camada Always Free.
