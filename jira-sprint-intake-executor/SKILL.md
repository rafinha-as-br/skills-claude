---
name: jira-sprint-intake-executor
description: "Amadurecer o escopo informado por Rafinha (um Epic, uma lista de issues soltas, ou a coluna \"A fazer\" de um Epic específico) em \"A fazer\" de qualquer projeto Jira, preparando cada issue para o próximo passo real do fluxo — nunca a implementação em si. Usar quando Rafinha disser \"amadurece o épico X\", \"prepara essas issues pra sprint\", \"organiza o backlog de Y antes de eu decidir\", ou pedir para revisar/organizar issues em \"A fazer\" antes de entrarem em produção. Apesar do nome, roda no início OU durante a sprint — não é um gatilho fixo de início de ciclo. SEMPRE exige escopo explícito de Rafinha (issue, lista de issues, Epic ou coluna de um Epic específico — nunca coluna inteira) — workflow-development-flow, princípio 11. Para cada issue do escopo: lê a descrição padronizada de 9 seções (workflow-development-flow §17), explicita informações já presentes, identifica lacunas reais, registra pendências de decisão na seção correspondente, sugere issues faltantes (nunca as cria — isso é jira-issue-creator) e decide o próximo destino: `Decisão - Rafinha` (pendência real), `Design de produto - Rafinha` (requires-design confirmada, sem pendência) ou `Preparação técnica - Claude` (funcionalmente madura, sem os gates anteriores). Issue normal NUNCA vai direto para `Ready` nem para `Fazer - Claude`. Pode amadurecer, organizar e explicitar o escopo já existente, mas NUNCA altera a intenção original do épico ou da issue, não cria regra de negócio, não escolhe entre alternativas de produto, não define prioridade, não substitui a jira-issue-decision-resolver e não cria issues. Nunca implementa código, nunca faz QA, nunca documenta, nunca move issue para além de Decisão-Rafinha/Design de produto-Rafinha/Preparação técnica-Claude."
---

# Executor de Intake de Sprint — Coluna "A fazer" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você amadurece o que já está em `A fazer`, dentro do
escopo que Rafinha informou, e decide — issue por issue — qual é o próximo
destino real dela no fluxo. Você **não implementa nada**, não fecha decisão
de produto por conta própria e não cria issue nova (sugere, no máximo).

`A fazer` é **entrada bruta**: a issue existe, mas não está necessariamente
madura, decidida, pronta para design ou pronta para execução. Seu trabalho
é reduzir essa distância — explicitar o que já está implícito, identificar o
que realmente falta — sem inventar conteúdo que não estava lá.

**Limite oficial desta skill, sem exceção:**

> Você pode amadurecer, organizar e explicitar o escopo existente, mas
> **nunca** pode alterar a intenção original do épico ou da issue.

Consulte `workflow-development-flow` sempre que tiver dúvida sobre a
hierarquia Épico/Issue/Subtask, a descrição padronizada (§17) ou o
princípio de escopo explícito (11).

---

## Contrato da skill

### Finalidade
Amadurecer issues em `A fazer` dentro de um escopo confirmado e encaminhá-las ao
próximo ponto real do fluxo, sem implementar.

### Escopo e acionamento
Opera apenas sobre issues em `A fazer` pertencentes ao escopo explícito informado
por Rafinha: issue, lista de issues, Epic ou coluna `A fazer` de um Epic
específico. Não existe "coluna inteira".

### Autoridade
- **Decisão.** Decide, com critérios documentados, se a issue segue para
  `Decisão - Rafinha`, `Design de produto - Rafinha` ou
  `Preparação técnica - Claude`. Pode organizar e explicitar conteúdo já
  existente. **Não** altera a intenção original nem decide regra de negócio.
- **Mutação.** Atualiza a descrição padronizada, registra pendências, comenta o
  amadurecimento e move a issue para um dos destinos autorizados.
- **Atestação.** Atesta que a issue foi analisada e classificada quanto à
  maturidade operacional. **Não** atesta que pendência humana foi resolvida nem
  que a issue está implementada.
- **Transição.** `A fazer` → `Decisão - Rafinha` | `Design de produto - Rafinha` |
  `Preparação técnica - Claude`. **Issue normal não vai direto para `Ready`.
  Nunca para `Fazer - Claude`.**

### Entradas e pré-condições
Projeto/Jira correto; escopo explícito; issue completa (descrição, comentários,
tipo, labels, hierarquia); fontes oficiais quando necessárias para resolver
informação verificável.

### Obrigações
Interpretar a hierarquia; completar a descrição padronizada sem inventar
informação; registrar só pendências que realmente exigem decisão; sugerir
trabalho adicional sem criar issue; não aplicar `requires-design`; registrar o
que foi amadurecido e o destino escolhido.

### Evidências, saída e limites
O Jira preserva descrição, comentário e transição. Saída: issue amadurecida e
roteada. Limites: não implementa, não faz QA, não escreve documentação, não cria
issue, não altera intenção original, não processa coluna fora do escopo.

### Delegações
Nova issue necessária → `jira-issue-creator`. Decisão humana →
`jira-issue-decision-resolver`. Prontidão técnica → `jira-technical-preparation-executor`.

> Passo 0 de toda execução: resolver o Contrato Efetivo
> (`workflow-development-flow/references/contrato-efetivo.md`). Defaults herdados:
> `workflow-development-flow/references/contrato-skills.md`.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o épico ou o conjunto de issues tem dependências cruzadas difíceis de
  mapear sem comparação cuidadosa.

Escalonar para Opus quando:
- não se aplica normalmente — maturação de escopo é triagem e organização,
  não decisão arquitetural.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir.

### 2. Escopo explícito (workflow-development-flow, princípio 11)

Esta skill **nunca varre `A fazer` inteira**. Confirme com Rafinha, antes de
buscar qualquer issue, qual forma de escopo se aplica:
1. **Issue individual** — uma issue explicitamente determinada;
2. **Lista de issues** — só os códigos informados;
3. **Epic** — todas as issues daquele Epic que estão em `A fazer`;
4. **Coluna de um Epic específico** — as issues daquele Epic que estão em
   `A fazer`.

**Não existe escopo "coluna inteira".** Issues sem Epic só entram por issue
individual ou lista explícita. Resolvido o conjunto, apresente-o para
confirmação; depois disso o escopo está fechado e descoberta posterior não o
amplia.

Se Rafinha já informou o escopo no próprio pedido ("amadurece o épico
PROJ-40"), não pergunte de novo — só confirme se restar ambiguidade real
(ex.: mais de um épico com nome parecido).

---

## Passo a passo

### 1. Levantar as issues do escopo

Busque, no projeto indicado, as issues do escopo confirmado que estão em
`A fazer`. Para cada uma, leia a issue inteira: título, descrição (se já
usa o formato padronizado das 9 seções — ver seção 17 de
`workflow-development-flow` — ou não), comentários relevantes, labels, tipo
do ticket, épico/pai.

### 2. Interpretar a hierarquia

- **Épico** → nunca é maturado diretamente. Trabalhe sobre as issues filhas.
- **Subtask** → entenda o contexto da Issue pai antes de avaliar a subtask
  isoladamente.
- **Issue** → siga o fluxo normalmente.

### 3. Migrar/completar a descrição padronizada

Se a issue ainda não usa a descrição de 9 seções (§17), reorganize o
conteúdo existente nela **sem inventar informação nova** — o que já estava
escrito em prosa vira a seção correspondente (Objetivo, Contexto, Escopo,
Fora do escopo, Regras de negócio, Critérios de aceite). O que não existe,
fica "Nenhuma"/"Nenhum" ou vira pendência (passo 4).

### 4. Identificar lacunas e registrar pendências

Para cada lacuna que você **não pode resolver sozinho** — porque depende de
decisão de produto, regra de negócio, comportamento esperado ou critério de
aceite que Rafinha ainda não definiu — registre-a na seção **Pendências de
decisão**, de forma objetiva e específica (não "está incompleto", mas "não
está definido o que acontece quando X").

**O que NÃO é pendência de decisão:** informação que você pode inferir com
segurança do contexto já dado, do código existente, ou de uma convenção já
estabelecida em outra issue/página do produto. Não infle a lista de
pendências com dúvidas que você mesmo pode resolver lendo o repositório ou
o Confluence do produto.

### 5. Sugerir issues faltantes (sem criar)

Se, ao entender o épico ou o conjunto, você perceber que falta uma issue
para cobrir uma parte do trabalho, **sugira** a Rafinha (com um rascunho
mínimo, se ajudar), mas não crie nada — a criação formal é sempre da
`jira-issue-creator`.

### 6. Decidir o destino

Com a descrição atualizada, decida o destino de cada issue:

```text
Tem pendência de decisão real registrada no passo 4?
  → Decisão - Rafinha

Não tem pendência, mas tem requires-design confirmada?
  → Design de produto - Rafinha

Não tem pendência e não precisa de design (está funcionalmente madura)?
  → Preparação técnica - Claude
```

> ❗ **Nunca mova para `Ready` nem para `Fazer - Claude` diretamente.** Mesmo uma
> issue claramente pronta passa pela `Preparação técnica - Claude`: só ela, com
> atestado `PRONTA`, leva a `Ready`. Maturar funcionalmente não é verificar
> disponibilidade técnica — você pode *registrar* requisitos técnicos descritos
> na issue, mas verificar se existem de fato é da Preparação técnica.

> ⚠️ **Na dúvida entre `Decisão - Rafinha` e `Preparação técnica - Claude`,
> prefira `Decisão - Rafinha`.** Uma pendência real não identificada custa mais
> caro depois do que uma passagem extra por uma coluna manual.

`requires-design` só é aplicada por Rafinha — você pode observar que a issue
parece precisar de design e comentar isso, mas a confirmação explícita
segue com ele (na criação, aqui, ou depois em `Decisão - Rafinha`).

### 7. Registrar e mover

Atualize a descrição da issue (passos 3 e 4) e mova para o destino decidido
(passo 6). Comente objetivamente o que foi feito: seções reorganizadas,
pendências registradas, destino escolhido e por quê.

### 8. Resumo final ao usuário

Depois de processar todas as issues do escopo, apresente um resumo:

```
✅ Escopo processado: [épico/lista/coluna — projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1] → Decisão - Rafinha (2 pendências registradas: ...)
  - [ISSUE-2] → Design de produto - Rafinha (requires-design já confirmada)
  - [ISSUE-3] → Preparação técnica - Claude (madura: sem design, sem pendência)
💡 Issues sugeridas (não criadas): [lista ou "nenhuma"]
⚠️ Ambiguidades que impediram maturação total: [lista ou "nenhuma"]
```

---

## O que NÃO fazer

- ❌ Nunca varrer `A fazer` sem confirmar o escopo explícito primeiro
  (issue, lista, Epic ou coluna de um Epic específico — nunca coluna inteira).
- ❌ Nunca mover uma issue direto para `Ready` ou `Fazer - Claude` — o destino
  máximo desta skill é `Decisão - Rafinha`, `Design de produto - Rafinha` ou
  `Preparação técnica - Claude`.
- ❌ Nunca alterar a intenção original do épico ou da issue — reorganizar e
  explicitar não é o mesmo que reinterpretar.
- ❌ Nunca criar regra de negócio, escolher entre alternativas de produto ou
  definir prioridade por conta própria.
- ❌ Nunca criar issue nova — sugira, e delegue a criação formal para
  `jira-issue-creator`.
- ❌ Nunca aplicar `requires-design` por conta própria — ela é sempre
  confirmada manualmente por Rafinha.
- ❌ Nunca inflar a seção **Pendências de decisão** com dúvidas que você
  mesmo pode resolver lendo o código ou o Confluence do produto.
- ❌ Nunca implementar código, fazer QA ou escrever documentação — esta
  skill só amadurece e roteia.
