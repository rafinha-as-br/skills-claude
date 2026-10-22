# Pacote 8 — Rascunho de publicação no Confluence (CS1)

**Status: NÚCLEO (itens 1–6) E ÍNDICES (itens 7–8) PUBLICADOS, autorizados por Rafinha em 2026-10-21. Item 9 (22 fichas) NÃO publicado, de propósito.**
Preparado em 2026-10-21 a partir da leitura das páginas atuais. Publicar altera páginas reais do espaço
**CS1** (`cloudId ac6bf4cf-…`). Regra de vigência (mesma do Pacote 6): o texto conflitante é
**substituído**, sem convivência com o antigo.

**Publicado (cada página relida em HTML antes de atualizar; atualizada por substituição de corpo):**

| Item | Página | ID | Versão publicada |
|---|---|---|---|
| 1 | Contrato do Workflow | 79167489 | 5 |
| 2 | Contrato das skills | 79265793 | 3 |
| 3 | Model Escalation Policy | 48562226 | 3 |
| 4 | Execution State | 52887553 | 3 |
| 5 | Orquestração remota | 83197953 | 3 |
| 6 | 2. Sincronizar as skills | 44302422 | 6 |

**Publicado depois (itens 7 e 8, mesma regra: página relida em HTML antes de cada atualização):**

| Item | Página | ID | Versão |
|---|---|---|---|
| 8 | **Executores** (nova, filha de *Workflow*) | 86769665 | 1 |
| 7 | Claude Skills (home) | 44204199 | 11 |
| 7 | Skills (índice) | 44105730 | 9 |
| 7 | Workflow (índice) | 44105751 | 9 |

A página **Skills** avisa expressamente que as fichas ainda descrevem o contrato anterior à adaptação e que
serão regeneradas depois dos testes de laboratório (até lá, vale o `SKILL.md` como implementação e o Contrato
do Workflow como norma). A lista de páginas modificadas na última hora mostrou 9 de 10; a *Workflow* não
apareceu na busca (provável atraso de indexação), mas a atualização retornou a versão 9.

Verificação posterior (itens 1–6): `data-local-id` da lista de tarefas da página 6 preservados; link da ficha na
página 5 aponta para o ID real (83230721); só essas 6 páginas foram modificadas no espaço na hora da
publicação. A reversão é pelo histórico de versões de cada página.

**Divergências que já existiam e NÃO foram resolvidas (precisam de decisão de Rafinha):**
- *Model Escalation Policy:* a tabela do Confluence tem 14 linhas; a do repositório (§11.6) tem 18 (a mais:
  intake, decision-resolver, captura de incidente e Preparação técnica com decisão complexa). Mantive as 14,
  convertidas para nível.
- *2. Sincronizar as skills:* diz "25 skills" (README e Contrato das skills: 26 no repositório, 24 do
  workflow); tem um título "Coexistência com as skills da conta claude.ai" sem conteúdo.

O que **não** muda no Confluence: nomes de coluna (`Fazer - Claude`…), "Nomenclatura de colunas do
board", "Visão geral do fluxo" e "Preparação técnica e atestado" — os nomes contratuais ficam como estão
(A.10), então essas páginas não têm texto a corrigir por causa do executor.

## 1. Páginas e mudanças

| # | Página | ID | Mudança | Prioridade |
|---|---|---|---|---|
| 1 | Contrato do Workflow | 79167489 | 3 trocas + 2 seções novas (item 2) | Núcleo |
| 2 | Contrato das skills | 79265793 | 5 defaults herdados + 1 linha da anatomia (item 3) | Núcleo |
| 3 | Model Escalation Policy | 48562226 | Substituir pelo espelho da §11 atual do `workflow-development-flow` (níveis 0–4, tabela 11.6 por nível, 11.9 e 11.10) | Núcleo |
| 4 | Execution State | 52887553 | "sessões do Claude Code" → sessão de qualquer executor; seções `Executor` e `Handoff` no formato; `.claude/` como estrutura compartilhada; recovery com claim | Núcleo |
| 5 | Orquestração remota | 83197953 | canal remoto homologado; pré-condição de executor homologado; claim no despacho | Núcleo |
| 6 | 2. Sincronizar as skills | 44302422 | fonte única `~/.claude/skills`; `~/.codex/skills` só leitura (`git pull --ff-only`); limite de descrição do Codex | Núcleo |
| 7 | Claude Skills (home), Skills (índice), Workflow (índice) | 44204199 · 44105730 · 44105751 | menção ao Codex como executor alternativo **sem nenhuma capacidade homologada**; link para a página Executores | Índices |
| 8 | **Executores** (página nova, sob *Workflow*) | — | espelho de `references/executores.md`: matriz de capacidades e homologação declarada | Opcional |
| 9 | Fichas das skills (22 páginas) | ver abaixo | regenerar `Contrato da skill` e `Model Policy` a partir do `SKILL.md` via `workflow-doc-writer` (trilha ficha de skill, com **checagem de drift**) | Segunda etapa |

**Fichas (22):** `workflow-development-flow` 44400642, `workflow-remote-orchestrator`, `jira-sprint-intake-executor`
73170982, `jira-issue-decision-resolver`, `jira-technical-preparation-executor` 79953921, `jira-hotfix-creator`,
`jira-issue-creator`, `jira-issue-executor` 44072962, `jira-integration-executor` 44171267, `jira-qa-executor`
44367874, `jira-human-validation-executor` 50855937, `jira-doc-executor` 44204245, `jira-review-executor`
44400665, `jira-release-executor` 44072995, `engineering-context-manager`, `ai-memory-manager`,
`product-doc-writer`, `tech-doc-writer`, `screen-doc-writer`, `user-doc-writer`, `workflow-doc-writer`,
`workflow-incident-capture-executor` 73236522 (IDs ausentes: não consultados). Fora: `doc-pendency-resolver` e
`flutter-development-standards` (sem mudança de contrato). As descrições do `SKILL.md` **não** vão para as
fichas (elas têm o próprio "Resumo").

## 2. Contrato do Workflow — texto proposto

**Troca A** — em *Exceção oficial — Comando remoto*:
`Numa sessão de Remote Control iniciada por Rafinha` →
`Numa sessão remota iniciada por Rafinha em **canal remoto homologado** (ver *Executor técnico*)`.

**Troca B** — depois da tabela de *Autoridade de evidência*, acrescentar:

> **Registro mínimo por operação relevante.** Todo registro operacional no Jira carrega, no mínimo:
> `Executor` (Claude | Codex — quem de fato executou), `Tentativa` (quando aplicável), `Escopo fechado` (as
> issues efetivamente processadas), `Evidências` (links, SHAs, runs, páginas) e `Handoff` (origem e destino,
> quando houve). O campo `Executor` não substitui o título contratual do comentário.

**Seção nova** — `## Executor técnico` (depois de *Autoridade de evidência*, antes do Bloco B):

> **Claude Code e Codex são executores técnicos alternativos.** A escolha do executor não altera a
> autoridade, o escopo, os gates, as evidências nem as transições permitidas para a skill: o contrato vale
> igual para qualquer executor. Ferramenta, conector, plugin ou token continuam não sendo autoridade.
> - **Nomes contratuais históricos.** Colunas (`Fazer - Claude`, `QA - Claude`, `Preparação técnica - Claude`,
>   `Análise Final - Claude`), o sufixo `-claude` da branch, títulos de comentário estruturado (ex.:
>   "Implementação Claude") e labels operacionais são nomes do contrato: não indicam o executor e não mudam
>   quando ele muda. Quem agiu consta em `Executor`.
> - **Capacidade ausente é bloqueio.** Se o executor não tem capacidade homologada que uma etapa ou gate
>   exige (executor web, conector Jira/Confluence/GitHub/AIO Tests, revisão de código), o gate permanece não
>   satisfeito. Sem fallback silencioso.
> - **Homologação.** Um executor só opera uma capacidade depois dos três testes — seleção, execução permitida
>   e negativa/gate — em projeto de laboratório **e** da declaração de Rafinha. Sem declaração, a capacidade
>   fica apenas no executor já homologado.
> - **Canais remotos e executor web** significam *canal remoto homologado* e *executor web homologado*, nunca
>   uma ferramenta presumida.
> - **Nível, não modelo.** A política de modelo é expressa em níveis neutros; cada executor mapeia o nível
>   para a própria configuração. O executor recomenda, Rafinha decide.

**Seção nova** — `## Concorrência, claim e handoff entre executores` (no fim do Bloco B):

> **Uma issue não pode ter dois executores (ou duas sessões) mutando a mesma etapa ao mesmo tempo.**
> **Claim.** Toda execução que **muta** uma issue ou o trabalho dela abre, depois de fechar o escopo e antes da
> primeira mutação, um comentário de claim no Jira por issue (`Executor`, etapa/skill, escopo fechado,
> tentativa). Claim vigente de **outro** executor (sem resultado nem liberação) → a skill para e reporta a
> Rafinha; nunca disputa nem presume abandono. O claim **não expira**: só Rafinha o libera. Termina com o
> comentário de resultado da própria etapa ou com a liberação de Rafinha. Mesmo executor em sessão nova é
> retomada (recovery check), não disputa. Capacidades sem mutação de issue não abrem claim.
> **Retomada por outro executor (handoff):** (1) claim anterior concluído ou liberado por Rafinha; (2) recovery
> check completo e reconciliação com Jira, Git/GitHub, Execution State, `context/` e `ai-memory/`; (3) handoff
> registrado no Jira (origem → destino, motivo, estado verificado, próxima ação); (4) novo claim. Divergência
> que arrisque decisão ou trabalho → para e pergunta. Mutação já registrada nunca é refeita sem checar a
> evidência.

## 3. Contrato das skills — texto proposto

Na lista de *Defaults herdados*, acrescentar:

> - **O executor não é autoridade.** Trocar de executor (Claude Code ou Codex) não troca autoridade, escopo,
>   gates, evidências nem transições. Capacidade não homologada bloqueia; sem fallback silencioso.
> - **Identidade do executor.** Todo registro operacional no Jira inclui `Executor`; o título contratual do
>   comentário não muda.
> - **Claim antes de mutar.** Skill que muta issue abre o claim antes da primeira mutação e para diante de claim
>   vigente de outro executor.
> - **Reconciliar antes de retomar.** Retomada exige recovery check e reconciliação do estado local com Jira,
>   Git e GitHub; handoff entre executores é registrado. O estado local nunca é instrução cega.
> - **Nível, não modelo.** A skill declara na `Model Policy` um nível (0–4); cada executor o mapeia.

Na anatomia: `Model Policy, recovery, detalhes específicos` → `Model Policy (nível 0–4), recovery, detalhes
específicos`. A contagem (24 skills) e a lista não mudam.

## 4. Ordem recomendada de publicação

1. **Núcleo (itens 1–6):** é o que torna o contrato consistente entre skills (já commitadas) e Confluence.
   Sem isso há *drift contratual* declarado.
2. **Índices e página Executores (itens 7–8).**
3. **Fichas (item 9):** depois dos testes de laboratório, porque as skills ainda podem mudar nas
   homologações; regenerar uma vez só, com checagem de drift.

## 5. Riscos a considerar antes de publicar

- O Confluence é a **autoridade normativa**. Publicar A.10 e B.5 torna a regra de claim e de homologação
  normativa **antes** de qualquer teste real. O texto já diz que sem homologação o Codex bloqueia, então o
  risco é de expectativa, não de comportamento.
- Páginas com **comentários inline** ou edições manuais recentes: o `updateConfluencePage` substitui o corpo;
  cada página deve ser relida imediatamente antes de atualizar (versão) e atualizada por trechos.
- As páginas não têm histórico Git próprio: o histórico de versões do Confluence é a única reversão.
