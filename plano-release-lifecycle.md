# Plano de implementação — Release Lifecycle do Workflow Rafinha-Claude

Documento de planejamento e **registro de implementação**. As fases 0–6 e 8
estão implementadas (§0 e §10); resta o piloto ponta a ponta.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-12 | Versão inicial, a partir da análise do estado atual × `Plano de atualização — Release Lifecycle` |
| 2026-09-12 | 14 decisões tomadas por Rafinha (§8) |
| 2026-09-12 | 14 ajustes aplicados a partir de `Ajustes ao plano de implementação` — **D5 revisada**, D11 refinada, 1 decisão nova levantada |
| 2026-09-12 | **D15 decidida (opção A)**: GitHub Release por componente só em release FINAL. Nenhuma decisão em aberto — plano pronto para a fase 0 |
| 2026-09-12 | **Fases 0–6 e 8 implementadas** (ver §10). Resta a fase 7 (piloto ponta a ponta) e a migração do Compass, que é trilha separada |

---

## 0. Status de implementação

| Fase | Status | Onde |
| --- | --- | --- |
| 0. Contratos | ✅ | fundida na fase 1 — os contratos **são** o arquivo de referência, escrevê-los em documento separado seria retrabalho |
| 1. Skill mãe | ✅ | `workflow-development-flow/references/release-lifecycle.md` (novo) + seção 10 do `SKILL.md` reduzida a resumo |
| 2. Templates de repositório | ✅ | `templates/project.yml` (novo), `release.yml` (reescrito), `release-notes-README.md` (fallback por versão base), `release-components.yml` (removido) |
| 3. Orchestrator + Runtime | ✅ | `templates/orchestrator/` e `templates/runtime/` (novos) |
| 4. Skill executora | ✅ | `jira-release-executor/SKILL.md` reescrita nas 7 fases |
| 5. Confluence do workflow | ✅ | 6 páginas novas, 5 atualizadas (ver §10) |
| 6. Validação Humana | ✅ | `jira-human-validation-executor/SKILL.md` + página do Confluence |
| 7. Piloto ponta a ponta | ⬜ | pendente — precisa de um projeto real |
| 8. Fechamento | ✅ | `README.md` atualizado, template antigo removido |
| Migração do Compass | ⬜ | trilha separada, por decisão (D2) |

Princípio que organiza o plano: **primeiro o contrato, depois a implementação.**

---

## 1. Estado atual analisado

| Peça | Onde | Situação |
| --- | --- | --- |
| Skill mãe, seção 10 (Release & Versionamento) | `workflow-development-flow/SKILL.md:489-771` | 10 subseções, ~280 linhas dentro de um SKILL.md de 1244 |
| Skill executora | `jira-release-executor/SKILL.md` | 10 passos, ciclo completo repo-único |
| Template do workflow | `jira-release-executor/templates/release.yml` | 255 linhas, fortemente acoplado ao Compass System |
| Template do manifesto | `jira-release-executor/templates/release-components.yml` | `.github/release-components.yml`, lista plana de componentes |
| Template das notas | `jira-release-executor/templates/release-notes-README.md` | OK conceitualmente, precisa de ajuste para pre-release |
| Confluence — conceito | CS1 › Workflow › `Release & Versionamento` (44335153) | Espelha a seção 10 da skill mãe |
| Confluence — setup | CS1 › Como montar… › `9. Configurar o ciclo de Release` (44531714) | Checklist de instalação, repo-único |
| Confluence — projeto | CS › `Versionamento` (60194817) | Página solta no space do projeto, sem árvore de CI/CD |

**Preservado inteiro:** separação Release × 8 etapas; proibição de coluna
"Release" no Jira; componente como unidade versionada; tag namespaced
`<componente>/vX.Y.Z`; Fix Version multi-valorada; decisão de versão sempre de
Rafinha; notas de release como texto corrido; falha = bloqueio; template como
fonte de verdade.

---

## 2. Diagnóstico

### 2.1 O que está específico demais para um projeto

| Linha/bloco de `templates/release.yml` | Problema |
| --- | --- |
| Step "Montar o pacote de demo (compass-demo.zip)" | Docker + `docker save` de `postgres:15` e `nginx:alpine` + `seed_test_data.py` + `deploy/demo/*.bat` — decisões de UM projeto vendidas como template |
| Toolchains fixas (JDK 17 + Maven + Flutter 3.35.5) | Assume a stack do Compass |
| `routecraft_version` / `travel_matrix_version` / `api_version` | Nomes de componentes reais nos inputs, no bump, no build e nas chamadas de tag |
| `upload-artifact` com nomes `compass-demo` e `componentes` | Nome não determinístico — impossível um agregador buscar por contrato |

O "pacote de demo" é, na prática, um **Runtime Package + distribuição embutidos
no template**. Com D6, essa montagem sai do workflow e passa ao Orchestrator.

### 2.2 Conflitos entre o estado atual e o modelo novo

| # | Modelo novo | Estado atual | Natureza |
| --- | --- | --- | --- |
| C1 | Projeto ≠ repositório; projeto pode ser multi-repo | Skill assume `cwd` = o único repositório | Estrutural |
| C2 | Dois eixos: `Type` e `Scope` | Não existe eixo Type; RC aparece como passo 7 **depois** do dispatch — incoerente | Estrutural |
| C3 | `depends_on` declarado; Requested × Effective Scope; `carried` | Não existe dependência entre componentes | Novo |
| C4 | Artifact ≠ Release; artefato identificável e recuperável | Artefatos com nome livre, não consumíveis por um agregador | Contrato |
| C5 | Runtime Package como convenção declarada | Embutido no template como pacote de demo | Estrutural |
| C6 | Distribuição agregada + versão de produto + `release-manifest.yml` | Não existe conceito de distribuição de produto | Novo |
| C7 | Release Orchestrator local em todo projeto, que também dispara Actions | Não existe | Novo |
| C8 | Manifesto central `.release/project.yml` | `.github/release-components.yml`, schema diferente | Migração |
| C9 | Confluence do projeto como documentação operacional obrigatória | Só existe a página `Versionamento` | Estrutural |
| C10 | Documentação mínima é pré-requisito da primeira release | Skill só bloqueia por falta do manifesto | Novo gate |
| C11 | `PRE_RELEASE` é o tipo; `rc.N` é identificador; promoção rc → final | Skill trata "Release Candidate" como mecanismo à parte | Nomenclatura |
| C12 | Pre-release e Final pelo mesmo mecanismo; `publish` é modo operacional | `release.yml` só tem `publish: bool`, sem `--prerelease` | Implementação |

### 2.3 Incoerências internas encontradas de passagem

- Skill mãe 10.7 numera o ciclo até o **passo 12** e manda atualizar o Confluence
  "no passo 12"; a skill tem **10 passos**. Renumerar na reescrita.
- As notas usam `<comp>-<versao>.md`. Com `rc.N` isso gera três arquivos
  idênticos. Precisa de fallback (§3.4).

---

## 3. Arquitetura final

### 3.1 Três níveis

```text
NÍVEL DE CONTEXTO     jira-release-executor
                      Jira, Confluence, decisão de Rafinha, escopo, versões, notas
                            │  entrega o Release Request
                            ▼
NÍVEL DE PRODUTO      Release Orchestrator (PowerShell, local, do projeto)
                      valida, dispara Actions, aguarda, coleta, agrega, empacota
                            │
                            ▼
NÍVEL DE COMPONENTE   Release Action (uma por repositório)
                      build, package, publicação técnica do artefato
```

> A **Action** faz o que é determinístico dentro de um repositório.
> O **Orchestrator** faz o que é determinístico entre repositórios — incluindo
> **disparar as Actions** e aguardar seus resultados.
> A **skill** faz o que exige contexto de Jira, Confluence e decisão humana.
> Ninguém reimplementa o vizinho, e ninguém toma decisão do vizinho.

**O Orchestrator dispara, mas não decide** (D5 revisada). Ele recebe um Release
Request já fechado — tipo, escopo, versões e commits decididos — e executa. Toda
decisão de negócio já aconteceu antes dele.

O invariante antigo continua de pé: a Action segue sendo `workflow_dispatch`
comum, então **Rafinha continua podendo fechar um componente pela aba Actions**,
sem skill e sem Orchestrator. O que o Orchestrator faz é evitar que ele *precise*
disso quando há vários repositórios envolvidos.

Quem dispara, por caso:

| Caso | Quem dispara |
| --- | --- |
| Release parcial, sem distribuição a montar | a skill, direto (`gh workflow run`) |
| Release que gera distribuição (completa, ou parcial agregada) | o Orchestrator |
| Operação manual/excepcional | Rafinha, pela aba Actions |

### 3.2 Manifesto central do projeto — `.release/project.yml`

```yaml
project:
  id: geoprag
  name: GeoPrag
  topology: multi_repo          # monorepo | multi_repo
  version: 1.0.0                # SemVer do PRODUTO (D3)

repositories:
  - id: geoprag-api
    remote: rafinha-as-br/geoprag-api
    path: ./geoprag-api         # monorepo: path "."

components:
  geoprag_api:
    repository: geoprag-api
    path: .                     # prefixo p/ mapear arquivos do PR -> componente
    type: spring_boot
    version: 2.1.0              # versão atual conhecida
    version_file: pom.xml
    dispatch_input: api_version
    artifacts: [jar]
    depends_on: []

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
  components: ALL
  exclusions:                   # exceção arquitetural PERMANENTE (D11)
    - legacy_component

runtime_package:
  required: true
  entrypoint: runtime/start     # nome configurável pelo projeto
  source: .release/runtime
```

**Exceções permanentes × release parcial** — são coisas diferentes e o plano
não pode confundi-las:

| | O que é | Onde vive |
| --- | --- | --- |
| `full_release.exclusions` | Exceção arquitetural conhecida e permanente (componente legado, interno, não distribuível) | Manifesto, versionado/declarado |
| Release parcial | Subconjunto escolhido para **aquela** execução | Release Request daquela rodada |

Consequências para a skill:

- Uma exclusão já declarada **não é questionada de novo** a cada release
  completa. Ela é informada no resumo de escopo, não perguntada.
- Uma exclusão **não declarada nunca é inventada** durante a execução. Se um
  componente deveria ficar de fora permanentemente, isso vira alteração de
  manifesto, com decisão de Rafinha, antes da release.

**Onde o arquivo vive (D1):**

| Topologia | Local | Versionado? |
| --- | --- | --- |
| Monorepo | `.release/project.yml` no próprio repositório | Sim, commitado |
| Multi-repo | `.release/project.yml` na pasta mãe | **Não** — cópia mantida no Drive |

Substitui `.github/release-components.yml`, sem compatibilidade retroativa (D2).

### 3.3 Release Request — o contrato central novo

O pedido de **uma execução específica**. Não é registro histórico permanente do
produto (isso é o Release Manifest, §3.6) — é o que permite reproduzir o
contexto daquela execução.

```yaml
release_request:
  project: geoprag
  type: PRE_RELEASE             # PRE_RELEASE | FINAL
  product_version: 1.0.0-rc.1   # só quando a release for completa (D3, D12)
  promotes: null                # em FINAL: a pre-release validada que está sendo promovida
  requested_scope: [geoprag_admin]
  effective_scope: [geoprag_admin, geoprag_api]
  version_scope:                # recebe versão nova
    geoprag_admin: 1.2.0-rc.1
  carried:                      # entra na distribuição sem versão nova (D10)
    geoprag_api: 2.1.0
  ref: develop
  commits:
    geoprag-admin: 9f2c1ab
    geoprag-api:   77be004
  issues:
    geoprag_admin: [GEO-41, GEO-44]
  created_at: 2026-09-12T14:00:00Z
```

Onde vive: `.release/requests/<data>-<tipo>.yml`, seguindo a regra de
versionamento do manifesto (D1). Uma cópia vai dentro do ZIP da distribuição.

### 3.4 Contrato da Release Action (por repositório)

Cada projeto escreve a sua. O workflow-mãe padroniza só a interface.

**Inputs**

| Input | Valor | Responde |
| --- | --- | --- |
| `<componente>_version` | SemVer ou vazio | quais componentes deste repo entram na rodada |
| `release_type` | `pre_release` \| `final` | **que tipo de versão estou produzindo** |
| `publish` | boolean | **esta execução deve efetivamente publicar o resultado** |

`publish` **não é um terceiro tipo de release**. Os dois eixos são
independentes: `PRE_RELEASE + publish=false` valida o processo de pre-release
sem publicar; `FINAL + publish=false` valida tecnicamente o processo final sem
efetivá-lo. Não existe `DRY_RUN`, `TEST` ou `ENSAIO` como tipo.

**Saídas — contrato, não implementação**

| Contrato | O que significa |
| --- | --- |
| Artefato identificável | nome determinístico `<componente>-<versao>`, para que um agregador ache sem adivinhar |
| Artefato recuperável | disponível para download por um consumidor autorizado, com retenção suficiente para a distribuição ser montada |
| Versão rastreável | tag `<componente>/vX.Y.Z[-rc.N]` apontando o commit que produziu o artefato |
| Publicação diferenciada | a Action distingue `pre_release` de `final` ao publicar |
| Notas | `.github/release-notes/<comp>-<versao>.md` → fallback `<comp>-<versao-base>.md` → fallback automático |

**O mecanismo de publicação e de download é detalhe de implementação, não
arquitetura.** `gh release download`, download de workflow artifact, API do
GitHub ou outra estratégia se escolhem na fase de implementação. O contrato
exige apenas: *a Action publica de forma recuperável; o Orchestrator obtém,
valida e agrega.*

O fallback de dois níveis nas notas evita três arquivos idênticos por `rc.N`:
`routecraft_app-1.4.0.md` serve `rc.1`, `rc.2` e a final.

**O que a Action não faz:** decidir incremento, ler Jira, montar a distribuição
agregada (D6), assumir Docker/banco/stack, tocar a máquina de Rafinha.

**Quando a Action cria GitHub Release (D15):**

| Situação | Tag | Artefato | GitHub Release |
| --- | --- | --- | --- |
| `PRE_RELEASE` (qualquer escopo) | sim, `…-rc.N` | sim, recuperável | **não** |
| `FINAL` parcial | sim | sim | **sim**, do componente |
| `FINAL` completa | sim | sim | **sim**, do componente |
| Distribuição do produto (ZIP) | — | — | **nunca** — vai para Drive + Confluence (D9) |

A regra em uma frase: **toda versão final tem lugar durável de download; nenhum
RC polui a área de Releases; nenhum repositório vira dono do produto.**

Efeito colateral que deixa de existir: como pre-release não cria Release, some a
preocupação de um `rc.N` aparecer como `Latest`.

### 3.5 Runtime Package — contrato

```yaml
runtime_package:
  required: true | false
  entrypoint: runtime/start     # nome definido pelo projeto
  source: .release/runtime
```

| `required` | Significado | Consequência |
| --- | --- | --- |
| `true` | A versão distribuída precisa de runtime para ser executada | Release **completa** sem Runtime Package funcional = **bloqueio** (G7). Ausente ou inválido, para |
| `false` | O projeto declarou que não precisa | Exige, no Confluence: a **justificativa** e **como a versão distribuída é executada sem ele** |

Ausência silenciosa nunca é permitida: o campo é obrigatório no manifesto, e
`false` sem a página correspondente é falha de setup, não omissão tolerada.

O workflow não impõe Docker, banco, Flutter, nada. Flutter Web é
`flutter build web` → artefato servível; Docker entra só se o projeto quiser.

**Compatibilidade runtime ↔ versão (§32 do doc original):** o runtime não tem
versão própria, mas o `release-manifest.yml` registra de qual runtime aquele ZIP
saiu — commit quando versionado (monorepo), checksum do conteúdo quando não
(multi-repo).

### 3.6 Distribuição agregada e `release-manifest.yml`

```text
geoprag-1.0.0-rc.1.zip
├── artifacts/
│   ├── geoprag_api/geoprag-api-2.1.0.jar
│   ├── geoprag_admin/web.zip
│   └── geoprag_mobile/geoprag-mobile-1.4.0.apk
├── runtime/
│   └── start
├── release-manifest.yml
└── release-request.yml         ← cópia do pedido que originou o pacote
```

O Release Manifest é o **registro do que efetivamente foi produzido**, e precisa
responder sozinho às oito perguntas de rastreabilidade:

```yaml
project: geoprag
product_version: 1.0.0-rc.1          # 1. qual a versão do produto
release_type: pre_release
created_at: 2026-09-12T15:10:00Z
source_request: 2026-09-12-pre.yml   # 8. qual Release Request originou
components:                          # 2. quais componentes estão dentro
  geoprag_mobile:
    version: 1.4.0                   # 3. qual a versão de cada um
    commit: 3ac91f2                  # 4. qual commit de cada um
    tag: geoprag_mobile/v1.4.0
    artifact: geoprag-mobile-1.4.0.apk
    carried: false                   # 5/6. versionado nesta release
  geoprag_api:
    version: 2.1.0
    commit: 77be004
    tag: geoprag_api/v2.1.0
    artifact: geoprag-api-2.1.0.jar
    carried: true                    # 5/6. carregado, sem versão nova
runtime:                             # 7. qual Runtime Package foi usado
  entrypoint: runtime/start
  checksum: sha256:1d0ee43…          # ou commit, no monorepo
```

Só entra o que o projeto tem. Nada de API/Web/Mobile/Banco obrigatórios.

**Pre-release da distribuição completa existe (D12):** `geoprag-1.0.0-rc.1.zip` é
montado pelo mesmo caminho da final, com o mesmo runtime e os mesmos artefatos.

### 3.7 Release Orchestrator

Scripts **PowerShell** (D7) em `.release/scripts/`, específicos do projeto,
usados em **todo projeto** (D6). Não é GitHub Action.

```text
.\orchestrate.ps1 -Request .release\requests\2026-09-12-final.yml

1. validar o manifesto (schema, ciclos em depends_on, repos declarados)
2. validar o estado local dos repositórios (existe, limpo, no commit esperado)
3. resolver effective scope a partir de depends_on
4. disparar as Release Actions necessárias
5. aguardar os resultados
6. coletar os artefatos publicados
7. montar dist/artifacts/<componente>/
8. copiar o Runtime Package
9. gerar release-manifest.yml + copiar o release-request.yml
10. gerar o ZIP, nomeado com a versão do produto
```

**Pode:** validar manifesto; validar repositórios; resolver dependências
declaradas; consumir/gerar Release Request; disparar Release Actions; aguardar
resultados; coletar artefatos; montar a distribuição; copiar o Runtime Package;
gerar o Release Manifest; gerar o ZIP.

**Não pode:** ler Jira para decidir; decidir versão; decidir escopo de negócio;
inventar dependência; escolher MAJOR/MINOR/PATCH; aprovar produto; executar
análise humana; substituir a skill.

**Consequência de D15 sobre o passo 6:** de onde o Orchestrator coleta depende do
tipo da release. Em `FINAL` existe GitHub Release do componente para baixar; em
`PRE_RELEASE` não existe, e a coleta sai do artefato da execução. São dois
caminhos de obtenção, um contrato só ("artefato identificável e recuperável"), e
a escolha do mecanismo concreto continua sendo da implementação (§3.4).

Daí decorre uma regra de retenção que precisa estar no contrato da Action: **o
artefato de um `PRE_RELEASE` precisa sobreviver tempo suficiente para a
distribuição ser montada e validada.** Depois disso, quem guarda o rc é o ZIP no
Drive — não o GitHub.

Consequência de D6 a registrar: no Compass System, fechar uma distribuição passa
a exigir rodar o script local — hoje o ZIP de demo sai sozinho na Action. O ganho
é uma implementação só de empacotamento e um `release.yml` mais simples.

### 3.8 Fontes de verdade — quem responde o quê

Não existem cinco fontes concorrentes. Cada sistema responde uma pergunta
diferente, e nenhuma informação tem duas interpretações independentes.

| Sistema | Responde | Não responde |
| --- | --- | --- |
| **Jira** | Qual trabalho foi feito: issues, status, Fix Versions, rastreabilidade do trabalho | Qual foi a composição técnica de uma distribuição |
| **GitHub** | Verdade técnica dos repositórios: código, commits, implementação; as Actions produzem os artefatos | Contexto de negócio ou decisão de escopo |
| **Release Request** | O que foi pedido **naquela execução** — registro operacional, reproduzível | Estado histórico do produto |
| **Release Manifest** | O que foi **efetivamente produzido** naquela distribuição. Viaja dentro do ZIP | Por que aquelas issues entraram |
| **Confluence** | Documentação operacional e índice histórico acessível do projeto | Nada que já não venha do Manifest — ele **copia** o conteúdo, não reinterpreta |

Regras que decorrem disso:

- Jira e GitHub permanecem sincronizados pelas regras já existentes do workflow.
- Para cada distribuição agregada relevante, o Confluence guarda uma **cópia do
  conteúdo do Release Manifest** — nunca uma segunda versão escrita à mão.
- O ZIP armazenado é o portador do Manifest; o Confluence é o índice
  pesquisável. Os dois carregam o mesmo conteúdo, com papéis diferentes.

### 3.9 Pre-release → validação → Final

Os três conceitos, sem ambiguidade:

| Termo | O que é |
| --- | --- |
| **PRE_RELEASE** | Tipo técnico de uma versão que ainda não é a oficial. Existe para teste, QA, demonstração, validação, distribuição a terceiros, preparação da final |
| **RC** | Uma pre-release tratada como **candidata à versão final**. `rc.N` é só o identificador SemVer disso — não é mecanismo separado |
| **FINAL** | A versão oficial aprovada, que representa o estado que Rafinha aceitou como entrega |

Fluxo:

```text
PRE_RELEASE → validação humana → aprovação → FINAL
```

`PRE_RELEASE` **não** significa "quase final porque passou no CI". Significa
"distribuição real disponível para validação antes da oficialização". Nem toda
pre-release vira final:

```text
1.0.0-rc.1 → reprovada
1.0.0-rc.2 → reprovada
1.0.0-rc.3 → aprovada → 1.0.0
```

**Promoção (mecanismo, G8).** A final não é produzida silenciosamente a partir
de outro estado de código. Quando uma FINAL promove uma pre-release validada, o
Release Request carrega `promotes: geoprag-1.0.0-rc.3`, e os commits vêm do
Release Manifest daquele rc — não do `HEAD` de `develop`. O Orchestrator
verifica que cada repositório está nesses commits e **para** se algum divergiu.
Uma FINAL sem promoção (projeto pequeno, sem rc) é legítima: aí os commits vêm
do `ref` informado.

### 3.10 Gates

| Gate | Quem valida | Bloqueia |
| --- | --- | --- |
| **G0 Documentação** | skill | Árvore `CI/CD - Workflow Rafinha-Claude` ausente ou incompleta (§41) |
| **G1 Manifesto** | skill / orchestrator | `.release/project.yml` ausente, inválido, com ciclo em `depends_on`, ou divergente do `release.yml` |
| **G2 Escopo** | Rafinha | Effective Scope não confirmado |
| **G3 Dependência consumível** | skill / orchestrator | Componente `carried` sem versão publicada e compatível — nunca fabricar dependência, nunca usar código local não publicado |
| **G4 Versão** | Rafinha | Incremento não confirmado, por componente + o do produto quando completa |
| **G5 Notas** | skill | Notas não commitadas antes do dispatch |
| **G6 Execução** | Action / Orchestrator | Qualquer falha — corrige e repete, nunca contorna na mão |
| **G7 Distribuição** | Rafinha | Release completa com `runtime_package.required: true` sem runtime funcional, ou FINAL sem execução real fora da IDE |
| **G8 Promoção** | orchestrator | FINAL que promove um rc, com repositório fora dos commits daquele rc |
| **G9 Registro** | skill | Fix Versions, Confluence e cópia do Drive não atualizados |

G0, G3, G7 e G8 são novos.

---

## 4. Fluxo conceitual

Release completa (ou parcial que gera distribuição):

```text
Rafinha solicita Release
        ↓
jira-release-executor: Type + Requested Scope
        ↓
resolver dependências declaradas → Effective Scope
        ↓
version_scope + carried
        ↓
Rafinha decide versões (componentes + produto)
        ↓
Release Request
        ↓
Release Orchestrator: dispara Actions → aguarda → coleta artifacts
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
Rafinha → Type + Scope → skill dispara a Action → artifact → uso/teste
```

O Orchestrator só participa quando há o que agregar.

---

## 5. O que muda em cada peça

### 5.1 `workflow-development-flow` (skill mãe)

A seção 10 tem ~280 linhas num arquivo de 1244, e o modelo novo dobra isso.
Extrair para `workflow-development-flow/references/release-lifecycle.md`, com um
resumo de ~40 linhas + ponteiro no `SKILL.md`.

| Subseção | Status |
| --- | --- |
| Dois ciclos diferentes | preserva |
| Projeto, Repositório e Componente | **nova** (C1) |
| Componente: unidade de versionamento | preserva, ajusta para "projeto" |
| SemVer por componente + versão do produto + `rc.N` | preserva + amplia (D3) |
| Release Type × `publish` como eixos independentes | **nova** (C2, C12) |
| Release Scope: parcial × completa; exclusões permanentes | **nova** (C3, D11) |
| Dependências e o contrato de `carried` | **nova** (C3, D10) |
| Manifesto central e onde vive por topologia | **substitui** a atual (C8, D1) |
| Release Request | **nova** |
| Artifact ≠ Release; Release Build ≠ CI Build | **nova** (C4) |
| Runtime Package: contrato e `required` | **nova** (C5) |
| Distribuição, versão de produto e Release Manifest | **nova** (C6, D3) |
| Release Orchestrator: pode/não pode | **nova** (C7, D5 revisada) |
| Pre-release → validação → Final, e promoção | **nova** (C11) |
| Fontes de verdade e suas responsabilidades | **nova** |
| Fronteira skill / Action / Orchestrator | reescreve 10.7 (renumerar!) |
| Contrato da Release Action | reescreve 10.8 |
| Notas de release | preserva + fallback por rc |
| Documentação obrigatória no Confluence | **nova** (C9, C10) |
| Limitação aceita: multi-repo sem Git | **nova** (D1) |

Frase-guia a acrescentar (§43 do doc original): *o workflow não ensina cada
projeto a ser um Compass System; define contratos gerais para que cada projeto
descreva o seu.*

### 5.2 `jira-release-executor`

Dos 10 passos lineares para **7 fases**, com Type/Scope na fase 1.

| Fase | O que faz | Novo? |
| --- | --- | --- |
| **0. Pré-voo** | G0 + G1 + `git status` + topologia | G0 é novo |
| **1. Intake** | pedido → `type` + `requested_scope` | novo (C2) |
| **2. Resolução** | `depends_on` → effective scope; `version_scope` × `carried`; G3; apresentar exclusões declaradas sem re-perguntar; G2 | novo (C3, D10, D11) |
| **3. Decisão** | incremento por componente + versão do produto quando completa (G4) | amplia (D3) |
| **4. Notas** | escrever/commitar notas, CHANGELOG, README (G5) | preserva + fallback rc |
| **5. Execução** | com distribuição → entrega o Request ao Orchestrator; sem distribuição → `gh workflow run` direto (G6) | amplia (C1, D5 revisada) |
| **6. Validação** | Rafinha executa a distribuição fora da IDE; decide promover ou gerar novo rc (G7) | novo |
| **7. Registro** | Fix Versions (só final, por componente) + Confluence (cópia do Manifest) + Drive (G9) | amplia (D4, D9, D14) |

Mudanças pontuais:

- Mapear issue → componente hoje usa `gh pr view <numero>` assumindo o repo
  corrente. Em multi-repo o campo `Links para merge` aponta para repos
  diferentes — passar a usar a **URL completa do PR**, que funciona nos dois
  casos sem caso especial.
- O antigo passo 7 ("Release Candidate quando aplicável") desaparece como passo
  e vira o eixo `type` da fase 1.
- Fix Version só em FINAL e só por componente (D4, D14).
- Acrescentar ao "O que NÃO fazer": nunca inferir dependência por análise de
  código; nunca montar distribuição na mão; nunca bumpar componente `carried`;
  nunca inventar exclusão não declarada; nunca re-perguntar justificativa de
  exclusão já declarada; nunca produzir FINAL a partir de estado de código
  diferente do rc promovido; nunca criar Fix Version de rc.
- Ajustar o `description` do frontmatter: hoje cita "o Compass System tem três"
  como se fosse definição do workflow.

### 5.3 Templates da skill

| Template | Ação |
| --- | --- |
| `templates/project.yml` | **novo** — manifesto central (§3.2) |
| `templates/release-components.yml` | **remover** (D2) |
| `templates/release.yml` | **reescrever e simplificar** — sai o pacote de demo; entram `release_type`, `publish` como eixo separado, artefato `<componente>-<versao>` sempre recuperável, Release **só em FINAL** (D15), tag sempre, fallback de notas. Toolchain e build viram bloco de exemplo marcado |
| `templates/release-notes-README.md` | **ajustar** — fallback por versão base |
| `templates/runtime/` | **novo** — `start` de exemplo + README com o contrato e três estratégias possíveis, nenhuma obrigatória |
| `templates/orchestrator/` | **novo e central** — `orchestrate.ps1` (validar, disparar, aguardar, coletar, agregar), schema do `release-manifest.yml`, README do contrato |
| `templates/confluence-cicd.md` | **novo** — esqueleto das páginas do §21 |

Um segundo template de `release.yml` para componente único **não** deve existir:
o formato cobre o caso apagando blocos, e dois templates divergem.

### 5.4 Confluence — espaço do workflow (CS1)

| Página | Ação |
| --- | --- |
| `Release & Versionamento` (44335153) | **reescrever** como índice do Release Lifecycle |
| ↳ `Projeto, Componentes e Repositórios` | criar |
| ↳ `Tipos e Escopo de Release` | criar |
| ↳ `Artefatos, Runtime Package e Distribuição` | criar |
| ↳ `Release Orchestrator` | criar |
| ↳ `Fontes de verdade no ciclo de Release` | criar |
| `Release Lifecycle — guia de consulta` | **criar** — página única de resumo do ciclo inteiro, para Rafinha consultar e tirar dúvidas sem percorrer a árvore |
| `9. Configurar o ciclo de Release` (44531714) | **reescrever** — manifesto novo, gate de documentação, runtime, orchestrator |
| `jira-release-executor` (44072995) | atualizar para as 7 fases |
| `workflow-development-flow` (44400642) | atualizar o resumo da seção 10 |
| `Validação Humana Agregada` (50888706) | atualizar — recomendação de pre-release (D13) |
| `Pipelines no GitHub` (44105774) | revisar — distinguir CI Build × Release Build |

### 5.5 Confluence — espaço de cada projeto

```text
CI/CD - Workflow Rafinha-Claude
├── Projeto e Componentes
├── Build e Artefatos
├── Execução de uma Versão
├── Runtime Package                   ← justificativa obrigatória se required: false
├── Banco e Infraestrutura Local      (quando aplicável)
├── CI/CD
├── Release                           ← índice das distribuições + cópia dos Manifests (D9)
├── Validação da Release              ← veredito do G7 (D13)
├── Versionamento                     ← produto + componentes (D3); a página existente migra
└── Release Multi-Repository          (obrigatória se topology = multi_repo)
```

A página **Release** guarda, por distribuição: data, versão do produto, versões
e commits dos componentes, quais foram `carried`, runtime usado e link do Drive —
ou seja, **a cópia do conteúdo do Release Manifest**, não uma reescrita.

Efeitos colaterais: `CS › Versionamento` (60194817) está linkada da página 9 como
modelo — mover exige atualizar o link. `EP › CI/CD, Deploy e Qualidade` (33390593)
cobre parte do assunto: decidir se vira a página `CI/CD` da árvore ou se é
absorvida.

### 5.6 Jira

- Fix Version namespaced e multi-valorada, por componente: preserva.
- Só em release final (D4); `rc.N` não aparece no Jira.
- Versão do produto **não** vira Fix Version (D14).
- Nenhuma coluna nova, nenhum tipo de issue novo.

### 5.7 `README.md` do repositório de skills

O parágrafo "Release por componente" precisa mencionar projeto ≠ repositório,
Type × publish, distribuição, versão de produto, runtime e Orchestrator.

### 5.8 `jira-human-validation-executor` (tocada por D13)

Mudança pequena, numa direção só: ao montar uma Validação Manual, a skill pode
marcar um cenário como **"só validável na distribuição real"** e **recomendar**
que Rafinha gere uma pre-release.

Ela **não** dispara release, **não** cria issue de release, **não** bloqueia a
Validação Manual esperando o pacote. O veredito de ter rodado a distribuição é
registrado na página **Validação da Release**.

---

## 6. Estratégias por topologia

### 6.1 Monorepo (Compass System)

```text
compass/
├── .github/workflows/release.yml     ← builda e publica por componente
└── .release/                         ← commitado
    ├── project.yml
    ├── requests/
    ├── runtime/
    └── scripts/orchestrate.ps1
```

O `release.yml` continua resolvendo build e publicação; a distribuição é montada
localmente pelo Orchestrator (D6). O "pacote de demo" do Compass se decompõe em
duas peças declaradas: o Runtime Package e a distribuição montada pelo
Orchestrator. Sai do template, entra no projeto.

### 6.2 Multi-repo (GeoPrag)

```text
geoprag/                              ← pasta mãe, NÃO é repositório Git
├── geoprag-api/        (repo)  → release.yml → jar
├── geoprag-admin/      (repo)  → release.yml → web
├── geoprag-public/     (repo)  → release.yml → web
├── geoprag-mobile/     (repo)  → release.yml → apk
└── .release/                         ← local, cópia no Drive (D1)
    ├── project.yml
    ├── requests/
    ├── runtime/
    └── scripts/orchestrate.ps1
```

**Limitação arquitetural aceita conscientemente:** a pasta mãe não é Git, não tem
histórico Git e **não será transformada em repositório**. A limitação concreta é
uma só, e é esta:

> O estado atual do `.release/project.yml` não possui histórico Git próprio.

Isso não é erro de arquitetura nem lacuna a corrigir depois — é decisão (D1), e
deve aparecer documentada assim, não escondida. A rastreabilidade histórica da
composição do produto é preservada por outros três registros, que por isso
deixam de ser opcionais: **Release Manifest + ZIP armazenado + registro no
Confluence**.

---

## 7. Plano de implementação, em fases

| Fase | Entrega | Depende de | Risco |
| --- | --- | --- | --- |
| **0. Contratos** | Schemas do `project.yml`, Release Request, Release Manifest; contrato de I/O da Action; contrato do Runtime Package; contrato do Orchestrator | — (decisões fechadas) | baixo |
| **1. Skill mãe** | `references/release-lifecycle.md` + seção 10 resumida; renumeração corrigida | 0 | baixo |
| **2. Templates de repositório** | `project.yml`, `release.yml` genérico, notas ajustadas | 0, 1 | médio |
| **3. Orchestrator + Runtime** | `orchestrate.ps1` (validar → disparar → aguardar → coletar → agregar), `templates/runtime/`, `release-manifest.yml` | 0, 2 | **alto** — único código novo de verdade, agora com disparo e espera |
| **4. Skill executora** | `jira-release-executor` nas 7 fases, com G0/G2/G3/G7 | 1, 2, 3 | médio |
| **5. Confluence do workflow** | Árvore CS1 + passo 9 + Validação Humana Agregada | 1, 4 | baixo |
| **6. Ajuste da Validação Humana** | recomendação de pre-release (§5.8) | 1 | baixo |
| **7. Piloto ponta a ponta** | Um projeto rodando o ciclo completo: rc → validação fora da IDE → promoção → final | 3, 4, 5 | médio |
| **8. Fechamento** | `README.md`, remoção do template antigo, coerência skill ↔ Confluence | 7 | baixo |

**Migração do Compass System:** decidida (D2) como migração completa, sem
compatibilidade retroativa, mas **fora deste ciclo de trabalho** — trilha própria,
depois das fases 0–5. Até lá o Compass segue no formato antigo.

**Efeito do ajuste 3 na fase 3:** o Orchestrator agora dispara Actions e aguarda
resultados, o que acrescenta tratamento de execução remota (disparo, polling,
timeout, falha parcial, re-execução). Continua sendo a fase de maior risco, e
agora com mais superfície.

Ordem inegociável: **contrato antes de implementação**, e **Orchestrator antes da
skill que o chama**.

Granularidade sugerida no Jira: cada fase é um Épico; cada linha das tabelas da
§5 é uma Issue. Fases 0, 1 e 5 são de documentação; 2, 3, 4 e 6 são de código.

---

## 8. Decisões

### 8.1 Tomadas

| # | Decisão | Escolha |
| --- | --- | --- |
| **D1** | Manifesto de projeto multi-repo | **Arquivo local, não versionado**, cópia no Drive. Limitação documentada (§6.2) |
| **D2** | Transição do formato de manifesto | **Migrar de vez**; migração do Compass é trabalho separado |
| **D3** | Versão da distribuição agregada | **SemVer próprio do produto**, decidido por Rafinha na release completa |
| **D4** | Pre-release cria Fix Version? | **Não** — só a final |
| **D5** | Orchestrator dispara Actions? | ~~Não~~ → **REVISADA (ajuste 3): sim.** Dispara, aguarda e coleta; continua sem decidir nada |
| **D6** | Monorepo usa Orchestrator? | **Sim** — ele monta a distribuição em todo projeto |
| **D7** | Linguagem do Orchestrator | **PowerShell** |
| **D8** | Onde vive o Runtime Package | **`.release/runtime/`**, junto do manifesto |
| **D9** | Armazenamento e registro do ZIP | **Drive + cópia do manifesto + registro no Confluence** |
| **D10** | Componente puxado por dependência sem mudança | **`carried`** — entra na distribuição na versão atual, sem versão nova. Se mudou, vai para `version_scope`. Se não há versão publicada compatível, **bloqueia** (G3) |
| **D11** | "Release completa" | **Todos os componentes declarados**, menos as **exclusões permanentes** do manifesto. Exclusão declarada não é re-perguntada; exclusão não declarada não é inventada. Completa ≠ todos recebem versão nova |
| **D12** | Pre-release da distribuição completa | **Existe** — o ZIP também tem `rc.N` |
| **D13** | Conexão com a Validação Humana Agregada | **Ela recomenda, Rafinha decide** — veredito na página Validação da Release, sem issue nova |
| **D14** | Versão do produto vira Fix Version? | **Não** — Fix Version só por componente |
| **D15** | Quando se cria GitHub Release | **Só em release FINAL, por componente** (parcial ou completa). `PRE_RELEASE` produz tag + artefato recuperável, sem Release. A distribuição do produto nunca vira GitHub Release — Drive + Confluence |

### 8.2 D15 — o que a escolha implica

O ajuste 12 pedia "GitHub Release oficial = FINAL + FULL RELEASE". Aplicado ao pé
da letra, isso colidia com duas coisas já decididas: o §14 do documento original
(pre-release aparece como GitHub Pre-release, sem inventar complexidade para
esconder a existência técnica dessas versões) e o D9 + §24 (uma Release "do
produto" precisaria morar num repositório, elegendo um dono técnico que o §24
proíbe). Havia ainda o efeito prático de uma **release final parcial** ficar sem
lugar durável de download, já que workflow artifact expira.

A opção escolhida separa os dois eixos que estavam colados na formulação
original — **tipo** (pre/final) e **escopo** (parcial/completa) — e condiciona a
Release só ao primeiro:

| | Componente em PRE_RELEASE | Componente em FINAL parcial | Componente em FINAL completa | Produto |
| --- | --- | --- | --- | --- |
| **Escolhido (A)** | tag + artefato, sem Release | tag + **Release** | tag + **Release** | sem GitHub Release — Drive + Confluence |

O objetivo declarado do ajuste 12 é cumprido (nenhum RC entra na área de
Releases), toda versão final tem download durável, e nenhum repositório vira
dono do produto.

**O que isso obriga na implementação:**

1. A Action publica o artefato de forma recuperável **mesmo quando não cria
   Release** (§3.4), com retenção suficiente para a distribuição ser montada e
   validada.
2. O Orchestrator tem dois caminhos de coleta — da Release em `FINAL`, do
   artefato da execução em `PRE_RELEASE` (§3.7).
3. A tag existe sempre, inclusive em pre-release: é ela que amarra artefato ↔
   commit no Release Manifest, independentemente de haver Release.
4. Quem guarda um rc a longo prazo é o ZIP no Drive, não o GitHub. Isso precisa
   estar escrito na página **Release** do projeto, senão vira surpresa quando um
   rc antigo for procurado.

---

## 9. O que este plano preserva integralmente

- Release separada das 8 etapas; nunca varredura de coluna; nunca coluna "Release".
- Componente como unidade versionada; tag namespaced; Fix Version multi-valorada.
- Decisão de versão sempre de Rafinha — N componentes + o produto.
- Falha é bloqueio, nunca contorno manual.
- A skill nunca reimplementa o determinístico; o Orchestrator nunca decide.
- A Action continua sendo `workflow_dispatch` comum: Rafinha fecha um componente
  pela aba Actions quando quiser.
- Release Action específica de cada projeto/repositório; Orchestrator específico
  do projeto e local.
- Template é a fonte de verdade; melhoria descoberta num projeto volta ao template.
- Chat não é fonte de verdade — o Release Request existe por isso.
- Notas de release são texto corrido para qualquer pessoa ler.

---

## 10. O que foi produzido (2026-09-12)

### Skills

| Arquivo | Mudança |
| --- | --- |
| `workflow-development-flow/references/release-lifecycle.md` | **novo** — os contratos completos: manifesto, Release Request, Release Action, Runtime Package, distribuição, Orchestrator, fontes de verdade, promoção e os 10 gates |
| `workflow-development-flow/SKILL.md` | seção 10 de ~280 linhas → resumo de ~65 + ponteiro; frontmatter atualizado; referência a "10.4" corrigida |
| `jira-release-executor/SKILL.md` | reescrita: 10 passos lineares → 7 fases, com Type/Scope na fase 1 |
| `jira-human-validation-executor/SKILL.md` | cenário "só validável na distribuição real" + recomendação de pre-release |
| `README.md` | parágrafo de Release reescrito para o modelo novo |

### Templates

| Arquivo | Mudança |
| --- | --- |
| `templates/project.yml` | **novo** — manifesto central |
| `templates/release.yml` | reescrito e **mais simples**: sai o pacote de demo do Compass, entram `release_type`, artefato determinístico, Release só em final |
| `templates/release-notes-README.md` | fallback por versão base |
| `templates/runtime/` | **novo** — README do contrato + `start.example.ps1` |
| `templates/orchestrator/` | **novo** — `orchestrate.ps1`, README, exemplos de manifest e request |
| `templates/release-components.yml` | **removido** |

### Confluence (space Claude Skills)

**Novas:** Release Lifecycle — guia de consulta (61505539) · Projeto, Componentes e Repositórios (61603841) · Tipos e Escopo de Release (61538321) · Artefatos, Runtime Package e Distribuição (61603864) · Release Orchestrator (61636609) · Fontes de verdade no ciclo de Release (61538342)

**Atualizadas:** Release & Versionamento (44335153) · 9. Configurar o ciclo de Release (44531714) · jira-release-executor (44072995) · workflow-development-flow (44400642) · Validação Humana Agregada (50888706) · Pipelines no GitHub (44105774)

### Verificações executadas

- sintaxe de `orchestrate.ps1` e `start.example.ps1` — OK (parser do PowerShell)
- `project.yml`, `release.yml` e os dois exemplos YAML — parseiam sem erro
- `gh` presente; **`powershell-yaml` ainda não instalado** na máquina

### Pendências conhecidas

1. `Install-Module powershell-yaml -Scope CurrentUser` antes de rodar o Orchestrator.
2. O `orchestrate.ps1` nunca foi executado contra um projeto real — só validado sintaticamente. É a fase 7.
3. `CS › Versionamento` (60194817) ainda é página solta; migra para a árvore do projeto quando o Compass for migrado.
4. `EP › CI/CD, Deploy e Qualidade` (33390593) — decidir se vira a página `CI/CD` da árvore nova ou se é absorvida.
