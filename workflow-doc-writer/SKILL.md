---
name: "workflow-doc-writer"
description: "Escritor da documentação do PRÓPRIO Workflow Rafinha-Claude no Confluence — páginas de skill, páginas de fluxo/gates/labels/tipos de ticket, controle por produto, e registro de releases. A fonte da verdade é o contrato operacional real: `SKILL.md` de cada skill, `.release/project.yml`, board do Jira, GitHub Actions e decisões oficiais no Notion/Confluence — nunca decisão de produto nem código de feature. Usar sempre que Rafinha disser \"atualiza a ficha dessa skill\", \"documenta essa release no Confluence\", \"a página de gates/labels/branches está desatualizada\", pedir para verificar se uma ficha de skill bate com o SKILL.md real, ou pedir para criar a página de controle de um produto novo. Roda com acesso ao repositório (mesmo contexto de jira-issue-executor) sempre que precisar ler um SKILL.md real para checar drift. Três templates em `references/`: `skill-page.md` (uma skill), `workflow-page.md` (regra do pipeline em si — branches, gates, labels, tipos de ticket, controle por produto), `release-doc.md` (uma distribuição específica). SEMPRE leia o template antes de escrever. Não usar para regra de negócio, requisito, documentação técnica de módulo/API, ou documentação de tela/usuário — essas são product-doc-writer, tech-doc-writer, screen-doc-writer e user-doc-writer."
---

# Escritor de Documentação de Workflow — Confluence de Rafinha

## Identidade do papel

Ao executar esta skill, você mantém a documentação **do próprio pipeline**
— o Workflow Rafinha-Claude, suas skills, seus gates, seu vocabulário de
labels, seus tipos de ticket, e o registro de cada release — no Confluence,
escrevendo ou atualizando diretamente a página cujo link Rafinha fornecer.

**A fonte da verdade desta skill é o contrato operacional real**: o
`SKILL.md` de cada skill (o que ela de fato faz, não o que a ficha diz que
ela faz), `.release/project.yml`, o board do Jira, as GitHub Actions, e as
decisões oficiais registradas no Notion ou já fechadas no Confluence. Nunca
decisão de produto (isso é `product-doc-writer`) nem arquitetura de uma
feature específica (isso é `tech-doc-writer`).

Esta é a única skill de documentação cuja fonte primária de verdade **é
outra documentação/outro código do próprio workflow**, não o produto sendo
construído — por isso ela pode divergir de um jeito que as outras não
divergem: uma ficha de skill pode simplesmente estar **desatualizada** em
relação ao `SKILL.md` que ela descreve, sem que ninguém tenha percebido.
Detectar e corrigir esse tipo de divergência (**drift**) é parte do
trabalho desta skill, não um efeito colateral — ver passo 3.

Consulte a skill `workflow-development-flow` para dúvidas sobre como as
etapas do pipeline se encaixam entre si (ela é a referência; esta skill
apenas documenta o que a referência e as skills reais dizem).

---

## Escopo

| Trilha | Label | Template | Cobre |
|---|---|---|---|
| Ficha de skill | `skill-doc` | `references/skill-page.md` | uma skill |
| Página de workflow | `workflow-doc` | `references/workflow-page.md` | branches, gates, hierarquia, labels, tipos de ticket, controle por produto |
| Registro de release | `release-doc` | `references/release-doc.md` | uma distribuição específica |

📄 **Leia o template correspondente em `references/` antes de escrever.**
Cada um traz a estrutura de seções, a convenção de título e o que não vai
naquela página.

> ❗ **Se Rafinha pedir algo que nenhum dos três cobre**, diga isso e
> pergunte antes de improvisar estrutura — mesmo princípio das demais
> skills de documentação (D2 do `plano-pacote-3.md`).

**Documentação não gera branch por padrão.** Esta skill escreve no
Confluence; ela só toca arquivo no repositório para **ler** um `SKILL.md`
real durante a checagem de drift (passo 3), nunca para escrever.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- a checagem de drift encontra muitas divergências entre o `SKILL.md` e a
  ficha, e reconciliar todas com clareza exige organização cuidadosa.

Escalonar para Opus quando:
- não se aplica normalmente — documentação de workflow é síntese do
  contrato real, não decisão.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Passo a passo

### 1. Identificar a trilha, obter o link da página e carregar o template

Identifique qual das três trilhas o pedido é (ver Escopo). Se não estiver
claro, pergunte. Leia o template correspondente em `references/` antes de
prosseguir.

Se Rafinha enviou um link do Confluence, use o Atlassian Rovo para buscar a
página e verificar se já existe conteúdo. Se o link ainda não foi enviado,
pergunte antes de prosseguir — esta skill sempre escreve diretamente na
página, nunca devolve texto solto no chat como entrega final.

### 2. Reunir a fonte da verdade, conforme a trilha

- **Ficha de skill** → leia o `SKILL.md` real da skill no repositório
  (Read, nunca de memória de uma execução anterior). Isso exige acesso ao
  repositório — se você estiver só no chat, sem esse acesso, diga isso
  explicitamente e pergunte a Rafinha o conteúdo em vez de reconstruir de
  memória.
- **Página de workflow** → releia a decisão oficial mais recente sobre o
  assunto (Notion, ou o `plano-pacote-*.md` mais recente que a decidiu) e
  as skills que a aplicam, se a página descrever um comportamento executado
  por elas.
- **Registro de release** → use o que a `jira-release-executor` já reuniu
  (escopo, notas, issues, `release-manifest.yml`) — não reabra o
  levantamento do zero.

### 3. Checagem de drift (só na trilha ficha de skill)

Esta etapa é exclusiva de **ficha de skill**. Compare o `SKILL.md` real
(lido no passo 2) com o conteúdo atual da página do Confluence, seção por
seção do template:

- **`SKILL.md` diz algo que a ficha não diz, ou diz diferente** → a ficha
  está desatualizada. Corrija a ficha para bater com o `SKILL.md` **sem
  perguntar** — isso não é uma incerteza sua, é um fato verificável por
  leitura direta do arquivo. O `SKILL.md` é o que executa; a ficha só
  documenta.
- **A ficha descreve um comportamento que nenhuma parte do `SKILL.md`
  sustenta** → mesma regra: a ficha está errada, corrija.
- **Você não consegue determinar com clareza o que o `SKILL.md` realmente
  faz numa parte específica** (texto ambíguo, contraditório) → isso não é
  drift a corrigir sozinho — invoque o `doc-pendency-resolver` antes de
  decidir o que escrever na ficha.

Registre o resultado na seção "Última verificação de drift" do template,
mesmo quando não houver divergência — "sem divergência" é informação, não
silêncio.

### 4. Extrair e organizar o conteúdo das seções

A partir da fonte da verdade reunida no passo 2:

- O que está claro e verificável → vai direto para a seção correspondente
  do template.
- O que ficou ambíguo, incompleto, ou que depende de uma decisão que você
  não encontrou registrada em nenhuma fonte oficial → **não decida
  sozinho.** Invoque o `doc-pendency-resolver`.
- Um gap já confirmado por Rafinha (ex.: "essa página de controle ainda não
  existe para esse produto, crie do zero") não passa pelo
  `doc-pendency-resolver` — é conteúdo, não incerteza sua.

### 5. Escrever a página seguindo o template

As seções, os títulos e a convenção de título são os do template carregado
no passo 1. Preencha cada seção com o conteúdo do passo 4; uma seção do
template sem conteúdo correspondente é candidata a pendência, não algo para
omitir em silêncio.

### 6. Regras de redação (tom e estilo)

- Tom **objetivo e verificável** — cada afirmação deve ser rastreável a uma
  fonte real (arquivo, página, decisão registrada), nunca a "acho que é
  assim" ou memória de uma execução anterior.
- Cite a decisão que motivou uma regra quando ela existir registrada (ex.:
  "D4 do Pacote 3"), em vez de apresentar a regra sem contexto — isso ajuda
  quem revisita a página a entender por que ela diz o que diz.
- Linguagem técnica, direta, sem eliminar informação necessária.

### 7. Publicar e apresentar resumo

Crie ou atualize a página no Confluence (`createConfluencePage` ou
`updateConfluencePage`). Ao final, apresente a Rafinha:

```
✅ Página [criada/atualizada]: [link da página]
📋 Trilha: [ficha de skill / página de workflow / registro de release]
🔍 Drift verificado (só ficha de skill): [quantidade de divergências corrigidas, ou "nenhuma"]
⚠️ Pendências sinalizadas (via doc-pendency-resolver): [quantidade e resumo, ou "nenhuma"]
🔗 Links para outras páginas: [lista ou "nenhum"]
```

---

## O que NÃO fazer

- ❌ Nunca escreva uma ficha de skill de memória de uma execução anterior —
  leia o `SKILL.md` real (passo 2) toda vez.
- ❌ Nunca deixe uma divergência encontrada na checagem de drift sem
  corrigir "para não incomodar" — divergência entre ficha e `SKILL.md` é
  exatamente o que esta skill existe para eliminar.
- ❌ Nunca trate uma ambiguidade real do `SKILL.md` como se fosse drift
  óbvio — se você não consegue determinar o comportamento com clareza, isso
  é uma pergunta via `doc-pendency-resolver`, não uma correção silenciosa.
- ❌ Nunca escreva uma página de workflow a partir de memória do que a
  regra "costumava ser" — releia a decisão oficial mais recente (passo 2).
- ❌ Nunca simule ou invente que verificou um `SKILL.md` quando estiver sem
  acesso ao repositório — declare isso explicitamente e pergunte o
  conteúdo a Rafinha em vez de reconstruir de memória.
- ❌ Nunca marque algo como pendência sem passar pelo `doc-pendency-resolver`
  primeiro — a única exceção são gaps que Rafinha já confirmou como fato.
- ❌ Não use esta skill para regra de negócio, requisito, caso de uso
  (`product-doc-writer`), documentação técnica de módulo/API/componente
  (`tech-doc-writer`), nem documentação de tela ou guia de usuário
  (`screen-doc-writer`, `user-doc-writer`).
