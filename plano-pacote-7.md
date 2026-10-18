# Plano de implementação — Pacote 7: Orquestração remota

Registro de implementação, no formato dos `plano-pacote-N.md` anteriores.
**Status: PLANO — nada implementado ainda.**

**Fonte do contrato:** página Notion *"Orquestração remota"* (filha de *Rafinha Workflow*,
lida em 2026-10-18; "Decisão atual" + "Diretrizes recebidas para a primeira versão
experimental" + "Itens deixados para teste"). Estado declarado na própria página:
*pronta para criar e testar como primeira versão experimental*.

**Escopo (instrução explícita de Rafinha):** só **skills (repo)** e **Confluence (CS1)**.
**Nada de Jira.** Conteúdo conflitante é **substituído**, não preservado. Sem convivência
com o texto antigo, sem migração (mesma vigência do Pacote 6 — Contrato do Workflow, Bloco E).

**Veredito de bloqueio:** nenhum item crítico. Tudo que o Notion deixou em aberto está
marcado lá mesmo como "hipótese de teste" ou é resolvido pelos defaults da seção 1.

---

## 1. Decisões tomadas por default (Rafinha não precisa decidir agora)

| # | Lacuna / tensão | Default adotado |
| --- | --- | --- |
| P1 | O Notion diz, em "Decisão atual", que a orquestradora pode fazer "transições Jira permitidas" e, em "Diretrizes", que **não** deve ter "transição própria ilimitada" e que o mecanismo de `Ready → Fazer` está indefinido | **Autoridade de transição limitada e enumerada.** A orquestradora só executa dois tipos de transição, **ambos como execução de comando explícito de Rafinha, registrado em comentário da issue**: (a) `Ready → Fazer - Claude` (issue normal com atestado `PRONTA`); (b) saída de coluna de Rafinha (`Análise - Rafinha`, `Análise Final - Rafinha`, `Design de produto - Rafinha`) **quando Rafinha declara o resultado** (ex.: "PR aprovado") — a orquestradora registra, nunca escolhe o resultado. Qualquer outra transição continua sendo da skill dona da etapa. Nunca Hotfix, nunca Modo B |
| P2 | Hotfix: "nenhuma skill move" × "confirmação remota vale como ação manual" | **Prevalece a exceção Hotfix** (o próprio Notion diz que a orquestradora "não pode corrigir isso"). Orquestradora não move Hotfix; Rafinha move pelo Jira |
| P3 | Skills delegadas exigem confirmar escopo; a orquestradora já confirmou com Rafinha → pergunta duplicada | Cláusula nova no Contrato do Workflow (B.2): **escopo fechado e confirmado por Rafinha na sessão e repassado pela orquestradora vale como confirmação**; a skill continua registrando o escopo no Jira. Sem editar a lógica de cada executor além de uma frase de referência |
| P4 | "Continuar EPIC-123" autoriza várias issues em sequência, mas o **modo da Integração nunca é inferido** | O cartão de confirmação de escopo da orquestradora **pergunta o modo (A/B/C)** quando o recorte inclui `Integração`. Modo B: confirmação distinta **na hora do merge**, nunca herdada de confirmação anterior da sessão |
| P5 | Concorrência, expiração, religamento, falha/repetição, compactação, custo | Ficam como o Notion definiu: **hipóteses de teste**, listadas na ficha como "Pontos em observação". Sem trava implementada na v1. Diante de estado ambíguo: ler evidência antes de repetir ação material |
| P6 | Model Policy | **Nenhuma** (Notion: "sem Model Escalation Policy específica"). A seção `## Model Policy` da skill diz isso explicitamente e não escala sozinha |
| P7 | Onde mora a regra | Spec completa em `workflow-development-flow/references/orquestracao-remota.md` (espelho da página Confluence); `SKILL.md` da skill = contrato + operação; `workflow-development-flow` ganha só §21 curta + correções pontuais |
| P8 | Contagem de skills | 23 → **24** no Rafinha-Claude; repo 25 → **26** |
| P9 | Permissões do Claude Code no notebook (prompts de ferramenta) | Fora do contrato: o Remote Control repassa o prompt ao celular; a skill não contorna. Anotado como pré-requisito operacional |

---

## 2. Conteúdo conflitante a descartar

| Onde | Descartar | Entra |
| --- | --- | --- |
| `workflow-development-flow` §4 (~l.390) e §5.4 (~l.514); FAQ (~l.2205); README ("Rafinha autoriza"); Confluence: Visão geral do fluxo, Nomenclatura de colunas, Preparação técnica e atestado | "`Ready → Fazer - Claude` é manual, feita por Rafinha" | "é autorização de Rafinha — dada por ele no Jira **ou** por confirmação remota explícita executada pela `workflow-remote-orchestrator`, registrada em comentário" |
| `contrato-workflow.md` A.5 | autoridade de transição só da skill dona da etapa | + exceção "Comando remoto" (P1), com Hotfix e Modo B excluídos |
| `contrato-workflow.md` B.2 | skill sempre apresenta o conjunto ao humano para confirmar | + escopo já confirmado na sessão e repassado vale (P3) |
| `contrato-skills.md` | "Incluídas (23)" | 24, + default herdado "Chamada pela orquestradora" |
| Executores (issue, integração, QA, doc, review, human-validation, intake, preparação) | "confirma o escopo com Rafinha antes de buscar issues" sem alternativa | + 1 frase: escopo confirmado e repassado pela orquestradora na sessão conta |
| README, Confluence home/Skills/Workflow | "23 skills", sem skill de orquestração | 24, nova família "Orquestração remota" |

---

## 3. Ondas de implementação

### Onda 1 — Spec e contrato (repo)
1. **Novo** `workflow-development-flow/references/orquestracao-remota.md`: objetivo, comandos
   ("Onde paramos?", "Continuar EPIC", "Trabalhar ISSUE", "Preparar issues de EPIC em
   Preparação técnica", "Retomar sessão X", "Parar/cancelar"), mapa etapa → skill dona →
   limite remoto (tabela do Notion, com P1/P2/P4), fluxo de 9 passos, saída (cartão
   remoto), segurança, regras especiais, itens em observação (P5).
2. `contrato-workflow.md`: A.5 (exceção comando remoto), B.2 (P3), A.8 (nota: nada muda nas
   decisões reservadas).
3. `contrato-skills.md`: incluídas (24), default herdado "Chamada pela orquestradora —
   delegação não transfere autoridade; a chamada atua só no contrato dela".
4. `workflow-development-flow/SKILL.md`: §4/§5.4 (Ready→Fazer), §8 (nota em G13/G15: a
   orquestradora preserva, não satisfaz), §9 (frase de responsabilidade), §18 (índice), **§21
   Orquestração remota** (curta, aponta para a reference), FAQ, "NUNCA faz". Frontmatter
   `description` só se citar contagem/lista.

### Onda 2 — A skill nova (repo)
5. **Novo** `workflow-remote-orchestrator/SKILL.md` — frontmatter (`name`,
   `description` com gatilhos: "onde paramos?", "continua o EPIC-X", "trabalha a ISSUE-Y",
   "prepara as issues do épico", "retoma a sessão", "para/cancela", sessão Remote Control),
   `## Identidade`, `## Contrato da skill` (12 campos do `contrato-skills.md`:
   finalidade; escopo/acionamento; decisão = só consequências únicas; mutação = nenhuma além
   das transições de P1 e comentário Jira; atestação = só "comando recebido, escopo
   interpretado, despachado/não, resultado comunicado"; transição = P1; entradas e
   pré-condições incl. checagem read-only de disponibilidade; obrigações; evidências =
   comentário Jira com alvo/escopo/ação/resultado; saída = cartão remoto; limites; delegações
   a skills donas, `ai-memory-manager`, `workflow-incident-capture-executor`), depois
   `## Operação técnica` (invocar skills uma por vez via Skill tool — nunca em paralelo no
   mesmo alvo; descoberta de "onde paramos?" por Jira → AI Memory/Execution State, sem ranking
   fixo; formato do comentário Jira; resposta curta de celular → comentário da issue),
   `## Model Policy` (P6), `## O que NUNCA faz`.

### Onda 3 — Ajustes cirúrgicos nas skills existentes (repo)
6. Uma frase de referência ao escopo repassado (P3) em: `jira-sprint-intake-executor`,
   `jira-technical-preparation-executor`, `jira-issue-executor`, `jira-integration-executor`,
   `jira-qa-executor`, `jira-human-validation-executor`, `jira-doc-executor`,
   `jira-review-executor`.
7. `jira-integration-executor`: Modo B — "autorização distinta e atual; nunca herdada da
   orquestradora nem de confirmação anterior" (G15).
8. `jira-issue-executor` / `jira-technical-preparation-executor`: onde dizem que `Ready →
   Fazer` é manual, alinhar ao texto de §2.
9. `ai-memory-manager` e `workflow-incident-capture-executor`: acrescentar a orquestradora
   como chamadora legítima (handoff / incidente). Nenhuma autoridade nova.
10. `workflow-doc-writer`: só se enumerar skills (verificar; provável nenhuma mudança).

### Onda 4 — README e registro (repo)
11. `README.md`: 26/24, linha em "Quem faz o quê" (Rafinha confirma pelo celular), grupo
    "Orquestração remota" no catálogo, linha do Claude Code Remote Control no ecossistema
    (condicional), aviso "primeira versão experimental" em Estado atual, referência ao
    `orquestracao-remota.md` e a este plano.
12. Fechar este arquivo (status por onda, lista final de artefatos). **Sem commit** — só se
    Rafinha pedir.

### Onda 5 — Confluence (espaço CS1, `cloudId ac6bf4cf-79ad-4c22-b74c-d6c177939afa`)
Criar (usando `workflow-doc-writer`: templates `workflow-page.md` e `skill-page.md`):
- **Orquestração remota** (sob *Workflow* `44105751`) — espelho de `orquestracao-remota.md`.
- Ficha **`workflow-remote-orchestrator`** (sob *Skills* `44105730`) — com "Pontos em observação".

Atualizar (substituir o trecho conflitante, sem preservar):

| Página | ID | Mudança |
| --- | --- | --- |
| Contrato do Workflow | 79167489 | A.5, B.2 (espelho da Onda 1) |
| Contrato das skills | 79265793 | 24 skills + default herdado |
| workflow-development-flow (ficha) | 44400642 | §21, Ready→Fazer |
| Skills (índice) | 44105730 | linha da nova ficha, contagem |
| Workflow (índice) | 44105751 | link da nova página |
| Claude Skills (home) | 44204199 | menção ao controle remoto |
| Visão geral do fluxo | 44302381 | Ready→Fazer + parágrafo remoto |
| Nomenclatura de colunas | 44302402 | Contrato de Etapa de `Ready` / `Fazer - Claude` |
| Preparação técnica e atestado | 79298561 | quem autoriza Ready→Fazer |
| Hotfix e fast-track | 79331329 | orquestradora não move Hotfix |
| Gates operacionais | 68223007 | notas G13/G15 |
| Fichas dos 8 executores (intake, preparação, executor, integração, QA, human-validation, doc, review) | 73170982, 79953921, 44072962, 44171267, 44367874, 50855937, 44204245, 44400665 | frase P3 (+ G15 na integração) |
| Fichas `ai-memory-manager`, `workflow-incident-capture-executor` | 79986689, 73236522 | chamadora legítima |
| Como montar um projeto — passo 2 (Sincronizar as skills) | 44302422 | pré-requisito opcional: Remote Control no notebook |

Revisar sem mudança esperada: Model Escalation Policy (68 ficha só se listar skills por nome),
Execution State, AI Memory.

### Onda 6 — Verificação
- `grep` no repo: nenhuma ocorrência restante de "Ready → Fazer … manual, feita por Rafinha",
  "23 skills", "Incluídas (23)".
- Cada página Confluence tocada: reler e confirmar que não sobrou o texto antigo.
- Registrar "Última verificação de drift" na ficha nova.
- Resumo final para Rafinha; **sem commit**.

---

## 4. Handoff (fica com Rafinha, fora desta sessão)

- Jira: **nada** nesta atualização (instrução). Para a skill funcionar de ponta a ponta, o
  usuário Jira usado pela sessão precisa poder executar as transições da seção P1 — já é o caso
  hoje (mesmo usuário das skills).
- Notebook: Claude Code Remote Control configurado e autenticado; projeto/diretório correto.
- Teste real: rodar 1–2 comandos ("Onde paramos?" e um `Trabalhar ISSUE-X` de baixo risco) e
  alimentar a seção "Pontos em observação" com o que aparecer (concorrência, desconexão, custo).

## 5. Estimativa de esforço (para o prazo)

Onda 1+2 (núcleo, bloqueia o resto): é o caminho crítico. Ondas 3 e 4 são edições de 1–3 linhas
cada. Onda 5 é a mais longa por volume de chamadas de API (≈ 28 páginas); as 14 edições de
fichas/índices são independentes entre si. Se o prazo apertar, o **mínimo utilizável** é
Ondas 1, 2 e a criação das duas páginas novas + Contrato do Workflow/das skills no Confluence;
as fichas dos executores (P3) podem ficar para depois sem quebrar a operação, porque a cláusula
B.2 já cobre o comportamento.

---

## 6. Status de implementação (atualizado)

| Onda | Status |
| --- | --- |
| 1 — reference `orquestracao-remota.md`, `contrato-workflow.md` (A.5, B.2), `contrato-skills.md` (24 + default), `workflow-development-flow/SKILL.md` (§4, §5.4, §18, §21, FAQ, frontmatter) | ✅ feito |
| 2 — `workflow-remote-orchestrator/SKILL.md` | ✅ feito |
| 3 — frase de escopo repassado em 8 executores; G15 na integração; chamadora em `ai-memory-manager` e `workflow-incident-capture-executor` | ✅ feito (`workflow-doc-writer`: sem mudança necessária) |
| 4 — README | ✅ feito |
| 5 — Confluence | ver abaixo |
| 6 — Verificação | pendente |

**Artefatos novos (repo):** `workflow-remote-orchestrator/SKILL.md`,
`workflow-development-flow/references/orquestracao-remota.md`, `plano-pacote-7.md`.
**Alterados:** `workflow-development-flow/SKILL.md`, `references/contrato-workflow.md`,
`references/contrato-skills.md`, `README.md`, e os `SKILL.md` de intake, preparação técnica,
issue-executor, integração, QA, human-validation, doc, review, `ai-memory-manager`,
`workflow-incident-capture-executor`.

### Confluence (Onda 5) — estado final

**Criadas (CS1):** *Orquestração remota* (83197953, sob Workflow) e ficha
`workflow-remote-orchestrator` (83230721, sob Skills).

**Atualizadas:** Contrato do Workflow (A.5 exceção Comando remoto; B.2 escopo repassado),
Contrato das skills (24 + default), Skills (índice), Workflow (índice), Claude Skills (home),
Visão geral do fluxo, Nomenclatura de colunas (Ready), Preparação técnica e atestado,
Hotfix e fast-track, Gates operacionais (G13/G15), ficha `workflow-development-flow` (§21),
fichas `jira-integration-executor`, `jira-technical-preparation-executor`,
`ai-memory-manager`, `workflow-incident-capture-executor`.

**Fichas dos executores:** a frase "escopo repassado pela orquestradora" foi aplicada também em `jira-sprint-intake-executor`, `jira-issue-executor`, `jira-qa-executor`, `jira-human-validation-executor`, `jira-doc-executor` e `jira-review-executor`. **Não feito:** passo 2 de *Como montar um projeto* (pré-requisito opcional de Remote Control).

### Verificação (Onda 6)
Repo: nenhuma ocorrência restante de "Ready → Fazer … manual, feita por Rafinha" nem de
"23 skills". Nenhum commit feito.
