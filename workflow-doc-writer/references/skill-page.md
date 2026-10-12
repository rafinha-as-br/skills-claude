# Template — Ficha de skill

**Label:** `skill-doc` · **Skill:** `workflow-doc-writer`
**Fonte da verdade:** o `SKILL.md` real no repositório (comportamento
*implementado*) e o contrato normativo da skill. O **Confluence é a autoridade
normativa**; o `SKILL.md` demonstra o implementado. Divergência entre os dois é
**drift** — descritiva/técnica compatível: sincronize; contratual: reconcilie
(ver passo 3 da skill)
**Convenção de título:** o nome da skill, exatamente como no frontmatter
(`name:`), ex.: `jira-issue-executor`

> **Forma da ficha: Contrato + Operação técnica.** A ficha é a documentação de
> **uma** capacidade em duas camadas — não de duas skills. O bloco *Contrato da
> skill* é a interface normativa; *Operação técnica* resume como ela cumpre o
> contrato.

## Resumo
2–4 frases: o que a skill faz e por que ela existe. Vem do `SKILL.md`, não de
memória do que ela fazia antes.

## Contrato da skill
Cópia fiel do bloco `## Contrato da skill` do `SKILL.md`: finalidade; escopo e
acionamento; **autoridade** de decisão, mutação, atestação e transição; entradas
e pré-condições; obrigações; evidências e registros; saída; limites; delegações.
Regras universais (defaults herdados) **referenciam** a página *Contrato das
skills* — não são copiadas.

## Quando é acionada
Os gatilhos reais — frase que Rafinha diria, coluna do Jira, ou outra skill
que a chama. Vem da `description` do frontmatter e do "Quando usar" do
`SKILL.md`, não inventado.

## Fonte da verdade da skill
De onde ela tira o conteúdo que escreve/decide (código, decisão de produto,
UI rodando, Jira, etc.) — uma frase.

## Operação técnica (resumo)
Como a skill cumpre o contrato: procedimento em alto nível, ferramentas,
integrações, formatos e fallbacks técnicos autorizados, Model Policy. Não repete
o passo a passo completo — esse vive no `SKILL.md`. A operação **não pode**
ampliar a autoridade declarada no contrato.

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
| Documentação de release de um projeto | Árvore `CI/CD - Workflow Rafinha-Claude` | `workflow-doc-writer`, template `release-doc.md` |

> Esta página documenta **contrato e operação** para quem não vai abrir o
> repositório. O contrato é normativo; a operação resume o `SKILL.md`. Se a
> divergência for apenas descritiva, corrija a página; se for **contratual**,
> trate como drift a reconciliar — não altere a norma para justificar o
> comportamento implementado, nem declare o `SKILL.md` correto só porque ele
> executa.
