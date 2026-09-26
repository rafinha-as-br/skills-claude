# Release Lifecycle — referência completa

Referência do ciclo de Release do Workflow Rafinha-Claude. Carregada sob
demanda pela skill mãe `workflow-development-flow` (seção 10) e pelas skills
que executam o ciclo.

Este arquivo é **o contrato**. Implementações — a Action de cada repositório, o
Orchestrator de cada projeto, o Runtime Package de cada produto — são livres por
dentro e obrigadas por fora, pelo que está definido aqui.

> O workflow não ensina cada projeto a ser um Compass System. Ele define
> contratos gerais o bastante para que cada projeto descreva a sua própria
> forma de construir, distribuir e executar seu software.

---

## 1. Dois ciclos diferentes

> **Issue workflow e Release workflow não são a mesma coisa.**

- **Issue workflow** (as 12 colunas) → processo de conclusão de uma unidade de
  mudança. Termina em `Concluído`.
- **Release workflow** (este arquivo) → processo de entrega do produto. Agrupa
  várias issues concluídas numa versão publicada.

```text
ISSUE WORKFLOW                             RELEASE WORKFLOW

A fazer → Decisão → Design → Ready         Pedido de release (sob demanda)
      ↓                                           ↓
Fazer - Claude                             Tipo + Escopo → Dependências → Escopo efetivo
      ↓                                           ↓
Análise - Rafinha                          Versões decididas por Rafinha
      ↓                                           ↓
Integração                                 develop → release/current (G10)
      ↓                                           ↓
QA - Claude                                Commit de bump em release/current
      ↓                                           ↓
Análise Final - Rafinha                    Release Request
      ↓                                           ↓
Documentar                                 Actions → artefatos
      ↓                                           ↓
Análise Final - Claude                     Distribuição + Runtime
      ↓                                           ↓
Concluído                                  Validação → versão oficial
```

Uma issue chegar a `Concluído` **não** significa que ela foi lançada.

**Regras invioláveis:**

- Release **nunca** vira uma coluna do Jira.
- Release **nunca** é acionada por varredura automática de coluna.
- Release só começa quando Rafinha pede explicitamente.
- Nenhuma issue concluída gera release automaticamente.

### As três branches do ciclo

O ciclo de release não tem coluna, mas tem **branch**. São três, com papéis
que não se sobrepõem:

| Branch | Representa |
| --- | --- |
| `develop` | **Integração** do produto — onde o trabalho aprovado se junta |
| `release/current` | **Estabilização** da próxima release — linha persistente, já versionada |
| `main` | **Produção / publicado**, quando o projeto usa `main` dessa forma |

```text
develop
  → release/current
  → commit de bump em release/current
  → release/<data>-<run_number>        (branch efêmera, criada pela Action)
  → tag / GitHub Release
```

**A release não parte da `develop` por padrão.** O Release Request usa
`release/current` como referência, salvo exceção explícita autorizada por
Rafinha.

`release/current` é a linha **persistente** de estabilização e versionamento.
`release/<data>-<run_number>` continua sendo a branch **efêmera** de uma
execução específica — ela só passa a nascer da `release/current` já preparada,
em vez da `develop`.

A promoção `develop → release/current` não é livre: ver
**§22 — Promoção para `release/current`** e o gate **G10**.

---

## 2. Projeto, Repositório e Componente

Três conceitos distintos. Confundi-los é a origem da maior parte dos erros
possíveis neste ciclo.

| Conceito | O que é |
| --- | --- |
| **Projeto** | A unidade de **produto**. O que tem nome comercial, documentação e distribuição |
| **Repositório** | Unidade técnica de armazenamento e execução de CI |
| **Componente** | Unidade **versionável** do produto — um artefato buildável independente |

**Um projeto não é necessariamente um repositório.** As duas topologias válidas:

```text
MONOREPO                        MULTI-REPO

Projeto                         Projeto
└── Repositório                 ├── Componente → Repositório
    ├── Componente              ├── Componente → Repositório
    ├── Componente              └── Componente → Repositório
    └── Componente
```

O manifesto declara qual é a topologia (`topology: monorepo | multi_repo`), e é
isso que determina os caminhos de execução. **Nunca inferir topologia** olhando
a estrutura de pastas.

Em multi-repo, os repositórios ficam reunidos numa **pasta mãe local** que:

- **não** é um repositório Git;
- **não** substitui nenhum dos repositórios;
- serve como estrutura local do projeto;
- contém `.release/` (manifesto, runtime, orchestrator, requests).

---

## 3. Componente: a unidade de versionamento

**A unidade que recebe uma versão é o componente, não o repositório.** Um
repositório pode conter vários artefatos buildáveis independentes. Cada um
evolui no seu próprio ritmo: a API pode ir a PATCH sem forçar versão nova em
nenhum app.

Projeto de artefato único declara **um** componente — mesmo formato, sem caso
especial.

> ⚠️ **Componente não é a label de plataforma.** A label `web`/`mobile` que a
> `jira-issue-executor` aplica serve para a `jira-qa-executor` escolher o
> executor de QA. São eixos diferentes; reaproveitar um como o outro quebra os
> dois.

O `path` do componente no manifesto é o que mapeia **issue → componente**: os
arquivos tocados pelo Pull Request da issue (campo `Links para merge`) dizem a
quais componentes ela pertence.

---

## 4. Versionamento

### 4.1 SemVer por componente

Convenção `MAJOR.MINOR.PATCH`:

- **MAJOR** — mudança incompatível.
- **MINOR** — nova funcionalidade compatível.
- **PATCH** — correção compatível.

Projetos em desenvolvimento inicial começam em `0.x.y` — faixa reservada pelo
próprio SemVer para quando o contrato ainda não é estável. Não significa projeto
incompleto.

**A tag é sempre namespaced pelo componente:**

```text
compass-api/v0.1.0
routecraft_app/v1.2.0
geoprag_mobile/v1.4.0-rc.1
```

Nunca `v1.2.0` solto num projeto multi-componente — três componentes podem estar
em `0.0.1` ao mesmo tempo e a tag colide. Projeto de componente único pode usar
`vX.Y.Z` simples, mas o prefixo mantém tudo uniforme e não custa nada.

### 4.2 Versão do produto

Existem **dois níveis** de versionamento, e eles não se substituem:

```text
GeoPrag 1.0.0          ← versão do PRODUTO

mobile  → 1.4.0        ← versões dos COMPONENTES
admin   → 1.2.0
public  → 1.8.0
api     → 2.1.0
```

A versão do produto:

- tem SemVer próprio;
- identifica uma **distribuição completa** do produto;
- é decidida por Rafinha quando uma release completa é preparada;
- **não** substitui o versionamento por componente;
- **não** vira Fix Version no Jira;
- é registrada junto da composição da distribuição.

A razão de existir é rastreabilidade direta: consultar `GeoPrag 1.0.0` no
Confluence precisa responder, sem investigação retroativa, quais versões de cada
componente estavam naquela distribuição.

### 4.3 Quem decide o incremento

**Sempre Rafinha** — nunca o Claude sozinho. O incremento envolve significado de
produto, não é decisão puramente técnica. O Claude sugere com justificativa; a
decisão final é dele.

Com versionamento por componente isso vira **N decisões independentes** numa
rodada parcial, e **N+1** numa rodada completa (a do produto).

---

## 5. Os dois eixos de uma release

Todo pedido de release tem dois eixos independentes:

```text
Release Request
├── Type   → PRE_RELEASE | FINAL
└── Scope  → parcial | completa
```

### 5.1 Release Type

| Tipo | O que é |
| --- | --- |
| **PRE_RELEASE** | Versão que ainda não é a oficial. Existe para teste, QA, demonstração, validação, distribuição a terceiros, preparação da final |
| **FINAL** | Versão oficial aprovada — o estado que Rafinha aceitou como entrega |

**RC (Release Candidate)** é uma pre-release tratada como candidata à versão
final. `rc.N` é o **identificador SemVer** disso (`1.0.0-rc.1`), não um mecanismo
separado. O workflow tem dois tipos, não três.

`PRE_RELEASE` **não** significa "quase final porque passou no CI". Significa
"distribuição real disponível para validação antes da oficialização".

### 5.2 `publish` não é um tipo

`publish` é um **modo operacional**, independente do tipo:

| | Responde |
| --- | --- |
| `release_type` | "Que tipo de versão estou produzindo?" |
| `publish` | "Esta execução deve efetivamente publicar o resultado?" |

Combinações todas válidas:

```text
PRE_RELEASE + publish=false   valida o processo de pre-release sem publicar
PRE_RELEASE + publish=true    produz e publica a pre-release
FINAL       + publish=false   valida tecnicamente o processo final sem efetivá-lo
FINAL       + publish=true    produz e publica a versão oficial
```

> ⚠️ Não existe `DRY_RUN`, `TEST` ou `ENSAIO` como tipo de release. Quem tratar
> `publish=false` como um terceiro tipo está errado.

### 5.3 Release Scope

| Escopo | O que é |
| --- | --- |
| **Parcial** | Subconjunto explicitamente solicitado **para aquela execução** |
| **Completa** | Todos os componentes declarados pelo projeto, menos as exclusões permanentes do manifesto |

Release completa **não** significa "todos os componentes que parecem
importantes", nem "todos os detectados automaticamente".

**Exclusões permanentes × release parcial** são coisas diferentes:

| | O que é | Onde vive |
| --- | --- | --- |
| `full_release.exclusions` | Exceção arquitetural conhecida e permanente (componente legado, interno, não distribuível) | Manifesto |
| Release parcial | Escolha daquela execução | Release Request |

Consequências obrigatórias:

- Uma exclusão **já declarada não é questionada de novo** a cada release
  completa. É informada no resumo de escopo, não perguntada.
- Uma exclusão **não declarada nunca é inventada** durante a execução. Se um
  componente deve ficar permanentemente de fora, isso é alteração de manifesto,
  com decisão de Rafinha, **antes** da release.

> ⚠️ Release completa significa que **todos os componentes estão presentes na
> distribuição** — não que todos receberam versão nova. Um componente inalterado
> pode estar presente como `carried` (§6).

---

## 6. Dependências e `carried`

### 6.1 Dependência é declarada, nunca descoberta

As dependências entre componentes são declaradas no manifesto, em `depends_on`.

> ⚠️ **Nunca inferir dependência** por análise de código, por tentativa e erro
> ou por "parece que o app chama a API". Se a dependência não está declarada,
> ela não existe para o ciclo de release. Declarar é decisão de Rafinha.

### 6.2 Requested Scope × Effective Scope

```text
Requested Scope:        geoprag_admin

Dependency Resolution:  geoprag_admin
                              ↓
                        geoprag_api

Effective Scope:        geoprag_admin, geoprag_api
```

A expansão é apresentada a Rafinha antes da execução sempre que ela acrescentar
algo ao que foi pedido.

### 6.3 `version_scope` × `carried`

Estar no escopo efetivo **não** implica receber versão nova.

| Situação do componente | Onde entra |
| --- | --- |
| Mudou nesta rodada | `version_scope` — recebe versão nova, tag e (em FINAL) Release |
| Foi puxado por dependência e **não** mudou | `carried` — entra na distribuição na versão que já tem |

Exemplo: só o Admin mudou.

```yaml
version_scope:
  geoprag_admin: 1.2.0-rc.1
carried:
  geoprag_api: 2.1.0
```

A distribuição contém `admin 1.2.0-rc.1` + `api 2.1.0`. A API **não** recebe
versão nova só por ter sido carregada.

**Por que:** subir o número de algo que não mudou faz o histórico de versões
mentir — cria uma `2.1.1` idêntica à `2.1.0`.

### 6.4 Regra de bloqueio

Se um componente `carried` **não tem versão publicada e consumível compatível**
com o componente que depende dele, a release **para**.

> ⚠️ Nunca fabricar uma dependência. Nunca usar código local não publicado
> silenciosamente para preencher a lacuna. Isso é bloqueio (gate G3), não
> improviso.

---

## 7. CONTRATO — Manifesto central do projeto

Arquivo `.release/project.yml`. Fonte determinística de composição do projeto.

```yaml
project:
  id: geoprag                   # identificador curto, usado em nomes de arquivo
  name: GeoPrag                 # nome do produto
  topology: multi_repo          # monorepo | multi_repo
  version: 1.0.0                # SemVer atual do PRODUTO

repositories:
  - id: geoprag-api             # identificador interno
    remote: rafinha-as-br/geoprag-api
    path: ./geoprag-api         # relativo à pasta do projeto; monorepo usa "."

components:
  geoprag_api:                  # chave = nome do componente (prefixo de tag e Fix Version)
    repository: geoprag-api     # deve existir em `repositories`
    path: .                     # prefixo p/ mapear arquivos do PR -> componente
    type: spring_boot           # livre; informativo para quem lê
    version: 2.1.0              # versão atual conhecida
    version_file: pom.xml       # onde a versão vive no código
    dispatch_input: api_version # input do workflow_dispatch correspondente
    artifacts: [jar]            # o que este componente produz
    depends_on: []              # nomes de outros componentes

  geoprag_admin:
    repository: geoprag-admin
    path: .
    type: flutter_web
    version: 1.2.0
    version_file: pubspec.yaml
    dispatch_input: admin_version
    artifacts: [web_zip]
    depends_on: [geoprag_api]

full_release:
  components: ALL               # todos os declarados
  exclusions: []                # exceções arquiteturais PERMANENTES

runtime_package:
  required: true                # obrigatório declarar (true|false)
  entrypoint: runtime/start     # nome definido pelo projeto
  source: .release/runtime
```

**Onde o arquivo vive:**

| Topologia | Local | Versionado |
| --- | --- | --- |
| Monorepo | `.release/project.yml` no próprio repositório | Sim, commitado |
| Multi-repo | `.release/project.yml` na pasta mãe | Não — cópia mantida no Drive (ver §14) |

**Validação obrigatória antes de qualquer release (gate G1):**

- o arquivo existe e o schema é válido;
- todo `repository` referenciado por um componente existe em `repositories`;
- todo nome em `depends_on` existe em `components`;
- não há ciclo em `depends_on`;
- todo nome em `full_release.exclusions` existe em `components`;
- `runtime_package.required` está declarado;
- os componentes do manifesto batem com o que a Action do repositório builda.

> ⚠️ Divergência entre manifesto e `release.yml` é bug, não detalhe. Pare e
> avise Rafinha.

---

## 8. CONTRATO — Release Request

O pedido de **uma execução específica**. Registro operacional que permite
reproduzir o contexto daquela execução — **não** é registro histórico do estado
do produto (isso é o Release Manifest, §10).

```yaml
release_request:
  project: geoprag
  type: PRE_RELEASE             # PRE_RELEASE | FINAL
  product_version: 1.0.0-rc.1   # só quando a release for completa; null se parcial
  promotes: null                # em FINAL: identificador da pre-release promovida
  requested_scope: [geoprag_admin]
  effective_scope: [geoprag_admin, geoprag_api]
  version_scope:                # componente -> versão nova
    geoprag_admin: 1.2.0-rc.1
  carried:                      # componente -> versão já existente
    geoprag_api: 2.1.0
  ref: release/current          # referência base — ver §22; develop só por exceção autorizada
  commits:                      # repositório -> commit exato usado
    geoprag-admin: 9f2c1ab
    geoprag-api:   77be004
  issues:                       # componente -> issues incluídas
    geoprag_admin: [GEO-41, GEO-44]
  eligibility:                  # §22 — prova de que release/current só levou trabalho aprovado
    checked_range: 9f2c1ab..77be004
    approved:                   # issue -> commit que a trouxe
      GEO-41: 3ac91fe
      GEO-44: b207d5c
    exceptions: []              # exceções autorizadas por Rafinha; vazio = nenhuma
  created_at: 2026-09-12T14:00:00Z
```

**`eligibility` é obrigatório.** Um Release Request sem esse bloco não pode
ser executado — ele é a evidência de que o gate G10 rodou, não um campo
opcional de auditoria. O Orchestrator recusa o request na validação.

`exceptions: []` é obrigatório mesmo vazio. Ausência silenciosa não é
permitida: a lista vazia afirma "verifiquei e não houve exceção", enquanto o
campo ausente não afirma nada.

Cada exceção tem **quatro campos, todos obrigatórios**:

```yaml
    exceptions:
      - item: GEO-52            # issue ou épico que ficou fora da regra
        risco: "Fluxo de exportação não passou por QA sobre a develop"
        autorizacao: "pode seguir sem o QA da 52, eu valido na mão depois"
        impacto: "Se a exportação quebrar, a correção sai em PATCH"
```

Exceção com campo faltando **não é exceção, é lacuna** — e o Orchestrator
bloqueia.

**Onde vive:** `.release/requests/<data>-<tipo>.yml`, seguindo a mesma regra de
versionamento do manifesto. Uma cópia vai dentro do ZIP da distribuição.

**Quem produz:** a `jira-release-executor`, depois das decisões de Rafinha.
**Quem consome:** o Release Orchestrator.

---

## 9. CONTRATO — Release Action (por repositório)

Cada projeto escreve a sua. O workflow padroniza apenas a **interface**.

### 9.1 Inputs

| Input | Valor | Semântica |
| --- | --- | --- |
| `<componente>_version` | SemVer ou vazio | um por componente do repositório; vazio = fora da rodada |
| `release_type` | `pre_release` \| `final` | que tipo de versão está sendo produzida |
| `publish` | boolean | se esta execução publica o resultado |

### 9.2 Saídas obrigatórias

| Contrato | O que significa |
| --- | --- |
| **Artefato identificável** | nome determinístico `<componente>-<versao>`, para um agregador achar sem adivinhar |
| **Artefato recuperável** | disponível para download por um consumidor autorizado, com retenção suficiente para a distribuição ser montada e validada |
| **Versão rastreável** | tag `<componente>/vX.Y.Z[-rc.N]` apontando o commit que produziu o artefato — **sempre**, inclusive em pre-release |
| **Publicação diferenciada** | a Action distingue `pre_release` de `final` ao publicar (§9.3) |
| **Notas** | `.github/release-notes/<comp>-<versao>.md` → fallback `<comp>-<versao-base>.md` → fallback automático |

> O **mecanismo** de publicação e de download é detalhe de implementação, não
> arquitetura. `gh release download`, download de workflow artifact, API do
> GitHub ou outra estratégia se escolhem na implementação. O contrato exige
> apenas: *a Action publica de forma recuperável; o Orchestrator obtém, valida e
> agrega.*

O fallback de dois níveis nas notas evita três arquivos idênticos por `rc.N`:
`routecraft_app-1.4.0.md` serve `rc.1`, `rc.2` e a final. Um arquivo específico
de rc só existe quando houver algo a dizer só daquele rc.

### 9.3 Quando se cria GitHub Release

| Situação | Tag | Artefato | GitHub Release |
| --- | --- | --- | --- |
| `PRE_RELEASE`, qualquer escopo | sim | sim | **não** |
| `FINAL` parcial | sim | sim | **sim**, do componente |
| `FINAL` completa | sim | sim | **sim**, do componente |
| Distribuição do produto (ZIP) | — | — | **nunca** |

A regra em uma frase: **toda versão final tem lugar durável de download; nenhum
RC polui a área de Releases; nenhum repositório vira dono do produto.**

Consequências:

- A distribuição agregada vai para o Drive e é registrada no Confluence (§13),
  nunca para uma GitHub Release.
- Quem guarda um rc a longo prazo é o ZIP armazenado, não o GitHub.
- Como pre-release não cria Release, não existe o problema de um `rc.N`
  aparecer como `Latest`.

### 9.4 O que a Action nunca faz

- decidir incremento de versão;
- ler o Jira ou tratá-lo como fonte de verdade;
- decidir quais issues pertencem à release;
- montar a distribuição agregada (isso é do Orchestrator);
- presumir tecnologia de banco, Docker, Flutter ou qualquer stack universal;
- assumir acesso ao computador local de Rafinha (emulador, dispositivo, Drive).

---

## 10. CONTRATO — Runtime Package

Convenção oficial do workflow, implementação livre, existência **declarada**.

```yaml
runtime_package:
  required: true | false
  entrypoint: runtime/start     # nome definido pelo projeto
  source: .release/runtime
```

| `required` | Significado | Consequência |
| --- | --- | --- |
| `true` | A versão distribuída precisa de runtime para ser executada | Release **completa** sem Runtime Package funcional é **bloqueio** (G7) |
| `false` | O projeto declarou que não precisa | Exige, no Confluence: a **justificativa** e **como a versão distribuída é executada sem ele** |

> ⚠️ Ausência silenciosa nunca é permitida. O campo é obrigatório no manifesto, e
> `required: false` sem a página correspondente é falha de setup.

**Contrato mínimo quando existe:** um entrypoint oficial para iniciar a versão
distribuída.

```text
runtime/
└── start
```

O nome do entrypoint e a implementação interna são do projeto. O workflow **não
impõe** Docker, PostgreSQL, Flutter nem qualquer outra tecnologia. Exemplos
igualmente válidos:

```text
runtime/start → docker compose up
runtime/start → sobe servidor HTTP local + API + banco
runtime/start → executa aplicação desktop
```

**Compatibilidade runtime ↔ versão:** o runtime não tem versão própria, mas o
Release Manifest registra de qual runtime aquele ZIP saiu — commit quando
versionado (monorepo), checksum do conteúdo quando não (multi-repo). Uma
distribuição nunca usa scripts de runtime de uma versão incompatível.

---

## 11. CONTRATO — Distribuição e Release Manifest

### 11.1 Estrutura da distribuição

```text
geoprag-1.0.0-rc.1.zip
├── artifacts/
│   ├── geoprag_api/geoprag-api-2.1.0.jar
│   ├── geoprag_admin/web.zip
│   └── geoprag_mobile/geoprag-mobile-1.4.0.apk
├── runtime/
│   └── start
├── release-manifest.yml
└── release-request.yml
```

Só entra o que o projeto realmente tem. O workflow **não** impõe que toda
distribuição possua API, Web, Mobile, banco ou Docker.

### 11.2 Release Manifest

Registro do que **efetivamente foi produzido**. Viaja dentro do ZIP.

```yaml
project: geoprag
product_version: 1.0.0-rc.1
release_type: pre_release
created_at: 2026-09-12T15:10:00Z
source_request: 2026-09-12-pre.yml
components:
  geoprag_mobile:
    version: 1.4.0
    commit: 3ac91f2
    tag: geoprag_mobile/v1.4.0
    artifact: geoprag-mobile-1.4.0.apk
    carried: false
  geoprag_api:
    version: 2.1.0
    commit: 77be004
    tag: geoprag_api/v2.1.0
    artifact: geoprag-api-2.1.0.jar
    carried: true
runtime:
  entrypoint: runtime/start
  checksum: sha256:1d0ee43…
```

**O Manifest precisa responder sozinho a oito perguntas:**

1. Qual é a versão do produto?
2. Quais componentes estão dentro?
3. Qual a versão de cada componente?
4. Qual commit de cada componente foi usado?
5. Quais componentes foram versionados nesta release?
6. Quais foram `carried`?
7. Qual Runtime Package foi utilizado?
8. Qual Release Request originou a distribuição?

Se alguma dessas respostas não sai do arquivo, o Manifest está incompleto.

---

## 12. CONTRATO — Release Orchestrator

Scripts locais do projeto, em `.release/scripts/`. **Não** é GitHub Action.
Determinístico: recebe um Release Request já fechado e executa.

```text
orchestrate -Request .release/requests/2026-09-12-final.yml

 1. validar o manifesto (schema, ciclos, repositórios declarados)
 2. validar o estado local dos repositórios (existe, limpo, no commit esperado)
 3. resolver o effective scope a partir de depends_on
 4. disparar as Release Actions necessárias
 5. aguardar os resultados
 6. coletar os artefatos publicados
 7. montar dist/artifacts/<componente>/
 8. copiar o Runtime Package
 9. gerar release-manifest.yml + copiar o release-request.yml
10. gerar o ZIP, nomeado com a versão do produto
```

**Pode:** validar manifesto; validar repositórios; resolver dependências
declaradas; consumir e gerar Release Request; **disparar Release Actions**;
aguardar resultados; coletar artefatos; montar a distribuição; copiar o Runtime
Package; gerar o Release Manifest; gerar o ZIP.

**Não pode:** ler o Jira para tomar decisões; decidir versão; decidir escopo de
negócio; inventar dependência; escolher MAJOR/MINOR/PATCH; aprovar produto;
executar análise humana; substituir a skill.

> **O Orchestrator dispara, mas não decide.** Ele recebe tipo, escopo, versões e
> commits já fechados. Toda decisão de negócio aconteceu antes dele.

**Coleta depende do tipo** (consequência de §9.3): em `FINAL` existe GitHub
Release do componente para baixar; em `PRE_RELEASE` não existe, e a coleta sai do
artefato da execução. Dois caminhos de obtenção, um contrato só.

O Orchestrator **só participa quando há o que agregar**. Uma release parcial que
produz um artefato para uso direto não passa por ele.

---

## 13. Fontes de verdade

Não existem fontes concorrentes sobre a mesma informação. Cada sistema responde
uma pergunta diferente.

| Sistema | Responde | Não responde |
| --- | --- | --- |
| **Jira** | Qual trabalho foi feito: issues, status, Fix Versions | Composição técnica de uma distribuição |
| **GitHub** | Verdade técnica dos repositórios: código, commits, artefatos | Contexto de negócio ou decisão de escopo |
| **Release Request** | O que foi pedido **naquela execução** | Estado histórico do produto |
| **Release Manifest** | O que foi **efetivamente produzido** naquela distribuição | Por que aquelas issues entraram |
| **Confluence** | Documentação operacional e índice histórico acessível | Nada que já não venha do Manifest — ele **copia**, não reinterpreta |

Regras:

- Jira e GitHub permanecem sincronizados pelas regras já existentes do workflow.
- Para cada distribuição agregada relevante, o Confluence guarda uma **cópia do
  conteúdo do Release Manifest** — nunca uma segunda versão escrita à mão.
- O ZIP armazenado é o portador do Manifest; o Confluence é o índice
  pesquisável. Mesmo conteúdo, papéis diferentes.

---

## 14. Limitação aceita: multi-repo sem Git

Em projetos multi-repo, a pasta mãe **não é Git**, não tem histórico Git e **não
será transformada em repositório**. A limitação concreta é uma só:

> O estado atual do `.release/project.yml` não possui histórico Git próprio.

Isso é **decisão consciente**, não erro de arquitetura nem lacuna a corrigir
depois. Deve aparecer documentada, não escondida.

A rastreabilidade histórica da composição do produto é preservada por três
registros, que por isso deixam de ser opcionais:

```text
Release Manifest  +  ZIP armazenado  +  registro no Confluence
```

O manifesto do Drive responde "como o projeto está hoje". Os ZIPs respondem
"como o projeto estava em cada versão".

---

## 15. Pre-release → validação → Final

```text
PRE_RELEASE → validação humana → aprovação → FINAL
```

Nem toda pre-release vira final:

```text
1.0.0-rc.1 → reprovada → correção
1.0.0-rc.2 → reprovada → correção
1.0.0-rc.3 → aprovada  → 1.0.0
```

**Promoção.** A final não é produzida silenciosamente a partir de outro estado de
código. Quando uma FINAL promove uma pre-release validada:

- o Release Request carrega `promotes: <identificador do rc>`;
- os commits vêm do **Release Manifest daquele rc**, não do `HEAD` da branch;
- o Orchestrator verifica que cada repositório está nesses commits e **para** se
  algum divergiu (gate G8).

Uma FINAL sem promoção é legítima (projeto pequeno, mudança simples): aí os
commits vêm do `ref` informado.

**Validação da distribuição.** Antes de promover, Rafinha baixa o pacote, executa
fora da IDE e valida o produto real. É especialmente importante quando existe
Runtime Package — é o que separa "o CI passou" de "o produto funciona quando
alguém o executa".

A `jira-human-validation-executor` pode **recomendar** a geração de uma
pre-release quando um cenário só for validável na distribuição real. Ela
recomenda; quem decide gerar é Rafinha. O veredito é registrado na página
"Validação da Release" do projeto — sem issue nova, sem misturar os dois ciclos.

---

## 16. Fronteira skill / Orchestrator / Action

> A **Action** faz o que é determinístico dentro de um repositório.
> O **Orchestrator** faz o que é determinístico entre repositórios.
> A **skill** faz o que exige contexto de Jira, Confluence e decisão humana.
> Ninguém reimplementa o vizinho, e ninguém decide pelo vizinho.

```text
Rafinha solicita Release
        ↓
jira-release-executor: Type + Requested Scope
        ↓
resolver dependências declaradas → Effective Scope
        ↓
version_scope + carried
        ↓
Rafinha decide as versões (componentes + produto)
        ↓
Release Request
        ↓
Release Orchestrator: dispara Actions → aguarda → coleta artefatos
        ↓
monta distribuição + Runtime Package + release-manifest.yml → ZIP
        ↓
Rafinha valida a distribuição fora da IDE
        ↓
aprovação → FINAL (promovendo o rc validado)
        ↓
Jira (Fix Versions) + Confluence (cópia do Manifest) + Drive (ZIP)
```

Release parcial que **não** gera distribuição:

```text
Rafinha → Type + Scope → skill dispara a Action → artefato → uso/teste
```

**Propriedade do desenho que não pode se perder:** a Action continua sendo um
`workflow_dispatch` comum. Rafinha fecha um componente pela aba Actions do
GitHub sem skill e sem Orchestrator. O que se perde rodando assim é a qualidade
das notas, a Fix Version no Jira e a distribuição agregada — não a capacidade de
lançar.

---

## 17. Notas de release

A Release de cada componente carrega uma descrição **escrita para qualquer
pessoa ler** — inclusive quem não acompanhou a sprint e não sabe o que é CPS-107.
Listar issues ou Pull Requests não cumpre esse papel.

Mecanismo: a `jira-release-executor` escreve
`.github/release-notes/<componente>-<versao>.md` a partir do campo `Resumo` das
issues e commita **antes** do dispatch.

Princípios do texto:

- descrever a mudança do ponto de vista de **quem usa o sistema**;
- agrupar por tema, não por issue (três issues do mesmo assunto viram um
  parágrafo só);
- chaves de issue, quando presentes, ficam no fim como referência — nunca no
  lugar da explicação;
- sem jargão interno (nome de branch, de arquivo, de classe);
- breaking change sempre aparece, com o que a pessoa precisa fazer a respeito.

---

## 18. A entidade Release no Jira

Usa a estrutura nativa de Releases/Versions (**Fix Version**). Não é pai
hierárquico de Épico/Issue/Subtask — é relação de versionamento:

- **Release** responde: "quais mudanças compõem esta versão?"
- **Épico** responde: "qual grande iniciativa estamos desenvolvendo?"

Regras:

- **Nome namespaced**, igual à tag: `routecraft_app 0.2.0`, nunca `0.2.0` solto.
- **Só em release FINAL.** `rc.N` não vira Fix Version — a lista de versões do
  projeto responde "em que versão isso saiu?", e rc's poluiriam essa resposta. A
  rastreabilidade do rc fica no Release Manifest e no ZIP.
- **Só por componente.** A versão do produto não vira Fix Version.
- **Multi-valorada.** Uma issue que tocou dois componentes recebe uma Fix Version
  por componente, à medida que cada um for lançado.

```text
CPS-107  Fix Version: routecraft_app 0.2.0     ← lançado hoje
                      compass-api 0.1.0        ← lançado depois
```

A issue só está **inteiramente entregue** quando todos os componentes que ela
tocou saíram.

---

## 19. Documentação obrigatória do projeto

Todo projeto que usa o ciclo de Release tem, no seu space do Confluence, a
página **`CI/CD - Workflow Rafinha-Claude`** e suas filhas:

```text
CI/CD - Workflow Rafinha-Claude
├── Projeto e Componentes
├── Build e Artefatos
├── Execução de uma Versão
├── Runtime Package
├── Banco e Infraestrutura Local      (quando aplicável)
├── CI/CD
├── Release                           ← índice das distribuições + cópia dos Manifests
├── Validação da Release
├── Versionamento                     ← produto + componentes
└── Release Multi-Repository          (obrigatória se topology = multi_repo)
```

Quem escreve essa árvore é a `workflow-doc-writer`, trilha `release-doc`
(template `workflow-doc-writer/references/release-doc.md`) — tanto a montagem
inicial pedida pelo G0 quanto a entrada de cada distribuição no registro G9.
A `jira-release-executor` delega; não escreve as páginas.

**Para as informações operacionais do Release, a fonte de verdade do projeto é o
Confluence.** Antes da primeira release, precisa ser possível responder:

```text
Quais são os componentes?
Quais são os repositórios?
Como cada componente é construído?
Quais artefatos são produzidos?
Como uma versão é executada?
Quais dependências existem?
Como funciona a release completa?
Existe Runtime Package? Como ele é executado?
Como a versão é validada?
```

> ⚠️ Se essas respostas não estão documentadas, a release **não começa**. Isso é
> pendência de setup (gate G0), não algo a improvisar durante a execução. O
> executor de release **nunca inventa** informação ausente dessa documentação.

---

## 20. Release Build ≠ CI Build

| | Pergunta que responde |
| --- | --- |
| **CI** (`ci.yml`, etapa de Integração) | "Essa alteração pode entrar no sistema?" |
| **Release** (`release.yml`) | "Este conjunto específico de código está pronto para virar uma versão?" |

Pode haver comandos comuns entre os dois. A finalidade é diferente, e por isso
são workflows separados.

**Artifact ≠ Release:**

```text
Build → Artifact → Release
```

Artifact é o resultado de uma execução (APK, JAR, ZIP, EXE, pacote Web, imagem).
Release é a representação versionada e distribuível de um estado do software,
que pode carregar artifacts como assets.

---

## 21. Gates do ciclo

| Gate | Quem valida | Bloqueia |
| --- | --- | --- |
| **G0 Documentação** | skill | Árvore `CI/CD - Workflow Rafinha-Claude` ausente ou incompleta |
| **G1 Manifesto** | skill / orchestrator | `.release/project.yml` ausente, inválido, com ciclo, ou divergente do `release.yml` |
| **G2 Escopo** | Rafinha | Effective Scope não confirmado |
| **G3 Dependência consumível** | skill / orchestrator | Componente `carried` sem versão publicada compatível |
| **G4 Versão** | Rafinha | Incremento não confirmado — por componente, mais o do produto quando completa |
| **G5 Notas** | skill | Notas não commitadas antes do dispatch |
| **G6 Execução** | Action / Orchestrator | Qualquer falha técnica |
| **G7 Distribuição** | Rafinha | Release completa sem Runtime Package funcional quando `required: true`, ou FINAL sem execução real fora da IDE |
| **G8 Promoção** | orchestrator | FINAL que promove um rc, com repositório fora dos commits daquele rc |
| **G9 Registro** | skill | Fix Versions, Confluence e cópia do Drive não atualizados |
| **G10 Elegibilidade** | skill | `develop` contém commit que não rastreia para issue com `qa-develop-aprovado` (§22) |

> Os números dos gates são **identificadores, não ordem de execução**. G10 é o
> mais recente a entrar no ciclo, mas roda cedo: antes da promoção
> `develop → release/current`, logo depois de as versões serem decididas.

**Falha em gate é bloqueio de avanço**, mesmo princípio das demais camadas de
validação do workflow. Corrija e repita. Nunca contorne fazendo o passo na mão.

---

## 22. Promoção para `release/current`

A promoção `develop → release/current` é o ponto em que trabalho integrado
vira trabalho **candidato a ser publicado**. Ela não é um merge qualquer.

### A regra

```text
A skill de release não pode mergear develop → release/current se a develop
contiver alterações não aprovadas que seriam levadas junto.
```

O problema é que o merge não é seletivo: ele leva **tudo** que está na
`develop`. Não existe "promover só as issues do escopo" — ou a `develop`
inteira está apta, ou a promoção para.

### Critério de estabilidade por épico

1. Todas as issues obrigatórias do épico foram integradas na `develop`.
2. Todas foram testadas em `QA - Claude` **sobre a `develop`**.
3. Todas possuem a label `qa-develop-aprovado`.
4. Não existem issues obrigatórias do épico pendentes de QA, correção ou
   decisão.

### G10 — como a elegibilidade é provada

A label `qa-develop-aprovado` diz que uma **issue** passou. O gate precisa
provar algo mais forte: que **todo commit** que vai entrar em
`release/current` pertence a uma issue que passou.

O caminho é o nome da branch. A convenção `{tipo}/<ISSUE-KEY>-claude` é
mantida pela `jira-issue-executor` em toda issue de código, o que significa
que cada merge commit na `develop` carrega a chave da issue no seu segundo
pai.

```text
1. Calcular o intervalo  release/current..develop
2. Para cada merge commit do intervalo:
     extrair a chave da issue do nome da branch de origem
3. Para cada chave extraída:
     verificar a presença de `qa-develop-aprovado`
4. BLOQUEAR se:
     - commit sem chave extraível        (inclui commit direto na develop)
     - chave sem `qa-develop-aprovado`
     - chave que não resolve para issue existente
5. Registrar o mapeamento commit → issue → label no bloco `eligibility`
   do Release Request (§8), aprovado ou bloqueado
```

**Commit direto na `develop`, sem Pull Request, bloqueia a promoção.** É
deliberado: um commit sem PR é, por construção, um commit que não passou por
QA. Se o trabalho é legítimo, o caminho é a exceção autorizada — não o
silêncio.

> ⚠️ A primeira promoção de um projeto não tem `release/current` para
> comparar. Nesse caso o intervalo é decidido com Rafinha — tipicamente a
> última tag publicada, ou o ponto em que o projeto adotou o workflow. Isso
> é **pergunta**, não inferência.

### Exceção autorizada

Rafinha pode autorizar explicitamente a promoção mesmo com item fora da
regra. Quando isso acontece, a skill registra, no bloco `eligibility` e no
Confluence:

1. Qual issue ou épico ficou fora da regra padrão.
2. Qual risco foi aceito.
3. A frase ou comando de autorização de Rafinha.
4. O impacto esperado na release.

Exceção sem esses quatro itens registrados **não é exceção, é lacuna** — e a
skill não prossegue.

### O bump é dividido em dois

Depois da promoção, o commit de bump vai **direto na `release/current`**.
Isso significa que a `release/current` carrega o estado estabilizado **e já
versionado** da release.

Mas a Action continua tendo um step de bump, e isso **não é duplicação**:

| Parte | Onde é aplicada | Por quê |
| --- | --- | --- |
| Versão semântica (`1.2.0`) | commit na `release/current`, pela skill | É decisão de Rafinha e pertence à linha persistente |
| Metadado de build (`+<run_number>`) | branch efêmera, pela Action | Só existe no contexto daquela execução |

Na prática, o step de bump da Action roda `versions:set` com a mesma versão
que já está no arquivo, não gera diff para a parte semântica, e o
`git diff --quiet` do template resolve sozinho. **Por isso a migração do bump
para a `release/current` não exige mudança no `release.yml`.**

> Não "corrija" o step de bump da Action achando que ele virou redundante.
> Em stacks que usam build number (Flutter, Android), ele ainda é o que
> carimba o `+<run_number>` — e esse carimbo pertence à execução, não à
> linha de estabilização.
