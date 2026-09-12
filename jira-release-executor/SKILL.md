---
name: "jira-release-executor"
description: "Preparar e executar uma release do Workflow Rafinha-Claude — transformar um estado do software numa distribuição versionada, identificável, reproduzível e utilizável fora do ambiente de desenvolvimento. Usar quando Rafinha disser algo como \"prepara a release 0.5.0\", \"gera uma pre-release do APK do Routecraft\", \"fecha a versão completa do Compass\", \"que issues entram na próxima release\", ou pedir para publicar/versionar/distribuir o projeto. NUNCA é acionada por varredura de coluna do Jira — Release não é uma etapa do workflow de issue (ver workflow-development-flow), é um ciclo sob demanda e separado. Todo pedido tem dois eixos: TIPO (PRE_RELEASE ou FINAL) e ESCOPO (parcial ou completa). Projeto ≠ repositório: um projeto pode ser monorepo ou multi-repo, e a topologia é declarada no manifesto `.release/project.yml`, nunca inferida. Versiona por COMPONENTE (tags namespaced `<componente>/vX.Y.Z`), e uma distribuição completa recebe também uma versão de PRODUTO. Resolve dependências declaradas para expandir o escopo pedido no escopo efetivo, separando quem recebe versão nova de quem entra como `carried`. Mapeia issue → componente pelos arquivos do Pull Request, monta as notas a partir do campo Resumo das issues, sugere os incrementos com justificativa mas nunca decide sozinha, produz o Release Request e entrega a execução ao Release Orchestrator local (que dispara as Actions e monta a distribuição) ou dispara a Action direto quando não há o que agregar. Ao final aguarda a validação da distribuição fora da IDE, associa as Fix Versions namespaced (só em release final) e atualiza o Confluence. Herda as regras de segurança de jira-integration-executor (nunca --force, nunca descarta trabalho não commitado sem perguntar)."
---

# Executor de Release — Ciclo de Distribuição do Produto

## Identidade do papel

Ao executar esta skill, você conduz o **ciclo de Release** do Workflow
Rafinha-Claude. Release aqui não significa "versionar, criar tag e publicar".
Significa:

> A transformação de um estado específico do software numa distribuição
> versionada, identificável, reproduzível e **utilizável fora do ambiente de
> desenvolvimento**.

Isso é um ciclo **completamente separado** do workflow de 8 etapas: uma issue
termina em `Concluído`, mas isso não significa "lançado".

Diferente de todas as outras skills do pipeline, esta **nunca é acionada por
varredura automática de coluna** — não existe coluna "Release" no Jira e nunca
deve existir. Você só age quando Rafinha inicia explicitamente.

📄 **Leia `workflow-development-flow/references/release-lifecycle.md` antes de
executar.** Ele é o contrato — manifesto, Release Request, Release Action,
Runtime Package, distribuição, Orchestrator e os dez gates. Esta skill é o
procedimento; aquele arquivo é a definição.

Você **herda as regras de segurança de `jira-integration-executor`**: nunca
`git push --force` ou `--force-with-lease`; nunca descarta trabalho não
commitado sem perguntar; sempre `git status` antes de qualquer checkout.

**A decisão de versão nunca é sua.** Você sugere incremento com justificativa —
por componente, mais o do produto quando a release for completa — e a decisão
final é sempre de Rafinha.

---

## O princípio que organiza esta skill

> **A Action faz o que é determinístico dentro de um repositório. O Orchestrator
> faz o que é determinístico entre repositórios. Você faz o que exige contexto
> de Jira, Confluence e decisão humana. Ninguém reimplementa o vizinho, e
> ninguém decide pelo vizinho.**

Criar branch, bump, build, artefato, tag e Release é da Action. Disparar as
Actions, coletar artefatos, montar a distribuição e gerar o ZIP é do
Orchestrator. Você **não** faz nada disso na mão.

O que é seu: descobrir o que entra, mapear issue → componente, expandir o escopo
pelas dependências declaradas, propor os incrementos, escrever as notas em
português, produzir o Release Request, e depois registrar tudo no Jira e no
Confluence.

Consequência que você precisa preservar: **Rafinha consegue fechar um componente
sozinho**, pela aba Actions do GitHub, sem você e sem o Orchestrator. Você é
acelerador, não gargalo.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: High

Escalonar effort quando:
- o changelog agrega mudanças de múltiplos componentes com risco real de
  breaking change;
- muitas issues cruzam componentes, tornando o mapeamento ambíguo;
- a resolução de dependências muda o escopo de forma não óbvia.

Escalonar para Opus quando:
- surge uma decisão atípica de estratégia de release sem precedente no Release
  Lifecycle documentado.

Nunca escalar automaticamente — ver Model Escalation Policy em
`workflow-development-flow`.

---

## Fase 0 — Pré-voo

Nada começa antes destes quatro pontos.

### 0.1 Qual projeto

Se estiver claro pelo contexto, use. Caso contrário, pergunte. Confirme também
qual é a **pasta do projeto** — que em multi-repo é a pasta mãe, não um
repositório.

### 0.2 Gate G0 — documentação do projeto

O projeto precisa ter, no seu space do Confluence, a página
**`CI/CD - Workflow Rafinha-Claude`** com as filhas obrigatórias. Antes da
primeira release, precisa ser possível responder:

```text
Quais são os componentes?          Como uma versão é executada?
Quais são os repositórios?         Quais dependências existem?
Como cada componente é construído? Como funciona a release completa?
Quais artefatos são produzidos?    Existe Runtime Package? Como é executado?
                                   Como a versão é validada?
```

> ⚠️ Se essas respostas não estão documentadas, **a release não começa**. Isso é
> pendência de setup, e você trata como tal: apresenta o que falta e ajuda a
> montar. **Nunca invente** informação ausente dessa documentação.

### 0.3 Gate G1 — manifesto

Leia `.release/project.yml`. Valide: schema; `topology` declarada; todo
`repository` de componente existe; todo `depends_on` existe; sem ciclo; toda
exclusão existe; `runtime_package.required` declarado; componentes batem com o
que o `release.yml` builda.

Se o arquivo não existir, **pare e monte com Rafinha** a partir de
`templates/project.yml`. Se divergir do `release.yml`, **pare e avise** — os
dois divergiram, e isso é bug.

Se faltarem `release.yml`, Runtime Package ou Orchestrator, instale a partir dos
templates desta skill:

| Template | Vai para |
| --- | --- |
| `templates/project.yml` | `.release/project.yml` |
| `templates/release.yml` | `.github/workflows/release.yml` (em cada repositório) |
| `templates/release-notes-README.md` | `.github/release-notes/README.md` |
| `templates/runtime/` | `.release/runtime/` |
| `templates/orchestrator/` | `.release/scripts/` |

> ⚠️ **Nunca copie de outro projeto**, nem do Compass System. Um projeto pode ter
> divergido, e copiar propaga a divergência silenciosamente. Melhoria descoberta
> num projeto volta para o template.

> ⚠️ `workflow_dispatch` só aparece se o arquivo existir na **branch padrão**.
> Num fluxo `develop → main`, o `release.yml` precisa estar nas duas.

### 0.4 Estado limpo

`git status` em cada repositório do projeto antes de qualquer coisa. Alterações
não commitadas: pare e pergunte. Nunca descarte sozinho.

---

## Fase 1 — Intake: os dois eixos

Todo pedido tem dois eixos, e você precisa fechar os dois antes de seguir.

```text
Release Request
├── Type   → PRE_RELEASE | FINAL
└── Scope  → parcial | completa
```

Traduzindo pedidos reais:

| Pedido | Type | Scope |
| --- | --- | --- |
| "Gera uma pre-release do APK do Routecraft" | PRE_RELEASE | parcial: `routecraft_android` |
| "Prepara uma pre-release do Compass API + Web" | PRE_RELEASE | parcial: dois componentes |
| "Fecha a versão completa do Compass System" | FINAL | completa |
| "Prepara a release completa do GeoPrag" | FINAL | completa |

Se o tipo não estiver claro no pedido, **pergunte** — não assuma FINAL. Uma
release completa sem pre-release anterior é legítima, mas é decisão de Rafinha,
não sua.

`rc.N` é o identificador de uma pre-release candidata à final, não um mecanismo
separado. `publish=false` é modo de execução, **não** um terceiro tipo.

---

## Fase 2 — Resolução do escopo

### 2.1 Levantar as issues candidatas

Busque issues em **"Concluído"** cuja Fix Version ainda não cobre todos os
componentes que elas tocaram. Se Rafinha já indicou quais entram (ou quais
ficam de fora), essa indicação vence a varredura.

### 2.2 Mapear cada issue ao seu componente

1. Leia o campo **`Links para merge`** da issue (o PR que a
   `jira-issue-executor` gravou lá).
2. `gh pr view <URL completa do PR> --json files` — **use a URL, não o número**:
   em multi-repo os PRs estão em repositórios diferentes, e a URL funciona nos
   dois casos sem caso especial.
3. Case o prefixo do path com o `path` de cada componente do manifesto.

Uma issue pode casar com **mais de um componente** — adicionar um endpoint na
API e consumi-lo no app é o caso comum. Ela entra na lista dos dois.

> ⚠️ Não use a label de plataforma (`web`/`mobile`) como componente. Ela existe
> para a `jira-qa-executor` escolher o executor de QA. Componente vem do
> manifesto e dos arquivos do PR, sempre.

PR inacessível ou campo vazio: **pergunte** a qual componente pertence. Não
chute pelo título.

### 2.3 Expandir pelo escopo efetivo

Resolva `depends_on` do manifesto sobre o escopo pedido:

```text
Requested Scope:   geoprag_admin
                         ↓ depends_on
Effective Scope:   geoprag_admin, geoprag_api
```

> ⚠️ Dependência é **declarada**, nunca descoberta. Não infira por análise de
> código, não deduza de import, não conclua de "o app chama a API". Se não está
> no manifesto, não existe para este ciclo — e declarar é decisão de Rafinha.

### 2.4 Separar `version_scope` de `carried`

Estar no escopo efetivo **não** implica receber versão nova.

| Situação | Onde entra |
| --- | --- |
| Mudou nesta rodada | `version_scope` — versão nova, tag, e Release se for final |
| Puxado por dependência e **não** mudou | `carried` — entra na distribuição na versão atual |

**Gate G3:** se um componente `carried` não tem versão publicada e consumível,
**pare**. Nunca fabrique a dependência, nunca aponte para código local não
publicado. A saída é publicar aquela versão antes, ou mover o componente para o
`version_scope`.

### 2.5 Apresentar e confirmar (Gate G2)

```text
Projeto: GeoPrag          Tipo: PRE_RELEASE       Escopo: parcial

Pedido:            geoprag_admin
Dependência:       geoprag_api  (declarada em depends_on)

Recebem versão:    geoprag_admin   GEO-41, GEO-44
Entram como carried: geoprag_api   2.1.0 (sem mudança nesta rodada)

Fora do escopo:    geoprag_mobile, geoprag_public
```

Em release **completa**, informe as exclusões permanentes do manifesto como
fato, **sem perguntar de novo**:

```text
Escopo completo: todos os componentes, exceto legacy_component
                 (exclusão permanente declarada no manifesto)
```

> ⚠️ Exclusão **não** declarada nunca é inventada durante a execução. Se um
> componente deve ficar permanentemente de fora, isso é alteração de manifesto,
> com decisão de Rafinha, **antes** da release.

Aguarde confirmação antes de seguir.

---

## Fase 3 — Decisão das versões (Gate G4)

Sugira o incremento **de cada componente do `version_scope`**, com justificativa
objetiva:

```text
geoprag_admin   1.1.0 → 1.2.0-rc.1   MINOR (tela nova, nada quebrado)
geoprag_api     2.1.0 → carried       sem mudança nesta rodada
```

Em release **completa**, sugira também a **versão do produto**:

```text
GeoPrag  0.9.0 → 1.0.0-rc.1   MAJOR (primeira distribuição completa estável)
```

A versão do produto identifica o conjunto; ela **não** substitui as versões dos
componentes e **não** vira Fix Version.

**Nunca decida sozinha.** Aguarde confirmação ou correção para cada item.

---

## Fase 4 — Notas de release (Gate G5)

Esta é a parte que mais agrega valor e a que mais fácil sai errada. **O produto
deste passo é texto corrido que qualquer pessoa entende — não uma lista de
issues.**

A matéria-prima é o campo **`Resumo`** de cada issue, que a
`jira-issue-executor` mantém atualizado. Use isso, não a mensagem de commit e
não o título da issue.

Escreva `.github/release-notes/<componente>-<versao-base>.md` — **versão base**,
sem o `-rc.N`: um arquivo `geoprag_admin-1.2.0.md` serve o `rc.1`, o `rc.2` e a
final, que é o que se quer, já que descrevem a mesma entrega.

> **Regra do texto:** descreva o que mudou do ponto de vista de quem **usa** o
> sistema. Se a frase só faz sentido para quem abriu o Pull Request, reescreva.

- **Agrupe por tema, não por issue.** Três issues que juntas melhoraram o
  cadastro viram *um* parágrafo sobre cadastro.
- **Nunca liste issues ou PRs como conteúdo.** Chaves vão no fim, depois de um
  `---`, como referência.
- **Seções por natureza** (`## Novidades`, `## Correções`, `## Mudanças que
  exigem atenção`), não por componente — o arquivo já é de um componente só.
- **Sem jargão interno:** nada de branch, arquivo, classe, "refatorado o
  service". Mudança puramente interna ou fica de fora, ou vira uma frase sobre o
  efeito prático.
- **Breaking change sempre aparece**, com o que a pessoa precisa fazer.

`Resumo` vazio ou genérico demais: **pergunte a Rafinha** o que aquela mudança
significou na prática. Não invente e não caia no título da issue.

Atualize também, no mesmo commit: `CHANGELOG.md` e a tabela de versões do
`README.md`, se houver.

**Commite antes do dispatch** — é de lá que a Action lê as notas. Sem o arquivo,
ela cai no `--generate-notes` e publica a lista crua de PRs.

---

## Fase 5 — Execução (Gate G6)

### 5.1 Produzir o Release Request

Escreva `.release/requests/<data>-<tipo>.yml` no formato do contrato (§8 da
referência, exemplo em `templates/orchestrator/release-request.example.yml`):
tipo, versão de produto, escopo pedido e efetivo, `version_scope`, `carried`,
`ref`, commits por repositório e issues por componente.

Em FINAL que promove uma pre-release validada, preencha `promotes` — e então os
commits vêm do `release-manifest.yml` daquele rc, **não** do `HEAD` da branch.

### 5.2 Escolher o caminho

| Caso | O que fazer |
| --- | --- |
| Há distribuição a montar (completa, ou parcial agregada) | `.\.release\scripts\orchestrate.ps1 -Request <caminho>` |
| Release parcial sem distribuição | `gh workflow run release.yml --repo <remote> --ref <ref> -f <input>=<versao> -f release_type=<tipo> -f publish=true` |

Rode o Orchestrator com `-Validate` primeiro: ele confere manifesto, escopo e
estado dos repositórios sem tocar na rede.

O Orchestrator dispara as Actions, aguarda, coleta os artefatos, monta a
distribuição com o Runtime Package, gera o `release-manifest.yml` e o ZIP.

**Falha aqui é bloqueio de avanço.** Corrija e repita. Nunca contorne fazendo o
passo na mão — se a Action falhou, conserte a Action; se o Orchestrator falhou,
conserte o Orchestrator.

---

## Fase 6 — Validação da distribuição (Gate G7)

Antes de considerar entregue, **Rafinha executa a distribuição fora da IDE**:
baixa o pacote, roda o entrypoint do Runtime Package, usa o produto real.

Isso não é a `Análise final - Rafinha` de cada issue, já feita antes. Aqui é a
validação do **pacote como entrega** — é o que separa "o CI passou" de "o
produto funciona quando alguém o executa".

Não prossiga sem confirmação explícita. O resultado:

```text
aprovada   → promover para FINAL (nova execução, com `promotes` preenchido)
reprovada  → correção → novo rc (rc.2, rc.3, …)
```

Nem toda pre-release vira final, e não há limite de rc's. Registre o veredito na
página **Validação da Release** do projeto.

> A `jira-human-validation-executor` pode **recomendar** a geração de uma
> pre-release quando um cenário só for validável na distribuição real. Ela
> recomenda; quem decide gerar é Rafinha.

---

## Fase 7 — Registro (Gate G9)

Só depois de uma release **FINAL** validada:

### 7.1 Fix Versions no Jira

Crie/atualize as versões com **nome namespaced**, igual à tag:

```text
geoprag_admin 1.2.0
geoprag_api 2.1.0
```

- **Só em release final.** `rc.N` nunca vira Fix Version.
- **Só por componente.** A versão do produto não vira Fix Version.
- **Multi-valorada:** uma issue que tocou dois componentes recebe as duas, à
  medida que cada um for lançado.

> ⚠️ Uma issue que tocou dois componentes e teve só um lançado **não está
> inteiramente entregue**. Não a trate como concluída no sentido de release.

### 7.2 Confluence

- Página **Release** do projeto: acrescente a distribuição, copiando o
  **conteúdo do `release-manifest.yml`** — nunca uma segunda versão escrita à
  mão.
- Página **Versionamento**: atualize as versões dos componentes e a do produto.
- Página **Validação da Release**: o veredito da fase 6.

### 7.3 Armazenamento

O ZIP vai para a pasta do Drive definida pelo projeto, junto de uma cópia
atualizada do `.release/project.yml`. Em multi-repo isso não é conveniência: o
manifesto não tem histórico Git, e o Drive + o Confluence + os ZIPs **são** a
rastreabilidade histórica.

---

## O que NÃO fazer

- ❌ Nunca decidir sozinha o incremento de versão — de componente ou de produto.
- ❌ Nunca criar branch de release, bump, build, `git tag` ou `gh release create`
  na mão. Se a Action falhar, conserte a Action.
- ❌ Nunca montar a distribuição na mão. Se o Orchestrator falhar, conserte-o.
- ❌ Nunca gerar release automaticamente a partir de issue concluída.
- ❌ Nunca varrer coluna do board para disparar esta skill.
- ❌ Nunca criar ou sugerir uma coluna "Release" no Jira.
- ❌ Nunca inferir topologia de projeto — ela é declarada no manifesto.
- ❌ Nunca inferir dependência entre componentes por análise de código.
- ❌ Nunca bumpar um componente `carried` que não mudou.
- ❌ Nunca prosseguir com `carried` sem versão publicada compatível — nem
  fabricar a dependência, nem usar código local não publicado.
- ❌ Nunca inventar exclusão de componente não declarada no manifesto.
- ❌ Nunca re-perguntar justificativa de exclusão já declarada.
- ❌ Nunca usar tag ou Fix Version sem o prefixo do componente.
- ❌ Nunca criar Fix Version para um `rc.N`.
- ❌ Nunca transformar a versão do produto em Fix Version.
- ❌ Nunca inferir componente pelo título da issue ou pela label de plataforma.
- ❌ Nunca entregar notas que sejam lista de issues, PRs ou mensagens de commit.
- ❌ Nunca deixar de commitar as notas antes do dispatch.
- ❌ Nunca inventar o que uma issue fez porque o `Resumo` estava vazio.
- ❌ Nunca produzir uma FINAL a partir de estado de código diferente do rc
  promovido.
- ❌ Nunca começar uma release sem a documentação do projeto no Confluence.
- ❌ Nunca instalar templates copiando de outro projeto.
- ❌ Nunca marcar como entregue uma issue cujos componentes não saíram todos.
- ❌ Nunca usar `git push --force` ou `--force-with-lease`.
- ❌ Nunca descartar alterações não commitadas sem confirmação explícita.

---

## Resumo final ao usuário

```
🚀 Release executada — GeoPrag

📦 Tipo: FINAL (promoção de 1.0.0-rc.3)   Escopo: completa
🏷️  Produto: GeoPrag 0.9.0 → 1.0.0

   Componente        Versão              Origem
   geoprag_mobile    1.3.0 → 1.4.0       versionado   GEO-38, GEO-40
   geoprag_admin     1.1.0 → 1.2.0       versionado   GEO-41, GEO-44
   geoprag_public    1.8.0               carried
   geoprag_api       2.1.0               carried
   legacy_component  —                   exclusão permanente

⚙️  Orchestrator: 2 Actions disparadas, ambas verdes
📦 Distribuição: geoprag-1.0.0.zip (148 MB) — runtime incluído
✅ Validada fora da IDE por Rafinha em 12/09
🏷️  Fix Versions: "geoprag_mobile 1.4.0", "geoprag_admin 1.2.0"
📝 Confluence: Release, Versionamento e Validação da Release atualizadas
💾 Drive: ZIP + cópia do project.yml

⚠️  GEO-44 tocou admin e api; só o admin saiu nesta release — segue aguardando
   o lançamento de geoprag_api.
```
