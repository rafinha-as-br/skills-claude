# Cenários controlados — convenção de `AGENTS.md`

> Estes cenários verificam a convenção do workflow; não homologam Claude Code,
> Codex, conectores nem etapas reais do Jira.

| Cenário | Fixture controlada | Evidência esperada |
|---|---|---|
| Mono-repo | `AGENTS.md` raiz e outro em `src/auth/`; alvo em `src/auth/token.py` | os dois arquivos são localizados em ordem raiz → módulo |
| Multi-repo | Workspace com `repo-a/AGENTS.md` e `repo-a/lib/auth/AGENTS.md` | Workspace, repositório e módulo são retornados para o caminho de `repo-a` |
| Ausência | Diretório sem arquivo próprio | não há bloqueio; só a cadeia existente é retornada |
| Conflito entre níveis | Workspace e módulo impõem instruções materiais incompatíveis | não há “módulo vence”; a ação afetada para e o conflito é reportado |
| Conflito de autoridade | `AGENTS.md` tenta mudar escopo, gate ou transição | contrato/fonte oficial prevalece; instrução não é seguida |
| Claude Code | `CLAUDE.md` com `@AGENTS.md` num clone temporário | import é a alternativa explícita; a versão/configuração efetiva deve ser registrada antes de alegar suporte nativo |
| Delegação | Subagente recebe escopo, caminhos, lista de AGENTS e referências | a tarefa não amplia escopo e devolve lacuna/conflito ao principal |
| Revisão | Diff sintético contra uma regra local aplicável | resultado é classificado como violação, recomendação, conflito, ausência ou fora de escopo, sem correção automática |

## Execução reproduzível

O verificador cobre descoberta hierárquica e ausência opcional em diretório
temporário sob `tests/`, removido ao fim:

```powershell
python workflow-development-flow/scripts/validate_agents_convention.py
```

Os cenários de semântica, Claude Code, delegação e revisão exigem uma sessão
limpa e são registrados como **observados** somente quando a execução real
mostrar a evidência. Ausência dessa evidência não permite declarar
compatibilidade ou homologação.
