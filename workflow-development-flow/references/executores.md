# Executores — capacidades, mapeamento e homologação

> **Fonte única** do que cada executor técnico tem e de quais capacidades Rafinha
> **homologou** (Contrato do Workflow, A.10). As skills apontam para este arquivo em vez
> de repetir tabelas de ferramenta. Estado em **2026-10-21**.

## Como ler

- **Homologada** = só vale com **declaração de Rafinha**, depois dos três testes
  (seleção, execução permitida, negativa/gate) em projeto de laboratório. Sem declaração,
  a capacidade **não** é do executor (A.10), mesmo que a ferramenta exista.
- **Observado** = visto no host ou no inventário de ferramentas de uma sessão do
  Codex (`~/.codex/sessions`, 2026-10-20). **Não** é "testado em operação".
- Credenciais: esta página registra apenas **presença** de variáveis de ambiente, nunca
  valores.

## Homologação declarada

| Executor | Capacidades homologadas |
|---|---|
| Claude Code | todas as que o workflow usa hoje |
| Codex | **nenhuma** (Pacote 8, D3: o Codex começa em etapas selecionadas e só depois dos testes de laboratório) |

Quando Rafinha homologar uma capacidade para o Codex, ele (ou a skill, a pedido) atualiza
esta tabela e a coluna "Situação no Codex" abaixo.

## Matriz de capacidades

| Capacidade | Claude Code | Codex | Situação no Codex |
|---|---|---|---|
| **Jira e Confluence** | Atlassian Rovo (`getJiraIssue`, `searchJiraIssuesUsingJql`, `editJiraIssue`, `createJiraIssue`, `addCommentToJiraIssue`, `transitionJiraIssue`, `getConfluencePage`, `createConfluencePage`, `updateConfluencePage`, …) | Conector Atlassian: `atlassian_getJiraIssue`, `…searchJiraIssuesUsingJql`, `…editJiraIssue`, `…createJiraIssue`, `…addOrEditJiraIssueComment`, `…transitionJiraIssue`, `…getConfluenceContent`, `…createConfluenceContent`, `…updateConfluenceContent`, `…searchConfluence`; mais as variantes `rovo__legacy__…` com **os mesmos nomes do Rovo** (ex.: `…_getConfluencePage`, `…_addCommentToJiraIssue`, `…_getTransitionsForJiraIssue`) | Observado; não homologado |
| **Anexo de arquivo** (Jira/Confluence) | Sem ferramenta no Rovo: REST via `screen-doc-writer/scripts/anexar-print.sh` | Sem ferramenta observada: o mesmo script | Não verificado no Codex |
| **GitHub** | `gh` (CLI) | `gh` (no host) e conector GitHub: `create_pull_request`, `merge_pull_request`, `compare_commits`, `create_branch`, `fetch_workflow_run_jobs`, `fetch_workflow_run_artifacts`, `fetch_workflow_job_logs`, `get_commit_combined_status`. **Não observado:** disparo de workflow (usar `gh workflow run`) | Observado; não homologado |
| **Git** | `git` | `git` (host) | Observado |
| **Revisão automatizada** | `/code-review` (medium) + `/ponytail:ponytail-review` | skill `review-agent` (somente leitura, P0–P3) com o critério de over-engineering **no pedido**; plugin `code-review@openai-bundled` habilitado no `config.toml` | `review-agent` observado; não homologado |
| **Executor web** (QA Web, `screen-doc-writer`) | Claude in Chrome | Candidatos presentes no cache de plugins (ativação não verificada): `browser`, `chrome`, `computer-use`, `unified-computer-use` | **Nenhum homologado — bloqueia** |
| **Android (QA)** | Maestro (MCP preferencial, CLI) | Maestro **CLI** no host; o MCP **não** está configurado no Codex (`config.toml` só tem `node_repl`) | CLI observado; não homologado |
| **AIO Tests** | REST + `AIO_TESTS_ACCESS_TOKEN`, via `jira-qa-executor/scripts/aio.sh` | O mesmo | Variável presente no ambiente do usuário do Windows; chamada não testada |
| **Docker** | `docker` | `docker` (host) | Observado |
| **Release** (Orchestrator, Actions) | `orchestrate.ps1`, `gh workflow run` | PowerShell (Windows) e `gh` no host; `pwsh` não verificado | Observado; **não homologado** |
| **Drive** (ZIP da release) | conforme o projeto | **Não observado** | Ausente: bloqueia o G9 (7.3) no Codex |
| **Canal remoto** | Claude Code Remote Control | Codex Remote Control: **não configurado nem validado** | Ausente: bloqueia |
| **Nível de modelo** | tabela 11.10 do `workflow-development-flow` | tabela 11.10 (coluna Codex "a definir") | A definir por Rafinha |

## Ambiente do host (verificado em 2026-10-21, só leitura)

- No PATH: `gh`, `docker`, `adb`, `maestro`, `java`, `flutter`, `git`, `python`, `node`.
- **Fora do PATH:** `emulator` e `ANDROID_HOME`/`ANDROID_SDK_ROOT` — o mesmo caso que a
  `jira-qa-executor` já trata para o Claude Code (SDK fora do PATH).
- `AIO_TESTS_ACCESS_TOKEN`: definida no ambiente do usuário do Windows (visível a
  qualquer processo do usuário, inclusive o Codex).
- `JIRA_API_EMAIL` e `JIRA_API_TOKEN`: **não** estão no ambiente do Windows; estão
  referenciadas no `~/.bashrc` do Git Bash. Um shell não interativo, ou o Codex em
  PowerShell, pode **não** enxergá-las — o `anexar-print.sh` bloqueia com mensagem clara
  se faltarem. **Não verificado** se o Codex as enxerga.
- `MAESTRO_CLOUD_API_KEY`, `GH_TOKEN`, `GITHUB_TOKEN`: ausentes (o `gh` usa a própria sessão).
