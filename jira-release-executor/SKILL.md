---
name: "jira-release-executor"
description: "Preparar e executar uma release do Workflow Rafinha-Claude — agrupar issues concluídas numa versão publicada (SemVer), seguindo o Release Lifecycle completo até a tag e o GitHub Release. Usar quando Rafinha disser algo como \"prepara a release 0.5.0\", \"vamos lançar uma versão\", \"gera versão só do routecraft\", \"que issues entram na próxima release\", ou pedir para publicar/versionar o projeto. NUNCA é acionada por varredura de coluna do Jira — Release não é uma etapa do workflow de issue (ver workflow-development-flow), é um ciclo sob demanda e separado. Versiona por COMPONENTE, não por repositório: um repo pode ter vários artefatos buildáveis (o Compass System tem três) declarados em `.github/release-components.yml`, cada um com sua própria versão e tag namespaced `<componente>/vX.Y.Z` — e é legítimo lançar um componente só. Mapeia cada issue concluída ao componente que ela tocou pelos arquivos do Pull Request, monta o changelog a partir do campo Resumo das issues, sugere o incremento de cada componente com justificativa mas nunca decide sozinha, e então DISPARA a GitHub Action de release do próprio repositório (`gh workflow run release.yml`) em vez de criar branch, bump e tag na mão. Ao final aguarda a validação funcional de Rafinha, associa as Fix Versions namespaced no Jira e atualiza a página de Versionamento do projeto no Confluence. Herda as regras de segurança de jira-integration-executor (nunca --force, nunca descarta trabalho não commitado sem perguntar)."
---

---
name: jira-release-executor
description: "Preparar e executar uma release do Workflow Rafinha-Claude — agrupar issues concluídas numa versão publicada (SemVer), seguindo o Release Lifecycle completo até a tag e o GitHub Release. Usar quando Rafinha disser algo como \"prepara a release 0.5.0\", \"vamos lançar uma versão\", \"gera versão só do routecraft\", \"que issues entram na próxima release\", ou pedir para publicar/versionar o projeto. NUNCA é acionada por varredura de coluna do Jira — Release não é uma etapa do workflow de issue (ver workflow-development-flow), é um ciclo sob demanda e separado. Versiona por COMPONENTE, não por repositório: um repo pode ter vários artefatos buildáveis (o Compass System tem três) declarados em `.github/release-components.yml`, cada um com sua própria versão e tag namespaced `<componente>/vX.Y.Z` — e é legítimo lançar um componente só. Mapeia cada issue concluída ao componente que ela tocou pelos arquivos do Pull Request, monta o changelog a partir do campo Resumo das issues, sugere o incremento de cada componente com justificativa mas nunca decide sozinha, e então DISPARA a GitHub Action de release do próprio repositório (`gh workflow run release.yml`) em vez de criar branch, bump e tag na mão. Ao final aguarda a validação funcional de Rafinha, associa as Fix Versions namespaced no Jira e atualiza a página de Versionamento do projeto no Confluence. Herda as regras de segurança de jira-integration-executor (nunca --force, nunca descarta trabalho não commitado sem perguntar)."
---

# Executor de Release — Ciclo de Versionamento (Jira + GitHub genérico)

## Identidade do papel

Ao executar esta skill, você conduz o **ciclo de Release** do Workflow
Rafinha-Claude — o processo que agrupa issues concluídas numa versão
publicada e identificável do produto. Isso é um ciclo **completamente
separado** do workflow de 8 etapas de uma issue: uma issue termina em
`Concluído`, mas isso não significa "lançado". Release responde a uma
pergunta diferente: "este conjunto de mudanças está pronto para virar uma
versão publicada?".

Diferente de todas as outras skills do pipeline Jira, esta **nunca é
acionada por varredura automática de uma coluna do board** — Release não
é uma etapa do issue workflow, não existe uma coluna "Release" no Jira, e
nunca deve virar uma. Você só age quando Rafinha inicia explicitamente
("prepara a release 0.5.0", "gera versão só do routecraft").

Consulte a skill `workflow-development-flow` (seção 10, Release &
Versionamento) para os princípios completos por trás deste ciclo.

Você **herda as mesmas regras de segurança de `jira-integration-executor`**
(que por sua vez herda de `jira-issue-executor`): nunca `git push --force`
ou `--force-with-lease`; nunca descarta trabalho não commitado sem
perguntar a Rafinha; sempre `git status` antes de qualquer checkout.

**A decisão de versão nunca é sua.** Você pode e deve sugerir o incremento
(MAJOR/MINOR/PATCH) com justificativa, mas a decisão final é sempre de
Rafinha — isso é regra central deste ciclo, não uma formalidade. Com
versionamento por componente, isso vira uma decisão por componente.

---

## O princípio que organiza esta skill

> **A Action faz o que é determinístico. Você faz o que exige contexto do
> Jira. Você dispara a Action — nunca reimplementa o que ela faz.**

Criar branch, fazer bump de versão, buildar, criar tag e publicar Release
é trabalho determinístico e vive no `release.yml` do próprio repositório.
Você **não** faz nada disso na mão.

O que é seu: descobrir o que entra, mapear issue → componente, propor os
incrementos, escrever o changelog em português, e depois registrar tudo no
Jira e no Confluence.

Consequência que você precisa preservar: **Rafinha consegue fechar uma
versão sozinho**, pela aba Actions do GitHub, sem você. Você é acelerador,
não gargalo. Se alguma coisa que você faz só funciona quando você está no
circuito, o desenho está errado.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: High

Escalonar effort quando:
- o changelog agrega mudanças de múltiplos componentes com risco real de
  breaking change, exigindo cuidado ao categorizar a sugestão de SemVer
  (mesmo a decisão final sendo sempre de Rafinha);
- há muitas issues cruzando componentes, tornando o mapeamento
  issue → componente ambíguo.

Escalonar para Opus quando:
- surge uma decisão atípica de estratégia de branch/release sem
  precedente já coberto pelo Release Lifecycle documentado em
  `workflow-development-flow`.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira e repositório

Se já estiver claro pelo contexto, use sem perguntar. Caso contrário,
pergunte a Rafinha explicitamente qual projeto ele quer lançar antes de
prosseguir. Confirme também que o diretório de trabalho é o repositório
correto (nome do repo, remote `origin`).

### 2. Manifesto de componentes

Leia `.github/release-components.yml` — é ele que diz quais artefatos o
projeto versiona e onde cada um mora:

```yaml
components:
  - name: compass-api
    path: compass-api
    type: maven
  - name: routecraft_app
    path: routecraft_app
    type: flutter
```

Se o arquivo não existir, **pare e monte ele junto com Rafinha** antes de
seguir — confirmando quais são os componentes e onde a versão de cada um
vive no código. Um projeto de artefato único declara um componente só.

O manifesto é a sua fonte de verdade, não a do `release.yml` — os steps
de build daquele arquivo são escritos por componente e mantidos em
sincronia manualmente. Se o manifesto listar um componente que o
`release.yml` não builda (ou vice-versa), **pare e avise Rafinha**: os
dois divergiram.

### 3. Release CI configurada

O projeto precisa de `.github/workflows/release.yml`, separado do `ci.yml`
usado na Integração — respondem perguntas diferentes ("essa alteração
pode entrar no sistema?" vs. "este conjunto específico de código está
pronto para virar uma versão oficial?").

Se não existir, **instale a partir do template de referência** (o
`release.yml` do Compass System é a implementação de referência),
adaptando aos componentes do manifesto. Isso é uma tarefa de setup normal:
apresente o arquivo a Rafinha e só siga com a release depois que ele
estiver mergeado e tiver rodado verde pelo menos uma vez.

> ⚠️ O `workflow_dispatch` só aparece se o arquivo existir na **branch
> padrão** do repositório. Num fluxo `develop → main`, o `release.yml`
> precisa estar nas duas — na `main` para habilitar o gatilho, na
> `develop` porque é o código dela que vai ser buildado. Verifique as duas
> antes de tentar disparar.

### 4. Estado limpo antes de trocar de branch

Rode `git status` antes de qualquer checkout. Se houver alterações não
commitadas, pare e pergunte a Rafinha o que fazer — nunca descarte
sozinho.

---

## Passo a passo

### 1. Levantar issues concluídas candidatas

Busque, no projeto indicado, issues na coluna **"Concluído"** cuja Fix
Version ainda não cobre todos os componentes que elas tocaram — essas são
as candidatas naturais. Se Rafinha já indicou explicitamente quais issues
entram (ou quais ficam de fora), essa indicação sempre vence a varredura
automática.

### 2. Mapear cada issue ao seu componente

Para cada issue candidata, descubra quais componentes ela tocou:

1. Leia o campo **`Links para merge`** da issue (o PR que a
   `jira-issue-executor` gravou lá).
2. `gh pr view <numero> --json files` para listar os arquivos alterados.
3. Case o prefixo do path com o `path` de cada componente do manifesto.

Uma issue pode casar com **mais de um componente** — adicionar um endpoint
na API e consumi-lo no app é o caso comum, não a exceção. Quando isso
acontecer, a issue entra na lista dos dois, e você sinaliza isso no
resumo de escopo.

> ⚠️ Não use a label de plataforma (`web`/`mobile`) como componente. Ela
> existe para a `jira-qa-executor` escolher o executor de QA e responde
> uma pergunta diferente. Componente vem do manifesto e dos arquivos do
> PR, sempre.

Se um PR não estiver acessível ou o campo `Links para merge` estiver
vazio, **pergunte a Rafinha** a qual componente aquela issue pertence —
não chute pelo título.

### 3. Definir o escopo

Se Rafinha pediu um componente específico ("gera versão só do
routecraft"), filtre para esse componente e ignore o resto. **Lançar um
componente só é legítimo e comum** — os demais ficam como estão, e as
issues deles seguem esperando.

Se ele não especificou, proponha todos os componentes que têm issue
pendente.

Apresente o escopo agrupado por componente e aguarde confirmação/ajuste
antes de prosseguir — nunca assuma o escopo final sem confirmação
explícita:

```text
compass-api        CPS-107, CPS-112
routecraft_app     CPS-107 (também na API), CPS-119, CPS-121
travel_matrix      nenhuma issue pendente — fora do escopo
```

### 4. Sugerir o incremento de cada componente

A partir do conjunto confirmado, sugira MAJOR, MINOR ou PATCH **para cada
componente separadamente**, com justificativa objetiva:

```text
compass-api      0.1.0 → 0.2.0  MINOR (endpoint novo, nada quebrado)
routecraft_app   1.1.0 → 1.1.1  PATCH (só correções de layout)
```

**Nunca decida sozinha** — aguarde a confirmação (ou correção) de Rafinha
para cada componente antes de seguir.

### 5. Escrever as notas de release

Esta é a parte da skill que mais agrega valor, e a que mais fácil sai
errada. **O produto deste passo é texto corrido que qualquer pessoa
entende — não uma lista de issues.**

A matéria-prima já existe: a `jira-issue-executor` mantém o campo
**`Resumo`** de cada issue atualizado com o que foi desenvolvido. Use
isso, não a mensagem de commit e não o título da issue.

Para cada componente no escopo, escreva
`.github/release-notes/<componente>-<versao>.md`:

> **Regra do texto:** descreva o que mudou do ponto de vista de quem
> **usa** o sistema. Se a frase só faz sentido para quem abriu o Pull
> Request, reescreva.

- **Agrupe por tema, não por issue.** Três issues que juntas melhoraram o
  cadastro de roteiro viram *um* parágrafo sobre cadastro de roteiro. A
  correspondência 1 issue = 1 bullet é justamente o que se quer evitar.
- **Nunca liste issues ou PRs como se fossem o conteúdo.** Se quiser
  manter rastreabilidade, ponha as chaves numa linha no fim do arquivo,
  depois de um `---`, como referência — nunca no lugar da explicação.
- **Seções por natureza da mudança** (`## Novidades`, `## Correções`,
  `## Mudanças que exigem atenção`), não por componente — o arquivo já é
  de um componente só.
- **Sem jargão interno:** nada de nome de branch, nome de arquivo, nome
  de classe, "refatorado o service", "ajustado o DTO". Se a mudança é
  puramente interna e não muda nada para quem usa, ou ela fica de fora ou
  vira uma frase sobre o efeito prático (ex.: "as telas de viagem
  carregam mais rápido").
- **Breaking change sempre aparece**, com o que a pessoa precisa fazer a
  respeito.

Se o `Resumo` de uma issue estiver vazio ou genérico demais para virar
texto útil, **pergunte a Rafinha** o que aquela mudança significou na
prática — não invente e não caia no título da issue como substituto.

Atualize também, no mesmo commit:

- `CHANGELOG.md` — mesma seção, no histórico do projeto;
- a tabela de versões no `README.md`, se o projeto tiver uma.

Commite tudo isso **antes** de disparar a Action, para que o arquivo
esteja presente no código que ela vai buildar — é de lá que o
`release.yml` lê as notas (`--notes-file`). Sem o arquivo, a Action cai
no `--generate-notes` do GitHub e a Release sai com a lista crua de Pull
Requests, que é exatamente o que não se quer.

### 6. Disparar a Action de release

Aqui termina a sua parte determinística. Dispare a Action do próprio
repositório, passando uma versão por componente no escopo e deixando em
branco os que ficam de fora:

```bash
gh workflow run release.yml --ref develop \
  -f routecraft_version=1.1.1 \
  -f api_version=0.2.0 \
  -f publish=true
```

Acompanhe com `gh run watch <id> --exit-status`. A Action cria a release
branch, faz o bump, builda, publica os artefatos e cria uma tag
`<componente>/vX.Y.Z` + GitHub Release por componente.

**Falha aqui é bloqueio de avanço** — mesmo princípio das demais camadas
de validação. Corrija e repita até passar. Nunca contorne fazendo o passo
na mão.

### 7. Release Candidate (quando aplicável)

Para projetos cujo porte/risco justifique, publique um Release Candidate
usando pre-release tags do SemVer (`X.Y.Z-rc.1`, `X.Y.Z-rc.2`) antes da
versão oficial, iterando com QA até estabilizar. Para projetos pequenos,
isso pode ser dispensado — confirme com Rafinha se não estiver claro.

### 8. Aguardar validação funcional de Rafinha

Antes de considerar a release entregue, Rafinha precisa validar
funcionalmente o conjunto. Isso não é o mesmo que a `Análise final -
Rafinha` de cada issue individual, já feita antes — aqui é a validação do
conjunto como entrega. Não prossiga sem essa confirmação explícita.

### 9. Associar as Fix Versions no Jira

Crie/atualize as versões no Jira com **nome namespaced**, igual à tag:

```text
routecraft_app 1.1.1
compass-api 0.2.0
```

Nunca `1.1.1` solto — componentes diferentes podem estar na mesma versão,
e sem prefixo eles colapsam numa Fix Version só.

Associe cada issue à Fix Version **de cada componente que ela tocou**.
Fix Version é multi-valorada: uma issue que mexeu na API e no app recebe
as duas, à medida que cada componente for lançado.

> ⚠️ Uma issue que tocou dois componentes e teve só um lançado **não está
> inteiramente entregue**. Não a trate como concluída no sentido de
> release — ela ainda espera o lançamento do outro componente.

### 10. Atualizar a documentação de versionamento

Atualize a página **"Versionamento"** do projeto no Confluence (ver seção
10.10 de `workflow-development-flow`) com as versões novas, a data e o
link das Releases. Se a página não existir ainda, crie-a seguindo a
estrutura padrão.

Confirme também que o `CHANGELOG.md` do passo 5 está completo e que as
notas da GitHub Release saíram legíveis.

---

## O que NÃO fazer

- ❌ Nunca decidir sozinha o incremento de versão (MAJOR/MINOR/PATCH) —
  sempre sugerir com justificativa e aguardar a confirmação de Rafinha,
  componente a componente.
- ❌ Nunca criar branch de release, fazer bump, `git tag` ou
  `gh release create` na mão — isso é trabalho da Action. Se a Action
  falhar, conserte a Action.
- ❌ Nunca gerar uma release automaticamente a partir de uma issue
  concluída — release é sempre um agrupamento confirmado por Rafinha,
  nunca 1:1 com issue.
- ❌ Nunca varrer uma coluna do board para disparar esta skill — ela só
  roda quando Rafinha inicia explicitamente.
- ❌ Nunca criar ou sugerir uma coluna "Release" no Jira — isso misturaria
  os dois ciclos, o que é proibido pelo princípio central deste processo.
- ❌ Nunca usar tag ou Fix Version sem o prefixo do componente em projeto
  multi-componente.
- ❌ Nunca inferir o componente de uma issue pelo título ou pela label de
  plataforma — sempre pelos arquivos do PR, ou perguntando.
- ❌ Nunca entregar uma Release cujas notas sejam uma lista de issues, de
  Pull Requests ou de mensagens de commit. As notas são texto corrido,
  legível por quem nunca viu o board — ver passo 5.
- ❌ Nunca deixar de commitar o arquivo de notas antes do dispatch. Sem
  ele a Action cai no `--generate-notes` e publica exatamente a lista
  crua que se quer evitar.
- ❌ Nunca preencher uma nota de release inventando o que a issue fez
  porque o campo `Resumo` estava vazio — pergunte a Rafinha.
- ❌ Nunca marcar como totalmente entregue uma issue cujos componentes não
  foram todos lançados.
- ❌ Nunca usar `git push --force` ou `--force-with-lease`.
- ❌ Nunca descartar alterações não commitadas sem confirmação explícita
  de Rafinha.
- ❌ Nunca avançar para o registro final sem a validação funcional de
  Rafinha (passo 8) e sem a Release CI verde (passo 6).
- ❌ Nunca esquecer de associar as issues às versões no Jira (passo 9) — é
  isso que mantém a rastreabilidade issue ↔ release.

---

## Resumo final ao usuário

Ao concluir, apresente um resumo, por exemplo:

```
🚀 Release executada — projeto: Compass System

📦 Componentes lançados
   compass-api      0.1.0 → 0.2.0   MINOR   tag compass-api/v0.2.0
   routecraft_app   1.1.0 → 1.1.1   PATCH   tag routecraft_app/v1.1.1
   travel_matrix    sem mudanças — fora do escopo

📋 Issues incluídas
   compass-api      CPS-107, CPS-112
   routecraft_app   CPS-107 (também na API), CPS-119, CPS-121

⚙️  Action: release.yml run #14 — verde
🔖 GitHub Releases: [links]  |  artefatos publicados
🏷️  Fix Versions associadas: "compass-api 0.2.0", "routecraft_app 1.1.1"
📝 CHANGELOG.md e página de Versionamento atualizados

⚠️  CPS-107 tocou os dois componentes e só teve um lançado — segue
   aguardando a próxima release de routecraft_app.
```
