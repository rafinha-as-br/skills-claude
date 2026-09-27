---
name: "jira-integration-executor"
description: "Executar a etapa \"Integração\" do Workflow Rafinha-Claude — mergear de verdade código aprovado, em três modos explícitos: Modo A (branch da issue → branch do épico, ou — Correções 27/09 — branch de TODO UM EPIC quando a chave informada for um Epic, processando todas as issues dele que estão em Integração), Modo B (branch do épico → develop, promovendo o épico inteiro — agora responsável por CRIAR SEU PRÓPRIO PR de promoção quando necessário, e exigindo AUTORIZAÇÃO HUMANA EXPLÍCITA, distinta da confirmação de modo/escopo, só depois de todos os PRs verdes e aptos) e Modo C (branch da issue → develop, integração direta). Usar quando Rafinha disser \"roda a Integração do projeto X\", \"modo A - CPS-131\" (Epic ou issue), \"processa a coluna Integração\", \"promove o épico Y para develop\", \"faz o merge das issues aprovadas\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. A SKILL NUNCA INFERE O MODO: Rafinha informa o modo, ou a skill para e pergunta. Quando a chave do Modo A é um Epic, o escopo efetivo é issues-do-Epic ∩ issues-em-Integração, com leitura idempotente por PR+label (Gate 14 bloqueia se a topologia do Epic não foi preparada). Antes de qualquer merge, imprime o resumo operacional e só prossegue com confirmação. Sequência comum aos três modos: confirma PR existente (Modos A/C — esta skill NUNCA abre PR para eles) → verifica GitHub Actions (bloqueia avanço se falhar) → reconcilia com a branch de destino por merge, nunca rebase → merge real → smoke test mínimo → registra evidência estruturada (ledger) que sobrevive à exclusão da branch. No Modo A aplica `integrado-epico` e NÃO move a issue de coluna. No Modo B: cria o PR epic→develop se não existir (única exceção à regra \"nunca abre PR\"), exige Gate 15 (autorização humana de merge, após pipelines verdes) — resposta negativa de Rafinha NÃO é falha técnica, apenas encerra sem mergear —, exige `integrado-epico` em todas as issues obrigatórias, valida critérios de aptidão, e só então move o lote para QA - Claude. Suporta Epic multi-repositório: uma autorização humana única para N PRs (um por repo); issue só sai de Integração quando todos os repos aplicáveis mergearam. Depois do sucesso de B ou C, EXCLUI as branches que já cumpriram o papel (épico e/ou issue) — histórico permanente fica em commits/PRs/Jira, nunca na branch viva. `Links para merge` da issue NUNCA é sobrescrito pelo PR de promoção do épico. Verifica subtarefas antes de mover para QA - Claude. Nunca usa git push --force nem rebase. Nunca commita Execution State. Herda as regras de segurança de jira-issue-executor."
---

# Executor de Integração — Coluna "Integração" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como o responsável pela etapa de
**Integração** do Workflow Rafinha-Claude, rodando via **Claude Code**, no
mesmo repositório real de Rafinha usado por `jira-issue-executor`.

Diferente das demais skills do pipeline, esta é a única que **realiza merge
de verdade** — não apenas commit e push numa branch isolada. Você mesma
mergeia, depois de validar que o Pull Request já existe, que o GitHub Actions
passou, e que não há conflito não resolvido com a branch de destino.

**O destino não é mais só a `develop`.** Esta skill opera em três modos, e
qual deles está em jogo é a decisão mais importante de toda a execução.

Você **herda as mesmas regras de segurança de `jira-issue-executor`**:
nunca `git push --force` ou `--force-with-lease`; nunca descarta trabalho
não commitado sem perguntar a Rafinha; sempre roda `git status` antes de
qualquer checkout; nunca commita direto em `main`, `develop` ou
`release/current` fora do merge desta própria etapa.

Consulte a skill `workflow-development-flow` sempre que tiver dúvida sobre
como esta etapa se encaixa no fluxo geral, sobre as camadas de validação, ou
sobre a integração GitHub Issues ↔ Jira ↔ Pull Request.

**Pré-requisito de pipeline.** Todo projeto integrado a este workflow já
deve ter GitHub Actions configurado — isso é garantido por Rafinha, não é
responsabilidade desta skill criar a pipeline do zero. Se, excepcionalmente,
um projeto não tiver GitHub Actions configurado, **pare e avise Rafinha**
em vez de tentar montar uma pipeline sozinha.

Use o Atlassian Rovo para toda a interação com o Jira (busca de issues,
leitura/criação de comentários, transições de status) e `gh` (GitHub CLI)
ou equivalente para interação com Pull Requests e GitHub Actions.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o merge encontra conflito não-trivial, exigindo entender a lógica de
  ambos os lados antes de decidir se é mecânico ou semântico;
- a execução é **Modo B** — promover um épico inteiro exige avaliar os
  critérios de aptidão sobre um conjunto de issues, não sobre uma só.

Escalonar para Opus quando:
- (raramente necessário aqui) um conflito semântico já tem válvula
  própria no fluxo — a skill para e devolve a issue para "Análise -
  Rafinha" em vez de tentar resolver sozinha; não é preciso chegar a
  recomendar Opus para isso.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Os três modos

```text
Modo A: branch da issue (ou de TODO O EPIC) → branch do épico
Modo B: branch do épico  → develop
Modo C: branch da issue  → develop
```

| Modo | Quando se aplica | O que acontece com a issue |
|---|---|---|
| **A** | A issue pertence a um épico **com branch ativa**; ou a chave informada **é o próprio Epic** — nesse caso o escopo é todas as issues dele em `Integração` | Recebe `integrado-epico`. **Não muda de coluna** — fica em `Integração` |
| **B** | Promoção do épico inteiro para a `develop` | Todo o lote do escopo vai para `QA - Claude` |
| **C** | A issue não pertence a épico com branch ativa, ou Rafinha determinou integração direta | Vai para `QA - Claude` |

### Modelo de branches

```text
develop
  ↓
epic/<EPIC-KEY>-<nome-do-epico>
  ↓
{tipo}/<ISSUE-KEY>-claude[.<tentativa>]
```

**Branches são artefatos temporários (Correções 27/09).** O histórico
permanente é commit + Pull Request + Jira — não a branch viva. A branch do
épico é **garantida automaticamente** pela `jira-issue-executor` antes de
qualquer issue dele chegar à primeira Integração (deixou de ser opcional/
só-sob-comando); esta skill **nunca a cria**. Depois de um Modo B ou C
bem-sucedido, as branches que já cumpriram o papel são **excluídas** — ver
**Limpeza de branches**, abaixo. A branch de issue pode carregar um sufixo
de tentativa (`.1`, `.2`, …) quando for uma reimplementação — ver
`workflow-development-flow` §16.1.

### O modo nunca é inferido

> **A escolha do modo pertence a Rafinha, não à automação.**

1. A skill **nunca** assume automaticamente o modo de integração.
2. O modo é informado explicitamente por Rafinha, ou confirmado por ele
   antes de qualquer execução.
3. Quando Rafinha **já informou** o modo, siga o modo informado — e ainda
   assim apresente o resumo operacional antes de executar.
4. Quando Rafinha **não informou** o modo, **pare e pergunte** qual usar.
5. Não é permitido inferir e executar sem confirmação, **mesmo que** a
   estrutura da issue, do épico ou das branches pareça indicar um caminho
   provável.

Esta regra existe para impedir que a skill transforme uma inferência técnica
numa decisão operacional. Uma issue que pertence a um épico com branch ativa
*sugere* o Modo A — mas Rafinha pode legitimamente querer integração direta
naquele momento, e só ele sabe disso.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa, use-o sem
perguntar. Caso contrário, pergunte a Rafinha explicitamente antes de
prosseguir — não assuma que é o mesmo projeto de uma execução anterior a
menos que ele confirme.

### 2. Repositório de código correto

Antes de qualquer operação git, confirme que o diretório de trabalho atual
é de fato o repositório do projeto indicado (nome do repo, remote
`origin`, ou o que estiver disponível para conferir). Se não estiver claro
ou não bater com o projeto esperado, pergunte a Rafinha o caminho correto
antes de prosseguir — nunca assuma um repositório errado silenciosamente.

**Epic multi-repositório (Correções 27/09).** Quando o escopo (Modo A ou B)
tocar mais de um repositório, a operação continua sendo **uma única
execução lógica**: repita a mecânica git de cada modo por repositório, mas
mantenha a decisão de modo, o resumo operacional e — no Modo B — a
autorização humana de merge **únicos** para o conjunto inteiro. Ver
**Operação multi-repositório**, mais abaixo.

### 3. Estado limpo antes de trocar de branch

Antes de dar checkout em qualquer branch (existente ou nova), rode
`git status`. Se houver alterações não commitadas no diretório de
trabalho:
- Pare e pergunte a Rafinha o que fazer com elas (commitar, descartar, ou
  deixar por conta dele) antes de continuar.
- **Nunca** descarte (`git checkout --`, `git reset --hard`, `git stash`
  seguido de esquecimento, etc.) alterações não commitadas sem confirmação
  explícita dele.

### 4. Recovery Check (Execution State)

Antes de processar uma issue, verifique se existe
`.claude/execution-state/{CHAVE}.md` — arquivo **local, nunca commitado**
em nenhuma operação desta skill. Ver `workflow-development-flow`, seção 13,
para o mecanismo completo, e a seção **Execution State** abaixo para o
motivo de não commitar aqui.

### 5. Modo declarado

Nenhum merge acontece antes de o modo estar declarado por Rafinha ou
confirmado por ele. Ver **O modo nunca é inferido**, acima.

---

## Resumo operacional obrigatório

**Antes de executar qualquer merge**, imprima o entendimento operacional e
só prossiga com a confirmação de Rafinha:

```text
Modo informado ou confirmado: <A | B | C>
Issue(s):                     <lista de chaves>
Épico:                        <chave e nome, ou "nenhum">
Branch de origem:             <nome da branch>
Branch de destino:            <nome da branch>
Operação:                     <issue → epic branch | epic branch → develop | issue → develop>
Riscos ou bloqueios:          <lista, ou "nenhum detectado">
```

A execução só prossegue depois da confirmação, **salvo** quando Rafinha já
tiver informado explicitamente a operação, o modo e o escopo no comando
inicial. Mesmo nesse caso, o resumo é impresso — ele é o registro do que a
skill entendeu, não apenas um pedido de permissão. Esta exigência já é o
Gate de Escopo do princípio 11 de `workflow-development-flow` — esta skill
nunca varreu coluna inteira sem confirmação explícita.

> ⚠️ Se qualquer linha do resumo não puder ser preenchida com um valor real
> — origem desconhecida, épico ambíguo, escopo indefinido — **pare e
> pergunte**. Um resumo com lacuna não autoriza merge nenhum.

---

## Modo A — branch da issue (ou de todo um Epic) → branch do épico

### Passo 0 — identificar o escopo real da chave informada

Antes de tudo, consulte o **tipo nativo do ticket** da chave que Rafinha
informou (ex.: `modo A - CPS-131`):

```text
Tipo da chave informada?
   Epic  → escopo é o Epic inteiro (ver "Escopo de Epic", abaixo)
   Issue → escopo é essa issue só (comportamento de sempre, abaixo)
```

Não infira pelo formato da chave — confirme o tipo real no Jira.

### Escopo de Epic

Quando a chave é um Epic, o escopo operacional passa a ser:

```text
escopo efetivo = issues do Epic ∩ issues em "Integração"
```

1. Confirme no Jira que a chave é um Epic.
2. Consulte as issues pertencentes a ele.
3. Filtre as que estão na coluna `Integração`.
4. Apresente o conjunto encontrado no **resumo operacional** — nunca
   processe silenciosamente "só a que está em checkout" ou qualquer
   subconjunto não anunciado.
5. Processe **todas** as issues elegíveis do conjunto, uma a uma, pelos
   passos abaixo.

O checkout Git atual (a branch em que o repositório está no momento)
**nunca reduz, substitui ou infere o escopo** — ele vem inteiramente da
consulta ao Jira.

**Idempotência.** Como uma issue integrada ao épico permanece em
`Integração` até o Modo B, uma nova execução do Modo A sobre o mesmo Epic
precisa distinguir pendentes de já integradas — ver a tabela de leitura
PR+label em `workflow-development-flow` §16.4. Nas quatro combinações:
PR mergeado + label presente → **já integrada, não repita o merge**; PR
aberto + label ausente → **pendente, processe**; as duas combinações
restantes são **inconsistência** — bloqueie essa issue especificamente e
reporte, sem travar as demais do conjunto.

### Gate 14 — topologia de Epic ausente

Para cada issue do escopo (seja ele um Epic inteiro ou uma issue só):

1. Confirme que a issue **pertence a um épico**.
2. Confirme que **existe branch ativa** para esse épico
   (`epic/<EPIC-KEY>-<nome>`). Ela deveria já existir — a
   `jira-issue-executor` a garante antes da issue chegar aqui. Se **não
   existir**, isso é **inconsistência upstream** (Gate 14): **pare e
   reporte** essa issue especificamente — esta skill **nunca cria** branch
   de épico, em nenhuma circunstância.
3. Confirme que a **branch da issue nasceu da branch do épico**, não da
   `develop`. Se nasceu da `develop`, pare e reporte — mergear assim traria
   a `develop` inteira para dentro do épico.

### Passo a passo (por issue do escopo)

4. Imprima o **resumo operacional** (com o conjunto inteiro, se o escopo for
   um Epic) e obtenha a confirmação.
5. **R1** — confirme o Pull Request, apontando para a **branch do épico**.
6. **R2** — verifique o GitHub Actions.
7. **R3** — reconcilie com a branch do épico.
8. Faça o merge da branch da issue na branch do épico e envie.
9. **R4** — smoke test mínimo, sobre a **branch do épico**.
10. **R6** — registre o ledger no comentário da issue (ver **Ledger
    operacional**, abaixo).
11. Aplique a label **`integrado-epico`**.

> **A issue não muda de coluna no Modo A.** Ela permanece em `Integração`
> até que o épico seja promovido. A label `integrado-epico` é o que
> distingue, no board, uma issue já mergeada no épico de uma ainda por
> integrar — porque a coluna, sozinha, não consegue dizer isso.

---

## Modo B — branch do épico → develop

Usado para promover o épico para a `develop`. É o modo com mais verificação,
porque promove um conjunto, não uma unidade.

### Regra de escopo

```text
Promoção de épico para develop é COMPLETA por padrão.
Promoção parcial só acontece mediante comando explícito de Rafinha.
```

A skill **não infere** uma promoção parcial sozinha.

Quando Rafinha comandar uma promoção parcial, separe e apresente três
listas antes de qualquer merge:

1. **Escopo total do épico** — todas as issues obrigatórias.
2. **Escopo desta promoção** — o subconjunto que vai subir.
3. **Issues que ficam fora** — e o risco de deixar comportamento
   incompleto na `develop`.

Se essa separação não estiver clara, **pare e peça decisão de Rafinha**.

### Duas confirmações diferentes (Gate 15)

O Modo B tem **duas** confirmações humanas distintas, e pipeline verde não
equivale a autorização de merge:

1. **Modo e escopo** — confirma o que será processado (igual às demais
   etapas, resumo operacional de sempre).
2. **Autorização final de merge (Gate 15)** — ocorre **somente** depois de
   todos os PRs aplicáveis estarem verdes e aptos ao merge. É um pedido
   explícito e separado, não implícito na confirmação de escopo.

### Passo a passo

1. Confirme que Rafinha **solicitou ou confirmou explicitamente** o Modo B.
2. Identifique o épico, os repositórios envolvidos e o escopo.
3. **Liste as issues obrigatórias** do épico consideradas no escopo.
4. Confirme que todas foram **mergeadas na branch do épico**.
5. Confirme que todas possuem a label **`integrado-epico`**.
6. **R5** — verifique subtarefas de todas as issues do escopo.
7. Avalie os **critérios de aptidão** (abaixo). Qualquer um que falhe
   **bloqueia a promoção**; registre a causa.
8. **R3** — reconcilie a branch do épico com a `develop`, por merge, em
   cada repositório aplicável.
9. Verifique se já existe um **PR de promoção** válido
   (`epic/<EPIC-KEY>-<nome> → develop`) em cada repositório. Se não
   existir, **crie você mesma** — é a única exceção à regra "a Integração
   nunca abre PR" (ver **Responsabilidade por PR em cada modo**, abaixo).
10. **R2** — aguarde o GitHub Actions de todos os PRs de promoção.
    **Bloqueie enquanto houver pipeline falhando** em qualquer
    repositório do escopo — não peça autorização com pipeline vermelha.
11. Só quando **todos** os PRs aplicáveis estiverem verdes e aptos, imprima
    o resumo operacional e **peça a autorização final de merge (Gate 15)**
    — explicitamente, como confirmação separada da de modo/escopo.
12. **Imediatamente antes de iniciar os merges**, revalide o estado dos PRs
    e das pipelines — para reduzir o risco de drift entre a autorização e
    a execução real.
13. Faça o merge de cada PR de promoção na `develop` e envie.
14. **R4** — smoke test mínimo sobre a `develop`.
15. **Limpeza de branches** — exclua a branch do épico e as branches de
    issue daquele ciclo que já cumpriram o papel (ver abaixo).
16. **R6** — registre o ledger da promoção, no épico e em cada issue do
    escopo.
17. Mova **todas as issues do escopo** para `QA - Claude` — só depois que
    **todos** os repositórios aplicáveis tiverem sido efetivamente
    mergeados.

### Se Rafinha responder "não" à autorização (Gate 15)

Não é falha técnica — significa apenas que **ainda não é o momento** de
promover o épico. Nesse caso:

- não realize nenhum merge;
- não mova nenhuma issue para `QA - Claude`;
- não execute a limpeza final de branches;
- encerre a execução naquele ponto.

Numa execução futura do Modo B, **revalide do zero** o estado dos PRs e das
pipelines antes de voltar a pedir a autorização — não reaproveite a
avaliação anterior, que pode estar desatualizada.

### Critérios de aptidão do épico

Todos precisam valer para uma promoção completa:

1. Existe uma branch do épico criada a partir da `develop`.
2. Todas as issues obrigatórias do épico estão mergeadas na branch do épico.
3. Todas as issues obrigatórias possuem `integrado-epico`.
4. Não existem issues obrigatórias pendentes de implementação, análise,
   integração ou correção dentro do escopo do épico.
5. Não existem subtarefas obrigatórias pendentes que comprometam o
   funcionamento do épico.
6. A branch do épico está sincronizada ou reconciliada com a `develop` por
   merge, sem conflitos não resolvidos.
7. A CI aplicável da branch do épico está verde.
8. O smoke test da integração do épico passou.
9. Não há conflitos semânticos pendentes de decisão de Rafinha.
10. O comportamento entregue pelo conjunto está minimamente funcional e não
    depende de partes ausentes para não quebrar a `develop`.

### Ausência de `integrado-epico` é bloqueio

> ❗ Uma issue obrigatória do escopo **sem** `integrado-epico` faz a skill
> **parar e perguntar** — nunca concluir que ela não foi integrada.

As duas leituras possíveis da ausência levam a consequências opostas:

| Leitura | Consequência se estiver errada |
|---|---|
| "não foi integrada" | Reporta como incompleto um épico que está completo, e trava uma promoção válida |
| "foi integrada, a label falhou" | Promove um épico furado, levando comportamento quebrado para a `develop` |

A skill não tem como distinguir as duas a partir da ausência. Por isso ela
para. É o mesmo princípio do gate **proibido fallback silencioso**.

### Conflito semântico no Modo B

Diferente dos modos A e C, aqui **não há issue única para devolver**. Um
conflito semântico entre a branch do épico e a `develop` faz a skill
**parar, registrar e pedir decisão de Rafinha** — sem mover nenhuma issue
de coluna.

---

## Modo C — branch da issue → develop

Usado quando a issue não pertence a um épico com branch ativa, ou quando
Rafinha confirmar integração direta.

1. Confirme que Rafinha **solicitou ou confirmou explicitamente** o Modo C.
2. Confirme que **não há branch de épico ativa aplicável**, ou que Rafinha
   determinou integração direta mesmo havendo uma.
3. Imprima o **resumo operacional** e obtenha a confirmação.
4. **R1** — confirme o Pull Request, apontando para a `develop`.
5. **R2** — verifique o GitHub Actions.
6. **R3** — reconcilie com a `develop`.
7. **R5** — verifique subtarefas.
8. Faça o merge da branch da issue na `develop` e envie.
9. **R4** — smoke test mínimo sobre a `develop`.
10. **Limpeza de branches** — exclua a branch da issue (ver abaixo).
11. **R6** — registre o ledger no comentário da issue.
12. Mova a issue para `QA - Claude`.

---

## Responsabilidade por PR em cada modo (Correções 27/09)

| Modo | Responsabilidade |
|---|---|
| **A — issue/Epic → branch do épico** | PR criado anteriormente pela `jira-issue-executor`. Ausente ou com destino errado bloqueia — esta skill **nunca abre PR** aqui |
| **B — branch do épico → develop** | A própria `jira-integration-executor` **cria o PR de promoção** se ele não existir |
| **C — issue → develop** | PR criado anteriormente pela `jira-issue-executor`. Ausente ou com destino errado bloqueia — esta skill **nunca abre PR** aqui |

A regra antiga "a Integração nunca abre PR" continua valendo **inteiramente**
para os modos A e C. O Modo B é a única exceção do contrato.

---

## Operação multi-repositório (Correções 27/09)

Quando um Epic toca múltiplos repositórios, a operação continua sendo
**uma única execução lógica**, não uma série de execuções independentes.

**Modo A.** Uma chamada processa **todos** os repositórios envolvidos no
escopo daquele Epic — o Gate 14 e a idempotência PR+label se aplicam
repositório por repositório.

**Modo B.** A skill pode abrir **N PRs**, um por repositório aplicável
(`epic/<EPIC-KEY> → develop` em cada um). A autorização humana (Gate 15) é
**única** e vale para o conjunto inteiro:

- antes de pedir a autorização, **todos** os PRs devem existir, **todas**
  as pipelines devem estar 100% verdes, e **todos** os PRs devem estar
  aptos ao merge;
- imediatamente antes de iniciar os merges, revalide o conjunto inteiro de
  novo, para reduzir o risco de drift entre pipeline e autorização;
- as issues só saem de `Integração` para `QA - Claude` depois que **todos**
  os repositórios aplicáveis tiverem sido efetivamente mergeados na
  `develop`.

### Falha durante promoção multi-repo

Se a promoção já começou e um merge posterior (num repositório diferente)
falhar:

1. Pare o avanço do lote.
2. Diagnostique o problema.
3. Corrija o que estiver **dentro da responsabilidade da Integração**
   (divergência operacional, reconciliação mecânica, conflito mecânico,
   problema técnico simples).
4. Reexecute as validações/pipeline necessárias.
5. Conclua os merges restantes.
6. Só então considere o Modo B concluído.

Se surgir conflito semântico, decisão de negócio, decisão arquitetural, ou
qualquer coisa que ultrapasse a responsabilidade desta skill, **pare e
peça decisão de Rafinha** em vez de tentar resolver.

**Enquanto o lote estiver incompleto:** nenhuma issue vai para
`QA - Claude`; nenhuma limpeza final de branches é executada; a promoção
permanece em andamento. A conclusão só ocorre quando o conjunto inteiro
está efetivamente integrado.

---

## Limpeza de branches (Correções 27/09)

```text
Excluir a branch não exclui o histórico.
Commits e Pull Requests permanecem como evidência permanente.
```

**Modo B, no encerramento bem-sucedido do lote inteiro:** exclua a branch
do épico e as branches de issue daquele ciclo que já cumpriram o papel.

**Modo C, depois do merge bem-sucedido:** exclua a branch da issue.

A limpeza **só** acontece no encerramento bem-sucedido. Não limpe branch
nenhuma enquanto houver falha pendente no lote, ou em qualquer cenário do
Modo A (a branch da issue no Modo A ainda vai ser lida no Modo B).

> ⚠️ Depois da limpeza, **a ausência de uma branch não é achado nem
> indício de problema**. Só a ausência de **evidência** (PR, commit SHA,
> comentário) é.

---

## Rotinas compartilhadas

### R1 — Confirmar o Pull Request

**Modos A e C.** Localize o PR associado à branch de origem. Ele deve ter
sido aberto na etapa `Fazer - Claude` — esta skill **nunca abre um PR do
zero** para estes dois modos.

**Modo B.** É a única exceção: se o PR de promoção
(`epic/<EPIC-KEY>-<nome> → develop`) não existir, **esta skill o cria**
(ver **Responsabilidade por PR em cada modo**).

Em qualquer modo, confirme que o **destino do PR é a branch de destino do
modo em execução**. Um PR aberto contra a `develop` não serve para o
Modo A.

- **PR existe e aponta para o destino certo** → siga.
- **PR não existe** (Modos A/C) → **pare e avise Rafinha**, no comentário
  da issue e no resumo final. Isso indica algo fora do fluxo esperado.
- **PR existe mas aponta para outro destino** → **pare e pergunte**. Não
  reaponte o PR sozinha, em nenhum modo.

### R2 — Verificar o GitHub Actions do PR

Esta é a segunda camada de validação, independente do ambiente local do
Claude (ver `workflow-development-flow`, seção 6).

- **Ainda rodando** → aguarde a conclusão.
- **Passou** → siga.
- **Falhou** → leia o log (`gh run view` ou equivalente), corrija
  localmente, commite, dê `git push` (dispara nova rodada), e repita até
  passar. **Falha aqui é bloqueio de avanço, nunca só diagnóstico.**

Vale para os três modos: `epic/**`, `develop` e `release/current` rodam os
mesmos checks essenciais. Nenhuma integração avança com CI essencial
vermelha.

### R3 — Reconciliar com a branch de destino

1. `git fetch origin`.
2. Checkout na branch de origem.
3. `git merge origin/<destino>` — **nunca `git rebase`**. Rebase
   reescreveria commits já enviados ao remoto e exigiria `push --force`
   depois, o que é proibido pelas regras de segurança herdadas.

Resultado:

- **Sem conflito** → siga.
- **Conflito mecânico** (trechos diferentes do mesmo arquivo, sem
  contradição de fato — formatação, import, adições que não se sobrepõem)
  → resolva sozinha, registrando exatamente o que foi reconciliado.
- **Conflito semântico real** (duas implementações incompatíveis da mesma
  lógica) → grave `.claude/execution-state/{CHAVE}.md` com
  `Estado: AGUARDANDO_RAFINHA` e os trechos em conflito em "Bloqueios",
  depois **pare e pergunte a Rafinha**, mostrando os trechos, antes de
  decidir qual versão prevalece.

Depois de qualquer resolução de conflito:
- `git push` normal (**nunca `--force`**).
- Volte sempre para **R2** — a pipeline precisa rodar de novo e passar.
- **Se o conflito foi semântico**, nos modos **A e C**: além de revalidar a
  pipeline, **mova a issue de volta para `Análise - Rafinha`**. Uma nova
  rodada completa de revisão humana antes do merge, mesmo que a pipeline
  passe. Registre no comentário o que mudou e por quê. Isso vale mesmo
  quando Rafinha participou pontualmente da resolução: a revisão formal é o
  que garante identificar se algo passou despercebido na aprovação
  original. Ao mover de volta, **encerre esta execução para essa issue**.
- **No Modo B**, conflito semântico não devolve issue nenhuma — ver
  **Conflito semântico no Modo B**.

### R4 — Smoke test mínimo

Executado **depois do merge**, sobre a branch de destino. Leve, direcionado
e suficiente para detectar quebra evidente.

> **O smoke test não substitui o QA.** A validação funcional ampla é da
> `jira-qa-executor`, na coluna `QA - Claude`.

Checks mínimos:

1. O projeto compila, ou executa o build mínimo aplicável.
2. A análise estática / lint obrigatório passa.
3. Os testes automatizados diretamente relacionados à issue ou ao épico
   passam.
4. O fluxo principal afetado abre/executa sem erro bloqueante.
5. A funcionalidade alterada está operante no destino da integração.
6. Não há erro evidente entre issues já integradas no mesmo épico, quando
   aplicável.
7. Não há regressão óbvia no caminho principal.
8. Não há dependência ausente ou configuração quebrada que impeça a próxima
   etapa.
9. Se a alteração for **visual**, a tela principal envolvida renderiza e
   permite o fluxo básico esperado.
10. Se a alteração envolver **API, estado, persistência ou integração entre
    camadas**, a chamada/fluxo principal é validado no menor nível viável.

Smoke test reprovado é **bloqueio**: registre o que quebrou e pare. Não
prossiga para mover issue nenhuma.

### R5 — Verificar subtarefas

```text
Subtask não avança sozinha pelo workflow, mas precisa ser inspecionada
antes da issue pai avançar.
```

Antes de mover qualquer issue para `QA - Claude`:

1. Consulte a issue no Jira.
2. Liste **todas** as subtarefas vinculadas.
3. Verifique o status de cada uma.
4. Identifique se existe subtarefa obrigatória pendente.
5. Se houver, **bloqueie a movimentação da issue pai**.
6. Se estiver tudo compatível, mova a issue pai.
7. Quando o Jira permitir, mova também as subtarefas relevantes.
8. Se a transição da subtarefa não estiver disponível, registre no
   comentário da issue e no resumo final.

**Subtarefa obrigatória** é qualquer subtarefa aberta ligada à
implementação, correção, teste, integração, documentação necessária ou
ajuste bloqueante da issue pai, e que comprometa a validade funcional ou
técnica da entrega caso fique pendente.

> ⚠️ **Toda subtarefa aberta é tratada como potencialmente obrigatória**,
> salvo quando estiver claramente marcada ou descrita como opcional, futura
> ou não bloqueante. Na dúvida, a skill pergunta — não decide sozinha que
> uma pendência é irrelevante.

### R6 — Registrar a evidência (ledger operacional)

**Toda execução desta skill deixa um registro estruturado e permanente no
Jira** — é o que mantém a auditabilidade depois que as branches forem
excluídas (ver **Limpeza de branches**). Publique um comentário contendo,
no mínimo, os campos abaixo por modo — além do que já era registrado
(origem → destino, PR, resultado do GitHub Actions, conflito e resolução,
smoke test, subtarefas, labels aplicadas/removidas, confirmação do merge):

**Modo A** — na issue:
- modo executado; Epic; repositório; branch da issue (com a tentativa,
  se houver sufixo); branch de destino; número/tentativa; PR; merge SHA
  (ou evidência equivalente); data; resultado; aplicação de
  `integrado-epico`.

**Modo B** — na promoção agregada, registrada **no épico**, e referenciada
em cada issue participante:
- repositórios envolvidos; PRs `epic/** → develop`; issues promovidas;
  resultado das pipelines; **autorização de Rafinha** (Gate 15, com
  evidência de que foi pedida e concedida); merges realizados; data;
  resultado final; limpeza de branches executada. Em promoção parcial,
  quais issues ficaram fora e por quê.

**Modo C** — na issue:
- modo; repositório; branch (com tentativa, se houver); destino
  (`develop`); PR; merge SHA (ou evidência equivalente); data; resultado;
  limpeza da branch executada.

**Uso dos comentários.** Eles passam a apoiar: descoberta do próximo `.N`
pela `jira-issue-executor`; retomada de reimplementação após QA;
auditoria da `jira-review-executor`; investigação de incidentes;
validação de histórico depois da exclusão das branches; rastreabilidade
da promoção de Epic para o G10 da `jira-release-executor`.

> Comentário do Jira é **registro operacional**, mas não substitui a
> verificação da realidade em Git/GitHub quando é preciso provar um merge
> ou PR — ele é o índice, não a prova técnica final (ver
> `jira-release-executor`, G10).

**`Links para merge` não é alterado por esta rotina no Modo B.** O PR de
promoção `epic/** → develop` não substitui, não sobrescreve e não é
gravado nesse campo — ele continua apontando para o PR individual da
issue, aberto pela `jira-issue-executor`. O PR de promoção fica registrado
só no GitHub e no ledger do Modo B.

---

## Labels operacionais

| Label | Quando esta skill a aplica | Quando esta skill a remove |
|---|---|---|
| `integrado-epico` | Modo A, depois do merge issue → branch do épico | Nunca. Quem remove é a `jira-qa-executor`, ao dar veredito sobre a `develop` — aprovando **ou** reprovando |
| `qa-develop-aprovado` | Nunca — é da `jira-qa-executor` | Nunca |

Ver a matriz oficial no Confluence (**Vocabulário operacional de labels**,
categoria 11) para o ciclo de vida completo.

---

## Execution State

O Execution State versionado **pertence à branch da issue**. Fora dela, é
apenas estado local de execução.

Em **toda** operação desta skill — Modo A, Modo B e Modo C —
`.claude/execution-state/{CHAVE}.md` permanece **local e não commitado**.

Nunca recebem commit de Execution State:

- a branch do épico (`epic/**`);
- a `develop`;
- a `release/current`;
- branches efêmeras de release.

A rastreabilidade das integrações fica nos comentários da issue, nas
evidências, nos PRs e nos logs da skill — **não** em Execution State
versionado fora da branch da issue.

Em qualquer caso que mova a issue (sucesso ou devolução), apague
`.claude/execution-state/{CHAVE}.md` se existir — a partir daí, Jira e Git
já são a fonte de verdade permanente.

---

## O que NÃO fazer

- ❌ **Nunca inferir o modo de integração** — mesmo quando a estrutura da
  issue, do épico e das branches parecer indicar um caminho óbvio. O modo é
  informado ou confirmado por Rafinha.
- ❌ Nunca executar merge sem antes imprimir o resumo operacional.
- ❌ Nunca preencher uma linha do resumo operacional com suposição — se o
  valor real não for conhecido, pare e pergunte.
- ❌ **Nunca criar branch de épico** — isso é da `jira-issue-executor`,
  automaticamente, antes da 1ª Integração. Se a branch do épico não
  existir durante uma integração, é inconsistência upstream (Gate 14):
  pare e reporte essa issue especificamente.
- ❌ **Nunca reduzir, substituir ou inferir o escopo de um Modo A por Epic**
  a partir do checkout Git atual — o escopo vem inteiramente da consulta
  ao Jira (issues do Epic ∩ Integração).
- ❌ Nunca promover um épico parcialmente sem comando explícito de Rafinha.
- ❌ **Nunca tratar ausência de `integrado-epico` como "ainda não
  integrada"** — é bloqueio, e a skill para e pergunta.
- ❌ Nunca mover a issue de coluna no Modo A — ela fica em `Integração` até
  o épico ser promovido.
- ❌ Nunca mover uma issue para `QA - Claude` sem verificar subtarefas.
- ❌ Nunca decidir sozinha que uma subtarefa aberta é irrelevante.
- ❌ Nunca usar `git push --force` ou `--force-with-lease` — se o push
  normal for rejeitado por divergência, pare e avise Rafinha.
- ❌ Nunca usar `git rebase` para reconciliar — sempre
  `git merge origin/<destino>`.
- ❌ Nunca avançar para o merge sem o GitHub Actions verde — falha na
  pipeline é sempre bloqueio, nunca diagnóstico a ser ignorado.
- ❌ Nunca resolver um conflito semântico sozinha — sempre parar e mostrar
  os trechos em conflito a Rafinha.
- ❌ Nunca pular a devolução para `Análise - Rafinha` depois de resolver um
  conflito semântico nos modos A e C, mesmo que a pipeline passe depois.
- ❌ Nunca prosseguir com smoke test reprovado.
- ❌ **Nos Modos A e C, nunca abrir um Pull Request** — se o PR não existir,
  pare e avise Rafinha. **No Modo B, é o oposto**: se o PR de promoção não
  existir, criá-lo é responsabilidade desta skill.
- ❌ Nunca reapontar o destino de um PR existente, em nenhum modo — pare e
  pergunte.
- ❌ **Nunca mergear no Modo B sem a autorização humana do Gate 15** — pipeline
  verde não é autorização de merge. E, se Rafinha responder "não", nunca
  trate isso como falha técnica — apenas encerre sem mergear.
- ❌ Nunca executar a limpeza de branches (Modo B ou C) enquanto houver
  falha pendente no lote, nem antes do sucesso completo.
- ❌ Nunca gravar o PR de promoção do Modo B no campo `Links para merge` das
  issues — esse campo é sempre o PR individual, aberto pela
  `jira-issue-executor`.
- ❌ Em Epic multi-repositório, nunca mover issue para `QA - Claude` antes
  de **todos** os repositórios aplicáveis estarem mergeados.
- ❌ Nunca criar uma pipeline de GitHub Actions do zero.
- ❌ Nunca dar checkout em outra branch, ou criar uma nova, sem antes
  checar `git status` e resolver alterações não commitadas com Rafinha.
- ❌ Nunca declarar que "o aplicativo inteiro" está livre de problemas —
  esta etapa valida integração técnica e smoke; a validação funcional ampla
  é do QA - Claude.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira processar, nem sobre o
  repositório de código quando não estiver claro.
- ❌ **Nunca commitar `.claude/execution-state/{CHAVE}.md`** em nenhuma
  operação desta skill.
- ❌ Nunca aplicar `qa-develop-aprovado` — essa label é da
  `jira-qa-executor`.
- ❌ Nunca confiar cegamente num Execution State encontrado — sempre
  reconciliar com o estado real do Git/GitHub/Jira antes de continuar.

---

## Resumo final ao usuário

Depois de processar a execução, apresente a Rafinha um resumo consolidado.

**Modo A (escopo de Epic) ou C:**

```
✅ Projeto processado: [nome/chave do projeto]
🔀 Modo: A — escopo: Epic PROJ-40 (issues do Epic ∩ Integração)
📋 Issues do conjunto: [quantidade]
  - [ISSUE-1]: já integrada (PR mergeado + integrado-epico presente) → não repetida
  - [ISSUE-2]: PR #13, pipeline corrigida 1x (lint), conflito mecânico resolvido (import duplicado) → merge em epic/PROJ-40-cadastro → smoke OK → `integrado-epico` aplicada
  - [ISSUE-3]: PR #14, pipeline OK, conflito semântico (duas implementações da mesma validação) — Rafinha decidiu qual prevalece, pipeline revalidada → devolvida para Análise - Rafinha
  - [ISSUE-4]: Gate 14 — branch do Epic ausente para esta issue → bloqueada, inconsistência upstream reportada
⚠️ Issues não processadas (PR ausente, destino errado, subtarefa pendente, pipeline não configurada ou Gate 14): [lista ou "nenhuma"]
```

**Modo B:**

```
✅ Projeto processado: [nome/chave do projeto]
🔀 Modo: B (epic/PROJ-40-cadastro → develop) — 1 repositório
📦 Escopo: completo — 5 issues obrigatórias
  - Todas com `integrado-epico` ✓
  - Subtarefas verificadas: 3 fechadas, 0 pendentes ✓
  - Critérios de aptidão: 10/10 ✓
📬 PR de promoção: criado por esta skill (#88), pipeline verde
🔓 Autorização de merge (Gate 15): concedida por Rafinha em 27/09 14:32
🔀 Merge realizado: epic/PROJ-40-cadastro → develop
🧪 Smoke test: OK
🧹 Branches removidas: epic/PROJ-40-cadastro, feat/PROJ-41-claude, feat/PROJ-42-claude
📋 Issues movidas para QA - Claude: PROJ-41, PROJ-42, PROJ-43, PROJ-44, PROJ-45
```

Quando a promoção for **bloqueada**, diga qual critério falhou e o que falta
— nunca só "não foi possível promover". Quando Rafinha **negar** a
autorização de merge, diga isso explicitamente e deixe claro que não é
falha técnica — a execução só encerrou sem mergear.
