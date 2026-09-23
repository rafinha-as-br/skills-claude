---
name: workflow-development-flow
description: "Skill mãe do Workflow Rafinha-Claude — referência consultável sobre a lista canônica de 10 colunas (A fazer, Design de produto - Rafinha, Fazer - Claude, Análise - Rafinha, Integração, QA - Claude, Análise Final - Rafinha, Documentar, Análise Final - Claude, Concluído), a camada de Design de Produto e o gate `requires-design` com Design Package em `.claude/design-packages/<ISSUE-KEY>/`, os 7 tipos oficiais de ticket (Epic, Implementação, Correção, Bug, Refatoração Técnica, Documentação, Validação Humana) que substituíram o campo customizado `Tipo`, a matriz oficial de labels mantida no Confluence, os 11 gates operacionais e a proibição de fallback silencioso, a hierarquia Épico → Issue → Subtask e a verificação de subtarefas antes de movimentação crítica, as camadas de validação, a integração GitHub Issues ↔ Jira ↔ Pull Request, o MODELO DE BRANCHES (seção 16) — branch da issue, branch de épico opcional e criada só sob comando explícito, develop, release/current e main, mais os três modos da Integração (A: issue→épico, B: épico→develop, C: issue→develop), a regra de que o modo nunca é inferido, e o ciclo das duas labels de estado `integrado-epico` e `qa-develop-aprovado` —, o ciclo separado de Release & Versionamento (contratos completos em `references/release-lifecycle.md`), a Validação Humana Agregada (seção 12) e o Execution State (seção 13). Esta skill NUNCA executa ação nenhuma no Jira, no Confluence ou no código — é só consulta. Use-a quando outra skill do pipeline precisar entender em qual etapa uma issue está, o que vem antes/depois, o que uma etapa deve produzir, qual gate se aplica, ou o que fazer diante de incerteza sobre o fluxo. Rafinha também aciona diretamente com perguntas como 'qual a próxima etapa depois de X', 'o que a etapa Y deveria produzir', 'como funciona o gate de design', 'quais labels são oficiais', 'como funciona o ciclo de release', ou qualquer dúvida sobre o workflow."
---

# Fluxo de Desenvolvimento — Skill Mãe (Rafinha + Claude)

## Identidade do papel

Esta é a **skill mãe** do workflow de desenvolvimento, revisão, integração,
QA e documentação de Rafinha e Claude. Ela guarda o vocabulário e o mapa do
processo que todas as demais skills do pipeline (`jira-issue-creator`,
`jira-issue-executor`, `jira-integration-executor`, `jira-qa-executor`,
`jira-doc-executor`, `jira-human-validation-executor`,
`jira-review-executor`, `product-doc-writer`, `tech-doc-writer`,
`screen-doc-writer`, `jira-release-executor`)
referenciam quando precisam entender em qual etapa uma issue está, o que
vem antes ou depois, o que uma etapa deve produzir, qual gate se aplica, ou
o que fazer diante de incerteza sobre o fluxo — incluindo o ciclo separado
de Release & Versionamento (seção 10), a camada de Validação Humana
Agregada (seção 12), o Execution State (seção 13), a camada de Design de
Produto (seção 14) e o vocabulário de labels (seção 15).

> **Estado do contrato: `preparado`.** Este documento descreve o contrato de
> destino. O Jira ainda não foi configurado — a configuração é manual, feita
> por Rafinha, em sessão separada. Enquanto o estado for `preparado`, estas
> skills vivem na branch `feat/pacote-1-design-labels-gates` e não operam a
> partir de `master`. O merge para `master` é o corte de vigência.

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
qualquer uma das etapas do fluxo (seção 5), é preciso entender sobre qual nível do
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
percorre as etapas do fluxo (seção 5). Contém: problema, objetivo,
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

> ⚠️ **Não confunda com a verificação de subtarefas.** Não reaplicar a
> decisão de nível é diferente de ignorar as subtarefas existentes.

### Verificação de subtarefas antes de movimentação crítica

```text
Subtask não avança sozinha pelo workflow, mas precisa ser inspecionada
antes da issue pai avançar.
```

A Subtask continua **sem ciclo de vida próprio** — ela não percorre colunas.
O que ela ganha é ser **verificada** antes de uma movimentação crítica da
Issue pai.

Antes de mover uma issue para `QA - Claude`, a `jira-integration-executor`:

1. Consulta a issue no Jira.
2. Lista **todas** as subtarefas vinculadas.
3. Verifica o status de cada uma.
4. Identifica se existe subtarefa obrigatória pendente.
5. Se houver, **bloqueia a movimentação da issue pai** (gate 11).
6. Se estiver tudo compatível, move a issue pai.
7. Quando o Jira permitir, move também as subtarefas relevantes.
8. Se a transição da subtarefa não estiver disponível, registra no comentário
   da issue e no resumo final.

**Subtarefa obrigatória** é qualquer subtarefa aberta ligada à implementação,
correção, teste, integração, documentação necessária ou ajuste bloqueante da
Issue pai, e que comprometa a validade funcional ou técnica da entrega caso
fique pendente.

> ⚠️ **Toda subtarefa aberta é tratada como potencialmente obrigatória**,
> salvo quando estiver claramente marcada ou descrita como opcional, futura
> ou não bloqueante. Na dúvida, a skill pergunta — não decide sozinha que uma
> pendência é irrelevante.

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

## 3. Tipos oficiais de ticket

A natureza de uma issue é o **tipo nativo do ticket no Jira**.

> ⚠️ **O campo customizado `Tipo` saiu do contrato operacional.** Nenhuma skill
> deve lê-lo. Se uma skill encontrar o campo, ela o ignora — o tipo do ticket é
> a única fonte.

### 3.1 Os 7 tipos

| Tipo | Natureza | Prefixo de branch |
|---|---|---|
| **Epic** | Frente maior de trabalho. Nunca executado diretamente | — |
| **Implementação** | Altera código de produto | `feat/` |
| **Correção** | Ajusta ou refina algo já entregue | `fix/` |
| **Bug** | Defeito real do produto | `fix/` |
| **Refatoração Técnica** | Melhoria estrutural sem mudança funcional planejada | `refactor/` |
| **Documentação** | Cria/atualiza documentação | sem branch por padrão; `docs/` só se versionada em Git |
| **Validação Humana** | Aceite manual de Rafinha | não gera branch de código |

O tipo **QA/Teste não existe**. QA é etapa do workflow, não tipo de ticket.

### 3.2 Correção não é Bug

**Correção** ajusta algo já entregue sem que isso seja necessariamente defeito
do produto: correção visual de UI já implementada (`correcao-ui`), ajuste de
copy, espaçamento, estado visual, refinamento de implementação anterior.

**Bug** fica reservado a defeito real — erro ao salvar, tela quebrando,
validação incorreta, regressão depois de merge.

Problema visual percebido **depois** da entrega vira **Correção** com
`correcao-ui`, nunca Bug e nunca retorno para a coluna de design.

### 3.3 Documentação declara a trilha por label

Issue do tipo **Documentação** precisa de uma label de trilha documental
(`rn-doc`, `module-doc`, `screen-doc`, `component-doc`, `api-doc`,
`architecture-doc`, `user-doc`, `workflow-doc`, `skill-doc`, `release-doc`,
`readme`, `adr`).

Se nenhuma estiver presente, a skill **pergunta a Rafinha** — não infere a
trilha pelo conteúdo quando isso define qual writer será usado. A label
`confluence` é destino/meio e não satisfaz o gate sozinha.

### 3.4 Subtask

Subtask continua sendo **nível hierárquico, não natureza de trabalho** (seção
1). Não tem ciclo de vida independente. Quando precisar de classificação
operacional, herda o contexto do **tipo do ticket pai**.

### 3.5 Ambiguidade

Quando houver ambiguidade real sobre o tipo na criação da issue, a skill
**pergunta a Rafinha** em vez de inferir silenciosamente.

> 📄 Contrato completo, com campos importantes e Definition of Done de cada
> tipo: página **Tipos oficiais de ticket** no Confluence (espaço CS1).

---

## 4. Fluxo geral — a lista canônica de colunas

```text
A fazer
        ↓
Design de produto - Rafinha      (só quando requires-design)
        ↓
Fazer - Claude
        ↓
Análise - Rafinha
        ↓
Integração
        ↓
QA - Claude
        ↓
Análise Final - Rafinha
        ↓
Documentar
        ↓
Análise Final - Claude
        ↓
Concluído
```

> ⚠️ **Grafia.** As skills comparam o nome da coluna como **texto literal**.
> É `Análise **F**inal`, com F maiúsculo — essa é a grafia real dos status no
> Jira, e o contrato segue o Jira. É `QA - Claude`, com espaços ao redor do
> hífen.

**Duas mudanças em relação ao fluxo anterior:**

1. Entram `A fazer` (entrada do board quando a issue sai do backlog) e
   `Design de produto - Rafinha` (etapa manual, seção 5.2).
2. `Documentar` passou para **depois** de `Análise Final - Rafinha`. A
   documentação descreve o estado **aceito**, não apenas o testado.

**Backlog** continua existindo como etapa pré-sprint, sem mudança. Issue sem
`requires-design` vai de `A fazer` direto para `Fazer - Claude`.

Para issues do tipo Documentação, as etapas técnicas não aplicáveis são
ignoradas conforme o tipo do ticket (seção 3).

**Exceção — Validação Humana.** A issue do tipo `Validação Humana` nasce em
`Análise Final - Rafinha` e vai **direto para `Concluído`**: não passa por
`Documentar` nem por `Análise Final - Claude` (seção 12).

---

## 5. As etapas em detalhe

### 5.1 A fazer

Entrada visual do board quando a issue sai do backlog. Não é etapa de
trabalho — nenhuma skill executa nada aqui.

Da `A fazer` a issue segue para:
- `Design de produto - Rafinha`, quando tem a label `requires-design`;
- `Fazer - Claude`, quando não tem.

### 5.2 Design de produto - Rafinha (manual)

> **Objetivo:** produzir o Design Package que a implementação vai consumir.

**Etapa manual de Rafinha com o Claude Design. Nenhuma skill varre esta
coluna.**

Fluxo: Rafinha constrói o design junto ao Claude Design → ajusta até
considerar adequado → exporta o Design Package → extrai o ZIP → salva o
conteúdo em `.claude/design-packages/<ISSUE-KEY>/` → a issue fica apta a
seguir.

A única atuação esperada de skill em relação a esta coluna:
- **sugerir** que uma issue talvez precise de design;
- **bloquear** a implementação quando `requires-design` existir sem pacote;
- **mover ou apontar** uma issue para design quando Rafinha pedir
  explicitamente.

**Não existe reprovação formal de design.** O design só sai da coluna quando
já está aprovado — por construção, não por veredito.

**Design não cria requisito sozinho.** Comportamento novo que surgir durante
o design precisa virar decisão explícita de Rafinha e ser refletido na issue
antes da implementação.

**Resultado esperado:** `Pronto para Fazer - Claude`

### 5.3 Fazer - Claude

> **Objetivo:** implementar a issue conforme requisitos, regras de negócio e
> arquitetura estabelecidos, produzindo os testes necessários para comprovar
> o comportamento alterado.

**Gate de Design — antes de qualquer linha de código.** Se a issue tem
`requires-design`, a skill procura `.claude/design-packages/<ISSUE-KEY>/`. Se
não encontrar, **para imediatamente** e reporta que o pacote não está
disponível **naquela máquina** — nunca conclui que o design não foi feito, e
nunca implementa no escuro.

Responsabilidades:
- Implementação da issue, respeitando a arquitetura já estabelecida.
- Aplicação dos padrões técnicos do projeto.
- Criação ou atualização de testes automatizados — tipo e quantidade
  proporcionais ao comportamento e risco introduzidos. Testes são
  obrigatórios e proporcionais ao risco.
- Análise estática.
- Verificação de compilação/build quando aplicável.
- Documentação de implementação (não genérica — deve explicar o impacto real
  da alteração).
- Commit + push, em branch cujo prefixo vem do **tipo do ticket** (seção 3.1).
- **Abrir Pull Request**, referenciando a Issue do Jira e, se houver GitHub
  Issue de origem vinculada, referenciá-la também (`Closes #N`).
- **Confirmar ou corrigir a label de plataforma** (`web`/`mobile`/…) conforme
  os arquivos realmente alterados — é o que a `jira-qa-executor` usa depois.
- Quando a issue tem `requires-design`, **registrar no comentário de
  execução** que encontrou e usou o Design Package, e quais IDs canônicos
  foram considerados ou aplicados.

**Labels de risco e controle que esta etapa respeita:**
`do-not-expand-scope`, `needs-manual-decision`, `needs-evidence`,
`high-risk`, `breaking-change`, `legacy`, `needs-human-review`.

**Design System.** Se o design referencia um ID canônico
(`<sigla>.<tipo>.<subtipo>`) que não existe no código nem na documentação de
componentes, a skill **reporta a divergência** — não recria o componente.

Falha de análise estática, build ou teste é bloqueio de avanço.

**Resultado esperado:** `Pronto para Análise - Rafinha`

### 5.4 Análise - Rafinha (manual)

> **Objetivo:** verificar se a implementação atende aos requisitos, às regras
> de negócio, à arquitetura estabelecida e possui testes adequados.

Responsabilidades: code review, verificação de regras de negócio, de
arquitetura, de qualidade da implementação, de testes, avaliação de efeitos
colaterais, decisão de aprovação ou reprovação.

- **Aprovação** → segue para Integração.
- **Reprovação** → volta direto para `Fazer - Claude`, com problema
  encontrado, comportamento esperado e correção necessária registrados.

Uma implementação tecnicamente elegante não deve ser aprovada se não atende
ao requisito, viola regra de negócio, tem arquitetura inadequada, testes
insuficientes para o risco, ou comportamento incorreto.

**Resultado esperado:** `Pronto para Integração`

### 5.5 Integração

> **Objetivo:** integrar a alteração ao destino correto, verificando que ela
> passa pelos gates técnicos num ambiente independente (GitHub Actions) e que
> consegue coexistir com o restante do sistema.

**O destino não é sempre a `develop`.** Esta etapa opera em **três modos**
(ver seção 16):

```text
Modo A: branch da issue  → branch do épico
Modo B: branch do épico  → develop
Modo C: branch da issue  → develop
```

> ❗ **O modo nunca é inferido.** Rafinha informa o modo, ou a skill para e
> pergunta — mesmo quando a estrutura da issue, do épico e das branches
> parece indicar um caminho óbvio. A escolha do modo pertence a Rafinha, não
> à automação. Antes de qualquer merge, a skill imprime o resumo operacional
> (modo, issues, épico, origem, destino, operação, riscos).

Responsabilidades comuns aos três modos, nesta ordem (pipeline antes de
conflito, conflito antes do merge):
1. Confirmar que o Pull Request já existe **e que aponta para o destino do
   modo em execução**.
2. Verificar o GitHub Actions do PR — ainda rodando: aguardar; passou: segue;
   falhou: corrigir e repetir até passar (bloqueio de avanço).
3. Reconciliar com a branch de destino por `git merge` — nunca rebase.
   Conflito mecânico: resolve e registra; conflito semântico real: para e
   pergunta a Rafinha. Depois de qualquer resolução, volta ao passo 2.
4. Merge para o destino.
5. **Smoke test mínimo** sobre o destino — leve, direcionado, suficiente para
   detectar quebra evidente. Não substitui o QA.
6. Registrar o resultado (modo, origem → destino, PR, pipeline, smoke, merge).

O que é específico de cada modo:

| Modo | Específico |
|---|---|
| **A** | Aplica `integrado-epico`. **A issue não muda de coluna** — fica em `Integração` até o épico ser promovido |
| **B** | Exige `integrado-epico` em todas as issues obrigatórias do escopo; valida os 10 critérios de aptidão do épico; move o **lote inteiro** para `QA - Claude` |
| **C** | Move a issue para `QA - Claude` |

**Verificação de subtarefas.** Antes de mover qualquer issue para
`QA - Claude`, a skill consulta a hierarquia real do Jira e bloqueia se
houver subtarefa obrigatória pendente (ver seção 1).

**Conflito semântico** nos modos A e C devolve a issue para
`Análise - Rafinha` antes do merge. No Modo B não há issue única a quem
atribuí-lo: a skill para, registra e pede decisão, sem mover coluna nenhuma.

A integração não declara que o aplicativo inteiro está livre de problemas —
isso é o QA.

**Resultado esperado:** `Pronto para QA - Claude` (modos B e C) ou
`Integrado no épico, aguardando promoção` (modo A)

### 5.6 QA - Claude

> **Objetivo:** verificar se o sistema **já integrado na `develop`** continua
> funcionando e se a alteração não introduziu regressões.

**Gate de plataforma.** A plataforma é lida da label da issue. Se ela for
necessária para escolher o executor e estiver ausente ou ambígua, a skill
**bloqueia e pergunta**. Não existe mais fallback para Web.

**Regra de composição:** plataforma escolhe o **executor**; protocolo de QA
(`functional-qa`, `visual-qa`, `regression-qa`, `e2e-qa`, `smoke-qa`,
`manual-qa`, `maestro`) escolhe a **estratégia** dentro do executor.

Responsabilidades: testes de regressão dos fluxos relacionados, testes dos
fluxos diretamente alterados, testes de integração quando a alteração
atravessa várias camadas, identificação de efeitos colaterais, registro dos
resultados e evidências.

**Gate de Bug.** Defeito real encontrado aqui **não vira Bug criado por esta
skill** — é delegado à `jira-issue-creator`, preservando rascunho, aprovação
e criação controlada por Rafinha.

**QA não julga design.** A skill pode validar sintomas visuais dentro do que
o ambiente permite, mas não decide se o design está certo ou errado como
decisão de produto.

**QA de lote.** O Modo B da Integração promove um épico inteiro de uma vez, e
o lote que chega aqui pode ser o épico completo. O **veredito continua sendo
por issue**: cada uma mantém evidência própria e é julgada pelo seu mérito.
Uma reprovação não bloqueia a aprovação das demais. O conjunto é registrado
no épico como fato, não como unidade de julgamento.

**Labels operacionais.** Esta é a única etapa que aplica
`qa-develop-aprovado` e a única que remove `integrado-epico` (seção 16):

| Veredito | `qa-develop-aprovado` | `integrado-epico` |
|---|---|---|
| Aprovado | aplica | remove |
| Reprovado | não aplica | remove |
| Inconclusivo por infraestrutura | não aplica | **não mexe** |

- **Aprovado** → segue para `Análise Final - Rafinha`.
- **Reprovado** → volta para `Fazer - Claude`. **Nunca** para a coluna de
  design.
- **Inconclusivo por infraestrutura** → não move e não mexe em label.

**Resultado esperado:** `Pronto para Análise Final - Rafinha`

### 5.7 Análise Final - Rafinha (manual)

> **Objetivo:** analisar se o produto realmente entrega o que era proposto.

Não repete o code review já feito na `Análise - Rafinha`. O foco é:

> **O produto entregue resolve corretamente o problema que a issue deveria
> resolver?**

Responsabilidades: validação funcional, uso das funcionalidades entregues,
confirmação de comportamento e regra de negócio, aceitação ou rejeição.

- **Aprovação** → segue para `Documentar`.
- **Reprovação** → volta direto para `Fazer - Claude`, com o problema
  registrado.

**Preparação por Validação Humana Agregada (seção 12).** Quando existir uma
`Validação Humana` cobrindo a issue, Rafinha executa esta etapa **a partir
dela**, e não issue por issue: os cenários, as pré-condições e os pontos de
observação já vêm prontos, e a aprovação vale para todas as issues agregadas
de uma vez.

**Resultado esperado:** `Pronto para Documentar`

### 5.8 Documentar

> **Objetivo:** registrar o estado final e **aceito** do sistema, mantendo
> sincronizadas a documentação do código e a do Confluence.

Roda **depois** da aceitação de Rafinha. Descreve o estado que foi aceito,
não apenas o que foi testado.

Responsabilidades: atualização da documentação de módulos no código (pasta
`docs/`, só o que fizer sentido), atualização do Confluence (regra de
negócio, módulo, tela), sem burocracia — nada é criado só por criar.

**Exclusão obrigatória.** A varredura desta coluna **ignora issues com a
label `validacao-humana`** — a issue de Validação Humana não passa por aqui
(seção 12).

**Resultado esperado:** `Pronto para Análise Final - Claude`

### 5.9 Análise Final - Claude

> **Objetivo:** auditoria final da issue para identificar pendências,
> inconsistências ou itens não contemplados nas etapas anteriores.

Recebe de `Documentar`. Verifica: testes faltantes, documentação
inconsistente, requisitos não atendidos, pendências não resolvidas,
divergência entre implementação e documentação, divergência entre
documentação do código e Confluence, evidências ausentes, **e o estado da
Validação Humana vinculada** (seção 12).

Auditoria acrescentada pelo contrato de labels e gates:
- as labels aplicadas foram respeitadas;
- a implementação **não expandiu escopo**;
- labels de risco e controle foram respeitadas pelas skills consumidoras;
- issue com `requires-design` tem **registro** de uso do Design Package — a
  auditoria olha o registro no comentário, **não a pasta local**, que é
  efêmera e pode não existir mais na máquina;
- o QA executou o protocolo esperado;
- evidências foram registradas quando as labels exigiram;
- correção visual foi tratada como **Correção** com `correcao-ui`, e não como
  Bug ou feature nova.

Não implementa correções automaticamente — pendência que exija decisão de
Rafinha interrompe a conclusão e solicita a decisão.

- **Nenhuma pendência** → aprova e conclui.
- **Pendências** → registra e devolve para `Fazer - Claude`.

**Resultado esperado:** `Concluído`

### 5.10 Concluído

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
| `Análise Final - Rafinha` | "O produto realmente entrega o comportamento esperado?" |

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
Workflow normal do Jira (as etapas da seção 5, sem mudança)
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

## 8. Gates

Existem dois tipos de gate, e eles respondem perguntas diferentes.

### 8.1 Gates de passagem — "posso avançar?"

```text
A fazer
    ↓
(requires-design? → Design de produto - Rafinha; senão → Fazer - Claude)
    ↓
Design de produto - Rafinha
    ↓
Design Package exportado e salvo em .claude/design-packages/<ISSUE-KEY>/
    ↓
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
Modo declarado por Rafinha (A, B ou C) + resumo operacional confirmado
    ↓
GitHub Actions aprovado + conflitos resolvidos + merge + smoke test
    ↓
(Modo A → volta a aguardar em Integração, com `integrado-epico`)
(Modos B e C → subtarefas verificadas → segue)
    ↓
QA - Claude
    ↓
Regressão + fluxos afetados (sobre a develop já integrada)
    ↓
Análise Final - Rafinha
    ↓
Aceitação funcional
    ↓
Documentar
    ↓
Estado aceito sincronizado (código + Confluence)
    ↓
Análise Final - Claude
    ↓
Auditoria final sem pendências
    ↓
Concluído
```

Uma etapa não é considerada concluída apenas porque uma ação foi executada —
só quando **sua saída esperada está comprovadamente atendida**.

### 8.2 Gates operacionais — "tenho contexto para executar?"

Um gate operacional interrompe a execução **antes** do trabalho, quando falta
informação obrigatória. Não é uma camada de validação — é a condição de
entrada delas.

| # | Gate | Condição de bloqueio | Skill responsável |
|---|---|---|---|
| 1 | Design | `requires-design` presente e Design Package ausente na máquina | `jira-issue-executor` |
| 2 | Tipo de ticket | Tipo ausente ou incompatível com a natureza do trabalho | `jira-issue-creator`, `jira-issue-executor` |
| 3 | Documental | Tipo Documentação sem label de trilha | `jira-doc-executor`, `jira-issue-executor` |
| 4 | Plataforma | Label de plataforma ausente/ambígua quando necessária | `jira-qa-executor` |
| 5 | Bug em QA | Defeito real encontrado durante QA | `jira-qa-executor` |
| 6 | Labels | Label necessária fora da matriz oficial | todas |
| 7 | Design System | ID canônico no design sem componente correspondente | `jira-issue-executor` |
| 8 | Avanço entre colunas | Saída esperada da etapa não comprovadamente atendida | skill dona da etapa |
| 9 | Modo de integração | Modo não informado por Rafinha nem confirmado por ele | `jira-integration-executor` |
| 10 | Integração de épico | Issue obrigatória do escopo sem `integrado-epico` na promoção | `jira-integration-executor` |
| 11 | Subtarefa | Subtarefa obrigatória pendente antes de mover a issue pai para `QA - Claude` | `jira-integration-executor` |

> O gate **G10 de elegibilidade de release** (todo commit do intervalo
> `release/current..develop` precisa rastrear para issue com
> `qa-develop-aprovado`) pertence ao ciclo separado de Release — ver
> `references/release-lifecycle.md`, §22. Ele não é um gate do fluxo de
> issues e não aparece na tabela acima.

### 8.3 Proibido fallback silencioso

> **Quando o contrato esperado não é encontrado, a skill para e reporta.**
> Ela nunca adivinha, nunca assume o valor mais comum e nunca volta a ler o
> contrato antigo.

Um gate que "deixa passar com um aviso" não é gate. Se a execução continua, a
informação não era obrigatória — e então não deveria ser gate.

O caso concreto que motivou a regra: a `jira-qa-executor` assumia `web` quando
não havia label de plataforma. Isso transformava uma lacuna de informação numa
decisão silenciosa — e um QA rodando no executor errado produz um verde que
não significa nada.

> 📄 Contrato completo de cada gate, com mensagens de bloqueio: página
> **Gates operacionais** no Confluence (espaço CS1).

---

## 9. Responsabilidade de cada etapa em uma frase

| Etapa | Pergunta principal |
|---|---|
| A fazer | "Esta issue está pronta para entrar no fluxo?" |
| Design de produto - Rafinha | "O design está adequado para ser implementado?" |
| Fazer - Claude | "Consigo implementar a issue e produzir evidências de que a mudança funciona?" |
| Análise - Rafinha | "A implementação está tecnicamente e funcionalmente correta?" |
| Integração | "Essa mudança consegue conviver com o restante do sistema, validada por um ambiente independente?" |
| QA - Claude | "O sistema integrado continua funcionando e não sofreu regressões?" |
| Análise Final - Rafinha | "O produto realmente entrega o que foi proposto?" |
| Documentar | "O estado aceito do sistema está registrado?" |
| Análise Final - Claude | "Existe algo que esquecemos ou deixamos inconsistente?" |

---

## 10. Release & Versionamento

Camada dedicada à entrega do produto em versões, mantida **completamente
separada** do workflow de issue (seções 4–5).

> 📄 **Referência completa:** `references/release-lifecycle.md` — contratos do
> manifesto, do Release Request, da Release Action, do Runtime Package, da
> distribuição e do Orchestrator, mais os gates do ciclo. Carregue esse arquivo
> sempre que a pergunta for sobre *como* o ciclo funciona por dentro. O resumo
> abaixo responde as perguntas de fronteira.

### 10.1 Dois ciclos diferentes

- **Issue workflow** (seções 4–5) → conclusão de uma unidade de mudança. Termina
  em `Concluído`.
- **Release workflow** → entrega do produto. Agrupa issues concluídas numa
  versão publicada.

Uma issue chegar a `Concluído` **não** significa que foi lançada.

**Regras invioláveis:** Release nunca vira coluna do Jira; nunca é acionada por
varredura de coluna; só começa quando Rafinha pede; nenhuma issue concluída gera
release automaticamente.

### 10.2 Projeto, Repositório e Componente

Três conceitos distintos. **Projeto** é a unidade de produto; **repositório** é
unidade técnica de armazenamento; **componente** é a unidade versionável.

Um projeto pode ser **monorepo** (um repositório, vários componentes) ou
**multi-repo** (vários repositórios, cada um com seus componentes, reunidos numa
pasta mãe local que não é Git). A topologia é **declarada** no manifesto
`.release/project.yml`, nunca inferida.

### 10.3 Dois níveis de versão

A unidade versionada é o **componente**, com tag namespaced
`<componente>/vX.Y.Z`. Uma distribuição completa recebe também uma versão de
**produto** (`GeoPrag 1.0.0`), que identifica o conjunto sem substituir as
versões dos componentes.

**Quem decide o incremento é sempre Rafinha** — N decisões numa release parcial,
N+1 numa completa.

> ⚠️ Componente não é a label de plataforma (`web`/`mobile`). São eixos
> diferentes: plataforma escolhe o executor de QA, componente versiona.

### 10.4 Os dois eixos de um pedido

```text
Release Request
├── Type   → PRE_RELEASE | FINAL
└── Scope  → parcial | completa
```

`rc.N` é o identificador SemVer de uma pre-release candidata à final, não um
mecanismo separado. `publish` é modo operacional, **não** um terceiro tipo.

Release completa = todos os componentes declarados, menos exclusões permanentes
do manifesto — e significa que todos estão **presentes na distribuição**, não que
todos receberam versão nova.

### 10.5 Fronteira skill / Orchestrator / Action

> A **Action** faz o que é determinístico dentro de um repositório.
> O **Orchestrator** faz o que é determinístico entre repositórios.
> A **skill** faz o que exige contexto de Jira, Confluence e decisão humana.

O Orchestrator dispara as Actions e monta a distribuição, mas **não decide** —
recebe um Release Request já fechado. A Action continua sendo um
`workflow_dispatch` comum, então **Rafinha fecha um componente pela aba Actions
sem skill e sem Orchestrator**.

Quem executa os passos de skill é a `jira-release-executor`, sempre sob demanda.

### 10.6 Onde o ciclo toca Jira e Confluence

- **Fix Version**: namespaced, multi-valorada, **só em release FINAL** e **só por
  componente**. A versão do produto não vira Fix Version.
- **Confluence**: todo projeto tem a árvore `CI/CD - Workflow Rafinha-Claude`, e
  ela é **pré-requisito da primeira release**. Sem ela documentada, a release não
  começa.

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

Camada que prepara a etapa `Análise Final - Rafinha` (seção 5.7). Não é
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

### 12.2 O que a Validação Humana é e o que não é

A `Validação Humana` é uma **unidade de aceitação humana**: o conjunto
mínimo de cenários que ainda exigem julgamento e observação de Rafinha,
depois de tudo o que as camadas automatizadas já cobriram.

Ela **não** substitui `Análise - Rafinha` (code review), `Integração`,
`QA - Claude`, nem `Análise Final - Claude`. Ela também **não** é uma
funcionalidade, uma Story, uma etapa de implementação, nem um novo QA.

```text
QA - Claude              "o sistema integrado continua funcionando?"
Validação Humana         "esse comportamento está aceitável como produto?"
```

Nenhum dos dois substitui o outro. O que a Validação Humana elimina é a
**repetição** do que já foi testado — não o julgamento humano.

> **Regra explícita:** a existência de uma Validação Humana não significa
> que Rafinha precise reexecutar os testes que o Claude já executou. O
> objetivo é cobertura automatizada **mais** julgamento humano dirigido,
> nunca QA automatizado **mais** repetição manual completa.

E a recíproca também vale: uma Issue sem cenário observável não deixa de
ser aceita — ela entra numa validação de lote com a justificativa de por
que não gera cenário. Reduzir repetição nunca significa reduzir a
responsabilidade de Rafinha sobre a aceitação do produto (princípio 10 da
seção 2).

### 12.3 Identidade própria

Uma Validação Humana **não é Subtask** de nenhuma Issue. Ela precisa de
ciclo de vida próprio porque agrega várias Issues, sobrevive a múltiplas
tentativas de validação, registra o feedback humano e pode originar Issues
corretivas.

Onde ela vive:

| Aspecto | Convenção |
|---|---|
| Tipo (Jira) | `Validação Humana` onde o tipo existir; senão, `Tarefa` |
| Identificação por máquina | label (categoria) `validacao-humana` — **nunca** o tipo |
| Título | `Validação Humana — <fluxo funcional>` |
| Chave | a do próprio projeto (`CPS-121`); não existe projeto `VAL` |
| Coluna | nasce em `Análise Final - Rafinha`, termina em `Concluído` |
| Rastreabilidade | link `Relates` para cada Issue agregada |

Os cinco estados possíveis mapeiam sem criar status novo: *pendente* e *em
validação* = aberta em `Análise Final - Rafinha`; *aprovada* = movida para
`Concluído`; *reprovada* = continua aberta, com a label
`validacao-reprovada`; *bloqueada* = label `validacao-bloqueada`.

### 12.4 Quando é gerada

Por **varredura em lote** da coluna `Análise Final - Rafinha`, sob demanda,
executada pela `jira-human-validation-executor`. Nunca por issue
individual ao fim da etapa `Documentar` — agregação exige lote, e disparar
por issue produziria uma validação para cada uma, que é exatamente o que
esta camada existe para evitar.

### 12.5 Reprovação

```text
Validação Humana reprovada
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
nova tentativa da MESMA Validação Humana
```

Regras que não podem ser violadas:

- A Validação Humana **nunca vira Issue de implementação**.
- Problema que já era escopo de uma Issue existente **não gera Issue
  nova** — a Issue original continua sendo a unidade correta de
  implementação, e reabri-la preserva a rastreabilidade.
- Reprovação **não gera Subtask**. Subtask continua sendo apenas
  decomposição interna de uma Issue (seção 1).
- A mesma Validação Humana registra **todas** as tentativas. Ela é o
  registro persistente da aceitação humana daquele comportamento, não um
  ticket descartável.

### 12.6 Efeito nas etapas existentes

| Etapa | O que muda |
|---|---|
| `QA - Claude` | Passa a mover a issue aprovada para `Análise Final - Rafinha` (antes ia para `Documentar`). |
| `Análise Final - Rafinha` | Quando existe validação, Rafinha executa a partir dela (seção 5.7). Issues aprovadas seguem para `Documentar`. |
| `Documentar` | Documenta o estado **aceito**, não só o testado. **Ignora issues com a label `validacao-humana`** na varredura. |
| `Análise Final - Claude` | Passa a receber de `Documentar` e audita também o estado da validação vinculada (seção 5.9). |
| `Fazer - Claude` | Reconhece `validação humana reprovada` como gatilho de correção, ao lado de `review reprovada por…`. |
| Demais etapas | Nada. |

### 12.7 Ciclo próprio da issue de validação

A issue do tipo `Validação Humana` nasce em `Análise Final - Rafinha` e vai
**direto para `Concluído`**. Ela **não** passa por `Documentar` nem por
`Análise Final - Claude`.

**Por quê.** Uma validação é um registro de aceite, não uma entrega de
produto. Não há o que documentar sobre ela, e a auditoria final audita as
issues agregadas, não o ticket de aceite.

**Consequência operacional.** A `jira-doc-executor` **ignora** issues com a
label `validacao-humana` ao varrer `Documentar`. É por isso que a
identificação é por label e não por tipo — o filtro precisa funcionar mesmo
em projeto onde o tipo não foi criado.

**Consequência no Jira.** Precisa existir transição direta de
`Análise Final - Rafinha` para `Concluído`.

### 12.8 Labels de cenário

Além das três labels de estado (`validacao-humana`, `validacao-reprovada`,
`validacao-bloqueada`), os cenários podem ser tipificados:

| Label | Foco do cenário |
|---|---|
| `acceptance-check` | Aceite do fluxo |
| `visual-check` | Percepção visual |
| `business-flow-check` | Coerência com a regra de negócio |
| `copy-check` | Revisão de textos |
| `usability-check` | Usabilidade |

Elas tornam explícito **o que Rafinha precisa observar**, em vez de deixar
isso só na prosa da descrição.

> A label `validacao-aprovada` **saiu do contrato**. O estado aprovado já é
> representado pela coluna `Concluído` e pelo histórico.

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

```text
Execution State versionado pertence à branch da issue.
Fora dela, é apenas estado local de execução.
```

Só é **commitado** quando a etapa opera numa branch isolada da issue
(`Fazer - Claude`, via `jira-issue-executor`) — nesse caso o arquivo viaja
junto dos commits normais da issue, e é removido (com commit próprio)
antes de a issue seguir para `Análise - Rafinha`/Integração, para nunca
chegar por merge à branch de destino, seja ela a `develop` ou a branch do
épico.

**Nenhuma outra branch recebe commit de Execution State:** `epic/**`, a
`develop`, a `release/current` e as branches efêmeras de release estão
todas fora. Nas etapas que operam **depois do merge** (`Integração`,
`QA - Claude`, `Documentar`, `Análise Final - Claude`), o arquivo **nunca
é commitado** — cairia na regra existente de nunca commitar direto no
trunk. Isso vale para os três modos da `jira-integration-executor`,
inclusive o Modo A, que opera sobre a branch do épico. Ele existe só localmente (adicionar
`.claude/execution-state/` ao `.gitignore` do projeto, na primeira vez que
a etapa criar o diretório) — isso ainda cobre o cenário central da
proposta (mesma pasta de trabalho, nova sessão, troca de conta); só não
sobrevive a uma máquina diferente, cenário que a proposta não exige.

> **Duas pastas locais, mesma regra.** `.claude/execution-state/` e
> `.claude/design-packages/` (seção 14) são ambas locais e não versionadas.
> As duas entram no `.gitignore` do projeto. A diferença é que o Execution
> State *pode* ser commitado na branch isolada da issue, enquanto o Design
> Package **nunca** vai para o Git.

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
| Análise Final - Claude | `jira-review-executor` | Não (local) |

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

## 14. Camada de Design de Produto

Camada transversal que entra **antes** de `Fazer - Claude`. Não substitui
nenhuma etapa; ela produz o insumo que a implementação consome.

### 14.1 A label `requires-design`

É a **única** label do vocabulário com regra de aplicação diferenciada.

| Regra | Detalhe |
|---|---|
| Quem aplica | **Rafinha, manualmente. Sempre** |
| O que a skill pode fazer | `jira-issue-creator` pode **sugerir** no rascunho, marcada como sugestão |
| O que a skill não pode fazer | Aplicar `requires-design` silenciosamente. Nunca |
| `ui` e `correcao-ui` | **Não** obrigam Design Package. O gatilho é exclusivamente `requires-design` |
| Depois da entrega | A label **permanece** como marcador histórico |

**Por que permanece.** `requires-design` é o registro rastreável de que
aquela implementação dependeu de um Design Package. Depois da
implementação, ela **não** significa que a issue ainda aguarda design.

### 14.2 O Design Package

```text
.claude/
└── design-packages/
    └── <ISSUE-KEY>/
        └── conteúdo extraído do Design Package
```

| Regra | Detalhe |
|---|---|
| Versionamento | **Nunca** vai para o Git nem para o remoto |
| `.gitignore` | `.claude/design-packages/` entra no `.gitignore` do projeto |
| Persistência | Não precisa ser preservado como histórico permanente |
| Escopo | Local à máquina onde a implementação roda |
| ZIP | Meio de **transporte**. O conteúdo **extraído** é a referência |

**Sem documento auxiliar obrigatório.** Não é preciso gerar
`implementation-contract.md` nem equivalente. A rastreabilidade entre design
e implementação é feita pelos **IDs canônicos**, não por um arquivo por issue.

### 14.3 O bloqueio

Quando a issue tem `requires-design` e a pasta não existe na máquina, a
`jira-issue-executor` **para antes de escrever código** e reporta que o
artefato não está disponível **naquela máquina**.

> A skill nunca conclui "o design não foi feito". Ela conclui "o artefato não
> está aqui". O pacote é local e efêmero por definição — a ausência numa
> máquina não diz nada sobre o estado do design.

Não é preciso Execution State para esse bloqueio: ele ocorre antes de a
implementação começar, e o Jira já representa o estado da issue.

### 14.4 IDs canônicos de componentes reutilizáveis

A ponte entre Claude Design e Claude Code é **contrato textual**, não
integração automática:

```text
<sigla>.<tipo-do-componente>.<subtipo-do-componente>
```

A **sigla** vem da página de Controle de workflow do produto, no Confluence.
Ela é definida **manualmente** — **nenhuma skill infere sigla**.

O mesmo ID precisa existir em três lugares: página de Design System do
projeto no Claude Design, catálogo de componentes no Confluence, e
documentação do componente no código.

**Componente candidato** usa `<sigla>.candidate.<nome>` e **não** é
componente reutilizável oficial até haver aprovação, implementação e entrada
no catálogo.

**Regra de implementação:** reaproveitar componente existente com ID
correspondente; **nunca recriar** o que já existe; **reportar divergência**
quando o design citar um ID que não existe no código nem no catálogo.

### 14.5 Registro na execução

Issue com `requires-design` exige, no comentário de execução, o registro de
que o pacote foi encontrado e usado, e quais IDs canônicos foram considerados.

A `jira-review-executor` audita **esse registro**, não a pasta local — que é
efêmera e pode não existir mais quando a auditoria rodar.

> 📄 Contrato completo: páginas **Design Package e requires-design**,
> **Controle de workflow por produto** e **Componentes reutilizáveis por
> produto** no Confluence (espaço CS1).

---

## 15. Vocabulário de labels

### 15.1 A regra central

> **Nenhum agente pode inventar label fora da matriz oficial.**

- Label **documentada** na matriz → a skill pode aplicá-la e criá-la no Jira
  sob demanda, mesmo que ainda não exista naquele projeto.
- Label **não documentada** → a skill não inventa, não aplica, e **pergunta**.
- **Não existe limite fixo** de labels por issue. A regra é usar apenas
  labels necessárias, documentadas e justificáveis.

**A fonte de verdade é o Confluence, não esta skill.** Esta seção descreve as
categorias e as regras de consumo; a lista completa, com significado e
exemplos de cada label, vive na página **Vocabulário operacional de labels**
(espaço CS1).

### 15.2 Padrão de nomenclatura

Minúsculas, sem acento, sem espaço, `kebab-case` quando composta.

### 15.3 As 11 categorias

| Categoria | Para quê | Fonte |
|---|---|---|
| Área técnica | `ui`, `frontend`, `backend`, `database`, `api`, `state-management`, `integration`, `infra`, `pipeline`, `architecture` | matriz global |
| Plataforma | `web`, `mobile`, `desktop`, `android`, `ios`, `api-only` | matriz global |
| Protocolo de QA | `functional-qa`, `visual-qa`, `regression-qa`, `e2e-qa`, `smoke-qa`, `manual-qa`, `maestro` | matriz global |
| Design | `requires-design` | matriz global |
| Validação humana | `validacao-*` e os `*-check` | matriz global |
| Risco e controle | `high-risk`, `breaking-change`, `legacy`, `needs-human-review`, `do-not-expand-scope`, `needs-evidence`, `needs-manual-decision`, `intermittent`, `reproducible`, `regression` | matriz global |
| Natureza do defeito | `correcao-ui`, `visual-bug`, `data-bug`, `build-bug` | matriz global |
| Refatoração técnica | `cleanup`, `deduplication`, `performance`, `testability`, `dependency`, `naming` | matriz global |
| Documentação | trilhas documentais (`rn-doc`, `module-doc`, `screen-doc`, `component-doc`, …) | matriz global |
| **Produto / módulo / feature** | labels específicas de um produto | **página de Controle de workflow daquele produto** |
| Estado operacional de integração | `integrado-epico`, `qa-develop-aprovado` | matriz global |

> ⚠️ A décima categoria é a única cuja lista **não** vive na matriz global. A
> matriz define que a categoria existe e como ela se comporta; **quais** labels
> existem é declarado por produto. Se a label não estiver declarada na página
> do produto, a skill pergunta.

**A décima primeira categoria é estado, não natureza.** `integrado-epico` diz
em qual branch o código da issue já foi mergeado — informação que a coluna
`Integração` não carrega, porque ela é uma só para três destinos de merge.
`qa-develop-aprovado` diz que aquele QA sobre a `develop` passou — informação
que o ciclo de release precisa ler muito depois de a issue já ter saído de
`QA - Claude`, e release não é coluna do board.

Por isso elas não contradizem a regra que tirou a label genérica de revisão do
contrato: aquela duplicava a coluna, estas duas carregam o que nenhuma coluna
tem. O ciclo de vida completo das duas vive na matriz do Confluence.

> ⚠️ **Ausência de `integrado-epico` é bloqueio, não "ainda não integrada".**
> As duas leituras possíveis — "não foi integrada" e "foi integrada mas a
> label falhou" — levam a consequências opostas, e a skill não tem como
> distinguir. Ela para e pergunta.

### 15.4 O que saiu do contrato

| Saiu | Motivo |
|---|---|
| Label genérica de revisão, em todas as grafias | A revisão já é representada por coluna do workflow |
| `validacao-aprovada` | O estado aprovado já é a coluna `Concluído` mais o histórico |
| Labels de agente/modelo (`needs-opus`, `needs-sonnet`, `claude-suitable`, `codex-suitable`) | Modelo e esforço são a Model Escalation Policy (seção 11), não label |

---

## 16. Modelo de branches

O workflow de issues tem colunas. O de branches tem **níveis**, e eles não se
confundem: uma coluna diz em que etapa a issue está; uma branch diz onde o
código dela vive.

### 16.1 Os níveis

```text
main                          produção / publicado
  ↑
release/current               estabilização da próxima release (persistente)
  ↑
develop                       integração do produto
  ↑
epic/<EPIC-KEY>-<nome>        agrupamento técnico de um épico (opcional)
  ↑
{tipo}/<ISSUE-KEY>-claude     trabalho de uma issue
```

| Branch | Representa | Criada por |
|---|---|---|
| `{tipo}/<ISSUE-KEY>-claude` | Trabalho de uma issue | `jira-issue-executor` |
| `epic/<EPIC-KEY>-<nome>` | Agrupamento técnico de um épico | `jira-issue-executor`, **só sob comando explícito** |
| `develop` | Integração do produto | — |
| `release/current` | Estabilização da próxima release | `jira-release-executor` |
| `main` | Produção/publicado, quando o projeto usa assim | — |

A convenção de nome da branch de issue **não mudou** com a entrada do nível
de épico. O prefixo continua vindo do tipo do ticket (seção 3.1).

### 16.2 A branch de épico é opcional e explícita

```text
Branch de épico só é criada mediante comando explícito de Rafinha.
```

> ❗ **Pertencer a um épico não autoriza, por si só, a criação da branch.**
> Uma issue vinculada a um épico sem branch segue o fluxo normal e integra
> direto na `develop` (Modo C). Isso é o comportamento esperado, **não** uma
> lacuna a ser corrigida pela automação.

A branch do épico nasce da `develop`, e a origem é registrada em comentário
no épico. Rodar a coluna `Fazer - Claude` **nunca** cria branch de épico.

### 16.3 A base da branch da issue

| Situação | Branch base | Destino do PR |
|---|---|---|
| Issue de épico **com** branch ativa | `epic/<EPIC-KEY>-<nome>` | a branch do épico |
| Issue de épico **sem** branch | `develop` | `develop` |
| Issue sem épico | `develop` | `develop` |

```text
base da branch da issue = destino do PR = destino que a Integração valida
```

Os três são o mesmo valor. A `jira-issue-executor` escolhe a base e abre o PR
contra ela; a `jira-integration-executor` valida que bate com o modo. A base
escolhida é **registrada** no Execution State e no comentário da issue, para
a validação não depender de arqueologia de histórico.

> ⚠️ Mais de uma branch `epic/<EPIC-KEY>-*` para o mesmo épico é **bloqueio**.
> Escolher sozinha significaria decidir onde o trabalho vai parar.

### 16.4 As duas labels de estado

O board tem **uma** coluna `Integração` para três destinos de merge, e o ciclo
de release lê a issue muito depois de ela ter saído de `QA - Claude`. Duas
labels carregam o que nenhuma coluna consegue dizer:

| Label | Significa | Aplica | Remove |
|---|---|---|---|
| `integrado-epico` | O código está na branch do épico, ainda não validado na `develop` | `jira-integration-executor` (Modo A) | `jira-qa-executor`, no veredito |
| `qa-develop-aprovado` | A issue passou no QA sobre a `develop` | `jira-qa-executor`, só na aprovação | ninguém — é permanente |

**Nenhuma skill aplica e remove a mesma label.** Quem cria um estado nunca é
quem o encerra, e as duas pontas ficam auditáveis pela
`jira-review-executor` (pontos 8, 9 e 10 da auditoria de contrato).

> ❗ **Ausência de `integrado-epico` é bloqueio, não "ainda não integrada".**
> As duas leituras possíveis — "não foi integrada" e "foi integrada mas a
> label falhou" — levam a consequências opostas, e a skill não tem como
> distinguir. Ela para e pergunta.

> ❗ **`qa-develop-aprovado` ausente é o achado mais consequente do fluxo.**
> Não quebra nada no momento. Quebra a release semanas depois, no gate G10,
> quando ninguém mais lembra daquela issue.

Ciclo de vida completo das duas: página **Vocabulário operacional de labels**
no Confluence, categoria 11.

### 16.5 Onde o Execution State pode ser commitado

```text
Execution State versionado pertence à branch da issue.
Fora dela, é apenas estado local de execução.
```

`epic/**`, `develop`, `release/current` e branches efêmeras de release
**nunca** recebem commit de Execution State. Ver seção 13.3.

### 16.6 Do outro lado: release

A promoção `develop → release/current` não é livre, e o commit de bump da
versão semântica vive na `release/current`, não na branch efêmera. O contrato
completo está em `references/release-lifecycle.md` — §1 (as três branches do
ciclo) e §22 (promoção, gate G10 e a divisão do bump).

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
- "O que é uma Validação Humana?" / "Ela substitui o QA?" / "O que acontece
  quando eu reprovo uma validação?"
- "Como uma nova sessão retoma uma issue interrompida?" / "O que é o
  Execution State?"
- "Como funciona o gate de design?" / "Quando uma issue precisa de
  `requires-design`?" / "Onde fica o Design Package?"
- "Quem aplica `requires-design`?" / "A skill pode aplicar sozinha?"
- "Essa label é oficial?" / "Posso criar uma label nova?" / "Onde fica a
  matriz de labels?"
- "Qual tipo de ticket eu uso aqui?" / "Isso é Correção ou Bug?"
- "O campo `Tipo` ainda vale?"
- "O que acontece se faltar a label de plataforma no QA?"
- "Por que a Validação Humana não passa por `Documentar`?"
- "De onde nasce a branch dessa issue?" / "O PR aponta pra onde?"
- "Quando se cria uma branch de épico?" / "Toda issue de épico precisa de
  uma?"
- "O que são os três modos da Integração?" / "Quem escolhe o modo?"
- "Por que essa issue continua em `Integração` depois do merge?"
- "O que é `integrado-epico`?" / "Por que ela some depois do QA?"
- "O que é `qa-develop-aprovado`?" / "Por que a release depende dela?"
- "Por que a release não parte da `develop`?" / "O que é `release/current`?"
- "Uma subtarefa aberta trava a issue pai?"
- Qualquer dúvida sobre nomenclatura de colunas, ordem das etapas, gates,
  ou regra de bloqueio de avanço.

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
  decisão é sempre de Rafinha (seção 10.3).
- ❌ Não substitui a matriz oficial de labels do Confluence. A seção 15
  descreve as categorias e as regras de consumo; **quais** labels existem é
  o Confluence que diz.
- ❌ Não autoriza aplicar `requires-design`. Essa label é sempre confirmada
  manualmente por Rafinha (seção 14.1).
