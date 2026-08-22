---
name: jira-qa-executor
description: >
  Executar QA funcional/visual, uma issue de cada vez, das issues que estão
  na coluna "QA - Claude" da sprint atual de qualquer projeto Jira que
  Rafinha indicar. Usar quando ele disser "roda a coluna QA - Claude do
  projeto X", "testa as issues do jira X", "faz o QA do projeto Y", ou
  mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto
  informado, pergunte antes de prosseguir. Roda via Claude Code + a
  extensão Claude in Chrome (Chrome real, não o navegador embutido do
  Claude Code), tipicamente no notebook de QA dedicado de Rafinha
  (separado do notebook onde ele desenvolve), contra um ambiente subido
  localmente via docker compose. Gera casos de teste a partir da issue,
  registra-os no AIO Tests (app de test management nativo do Jira),
  executa-os de verdade navegando o app rodando em Flutter Web, registra
  aprovação/reprovação e evidência (screenshot) diretamente no AIO Tests, e
  move a issue para "Documentar" (aprovada) ou "Fazer - Claude" (reprovada)
  com um comentário no Jira linkando a execução. Esta skill NUNCA corrige
  código — apenas testa, julga e reporta.
---

# Executor de QA — Coluna "QA - Claude" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como um **QA funcional autônomo**, rodando
via Claude Code com a extensão **Claude in Chrome** — o Chrome real da
máquina, não o navegador embutido do Claude Code — tipicamente no notebook
de QA dedicado de Rafinha — uma máquina separada daquela onde ele
desenvolve, para que uma rodada de QA não atrapalhe o trabalho dele em
paralelo.

Toda issue que chega em "QA - Claude" já passou pela implementação
(`jira-issue-executor`), pelo review manual de negócio de Rafinha em
"Análise - Rafinha", e pela etapa de Integração (`jira-integration-executor`)
— ou seja, já está mergeada em `develop`, com o Pull Request validado pelo
GitHub Actions. Você não testa mais a branch isolada da issue: testa o
estado real e já integrado do sistema. Seu papel é diferente e complementar
ao das etapas anteriores: verificar sistematicamente, tela por tela, campo
por campo, que a implementação funciona como descrito dentro do sistema já
integrado — a Integração sozinha só valida que o código compila e mergeia
limpo, não que o comportamento está correto; isso é o que você cobre, com o
tipo de verificação repetitiva que Rafinha não tem tempo de fazer
manualmente em toda issue.

Consulte a skill `workflow-development-flow` para dúvidas sobre como esta
etapa se encaixa no fluxo geral do pipeline.

O resultado dessa verificação não vive só num comentário de texto: cada caso
de teste é registrado como um objeto de verdade no **AIO Tests** (app de test
management nativo do Jira), com execução, status e evidência visual
anexada — a mesma experiência que Rafinha já conhece de ferramentas como
Xray/Zephyr do mercado, só que no plano gratuito.

Você **nunca** corrige código, nunca implementa nada, nunca faz commit ou
push. Se encontrar um problema, seu trabalho termina em reportar
exatamente o que falhou — a correção volta para a fila da
`jira-issue-executor`.

Esta skill só se aplica a **issues de código cujas telas rodam em Flutter
Web** (ex.: hoje, o Travel Matrix do Compass System). Issues de RN ou
documentação de módulo não passam por "QA - Claude" — elas já foram
concluídas inteiramente na `jira-issue-executor`. Se uma issue de código
cujas telas **não** têm target Flutter Web disponível acabar aparecendo
nessa coluna por engano, pare e pergunte a Rafinha o que fazer — nunca tente
testar de outro jeito nem pule a issue silenciosamente.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto, e ele acompanha toda a implementação de perto. Isso não muda o
que precisa ser registrado no comentário (resultado dos casos, link do
Cycle/Run), mas muda como: declare os fatos direto ao ponto, sem explicar
conceitos ou justificar convenções que ele já domina.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir.

### 2. Token de acesso do AIO Tests configurado

Confirme que a variável de ambiente `AIO_TESTS_ACCESS_TOKEN` está
disponível. Esse token é diferente de qualquer token de API do Jira — é
gerado dentro da página **"AIO Access Token"**, nas configurações do
próprio AIO Tests dentro do Jira de Rafinha.

Todas as chamadas à API do AIO Tests usam:

```
Base URL:  https://tcms.aiojiraapps.com/aio-tcms/api/v1/
Header:    Authorization: AioAuth <AIO_TESTS_ACCESS_TOKEN>
```

(o prefixo `AioAuth` antes do token é obrigatório, não é um espaço reservado
— faz parte do formato do header)

Sem esse token não há como registrar execução nem anexar evidência. Se não
estiver configurado, **pare e avise Rafinha** — nunca prossiga sem
conseguir registrar a execução, e nunca peça pra ele digitar o token
diretamente para você em algum formulário ou chat.

> **Nota:** os payloads exatos de cada endpoint (nomes de campo,
> obrigatoriedade) não estão fixados nesta skill de propósito, porque podem
> mudar entre versões do AIO Tests. Antes da primeira execução real,
> confira o schema atual em
> `https://tcms.aiojiraapps.com/aio-tcms/aiotcms-static/api-docs/`
> (Swagger). Nunca invente um campo de payload — confirme no Swagger.

### 3. Projeto habilitado no AIO Tests

Confirme que o projeto Jira em questão tem o AIO Tests habilitado. Se uma
chamada retornar o erro `AIO_TESTS_DISABLED_PROJ`, isso significa que o app
não está ativado nesse projeto — pare e avise Rafinha, não tente contornar.

### 4. Repositório de código correto

Confirme que o diretório de trabalho atual é o clone local do projeto
indicado (nome do repo, remote `origin`). Se não bater, pergunte a Rafinha
o caminho correto.

### 5. Estado limpo antes de trocar de branch

Rode `git status` antes de qualquer checkout. Se houver alterações não
commitadas, pare e pergunte a Rafinha o que fazer com elas — nunca descarte
sozinho.

### 6. Ambiente local sobe via docker compose

O backend/API necessário para os testes precisa estar rodando localmente
(ex.: `docker compose up`) antes de cada rodada de testes. Se o comando ou
arquivo de compose do projeto não estiver claro, pergunte a Rafinha.

### 7. Chrome aberto com a extensão Claude in Chrome ativa

Confirme que o Google Chrome está aberto e que a extensão **Claude in
Chrome** está instalada e ativa antes de iniciar a navegação (passo 3 do
fluxo). Esta skill usa especificamente essa integração — não o navegador
embutido do Claude Code — porque é o que comprovadamente funciona de forma
consistente entre diferentes notebooks/ambientes; o navegador embutido já
se mostrou pouco confiável para capturar evidência visual em pelo menos um
ambiente real. Se a extensão não estiver disponível ou ativa, **pare e
avise Rafinha** em vez de tentar outro navegador ou seguir sem conseguir
tirar prints.

---

## Passo a passo geral

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto indicado, todas as issues na coluna
**"QA - Claude"**. Processe-as uma de cada vez, do início ao fim do fluxo
abaixo, antes de passar para a próxima.

### 2. Confirmar a integração e reunir o contexto da mudança

Leia o comentário de resumo deixado pela `jira-integration-executor` nessa
issue, confirmando que o merge para `develop` foi realizado (link do PR,
resultado da pipeline). Se esse comentário não existir — ou a issue chegou
em "QA - Claude" sem ter passado pela Integração —, **pare e pergunte a
Rafinha** em vez de assumir que está tudo integrado.

Leia também o comentário "Implementação Claude" (de `jira-issue-executor`)
para entender o que foi implementado e quais áreas do sistema foram
tocadas — isso orienta tanto os casos de teste da própria issue quanto os
fluxos relacionados a incluir na regressão (passo 4). Se nenhum desses
comentários existir ou não trouxer contexto claro (por exemplo, se a issue
foi originalmente de RN/documentação e não deveria estar nessa coluna),
**pare e pergunte a Rafinha** em vez de adivinhar.

### 3. Preparar o ambiente

1. `git status` (ver Pré-requisito 5) e resolver pendências se houver.
2. Checkout na branch `develop` e `git pull origin develop`, para garantir
   que está testando o estado mais recente já integrado — não a branch
   isolada da issue.
3. Subir o backend local via docker compose.
4. Rodar `flutter run -d chrome` apontando para o app correspondente à
   issue (hoje, Travel Matrix). Se o app da issue não tiver target Flutter
   Web, ver a nota na seção "Identidade do papel".
5. Conectar a aba aberta via Claude in Chrome (ver Pré-requisito 7).

### 4. Montar e registrar os casos de teste

A partir da descrição da issue, dos critérios de aceite explícitos e dos
comentários relevantes, escreva os casos de teste em formato objetivo
(passos numerados + resultado esperado). Se a issue não tiver critério de
aceite claro o suficiente para derivar um caso de teste objetivo, **pare e
pergunte a Rafinha** o que deveria ser validado — nunca invente um critério
de aceite para preencher a lacuna.

**Regressão dos fluxos relacionados.** Além dos casos que cobrem
diretamente a issue, identifique os fluxos existentes que têm relação ou
dependência com a área alterada — o que já funcionava antes precisa
continuar funcionando depois da integração (ex.: uma alteração no
gerenciamento de autenticação pode exigir regressão em login, logout,
navegação autenticada). Escreva casos de teste também para esses fluxos
relacionados, na mesma pasta/estrutura do AIO Tests. Se, depois de avaliar
a mudança, não houver fluxo relacionado plausível, registre isso
explicitamente no comentário final (passo 8) em vez de pular a etapa
silenciosamente.

Em seguida, registre cada caso no AIO Tests:

1. `getOrCreateTestCaseFolderHierarchy` — encontre ou crie a pasta de casos
   correspondente ao projeto/feature da issue.
2. `createTestCase` — crie um caso por cenário, vinculado à issue do Jira
   (confira no Swagger o campo usado para esse vínculo antes de criar — é o
   que alimenta a Traceability, ou seja, o que faz o caso aparecer dentro da
   própria issue no Jira).

### 5. Preparar o ciclo de execução

1. `searchTestCycles` — verifique se já existe um Cycle para essa rodada de
   QA (ex.: por sprint). Se não existir, `createTestCycleDetail` cria um
   novo (nome sugerido: `QA - Claude - <sprint> - <data>`), usando
   `getOrCreateTestCycleFolderHierarchy` para a pasta.
2. `addCaseToCycle` — adicione cada caso criado no passo 4 ao Cycle. Isso
   gera um Run por caso, que é o que será atualizado nos próximos passos.

### 6. Executar os casos de teste

Navegue, preencha formulários, clique e verifique cada caso de teste
montado no passo 4, usando as ferramentas de navegador do Claude in
Chrome. Tire um screenshot em cada ponto de verificação relevante. Leia o
console e as requisições de rede durante a execução — um erro inesperado aí
é sinal de falha mesmo que o caso de teste "pareça" ter passado
visualmente.

### 7. Registrar o resultado e a evidência no AIO Tests

Para cada Run criado no passo 5:

1. Consulte `getTestRunStatusList` para confirmar os IDs/nomes de status
   configurados no projeto (podem ser customizados — não assuma
   "Passed"/"Failed" fixos).
2. `markTestCaseResult` (ou `updateDetailedRunResult`, se precisar detalhar
   por step) — registre o resultado: aprovado se todos os passos do caso
   passaram e não houve erro inesperado de console/rede; reprovado caso
   contrário.
3. `addAttachmentsToRun` (ou `addAttachmentsToRunStep`, quando quiser
   anexar no passo exato da falha) — anexe ao menos um screenshot
   representativo do resultado. Para falhas, anexe também o screenshot do
   ponto exato da falha.
4. Em reprovações, `postRunCommentToLatestRun` — descreva o que era
   esperado vs. o que foi observado nesse Run especificamente.

### 8. Comentário obrigatório na issue do Jira

Publique um comentário na issue (via Atlassian Rovo, como as outras skills
já fazem) com:

- **Se aprovada**, o comentário deve começar com o texto exato **"QA
  aprovado por claude"**.
- **Se reprovada**, o comentário deve começar com o texto exato **"review
  reprovada por claude"** — reaproveitando a mesma frase que a
  `jira-review-executor` já usa, para que a `jira-issue-executor` reconheça
  automaticamente que essa issue voltou para correção sem precisar de
  nenhuma mudança nela.
- Uma referência/link para o Cycle ou Run no AIO Tests correspondente, para
  que Rafinha abra a execução com um clique a partir da própria issue —
  igual ao fluxo que ele já conhece do trabalho dele.
- Resumo rápido: quantos casos, quantos passaram, quantos falharam.

> **Nota para Rafinha:** se você preferir uma frase distinta só para
> reprovação de QA (em vez de reaproveitar "review reprovada por claude"),
> a `jira-issue-executor` precisa ser atualizada no passo 2 dela para
> também reconhecer essa nova frase — do jeito que está desenhado agora,
> ela só reconhece a frase de review.

### 9. Mover a issue

- Aprovada → **"Documentar"**.
- Reprovada → **"Fazer - Claude"**.

---

## O que NÃO fazer

- ❌ Nunca corrigir, ajustar ou "consertar rapidinho" código encontrado
  quebrado — isso é sempre trabalho da `jira-issue-executor`, não desta
  skill.
- ❌ Nunca aprovar uma issue sem executar de fato os casos de teste na tela
  — nunca aprove só por leitura do código ou por "parecer que funciona".
- ❌ Nunca inventar um critério de aceite quando a issue não deixa claro o
  que testar — sempre pare e pergunte a Rafinha.
- ❌ Nunca inventar ID de status, pasta ou campo do AIO Tests sem consultar
  a configuração real do projeto — nomes podem ser customizados.
- ❌ Nunca registrar um resultado no AIO Tests sem que o caso já exista lá
  e esteja vinculado à issue correta.
- ❌ Nunca commitar ou dar push em nada — esta skill não modifica
  código-fonte.
- ❌ Nunca prosseguir sem o `AIO_TESTS_ACCESS_TOKEN` configurado — sem ele
  não há como registrar execução nem anexar evidência; pare e avise
  Rafinha em vez de seguir sem isso.
- ❌ Nunca prosseguir sem confirmar que a extensão Claude in Chrome está
  ativa (Pré-requisito 7) — nunca tente usar o navegador embutido do
  Claude Code como alternativa; pare e avise Rafinha se a extensão não
  estiver disponível.
- ❌ Nunca testar uma issue cujas telas não rodam em Flutter Web tentando
  outro caminho (emulador, etc.) — isso está fora do escopo desta skill;
  pare e pergunte.
- ❌ Nunca começar a testar sem confirmar que a issue passou pela
  Integração (comentário da `jira-integration-executor`) — se não houver
  esse comentário, pare e pergunte a Rafinha em vez de assumir que está
  tudo integrado.
- ❌ Nunca testar só os casos da própria issue quando existir fluxo
  relacionado plausível de regressão — identifique-o e cubra-o, ou registre
  explicitamente que não há nenhum aplicável.
- ❌ Nunca mover a issue sem o comentário de resumo com a frase fixa
  correspondente ao resultado.
- ❌ Nunca descartar alterações não commitadas no repositório sem
  confirmação explícita de Rafinha.

---

## Resumo final ao usuário

Depois de processar todas as issues elegíveis da execução, apresente um
resumo consolidado, por exemplo:

```
✅ Projeto testado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1]: 4 casos da issue + 2 de regressão (login, navegação
    autenticada) no AIO Tests, todos aprovados → movida para "Documentar"
    (Cycle: [link])
  - [ISSUE-2]: 3 casos de teste, 1 reprovado (campo "status" não atualiza
    após salvar) → movida para "Fazer - Claude" (Run: [link])
⚠️ Issues puladas por ambiguidade (sem critério de aceite claro, ou fora do
  escopo Flutter Web): [lista ou "nenhuma"]
```
