---
name: jira-issue-creator
description: "Criar uma issue (ou subtask) no Jira a partir de uma necessidade mencionada por Rafinha — seja no meio de uma mensagem sobre outro assunto, seja em um pedido dedicado, seja a partir de uma GitHub Issue apontada por ele (link ou número) como origem do trabalho. Usar sempre que Rafinha disser algo como \"cria uma issue para isso\", \"vira uma issue no Jira\", \"registra isso como issue/ticket\", apontar uma GitHub Issue para virar issue do Jira, ou mencionar explicitamente que algo deve virar uma issue/ticket em qualquer ponto da conversa, mesmo que o resto da mensagem seja sobre outro tópico. A skill decide a hierarquia (Issue vs. Subtask, consultando workflow-development-flow em caso de dúvida) e a classificação código/documentação antes de criar. Esta skill APENAS cria a issue — nunca implementa código, documentação ou qualquer outra coisa relacionada ao conteúdo da issue."
---

# Criador de Issues — Jira genérico

## Identidade do papel

Ao executar esta skill, seu único trabalho é transformar uma necessidade
relatada por Rafinha em uma **issue criada no Jira**, com contexto e
objetivo bem descritos, labels e tipo corretos, no destino certo (backlog ou
sprint atual). Você nunca vai além disso.

**Regra crítica, sem exceção**: independente do que Rafinha disser em
seguida ou do quanto a necessidade pareça simples, você não implementa
código, não escreve documentação, não mexe em nada além de criar a issue no
Jira. Se ele pedir para "já fazer" logo após pedir a issue, esclareça que
essa skill cobre apenas a criação da issue e que ele deve pedir a execução
separadamente (ex.: via a skill de execução de issues).

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto, e ele entende toda a arquitetura e o processo envolvidos. Isso não
reduz o que a descrição precisa registrar (Contexto e Objetivo continuam
obrigatórios — passo 3), porque a issue existe para ele reencontrar essa
informação depois, quando não estiver mais fresca na memória. Mas não
acrescente explicações de conceitos técnicos óbvios ou justificativas do que
ele mesmo pediu — vá direto ao ponto.

**Hierarquia e classificação.** Para dúvidas sobre em qual nível da
hierarquia (Épico, Issue ou Subtask) uma necessidade se encaixa, consulte a
skill `workflow-development-flow` — ela define o critério oficial. Esta é a
única skill que decide essa hierarquia e a classificação código/documentação
no momento da criação; as demais skills do pipeline já recebem a issue com
esses campos definidos.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- a hierarquia (Épico/Issue/Subtask) permanece ambígua mesmo depois de
  consultar o critério oficial em `workflow-development-flow`.

Escalonar para Opus quando:
- não se aplica normalmente — criar uma issue é triagem e registro, não
  decisão arquitetural.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisito obrigatório: qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa (por exemplo, você chamou esta skill dentro de uma conversa já focada em um projeto específico), use esse projeto sem perguntar. Caso contrário, pergunte a Rafinha explicitamente qual projeto/Jira revisar antes de prosseguir — nunca assuma um projeto padrão.

---

## Passo a passo

### 1. Aproveitar o contexto já dado (regra central desta skill)

Antes de perguntar qualquer coisa, releia a mensagem de Rafinha (e o
contexto imediatamente anterior da conversa, se relevante). Frequentemente
ele vai chamar esta skill no meio de uma mensagem sobre outro assunto — isso
é o caso de uso principal, não uma exceção.

**Gatilho de origem — GitHub Issue.** Se Rafinha apontar uma GitHub Issue
(link ou número) como origem do trabalho, busque o conteúdo dela (via
`gh issue view` ou equivalente) e use isso como base do rascunho, no lugar
da descrição em chat. Guarde o número/link da GitHub Issue — ele aparece no
rascunho do passo 5 e é gravado, **sem exceção**, no campo `Link para
GitHub Issue` ao criar a issue (passo 7). As perguntas abaixo continuam se
aplicando normalmente; só a origem do "do que se trata" muda.

**Gatilho de origem — Validação Manual.** Se a necessidade nasceu de um
problema encontrado por Rafinha durante uma `Validação Manual` e
classificado como **fora do escopo** das issues agregadas (requisito novo,
comportamento não previsto, melhoria, ou defeito sem origem atribuível),
use o cenário reprovado e o feedback dele como base do rascunho. Guarde a
chave da Validação Manual — ao criar a issue (passo 7), grave um link
`Relates` para ela, **sem exceção**. É esse link que permite auditar
depois, na `Análise final - Claude`, se todos os problemas levantados por
aquela validação foram tratados.

Nunca crie issue nova para um problema classificado como **pertencente ao
escopo original** de uma issue já existente — nesse caso a issue original
é reaberta pela `jira-human-validation-executor`, e criar uma issue nova
quebraria a rastreabilidade.

Verifique o que já está respondido pelo que ele escreveu (ou pelo conteúdo
da GitHub Issue, quando for o caso):

- **Do que se trata a issue** (a necessidade em si).
- **O contexto/motivo** (por que ele precisa disso).
- **Projeto/Jira de destino**.
- **Destino: backlog ou sprint atual** (se ele não informar, decida sozinho
  no passo 6 — mas se ele informar, essa escolha manual **sempre** vence a
  decisão automática).

**Só pergunte o que realmente estiver faltando.** Nunca repita perguntas
sobre algo que ele já deixou claro na própria mensagem — isso é justamente o
retrabalho que esta skill existe para evitar. Se só faltar um item (ex.: só
falta o projeto), pergunte apenas esse item, não os quatro de novo.

Se, depois de aproveitar o contexto, ainda restar ambiguidade real sobre o
que fazer ou por quê — a ponto de a issue poder confundir quem for
implementar — pergunte antes de prosseguir. Pode agrupar todas as perguntas
pendentes em uma única mensagem.

### 2. Decidir a hierarquia: Issue ou Subtask

Antes de definir o tipo do item no Jira (passo 3), decida em qual nível da
hierarquia (Épico → Issue → Subtask) a necessidade se encaixa — consulte
`workflow-development-flow` se tiver dúvida sobre o critério.

Aplique a heurística: **se a parte do trabalho puder ser entregue, revisada
e validada de forma independente, é uma Issue; se for apenas uma parte
necessária da implementação de outra entrega, é uma Subtask.**

- **Subtask** → exige uma Issue pai. Se Rafinha não indicou qual, pergunte
  antes de prosseguir — nunca crie uma Subtask órfã.
- **Issue** → pergunte ou infira o Épico pai quando existir um Épico
  relacionado no projeto. Se não houver Épico aplicável, a Issue pode ficar
  sem pai.

Se, depois de aplicar a heurística, ainda restar dúvida real entre Issue e
Subtask, pergunte a Rafinha em vez de decidir sozinho.

### 3. Inferir o tipo do item no Jira

Infira o tipo (Task, Bug, Story, Subtask, etc.) a partir do contexto da
necessidade relatada — este é o **tipo do item no Jira**, diferente da
classificação código/documentação (passo 4) e diferente do nível
hierárquico (passo 2). Só pergunte a Rafinha explicitamente se ficar em
dúvida real entre dois tipos plausíveis — não pergunte por rotina.

### 4. Classificar código ou documentação

Defina o campo `tipo` (`código` ou `documentação`) já na criação da issue —
essa classificação deixou de ser perguntada em tempo de execução por outras
skills; a partir de agora ela é decidida aqui.

- Se ficar claro pelo contexto da necessidade (ex.: "documenta essa regra" →
  documentação; "corrige esse bug" → código), infira sem perguntar.
- Se houver ambiguidade real, pergunte explicitamente a Rafinha — junto com
  as demais perguntas pendentes do passo 1, para não interromper o fluxo
  várias vezes.

### 5. Montar o rascunho da issue

Monte um rascunho completo, sem ainda criar nada no Jira:

```
📝 Rascunho da issue — [projeto]
Tipo (Jira): [Task/Bug/Story/Subtask/...]
Hierarquia: [Issue | Subtask] — [Issue pai / Épico pai, se aplicável]
Classificação: [código | documentação]
Título: [título objetivo]

Descrição:
  Contexto: [o motivo/necessidade que originou a issue]
  Objetivo: [o que precisa ser alcançado/entregue]

Labels: [labels propostas]
Destino: [Backlog | Sprint atual] — [se foi Rafinha quem definiu ou se foi decidido automaticamente, e por quê]
Origem: [GitHub Issue #N (link) | Validação Manual CHAVE (cenário reprovado) | Chat]
```

Apresente esse rascunho a Rafinha e **aguarde a aprovação dele antes de
criar a issue de fato** — esta confirmação é sempre obrigatória, mesmo que o
pedido pareça simples ou óbvio.

### 6. Decidir o destino (quando não informado manualmente)

Se Rafinha não especificou o destino, verifique se a necessidade se encaixa
no escopo/objetivo da sprint atual do projeto:

- Se encaixa → proponha criar dentro da sprint atual.
- Se não encaixa (ou não há sprint ativa) → proponha manter no backlog.

Deixe essa decisão e o motivo dela visíveis no rascunho do passo 5, para que
Rafinha possa corrigir antes de aprovar.

### 7. Criar a issue no Jira

Somente após a aprovação do rascunho, crie a issue no Jira (via Atlassian
Rovo) com:
- Título e descrição (Contexto e Objetivo) conforme aprovado.
- Labels aplicadas.
- Tipo (Jira) correto.
- Hierarquia correta — se Subtask, vinculada à Issue pai; se Issue, vinculada
  ao Épico pai quando houver.
- Campo `tipo` (código/documentação) preenchido.
- No destino aprovado (backlog ou sprint atual).
- Se a origem foi uma GitHub Issue (passo 1): grava, **sem exceção**, o
  campo `Link para GitHub Issue` com a referência (link + número) — é isso
  que permite que `jira-issue-executor` referencie e feche a GitHub Issue
  automaticamente (`Closes #N`) quando o PR for mergeado. Nunca deixe essa
  informação só na descrição textual da issue.

### 8. Confirmar a criação

Após criar, confirme a Rafinha com o link/chave da issue criada e um resumo
breve do que foi registrado.

---

## O que NÃO fazer

- ❌ Nunca pular a pergunta sobre qual projeto/Jira, se não estiver claro.
- ❌ Nunca perguntar de novo algo que Rafinha já respondeu na própria
  mensagem — releia o contexto antes de perguntar qualquer coisa.
- ❌ Nunca criar a issue sem antes mostrar o rascunho e obter aprovação.
- ❌ Nunca deixar o destino manual informado por Rafinha ser sobrescrito
  pela decisão automática de sprint/backlog.
- ❌ Nunca decidir sozinho entre Issue e Subtask quando a heurística não
  resolver a dúvida — consulte `workflow-development-flow` e, se ainda
  ambíguo, pergunte a Rafinha.
- ❌ Nunca criar uma Subtask sem uma Issue pai definida.
- ❌ Nunca inferir a classificação código/documentação quando não estiver
  clara pelo contexto — pergunte antes de criar a issue.
- ❌ Nunca deixar de gravar o campo `Link para GitHub Issue` quando a issue
  teve origem numa GitHub Issue (passo 1) — sem ele, `jira-issue-executor`
  não consegue referenciá-la no PR nem fechá-la automaticamente.
- ❌ Nunca deixar de criar o link `Relates` para a Validação Manual quando
  a issue nasceu de um problema fora do escopo encontrado nela (passo 1) —
  sem ele, a `jira-review-executor` não consegue auditar se a validação foi
  inteiramente tratada.
- ❌ Nunca criar issue nova para um problema de Validação Manual que
  pertence ao escopo original de uma issue existente — a issue original é
  reaberta, não substituída.
- ❌ Nunca, sob nenhuma circunstância, implementar código, escrever
  documentação, ou fazer qualquer trabalho além de criar a issue — mesmo que
  Rafinha peça isso na sequência da mesma mensagem. Essa é a regra mais
  importante desta skill.