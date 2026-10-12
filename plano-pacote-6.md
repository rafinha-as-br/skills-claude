# Plano de implementação — Pacote 6: Revisão do workflow 2

Registro de implementação, no formato dos `plano-pacote-N.md` anteriores.

**Fonte do contrato:** árvore do Notion *"Atualização - Revisão do workflow 2"*
(4 atualizações consolidadas: Contratos, Contextualização modular, Upgrade em
multi-repo, Preparação técnica e hotfix) e o *"Plano de implementação - Revisão do
workflow 2"* (lido em 2026-10-12, já com D4, D6, D7 e D8 confirmadas por Rafinha).
A subpágina *"Revisão de pontos para a atualização — histórico de decisões"* é
histórica e não-normativa — não foi usada como fonte.

**Escopo desta rodada, por instrução explícita de Rafinha:** só **Confluence e
skills**. **Nada de Jira.** Conteúdo conflitante é **substituído**, não
preservado.

**Vigência (D8, confirmada):** não há convivência entre contrato antigo e novo,
nem migração de issues existentes. Reset/reconfiguração operacional do Jira e das
skills; o workflow novo é a única referência para novas execuções.

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 0 | Registro local (este arquivo) | ✅ feito |
| 1 | `workflow-development-flow` (13 etapas, 8 tipos, escopo, G13/G14, branches, §18–20) + 6 `references/` novos | ✅ feito |
| 2 | 4 skills novas: `jira-technical-preparation-executor`, `jira-hotfix-creator`, `engineering-context-manager`, `ai-memory-manager` | ✅ feito |
| 3 | 10 skills do fluxo: intake, decision-resolver, issue-creator, issue-executor, integration, qa, human-validation, doc-executor, review, release | ✅ feito |
| 4 | Skills de apoio: 5 writers, `doc-pendency-resolver`, `flutter-development-standards`, `workflow-incident-capture-executor` | ✅ feito |
| 5 | `README.md`, `references/release-lifecycle.md` | ✅ feito |
| 6 | Confluence (6a normativas novas · 6b páginas do workflow e guia de montagem · 6c fichas) | ✅ feito |
| 7 | Verificação final, limpeza do scratch e resumo (sem commit — só se Rafinha pedir) | ✅ feito |

---

## 1. Decisões D1–D12

| # | Decisão |
| --- | --- |
| D1 | Skill `jira-hotfix-creator` (minúsculas); alias do Notion `Jira-hotfix-creator` citado nas fichas |
| D2 | Numeração das seções de `workflow-development-flow` preservada; conteúdo novo em §18–20 e `references/`. Quebrar o monolito = oportunidade futura |
| D3 | Contrato Efetivo sem engine/arquivo: procedimento "Passo 0" de 13 passos em `references/contrato-efetivo.md` |
| D4 | **Confirmada.** `jira-issue-executor` bloqueia quando a branch do Epic não existe (ex.: Epic promovido e excluído + issue reprovada); a issue volta à `Preparação técnica - Claude`, que recria a branch a partir de `develop`, revalida e libera novo `Ready`. O executor nunca recria branch de Epic |
| D5 | `engineering-context-manager` altera só a working tree; quem tem autoridade Git inclui no commit; chamadora sem autoridade Git → sem commit + reporte |
| D6 | **Confirmada.** `ai-memory-manager` pode `git add`/commitar as próprias alterações em `ai-memory/` em qualquer branch correta já existente (inclusive `develop` e `release/current`); sem `push`, merge, rebase, branch arbitrária ou gitlinks |
| D7 | **Confirmada.** Campo **Topologia** (mono-repo / multi-repo + Workspace) na página "Controle de workflow por produto"; ausente → bloqueia + incidente |
| D8 | **Confirmada.** Sem convivência/migração; reset operacional |
| D9 | Catálogo G1–G15 continua como índice; G13 e G14 reescritos; **sem gate numerado novo** |
| D10 | Model Policy das 4 skills novas: Sonnet/High (preparação, hotfix-creator); Sonnet/Medium (context/memory manager); preparação escala a Opus em decisão técnica complexa |
| D11 | Validação Humana: tipo nativo obrigatório, sem fallback `Tarefa` |
| D12 | Multi-repo "sem Workspace" da Integração (Pacote 5) preservado como base mecânica; Workspace acrescentado por cima |

**Decisão de implementação adicional (D13):** `release-lifecycle.md` descreve a
"pasta mãe" multi-repo sem Git. A Revisão do workflow 2 **não redefine** regras de
release não afetadas; adicionou-se uma nota esclarecendo que a relação entre o
Workspace Git e a pasta mãe do Release não é redefinida (decisão futura de Rafinha
se adotar o Workspace como pasta mãe).

---

## 2. Conteúdo conflitante descartado

| Onde | Descartado | Entrou |
| --- | --- | --- |
| Todas as skills, README, Confluence | "12 colunas / 12 etapas" | 13 etapas |
| intake, decision-resolver, §5.4/§8.1 | destino `Ready` direto; Ready = "fila de issues maduras" | destino `Preparação técnica - Claude`; Ready = Preparação PRONTA |
| `jira-issue-executor` | "única que cria branch de épico", "Garantia da branch de épico", recriação pós-reprovação | Preparação técnica cria; executor só consome; reprovação pós-promoção → D4 |
| `jira-integration-executor` | G14 "preparada pela jira-issue-executor" | "preparada pela Preparação técnica" |
| executor, intake, QA, integração, doc, human-validation, review, G13 | escopo "coluna inteira confirmada" | coluna de um Epic específico |
| human-validation, §12.3 | tipo `Validação Humana` ou, senão, `Tarefa` | tipo nativo obrigatório |
| integração, QA, human-validation, doc, review, executor | movimentação automática para todos os tipos | Hotfix: nenhuma movimentação automática |
| release-executor, release-lifecycle | QA elegível = só `qa-develop-aprovado` | elegível por estado da obrigação; caminho 1 inclui `hotfix/<KEY>` |
| review-executor | listas hardcoded de tipos/gates | Contrato Efetivo (Passo 0) + 16 verificações próprias |
| workflow-doc-writer | "o `SKILL.md` manda; corrija a ficha" | drift descritivo sincroniza; contratual reconcilia |

---

## 3. Artefatos criados/alterados (repo)

**Novos:**
`workflow-development-flow/references/{contrato-workflow,contrato-efetivo,politicas,contrato-skills,preparacao-e-hotfix,contexto-memoria-workspace}.md`;
`jira-technical-preparation-executor/`, `jira-hotfix-creator/`,
`engineering-context-manager/`, `ai-memory-manager/` (cada um com `SKILL.md`).

**Alterados:** `workflow-development-flow/SKILL.md`, `references/release-lifecycle.md`,
`workflow-doc-writer/references/skill-page.md`, `README.md`, e os `SKILL.md` de
`jira-sprint-intake-executor`, `jira-issue-decision-resolver`, `jira-issue-creator`,
`jira-issue-executor`, `jira-integration-executor`, `jira-qa-executor`,
`jira-human-validation-executor`, `jira-doc-executor`, `jira-review-executor`,
`jira-release-executor`, `product-doc-writer`, `tech-doc-writer`, `screen-doc-writer`,
`user-doc-writer`, `workflow-doc-writer`, `doc-pendency-resolver`,
`flutter-development-standards`, `workflow-incident-capture-executor`.

**Fora de escopo:** `task-creator-trabalho`, `weekly-organizer`.

---

## 3b. Confluence (espaço CS1) — o que foi feito

**Criadas (sob "Workflow"):** Contrato do Workflow, Contrato de Política, Contrato
Efetivo do Ticket, Contrato das skills, Preparação técnica e atestado, Hotfix e
fast-track, Contextualização de engenharia (context/), AI Memory, Workspace
multi-repo. **Criadas (sob "Skills"):** fichas de `jira-technical-preparation-executor`,
`jira-hotfix-creator`, `engineering-context-manager`, `ai-memory-manager`.

**Atualizadas:** home (Claude Skills), Skills (índice), Workflow (índice), Visão geral
do fluxo, Nomenclatura de colunas (= Contrato de Etapa), Tipos oficiais (= Contrato de
Tipo, 8 tipos), Gates operacionais, Controle de workflow por produto, Modelo de
branches, Design Package, Execution State, Validação Humana Agregada, Hierarquia,
Camadas de validação, Integração GitHub↔Jira↔PR, Model Escalation Policy, Release &
Versionamento, Release Lifecycle (guia), Pipelines no GitHub, guia "Como montar um
projeto" e os passos 1, 2, 3, 4 e 8, e as 19 fichas de skills existentes (Contrato da
skill + Operação técnica; `workflow-doc-writer` com a nova regra de drift).

**Revisadas sem mudança material:** Vocabulário operacional de labels, Componentes
reutilizáveis por produto.

**Nota D7:** o campo **Topologia** já existia em "Controle de workflow por produto";
foi apenas acrescentado o campo **Workspace** (e a pendência correspondente).

## 4. Handoff Jira (fica com Rafinha, fora desta sessão)

- Criar o status `Preparação técnica - Claude` (entre `Design de produto - Rafinha` e
  `Ready`; transições para `Ready`, de volta e as de entrada).
- Criar os tipos nativos `Hotfix` e `Validação Humana` em cada projeto.
- Declarar a **Topologia** de cada produto na página de Controle de workflow.
- Bootstrap manual do Workspace dos produtos multi-repo (repo superior, submodules).
- Sem migração de issues atuais (D8).
