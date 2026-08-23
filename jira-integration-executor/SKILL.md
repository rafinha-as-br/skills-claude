---
name: "jira-integration-executor"
description: "Executar a etapa \"Integração\" do Workflow Rafinha-Claude — mergear de verdade issues aprovadas na coluna \"Integração\" para a branch develop, validando antes o GitHub Actions do Pull Request e a ausência de conflitos. Usar quando Rafinha disser \"roda a Integração do projeto X\", \"processa a coluna Integração\", \"faz o merge das issues aprovadas\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. Opera só sobre issues que já passaram por Análise - Rafinha, com Pull Request já aberto por jira-issue-executor. Sequência obrigatória: confirma PR existente → verifica GitHub Actions (bloqueia avanço se falhar) → verifica merge limpo com develop (resolve conflito mecânico sozinha, para em conflito semântico e devolve para Análise - Rafinha) → merge real para develop → move para QA - Claude. Nunca usa git push --force nem rebase. Herda as regras de segurança de jira-issue-executor."
---

---
name: jira-integration-executor
description: "Executar a etapa \"Integração\" do Workflow Rafinha-Claude — mergear de verdade issues aprovadas na coluna \"Integração\" para a branch develop, validando antes o GitHub Actions do Pull Request e a ausência de conflitos. Usar quando Rafinha disser \"roda a Integração do projeto X\", \"processa a coluna Integração\", \"faz o merge das issues aprovadas\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. Opera só sobre issues que já passaram por Análise - Rafinha, com Pull Request já aberto por jira-issue-executor. Sequência obrigatória: confirma PR existente → verifica GitHub Actions (bloqueia avanço se falhar) → verifica merge limpo com develop (resolve conflito mecânico sozinha, para em conflito semântico e devolve para Análise - Rafinha) → merge real para develop → move para QA - Claude. Nunca usa git push --force nem rebase. Herda as regras de segurança de jira-issue-executor."
---

# Executor de Integração — Coluna "Integração" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como o responsável pela etapa de
**Integração** do Workflow Rafinha-Claude, rodando via **Claude Code**, no
mesmo repositório real de Rafinha usado por `jira-issue-executor`.

Diferente das demais skills do pipeline, esta é a única que **realiza merge
de verdade** para a branch `develop` — não apenas commit e push numa branch
isolada. Essa responsabilidade é nova: antes, o merge sempre dependia de
Rafinha abrir e mergear o Pull/Merge Request manualmente. A partir desta
skill, você mesma mergeia, depois de validar que o Pull Request já existe,
que o GitHub Actions passou, e que não há conflito não resolvido com a
`develop`.

Você **herda as mesmas regras de segurança de `jira-issue-executor`**:
nunca `git push --force` ou `--force-with-lease`; nunca descarta trabalho
não commitado sem perguntar a Rafinha; sempre roda `git status` antes de
qualquer checkout; nunca commita direto em `main` ou `develop` fora do
merge desta própria etapa.

Consulte a skill `workflow-development-flow` sempre que tiver dúvida sobre
como esta etapa se encaixa no fluxo geral, sobre as camadas de validação, ou
sobre a integração GitHub Issues ↔ Jira ↔ Pull Request.

**Pré-requisito de pipeline.** Todo projeto integrado a este workflow já
deve ter GitHub Actions configurado — isso é garantido por Rafinha, não é
responsabilidade desta skill criar a pipeline do zero. Se, excepcionalmente,
um projeto não tiver GitHub Actions configurado, **pare e avise Rafinha**
em vez de tentar montar uma pipeline sozinha.

Use o Atlassian Rovo para toda a interação com o Jira (busca de issues,
leitura/criação de comentários, transições de status) e `gh` (GitHub CLI)
ou equivalente para interação com Pull Requests e GitHub Actions.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o merge encontra conflito não-trivial, exigindo entender a lógica de
  ambos os lados antes de decidir se é mecânico ou semântico.

Escalonar para Opus quando:
- (raramente necessário aqui) um conflito semântico já tem válvula
  própria no fluxo — a skill para e devolve a issue para "Análise -
  Rafinha" em vez de tentar resolver sozinha; não é preciso chegar a
  recomendar Opus para isso.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa, use-o sem
perguntar. Caso contrário, pergunte a Rafinha explicitamente antes de
prosseguir — não assuma que é o mesmo projeto de uma execução anterior a
menos que ele confirme.

### 2. Repositório de código correto

Antes de qualquer operação git, confirme que o diretório de trabalho atual
é de fato o repositório do projeto indicado (nome do repo, remote
`origin`, ou o que estiver disponível para conferir). Se não estiver claro
ou não bater com o projeto esperado, pergunte a Rafinha o caminho correto
antes de prosseguir — nunca assuma um repositório errado silenciosamente.

### 3. Estado limpo antes de trocar de branch

Antes de dar checkout em qualquer branch (existente ou nova), rode
`git status`. Se houver alterações não commitadas no diretório de
trabalho:
- Pare e pergunte a Rafinha o que fazer com elas (commitar, descartar, ou
  deixar por conta dele) antes de continuar.
- **Nunca** descarte (`git checkout --`, `git reset --hard`, `git stash`
  seguido de esquecimento, etc.) alterações não commitadas sem confirmação
  explícita dele.

---

## Passo a passo geral

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto indicado, todas as issues que estão na
coluna **"Integração"** (via `searchJiraIssuesUsingJql` ou equivalente,
filtrando por status/coluna e sprint ativa). Essas issues chegaram aqui só
depois de `Análise - Rafinha` aprovada — o Pull Request já foi aberto por
`jira-issue-executor` durante a `Fazer - Claude`. Processe-as **uma de cada
vez**, do início ao fim do fluxo abaixo, antes de passar para a próxima.

### 2. Confirmar que o Pull Request já existe

Localize o PR associado à issue (pela branch `{tipo}/{CHAVE}-claude`, ou
pelo link registrado na issue). Ele deve ter sido aberto na etapa
`Fazer - Claude` — esta skill nunca abre um PR do zero.

- **PR existe** → siga para o passo 3.
- **PR não existe** → **pare e avise Rafinha**, tanto no comentário da
  issue quanto no resumo final. Não abra o PR você mesma — isso indica algo
  fora do fluxo esperado (ex.: issue movida manualmente para Integração sem
  passar por `Fazer - Claude`).

### 3. Verificar o GitHub Actions do PR

O PR já deve estar rodando (ou já ter rodado) o GitHub Actions desde a
`Fazer - Claude`/`Análise - Rafinha` — esta é a segunda camada de
validação, independente do ambiente local do Claude (ver
`workflow-development-flow`, seção de camadas de validação).

- **Ainda rodando** → aguarde a conclusão antes de prosseguir.
- **Passou** → siga para o passo 4.
- **Falhou** → leia o log da execução (`gh run view` ou equivalente),
  corrija localmente o que estiver causando a falha, commite, dê
  `git push` (dispara uma nova rodada da pipeline), e repita este passo até
  passar. **Falha aqui é bloqueio de avanço, nunca só diagnóstico** — a
  issue não segue para o passo 4 sem a pipeline verde.

### 4. Verificar se a branch mergeia limpo com a `develop`

1. `git fetch origin`.
2. Checkout na branch da issue.
3. `git merge origin/develop` — **nunca `git rebase`**. Rebase reescreveria
   os commits já enviados ao remoto e exigiria `push --force` depois, o que
   é proibido pelas regras de segurança herdadas de `jira-issue-executor`.

Resultado:

- **Sem conflito** → siga para o passo 5.
- **Conflito mecânico** (trechos diferentes do mesmo arquivo, sem
  contradição de fato — formatação, import, adições que não se sobrepõem)
  → resolva sozinha, registrando no comentário da issue exatamente o que
  foi reconciliado.
- **Conflito semântico real** (duas implementações incompatíveis da mesma
  lógica) → **pare e pergunte a Rafinha**, mostrando os trechos em
  conflito, antes de decidir qual versão prevalece ou como combiná-las.

Depois de qualquer resolução de conflito (mecânica ou semântica):
- `git push` normal (**nunca `--force`**).
- Isso **sempre volta para o passo 3** — a pipeline precisa rodar de novo e
  passar antes de prosseguir, independente do tipo de conflito resolvido.
- **Se o conflito foi semântico** (envolveu decisão de Rafinha durante a
  resolução): além de revalidar a pipeline, **mova a issue de volta para
  `Análise - Rafinha`** — uma nova rodada completa de revisão humana antes
  de seguir para o merge, mesmo que a pipeline passe. Registre no
  comentário o que mudou e por quê. Isso vale mesmo quando a resolução já
  teve a participação pontual de Rafinha: uma revisão formal de novo é o
  que garante identificar se algo passou despercebido na aprovação
  original. Ao mover de volta, **encerre esta execução para essa issue** —
  ela só retorna para `Integração` depois de uma nova aprovação.

### 5. Realizar o merge para `develop`

Só depois dos passos 3 e 4 totalmente resolvidos (e, se aplicável, depois
da nova `Análise - Rafinha` do passo 4). Faça o merge da branch da issue
para `develop` e envie (`git push origin develop`).

### 6. Registrar o resultado

Monte um resumo objetivo e publique como comentário na própria issue. O
comentário deve conter:

- Link/número do Pull Request.
- Resultado final do GitHub Actions (passou, e se houve correções no
  caminho).
- Se houve conflito: tipo (mecânico/semântico), o que foi reconciliado, e
  se a issue precisou voltar para `Análise - Rafinha`.
- Confirmação do merge realizado (branch → `develop`).

### 7. Mover a issue para o status correto

- Merge realizado com sucesso → mova para **"QA - Claude"**.
- Issue devolvida por conflito semântico (passo 4) → mova para
  **"Análise - Rafinha"** em vez de QA - Claude.
- Issue com PR ausente (passo 2) ou GitHub Actions sem configuração
  (pré-requisito) → **não mova**, deixe onde está, e destaque isso no
  resumo final.

---

## O que NÃO fazer

- ❌ Nunca usar `git push --force` ou `--force-with-lease` — se o push
  normal for rejeitado por divergência, pare e avise Rafinha em vez de
  forçar.
- ❌ Nunca usar `git rebase` para reconciliar com a `develop` — sempre
  `git merge origin/develop`.
- ❌ Nunca avançar para o merge (passo 5) sem o GitHub Actions verde —
  falha na pipeline é sempre bloqueio, nunca diagnóstico a ser ignorado.
- ❌ Nunca resolver um conflito semântico sozinha — sempre parar e mostrar
  os trechos em conflito a Rafinha antes de decidir qual versão prevalece.
- ❌ Nunca pular a devolução para `Análise - Rafinha` depois de resolver um
  conflito semântico, mesmo que a pipeline passe depois — essa revisão
  humana extra é obrigatória, não opcional.
- ❌ Nunca abrir um Pull Request nesta skill — se o PR não existir, pare e
  avise Rafinha em vez de criar um.
- ❌ Nunca criar uma pipeline de GitHub Actions do zero para um projeto que
  não tenha uma — pare e avise Rafinha.
- ❌ Nunca dar checkout em outra branch, ou criar uma nova, sem antes
  checar `git status` e resolver alterações não commitadas com Rafinha.
- ❌ Nunca declarar que "o aplicativo inteiro" está livre de problemas —
  esta etapa valida só a integração técnica; a validação funcional ampla é
  do QA - Claude.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira processar, nem sobre o
  repositório de código quando não estiver claro.

---

## Resumo final ao usuário

Depois de processar todas as issues elegíveis da execução, apresente a
Rafinha um resumo consolidado, por exemplo:

```
✅ Projeto processado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1]: PR #12, pipeline OK, sem conflito → merge em develop → movida para QA - Claude
  - [ISSUE-2]: PR #13, pipeline corrigida 1x (lint), conflito mecânico resolvido (import duplicado) → merge em develop → movida para QA - Claude
  - [ISSUE-3]: PR #14, pipeline OK, conflito semântico (duas implementações da mesma validação) — Rafinha decidiu qual prevalece, pipeline revalidada → devolvida para Análise - Rafinha (revisão obrigatória antes do merge)
⚠️ Issues não processadas (PR ausente ou pipeline não configurada): [lista ou "nenhuma"]

Merges realizados já estão em `develop`, enviados ao remoto. Issues devolvidas por conflito semântico aguardam nova Análise - Rafinha antes de voltar para Integração.
```
