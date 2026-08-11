---
name: jira-review-executor
description: >
  Fazer uma segunda revisão (revisão do Claude) das issues que estão na
  coluna "Review - Claude" da sprint atual de qualquer projeto Jira que
  Rafinha indicar (ou que já esteja claro pelo contexto da conversa). Usar
  sempre que Rafinha disser algo como "revisa as issues do Jira X", "roda a
  coluna Review - Claude", "faz a revisão de review do projeto Y", ou
  mencionar explicitamente a coluna "Review - Claude" em qualquer contexto de
  Jira/Atlassian Rovo/Confluence. Esta skill NUNCA implementa código ou
  documentação — apenas revisa, comenta e move o ticket.
---

# Revisor de Issues — Coluna "Review - Claude" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como uma **segunda camada de revisão**.
Toda issue na coluna "Review - Claude" já passou por uma revisão manual de
Rafinha na coluna "em análise" (com um comentário "review aprovada por
rafinha") — mas pode haver pontos que ele não percebeu. Seu papel é
conferir cada issue dessa coluna com atenção e decidir se ela está
realmente pronta ou se precisa voltar para decisão de Rafinha.

Você **nunca** implementa código, nunca escreve documentação, nunca corrige
nada diretamente — apenas revisa, comenta e move o ticket para a coluna
correta.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto. Ele acompanha toda a implementação e entende a arquitetura
envolvida. Comentários de revisão continuam objetivos: declare o que foi
observado e, em caso de reprovação, a decisão que ele já tomou (passo 3b) —
sem explicar conceitos ou convenções que ele já domina.

---

## Onde esta skill se encaixa no fluxo completo

Esta é a última camada antes de "feito", num pipeline maior de colunas,
cada uma com sua própria skill:

```
Fazer - Claude (jira-issue-executor)  →  Em análise (review manual de Rafinha)
                                                 ↓
                     [issue de código]  ↓  [issue nativa de RN/documentação]
                          ↓                              ↓
                  QA - Claude (jira-qa-executor)          ↓
                          ↓ aprovado                      ↓
                Documentar (jira-doc-executor)            ↓
                          ↓                               ↓
                  Review - Claude (esta skill)          ←─┘
                          ↓
                        feito
```

Na prática, isso significa que uma issue pode chegar aqui por dois
caminhos: já tendo passado por QA funcional e por atualização de
documentação (issues de código), ou vindo direto de "Em análise" sem
passar por nenhuma das duas (issues nativas de RN/documentação, que já
tiveram sua página escrita ainda na `jira-issue-executor`). O passo 2
desta skill — checar se a documentação foi devidamente atualizada — vale
para os dois casos: no primeiro, é a `jira-doc-executor` quem já deveria
ter atualizado a página certa; no segundo, é a própria página criada pela
`business-rule-writer`/`module-doc-writer` lá atrás. Se algo estiver
faltando ou divergente em qualquer um dos dois casos, trate como qualquer
outra pendência (passo 3b) — o caminho de origem não muda o critério de
revisão.

---

## Pré-requisito: qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa (por exemplo, você
chamou esta skill dentro de uma conversa já focada em um projeto
específico), use esse projeto sem perguntar. Caso contrário, pergunte a
Rafinha explicitamente qual projeto/Jira revisar antes de prosseguir — nunca
assuma um projeto padrão.

---

## Passo a passo

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto identificado, todas as issues que estão
na coluna **"Review - Claude"**. Processe-as uma de cada vez.

### 2. Revisar cada issue por completo

Para cada issue, revise:

- **A descrição, a proposta e todos os comentários** presentes no ticket
  (incluindo o histórico de implementação), verificando se não ficou nenhuma
  ponta solta em relação ao que foi pedido.
- **Ambiguidades ou divergências entre o que foi feito e a documentação**
  (Confluence) relacionada — por exemplo, se a issue propôs algo que
  contraria o que já está documentado, ou se falta alguma informação crucial
  no que foi implementado frente ao que a documentação exige.
- **Se a documentação foi devidamente atualizada**, caso o escopo da issue
  exigisse isso.

### 3. Decidir o resultado da revisão

#### 3a. Issue aprovada (sem pendências)

Se não há nenhuma ponta solta ou pendência:

1. Comente na issue: **"claude review aprovado"**, com um breve resumo do
   que foi conferido.
2. Mova o ticket para **"feito"**.

#### 3b. Issue reprovada (há pendência ou necessidade de decisão)

Se há qualquer ponta solta, ambiguidade, divergência com a documentação, ou
documentação faltante:

1. **Antes de escrever qualquer comentário na issue**, pare o fluxo e
   pergunte a Rafinha, no chat, sobre a(s) pendência(s) encontrada(s) nessa
   issue especificamente — não acumule para o final, pergunte issue por
   issue, assim que uma reprovação é identificada. Para cada pendência,
   explique com clareza o que foi observado e pergunte objetivamente o que
   deve ser feito a respeito (ex.: qual das opções seguir, se é para
   corrigir de um jeito específico, ignorar, ajustar a documentação, etc.).
   Espere a resposta dele antes de prosseguir.
2. Só depois de ter a decisão de Rafinha, comente na issue descrevendo
   **o que foi revisado, qual a pendência encontrada, e a decisão que
   Rafinha já tomou a respeito** — de forma clara o suficiente para que,
   quando essa issue for para execução, não seja necessário reabrir a
   investigação nem adivinhar o que fazer.
3. O comentário deve começar com o texto exato **"review reprovada por
   claude"** (não altere essa frase — ela é usada por outra automação para
   identificar issues que precisam de correção).
4. Mova o ticket para **"Review - Rafinha"** — não para "a fazer" e não
   direto para a fila de execução do Claude, mesmo já havendo uma decisão
   registrada. É Rafinha quem confirma, nesse momento, se o comentário
   reflete corretamente sua decisão antes de mandar a issue para correção.

---

## O que NÃO fazer

- ❌ Nunca implementar código, corrigir documentação, ou fazer qualquer
  ajuste diretamente — mesmo que a pendência pareça pequena e rápida de
  resolver.
- ❌ Nunca mover uma issue reprovada para "a fazer" ou para a fila de
  execução do Claude diretamente — o destino de uma reprovação é sempre
  "Review - Rafinha".
- ❌ Nunca alterar o texto fixo **"review reprovada por claude"** no início
  do comentário de reprovação — outras automações dependem exatamente
  desse texto para funcionar.
- ❌ Nunca aprovar uma issue sem checar também a documentação relacionada,
  quando o escopo da issue envolvia documentação.
- ❌ Nunca pular a identificação do projeto/Jira quando não estiver claro
  pelo contexto.
- ❌ Nunca escrever o comentário de reprovação sem antes perguntar a
  Rafinha, no chat e issue por issue (nunca em lote no final), o que deve
  ser feito a respeito de cada pendência encontrada.

---

## Resumo final ao usuário

Depois de revisar todas as issues elegíveis, apresente a Rafinha um resumo
consolidado, por exemplo:

```
✅ Projeto revisado: [nome/chave do projeto]
📋 Issues revisadas: [quantidade]
  - [ISSUE-1]: aprovada → movida para "feito"
  - [ISSUE-2]: reprovada → movida para "Review - Rafinha" ([resumo curto da pendência])
```
