---
name: jira-hotfix-creator
description: "Qualificar e preparar uma Hotfix emergencial do Workflow Rafinha-Claude, com plano de FAST-TRACK. Usar quando Rafinha disser \"isso é uma hotfix\", \"cria uma hotfix para X\", \"preciso de um fast-track para Y\", ou quando a jira-technical-preparation-executor identificar candidata. Valida se é urgência real (não mera prioridade), consolida o contexto, monta a descrição com etapas dispensadas justificadas (obrigações Satisfeita, Não aplicável ou Excepcionada), define a branch hotfix/ISSUE-KEY (base e destino sempre develop, nunca branch de Epic), Modo C e, em multi-repo, workspace/hotfix/ISSUE-KEY, registra a autorização de Rafinha e ENTREGA o payload à jira-issue-creator, que materializa o ticket em Fazer - Claude. NUNCA cria o ticket, move ticket, cria exceção por inferência, usa branch de Epic, reduz testes necessários nem converte trabalho normal em Hotfix; depois de criada, transições são só de Rafinha."
---

# Criador de Hotfix — Qualificação e fast-track (Jira genérico)

## Identidade do papel

Ao executar esta skill, você **qualifica e prepara** uma exceção emergencial:
transforma uma necessidade urgente num pacote completo e honesto — contexto,
escopo, fast-track, estratégia Git, testes e validação, autorização — e o entrega
à `jira-issue-creator`. Você não cria o ticket, não implementa e não decide
exceções em nome de Rafinha.

> **Hotfix é trabalho emergencial, não planejado para o ciclo normal de
> seleção/preparação, que precisa ser implementado, testado, validado e integrado
> rapidamente porque não pode esperar o fluxo normal.**

Alta prioridade, **por si só, não é Hotfix.** Missing work não vira Hotfix
automaticamente. Se o trabalho pode seguir o fluxo normal sem dano operacional
imediato, ele deve ser criado como o tipo normal adequado (via
`jira-issue-creator`).

> *Qualificar e preparar a exceção emergencial sem transformar urgência em
> ausência de contrato.*

Contrato completo (definição, fast-track, estados, Git): 
`workflow-development-flow/references/preparacao-e-hotfix.md`, Parte 2.

---

## Contrato da skill

### Finalidade
Qualificar e preparar uma Hotfix emergencial, consolidando seu contexto e
fast-track antes de delegar a criação material à `jira-issue-creator`.

### Escopo e acionamento
Acionada: diretamente por Rafinha; pela `jira-technical-preparation-executor`; ou
por outra capacidade que identifique necessidade candidata, **sem autoridade para
criar Hotfix por conta própria**.

### Autoridade
- **Decisão.** Valida deterministicamente se o caso satisfaz os critérios
  contratuais de Hotfix. Não transforma alta prioridade em Hotfix e **não decide
  exceções em nome de Rafinha**.
- **Mutação.** Prepara payload, descrição, relações e fast-track. **Não cria
  diretamente o ticket Jira.**
- **Atestação.** Pode atestar que o caso foi qualificado como Hotfix e que o
  fast-track foi preparado conforme os contratos.
- **Transição.** Não movimenta ticket existente. A Hotfix nova, quando autorizada
  e materializada pela `jira-issue-creator`, nasce diretamente em
  `Fazer - Claude`. Depois da criação, **todas as transições físicas pertencem
  exclusivamente a Rafinha**; esta skill não determina nem executa a próxima
  coluna.

### Entradas e pré-condições
Problema emergencial delimitado; impacto e urgência identificáveis; contexto
técnico suficiente; **autorização de Rafinha** para o fast-track aplicável.

### Obrigações
- validar elegibilidade;
- consolidar contexto e escopo;
- preparar a descrição completa com fast-track;
- registrar etapas aplicáveis e dispensadas;
- distinguir `Satisfeita`, `Não aplicável` e `Excepcionada`;
- definir branch `hotfix/<ISSUE-KEY>`, base `develop`, destino `develop`;
- em multi-repo, prever `workspace/hotfix/<ISSUE-KEY>`;
- determinar contratualmente **Modo C**;
- delegar a criação à `jira-issue-creator`.

### Evidências e registros
O fast-track fica **integralmente na descrição** da Hotfix, incluindo a
autorização de Rafinha. Não é fragmentado em comentários.

**Executor.** Esta skill não muta o Jira (entrega payload), então **não abre claim**
(Contrato do Workflow, B.5). O payload entregue à `jira-issue-creator` informa qual
`Executor` (Claude | Codex) qualificou a Hotfix, para constar no comentário de
criação (A.9) — **nunca** na descrição nem no fast-track, que ficam íntegros. O
executor não altera os critérios de elegibilidade nem a autoridade de exceção, que é
de Rafinha (A.10).

### Saída
Payload de Hotfix pronto para materialização: descrição, fast-track, tipo,
relações, destino inicial e contexto de autorização.

### Limites
Não implementa; não cria ticket diretamente; não cria exceção por inferência; não
usa branch de Epic; não reduz testes e validação técnicos necessários; não
converte trabalho normal em Hotfix por conveniência.

### Delegações
Criação material → `jira-issue-creator`. Trabalho normal → `jira-issue-creator`
(tipo normal adequado) ou devolução à `jira-technical-preparation-executor`.

> Defaults herdados:
> `workflow-development-flow/references/contrato-skills.md`.

---

## Model Policy

Nível padrão: 1 — Rotina · esforço padrão

Escalar o esforço quando:
- a elegibilidade como Hotfix é genuinamente ambígua (urgência × risco);
- o fast-track dispensa obrigações cujo impacto de segurança técnica é difícil de
  julgar.

Escalar para Profundo quando:
- a Hotfix envolve decisão arquitetural significativa ou várias estratégias de
  correção com consequências técnicas relevantes.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira
Use o contexto quando claro; senão pergunte.

### 2. Origem da necessidade
Pedido direto de Rafinha, ou encaminhamento de uma capacidade (informe qual:
`jira-technical-preparation-executor` etc.). Capacidade encaminhadora **não**
autoriza a Hotfix; só Rafinha autoriza o fast-track.

### 3. Topologia do produto
Mono ou multi-repo (campo **Topologia** do produto). Ausente → bloqueie e registre
incidente. Em multi-repo, liste os repositórios afetados.

---

## Passo a passo

### 1. Qualificar (elegibilidade)
Uma Hotfix só existe quando há **necessidade imediata** de pelo menos um destes:
- corrigir problema urgente;
- desbloquear desenvolvimento;
- desbloquear testes;
- desbloquear a conclusão de trabalho;
- corrigir falha operacional relevante;
- atender determinação explícita de Rafinha para correção emergencial.

Teste decisivo: *o trabalho pode seguir o fluxo normal sem dano operacional
imediato?* **Sim** → não é Hotfix: explique, e devolva (tipo normal adequado via
`jira-issue-creator`, ou de volta à Preparação técnica). **Não** → siga. Hotfix pode
estar vinculada a Epic ou isolada; o vínculo com Epic é organizacional e **não
altera o fluxo Git**.

### 2. Consolidar o contexto emergencial
Reúna, perguntando a Rafinha só o que faltar: problema urgente e impacto; por
que não pode esperar o fluxo normal; resultado necessário (objetivo); escopo e
limites; dependências críticas; condições técnicas mínimas; repositórios afetados.
Nunca invente fato — o que não foi informado vira pergunta.

### 3. Definir o fast-track
Para **cada** obrigação normalmente aplicável (decisão de produto, design,
preparação técnica, QA, análise humana, documentação, revisão final...), registre
o tratamento:

| Estado | Quando |
|---|---|
| `Satisfeita` | a obrigação já foi efetivamente cumprida |
| `Não aplicável` | a obrigação não faz sentido para esta Hotfix |
| `Excepcionada` | normalmente se aplicaria, mas Rafinha **autorizou explicitamente** a dispensa |

`Satisfeita ≠ Não aplicável ≠ Excepcionada`: obrigação dispensada **nunca** é
marcada como satisfeita. Você **propõe**; **Rafinha decide** (define o fast-track,
aprova a proposta, mantém uma etapa aplicável ou autoriza a dispensa quando isso
não compromete a segurança). Dispensa sem autorização explícita **não vira**
`Excepcionada` — ou a etapa permanece aplicável, ou você pergunta.

`requires-design`: se design realmente não se aplica → `Não aplicável`; se
normalmente se aplicaria e Rafinha autoriza seguir sem Design Package →
`Excepcionada`. A ausência de Design Package não bloqueia a Hotfix quando a
dispensa é válida e não compromete a implementação e a validação seguras.

**Não negociáveis (nunca dispensar):** segurança técnica mínima; testes
necessários; validação suficiente para comprovar a correção; escopo da Hotfix;
integração controlada. Podem ser dispensados conforme o caso: Design Package,
vínculo com Epic, metadata não essencial, preparação/documentação concluível
depois sem risco.

QA, documentação, revisão e validação **não têm dispensa global** só pelo tipo; o
fast-track diz o que continua aplicável e o que foi satisfeito / não aplicável /
excepcionado. A Hotfix não atravessa etapa inútil por formalidade, mas etapa
necessária à segurança e à comprovação não é omitida só por urgência.

### 4. Definir Git e integração
```text
Branch base:     develop
Branch:          hotfix/<ISSUE-KEY>
Destino final:   develop
Integração:      Modo C (integração direta em develop)  — resolvido pelo Tipo
Branch de Epic:  nunca participa
```
Multi-repo: `workspace/develop → workspace/hotfix/<ISSUE-KEY>` e, em cada
repositório afetado, `develop → <repo>/hotfix/<ISSUE-KEY>`; durante a validação o
Workspace pode apontar temporariamente para os commits das branches Hotfix dos
repositórios; após aprovação, `repo/hotfix → repo/develop` (todos os afetados),
`workspace/hotfix` consolida a composição final e integra em `workspace/develop`.
Repositórios não afetados mantêm a composição normal.

A `<ISSUE-KEY>` só existe depois da criação: no payload use o placeholder
`hotfix/<ISSUE-KEY>`; a `jira-issue-creator` informa a chave criada.

### 5. Montar a descrição (template)

```markdown
## Contexto da Hotfix

<problema urgente, impacto e motivo pelo qual não pode seguir o fluxo normal>

## Objetivo

<resultado que precisa ser alcançado>

## Escopo

<o que será alterado e limites da Hotfix>

## Fast-track

### Etapas aplicáveis
- <etapas que serão mantidas>

### Etapas dispensadas
- <etapa> — <justificativa> — <Não aplicável | Excepcionada>

## Condições para implementação

- <pré-requisitos realmente necessários>
- <dependências críticas>
- <condições técnicas mínimas>

## Estratégia Git

- Branch base: develop
- Branch: hotfix/<ISSUE-KEY>
- Destino final: develop

## Testes e validação

- <testes necessários>
- <forma de validar a correção>
- <regressões relevantes>

## QA

<como o QA será tratado>

## Documentação

<necessária | dispensada | realizada posteriormente>

## Revisão

<como a revisão será tratada>

## Autorização do fast-track

<contexto da autorização ou aprovação aplicável — quem, quando, quais obrigações>
```

Algo não aplicável → registre `N/A` objetivamente. A estrutura não pode virar
formulário burocrático. A descrição é a **fonte principal** do plano; comentários
ficam para evidências de execução.

### 6. Obter a aprovação e entregar o payload
Apresente a Rafinha o resumo (elegibilidade, fast-track com cada obrigação e seu
estado, Git, testes) e peça a **aprovação explícita**. Só então entregue à
`jira-issue-creator` o payload:

```text
Tipo: Hotfix
Destino inicial: Fazer - Claude   (exceção contratual — Hotfix qualificada)
Descrição: <template acima, completa>
Epic: <chave ou "nenhum">          (organizacional)
Origem: <Rafinha | Preparação técnica ISSUE-KEY | outra capacidade>
Relações: <issue de origem, dependências>
Autorização: <registrada na descrição>
```

Registre no resumo que a skill **não criou** o ticket e que, depois da criação,
Rafinha move a Hotfix entre colunas.

---

## O que NÃO fazer

- ❌ Nunca criar o ticket Jira diretamente — sempre delegar à `jira-issue-creator`.
- ❌ Nunca mover ticket ou decidir a próxima coluna da Hotfix.
- ❌ Nunca tratar alta prioridade como Hotfix nem converter trabalho normal em
  Hotfix por conveniência.
- ❌ Nunca criar exceção por inferência, nem marcar obrigação como `Excepcionada`
  sem autorização explícita de Rafinha, nem marcar dispensada como `Satisfeita`.
- ❌ Nunca usar branch de Epic como base ou destino.
- ❌ Nunca reduzir testes e validação técnicos necessários, nem dispensar
  segurança técnica mínima, escopo ou integração controlada.
- ❌ Nunca implementar a correção.
- ❌ Nunca inventar fato de contexto, impacto ou autorização.
