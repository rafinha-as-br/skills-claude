# Template — Ficha de skill

**Label:** `skill-doc` · **Skill:** `workflow-doc-writer`
**Fonte da verdade:** o `SKILL.md` real no repositório — esta página documenta o
que ele faz, nunca o contrário
**Convenção de título:** o nome da skill, exatamente como no frontmatter
(`name:`), ex.: `jira-issue-executor`

## Resumo
2–4 frases: o que a skill faz e por que ela existe. Vem do `SKILL.md`, não de
memória do que ela fazia antes.

## Quando é acionada
Os gatilhos reais — frase que Rafinha diria, coluna do Jira, ou outra skill
que a chama. Vem da `description` do frontmatter e do "Quando usar" do
`SKILL.md`, não inventado.

## Fonte da verdade da skill
De onde ela tira o conteúdo que escreve/decide (código, decisão de produto,
UI rodando, Jira, etc.) — uma frase.

## Entradas e saídas
O que ela lê antes de agir, e o que ela cria/altera ao final (branch, PR,
página, label, arquivo). Tabela quando houver mais de dois itens.

## Onde se encaixa no pipeline
Coluna do board, gate, ou etapa do ciclo de release a que ela pertence — link
para a página de workflow correspondente em vez de repetir a regra aqui.

## Dependências
Outras skills que ela aciona, e outras skills que a acionam. Nome + 1 frase
do porquê.

## Regras importantes (resumo)
As 3–5 regras que mais importam para quem só quer entender o comportamento
sem ler o `SKILL.md` inteiro — não é a lista completa de "O que NÃO fazer".

## Última verificação de drift
Data da última vez que esta página foi comparada com o `SKILL.md` real, e o
resultado: "sem divergência" ou o que foi corrigido.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Regra operacional que vale para várias skills (gate, modelo de branch) | Página de workflow | `workflow-doc-writer`, template `workflow-page.md` |
| Passo a passo interno completo da skill | O próprio `SKILL.md` | não se repete no Confluence |
| Registro de uma release específica | Registro de release | `workflow-doc-writer`, template `release-doc.md` |

> Esta página **resume** o `SKILL.md` para quem não vai abrir o repositório.
> Nunca é a página que decide o que a skill faz — se ela divergir do
> `SKILL.md`, a página está errada, não o código.
