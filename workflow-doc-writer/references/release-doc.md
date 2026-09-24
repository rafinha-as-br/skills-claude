# Template — Registro de release

**Label:** `release-doc` · **Skill:** `workflow-doc-writer`
**Fonte da verdade:** a execução real da release — Release Orchestrator,
GitHub Actions, `release-manifest.yml`
**Convenção de título:** `Release - <produto ou componente> vX.Y.Z`

## Resumo da distribuição
Tipo (`PRE_RELEASE`/`FINAL`), escopo (parcial/completa), data, e o que essa
versão entrega — 2–3 frases.

## Componentes e versões
Tabela: componente · versão anterior · versão nova · motivo do incremento (ou
`carried`, quando o componente foi puxado por dependência mas não mudou).

## O que mudou
Notas de release em texto corrido — vêm do que a `jira-release-executor` já
reuniu do Jira; não reescreva do zero aqui.

## Issues incluídas
Tabela: chave da issue · resumo · tipo. É a rastreabilidade de quem precisa
saber o que está dentro desta distribuição.

## Artefatos e onde encontrar
Link do pacote no Drive, e do `release-manifest.yml` quando relevante. Link
do GitHub Release só existe para versão **final** — nunca para RC.

## Riscos e exceções conhecidas
Exceções ao gate G10 autorizadas para esta release, se houver: item, risco,
autorização, impacto — os quatro campos, sem exceção.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Regra de negócio entregue nesta release | RN | `product-doc-writer` |
| Passo a passo de como a Action builda/publica | `release.yml` do repositório | não é página de Confluence |
| Ficha da skill de release | Ficha da skill | `workflow-doc-writer`, template `skill-page.md` |

> Esta página registra **o que saiu**, não como o processo de release
> funciona em geral — isso é `workflow-page.md`.
