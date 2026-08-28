# skills-claude

Coleção pessoal de [skills](https://docs.claude.com/en/docs/claude-code/skills) do Claude Code que automatizam o fluxo de desenvolvimento de Rafinha: da criação da issue no Jira até o merge, QA, documentação e release — com Claude executando cada etapa do pipeline sozinho, sempre parando para decisão humana nos pontos que importam.

## O pipeline Rafinha-Claude

Cada coluna do Jira tem uma skill dona. Issues de código são implementadas de verdade (branch, commit, PR); issues de documentação são delegadas para quem escreve Confluence.

```mermaid
flowchart LR
    A["Fazer - Claude"] --> B["Análise - Rafinha"]
    B --> C["Integração"]
    C --> D["QA - Claude"]
    D --> E["Documentar"]
    E --> F["Análise final - Rafinha"]
    F --> G["Análise final - Claude"]
    G --> H["Concluído"]
```

`workflow-development-flow` é a skill mãe: não executa nada, apenas responde "em qual etapa uma issue está" ou "o que vem depois de X" para as demais. Release & Versionamento (SemVer, tags, GitHub Release) é um ciclo separado, acionado sob demanda — nunca uma coluna do board.

**Validação Humana Agregada.** A unidade de implementação é a Issue, mas a unidade de aceitação humana pode agregar várias: antes da `Análise final - Rafinha`, a `jira-human-validation-executor` varre a coluna, agrupa as issues por comportamento funcional e cria *Validações Manuais* contendo só os cenários que ainda exigem julgamento humano — nada do que o QA já automatizou volta como passo. Não é uma coluna nova nem um status novo, e não substitui QA, code review ou auditoria.

## Skills

### Pipeline Jira

| Skill | O que faz |
|---|---|
| [`workflow-development-flow`](workflow-development-flow/SKILL.md) | Referência do fluxo: hierarquia Épico/Issue/Subtask, as 8 etapas, gates de passagem, ciclo de release. |
| [`jira-issue-creator`](jira-issue-creator/SKILL.md) | Cria issues/subtasks no Jira a partir de um pedido ou de uma GitHub Issue apontada. |
| [`jira-issue-executor`](jira-issue-executor/SKILL.md) | Implementa as issues de "Fazer - Claude": código + testes + review automatizado + PR. |
| [`jira-integration-executor`](jira-integration-executor/SKILL.md) | Faz o merge real para `develop`, validando GitHub Actions e conflitos antes. |
| [`jira-qa-executor`](jira-qa-executor/SKILL.md) | QA funcional/visual — Chrome real para Web, Maestro para Android — com evidências no AIO Tests. |
| [`jira-doc-executor`](jira-doc-executor/SKILL.md) | Identifica qual documentação foi impactada e delega para a skill de escrita certa. |
| [`jira-human-validation-executor`](jira-human-validation-executor/SKILL.md) | Agrupa as issues por comportamento e gera as Validações Manuais — só os cenários que exigem julgamento humano. Registra o veredito e roteia reprovações. |
| [`jira-review-executor`](jira-review-executor/SKILL.md) | Auditoria final antes de "Concluído". |
| [`jira-release-executor`](jira-release-executor/SKILL.md) | Prepara e publica releases (SemVer, changelog, tag, GitHub Release). |

### Documentação (Confluence)

| Skill | O que faz |
|---|---|
| [`business-rule-writer`](business-rule-writer/SKILL.md) | Páginas de regra de negócio, estrutura fixa. |
| [`module-doc-writer`](module-doc-writer/SKILL.md) | Documentação técnica/arquitetural de um módulo. |
| [`screen-doc-writer`](screen-doc-writer/SKILL.md) | Documentação de tela/UI, com prints reais via navegação ao vivo. |
| [`doc-pendency-resolver`](doc-pendency-resolver/SKILL.md) | Resolve pendências e ambiguidades perguntando antes de escrever, nunca assumindo. |

### Qualidade & produtividade

| Skill | O que faz |
|---|---|
| [`flutter-development-standards`](flutter-development-standards/SKILL.md) | Checklist de arquitetura/boas práticas Flutter, aplicado ao revisar ou escrever código. |
| [`weekly-organizer`](weekly-organizer/SKILL.md) | Organiza a semana e o inbox do Todoist. |
| [`task-creator-trabalho`](task-creator-trabalho/SKILL.md) | Registra tarefas e contexto de trabalhos acadêmicos. |

## Como usar

São skills do Claude Code — cada pasta é uma skill com seu `SKILL.md`. Clone para `~/.claude/skills/` (globais) ou `.claude/skills/` de um projeto, e o Claude passa a reconhecê-las automaticamente pelo gatilho descrito em cada `description`.

A maior parte pressupõe o ecossistema real de Rafinha (Jira via Atlassian Rovo, Confluence, GitHub, AIO Tests, Maestro) — usar como referência de arquitetura de skills ou adaptar os nomes de projeto/board antes de reaproveitar em outro contexto.
