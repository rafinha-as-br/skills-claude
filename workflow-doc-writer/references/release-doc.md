# Template — Documentação de release do projeto

**Label:** `release-doc` · **Skill:** `workflow-doc-writer`
**Fonte da verdade:** `.release/project.yml`, a `release.yml` de cada
repositório, as GitHub Actions e, para cada distribuição, o
`release-manifest.yml`
**Contrato de origem:** `workflow-development-flow/references/release-lifecycle.md`,
§13 (quem guarda o quê) e §19 (documentação obrigatória do projeto)

Cobre a árvore **`CI/CD - Workflow Rafinha-Claude`** que todo projeto com
ciclo de release precisa ter no seu space. Sem ela, o gate G0 bloqueia a
primeira release. É uma árvore, não uma página — cada filha responde uma
parte das perguntas do G0.

## Árvore e o que cada página responde

| Página | Responde | Fonte |
|---|---|---|
| `CI/CD - Workflow Rafinha-Claude` | índice da árvore; topologia (monorepo ou multi-repo) | `.release/project.yml` |
| Projeto e Componentes | quais são os componentes, quais os repositórios, quais dependências | `.release/project.yml` |
| Build e Artefatos | como cada componente é construído, quais artefatos produz | `release.yml` de cada repositório |
| Execução de uma Versão | como uma versão é executada fora da IDE | `.release/project.yml`, Runtime Package |
| Runtime Package | se existe e como é executado — ou, se `false`, a justificativa e como a versão roda sem ele | `.release/project.yml` |
| Banco e Infraestrutura Local | só quando aplicável | Rafinha |
| CI/CD | as Actions que existem e o que cada uma dispara | GitHub Actions |
| Release | **índice das distribuições + cópia de cada Manifest** | `release-manifest.yml` |
| Validação da Release | como a versão é validada, e o veredito de cada distribuição | fase 6 da `jira-release-executor` |
| Versionamento | versão atual do produto e de cada componente | tags `<componente>/vX.Y.Z` |
| Release Multi-Repository | obrigatória se `topology = multi_repo` | `.release/project.yml` |

Página com conteúdo ausente na fonte **não é preenchida por inferência** — é
pendência do G0, via `doc-pendency-resolver`.

## A página Release — regra própria

Cada distribuição **final** acrescenta uma entrada, nesta forma:

```text
### <produto ou componente> vX.Y.Z — <data>
Tipo: FINAL · Escopo: <parcial|completa>
Pacote: <link do Drive>

<conteúdo do release-manifest.yml, copiado literalmente num bloco de código>
```

> ⚠️ **O Confluence copia, não reinterpreta.** Nenhuma nota de release em
> texto corrido, nenhuma tabela de componentes reescrita à mão: o Manifest
> é a única versão. Uma segunda versão escrita à mão diverge do ZIP na
> primeira correção, e o contrato de release proíbe isso explicitamente.

Pre-release (`rc.N`) não entra nesta página — mesma regra do GitHub Release.

Exceção ao gate G10 autorizada para aquela promoção entra logo abaixo da
entrada, com os quatro campos (item, risco, autorização, impacto) — nunca
pela metade.

## O que NÃO vai nesta árvore

| Conteúdo | Vai em | Skill |
|---|---|---|
| Como o ciclo de release funciona em geral, para todos os projetos | Página de workflow (Release & Versionamento) | `workflow-doc-writer`, template `workflow-page.md` |
| Ficha da `jira-release-executor` | Ficha da skill | `workflow-doc-writer`, template `skill-page.md` |
| Regra de negócio entregue numa versão | RN | `product-doc-writer` |
| Notas de release reescritas à mão | lugar nenhum | o Manifest já é o registro |
