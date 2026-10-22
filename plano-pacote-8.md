# Plano de implementação — Pacote 8: Codex como executor alternativo

Registro de implementação, no formato dos `plano-pacote-N.md` anteriores.
**Status: PLANO APROVADO — Onda 0 executada e sincronizada (`c0c3322`); Onda 1 sincronizada (`7bf58f5`); Onda 2 sincronizada (`e5d0ce5`); Onda 3 sincronizada (`05e0eb9`); Onda 4 sincronizada (`2f10538`); Onda 5 sincronizada (`3b79d1c`); Onda 6: README feito e núcleo do Confluence publicado (itens 1–6); Ondas 1–6 pendentes.**

**Fonte:** `plano-adaptacao-codex.md` (proposta de Rafinha, em `~/.codex/skills/`), avaliada em
2026-10-21 contra o repo e contra `~/.codex`. As 6 decisões pendentes do plano original e as 6
lacunas novas abaixo foram **aprovadas por Rafinha em 2026-10-21** conforme as recomendações.

**Escopo:** skills (repo) e, na última onda, Confluence (CS1) e README. **Nada de Jira.**
Invariáveis do plano original mantidos integralmente: Contratos (Workflow, Tipo, Política, Etapa,
Efetivo), Gates G1–G15, autoridades, escopo explícito, separação entre etapas, regras de
Hotfix, evidências primárias. Nomes de colunas Jira e gramática de branch (`-claude`) **não mudam**.

---

## 1. Decisões aprovadas

### 1.1 As 6 pendências do plano original

| # | Pendência | Decisão |
| --- | --- | --- |
| D1 | Convivência com `.claude/` | **Aprovada.** `.claude/execution-state/` e `.claude/design-packages/` passam a ser formalmente estruturas históricas compartilhadas do workflow. Migração para caminho neutro só em evolução futura, com plano de compatibilidade |
| D2 | Política neutra de modelo | **Aprovada com 5 níveis, não 2** (ver L3). "Rotina/Profundo" do plano original **descartado** |
| D3 | Onde o Codex começa | **Etapas selecionadas.** Habilitado: Lotes A, B, D (documentação sem visual) e revisão. **Piloto no laboratório:** Lote C. **Só Claude até homologação:** QA, Release, orquestração remota e Modo B da Integração |
| D4 | Executor de QA Web | Codex já tem `browser` e `computer-use` instalados. Homologar **somente depois** de os três resultados (Aprovado / Reprovado / Inconclusivo) passarem no laboratório. Até lá, QA visual por Codex **bloqueado**, sem fallback silencioso |
| D5 | AIO Tests, Drive, Todoist, Calendar | Autorizado **só AIO Tests** (dependência do QA), sem token em chat, log ou Execution State. Drive só se a Release exigir. Todoist e Calendar ficam para o Lote G, fora do núcleo |
| D6 | Revisão Codex | **Manual, sob demanda por PR.** Automática só após estabilizar. Nunca comenta no GitHub sem autorização |

### 1.2 As 6 lacunas novas (não cobertas pelo plano original)

| # | Lacuna | Decisão |
| --- | --- | --- |
| L1 | Dois clones do mesmo repo (`~/.claude/skills` e `~/.codex/skills`, mesmo commit e remote) | **Fonte única** = `~/.claude/skills`. O clone Codex só faz `pull` (ou vira junction). `.system/` e arquivos soltos do clone Codex fora do versionamento (`.gitignore` local). Nunca editar nos dois |
| L2 | Descrições acima de 1024 caracteres e com `<`/`>` (24 de 26 skills; validador do Codex rejeita; runtime trunca o índice em ~380 caracteres) | **Onda 0:** reescrever `description` com **≤ 1024 caracteres, sem `<` `>`, gatilhos no começo**; o detalhe contratual já mora no corpo. Testar seleção no Claude **e** no Codex |
| L3 | Política de modelo de 2 níveis perde a gradação atual (Sonnet/Opus × Medium/High/XHigh, "subir effort antes de trocar modelo", tabela 11.6) | **Níveis neutros 0–4** com a mesma lógica de escalonamento; tabela 11.6 passa a referenciar nível. Cada executor mapeia nível → capacidade própria (tabela do Codex a preencher na homologação). Regra mantida: o executor recomenda, Rafinha decide, nunca escala sozinho |
| L4 | Título dos comentários estruturados ("Implementação Claude") alimenta o contador de tentativa e o recovery | **Título fixo**, tratado como nome contratual histórico (igual a colunas e branches). A identidade real vai no campo `Executor: Claude \| Codex` |
| L5 | "Bloqueio de concorrência" sem mecanismo; Execution State é local e invisível entre hosts | **Comentário de claim no Jira** (executor, etapa, início, tentativa) antes de agir, mais o recovery check já exigido. Retomada por outro executor = leitura das fontes primárias + handoff verificável. Claim ativo de outro executor → para e reporta |
| L6 | Skill nova `codex-independent-review` duplica o `review-agent` já existente em `.codex/skills/.system` | **Não criar skill nova.** Chamar `review-agent` (somente leitura, P0–P3) e levar o critério de over-engineering do `ponytail-review` para o prompt de revisão |

### 1.3 Ainda em aberto (não bloqueia o início)

- **Projeto e issues de laboratório:** Rafinha precisa indicar qual. Todos os critérios de aceite dependem dele. Sem laboratório, as Ondas 3 em diante ficam em "texto pronto, não habilitado".
- **Conectores Atlassian/GitHub/Confluence no Codex:** *(corrigido na Onda 5)* não aparecem no `config.toml`, **mas existem**: o cache de plugins tem `atlassian-rovo` e `github`, e o inventário de ferramentas das sessões do Codex lista `atlassian_*` e `github_*` (ver `references/executores.md`). O que continua em aberto é se estão **ativos e autorizados** na conta, e a homologação. Ausência = bloqueio do gate correspondente (regra do plano original).

---

## 2. Cláusulas contratuais novas

- **Contrato do Workflow:** "Claude Code e Codex são executores técnicos alternativos. A escolha do
  executor não altera a autoridade, o escopo, os gates, as evidências nem as transições permitidas
  para a skill." Acrescentar: acesso técnico não amplia autoridade contratual.
- **Contrato das skills:** (a) campo `Executor` em registros Jira; (b) handoff entre executores;
  (c) claim e bloqueio de concorrência (L5); (d) reconciliar estado local, Jira, Git e GitHub antes
  de retomar; (e) mapeamento nível → capacidade por executor.
- **Registro mínimo por operação relevante:** `Executor` · `Tentativa` · `Escopo fechado` ·
  `Evidências` · `Handoff`.
- **Orquestração remota** refere-se a **canal remoto homologado** (Claude Code Remote Control ou
  Codex Remote Control). **QA Web** refere-se a **executor web homologado**, sem presumir Claude in Chrome.

---

## 3. Ondas de implementação

Regra de todas as ondas: **texto neutralizado ≠ Codex habilitado.** A habilitação segue D3 e só
ocorre depois dos três testes (seleção, execução permitida, negativa/gate) no laboratório.
Substituir "Claude Code" por "executor autorizado" **só** onde a regra é comum; manter "Claude"
em nome de coluna, branch, título de comentário e fato histórico.

### Onda 0 — Infraestrutura (L1, L2) — **status: executada e sincronizada em 2026-10-21; falta o teste real de seleção**
1. **[feito]** Fonte única = `~/.claude/skills`. No clone Codex, `.system/` entrou em
   `.git/info/exclude` (config local, não versionada). O clone Codex continua sendo só leitura.
   **[feito]** commit `c0c3322` em `master`, push para `origin`, `git pull --ff-only` no clone Codex;
   os dois clones estão no mesmo commit e as descrições novas já estão em `~/.codex/skills`.
2. **[feito]** 23 descrições reescritas (as 24 acima do limite menos `doc-pendency-resolver`, que já
   cabia). Resultado nas 26 skills: `name` igual à pasta, descrição de no máximo 1024 caracteres (a maior
   ficou com 995), sem `<` nem `>`, e o primeiro gatilho entre aspas dentro dos ~380 caracteres que o
   índice do Codex mostra. Alterada **só a linha `description:`** (23 arquivos, 23 linhas); corpos,
   `name` e fim de linha intactos. Conteúdo removido das descrições conferido contra o corpo de cada
   skill: já existia lá. Neutralização incidental: "Atlassian Rovo", "Claude in Chrome" e "Claude Code
   Remote Control" saíram das descrições (viraram "Jira", "executor web homologado" e "canal
   homologado"); os **corpos ainda citam** Chrome e Remote Control até as Ondas 5/6.
   Script: reescrita idempotente, fora do repo (scratchpad da sessão).
3. **[parcial]** Proxy offline do teste de seleção: aprovado (limites e janela de 380 caracteres).
   O `quick_validate.py` do Codex **não rodou** (falta PyYAML nesta máquina); a mesma checagem foi
   refeita à mão. **[pendente]** Teste real de seleção nos dois executores (o sync do item 1 já foi feito).

### Onda 1 — Contrato e núcleo (Lote A) — **status: texto executado e sincronizado em 2026-10-21 (`7bf58f5`); Codex NÃO habilitado**
Entregue (10 arquivos, só texto; descrições, `name` e fim de linha CRLF intactos):
- `contrato-workflow.md`: **A.10 Executor técnico** (cláusula de executores alternativos; nomes
  contratuais históricos intocáveis; capacidade ausente = bloqueio; homologação por três testes mais
  declaração de Rafinha; canal remoto e executor web homologados; níveis neutros), **B.5 Concorrência,
  claim e handoff** (claim por issue antes da primeira mutação; claim de outro executor para a execução;
  sem expiração, só Rafinha libera; mesmo executor em sessão nova = recovery check; handoff em 4 passos),
  registro mínimo (`Executor`, `Tentativa`, `Escopo fechado`, `Evidências`, `Handoff`) em A.9; A.5 com
  canal remoto homologado.
- `contrato-skills.md`: 5 defaults herdados novos (executor não é autoridade, identidade, claim,
  reconciliar antes de retomar, nível em vez de modelo).
- `workflow-development-flow/SKILL.md`: **§11** em níveis 0–4 (Rotina/Profundo) com tabela 11.6 por
  nível e nova **11.10** (mapeamento por executor; coluna Codex "a definir por Rafinha"; declarações
  antigas Modelo/Effort leem-se pela coluna Claude Code); **§13** com `.claude/` como estrutura
  compartilhada, seções `Executor` e `Handoff` no Execution State e recovery com claim/handoff;
  §14.4, §18, §20, §21 e FAQ.
- `contexto-memoria-workspace.md` e `orquestracao-remota.md`: `AGENTS.md`, `Executor`/handoff em AI
  Memory, canal homologado, claim no despacho.
- `ai-memory-manager`, `engineering-context-manager`, `workflow-incident-capture-executor`,
  `workflow-remote-orchestrator`: `Executor`/handoff nos registros, `Model Policy` em nível 0,
  canal homologado e claim no despacho.

Não tocados por não terem texto acoplado ao executor: `contrato-efetivo.md`, `politicas.md`,
`preparacao-e-hotfix.md`, `release-lifecycle.md`. **Pendente:** as 18 skills das Ondas 2–5 ainda
declaram `Modelo padrão / Effort padrão` (lidas pela regra de transição da §11.9) e não registram
`Executor`/claim; migram nas respectivas ondas. Critério de aceite (Codex reconstrói o estado de
uma issue só pelas fontes) depende do laboratório.

Itens originais da onda:
4. `contrato-workflow.md` e `contrato-skills.md`: cláusulas da seção 2.
5. `workflow-development-flow`: §11 (níveis 0–4, L3), §13 (Execution State como estrutura compartilhada),
   §21 (canal remoto homologado), regras de claim/handoff, `references/`.
6. `ai-memory-manager`, `engineering-context-manager`, `workflow-incident-capture-executor`,
   `workflow-remote-orchestrator`: executor e handoff nos registros; canal remoto homologado.
   Critério: Codex reconstrói o estado de uma issue só com Jira, Git, GitHub, Execution State,
   `context/` e AI Memory, sem assumir fato não comprovado.

### Onda 2 — Jira e preparação (Lote B) — **status: texto executado e sincronizado em 2026-10-21 (`e5d0ce5`); Codex NÃO habilitado**
Entregue (6 SKILL.md, só texto; `description`, `name`, Contrato Efetivo, descrições, tipos, labels e
transições intactos; títulos e frases fixas dos comentários preservados):
- **Nível:** `Model Policy` migrada para nível (criador, intake e decision-resolver = 0; hotfix-creator,
  preparação técnica e validação humana = 1, conforme a tabela 11.6); "Opus" virou "Profundo".
- **`Executor` nos registros:** atestado de Preparação Técnica (linha `Executor:` sob `Resultado`),
  comentário de amadurecimento (intake), comentário de resultado da sessão (decision-resolver, que
  antes não deixava comentário e agora precisa dele para liberar o claim, inclusive em resolução
  parcial), comentário de criação (issue-creator), payload de Hotfix. Na validação humana a linha
  `Executor:` entra **abaixo** das frases fixas, que continuam abrindo o comentário.
- **Claim (B.5):** intake, decision-resolver, preparação técnica e validação humana abrem claim por
  issue antes da primeira mutação. **Sem claim:** `jira-issue-creator` (issue nova, nada concorrente) e
  `jira-hotfix-creator` (não muta o Jira). Na validação humana, a Validação Humana recém-criada no
  GERAR também fica fora do claim.
- **Ferramenta:** "via Atlassian Rovo" virou "conector Atlassian homologado do executor (Rovo no Claude
  Code)"; sem conector homologado a execução bloqueia (A.10). **Não verifiquei** as operações do
  conector Atlassian do Codex (não consta no `config.toml`): o mapeamento operação a operação ainda
  precisa ser feito na homologação. *(Corrigido na Onda 5: o conector existe e o mapeamento observado
  está em `references/executores.md`; falta só testá-lo e homologá-lo.)*
Critério de aceite (issue de laboratório: cria, comenta ou transiciona só dentro da autoridade, com os
gates satisfeitos) **não executado**: depende do projeto de laboratório.

Itens originais da onda:
7. `jira-issue-creator`, `jira-sprint-intake-executor`, `jira-issue-decision-resolver`,
   `jira-hotfix-creator`, `jira-technical-preparation-executor`, `jira-human-validation-executor`:
   campo `Executor` nos comentários, política de modelo por nível, referência de ferramenta.
   **Sem** mexer em Contrato Efetivo, descrições, tipos, labels ou transições.

### Onda 3 — Implementação, integração e auditoria (Lote C, piloto) — **status: texto executado e sincronizado em 2026-10-21 (`05e0eb9`); Codex NÃO habilitado**
Entregue (3 SKILL.md, só texto; `description`, `name`, gates 9/10/11/14/15, modos A/B/C, gramática de
branch `-claude[.N]`, título "Implementação Claude" e frases fixas `claude review aprovado` /
`review reprovada por claude` preservados):
- **`jira-issue-executor`, passo 5.3c (desvio consciente do texto do plano):** o plano dizia
  *substituir* `/code-review` e `/ponytail:ponytail-review` pelo `review-agent`. Como a skill é
  compartilhada e o `review-agent` não existe no Claude Code, substituir quebraria o Claude. O passo
  agora é **parametrizado por executor**, com duas frentes obrigatórias em ambos: Claude Code usa
  `/code-review` (medium) + `/ponytail:ponytail-review`; Codex usa o `review-agent`, **com o critério de
  over-engineering no pedido** (o `review-agent` não o cobre por padrão). P0–P2 corrigidos, P3 e baixa
  confiança viram nota para Rafinha. Mecanismo não homologado = bloqueio com incidente, nunca pular nem
  trocar. O `review-agent` é somente leitura e não substitui `jira-review-executor` nem a Análise -
  Rafinha. O comentário passa a registrar qual mecanismo foi usado.
- **Claim, `Executor`, handoff:** os três executores abrem claim por issue antes da primeira mutação (na
  integração, no Modo B, em cada issue promovida e no Epic do ledger); `Executor:` entra logo abaixo do
  título/frase fixa; recovery check trata executor diferente como handoff; handoff **nunca refaz merge
  registrado** sem checar PR e merge SHA.
- **Gate 15 / Modo B:** a autorização de merge **não passa de um executor para outro** nem entre
  sessões; handoff no meio do Modo B pede nova autorização; o ledger registra quem pediu e quem
  executou. **Modo B por Codex só após homologação declarada por Rafinha** (D3).
- **Nível:** issue-executor = 1, integration-executor = 0, review-executor = 3 (auditoria final;
  "Opus + XHigh" virou Nível 4).
- **Ferramenta:** conector Atlassian e `gh` "homologados do executor"; ausente = bloqueio.
**Não verificado:** o `review-agent` não foi invocado de verdade com o critério de over-engineering;
`gh` e o conector Atlassian no Codex não foram checados. O plugin `code-review@openai-bundled` do Codex
não foi avaliado como alternativa. Critério de aceite (issue artificial percorre implementação, revisão
humana e integração com os mesmos gates e autorizações) **não executado**: depende do laboratório.

Itens originais da onda:
8. `jira-issue-executor`: trocar `/code-review` e `/ponytail:ponytail-review` (passo 5.3c) por
   `review-agent` (L6), com o critério de over-engineering embutido; manter branch `-claude[.N]`,
   tentativas, PR, checks, ledger, recovery.
9. `jira-integration-executor` e `jira-review-executor`: preservar Modos A, B, C e Gates 9, 10, 11,
   14, 15 (incl. autorização distinta no Modo B); registrar `Executor`.
   Critério: issue artificial percorre implementação → revisão humana → integração com os mesmos
   gates, evidências e autorizações do Claude.

### Onda 4 — Documentação (Lote D) — **status: texto executado e sincronizado em 2026-10-21 (`2f10538`); Codex NÃO habilitado**
Entregue (7 SKILL.md, só texto; `description`, `name`, templates em `references/`, trilhas e regras de
pendência intactos):
- **Nível:** as 6 skills do lote em **Nível 0** (tabela 11.6: Documentação = 0); "Opus" virou "Profundo".
- **Conector:** "Atlassian Rovo" virou "conector Atlassian (Confluence) homologado do executor (Rovo no
  Claude Code)"; os nomes `getConfluencePage` / `createConfluencePage` / `updateConfluencePage` ficaram
  como nomes do Rovo, com "a operação equivalente do conector" para o Codex. Sem conector homologado, a
  publicação bloqueia (A.10). **Não verifiquei** as operações do conector Confluence do Codex. *(Corrigido na Onda 5: observadas
  `getConfluenceContent`, `createConfluenceContent`, `updateConfluenceContent` e as variantes legacy,
  em `references/executores.md`; nunca chamadas.)*
- **Página sem identidade do executor:** os 5 writers declaram que a página (e `docs/`, no
  `tech-doc-writer`) descreve só o estado atual, sem executor, tentativa ou histórico; o `Executor` fica
  no comentário Jira de quem delega, e o claim é dessa skill. Writers não abrem claim próprio.
- **`jira-doc-executor`:** claim por issue, `Documentação Claude` (título fixo) com `Executor:` abaixo,
  recovery check com executor/handoff, e regra nova **"writer que o executor não consegue exercer"**: o
  item do plano não é dispensado nem trocado, vira bloqueio documental e a issue não se move.
- **`jira-issue-executor` (passo 6):** a mesma regra de bloqueio para issues de Documentação (acrescentada
  aqui por consequência, fora do Lote C original).
- **`screen-doc-writer`:** pré-requisito 3 reescrito como tabela por executor. Claude Code = Claude in
  Chrome (homologado, inalterado). **Codex = nenhum executor web homologado, a skill bloqueia**
  (candidatos: Browser, Computer Use ou extensão do Chrome do Codex). Homologar exige verificar de ponta a
  ponta **navegar, capturar, anexar na página e incorporar o print**, e só Rafinha declara. O utilitário
  `anexar-print.sh` ficou executor-neutro (caminho `~/.claude/skills/` ou `~/.codex/skills/`) com a
  regra de nunca expor `JIRA_API_TOKEN`.
**Não alterado:** `doc-pendency-resolver` (fora do Lote D, sem `Model Policy` nem ferramenta acoplada).
**Não verificado:** a anexação por REST no ambiente do Codex (variáveis `JIRA_API_*` no shell, `curl`),
e se o conector Confluence do Codex anexa arquivo. Critério de aceite (Codex publica uma página com fonte
correta e, quando aplicável, evidência visual verificável) **não executado**.

Itens originais da onda:
10. `product-doc-writer`, `tech-doc-writer`, `user-doc-writer`, `workflow-doc-writer`,
    `jira-doc-executor`: conector Confluence do Codex, política de modelo por nível, menções a Rovo.
11. `screen-doc-writer`: **bloqueado para Codex** até D4 (executor visual). Documentação
    observacional não roda no Codex antes disso.

### Onda 5 — Homologação de QA, Release e remoto (Lotes E e F) — **status: texto e verificações de host executados e sincronizados em 2026-10-21 (`3b79d1c`); Codex NÃO habilitado**
Entregue (3 SKILL.md, 1 referência nova, 1 script novo; `description`, `name`, frases fixas do QA, G10,
labels `qa-develop-aprovado` / `integrado-epico`, classificação Aprovado/Reprovado/Inconclusivo e a
proibição de atestar QA por leitura de código preservados):
- **`workflow-development-flow/references/executores.md` (novo):** matriz de capacidades por executor e
  **registro da homologação declarada** (Claude Code = tudo; Codex = nada). É onde o mapeamento
  Rovo ↔ conector do Codex passa a morar; as skills apontam para ela. Referenciada em A.10 e na §18.
- **Verificações somente leitura do host (resultado):**
  - **Corrige o que eu disse nas Ondas 2–4:** o Codex **tem** conector Atlassian (`atlassian_*`: ler/criar/
    editar issue, comentar, transicionar, ler/criar/atualizar Confluence; mais variantes `rovo__legacy__*`
    com **os mesmos nomes do Rovo**) e GitHub (`create_pull_request`, `merge_pull_request`, artefatos de
    Actions…). Fonte: cache de plugins e inventário das sessões do Codex. **Observado, nunca chamado.**
    Não vi ferramenta de **anexo** em nenhum dos dois conectores (como no Rovo): segue REST.
  - Host: `gh`, `docker`, `adb`, `maestro` (CLI), `java`, `flutter`, `git`, `python`, `node` no PATH;
    `emulator` e `ANDROID_HOME` **fora** do PATH/ambiente (mesmo caso que a skill já trata).
  - `AIO_TESTS_ACCESS_TOKEN` está no ambiente do usuário do Windows (só presença checada).
    `JIRA_API_EMAIL`/`JIRA_API_TOKEN` **não** estão no ambiente do Windows, só referenciadas no
    `~/.bashrc`: o Codex pode não enxergá-las (`anexar-print.sh` bloqueia com mensagem clara).
  - Maestro **MCP não está configurado** no Codex (`config.toml` só tem `node_repl`): no Codex, CLI.
  - **Drive: nada observado** no Codex.
- **`jira-qa-executor`:** **QA Web bloqueado no Codex** (sem fallback para outro navegador, Maestro ou
  leitura de código; resultado = bloqueio/Inconclusivo por infraestrutura, nunca Aprovado); Android por
  Maestro CLI, dependente de homologação; claim, `Executor:` abaixo da frase fixa, handoff que não
  reaproveita Run de outro executor sem checar; Nível 1; tabela de ativação por plataforma × executor;
  critério de homologação = os **três resultados** (Aprovado, Reprovado, Inconclusivo) com evidência, AIO e
  labels corretos.
- **`jira-qa-executor/scripts/aio.sh` (novo):** wrapper das chamadas ao AIO Tests. O token vai por arquivo
  temporário do `curl -K`, fora da linha de comando, da saída e dos logs. **Testado contra um servidor local
  descartável** (GET, POST JSON, `@arquivo`, multipart, 401, 500, token ausente, rede fora): header
  injetado corretamente, **zero ocorrências do token** na saída e na linha de comando do `curl`. **Não foi
  chamado contra o AIO real.**
- **`jira-release-executor`:** Release por Codex só após homologação (D3); concorrência do ciclo por
  evidência primária (Release Request em andamento, run de Action ativo), já que o claim por issue não se
  aplica; `Executor` no corpo do commit de bump e no resumo, **sem mudar** o schema do Release Request nem
  o `release-manifest.yml`; checagem de claim de outro executor antes de editar Fix Versions; **Drive
  ausente no Codex bloqueia o G9 (7.3)**; Nível 1.
- **`workflow-remote-orchestrator`:** pré-condição nova: canal e executor da sessão homologados; skill
  despachada roda no executor da sessão e, se bloqueada por capacidade, o bloqueio é comunicado sem trocar
  de executor, skill ou etapa; critérios de homologação do Codex Remote Control.
**Decisões minhas a confirmar:** (1) `Executor` da release vai no commit de bump e no resumo porque a release
não deixa comentário Jira próprio; (2) `aio.sh` passou a ser o único caminho para o AIO Tests (as chamadas
inline a `curl` deixam de ser o procedimento).
**Não executado:** critério de aceite (QA real em ambiente de teste com os três resultados, registro AIO e
transições corretos) e a homologação de qualquer capacidade: dependem do laboratório e de você.

Itens originais da onda:
12. D4 e D5: executar os três resultados de QA no laboratório; AIO Tests encapsulado.
13. `jira-qa-executor`: Web só após homologação; Maestro mantido com validação de emulador;
    preservar `qa-develop-aprovado`, `integrado-epico` e a proibição de atestar QA por leitura de código.
14. `jira-release-executor` e `workflow-remote-orchestrator`: mapear GitHub Actions, Docker,
    artefatos, Confluence e Drive para o que o host Codex realmente tem; integração ausente =
    bloqueio; Codex Remote Control só após validação em host dedicado.

### Onda 6 — README e Confluence — **status: README feito; Confluence: núcleo (itens 1–6) e índices + página Executores (itens 7–8) PUBLICADOS em 2026-10-21; só as 22 fichas (item 9) pendentes, depois do laboratório**
- **README (repo, feito):** nova seção de evolução "6. Codex como executor alternativo (outubro de 2026)"
  com o estado real (**texto adaptado, Codex não habilitado, nada testado em operação**); linha "Escolha do
  executor e homologação" em *Quem faz o quê*; A.10 e B.5 no resumo dos contratos; tabela do ecossistema
  (Codex opcional/em adoção, Jira com conector observado e não testado, executor web e canal remoto
  "homologado"); fonte única das skills (`~/.claude/skills` editável, `~/.codex/skills` só leitura) e o limite
  de descrição do Codex; limite novo em *Estado atual e limites*; `executores.md` e `plano-pacote-8.md` nas
  referências; linha do orquestrador no catálogo. Contagem (26/24/2) e links conferidos.
- **Confluence (CS1) — núcleo PUBLICADO (itens 1–6, autorizado por Rafinha):** Contrato do Workflow (v5),
  Contrato das skills (v3), Model Escalation Policy (v3), Execution State (v3), Orquestração remota (v3) e
  2. Sincronizar as skills (v6). **Também publicados (itens 7–8):** página nova Executores (86769665), home
  (v11), Skills (v9) e Workflow (v9). **Pendente:** as 22 fichas (item 9, depois dos testes de laboratório). Detalhes, verificação e divergências pré-existentes
  não resolvidas em [`plano-pacote-8-confluence.md`](plano-pacote-8-confluence.md).
- *(histórico da preparação)* li as páginas Contrato do Workflow e Contrato das skills e mapeei o
  espaço (~30 páginas afetadas: contratos, Model Escalation Policy, Execution State, Orquestração remota,
  Sincronizar as skills, home e índices, e 22 fichas de skill). O rascunho com o texto proposto, as páginas,
  os IDs, a ordem e os riscos está em [`plano-pacote-8-confluence.md`](plano-pacote-8-confluence.md).
  Publicar é alteração externa, em página de autoridade normativa, e depende de autorização explícita de
  Rafinha (escopo: núcleo agora, fichas depois dos testes de laboratório).

Itens originais da onda:
15. `README.md`: Codex como executor alternativo, regra D3 (o que está habilitado), L1.
16. Confluence CS1 (via `workflow-doc-writer`): Contrato do Workflow, Contrato das skills,
    `workflow-development-flow` (ficha), política de modelo, índices. Substituir o conflitante,
    sem convivência com o texto antigo (mesma vigência do Pacote 6).
17. Fechar este arquivo (status por onda). **Sem commit** — só se Rafinha pedir.

Lote G (`task-creator-trabalho`, `weekly-organizer`): fora deste pacote.

---

## 4. Validação (por onda habilitada)

1. **Seleção:** o pedido correto aciona a skill correta, no Claude e no Codex (a descrição é lida truncada).
2. **Execução permitida:** a skill realiza a operação com evidência válida.
3. **Negativa/gate:** a skill para diante de escopo, autorização, design, evidência, claim de outro
   executor ou ambiente insuficientes.

Começar no projeto de laboratório. Nenhuma skill assume produção só porque a ferramenta parece compatível.

## 5. Definição de pronto

- Claude inicia uma issue e Codex a retoma sem duplicar mutações (claim + recovery check).
- Codex respeita todos os gates e autoridades do contrato atual.
- Jira identifica o executor de cada ação relevante, sem alterar títulos de comentário.
- QA Codex só aprova após execução real e evidência válida.
- Codex revisa código do Claude via `review-agent` sem alterar o workflow.
- Operação remota preserva as aprovações humanas existentes (Hotfix e Modo B intocados).
- Descrições ≤ 1024 caracteres, sem `<` `>`, e seleção testada nos dois executores.
- Uma única fonte das skills; nenhuma regra contratual simplificada para acomodar ferramenta.
