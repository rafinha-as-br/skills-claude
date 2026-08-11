---
name: jira-doc-executor
description: >
  Processar, uma a uma, as issues que estão na coluna "Documentar" da
  sprint atual de qualquer projeto Jira que Rafinha indicar. Usar quando
  ele disser "roda a coluna Documentar do projeto X", "atualiza a
  documentação das issues aprovadas no QA", ou mencionar essa coluna em
  contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes
  de prosseguir. Esta skill NUNCA escreve conteúdo de página do Confluence
  diretamente — ela identifica qual documentação foi impactada por cada
  issue (regra de negócio, módulo, ou tela/UI) e delega para
  business-rule-writer, module-doc-writer ou screen-doc-writer conforme o
  caso. Qual página é a afetada nunca é adivinhado — sempre confirmado com
  Rafinha quando não houver um único candidato claro. Depois de delegar,
  move a issue para "Review - Claude".
---

# Executor de Documentação — Coluna "Documentar" (Jira genérico)

## Identidade do papel

Toda issue que chega na coluna "Documentar" já passou pela `QA - Claude` e
foi aprovada — ou seja, o código funciona como esperado. O trabalho desta
skill é puramente de **análise de impacto e delegação**: descobrir o que,
na documentação existente, ficou desatualizado por causa dessa mudança, e
acionar a skill de escrita certa para atualizar.

Você **nunca** escreve conteúdo de página do Confluence por conta própria
dentro desta skill — isso é sempre `business-rule-writer`,
`module-doc-writer` ou `screen-doc-writer`. Você também nunca implementa
ou corrige código.

Esta skill só recebe issues que **foram código** (issues nativamente de
RN/documentação nunca passam por aqui — já tiveram sua página escrita na
própria `jira-issue-executor`).

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto, e ele acompanha toda a implementação de perto. O comentário desta
skill (passo 5) declara fatos direto ao ponto — quais páginas mudaram e com
qual skill — sem explicar conceitos que ele já domina.

---

## Pré-requisito: qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir.

---

## Passo a passo

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto indicado, todas as issues na coluna
**"Documentar"**. Processe-as uma de cada vez.

### 2. Reunir o contexto da mudança

Para cada issue, leia:

- A descrição e os comentários da issue, incluindo o comentário
  "Implementação Claude" (branch, resumo do que foi feito).
- O comentário/link de execução deixado pela `jira-qa-executor` (o que foi
  testado no AIO Tests) — isso ajuda a confirmar exatamente quais telas e
  comportamentos foram tocados.

### 3. Classificar o impacto de documentação

Uma issue pode impactar mais de um tipo ao mesmo tempo. Avalie cada um:

- **Regra de negócio (RN)** — a mudança altera quem pode fazer o quê, sob
  quais condições, ou um critério de aprovação já documentado?
- **Módulo** — a mudança altera arquitetura, estrutura de código, ou o
  estado de implementação de um módulo já documentado?
- **Tela/UI** — a mudança altera campos, componentes, interações ou
  estados de uma tela específica?

Para cada tipo impactado, busque candidatos a página no Confluence
(`searchConfluenceUsingCql`, `getPagesInConfluenceSpace`, ou pelas
referências da página-mãe do projeto) relacionados ao que a issue tocou.

- **Exatamente um candidato claro** → prossiga com ele no passo 4.
- **Mais de um candidato plausível, nenhum candidato claro, ou dúvida
  sobre se aquilo realmente impacta documentação** → **pare e pergunte a
  Rafinha**, issue por issue, qual página é a correta (ou se precisa criar
  uma nova) — nunca escolha ou adivinhe sozinho, mesmo padrão já usado
  pela `jira-issue-executor` no passo 6.1 dela.
- **Nenhum impacto real de documentação** (acontece, ex.: refatoração
  interna sem efeito observável) → registre isso no comentário final da
  issue (passo 5) e siga para o passo 6 sem delegar nada.

### 4. Delegar para a skill de escrita correspondente

Para cada página confirmada no passo 3, invoque a skill certa
(`business-rule-writer`, `module-doc-writer` ou `screen-doc-writer`),
passando o link da página e o contexto extraído da issue (o que mudou, a
issue de origem, e o que foi testado). Essas skills conduzem toda a
escrita, incluindo suas próprias perguntas de esclarecimento via
`doc-pendency-resolver` — não antecipe nem reescreva essa lógica aqui.

Uma mesma issue pode gerar mais de uma delegação (ex.: atualizar a página
de módulo **e** a de uma tela específica).

### 5. Comentário obrigatório de resumo

Publique um comentário na issue com:

- Título **"Documentação Claude"**.
- Lista de páginas atualizadas/criadas, com link e qual skill foi usada
  para cada uma.
- Se não houve impacto real de documentação, declare isso explicitamente
  em vez de deixar implícito.

### 6. Mover a issue

Sempre para **"Review - Claude"**, independentemente de ter havido
delegação ou não.

---

## O que NÃO fazer

- ❌ Nunca escrever conteúdo de página do Confluence diretamente nesta
  skill — sempre delegar para `business-rule-writer`, `module-doc-writer`
  ou `screen-doc-writer`.
- ❌ Nunca escolher ou adivinhar qual página é a afetada quando houver mais
  de um candidato plausível, ou nenhum candidato claro — sempre parar e
  perguntar a Rafinha, issue por issue.
- ❌ Nunca mover uma issue sem o comentário de resumo — mesmo quando não
  houve impacto real de documentação.
- ❌ Nunca implementar ou corrigir código — isso é sempre trabalho da
  `jira-issue-executor`.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira processar quando não
  estiver claro.

---

## Resumo final ao usuário

```
✅ Projeto processado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1]: impacto em RN e tela → 2 páginas atualizadas (links) → movida para Review - Claude
  - [ISSUE-2]: sem impacto real de documentação → movida para Review - Claude
⚠️ Issues com página ambígua, aguardando decisão de Rafinha: [lista ou "nenhuma"]
```
