# Template — Página de workflow

**Label:** `workflow-doc` · **Skill:** `workflow-doc-writer`
**Fonte da verdade:** o contrato operacional vigente — skills reais, Jira,
decisões oficiais registradas no Notion/Confluence
**Convenção de título:** livre, conforme a natureza da página (ex.: "Modelo de
branches", "Vocabulário operacional de labels", "Gates operacionais",
"Controle de workflow - <produto>")

Este é o template **guarda-chuva** para tudo que documenta o pipeline em si,
e não uma skill específica (isso é `skill-page.md`) nem a documentação de
release de um projeto (isso é `release-doc.md`): modelo de branches, gates, hierarquia, vocabulário
de labels, tipos de ticket, página de controle por produto.

## O que esta página documenta
1–3 frases: o recorte exato do contrato que esta página cobre, e para quem
ela serve — Rafinha revisitando a decisão, ou uma skill consultando antes de
agir.

## Regra vigente
O conteúdo central. Estrutura livre, conforme o assunto — tabela quando a
informação for comparativa (labels por categoria, branch por situação),
lista numerada quando for sequência (gates, etapas), texto corrido quando
for só contexto. Não force uma estrutura que não serve ao conteúdo.

## Como isso se aplica na prática
Exemplo concreto, ou referência a qual skill lê esta página / aplica esta
regra sem precisar reler o texto inteiro.

## Relação com outras páginas
Links para página-mãe, páginas-filhas, ou páginas irmãs do mesmo domínio —
cada link com 1 frase de contexto, nunca lista solta.

## Histórico de revisão relevante
Só mudanças que alteraram a regra vigente, não changelog de redação: data, o
que mudou, e a decisão que motivou (se houver uma registrada em
`plano-pacote-*.md` ou no Notion).

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Detalhe de comportamento de uma skill específica | Ficha da skill | `workflow-doc-writer`, template `skill-page.md` |
| Documentação de release de um projeto | Árvore `CI/CD - Workflow Rafinha-Claude` | `workflow-doc-writer`, template `release-doc.md` |
| Regra de negócio ou requisito de produto | RN / requisito | `product-doc-writer` |

> Se o conteúdo só faz sentido para uma skill (o que ela faz passo a passo)
> ou para uma distribuição específica (o que saiu nesta versão), ele não
> pertence aqui — mesmo que o assunto pareça "de workflow" à primeira vista.
