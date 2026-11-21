# Cenários controlados — convenção de `AGENTS.md`

> Estes cenários verificam a convenção do workflow e o esquema local; não
> homologam Claude Code, Codex, conectores nem etapas reais do Jira.

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
| AGENTS principal | Fixture com as seis seções e campos estáveis v1 | arquivo é aceito somente na ordem prevista, com nome, topologia e site Atlassian explícitos |
| Site não declarado | Fixture com URL Atlassian ausente/inválida | validação falha; a skill bloqueia a operação dependente, sem escolher site alternativo |
| Múltiplos recursos | Fixture declarando dois projetos Jira e dois espaços Confluence | a resolução exige recurso explícito dentro do mesmo site, nunca a primeira opção disponível |
| Conector errado | Simulação de conector que responde por outro site | tratado como capacidade insuficiente; não há fallback nem mutação |
| Escrita negada | Simulação de acesso somente leitura | leitura pode prosseguir quando suficiente; mutação fica bloqueada |
| Evento contextual | Mudança técnica/documental com e sem impacto em AGENTS | a manager atualiza somente o AGENTS determinístico afetado ou devolve “nenhuma alteração necessária” |
| Ciclo writer → manager | Documento técnico atualiza AGENTS | não cria nova publicação Confluence nem reinvoca o writer |

## Execução reproduzível

O verificador cobre descoberta hierárquica e ausência opcional em diretório
temporário sob `tests/`, removido ao fim:

```powershell
python workflow-development-flow/scripts/validate_agents_convention.py
python workflow-development-flow/scripts/validate_atlassian_resolution.py
```

Os cenários de semântica, Claude Code, delegação e revisão exigem uma sessão
limpa e são registrados como **observados** somente quando a execução real
mostrar a evidência. Ausência dessa evidência não permite declarar
compatibilidade ou homologação.
