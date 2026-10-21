# Plano de implementação — Pacote 8: Codex como executor alternativo

Registro de implementação, no formato dos `plano-pacote-N.md` anteriores.
**Status: PLANO APROVADO — Onda 0 executada (sem commit); Ondas 1–6 pendentes.**

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
- **Conectores Atlassian/GitHub/Confluence no Codex:** não aparecem no `config.toml`; confirmar se estão ativos. Ausência = bloqueio do gate correspondente (regra do plano original).

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

### Onda 0 — Infraestrutura (L1, L2) — **status: executada em 2026-10-21, falta sync e teste real**
1. **[feito]** Fonte única = `~/.claude/skills`. No clone Codex, `.system/` entrou em
   `.git/info/exclude` (config local, não versionada). O clone Codex continua sendo só leitura.
   **[pendente]** o clone Codex só recebe as descrições novas depois de commit + push aqui e `pull`
   lá; nada disso foi feito (sem commit, conforme combinado).
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
   refeita à mão. **[pendente]** Teste real de seleção nos dois executores, que exige o sync do item 1.

### Onda 1 — Contrato e núcleo (Lote A)
4. `contrato-workflow.md` e `contrato-skills.md`: cláusulas da seção 2.
5. `workflow-development-flow`: §11 (níveis 0–4, L3), §13 (Execution State como estrutura compartilhada),
   §21 (canal remoto homologado), regras de claim/handoff, `references/`.
6. `ai-memory-manager`, `engineering-context-manager`, `workflow-incident-capture-executor`,
   `workflow-remote-orchestrator`: executor e handoff nos registros; canal remoto homologado.
   Critério: Codex reconstrói o estado de uma issue só com Jira, Git, GitHub, Execution State,
   `context/` e AI Memory, sem assumir fato não comprovado.

### Onda 2 — Jira e preparação (Lote B)
7. `jira-issue-creator`, `jira-sprint-intake-executor`, `jira-issue-decision-resolver`,
   `jira-hotfix-creator`, `jira-technical-preparation-executor`, `jira-human-validation-executor`:
   campo `Executor` nos comentários, política de modelo por nível, referência de ferramenta.
   **Sem** mexer em Contrato Efetivo, descrições, tipos, labels ou transições.

### Onda 3 — Implementação, integração e auditoria (Lote C, piloto)
8. `jira-issue-executor`: trocar `/code-review` e `/ponytail:ponytail-review` (passo 5.3c) por
   `review-agent` (L6), com o critério de over-engineering embutido; manter branch `-claude[.N]`,
   tentativas, PR, checks, ledger, recovery.
9. `jira-integration-executor` e `jira-review-executor`: preservar Modos A, B, C e Gates 9, 10, 11,
   14, 15 (incl. autorização distinta no Modo B); registrar `Executor`.
   Critério: issue artificial percorre implementação → revisão humana → integração com os mesmos
   gates, evidências e autorizações do Claude.

### Onda 4 — Documentação (Lote D)
10. `product-doc-writer`, `tech-doc-writer`, `user-doc-writer`, `workflow-doc-writer`,
    `jira-doc-executor`: conector Confluence do Codex, política de modelo por nível, menções a Rovo.
11. `screen-doc-writer`: **bloqueado para Codex** até D4 (executor visual). Documentação
    observacional não roda no Codex antes disso.

### Onda 5 — Homologação de QA, Release e remoto (Lotes E e F)
12. D4 e D5: executar os três resultados de QA no laboratório; AIO Tests encapsulado.
13. `jira-qa-executor`: Web só após homologação; Maestro mantido com validação de emulador;
    preservar `qa-develop-aprovado`, `integrado-epico` e a proibição de atestar QA por leitura de código.
14. `jira-release-executor` e `workflow-remote-orchestrator`: mapear GitHub Actions, Docker,
    artefatos, Confluence e Drive para o que o host Codex realmente tem; integração ausente =
    bloqueio; Codex Remote Control só após validação em host dedicado.

### Onda 6 — README e Confluence
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
