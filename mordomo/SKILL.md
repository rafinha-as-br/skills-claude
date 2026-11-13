---
name: mordomo
description: Quando Rafinha pedir para iniciar, acompanhar, liberar ou revisar uma execução Claude pelo Mordomo, coordena localmente as contas A e B, bloqueia concorrência e emite revisão independente para mudança simples nos modos A ou C.
---

# Mordomo local

Coordena localmente duas contas do Claude Code no Windows a partir do workspace
explícito da sessão atual. O controlador instalado fica em
`C:\Users\rafin\workflow-mordomo\mordomo.ps1`; ele separa os perfis A e B,
mantém logs e locks por issue e repositório e produz uma revisão independente
em somente leitura.

## Contrato da skill

### Finalidade

Executar e supervisionar uma tarefa explicitamente delegada ao Claude Code,
sem permitir que duas sessões mutantes operem a mesma issue ou o mesmo
repositório; depois, avaliar se a mudança pode substituir `Análise - Rafinha`
por uma atestação automatizada de mudança simples.

### Escopo e acionamento

É acionada somente por comando explícito de Rafinha, com issue, conta A ou B,
workspace aberto na sessão atual, tarefa delimitada e modo de integração
informado. Atua em uma issue por despacho. A revisão de autoridade se aplica
somente aos modos A e C.

### Autoridade

- **Decisão.** Classifica uma mudança como `APPROVE_SIMPLE`,
  `REVIEW_REQUIRED` ou `BLOCKED` pelos critérios desta skill. Em A/C,
  `APPROVE_SIMPLE` só autoriza integração quando arquitetura, segurança,
  testes, build e pipeline estão `PASS`, não há lacuna de evidência e a revisão
  humana não é necessária. Na dúvida, exige revisão humana.
- **Mutação.** Cria e remove logs e locks locais do controlador. Depois de uma
  atestação efetiva A/C, registra no Jira o claim e o resultado estruturado da
  revisão, exclusivamente para a issue fechada; não altera Confluence, GitHub,
  branches, commits ou arquivos do workspace por autoridade própria.
- **Atestação.** Emite `authorizationEffective: true` no relatório local apenas
  para uma mudança simples A/C que satisfaz todos os critérios objetivos. Essa
  atestação é a entrada para a `jira-integration-executor`; não substitui os
  gates, claim, checks ou evidências que essa skill precisa revalidar.
- **Transição.** Move a issue normal de `Análise - Rafinha` para `Integração`
  somente após atestação efetiva A/C e registro do resultado. A integração é
  executada pela `jira-integration-executor`, com o relatório como evidência.

### Entradas, obrigações e saída

Entradas: escopo fechado, workspace Git explícito, conta A/B, prompt
delimitado, perfil disponível e, para revisão, modo A/C, base de comparação e
referência do PR quando existente. Obrigações: preservar os locks de issue e
repositório até o término; não inferir workspace; executar o revisor em
somente leitura; identificar a conta em log; bloquear autorização quando faltar
qualquer evidência obrigatória. Saída: `runId`, logs, estado local e, quando
solicitado, `review-report.json` com decisão, achados, evidências e necessidade
de revisão humana.

### Limites e delegações

Modo B é sempre manual de Rafinha e nunca é autorizado por esta skill. Ela não
decide regra de negócio, design, decisão técnica não determinística ou aceite
de produto. Lock local não substitui claim no Jira. Merge, comentário, claim e
transição pertencem às skills donas e permanecem sujeitos ao Contrato do
Workflow. O despacho do Claude não usa opções para pular permissões.

> Defaults herdados (silêncio não concede autoridade, acesso técnico não é
> autoridade, delegação não transfere autoridade etc.):
> `workflow-development-flow/references/contrato-skills.md`.

## Model Policy

Nível padrão: 2 — execução e revisão de código com verificação de evidências.

Escalar para 3 quando a alteração cobrir múltiplos módulos, integração entre
repositórios ou arquitetura não trivial. Nunca escalar automaticamente.

## Operação

1. Apresente escopo, fora do escopo, impacto retroativo, riscos e pendências.
2. Confirme issue, conta, workspace atual e instrução delimitada. Não escolha
   outro diretório por inferência.
3. Use `Validate` quando precisar verificar perfis, inicializadores, CLIs e raiz
   Git; esta verificação não inicia uma tarefa.
4. Gere a tarefa JSON e chame `Dispatch`. Use `Status` para acompanhar a sessão
   e os locks; `Release` exige confirmação explícita e processo encerrado.
5. Com `review.enabled`, leia `review-report.json`. Só trate A/C como
   autorizado quando `decision` for `APPROVE_SIMPLE`,
   `authorizationEffective` for `true` e `mergeAuthorization` corresponder ao
   modo solicitado.
6. Para uma autorização efetiva, leia primeiro o Jira, pare diante de claim
   vigente de outro executor, abra o claim do Mordomo, registre o relatório e
   mova somente a issue normal de `Análise - Rafinha` para `Integração`.
   Em seguida, entregue o relatório à `jira-integration-executor`: ela abre o
   próprio claim, revalida gates e checks e executa o merge dentro do próprio
   contrato. Para B, pare e peça a autorização manual distinta de Rafinha.

## Critério de mudança simples

Todos os itens devem estar comprovados: alteração pequena e isolada; nenhuma
mudança de arquitetura, regra de negócio, API/contrato público,
autenticação/autorização, dados/schema, dependência, infraestrutura, CI/CD ou
configuração sensível; arquitetura local lida e respeitada; testes, build e
pipeline verdes; nenhuma lacuna relevante de evidência.

Leia `C:\Users\rafin\workflow-mordomo\policy\review-policy.md` para o
detalhamento operacional do controlador.
