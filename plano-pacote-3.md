# Plano de implementação — Pacote 3: Skills de documentação

Documento de planejamento e **registro de implementação**, no mesmo formato do
`plano-pacote-2.md`.

**Fonte do contrato:** página do Notion *"Atualização — Skills de
documentação"*, lida em 2026-09-23.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-23 | Versão inicial. D1 decidida por Rafinha. Onda 1 concluída |
| 2026-09-23 | **D3 decidida por Rafinha — Pendência 4 fechada.** Onda 2 concluída |

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 1 | Higiene das skills atuais + rename | ✅ ver §3 |
| 2 | Taxonomia e templates em `references/` | ✅ ver §6 (mapa pendente) |
| 3 | Ampliação dos writers (product, tech, screen com modos) | ⬜ |
| 4 | Novas skills: `user-doc-writer`, `workflow-doc-writer` | ⬜ destravada por D3 |
| 5 | Integração com o fluxo Jira (`jira-doc-executor`) | ⬜ |
| 6 | Componentes reutilizáveis e piloto | ⬜ |

---

## 1. Por que este pacote não sai numa passagem

O Pacote 2 tinha uma seção explícita de **"Pendências encerradas nesta
rodada"**. Este não tem: a página se declara `Status: Definição oficial em
construção`, com **quatro pendências abertas**.

Duas delas bloqueiam trabalho de verdade.

### Pendência 1 — nome das skills → **DECIDIDA**

Ver §2.

### Pendência 4 — fronteira módulo × tela × usuário → **FECHADA**

Ver D3 em §2. Era o único bloqueio real do pacote.

### Pendência 2 — destino de `qa-doc`

`qa-doc` segue como label válida sem writer. Não bloqueia nada; só não pode
ser delegada.

### Pendência 3 — quando criar a `workflow-doc-writer`

Antes da janela de migração (para já escrever as páginas novas) ou depois
(para manutenção recorrente). Decisão de sequenciamento, não de conteúdo.

---

## 2. Decisões de implementação

### D1 — Renomear as duas skills

**Decidida em 2026-09-23 por Rafinha.**

```text
business-rule-writer  →  product-doc-writer
module-doc-writer     →  tech-doc-writer
```

**Por que isso vinha primeiro:** o nome decide o nome do diretório, todas as
referências cruzadas entre skills, os títulos das fichas no Confluence e o
que a `jira-doc-executor` invoca. Tudo depois da Onda 1 dependia dessa
escolha.

**Consequência de sequenciamento:** a ordem sugerida no Notion coloca o
rename na Onda 3. Como a decisão foi fechada antes, o rename foi **dobrado
dentro da Onda 1** — fazer a higiene num arquivo que mudaria de nome depois
seria passar duas vezes no mesmo lugar.

### D2 — Nome-alvo com escopo declarado, não escopo inventado

**Decidida em 2026-09-23, durante a Onda 1.**

O rename criou um problema imediato: a skill passa a se chamar
`product-doc-writer`, mas só sabe escrever regra de negócio. O nome promete
mais do que o conteúdo entrega — que é exatamente o defeito que o rename
deveria corrigir, invertido.

**Decisão:** cada writer ganha uma seção **Escopo** declarando, em tabela, o
que já tem template e o que não tem.

| Skill | Implementado hoje | Pendente de template |
| --- | --- | --- |
| `product-doc-writer` | `rn-doc` | requisito, caso de uso, fluxo de produto, critérios de aceitação |
| `tech-doc-writer` | `module-doc` + pasta `docs/` | `api-doc`, `component-doc`, `readme`, `adr` |

E a regra que fecha o buraco:

> Se Rafinha pedir uma trilha sem template, a skill **diz que o template não
> existe** e pergunta se ele quer a estrutura implementada adaptada, ou
> prefere esperar. Nunca improvisa uma estrutura nova nem a apresenta como
> oficial.

**Motivo:** estrutura inventada vira precedente, e precedente inventado é
mais difícil de corrigir do que uma lacuna declarada. É o mesmo princípio do
gate "proibido fallback silencioso" do Pacote 1, aplicado a template em vez
de label.

### D3 — Documentar é job composto, não escolha de página

**Decidida em 2026-09-23 por Rafinha.** Fecha a Pendência 4.

Eu tinha formulado a pendência como *"qual das quatro páginas este pedido
vira?"* — uma escolha excludente. **A formulação estava errada.**

> Quando se pede para documentar uma tela, o agente aciona **o conjunto** de
> skills. Documentar uma tela é um trabalho composto, e cada skill faz a
> sua parte.

**O que isso resolve.** O roteamento deixa de ser uma decisão: não existe
"qual writer", existe "quais writers, e o que cabe a cada um".

**O que eu tinha calculado errado.** Eu temia uma explosão de páginas — 30
telas × 4 páginas. Não acontece, porque **as granularidades são
diferentes**:

| Skill | Uma página por... |
| --- | --- |
| `tech-doc-writer` | **módulo** |
| `screen-doc-writer` | **tela** (modo dev, user ou híbrido) |
| `user-doc-writer` | **tarefa de usuário**, que atravessa telas |

Documentar uma tela nova **atualiza** a página do módulo que já existe e
**entra** no guia que já existe, enquanto cria ou atualiza a página dela
própria. O fan-out real é pequeno.

Isso também responde à dúvida de fronteira que restava: tarefa que atravessa
telas → guia; tarefa que mora numa tela só → a própria página de tela em
modo `user`.

**A regra anti-duplicação**, derivada do princípio que a própria página do
Notion declara (*"uma skill por fonte da verdade"*):

| Skill | Fonte da verdade | Escreve |
| --- | --- | --- |
| `tech-doc-writer` | o código | arquitetura do módulo, camadas, como as telas se encaixam nele |
| `screen-doc:dev` | a tela rodando + o código dela | rota, cubit, chamadas de API **daquela tela** |
| `screen-doc:user` | a tela rodando | campos, botões, mensagens, erros visíveis |
| `user-doc-writer` | o produto funcionando | a tarefa ponta a ponta |

```text
Cada writer escreve só o que a sua fonte da verdade entrega,
e linka em vez de repetir.
```

Exemplo do desempate: *"qual cubit gerencia esta tela"* é `screen-doc:dev`.
A página de módulo diz quais cubits existem no módulo; não detalha cada tela.

**Consequência de peso.** Isso desloca trabalho para a
`jira-doc-executor`: ela deixa de ser "label → writer" e passa a montar um
**conjunto de delegações por job**, decidindo quais das skills se aplicam e
declarando quais pulou e por quê — mesmo princípio do proibido fallback
silencioso. **A Onda 5 fica maior do que a página do Notion previa.**

---

## 3. Registro — Onda 1

**Concluída em 2026-09-23.**

### O que foi feito

| Item | Onde |
| --- | --- |
| **Rename** | `git mv` nos dois diretórios, `name:` no frontmatter, e todas as referências cruzadas em 8 arquivos |
| **Frontmatter duplicado** | Removido em `tech-doc-writer` e `doc-pendency-resolver` (o de `product-doc-writer` já tinha saído) |
| **"Rafael" → "Rafinha"** | 16 ocorrências no `product-doc-writer`, 2 no `tech-doc-writer`, 2 no `doc-pendency-resolver` |
| **Multi-produto** | 4 pontos do `tech-doc-writer` que assumiam GeoPrag |
| **`doc-pendency-resolver`** | Passa a listar as três writers em tabela, incluindo a `screen-doc-writer`, que não era citada |
| **Seção Escopo** | Nova nos dois writers renomeados (D2) |

### A generalização multi-produto era pior do que parecia

A `module-doc-writer` não só citava o GeoPrag como exemplo — ela mandava
"olhar 1-2 páginas já existentes **no espaço Geoprag**" para manter
consistência de tom. Rodando no Compass System, a skill importaria a
convenção do produto errado.

O texto agora manda olhar o espaço **daquele produto**, e diz explicitamente
que convenção de um produto não se importa para outro sem confirmar.

### `Rafael` ficou de fora em duas skills

`task-creator-trabalho` (11 ocorrências) e `weekly-organizer` (8) também
escrevem "Rafael". **Não foram tocadas**: a página do Notion cita o
`business-rule-writer` nominalmente, e essas duas não são skills de
documentação do workflow — são pessoais, de outro contexto. Se o "Rafinha"
for para valer em todo lugar, é uma decisão à parte.

### O que a Onda 1 deliberadamente NÃO fez

- Não ampliou o escopo de writer nenhum. Isso é Onda 3 e depende dos
  templates da Onda 2.
- Não tocou na `screen-doc-writer` além do rename das referências. Os modos
  `screen-doc:user` / `:dev` / `:hybrid` são Onda 3.
- Não criou skill nova. Onda 4, bloqueada pela Pendência 4.
- Não atualizou o Confluence. As fichas `business-rule-writer` e
  `module-doc-writer` ficaram com o nome antigo — ver §4.

---

## 4. Pendência imediata criada por esta onda

O rename deixou **onze páginas do Confluence** com os nomes antigos.
Levantado por CQL em 2026-09-23 — a estimativa inicial deste documento dizia
"duas fichas mais o índice", e estava errada.

**Fichas que precisam mudar de título e de conteúdo:**

| Página | ID |
| --- | --- |
| `business-rule-writer` | 44433409 |
| `module-doc-writer` | 44302341 |

**Páginas que só citam os nomes:**

| Página | ID |
| --- | --- |
| Skills (índice) | 44105730 |
| Claude Skills (home do espaço) | 44204199 |
| jira-doc-executor | 44204245 |
| screen-doc-writer | 44204265 |
| doc-pendency-resolver | 44138502 |
| jira-issue-executor | 44072962 |
| Visão geral do fluxo | 44302381 |
| Vocabulário operacional de labels | 68222978 |
| Gates operacionais | 68223007 |

Isso é drift criado por mim nesta onda, não drift herdado. Precisa ser
resolvido antes do corte de vigência do Pacote 3 — ou na Onda 2, ou numa
passada dedicada de Confluence.

---

## 5. Fora do escopo deste pacote

- Renomear "Rafael" nas skills pessoais (`task-creator-trabalho`,
  `weekly-organizer`).
- Definir destino de `qa-doc` (Pendência 2 da página de origem).

---

## 6. Registro — Onda 2

**Concluída em 2026-09-23**, exceto o mapa de taxonomia (ver §7).

### 12 templates, não 16

Os quatro restantes — `user-guide.md`, `workflow-page.md`, `skill-page.md` e
`release-doc.md` — pertencem a skills que **ainda não existem**. Criá-los
agora deixaria arquivo órfão em `references/` de skill nenhuma.

Eles nascem na Onda 4, junto com a `user-doc-writer` e a
`workflow-doc-writer`.

| Writer | Templates |
| --- | --- |
| `product-doc-writer` | `rn.md`, `requisito.md`, `caso-de-uso.md`, `fluxo-produto.md`, `criterios-aceitacao.md` |
| `tech-doc-writer` | `modulo.md`, `api.md`, `arquitetura-dev.md`, `componente-reutilizavel.md` |
| `screen-doc-writer` | `screen-dev.md`, `screen-user.md`, `screen-hybrid.md` |

### A seção que faz o modelo composto funcionar

Todo template termina com uma tabela **"O que NÃO vai nesta página"**,
apontando conteúdo por conteúdo para a skill dona.

Sem ela, o modelo da D3 não fecha: se as quatro skills rodam juntas no mesmo
job, e nenhuma sabe o que não é dela, todas escrevem tudo. A tabela é a
aplicação prática de *"uma skill por fonte da verdade"*.

Exemplo, do `modulo.md`:

> A página de módulo diz **quais cubits existem no módulo**; ela não detalha
> qual cubit gerencia cada tela. Isso é doc de tela.

### Modos da `screen-doc-writer`

Os três modos entraram nesta onda junto com os templates — separar "criar o
template" de "ligar a skill ao template" deixaria a skill num meio-termo
inútil.

Regra de desempate registrada:

> **Na dúvida, `hybrid`.** Duas páginas que ninguém mantém são piores que uma
> que serve a dois leitores. Separar depois é barato; reconciliar duas páginas
> que divergiram não é.

E o modo **nunca é inferido do nome da tela** — mesmo princípio do modo de
integração do Pacote 2.

### Uma lacuna da página de origem, declarada e não preenchida

As labels **`readme` e `adr`** existem na matriz oficial de labels, mas
**ficaram de fora da lista de 16 templates** da atualização. Não são
esquecimento meu.

Registrei as duas na tabela de escopo da `tech-doc-writer` marcadas como
**sem template**, com a instrução de declarar a lacuna e perguntar. Preencher
por conta própria seria inventar estrutura — exatamente o que a D2 proíbe.

---

## 7. O que falta

| Item | Onda | Bloqueio |
| --- | --- | --- |
| Mapa tipo de página → página-mãe → convenção de título | 2 | nenhum — é trabalho de Confluence |
| Ampliar os writers para as trilhas novas | 3 | nenhum |
| `user-doc-writer` + `user-guide.md` | 4 | nenhum (D3 destravou) |
| `workflow-doc-writer` + 3 templates | 4 | Pendência 3 é só *quando*, não *se* |
| `jira-doc-executor` como orquestradora de conjuntos | 5 | depende de 3 e 4 |
| Componentes reutilizáveis e piloto | 6 | depende do template, que já existe |
| 11 páginas do Confluence com nome antigo | — | nenhum |
| Fichas novas no Confluence para as skills novas | — | depende da Onda 4 |
| Corte de vigência (merge) | — | tudo acima |

A convenção de título de cada tipo de página **já está dentro do template**
— o mapa do Confluence passa a ser o índice disso, não a fonte.
