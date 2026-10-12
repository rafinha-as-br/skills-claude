# Contexto de engenharia, AI Memory e Workspace multi-repo

> Referência normativa das três camadas introduzidas pela Revisão do workflow 2.
> Espelho: páginas **Contextualização de engenharia (`context/`)**, **AI Memory**
> e **Workspace multi-repo** no Confluence (CS1). Skills: `engineering-context-manager`,
> `ai-memory-manager`; composição Git: `jira-integration-executor`.

## 1. Responsabilidades separadas

```text
context/       → conhecimento técnico atual e durável    ("como o sistema funciona e por quê?")
ai-memory/     → continuidade operacional, handoff, histórico de atuação da IA
                                                          ("o que aconteceu e o que o próximo agente precisa saber?")
Execution State→ ponto de retomada de UMA execução (SKILL.md §13); NÃO é AI Memory
Git            → histórico das alterações
Jira           → estado e histórico operacional das issues
Confluence     → documentação normativa (workflow, produto, negócio)
Código         → implementação técnica atual
```

`context/` e AI Memory nunca substituem a verificação da fonte autoritativa
quando uma operação crítica depende do fato. Execution State e AI Memory têm
finalidades diferentes e **não se fundem**.

## 2. `context/` — camada de contexto de engenharia

**Objetivo:** reduzir redescoberta técnica e preservar conhecimento cujo motivo,
restrição ou relação não é barato de obter só pelo código. *Se pode ser
descoberto rápido e com confiança só pelo código, em regra não vai para
`context/`.* Foco: realidade técnica atual + conhecimento de alto custo de
redescoberta. Não duplica regra de negócio/workflow do Confluence, Jira, Git nem
código.

**Princípios:** não duplicar o que o código mostra; priorizar o *porquê* (o código
já expressa o *como*); preservar decisões técnicas/humanas não inferíveis;
registrar decisões arquiteturais não óbvias; registrar restrições, invariantes e
armadilhas; servir de mapa de navegação; evitar documentação exaustiva de
classes/métodos/relações triviais; Markdown é a fonte técnica e Obsidian é só
interface opcional.

**Estrutura oficial (mínima e evolutiva — nunca criar arquivo/diretório vazio):**

```text
context/
├── README.md          ponto de entrada, índice e mapa (não duplica as notas)
├── architecture.md    arquitetura transversal atual e aspectos não óbvios
├── modules/           módulos cujo entendimento tem custo de redescoberta
├── integrations/      comportamento, rationale e restrições de integrações não óbvias
├── decisions/         decisões de engenharia duráveis (preservar o porquê)
└── constraints.md     invariantes, restrições transversais, limitações, armadilhas
```

Organização por **conceito técnico estável** — nunca por issue, sprint, agente,
sessão, data ou tentativa. Estrutura rasa. Não há diretório de histórico dentro
de `context/`: histórico de mudança = Git; histórico operacional = AI Memory.

**Formato da nota** — cabeçalho YAML padronizado + corpo especializado por tipo:

```yaml
---
type: module            # module | integration | decision | constraints | architecture
scope: authentication
status: active          # active | review-needed
last-reviewed: 2026-10-12
related-context:
  - ../integrations/keycloak.md
code-refs:
  - src/auth/
---
```

Campos: `type`, `scope`, `status`, `last-reviewed`, `related-context`,
`code-refs`. Estados: só `active` e `review-needed`. Não adicionar metadado que
duplique o Git. Corpo: *module* (responsabilidade, fronteiras, relações, pontos
não óbvios); *integration* (sistemas, fluxo, restrições, decisões); *decision*
(contexto, decisão, rationale, consequências); *constraints* (invariantes,
motivo, impacto, riscos).

**Ciclo de vida** — `context/` é a realidade técnica *atual*, não arquivo de
versões:

```text
continua válido        → manter
mudança parcial        → atualizar a mesma nota
mudança estrutural     → dividir, consolidar ou reorganizar
conceito deixou de existir → remover a nota (histórico fica no Git)
validade incerta       → status review-needed
```

**Branch awareness.** `context/` não é só o estado integrado em `develop`:

```text
develop        → realidade técnica oficialmente integrada
epic/<EPIC>    → realidade compartilhada do épico (inclui evolução relevante em andamento)
issue isolada  → realidade técnica isolada daquele trabalho
```

Evolução em andamento só entra no contexto compartilhado quando altera de forma
relevante como outros trabalhos entendem/alteram o sistema e o estado é claro. Após
integração, o contexto é normalizado. Descoberta não vira contexto compartilhado
só por existir: precisa de valor durável.

**`CLAUDE.md`** permanece pequeno, estável, bootstrap/router: ponto de entrada
para `context/README.md`, referências a contratos/skills, topologia mínima,
entrypoints. Não é banco de contexto, documentação arquitetural extensa, histórico
de decisões, AI Memory nem duplicação de `context/`.

**Consumo:** *invocação descentralizada, governança de mutação centralizada.*

```text
leitura simples e determinística      → acesso direto (qualquer skill)
localizar / interpretar / avaliar     → pode chamar a engineering-context-manager
criar / alterar / reorganizar / remover → governado pela engineering-context-manager
```

Sem whitelist de callers. Persistência durante a implementação: a skill decide o
nível (develop, branch compartilhada do Epic, issue isolada, Workspace).

**Git do `context/` (D5).** A `engineering-context-manager` altera apenas a
working tree. Quem tem autoridade Git sobre a operação em curso (`jira-issue-executor`
na implementação; `jira-integration-executor` na integração/composição) inclui as
mudanças no próprio commit. Chamadora sem autoridade Git (preparação técnica, QA,
review): a skill deixa a mudança sem commit e reporta.

## 3. AI Memory (`ai-memory/`)

Camada de **continuidade operacional e handoff**, não fonte de verdade do
produto. Existe em mono-repo (no repositório) e multi-repo (no Workspace).

```text
ai-memory/
├── active/
│   ├── <EPIC-KEY>/
│   │   ├── epic.md
│   │   ├── <ISSUE-KEY>.md
│   │   └── ...
│   └── isolated/
│       └── <ISSUE-KEY>.md
└── history/
    ├── <EPIC-KEY>/ (epic.md, <ISSUE-KEY>.md ...)
    └── isolated/<ISSUE-KEY>.md
```

- Issue de Epic fica na pasta do Epic; sem Epic → `isolated/`. Hotfix segue a
  mesma regra (vinculada a Epic → unidade do Epic; isolada → `isolated/`).
- **Criação sob demanda:** nada é materializado vazio. Issue criada → nenhum arquivo
  obrigatório; surge descoberta/dependência/tentativa/handoff → cria
  `<ISSUE-KEY>.md`. Vale para `epic.md`.
- Nome do arquivo = chave Jira exata (`GEO-123.md`).
- **Seções mínimas:** Contexto · Descobertas · Dependências e impactos · Decisões
  e direcionamentos · Handoff. A skill pode omitir seção sem conteúdo relevante.
- **Registrar quando útil:** contexto para o próximo agente, descobertas,
  dependências, impactos entre issues, direcionamentos técnicos, tentativas e
  retrabalho relevantes, problemas de QA, handoff.
- **Evitar:** transcrição de comandos, log bruto, cópia de código versionado,
  duplicação integral do Jira, dumps, secrets/tokens/credenciais, fatos com fonte
  oficial melhor, conhecimento técnico durável (→ `context/`).
- **Ciclo de vida:** ativo em `active/`; concluído **ou cancelado** → `history/`
  (nunca apagado). Retenção histórica indefinida, sem expiração, limite de
  tamanho, compactação ou limpeza automática (política só se o volume virar
  problema real).
- **QA:** o Jira guarda o resultado operacional; a AI Memory pode guardar o cenário
  técnico que falhou, passos relevantes, evidências, causa provável, arquivos/
  repositórios relacionados e handoff para a próxima tentativa.
- **Consumo:** leitura simples/determinística → direta; localizar/interpretar →
  pode chamar `ai-memory-manager`; criar/alterar/reorganizar/consolidar/arquivar →
  **obrigatoriamente** `ai-memory-manager`.
- **Encerramento:** a capacidade que constata oficialmente a conclusão/cancelamento
  pode solicitar o arquivamento; a skill confirma o estado na fonte oficial,
  consolida o handoff final, move `active → history` e commita. Ela não conclui a
  issue no Jira. Em Hotfix, aprovação de review não autoriza arquivar: só depois
  que o Jira confirmar o estado final movido por Rafinha.

**Git da AI Memory (D6, confirmado).** A `ai-memory-manager` pode, na branch
correta já existente para a operação — **inclusive `develop` e `release/current`**
quando for onde a operação válida ocorre —, fazer `git add` e criar o commit das
**próprias** alterações em `ai-memory/`. Não pode: `push`, criar branch arbitrária,
escolher/alterar base de branch, mergear, rebasear, `force push`, resolver
conflito semântico, alterar gitlinks, promover branch do Workspace, executar
operação Git fora de `ai-memory/`. Conflito que impeça persistência segura →
registra o bloqueio e delega a resolução à capacidade responsável. Commit de
memória ≠ integração de composição.

## 4. Workspace multi-repo

O Workspace é o repositório Git superior que representa o produto multi-repo como
**unidade versionada, contextualizada e reproduzível**.

```text
produto-workspace/
├── context/
├── ai-memory/ (active/, history/)
├── repo-a/   # Git submodule
├── repo-b/   # Git submodule
└── repo-c/   # Git submodule
```

Neutro em tecnologia de build. Cada **repositório componente** continua um
repositório Git independente (o termo descreve a posição na composição, não cria
categoria funcional nem convenção própria de branch). O Workspace versiona os
**gitlinks** (Git Submodules): um commit do Workspace representa uma composição
exata do produto. Hashes dos componentes não são duplicados em Markdown.

**Gitlink ≠ branch ativa.** Gitlink = snapshot exato (commit); branch ativa =
linha onde o trabalho ocorre. Nenhuma skill inicia implementação em `detached
HEAD`: antes de alterar um repositório componente, a branch correta deve estar
ativa e validada.

**Branches do Workspace:**

```text
workspace/develop              composição oficialmente integrada
workspace/epic/<EPIC-KEY>      composição acumulada e contexto compartilhado do Epic
workspace/issue/<ISSUE-KEY>    composição temporária de issue normal SEM Epic
workspace/hotfix/<ISSUE-KEY>   composição temporária de Hotfix antes da promoção
```

Issue normal de Epic **não cria branch persistente própria** no Workspace.
Prefixos de branch nos repositórios componentes **não são redefinidos**
(`feat/`, `fix/`, `refactor/`, `hotfix/<KEY>`...). Issue de Epic: branch de
implementação nasce da branch do Epic no repositório correspondente. Issue
isolada: nasce de `develop`. Hotfix: sempre de `develop`.

**Autoridades:**

```text
bootstrap inicial do Workspace (repo superior, composição, Submodules)  → Rafinha
preparação de topologia e branches obrigatórias (inclui Epic)           → jira-technical-preparation-executor
implementação nos repositórios                                          → jira-issue-executor
governança de context/                                                  → engineering-context-manager
integração dos repositórios + composição/gitlinks do Workspace         → jira-integration-executor
AI Memory                                                               → ai-memory-manager
```

**Paralelismo:** um único agente ativo por Epic (issues do mesmo Epic são
trabalhadas serialmente quanto ao estado compartilhado do Workspace). Epics
diferentes podem andar em paralelo. Sem locks, worktrees especiais, branches
auxiliares de coordenação ou protocolo de merge concorrente de AI Memory.

**Composição pela `jira-integration-executor`.** No mono-repo ela integra
branches no próprio repositório; no multi-repo, integra nos repositórios afetados
e atualiza a composição versionada. *Integrar o código inclui integrar a
composição.*

```text
Modo A — issue → Epic
  repositórios: issue → epic/<EPIC>
  Workspace: atualizar workspace/epic/<EPIC> → gitlinks dos commits integrados → commit de composição

Modo B — Epic → develop
  repositórios: epic/<EPIC> → develop
  Workspace: gitlinks para os commits finais de develop → commit final de composição
             → workspace/epic/<EPIC> → workspace/develop

Modo C — issue isolada → develop
  repositórios: issue → develop
  Workspace: workspace/issue/<ISSUE> (gitlinks dos commits integrados → commit de composição)
             → workspace/develop

Modo C — Hotfix
  repositórios: hotfix/<ISSUE> → develop
  Workspace: workspace/hotfix/<ISSUE> → composição final → workspace/develop
```

**Regra dos gitlinks (fluxo normal).**
- Issue de Epic: enquanto a branch da issue não foi integrada à branch do Epic no
  repositório, o gitlink de `workspace/epic/<EPIC>` **não** aponta para commit
  exclusivo da branch da issue. Depois da integração: issue → Epic (repo) →
  `workspace/epic/<EPIC>` avança o gitlink.
- Issue isolada: `workspace/issue/<ISSUE>` não aponta gitlink para commit ainda
  isolado; depois que os repositórios afetados forem integrados em `develop`, a
  branch avança para a composição final e é integrada em `workspace/develop`.
- `workspace/develop` só avança quando a composição correspondente está
  efetivamente integrada nas `develop` dos repositórios envolvidos.

**Exceção de Hotfix.** `workspace/hotfix/<ISSUE-KEY>` pode representar
temporariamente commits que ainda existem só nas branches `hotfix/<ISSUE-KEY>` dos
repositórios afetados, para validar a composição completa sem passar por Epic.
Repositórios não afetados continuam apontando para a composição de
`workspace/develop`. Após aprovação: `repo/hotfix → repo/develop` (todos os
afetados) → `workspace/hotfix` consolida a composição final → `workspace/develop`.
Hotfix nunca usa branch de Epic como base ou destino.

**Dois tipos conceituais de commit no Workspace:** *memória operacional*
(handoff, descoberta, dependência, estado de tentativa, observação de QA,
atualização de AI Memory — sem necessariamente alterar gitlinks) e
*composição/contexto* (avanço de gitlinks, atualização de `context/`, normalização
contextual, fechamento de unidade de trabalho). Commit de memória ≠ integração de
composição.

**Fluxo — issue normal de Epic.**

*Preparação* (`jira-technical-preparation-executor`): abre e valida o Workspace;
consulta contexto e AI Memory; confirma estados críticos nas fontes autoritativas;
cria `workspace/epic/<EPIC>` se a branch obrigatória não existe; cria/valida as
branches de Epic nos repositórios afetados; valida Design Package quando
aplicável; registra o atestado; só então a issue pode ir a `Ready`.

*Implementação* (`jira-issue-executor`): recebe a topologia preparada; cria/usa a
branch de implementação (nasce da branch do Epic); implementa; delega persistência
de handoff/descobertas à `ai-memory-manager`; pode atualizar `context/` via
`engineering-context-manager`; o gitlink não aponta para commit exclusivo da
branch da issue antes da integração no Epic.

*Integração da issue no Epic* (`jira-integration-executor`): integra a branch da
issue na do Epic no repositório; obtém o commit efetivamente integrado; atualiza o
gitlink de `workspace/epic/<EPIC>`; cria o commit de composição; `context/` é
normalizado pela capacidade responsável; resultado com valor de continuidade é
delegado à `ai-memory-manager`; a próxima issue do Epic parte do estado acumulado.

**Fluxo — issue normal isolada.** Criar `workspace/issue/<ISSUE>` a partir de
`workspace/develop`; criar a branch de implementação nos repositórios afetados a
partir da base aplicável; usar `context/` e AI Memory no nível da issue isolada; não
apontar gitlinks para commits não integrados à `develop`; após aprovação, a
`jira-integration-executor` integra os repositórios afetados em `develop`, obtém os
commits integrados, atualiza os gitlinks de `workspace/issue/<ISSUE>`, cria o
commit de composição, integra em `workspace/develop`, valida que `workspace/develop`
representa a composição integrada e limpa as branches encerradas. Integração dos
repositórios + promoção do Workspace = **uma operação lógica**.

**Encerramento de Epic (ordem consolidada).**
1. Todas as issues obrigatórias integradas nas branches de Epic dos repositórios.
2. Finalizar a AI Memory do Epic e seus handoffs (`ai-memory-manager`).
3. Mover `ai-memory/active/<EPIC>` → `ai-memory/history/<EPIC>` (`ai-memory-manager`).
4. Garantir, pela capacidade contextual, que `context/` represente o estado final do Epic.
5. Com as condições anteriores, `jira-integration-executor` executa a integração final.
6. Integra as branches de Epic dos repositórios em suas `develop`.
7. Obtém os commits finais resultantes.
8. Atualiza os gitlinks de `workspace/epic/<EPIC>` para os commits finais das `develop`.
9. Cria o commit final de composição.
10. Integra `workspace/epic/<EPIC>` em `workspace/develop`.
11. Valida que `workspace/develop` representa a composição efetivamente integrada.
12. Limpa as branches de Epic conforme a política vigente.

**Design Package em multi-repo.** Não fica no Workspace: permanece local-only e
gitignored no repositório afetado (`repo-afetado/.claude/design-packages/<ISSUE-KEY>/`).
Cada repositório com material de design pode ter o seu. A Preparação Técnica
identifica os repositórios afetados e valida o pacote aplicável quando
`requires-design` está ativa.

**Bootstrap manual.** O Workspace inicial (repositório superior, composição,
Submodules, estrutura) é responsabilidade de Rafinha, documentado no guia *Como
montar um projeto*, passo 1. As skills não o criam do zero. Se uma issue exige
operação multi-repo e o Workspace obrigatório não existe ou está estruturalmente
inválido, a Preparação Técnica bloqueia o avanço a `Ready` e aponta o
procedimento manual.

**Fora do escopo:** mover CI/CD para o Workspace; centralizar automação do
produto; alterar regras de release não afetadas; substituir Jira/Confluence/Git
pela AI Memory; tornar Obsidian obrigatório; paralelismo intraépico; locks/
worktrees especiais; migrar projetos concluídos; redefinir prefixos de branch dos
componentes.
