---
name: jira-doc-executor
description: "Processar, uma a uma, as issues que estão na coluna \"Documentar\" da sprint atual de qualquer projeto Jira que Rafinha indicar. Usar quando ele disser \"roda a coluna Documentar do projeto X\", \"atualiza a documentação das issues aceitas\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. A coluna Documentar fica DEPOIS de \"Análise Final - Rafinha\" e ANTES de \"Análise Final - Claude\": a issue que chega aqui já foi testada no QA e já foi ACEITA por Rafinha, então a documentação descreve o estado aceito, não apenas o testado. IGNORA obrigatoriamente issues com a label `validacao-humana`. É a ORQUESTRADORA da documentação: nunca escreve conteúdo, monta um CONJUNTO DE DELEGAÇÕES por issue entre os cinco writers (product-doc-writer, tech-doc-writer, screen-doc-writer, user-doc-writer, workflow-doc-writer), porque documentar é trabalho composto — uma issue que muda uma tela pode atualizar a página do módulo, a página da tela e o guia de usuário ao mesmo tempo. TRILHA A (issue do tipo Documentação): a label documental declara o writer, pela tabela de roteamento da workflow-development-flow §3.3 — sem label de trilha, pergunta e nunca infere pelo conteúdo; `qa-doc` não tem writer e para. TRILHA B (issue de código — Implementação, Correção, Bug, Refatoração Técnica): análise de impacto writer por writer, declarando quais se aplicam E quais foram pulados e por quê — nenhum writer é pulado em silêncio. Imprime o plano do conjunto antes de delegar, e delega em ordem (produto → técnico → tela → usuário), porque o guia linka páginas de tela que precisam existir antes. Qual página é a afetada nunca é adivinhado — sempre confirmado com Rafinha quando não houver um único candidato claro. Depois de delegar, move a issue para \"Análise Final - Claude\"."
---

# Executor de Documentação — Coluna "Documentar" (Jira genérico)

## Identidade do papel

Toda issue que chega na coluna "Documentar" já passou pela `QA - Claude`
**e pela aceitação funcional de Rafinha em `Análise Final - Rafinha`** — ou
seja, o código funciona como esperado **e foi aceito como produto**. O
trabalho desta skill é puramente de **análise de impacto e orquestração**:
descobrir o que, na documentação existente, ficou desatualizado por causa
dessa mudança, e montar o **conjunto** de writers que atualiza cada parte.

> **`Documentar` fica depois da aceitação.** Consequência prática: a
> documentação descreve o **estado aceito**, não apenas o estado testado. Se
> algo foi ajustado entre o QA e a aceitação, é o resultado aceito que vale.

Você **nunca** escreve conteúdo de página do Confluence por conta própria
dentro desta skill. Você também nunca implementa ou corrige código.

Issues do tipo Documentação cuja página já foi escrita na própria
`jira-issue-executor` (passo 6 dela) não precisam de nova delegação aqui —
confirme pelo comentário "Implementação Claude" e siga para o passo 5.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização. O comentário desta skill (passo 5) declara
fatos direto ao ponto — quais páginas mudaram, com qual skill, e quais
writers foram pulados e por quê — sem explicar conceitos que ele já domina.

---

## Documentar é trabalho composto

Não existe "qual writer" — existe **"quais writers, e o que cabe a cada
um"**. Cada writer escreve só o que a sua fonte da verdade entrega, e linka
em vez de repetir. As granularidades são diferentes, por isso o fan-out real
é pequeno: documentar uma tela nova **atualiza** a página do módulo que já
existe e **entra** no guia que já existe, enquanto cria a página da tela.

| Writer | Fonte da verdade | Uma página por... | Entra no conjunto quando... |
|---|---|---|---|
| `product-doc-writer` | decisão de produto | regra, requisito, caso de uso, fluxo | a mudança altera quem pode o quê, sob quais condições, ou um critério já documentado |
| `tech-doc-writer` | o código | **módulo** (e API, arquitetura, componente) | a mudança altera arquitetura, camadas, contrato de API, componente reutilizável, ou o estado de implementação de um módulo documentado |
| `screen-doc-writer` | a tela rodando | **tela** | a mudança altera campos, botões, mensagens, estados, rota, cubit ou chamadas de uma tela específica |
| `user-doc-writer` | o produto funcionando, via páginas de tela | **tarefa** que atravessa telas | a mudança altera como o usuário executa uma tarefa de ponta a ponta |
| `workflow-doc-writer` | o contrato operacional (skills, Jira, Actions) | skill, regra de pipeline, release | a issue é sobre o próprio workflow — raro em projeto de produto |

Referência completa do modelo: `plano-pacote-3.md`, decisão D3.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o conjunto de delegações não é óbvio (vários writers candidatos, várias
  páginas candidatas por writer), exigindo análise cuidadosa antes de
  confirmar com Rafinha.

Escalonar para Opus quando:
- não se aplica normalmente — esta skill só analisa impacto e delega, nunca
  escreve conteúdo nem decide sozinha uma ambiguidade real (isso vai para
  Rafinha, não para um modelo mais caro).

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisito: qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir.

## Recovery Check (Execution State)

Antes de processar uma issue (passo 2), verifique se existe
`.claude/execution-state/{CHAVE}.md` — útil sobretudo porque uma issue
costuma gerar mais de uma delegação (passo 4) e a execução pode ser
interrompida no meio do conjunto. Arquivo **local, nunca commitado** (esta
etapa não trabalha em branch isolada). Ver `workflow-development-flow`,
seção 13, para o mecanismo completo.

---

## Passo a passo

### 1. Localizar as issues elegíveis e decidir a trilha

Busque, na sprint atual do projeto indicado, todas as issues na coluna
**"Documentar"**. Processe-as uma de cada vez.

**Exclusão obrigatória — issues de validação.** Ignore qualquer issue que
tenha a label **`validacao-humana`**. A issue do tipo `Validação Humana`
nasce em `Análise Final - Rafinha` e vai direto para `Concluído`. Se uma
aparecer aqui, é engano de movimentação — **não a documente e não a mova**;
registre a observação para Rafinha.

> A exclusão é **pela label**, nunca pelo tipo do ticket. Os projetos são
> team-managed e o tipo pode não existir num projeto novo; a label
> `validacao-humana` é o contrato legível por máquina.

| Tipo do ticket | Trilha |
|---|---|
| **Documentação** | **A** — a label declara o writer |
| **Implementação**, **Correção**, **Bug**, **Refatoração Técnica** | **B** — análise de impacto |

#### Trilha A — issue nativa de documentação

A label documental declara o writer, pela **tabela de roteamento** da
`workflow-development-flow`, seção 3.3 — ela é a única fonte dessa tabela;
não a reproduza aqui de memória. Uma issue com mais de uma label documental
gera uma delegação por label.

- **Sem label de trilha** → **pergunte a Rafinha** antes de prosseguir. Não
  infira pelo conteúdo. A label `confluence` é destino/meio e não resolve a
  escolha.
- **`architecture-doc`** → o writer depende da fonte da verdade (decisão de
  produto → `product-doc-writer`; estrutura de código → `tech-doc-writer`).
  Se a issue não deixar claro, pergunte.
- **`qa-doc`** → **não tem writer** (pendência aberta da atualização de
  origem). Não delegue para writer nenhum por aproximação: registre no
  comentário que a trilha não tem destino operacional e deixe a issue para
  decisão de Rafinha, sem mover.
- **`readme` / `adr`** → vão para `tech-doc-writer`, que declara que não há
  template e pergunta. Isso é esperado — não é motivo para você escolher
  outro writer.

A Trilha A **não** dispensa o bom senso do conjunto: se a label é
`screen-doc` e a página da tela alimenta um guia existente, mencione o guia
no plano (passo 3) como candidato — mas só delegue para ele com confirmação
de Rafinha, porque a label não o declarou.

#### Trilha B — issue de código que impactou documentação

A análise de impacto do passo 3 roda por completo, writer por writer. As
labels documentais que por acaso estiverem numa issue de código **reduzem
a inferência, mas não eliminam a análise** — uma issue de código pode
afetar trilhas que nenhuma label declarou.

### 2. Reunir o contexto da mudança

Para cada issue, leia:

- A descrição e os comentários da issue, incluindo o comentário
  "Implementação Claude" (branch, arquivos/módulos tocados, resumo).
- O comentário/link de execução deixado pela `jira-qa-executor` (o que foi
  testado no AIO Tests) — isso ajuda a confirmar exatamente quais telas e
  comportamentos foram tocados.
- Se a issue alterou uma tela, quais tarefas de usuário passam por ela
  (guias existentes que linkam a página daquela tela).

### 3. Montar o plano do conjunto de delegações

Percorra **os cinco writers**, na ordem da tabela "Documentar é trabalho
composto", e para cada um decida: **aplica** ou **não aplica**, com o
motivo. Nenhum writer sai do plano sem motivo declarado — é o mesmo
princípio do "proibido fallback silencioso" aplicado à documentação.

Para cada writer que aplica, busque as páginas candidatas no Confluence
(`searchConfluenceUsingCql`, `getPagesInConfluenceSpace`, ou pelas
referências da página-mãe do produto):

- **Exatamente um candidato claro** → entra no plano.
- **Mais de um candidato plausível, nenhum candidato claro, ou dúvida sobre
  se aquilo realmente impacta a documentação** → **pare e pergunte a
  Rafinha** qual página é a correta, ou se precisa criar uma nova. Nunca
  escolha ou adivinhe sozinho.
- **Página nova** → informe a página-mãe onde ela vai nascer. Se o mapa de
  taxonomia da página de Controle de workflow do produto declara a
  página-mãe daquele tipo, use; se não declara, pergunte.

Para `screen-doc-writer`, o plano **não decide o modo** (`dev`/`user`/
`hybrid`) — a própria skill confirma o modo. Se a página já existe, o modo
é o que está nela.

Imprima o plano antes de delegar:

```
📚 Plano de documentação — [ISSUE-KEY] (Trilha A|B)
| Writer              | Aplica? | Página                      | Motivo |
|---------------------|---------|-----------------------------|--------|
| product-doc-writer  | não     | —                           | nenhuma regra de negócio mudou |
| tech-doc-writer     | sim     | Módulo - Viagens (atualizar)| novo cubit no módulo |
| screen-doc-writer   | sim     | Tela - Cadastro (atualizar) | campo novo |
| user-doc-writer     | sim     | Guia - Cadastrar viagem     | a tarefa ganhou um passo |
| workflow-doc-writer | não     | —                           | issue de produto |
```

Se o plano tiver alguma página a confirmar, pergunte antes de delegar
qualquer coisa. Se estiver processando várias issues e restar mais de uma
dúvida, agrupe as perguntas numa rodada só.

**Nenhum impacto real de documentação** (acontece, ex.: refatoração interna
sem efeito observável) → o plano mostra os cinco writers como "não aplica",
cada um com motivo, e a issue segue para o passo 5 sem delegação.

### 4. Delegar, em ordem

Delegue na ordem abaixo — ela não é estética, é dependência:

1. **`product-doc-writer`** — as outras páginas linkam a RN, não o
   contrário.
2. **`tech-doc-writer`** — independente da tela; inclua quais
   arquivos/módulos de código foram tocados (do comentário "Implementação
   Claude"), para ela avaliar também a pasta `docs/` do módulo
   (responsabilidade dela, não sua).
3. **`screen-doc-writer`** — precisa rodar **antes** do guia.
4. **`user-doc-writer`** — lê as páginas de tela publicadas no item 3 e
   linka para elas. Se a tela ainda não foi publicada, ele declara a
   dependência em vez de observar a UI por conta própria.
5. **`workflow-doc-writer`** — quando aplicável; independente dos demais.

Para cada delegação, passe o link da página (ou da página-mãe, se nova), e
o contexto extraído da issue: o que mudou, a issue de origem, o que foi
testado no QA, e **o plano do conjunto** — para que cada writer saiba que as
outras partes estão sendo escritas por outra skill e linke em vez de
repetir. Os writers conduzem toda a escrita, incluindo suas próprias
perguntas via `doc-pendency-resolver` — não antecipe nem reescreva essa
lógica aqui.

*Checkpoint:* ao concluir cada delegação, atualize
`.claude/execution-state/{CHAVE}.md` com as delegações já concluídas e as
que faltam — se a execução for interrompida no meio do conjunto, a próxima
sessão retoma só as pendentes, na mesma ordem.

### 5. Comentário obrigatório de resumo

Publique um comentário na issue com:

- Título **"Documentação Claude"**.
- Trilha (A ou B).
- O plano executado: para cada um dos cinco writers, a página
  criada/atualizada (com link) **ou** o motivo de não ter sido aplicado.
- Se não houve impacto real de documentação, declare isso explicitamente
  em vez de deixar implícito.

### 6. Mover a issue

Sempre para **"Análise Final - Claude"**, independentemente de ter havido
delegação ou não — **exceto** a issue `qa-doc` sem destino (passo 1), que
fica parada para decisão de Rafinha. Apague
`.claude/execution-state/{CHAVE}.md` se existir — o comentário no Jira e as
páginas do Confluence já são o registro permanente a partir daqui.

Lá a `jira-review-executor` faz a auditoria final — incluindo verificar se
a documentação ficou consistente com a entrega aceita.

A Validação Humana Agregada acontece **antes** desta etapa, na coluna
`Análise Final - Rafinha`. Não crie nem proponha Validação Humana aqui.

---

## O que NÃO fazer

- ❌ Nunca escrever conteúdo de página do Confluence diretamente nesta
  skill — sempre delegar para um dos cinco writers.
- ❌ Nunca tirar um writer do plano sem motivo declarado — "não aplica" sem
  motivo é fallback silencioso.
- ❌ Nunca delegar `qa-doc` para um writer por aproximação — a trilha não
  tem destino, e isso se declara, não se contorna.
- ❌ Nunca inferir o writer de uma issue do tipo Documentação pelo conteúdo
  quando falta a label de trilha — pergunte.
- ❌ Nunca decidir o modo da `screen-doc-writer` — ela confirma o modo.
- ❌ Nunca delegar o guia (`user-doc-writer`) antes da página de tela da
  qual ele depende.
- ❌ Nunca escolher ou adivinhar qual página é a afetada quando houver mais
  de um candidato plausível, ou nenhum candidato claro.
- ❌ Nunca mover uma issue sem o comentário de resumo — mesmo quando não
  houve impacto real de documentação.
- ❌ Nunca implementar ou corrigir código — isso é sempre trabalho da
  `jira-issue-executor`.
- ❌ Nunca commitar `.claude/execution-state/{CHAVE}.md` — o arquivo é
  sempre local (ver seção 13.3 de `workflow-development-flow`).
- ❌ Nunca confiar cegamente num Execution State encontrado — sempre
  reconciliar com o estado real do Confluence/Jira antes de continuar.

---

## Resumo final ao usuário

```
✅ Projeto processado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1] (B): módulo + tela + guia → 3 páginas (links); product e workflow não aplicam → movida para Análise Final - Claude
  - [ISSUE-2] (A, rn-doc): product-doc-writer → 1 página (link) → movida para Análise Final - Claude
  - [ISSUE-3] (B): sem impacto real de documentação (5 writers com motivo) → movida para Análise Final - Claude
⚠️ Aguardando decisão de Rafinha: [issues com página ambígua, sem label de trilha, ou qa-doc — ou "nenhuma"]
```
