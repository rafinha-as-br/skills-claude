---
name: "workflow-development-flow"
description: "Skill mãe do novo fluxo de desenvolvimento Rafinha-Claude — referência consultável sobre hierarquia (Épico → Issue → Subtask), princípios do fluxo, classificação de issues (código/documentação), as 8 etapas do pipeline (Fazer - Claude, Análise - Rafinha, Integração, QA - Claude, Documentar, Análise final - Rafinha, Análise final - Claude, Concluído) e seus gates de passagem, as camadas de validação (local, GitHub Actions, QA, Análise final), a integração GitHub Issues ↔ Jira ↔ Pull Request, o ciclo de Release & Versionamento (SemVer por componente, tags namespaced `<componente>/vX.Y.Z`, Fix Version multi-valorada, Release Lifecycle dividido entre skill e GitHub Action) — um ciclo separado do workflow de issue, nunca uma coluna do Jira —, a camada de Validação Humana Agregada (a unidade de aceitação humana pode agregar várias Issues; seção 12) e o Execution State (continuidade/recuperação de uma issue em execução entre sessões diferentes do Claude Code, sem depender do transcript da sessão anterior; seção 13). Esta skill NUNCA executa ação nenhuma no Jira, no Confluence ou no código — é só consulta. Use-a quando outra skill do pipeline precisar entender em qual etapa uma issue está, o que vem antes/depois, o que uma etapa deve produzir, ou o que fazer diante de incerteza sobre o fluxo. Rafinha também aciona diretamente com perguntas como 'qual a próxima etapa depois de X', 'o que a etapa Y deveria produzir', 'explica o fluxo novo', 'como funciona o ciclo de release', ou qualquer dúvida sobre como o workflow Rafinha-Claude funciona."
---

---
name: workflow-development-flow
description: "Skill mãe do novo fluxo de desenvolvimento Rafinha-Claude — referência consultável sobre hierarquia (Épico → Issue → Subtask), princípios do fluxo, classificação de issues (código/documentação), as 8 etapas do pipeline (Fazer - Claude, Análise - Rafinha, Integração, QA - Claude, Documentar, Análise final - Rafinha, Análise final - Claude, Concluído) e seus gates de passagem, as camadas de validação (local, GitHub Actions, QA, Análise final), a integração GitHub Issues ↔ Jira ↔ Pull Request, o ciclo de Release & Versionamento (SemVer por componente, tags namespaced `<componente>/vX.Y.Z`, Fix Version multi-valorada, Release Lifecycle dividido entre skill e GitHub Action) — um ciclo separado do workflow de issue, nunca uma coluna do Jira —, a camada de Validação Humana Agregada (a unidade de aceitação humana pode agregar várias Issues; seção 12) e o Execution State (continuidade/recuperação de uma issue em execução entre sessões diferentes do Claude Code, sem depender do transcript da sessão anterior; seção 13). Esta skill NUNCA executa ação nenhuma no Jira, no Confluence ou no código — é só consulta. Use-a quando outra skill do pipeline precisar entender em qual etapa uma issue está, o que vem antes/depois, o que uma etapa deve produzir, ou o que fazer diante de incerteza sobre o fluxo. Rafinha também aciona diretamente com perguntas como 'qual a próxima etapa depois de X', 'o que a etapa Y deveria produzir', 'explica o fluxo novo', 'como funciona o ciclo de release', ou qualquer dúvida sobre como o workflow Rafinha-Claude funciona."
---

# Fluxo de Desenvolvimento — Skill Mãe (Rafinha + Claude)

## Identidade do papel

Esta é a **skill mãe** do workflow de desenvolvimento, revisão, integração,
QA e documentação de Rafinha e Claude. Ela guarda o vocabulário e o mapa do
processo que todas as demais skills do pipeline (`jira-issue-creator`,
`jira-issue-executor`, `jira-integration-executor`, `jira-qa-executor`,
`jira-doc-executor`, `jira-human-validation-executor`,
`jira-review-executor`, `business-rule-writer`, `module-doc-writer`,
`screen-doc-writer`, `jira-release-executor`)
referenciam quando precisam entender em qual etapa uma issue está, o que
vem antes ou depois, o que uma etapa deve produzir, ou o que fazer diante
de incerteza sobre o fluxo — incluindo o ciclo separado de Release &
Versionamento (seção 10), a camada de Validação Humana Agregada
(seção 12) e o Execution State (seção 13).

**Esta skill nunca executa ação nenhuma sozinha** — não cria, não move, não
comenta e não transiciona issues no Jira; não escreve página no Confluence;
não toca em código ou em git. Ela só responde perguntas e fornece contexto.
Quem executa cada etapa é sempre a skill específica correspondente.

As skills específicas não precisam carregar todo este conteúdo na própria
execução — só precisam saber que podem consultar esta skill quando surgir
dúvida sobre o fluxo.

---

## 1. Hierarquia de trabalho no Jira

Esta hierarquia é uma **camada anterior ao workflow**. Antes de executar
qualquer uma das 8 etapas (seção 5), é preciso entender sobre qual nível do
Jira se está atuando.

```text
ÉPICO
  ↓
ISSUE
  ↓
SUBTASK
```

### Épico
Representa uma iniciativa grande, objetivo e contexto geral.
**Nunca é executado diretamente.** Contém: objetivo, motivação, escopo,
fora de escopo, arquitetura/visão geral, critérios gerais de sucesso,
dependências, issues relacionadas.

> **Épico = por que estamos fazendo isso?**

### Issue
Representa uma unidade de entrega concreta — é a unidade principal que
percorre as 8 etapas do fluxo (seção 5). Contém: problema, objetivo,
requisitos, regras de negócio, critérios de aceitação, testes esperados,
documentação necessária.

> **Issue = o que exatamente precisa ser entregue?**

### Subtask
Representa uma parte interna da execução de uma Issue.
**Não possui ciclo de vida independente** — não avança sozinha pelas
colunas do fluxo; existe só para indicar progresso interno da Issue pai.

> **Subtask = quais partes compõem essa entrega?**

### Regra principal ao receber um item do Jira

```text
Épico recebido
→ NÃO executar o Épico
→ consultar as Issues relacionadas
→ trabalhar somente sobre uma Issue executável

Issue recebida
→ executar normalmente, seguindo o fluxo geral (seção 4)

Subtask recebida
→ entender o contexto da Issue pai
→ executar somente a parte correspondente à subtask
→ respeitar o workflow da Issue pai
```

### Critério para decidir entre Issue e Subtask

> **Se uma parte do trabalho puder ser entregue, revisada e validada de
> forma independente, ela deve ser uma Issue. Se for apenas uma parte
> necessária da implementação de outra entrega, deve ser uma Subtask.**

### Escopo de aplicação

Decidir entre Épico/Issue/Subtask na criação, e interpretar o nível
recebido na execução, é responsabilidade de `jira-issue-creator` e
`jira-issue-executor`. As demais skills do pipeline (Integração, QA,
Documentação, Revisões) já recebem a Issue certa nessa altura do fluxo e
não precisam reaplicar essa decisão — a referência fica aqui só para
consulta quando surgir dúvida.

---

## 2. Princípios do fluxo

Válidos para todas as etapas, sem exceção:

1. **A IA implementa, mas não decide requisitos ou regras de negócio não
   especificados.**
2. **Nenhuma etapa deve ignorar falhas para permitir que a issue avance.**
3. **Cada etapa possui responsabilidades próprias e não deve assumir
   responsabilidades de outra etapa sem orientação explícita.**
4. **Testes devem validar comportamento e risco, não apenas buscar
   cobertura de código.**
5. **O tipo e a quantidade de testes devem ser proporcionais ao
   comportamento e ao risco introduzidos pela issue.**
6. **A documentação de implementação é produzida durante a execução da
   issue.**
7. **A documentação do estado final do produto somente é consolidada após
   integração e QA.**
8. **Cada etapa deve produzir uma saída verificável antes de permitir a
   passagem para a próxima etapa.**
9. **Toda decisão relevante deve deixar um registro onde possa ser
   consultada posteriormente.**
10. **A responsabilidade final pelas regras de negócio, pela aceitação do
    produto e pelas decisões técnicas críticas permanece com Rafinha.**

**Extensão à camada de pipeline:** o princípio 2 se aplica também à
validação por GitHub Actions (seção 6) — falha na pipeline é bloqueio de
avanço, nunca só informação de diagnóstico.

---

## 3. Classificação das issues

Toda issue possui um atributo que identifica seu tipo. **A classificação é
definida na criação da issue** (campo formal, preenchido por
`jira-issue-creator`) — não é mais perguntada em tempo de execução. Se o
campo não existir ou estiver ambíguo numa issue já criada, isso é tratado
como exceção pela skill que a recebe (fallback, não regra geral).

### 3.1 Issue de código
Altera código, comportamento executável, arquitetura, testes ou
configuração técnica. Exemplos: nova funcionalidade, correção de bug,
alteração de regra implementada em código, refatoração, alteração de
gerenciamento de estado, alteração de API/client, alteração de
persistência, criação ou alteração de testes.

`tipo: código` — percorre o fluxo técnico completo (implementação, testes,
integração).

### 3.2 Issue de documentação
Não altera o comportamento executável do sistema. Exemplos: documentação
de regra de negócio, documentação de módulo, documentação de tela,
documentação arquitetural, atualização de Confluence, correção de
documentação.

`tipo: documentação` — não executa etapas de implementação ou testes de
código que não sejam necessários para a própria documentação.

### 3.3 Ambiguidade
Quando houver ambiguidade real entre código e documentação na criação da
issue, a IA deve solicitar decisão de Rafinha em vez de inferir
silenciosamente.

---

## 4. Fluxo geral — as 8 etapas

```text
Fazer - Claude
        ↓
Análise - Rafinha
        ↓
Integração
        ↓
QA - Claude
        ↓
Documentar
        ↓
Análise final - Rafinha
        ↓
Análise final - Claude
        ↓
Concluído
```

Para issues de documentação, as etapas técnicas que não forem aplicáveis
são ignoradas de acordo com a classificação da issue (seção 3).

---

## 5. As etapas em detalhe

### 5.1 Fazer - Claude

> **Objetivo:** implementar a issue conforme requisitos, regras de negócio
> e arquitetura estabelecidos, produzindo os testes necessários para
> comprovar o comportamento alterado.

Responsabilidades:
- Implementação da issue, respeitando a arquitetura já estabelecida.
- Aplicação dos padrões técnicos do projeto.
- Criação ou atualização de testes automatizados — tipo e quantidade
  proporcionais ao comportamento e risco introduzidos (unitários, widget,
  integração, conforme aplicável). Testes deixaram de ser "se fizer
  sentido": são obrigatórios e proporcionais ao risco.
- Análise estática.
- Verificação de compilação/build quando aplicável.
- Documentação de implementação (não genérica — deve explicar o impacto
  real da alteração: componentes criados/alterados, camadas afetadas,
  testes adicionados, decisões técnicas relevantes).
- Commit + push.
- **Abrir Pull Request**, referenciando a Issue do Jira (a chave já está no
  nome da branch, mas deve constar também no título/descrição do PR) e, se
  houver GitHub Issue de origem vinculada, referenciá-la também
  (`Closes #N`).

Falha de análise estática, build ou teste é bloqueio de avanço — não avança
até ser corrigida ou explicitamente tratada por Rafinha.

**Resultado esperado:** `Pronto para Análise - Rafinha`

### 5.2 Análise - Rafinha (manual)

> **Objetivo:** verificar se a implementação atende aos requisitos, às
> regras de negócio, à arquitetura estabelecida e possui testes adequados.

Responsabilidades: code review, verificação de regras de negócio, de
arquitetura, de qualidade da implementação, de testes, avaliação de efeitos
colaterais, decisão de aprovação ou reprovação.

- **Aprovação** → segue para Integração.
- **Reprovação** → volta direto para `Fazer - Claude`, com problema
  encontrado, comportamento esperado e correção necessária registrados.

Uma implementação tecnicamente elegante não deve ser aprovada se não
atende ao requisito, viola regra de negócio, tem arquitetura inadequada,
testes insuficientes para o risco, ou comportamento incorreto.

**Resultado esperado:** `Pronto para Integração`

### 5.3 Integração

> **Objetivo:** integrar a alteração à `develop`, verificando que ela passa
> pelos gates técnicos num ambiente independente (GitHub Actions) e que
> consegue coexistir com o restante do sistema sem conflitos ou quebra dos
> testes automatizados.

Responsabilidades, nesta ordem (pipeline antes de conflito, conflito antes
do merge):
1. Confirmar que o Pull Request já existe (aberto na `Fazer - Claude`).
2. Verificar o GitHub Actions do PR — ainda rodando: aguardar; passou:
   segue; falhou: corrigir e repetir até passar (bloqueio de avanço, nunca
   só diagnóstico).
3. Verificar se a branch mergeia limpo com a `develop` — sem conflito:
   segue; conflito mecânico: resolve e registra; conflito semântico real:
   para e pergunta a Rafinha. Depois de qualquer resolução de conflito,
   volta ao passo 2 (pipeline precisa passar de novo). Se o conflito foi
   semântico, a issue também volta para `Análise - Rafinha` antes do merge.
4. Merge para `develop`.
5. Registrar o resultado (PR, resultado da pipeline, merge realizado).

A integração não declara que o aplicativo inteiro está livre de problemas
— isso é o QA. O objetivo aqui é só verificar se a alteração se integra de
forma tecnicamente consistente.

**Resultado esperado:** `Pronto para QA - Claude`

### 5.4 QA - Claude

> **Objetivo:** verificar se o sistema **já integrado na `develop`**
> continua funcionando corretamente e se a alteração não introduziu
> regressões nos fluxos existentes.

Roda **depois** da etapa Integração (pós-merge), não mais logo após
`Análise - Rafinha` aprovada — o ambiente de teste é a `develop`
atualizada, não a branch isolada da issue.

Responsabilidades: testes de regressão dos fluxos relacionados, testes dos
fluxos diretamente alterados, testes de integração quando a alteração
atravessa várias camadas, validação dos comportamentos impactados,
identificação de efeitos colaterais, registro dos resultados (fluxo
testado, resultado, falhas, evidências, ambiente, necessidade de
intervenção de Rafinha).

- **Aprovado** → segue para `Documentar`.
- **Reprovado** → volta para `Fazer - Claude`.

**Resultado esperado:** `Pronto para Documentação`

### 5.5 Documentar

> **Objetivo:** registrar o estado final e validado do sistema após
> integração e QA, mantendo sincronizadas a documentação do código e a do
> Confluence.

Descreve o **estado real e validado**, não apenas o que foi implementado
originalmente. Responsabilidades: atualização da documentação de módulos
no código (pasta `docs/` — `overview.md`, `architecture.md`,
`state-management.md`, `api.md`, `maintenance.md`, `changelog.md`, só os
que fizerem sentido), atualização do Confluence (regra de negócio, módulo,
tela), sem burocracia — nada é criado só por criar.

A documentação do estado final só é consolidada depois do QA; antes disso
existe apenas documentação de implementação (produzida na `Fazer -
Claude`).

**Resultado esperado:** `Pronto para Análise Final - Rafinha`

### 5.6 Análise final - Rafinha (manual)

> **Objetivo:** analisar se o produto realmente entrega o que era
> proposto.

Não repete o code review já feito na `Análise - Rafinha`. O foco é:

> **"O produto entregue resolve corretamente o problema que a issue deveria
> resolver?"**

Responsabilidades: validação funcional, uso das funcionalidades entregues,
confirmação de comportamento e regra de negócio, aceitação ou rejeição.

- **Aprovação** → segue para `Análise final - Claude`.
- **Reprovação** → volta direto para `Fazer - Claude`, com o problema
  encontrado registrado.

**Preparação por Validação Humana Agregada (seção 12).** Quando existir uma
`Validação Manual` cobrindo a issue, Rafinha executa esta etapa **a partir
dela**, e não issue por issue: os cenários, as pré-condições e os pontos de
observação já vêm prontos, e a aprovação/reprovação vale para todas as
issues agregadas de uma vez. A pergunta central da etapa não muda; o que
muda é que ele não precisa reconstituir o contexto de cada issue para
responder a ela.

**Resultado esperado:** `Pronto para Análise Final - Claude`

### 5.7 Análise final - Claude

> **Objetivo:** auditoria final da issue para identificar pendências,
> inconsistências ou itens não contemplados nas etapas anteriores.

Verifica: testes faltantes, documentação inconsistente, requisitos não
atendidos, pendências não resolvidas, detalhes esquecidos, divergência
entre implementação e documentação, divergência entre documentação do
código e Confluence, evidências ausentes das etapas anteriores, **e o
estado da Validação Manual vinculada** (seção 12) — se existe, se foi
aprovada, se há cenário reprovado em aberto, se há issue corretiva
pendente. Uma Validação Manual reprovada não é considerada resolvida só
porque a rodada de testes terminou. Não
implementa correções automaticamente — pendência que exija decisão de
Rafinha interrompe a conclusão e solicita a decisão.

- **Nenhuma pendência** → aprova e conclui.
- **Pendências** → registra e encaminha a issue para a etapa adequada —
  o destino de reprovação é `Fazer - Claude`.

**Resultado esperado:** `Concluído`

### 5.8 Concluído

Estado terminal da issue. Nenhuma ação adicional é esperada nesta coluna.

---

## 6. Camadas de validação

Quatro camadas coexistem — cada uma responde a uma pergunta diferente e
nenhuma substitui a outra:

| Camada | Pergunta que responde |
|---|---|
| Validação local (`Fazer - Claude`) | "O código que acabei de implementar funciona?" |
| GitHub Actions (`Integração`) | "O código enviado ao repositório passa pelos gates técnicos num ambiente independente?" |
| `QA - Claude` | "O sistema integrado continua funcionando e não foram introduzidas regressões?" |
| `Análise final - Rafinha` | "O produto realmente entrega o comportamento esperado?" |

**Princípio, válido em qualquer camada:** falha em validação local ou na
pipeline é **bloqueio de avanço**, nunca só informação de diagnóstico — a
issue não avança até o problema ser corrigido ou Rafinha tratá-lo
explicitamente.

A pipeline (GitHub Actions) não é uma nova etapa do fluxo — é um mecanismo
que roda dentro da etapa Integração. Ela não substitui code review, QA
funcional, nem a aceitação do produto por Rafinha.

---

## 7. Integração GitHub Issues ↔ Jira ↔ Pull Request

> **O Jira é a fonte de verdade do workflow de execução; o GitHub registra
> a origem do problema e a implementação que o resolve, sem criar um
> workflow paralelo.**

Fluxo de origem, quando o trabalho nasce de uma GitHub Issue:

```text
GitHub Issue          (registro do problema/bug/melhoria)
    ↓
jira-issue-creator    (novo trigger: GH Issue como origem)
    ↓
Jira Issue            (guarda referência de volta pra GH Issue)
    ↓
Workflow normal do Jira (as 8 etapas, sem mudança)
```

Responsabilidade de cada sistema:

| Sistema | Responsabilidade |
|---|---|
| GitHub Issue | Registrar o problema, bug ou melhoria identificada |
| Jira Issue | Controlar o trabalho e seu workflow |
| Pull/Merge Request | Registrar a implementação técnica e indicar qual Issue do Jira foi resolvida |
| Confluence | Registrar conhecimento e documentação |
| GitHub Actions | Validar tecnicamente o código enviado ao repositório |

Cadeia de rastreabilidade esperada:

```text
GitHub Issue ↔ Jira Issue ↔ Pull/Merge Request ↔ Commits
```

**Regra importante:** nenhum dos três sistemas mantém workflow paralelo. A
GitHub Issue não avança por colunas próprias — quando vira trabalho de
verdade, o controle passa a ser 100% do Jira.

---

## 8. Gates de passagem

```text
Fazer - Claude
    ↓
Implementação + testes + análise estática + build + documentação + PR aberto
    ↓
Análise - Rafinha
    ↓
Aprovação técnica e funcional
    ↓
Integração
    ↓
GitHub Actions aprovado + conflitos resolvidos + merge
    ↓
QA - Claude
    ↓
Regressão + fluxos afetados + integração (sobre a develop já integrada)
    ↓
Documentar
    ↓
Estado final sincronizado (código + Confluence)
    ↓
Análise final - Rafinha
    ↓
Aceitação funcional
    ↓
Análise final - Claude
    ↓
Auditoria final sem pendências
    ↓
Concluído
```

Uma etapa não é considerada concluída apenas porque uma ação foi
executada — só quando **sua saída esperada está comprovadamente
atendida**.

---

## 9. Responsabilidade de cada etapa em uma frase

| Etapa | Pergunta principal |
|---|---|
| Fazer - Claude | "Consigo implementar a issue e produzir evidências de que a mudança funciona?" |
| Análise - Rafinha | "A implementação está tecnicamente e funcionalmente correta?" |
| Integração | "Essa mudança consegue conviver com o restante do sistema, validada por um ambiente independente?" |
| QA - Claude | "O sistema integrado continua funcionando e não sofreu regressões?" |
| Documentar | "O estado final e validado do sistema está registrado?" |
| Análise final - Rafinha | "O produto realmente entrega o que foi proposto?" |
| Análise final - Claude | "Existe algo que esquecemos ou deixamos inconsistente?" |

---

## 10. Release & Versionamento

Complementa o workflow de 8 etapas com uma camada dedicada ao processo de
entrega do produto — publicado em versões — mantendo os dois ciclos
completamente separados.

### 10.1 Dois ciclos diferentes

> **Issue workflow e Release workflow não são a mesma coisa.**

- **Issue workflow** (seções 4–5 acima) → processo de conclusão de uma
  unidade de mudança. Termina em `Concluído`.
- **Release workflow** (esta seção) → processo de entrega do produto.
  Agrupa várias issues concluídas numa versão publicada.

```text
ISSUE WORKFLOW (inalterado)                RELEASE WORKFLOW

Fazer - Claude                             Issues concluídas
      ↓                                           ↓
Análise - Rafinha                          Agrupamento por componente
      ↓                                           ↓
Integração                                 Definição das versões
      ↓                                           ↓
QA - Claude                                Release Candidate
      ↓                                           ↓
Documentar                                 Validação final
      ↓                                           ↓
Análise final - Rafinha                    Tags
      ↓                                           ↓
Análise final - Claude                     GitHub Releases
      ↓                                           ↓
Concluído                                  Versões publicadas
```

**Regra explícita:** Release nunca vira uma nona coluna do Jira depois de
`Análise final - Claude` — misturaria duas unidades de trabalho diferentes.

### 10.2 Componente: a unidade de versionamento

**A unidade que recebe uma versão é o componente, não o repositório.** Um
repositório pode conter vários artefatos buildáveis e independentes — o
Compass System tem três (`compass-api`, `routecraft_app`,
`travel_matrix`). Cada um evolui no seu próprio ritmo: a API pode ir a
PATCH sem forçar versão nova em nenhum app.

Todo projeto declara seus componentes num manifesto versionado junto com
o código, em `.github/release-components.yml`:

```yaml
components:
  - name: compass-api
    path: compass-api
    type: maven          # maven | flutter | node | ...
  - name: routecraft_app
    path: routecraft_app
    type: flutter
```

Projeto de artefato único declara **um** componente — mesmo formato, sem
caso especial.

**Quem consome o manifesto é a `jira-release-executor`** — para saber o
que versionar, como filtrar escopo e como mapear issue → componente. O
`release.yml` ainda tem os steps de build escritos explicitamente por
componente, porque buildar Maven e buildar Flutter são comandos
diferentes; o manifesto e o workflow precisam ser mantidos em sincronia
na mão. Tornar o workflow orientado pelo manifesto é uma evolução
possível, não o estado atual.

O `path` é também o que mapeia **issue → componente**: os arquivos
tocados pelo Pull Request da issue (campo `Links para merge`) dizem a
quais componentes ela pertence.

> ⚠️ Não confundir componente com a label de plataforma (`web`/`mobile`)
> que a `jira-issue-executor` aplica. São eixos diferentes — plataforma
> serve para a `jira-qa-executor` escolher o executor de QA; componente
> serve para versionar. Reaproveitar um como o outro quebra os dois.

### 10.3 Versionamento (SemVer), por componente

Convenção `MAJOR.MINOR.PATCH`:
- **MAJOR** — mudança incompatível.
- **MINOR** — nova funcionalidade compatível.
- **PATCH** — correção compatível.

Projetos em desenvolvimento inicial começam em `0.x.y` — faixa reservada
pelo próprio SemVer para quando a API/contrato ainda não é considerada
estável, não significa que o projeto está incompleto.

**A tag é sempre namespaced pelo componente:**

```text
compass-api/v0.1.0
routecraft_app/v1.2.0
travel_matrix/v0.4.0
```

Nunca `v1.2.0` solto num projeto multi-componente — três componentes
podem estar em `0.0.1` ao mesmo tempo, e uma tag sem prefixo colide.
Projetos de componente único podem usar `vX.Y.Z` simples, mas usar o
prefixo mesmo assim mantém tudo uniforme e não custa nada.

### 10.4 Quem decide o incremento de versão

**Sempre Rafinha** — nunca o Claude sozinho. O incremento de versão
envolve significado de produto, não é decisão puramente técnica. O Claude
pode e deve sugerir com justificativa (ex.: "recomendo MINOR porque foram
adicionadas funcionalidades compatíveis"), mas a decisão final é sempre
dele.

Com versionamento por componente isso vira **N decisões independentes**,
uma por componente no escopo — não uma decisão só aplicada a todos.

### 10.5 Nem toda issue concluída gera uma release

Uma release representa uma entrega de software, não uma issue. Concluir
várias issues não significa gerar uma versão para cada uma — pode virar
uma única release agrupando todas. Todo projeto **deve** ter
versionamento; nenhuma issue concluída **deve** gerar automaticamente uma
release.

**Também é legítimo versionar um componente só.** Se Rafinha pedir "gera
versão só do routecraft", apenas esse componente recebe versão, tag e
Release — os demais ficam como estão, e suas issues seguem esperando a
release do componente delas.

### 10.6 A entidade "Release" no Jira

Usa a estrutura nativa de Releases/Versions do Jira (**Fix Version**). Uma
Release agrupa issues concluídas — mas **não é pai hierárquico** de
Épico/Issue/Subtask (hierarquia da seção 1). É uma **relação de
versionamento**, não hierárquica:

```text
RELEASE
   ↓
ÉPICO / ISSUE
   ↓
SUBTASK
```

- **Release** responde: "quais mudanças compõem esta versão?"
- **Épico** responde: "qual grande iniciativa estamos desenvolvendo?"

São perguntas diferentes — não confundir as duas hierarquias.

**O nome da versão no Jira é namespaced**, igual à tag:
`routecraft_app 0.2.0`, nunca `0.2.0` solto. Sem o prefixo, três
componentes na mesma versão colapsam numa Fix Version só e a
rastreabilidade se perde.

**Fix Version é multi-valorada, e isso importa.** Uma issue que tocou
dois componentes (adicionou um endpoint na API *e* consumiu ele no app —
o caso comum, não a exceção) recebe **uma Fix Version por componente**, à
medida que cada um for lançado:

```text
CPS-107  Fix Version: routecraft_app 0.2.0     ← lançado hoje
                      compass-api 0.1.0        ← lançado depois
```

A issue só está **inteiramente entregue** quando todos os componentes que
ela tocou saíram. Marcar a issue como lançada na primeira Fix Version é
erro — perde a rastreabilidade de que metade dela ainda não chegou a
ninguém.

### 10.7 Release Lifecycle e a fronteira skill/Action

O ciclo é dividido entre duas responsabilidades, e a divisão é o
princípio central deste processo:

> **A Action faz o que é determinístico. A skill faz o que exige contexto
> do Jira. A skill dispara a Action — nunca reimplementa o que ela faz.**

```text
┌─ SKILL (jira-release-executor) ──────────────────────────┐
│ 1. Levantar issues concluídas sem Fix Version            │
│ 2. Mapear cada issue → componente (arquivos do PR)       │
│ 3. Propor escopo + incremento por componente → Rafinha   │
│ 4. Escrever as notas de release, CHANGELOG.md e README,  │
│    e commitar tudo antes do dispatch                     │
└──────────────────────────────────────────────────────────┘
                          ↓  gh workflow run release.yml
┌─ ACTION (.github/workflows/release.yml) ─────────────────┐
│ 5. Criar a release branch                                │
│ 6. Bump da versão de cada componente no escopo           │
│ 7. Buildar todos os componentes                          │
│ 8. Publicar artefatos da execução                        │
│ 9. Criar tag <componente>/vX.Y.Z e GitHub Release        │
└──────────────────────────────────────────────────────────┘
                          ↓
┌─ SKILL ──────────────────────────────────────────────────┐
│ 10. Validação funcional de Rafinha (gate obrigatório)    │
│ 11. Criar/associar Fix Version namespaced no Jira        │
│ 12. Atualizar a página de Versionamento do projeto       │
└──────────────────────────────────────────────────────────┘
```

Release Candidate (`X.Y.Z-rc.1`), quando o porte do projeto justificar,
entra entre os passos 9 e 10 — iterando com QA até estabilizar.

Quem executa os passos de skill é a `jira-release-executor`, acionada sob
demanda por Rafinha (nunca por varredura automática de coluna, já que
Release não é uma etapa do issue workflow).

### 10.8 A Action de release vive em cada repositório

**Cada projeto tem o seu próprio `.github/workflows/release.yml`,
autocontido.** Ele cria branches, tags e Releases dentro do próprio
repositório e não depende de nenhum repo externo. Instalar a
funcionalidade num projeto novo é copiar o arquivo e escrever o
manifesto da seção 10.2.

É separado do `ci.yml` da etapa de Integração — respondem perguntas
diferentes ("essa alteração pode entrar no sistema?" vs. "este conjunto
específico de código está pronto para virar uma versão oficial?").

**O gatilho é `workflow_dispatch`**, com um campo de versão por
componente. Campo em branco pula aquele componente na rodada.

Duas consequências que são propriedade do desenho, não detalhe:

1. **Rafinha pode fechar uma versão sem o Claude**, pela aba Actions do
   GitHub. A skill é acelerador, não gargalo. O que se perde rodando sem
   ela é a qualidade das release notes e a associação da Fix Version no
   Jira.
2. **Os dois caminhos não podem divergir**, porque a skill dispara
   exatamente o mesmo botão. A skill nunca faz `git tag` na mão.

> ⚠️ Restrição do GitHub: `workflow_dispatch` só aparece se o arquivo
> existir na **branch padrão** do repositório. Num fluxo
> `develop → main`, o `release.yml` precisa estar nas duas — na `main`
> para habilitar o gatilho, na `develop` porque é o código dela que vai
> ser buildado.

### 10.9 As notas de release são texto, não lista de issues

A GitHub Release de cada componente carrega uma descrição **escrita para
qualquer pessoa ler** — inclusive quem não acompanhou a sprint e não sabe
o que é CPS-107. Listar as issues ou os Pull Requests mergeados não
cumpre esse papel.

O mecanismo: a `jira-release-executor` escreve
`.github/release-notes/<componente>-<versao>.md` a partir do campo
`Resumo` das issues e commita **antes** do dispatch; o `release.yml` usa
esse arquivo como corpo da Release (`gh release create --notes-file`).

Sem o arquivo — dispatch manual, sem o Claude no circuito — a Action cai
no `--generate-notes` automático do GitHub, que produz a lista crua de
Pull Requests. Funciona, mas é o resultado pior; é o preço de rodar sem a
skill, não o padrão aceitável.

Princípios do texto:
- descrever a mudança do ponto de vista de **quem usa o sistema**;
- agrupar por tema, não por issue (três issues do mesmo assunto viram um
  parágrafo só);
- chaves de issue, quando presentes, ficam no fim como referência —
  nunca no lugar da explicação;
- sem jargão interno (nome de branch, de arquivo, de classe).

### 10.10 Documentação de versionamento do projeto

Todo projeto com o workflow Rafinha-Claude tem, no seu space do
Confluence, uma página **"Versionamento"** dedicada, contendo:

- a versão atual de cada componente;
- onde fica a Action de release e como acioná-la;
- a convenção de tag do projeto;
- o link para a aba Releases do repositório.

Essa página é a resposta para "em que versão está cada parte do
projeto?" sem precisar abrir o GitHub. Quem a mantém atualizada é a
`jira-release-executor`, no passo 12 do ciclo — não é documentação
escrita à mão.

---

## 11. Model Escalation Policy

Política única de modelo (Sonnet/Opus) e effort (Medium/High/XHigh) para
todas as skills do workflow. Objetivo: economizar quota sem reduzir
qualidade nas etapas que realmente exigem raciocínio elevado.

### 11.1 Princípio geral

```text
Configuração padrão da skill
        ↓
Execução normal
        ↓
Claude avalia a complexidade encontrada
        ↓
Complexidade compatível?
    ┌───────┴───────┐
    │               │
   SIM             NÃO
    │               │
    ↓               ↓
Continua       Interrompe
                    ↓
             Explica o motivo
                    ↓
             Recomenda configuração
                    ↓
             Aguarda Rafinha
                    ↓
          Rafinha altera manualmente
                    ↓
               Continua
```

Identificar a necessidade de escalonamento é responsabilidade de Claude.
Decidir se aceita é sempre responsabilidade de Rafinha. **Claude nunca
troca de modelo ou effort sozinho** — nem automaticamente, nem "por
hábito", nem porque a tarefa é grande.

### 11.2 Configuração padrão global

```text
Modelo: Sonnet
Effort: High
```

Uma skill pode declarar um padrão diferente quando sua natureza
operacional justificar (ver tabela 11.6) — isso não é escalonamento, é
configuração de repouso daquela skill. Nenhuma skill deve usar Opus como
padrão só porque a tarefa *pode* ficar complexa eventualmente.

### 11.3 Hierarquia de escalonamento

```text
Nível 0 — Sonnet + Medium
        ↓
Nível 1 — Sonnet + High
        ↓
Nível 2 — Sonnet + XHigh
        ↓
Nível 3 — Opus + High
        ↓
Nível 4 — Opus + XHigh
```

Preferir subir effort antes de trocar de modelo, enquanto o Sonnet ainda
for adequado ao tipo de raciocínio exigido. Só recomendar troca de modelo
quando o problema exigir uma capacidade de raciocínio que o effort, por si
só, não cobre.

### 11.4 Quando escalar effort (Sonnet permanece adequado)

Considerar quando a execução encontrar: múltiplas abordagens plausíveis
que exigem comparação; comportamento não-determinístico; causa raiz
difícil de isolar; dependências entre vários arquivos/módulos; risco
real de solução incorreta sem raciocínio mais longo; tentativas repetidas
de análise sem conclusão confiável.

### 11.5 Quando escalar para Opus

Considerar quando aumentar o effort do Sonnet provavelmente não resolve:
decisão arquitetural significativa; refatoração transversal a vários
módulos; mudança em contratos/responsabilidades arquiteturais; debugging
extremamente difícil após investigação adequada; comparação entre
estratégias com consequências técnicas relevantes; auditoria que exige
achar inconsistências difíceis de detectar.

**Opus + XHigh é exceção**, não o próximo passo automático depois de Opus
+ High: só quando o problema for extremamente complexo, de alto impacto
arquitetural, com Sonnet + XHigh e Opus + High já considerados
insuficientes.

**Nunca** contam sozinhos como motivo de escalonamento: quantidade de
arquivos, de linhas, de comandos, de mensagens, duração da tarefa, ou o
tamanho da issue/Épico. Esses fatores podem contribuir, mas a decisão é
sobre dificuldade de raciocínio e risco técnico, não sobre volume.

### 11.6 Configuração padrão por natureza de atividade

| Tipo de atividade | Modelo | Effort |
|---|---|---|
| Implementação comum | Sonnet | High |
| Implementação simples | Sonnet | Medium |
| Implementação complexa | Sonnet | XHigh |
| Arquitetura complexa | Opus | High |
| Debugging difícil | Opus | High |
| Refatoração transversal | Opus | High |
| Integração mecânica | Sonnet | Medium |
| QA comum | Sonnet | High |
| QA complexo | Sonnet | XHigh |
| Documentação | Sonnet | Medium |
| Auditoria final | Opus | High |

Orientação geral — uma skill pode sobrescrevê-la com justificativa
explícita na sua própria seção `## Model Policy`.

### 11.7 Formato da interrupção

Ao identificar necessidade de escalonamento, Claude para **antes** de
continuar a parte que depende do raciocínio adicional (nunca depois de já
ter gasto o esforço extra) e apresenta:

```text
ESCALONAMENTO NECESSÁRIO

Motivo:
[explicação objetiva do problema]

Configuração atual:
- Modelo: [modelo]
- Effort: [effort]

Configuração recomendada:
- Modelo: [modelo recomendado]
- Effort: [effort recomendado]

Impacto esperado:
[qual parte da tarefa depende desse escalonamento]

Aguardando Rafinha alterar manualmente a configuração.
```

Depois da mensagem, Claude para e aguarda. A troca pode acontecer na
mesma sessão (sem precisar reiniciar contexto) — Rafinha altera modelo/
effort na configuração do Claude Code e pede para continuar.

### 11.8 Depois que Rafinha aceita um escalonamento

Claude tenta concluir a tarefa normalmente na nova configuração — não
pede novos escalonamentos repetidamente sem evidência concreta. Se mesmo
em Opus + XHigh o problema continuar sem solução segura, Claude
interrompe e devolve a decisão técnica a Rafinha, em vez de insistir
consumindo mais quota.

### 11.9 O que cada skill declara

Cada skill do pipeline declara sua própria política de repouso numa
seção `## Model Policy` logo após `## Identidade do papel`, neste
formato:

```markdown
## Model Policy

Modelo padrão: [Sonnet ou Opus]
Effort padrão: [Medium/High/XHigh]

Escalonar effort quando:
- [critério específico da skill]

Escalonar para Opus quando:
- [critério específico da skill]

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.
```

A política local complementa esta seção global — não pode removê-la.
Skills fora do pipeline de execução Jira (ex.: checklists consultados por
outra skill, ou assistentes pessoais fora deste workflow) não precisam
declarar seção própria; herdam o modelo/effort de quem as invoca.

---

## 12. Validação Humana Agregada

Camada que prepara a etapa `Análise final - Rafinha` (seção 5.6). Não é
uma etapa nova, não é uma coluna nova, e não altera a hierarquia
Épico → Issue → Subtask (seção 1).

### 12.1 O princípio

> **A unidade de implementação é a Issue; a unidade de aceitação humana
> pode agregar múltiplas Issues que alterem o mesmo comportamento
> funcional.**

Várias Issues podem ter sido implementadas, integradas, testadas e
documentadas separadamente e, ainda assim, representarem um único
comportamento do ponto de vista de quem usa o produto. Nesse caso, aceitar
esse comportamento uma vez é mais fiel — e mais barato — do que aceitar
cada Issue isoladamente.

### 12.2 O que a Validação Manual é e o que não é

A `Validação Manual` é uma **unidade de aceitação humana**: o conjunto
mínimo de cenários que ainda exigem julgamento e observação de Rafinha,
depois de tudo o que as camadas automatizadas já cobriram.

Ela **não** substitui `Análise - Rafinha` (code review), `Integração`,
`QA - Claude`, nem `Análise final - Claude`. Ela também **não** é uma
funcionalidade, uma Story, uma etapa de implementação, nem um novo QA.

```text
QA - Claude              "o sistema integrado continua funcionando?"
Validação Humana         "esse comportamento está aceitável como produto?"
```

Nenhum dos dois substitui o outro. O que a Validação Humana elimina é a
**repetição** do que já foi testado — não o julgamento humano.

> **Regra explícita:** a existência de uma Validação Manual não significa
> que Rafinha precise reexecutar os testes que o Claude já executou. O
> objetivo é cobertura automatizada **mais** julgamento humano dirigido,
> nunca QA automatizado **mais** repetição manual completa.

E a recíproca também vale: uma Issue sem cenário observável não deixa de
ser aceita — ela entra numa validação de lote com a justificativa de por
que não gera cenário. Reduzir repetição nunca significa reduzir a
responsabilidade de Rafinha sobre a aceitação do produto (princípio 10 da
seção 2).

### 12.3 Identidade própria

Uma Validação Manual **não é Subtask** de nenhuma Issue. Ela precisa de
ciclo de vida próprio porque agrega várias Issues, sobrevive a múltiplas
tentativas de validação, registra o feedback humano e pode originar Issues
corretivas.

Onde ela vive:

| Aspecto | Convenção |
|---|---|
| Tipo (Jira) | `Validação Manual` onde o tipo existir; senão, `Tarefa` |
| Identificação por máquina | label (categoria) `validacao-humana` — **nunca** o tipo |
| Título | `Validação Manual — <fluxo funcional>` |
| Chave | a do próprio projeto (`CPS-121`); não existe projeto `VAL` |
| Coluna | nasce em `Análise final - Rafinha`, termina em `Concluído` |
| Rastreabilidade | link `Relates` para cada Issue agregada |

Os cinco estados possíveis mapeiam sem criar status novo: *pendente* e *em
validação* = aberta em `Análise final - Rafinha`; *aprovada* = movida para
`Concluído`; *reprovada* = continua aberta, com a label
`validacao-reprovada`; *bloqueada* = label `validacao-bloqueada`.

### 12.4 Quando é gerada

Por **varredura em lote** da coluna `Análise final - Rafinha`, sob demanda,
executada pela `jira-human-validation-executor`. Nunca por issue
individual ao fim da etapa `Documentar` — agregação exige lote, e disparar
por issue produziria uma validação para cada uma, que é exatamente o que
esta camada existe para evitar.

### 12.5 Reprovação

```text
Validação Manual reprovada
        ↓
classificar o problema (Claude propõe, Rafinha decide)
        ↓
┌───────────────────────┬───────────────────────┐
│ pertence ao escopo    │ fora do escopo        │
│ de uma Issue agregada │ original              │
│        ↓              │        ↓              │
│ a Issue original      │ nova Issue de         │
│ volta para            │ implementação,        │
│ Fazer - Claude        │ ligada à validação    │
└───────────────────────┴───────────────────────┘
        ↓
workflow normal
        ↓
nova tentativa da MESMA Validação Manual
```

Regras que não podem ser violadas:

- A Validação Manual **nunca vira Issue de implementação**.
- Problema que já era escopo de uma Issue existente **não gera Issue
  nova** — a Issue original continua sendo a unidade correta de
  implementação, e reabri-la preserva a rastreabilidade.
- Reprovação **não gera Subtask**. Subtask continua sendo apenas
  decomposição interna de uma Issue (seção 1).
- A mesma Validação Manual registra **todas** as tentativas. Ela é o
  registro persistente da aceitação humana daquele comportamento, não um
  ticket descartável.

### 12.6 Efeito nas etapas existentes

| Etapa | O que muda |
|---|---|
| `Documentar` | Nada. Continua movendo a issue para `Análise final - Rafinha`. |
| `Análise final - Rafinha` | Quando existe validação, Rafinha executa a partir dela (seção 5.6). |
| `Análise final - Claude` | Passa a auditar também o estado da validação vinculada (seção 5.7). |
| `Fazer - Claude` | Reconhece `validação humana reprovada` como gatilho de correção, ao lado de `review reprovada por…`. |
| Demais etapas | Nada. |

---

## 13. Execution State & Continuidade

Objetivo: uma issue em execução deve poder ser retomada por uma **nova
sessão** do Claude Code — troca de conta, esgotamento de quota,
encerramento inesperado, reinício da máquina — sem depender do transcript
da sessão anterior. **O chat não é fonte de verdade**, é contexto
temporário; a fonte de verdade de uma execução em andamento é a combinação
de Jira + Git + GitHub/Confluence + o arquivo local desta seção.

### 13.1 O que é e o que não é

Não é uma nova etapa nem uma nova coluna do Jira — é uma camada
transversal usada dentro das etapas que a declaram (13.5). Não substitui
Jira (fonte de verdade do workflow), Git (fonte de verdade do código),
PR/GitHub Actions (fonte de verdade da integração) ou Confluence (fonte de
verdade da documentação) — só registra o que essas fontes não guardam: o
ponto exato de retomada, o que não repetir, e decisões/bloqueios que ainda
não viraram comentário formal.

### 13.2 Localização e formato

`.claude/execution-state/<CHAVE-DA-ISSUE>.md`, no repositório do projeto
(nunca neste repositório de skills). Um arquivo por issue, **sobrescrito**
a cada checkpoint — nunca um log anexado.

```markdown
# Execution State — <CHAVE>

## Estado
EM_EXECUÇÃO | BLOQUEADO | AGUARDANDO_RAFINHA | PRONTO_PARA_PRÓXIMA_ETAPA

## Objetivo atual / contexto de retomada
<2-4 linhas>

## Próxima ação
<ação concreta>

## Não repetir
- ...

## Decisões técnicas
- ...

## Bloqueios / decisões pendentes de Rafinha
- ...

## Última atualização
<data/hora>
```

Seção sem conteúdo real usa "Nenhum" — nunca inventar conteúdo só para
preencher o template (ver 13.4).

Deliberadamente **não inclui** branch, commit, PR, ou resultado de
teste/análise estática: essas informações já são reconstruídas ao vivo, a
cada execução, pela própria skill (convenção de nome de branch, `git log`,
`gh pr view`, campos do Jira) — duplicá-las no arquivo criaria uma segunda
fonte que pode divergir da real.

### 13.3 Política de Git

Só é **commitado** quando a etapa opera numa branch isolada da issue
(`Fazer - Claude`, via `jira-issue-executor`) — nesse caso o arquivo viaja
junto dos commits normais da issue, e é removido (com commit próprio)
antes de a issue seguir para `Análise - Rafinha`/Integração, para nunca
chegar a `develop` por merge.

Nas etapas que operam **depois do merge**, direto sobre `develop`/`main`
(`Integração`, `QA - Claude`, `Documentar`, `Análise final - Claude`), o
arquivo **nunca é commitado** — cairia na regra existente de nunca
commitar direto no trunk. Ele existe só localmente (adicionar
`.claude/execution-state/` ao `.gitignore` do projeto, na primeira vez que
a etapa criar o diretório) — isso ainda cobre o cenário central da
proposta (mesma pasta de trabalho, nova sessão, troca de conta); só não
sobrevive a uma máquina diferente, cenário que a proposta não exige.

### 13.4 Recovery Check

Toda etapa que declara Execution State (13.5) verifica, antes de agir
sobre uma issue:

```text
Existe .claude/execution-state/<CHAVE>.md?
        ↓                          ↓
       NÃO                        SIM
        ↓                          ↓
  fluxo normal da etapa    Ler o arquivo e reconciliar com a realidade:
                            - Jira ainda está na mesma coluna?
                            - (quando aplicável) branch/commit citados
                              ainda existem?
                            - "Próxima ação" ainda faz sentido dado o
                              estado real do código/PR/Confluence agora?
                                 ↓
                    Diverge de um jeito que arrisca decisão ou trabalho?
                    SIM → parar e perguntar a Rafinha
                    NÃO → seguir a partir de "Próxima ação", atualizando
                          o arquivo
```

**O arquivo nunca é instrução cega** — ele indica o que provavelmente
aconteceu; a etapa confirma o que realmente aconteceu antes de agir. Jira,
Git, GitHub e Confluence sempre prevalecem sobre o que está escrito nele.

### 13.5 Onde se aplica

| Etapa | Skill | Commitado? |
|---|---|---|
| Fazer - Claude | `jira-issue-executor` | Sim (branch da issue) |
| Integração | `jira-integration-executor` | Não (local) |
| QA - Claude | `jira-qa-executor` | Não (local) |
| Documentar | `jira-doc-executor` | Não (local) |
| Análise final - Claude | `jira-review-executor` | Não (local) |

Cada uma dessas skills declara os próprios pontos de checkpoint (marcos
relevantes da própria etapa) e o momento de apagar o arquivo — sempre ao
mover a issue adiante, porque Jira/Git/PR/Confluence já viram a fonte de
verdade permanente a partir dali.

### 13.6 Checkpoints, não log

Atualizar apenas em marcos relevantes (início, decisão tomada, bloco de
trabalho concluído, bloqueio encontrado, antes de mover a issue) — nunca a
cada comando. O arquivo descreve o **estado atual**, não o histórico da
execução.

### 13.7 Segurança

Nunca registrar credencial, token, senha ou qualquer segredo no arquivo —
só texto operacional (estado, próxima ação, decisões, bloqueios).

---

## Quando Rafinha aciona esta skill diretamente

Perguntas do tipo:
- "Qual a próxima etapa depois de X?"
- "O que a etapa Y deveria produzir?"
- "Explica o fluxo novo."
- "Essa issue devia ser Issue ou Subtask?"
- "Qual a diferença entre o que a pipeline valida e o que o QA valida?"
- "Como funciona o ciclo de release?" / "Quando uma issue concluída vira
  uma versão?"
- "Posso versionar só um dos componentes?" / "Dá pra fechar versão só do
  app sem mexer na API?"
- "E uma issue que tocou dois componentes, entra em qual versão?"
- "Consigo fechar uma versão sem o Claude?" / "Onde fica o botão de gerar
  versão?"
- "O que é uma Validação Manual?" / "Ela substitui o QA?" / "O que acontece
  quando eu reprovo uma validação?"
- "Como uma nova sessão retoma uma issue interrompida?" / "O que é o
  Execution State?"
- Qualquer dúvida sobre nomenclatura de colunas, ordem das etapas, ou
  regra de bloqueio de avanço.

## O que esta skill NUNCA faz

- ❌ Não cria, não move, não comenta e não transiciona issues no Jira.
- ❌ Não escreve nem edita página nenhuma no Confluence.
- ❌ Não toca em código, git, branch, commit, merge ou pipeline.
- ❌ Não decide sozinha uma ambiguidade de fluxo que deveria ser perguntada
  a Rafinha — ela expõe o critério já definido aqui; quando o caso real não
  se encaixa claramente em nenhuma regra deste documento, a skill que
  consultou deve perguntar a Rafinha, não inferir.
- ❌ Não decide (nem sugere sozinha, fora do contexto de uma execução real
  de `jira-release-executor`) o incremento de versão de uma release — essa
  decisão é sempre de Rafinha (seção 10.4).
