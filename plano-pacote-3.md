# Plano de implementação — Pacote 3: Skills de documentação

Documento de planejamento e **registro de implementação**, no mesmo formato do
`plano-pacote-2.md`.

**Fonte do contrato:** página do Notion *"Atualização — Skills de
documentação"*, lida em 2026-09-23.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-23 | Versão inicial. D1 decidida por Rafinha. Onda 1 concluída |

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 1 | Higiene das skills atuais + rename | ✅ ver §3 |
| 2 | Taxonomia e templates em `references/` | ⬜ |
| 3 | Ampliação dos writers (product, tech, screen com modos) | ⬜ |
| 4 | Novas skills: `user-doc-writer`, `workflow-doc-writer` | 🔒 **bloqueada** |
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

### Pendência 4 — fronteira módulo × tela × usuário → **bloqueia a Onda 4**

Sem regras objetivas separando documentação de módulo, de tela para dev, de
tela para usuário e guia de usuário que atravessa telas, a `user-doc-writer`
e o modo `screen-doc:user` se sobrepõem.

Implementar a `user-doc-writer` sem essa fronteira significaria **inventar
exatamente o recorte que esta atualização existe para definir** — e o
recorte inventado viraria precedente antes de Rafinha decidir.

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

O rename tornou **duas fichas do Confluence obsoletas no título**:

| Página | ID | Estado |
| --- | --- | --- |
| `business-rule-writer` | 44433409 | título e conteúdo com o nome antigo |
| `module-doc-writer` | 44302341 | título e conteúdo com o nome antigo |

Mais a página índice **Skills** (44105730), que lista as duas pelos nomes
antigos.

Isso é drift criado por mim nesta onda, não drift herdado. Precisa ser
resolvido antes do corte de vigência do Pacote 3 — ou na Onda 2, ou numa
passada dedicada de Confluence.

---

## 5. Fora do escopo deste pacote

- Renomear "Rafael" nas skills pessoais (`task-creator-trabalho`,
  `weekly-organizer`).
- Definir destino de `qa-doc` (Pendência 2 da página de origem).
