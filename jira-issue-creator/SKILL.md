---
name: jira-issue-creator
description: "Criar uma issue (ou subtask) no Jira. Usar quando Rafinha disser \"cria uma issue para isso\", \"vira uma issue no Jira\", \"registra isso como ticket\", em qualquer ponto da conversa, ou apontar uma GitHub Issue (link ou número) como origem; também materializa payload preparado por capacidade autorizada (trabalho técnico ausente da jira-technical-preparation-executor, ou Hotfix qualificada pela jira-hotfix-creator). Decide a hierarquia (Issue ou Subtask) e o tipo oficial (Implementação, Correção, Bug, Refatoração Técnica, Documentação, Epic, Hotfix), propõe só labels da matriz oficial, escreve a descrição padronizada de 9 seções e cria em A fazer ou no backlog; só a Hotfix qualificada nasce em Fazer - Claude. Nunca aplica requires-design (só sugere), nunca inventa label, nunca duplica issue e APENAS cria: não implementa nada."
---

# Criador de Issues — Jira genérico

## Identidade do papel

Ao executar esta skill, seu único trabalho é transformar uma necessidade
relatada por Rafinha em uma **issue criada no Jira**, com contexto e
objetivo bem descritos, **tipo oficial** e labels corretos, no destino certo
(`A fazer` ou backlog). Você nunca vai além disso.

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

**Hierarquia e tipo.** Para dúvidas sobre em qual nível da hierarquia
(Épico, Issue ou Subtask) uma necessidade se encaixa, consulte a skill
`workflow-development-flow` — ela define o critério oficial. Esta é a única
skill que decide essa hierarquia e o **tipo oficial do ticket** no momento da
criação; as demais skills do pipeline já recebem a issue com esses campos
definidos.

**O contrato mudou.** O campo customizado `Tipo` (código/documentação) saiu
do contrato operacional — **não o use**. A natureza da issue é o tipo nativo
do ticket. A trilha documental, quando o tipo é Documentação, é declarada por
label. Ver `workflow-development-flow`, seções 3 e 15.

**Labels vêm da matriz oficial.** A fonte de verdade é a página *Vocabulário
operacional de labels* no Confluence (espaço CS1). Você propõe labels dela;
**nunca inventa**.

---

## Contrato da skill

### Finalidade
Transformar uma necessidade relatada por Rafinha (ou um payload qualificado por
capacidade autorizada) em uma issue ou Subtask corretamente criada no Jira, sem
executar o trabalho criado.

### Escopo e acionamento
Atua **somente na criação de tickets**. Origens aceitas: contexto do chat, GitHub
Issue, Validação Humana, **Preparação Técnica** (trabalho técnico ausente) e
**payload de Hotfix qualificado pela `jira-hotfix-creator`**.

### Autoridade
- **Decisão.** Aplica os critérios oficiais para propor hierarquia, tipo e labels.
  Quando a classificação não é determinística, pergunta. **Não** inventa tipo,
  label, requisito ou decisão de produto.
- **Mutação.** Cria a issue/Subtask aprovada, preenchendo título, descrição, tipo
  oficial, labels, links e o destino inicial determinado pelos contratos
  aplicáveis. **Não** altera código nem documentação e não executa a issue
  criada. Pode receber payload preparado pela `jira-technical-preparation-executor`
  e pela `jira-hotfix-creator`, **sem herdar autoridade adicional** dessas skills.
- **Atestação.** Atesta que o ticket foi criado conforme o rascunho aprovado e o
  vocabulário vigente.
- **Transição.** **Não move tickets existentes.** Regra geral: ticket novo nasce em
  `A fazer` ou backlog, conforme decisão aprovada. **Exceção contratual:** Hotfix
  qualificada pela `jira-hotfix-creator`, com fast-track autorizado, nasce
  diretamente em `Fazer - Claude`. A skill não escolhe arbitrariamente esse
  destino; apenas materializa a consequência determinada pelo Contrato de Tipo /
  Contrato Efetivo.

### Entradas e pré-condições
Projeto/Jira; necessidade relatada ou payload preparado; contexto já fornecido;
origem do trabalho quando derivado de Preparação Técnica; contexto/fast-track
preparado pela `jira-hotfix-creator` quando Hotfix; pai, quando Subtask;
confirmação/autorização exigida pelo fluxo antes da criação.

### Obrigações
Usar a descrição padrão aplicável ao tipo; **para Hotfix, preservar
integralmente a descrição/fast-track** preparado; escolher apenas tipos oficiais;
usar somente labels documentadas; exigir trilha documental para tipo Documentação;
tratar `requires-design` conforme o Contrato Efetivo, sem inventar confirmação ou
exceção; preservar a origem (GitHub, Validação Humana, Preparação Técnica ou
Hotfix); evitar duplicação quando a Preparação Técnica informar issue equivalente
já reutilizada; apresentar/validar o rascunho conforme a regra aplicável.

### Evidências, saída e limites
A issue criada no Jira é o registro oficial; links de origem são preservados nos
campos/relacionamentos previstos. Saída: ticket criado no destino inicial aprovado
e resumo. Limites: nunca cria sem a autorização exigida; nunca cria Subtask
órfã; nunca inventa label; nunca cria diretamente em etapa posterior por escolha
própria (a única criação fora de `A fazer`/backlog é a Hotfix validamente
qualificada, em `Fazer - Claude`); nunca implementa código ou documentação; nunca
cria ticket novo quando houver trabalho equivalente já reutilizado pela Preparação
Técnica; nunca cria ticket novo para problema que já pertence ao escopo de issue
existente numa reprovação.

> Passo 0 de toda execução: resolver o Contrato Efetivo
> (`workflow-development-flow/references/contrato-efetivo.md`). Defaults herdados:
> `workflow-development-flow/references/contrato-skills.md`.

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

**Gatilho de origem — Validação Humana.** Se a necessidade nasceu de um
problema encontrado por Rafinha durante uma `Validação Humana` e
classificado como **fora do escopo** das issues agregadas (requisito novo,
comportamento não previsto, melhoria, ou defeito sem origem atribuível),
use o cenário reprovado e o feedback dele como base do rascunho. Guarde a
chave da Validação Humana — ao criar a issue (passo 7), grave um link
`Relates` para ela, **sem exceção**. É esse link que permite auditar
depois, na `Análise Final - Claude`, se todos os problemas levantados por
aquela validação foram tratados.

**Gatilho de origem — Preparação Técnica.** Se a necessidade vem da
`jira-technical-preparation-executor` (trabalho técnico ausente), você recebe o
tipo semanticamente classificado por ela e o contexto preparado. Preserve na
descrição do trabalho derivado: a **issue de origem**; a **origem na Preparação
Técnica**; o trabalho necessário; o motivo; a dependência/blocker; o impacto; o
contexto técnico; as evidências — e crie o link nativo de dependência com a issue
de origem quando aplicável. Se ela informar que já existe issue equivalente
(reutilizada), **não crie outra**. Você valida o tipo contra os contratos (sem
whitelist artificial de tipos), mas não herda autoridade da Preparação Técnica.

**Gatilho de origem — Hotfix.** Se o payload vem da `jira-hotfix-creator`, ele já
traz o tipo `Hotfix`, a descrição completa com **fast-track**, o destino inicial
`Fazer - Claude` e a autorização de Rafinha registrada. Verifique que o payload
está completo (todas as seções do fast-track, autorização registrada) — payload
incompleto volta para a `jira-hotfix-creator`, você não o completa. Preserve a
descrição **integralmente**. A chave `<ISSUE-KEY>` das branches só existe depois da
criação: informe-a no resumo.

Nunca crie issue nova para um problema classificado como **pertencente ao
escopo original** de uma issue já existente — nesse caso a issue original
é reaberta pela `jira-human-validation-executor`, e criar uma issue nova
quebraria a rastreabilidade.

Verifique o que já está respondido pelo que ele escreveu (ou pelo conteúdo
da GitHub Issue, quando for o caso):

- **Do que se trata a issue** (a necessidade em si).
- **O contexto/motivo** (por que ele precisa disso).
- **Projeto/Jira de destino**.
- **Destino: `A fazer` ou backlog** (se ele não informar, decida sozinho
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

O **tipo nativo do ticket é a natureza da issue**. Escolha entre os 8 tipos
oficiais — nenhum outro é válido:

| Tipo | Quando usar |
|---|---|
| **Epic** | Frente maior de trabalho. Nunca executável diretamente |
| **Implementação** | Altera código de produto |
| **Correção** | Ajusta ou refina algo já entregue |
| **Bug** | Defeito real do produto |
| **Refatoração Técnica** | Melhoria estrutural sem mudança funcional planejada |
| **Documentação** | Cria/atualiza documentação |
| **Validação Humana** | Aceite manual de Rafinha (criada pela `jira-human-validation-executor`, não aqui) |
| **Hotfix** | Trabalho emergencial que não pode esperar o ciclo normal. **Só a partir de payload qualificado pela `jira-hotfix-creator`**; alta prioridade sozinha não é Hotfix |

**Correção ≠ Bug.** Correção ajusta algo já entregue sem que isso seja
necessariamente defeito: ajuste visual de UI já implementada, copy,
espaçamento, refinamento. Bug fica reservado a defeito real — erro ao salvar,
tela quebrando, validação incorreta, regressão.

Só pergunte a Rafinha se ficar em dúvida real entre dois tipos plausíveis —
não pergunte por rotina.

> ⚠️ **O campo customizado `Tipo` saiu do contrato.** Não o preencha, não o
> leia, não o mencione no rascunho.

### 4. Propor as labels

Toda label proposta precisa estar na **matriz oficial** (página *Vocabulário
operacional de labels*, espaço CS1). **Nunca invente label.** Se nenhuma
label oficial se encaixar e isso bloquear a classificação, registre a dúvida
e peça decisão a Rafinha.

**Trilha documental — obrigatória no tipo Documentação.** Uma issue do tipo
Documentação precisa de uma label de trilha: `rn-doc`, `module-doc`,
`screen-doc`, `component-doc`, `api-doc`, `architecture-doc`, `user-doc`,
`workflow-doc`, `skill-doc`, `release-doc`, `readme` ou `adr`. Se não estiver
claro qual, **pergunte** — não infira pelo conteúdo. A label `confluence` é
destino/meio e não satisfaz esse requisito sozinha.

**Plataforma — você propõe, não decide.** Pode sugerir `web`/`mobile`/… como
intenção inicial. Quem confirma ou corrige é a `jira-issue-executor`,
conforme os arquivos realmente alterados.

**Labels de produto/módulo/feature.** Só podem ser usadas se estiverem
declaradas na página de *Controle de workflow por produto* daquele produto.
Se a label que você quer não estiver lá, pergunte.

**`requires-design` — você só sugere.** Ver passo 4.1.

#### 4.1 `requires-design` é confirmada manualmente por Rafinha

Esta é a única label com regra de aplicação diferenciada.

- Você **pode sugerir** `requires-design` no rascunho, sempre marcada
  explicitamente como **sugestão**.
- Você **nunca** a aplica por conta própria, e nunca a inclui na criação sem
  Rafinha ter confirmado no rascunho.
- `ui` e `correcao-ui` **não** implicam `requires-design`.

Sugira quando a issue cria ou redesenha interface cujo resultado visual ainda
não está definido. Não sugira para ajuste pontual de algo já desenhado.

### 5. Montar o rascunho da issue

Monte um rascunho completo, sem ainda criar nada no Jira:

```
📝 Rascunho da issue — [projeto]
Tipo: [Implementação | Correção | Bug | Refatoração Técnica | Documentação | Epic | Hotfix (payload da jira-hotfix-creator)]
Hierarquia: [Issue | Subtask] — [Issue pai / Épico pai, se aplicável]
Título: [título objetivo]

Descrição (padronizada — workflow-development-flow §17):
  ## Objetivo
  [o que precisa ser alcançado/entregue]
  ## Contexto
  [o motivo/necessidade que originou a issue]
  ## Escopo
  [o que está incluído]
  ## Fora do escopo
  [o que explicitamente não está incluído, se já souber]
  ## Regras de negócio
  [regras já conhecidas, ou "Nenhuma"]
  ## Critérios de aceite
  [já conhecidos, ou "Nenhum"]
  ## Pendências de decisão
  [qualquer incerteza real que Rafinha ainda precisa fechar, ou "Nenhuma"]
  ## Decisões registradas
  [Nenhuma — preenchida depois, se a issue passar por Decisão - Rafinha]
  ## Orientação para implementação
  [notas técnicas relevantes, ou "Nenhuma"]

Labels: [labels propostas, todas da matriz oficial]
Trilha documental: [só para tipo Documentação — rn-doc | module-doc | ...]
Plataforma (intenção): [web | mobile | ... — a confirmar na implementação]
requires-design: [SUGESTÃO — precisa da sua confirmação | não se aplica]
Destino: [Backlog | A fazer] — [quem definiu e por quê]
Origem: [GitHub Issue #N (link) | Validação Humana CHAVE (cenário reprovado) | Preparação Técnica CHAVE (trabalho ausente) | Hotfix (jira-hotfix-creator) | Chat]
```

> **A seção Pendências de decisão não é decoração.** Se, ao montar o
> rascunho, sobrar alguma incerteza real de escopo, regra de negócio,
> comportamento ou critério de aceite que você não pode assumir sozinho,
> registre-a ali — é o que leva a issue para `Decisão - Rafinha` depois de
> criada, em vez de ela chegar madura demais tarde, em `Fazer - Claude`.

> **`requires-design` aparece sempre como SUGESTÃO**, nunca como decisão
> tomada. Se Rafinha não confirmar explicitamente, a label **não** é aplicada.

Apresente esse rascunho a Rafinha e **aguarde a aprovação dele antes de
criar a issue de fato** — esta confirmação é sempre obrigatória, mesmo que o
pedido pareça simples ou óbvio.

### 6. Decidir o destino (quando não informado manualmente)

Se Rafinha não especificou o destino, verifique se a necessidade se encaixa
no escopo/objetivo da sprint atual do projeto:

- Se encaixa → proponha criar em **`A fazer`**, a coluna de entrada do board.
- Se não encaixa (ou não há sprint ativa) → proponha manter no **backlog**.

**`A fazer` é a entrada bruta do board quando a issue sai do backlog.** O
backlog continua existindo como etapa pré-sprint — os dois coexistem. `A
fazer` não é fila autorizada para envio direto a `Fazer - Claude`.

A issue **nunca** é criada direto em `Preparação técnica - Claude`, `Design de
produto - Rafinha`, `Decisão - Rafinha`, `Ready` ou `Fazer - Claude` por escolha
própria. Quem decide o próximo passo a partir de `A fazer` é a
`jira-sprint-intake-executor`:

```text
A fazer → Decisão - Rafinha            (pendência real registrada — ver Pendências de decisão)
A fazer → Design de produto - Rafinha  (requires-design confirmada, sem pendência)
A fazer → Preparação técnica - Claude  (funcionalmente madura, sem os gates anteriores)
```

> ⚠️ **Única exceção contratual — Hotfix.** Uma Hotfix qualificada pela
> `jira-hotfix-creator`, com fast-track autorizado por Rafinha, nasce
> **diretamente em `Fazer - Claude`**. Você não escolhe esse destino: ele é a
> consequência determinada pelo Contrato de Tipo. Criar em `Fazer - Claude` não
> apaga as obrigações das etapas anteriores — o fast-track da descrição registra
> como cada uma foi tratada. Depois da criação, nenhuma skill move a Hotfix:
> Rafinha controla toda transição.

Esta skill não decide entre essas três — só cria em `A fazer` ou backlog e
deixa a seção **Pendências de decisão** da descrição refletindo o que já
sabe. Deixe a decisão de destino e o motivo dela visíveis no rascunho do
passo 5, para que Rafinha possa corrigir antes de aprovar.

### 7. Criar a issue no Jira

Somente após a aprovação do rascunho, crie a issue no Jira (via Atlassian
Rovo) com:
- Título e descrição **padronizada de 9 seções** (workflow-development-flow
  §17) conforme aprovado — nunca só Contexto/Objetivo.
- **Tipo oficial** correto (um dos 8 — passo 3).
- Labels aprovadas, **todas da matriz oficial**.
- `requires-design` **somente se Rafinha confirmou explicitamente** no
  rascunho. Na dúvida, não aplique.
- Label de trilha documental, quando o tipo for Documentação.
- Hierarquia correta — se Subtask, vinculada à Issue pai; se Issue, vinculada
  ao Épico pai quando houver.
- No destino aprovado (`A fazer` ou backlog).
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
- ❌ Nunca inferir o tipo do ticket quando não estiver claro pelo contexto —
  pergunte antes de criar a issue.
- ❌ Nunca ler nem preencher o campo customizado `Tipo`. Ele saiu do contrato.
- ❌ Nunca aplicar `requires-design` sem confirmação explícita de Rafinha no
  rascunho — sugerir é permitido, aplicar não.
- ❌ Nunca inventar label fora da matriz oficial do Confluence. Se nada se
  encaixar, registre a dúvida e peça decisão.
- ❌ Nunca usar label de produto/módulo/feature que não esteja declarada na
  página de Controle de workflow daquele produto.
- ❌ Nunca criar issue do tipo Documentação sem label de trilha documental.
- ❌ Nunca criar a issue direto em `Preparação técnica - Claude`, `Design de
  produto - Rafinha`, `Decisão - Rafinha`, `Ready` ou `Fazer - Claude` — o
  destino é sempre `A fazer` ou backlog. **Única exceção:** Hotfix validamente
  qualificada pela `jira-hotfix-creator`, que nasce em `Fazer - Claude`.
- ❌ Nunca criar Hotfix sem payload qualificado pela `jira-hotfix-creator`, nem
  alterar ou resumir o fast-track dela — a descrição é preservada integralmente.
- ❌ Nunca mover uma Hotfix depois de criada; toda transição é de Rafinha.
- ❌ Nunca criar issue duplicada de trabalho que a Preparação técnica já informou
  como reutilizado.
- ❌ Nunca usar o formato antigo de descrição (só Contexto/Objetivo) — a
  descrição padronizada de 9 seções (workflow-development-flow §17) é
  obrigatória em toda issue criada.
- ❌ Nunca deixar de gravar o campo `Link para GitHub Issue` quando a issue
  teve origem numa GitHub Issue (passo 1) — sem ele, `jira-issue-executor`
  não consegue referenciá-la no PR nem fechá-la automaticamente.
- ❌ Nunca deixar de criar o link `Relates` para a Validação Humana quando
  a issue nasceu de um problema fora do escopo encontrado nela (passo 1) —
  sem ele, a `jira-review-executor` não consegue auditar se a validação foi
  inteiramente tratada.
- ❌ Nunca criar issue nova para um problema de Validação Humana que
  pertence ao escopo original de uma issue existente — a issue original é
  reaberta, não substituída.
- ❌ Nunca, sob nenhuma circunstância, implementar código, escrever
  documentação, ou fazer qualquer trabalho além de criar a issue — mesmo que
  Rafinha peça isso na sequência da mesma mensagem. Essa é a regra mais
  importante desta skill.