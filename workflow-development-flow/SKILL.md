---
name: "workflow-development-flow"
description: "Skill mãe do novo fluxo de desenvolvimento Rafinha-Claude — referência consultável sobre hierarquia (Épico → Issue → Subtask), princípios do fluxo, classificação de issues (código/documentação), as 8 etapas do pipeline (Fazer - Claude, Análise - Rafinha, Integração, QA - Claude, Documentar, Análise final - Rafinha, Análise final - Claude, Concluído) e seus gates de passagem, as camadas de validação (local, GitHub Actions, QA, Análise final), a integração GitHub Issues ↔ Jira ↔ Pull Request, o ciclo de Release & Versionamento (SemVer, Fix Version, Release Lifecycle) — um ciclo separado do workflow de issue, nunca uma coluna do Jira — e a camada de Validação Humana Agregada (a unidade de aceitação humana pode agregar várias Issues; seção 12). Esta skill NUNCA executa ação nenhuma no Jira, no Confluence ou no código — é só consulta. Use-a quando outra skill do pipeline precisar entender em qual etapa uma issue está, o que vem antes/depois, o que uma etapa deve produzir, ou o que fazer diante de incerteza sobre o fluxo. Rafinha também aciona diretamente com perguntas como 'qual a próxima etapa depois de X', 'o que a etapa Y deveria produzir', 'explica o fluxo novo', 'como funciona o ciclo de release', ou qualquer dúvida sobre como o workflow Rafinha-Claude funciona."
---

---
name: workflow-development-flow
description: "Skill mãe do novo fluxo de desenvolvimento Rafinha-Claude — referência consultável sobre hierarquia (Épico → Issue → Subtask), princípios do fluxo, classificação de issues (código/documentação), as 8 etapas do pipeline (Fazer - Claude, Análise - Rafinha, Integração, QA - Claude, Documentar, Análise final - Rafinha, Análise final - Claude, Concluído) e seus gates de passagem, as camadas de validação (local, GitHub Actions, QA, Análise final), a integração GitHub Issues ↔ Jira ↔ Pull Request, o ciclo de Release & Versionamento (SemVer, Fix Version, Release Lifecycle) — um ciclo separado do workflow de issue, nunca uma coluna do Jira — e a camada de Validação Humana Agregada (a unidade de aceitação humana pode agregar várias Issues; seção 12). Esta skill NUNCA executa ação nenhuma no Jira, no Confluence ou no código — é só consulta. Use-a quando outra skill do pipeline precisar entender em qual etapa uma issue está, o que vem antes/depois, o que uma etapa deve produzir, ou o que fazer diante de incerteza sobre o fluxo. Rafinha também aciona diretamente com perguntas como 'qual a próxima etapa depois de X', 'o que a etapa Y deveria produzir', 'explica o fluxo novo', 'como funciona o ciclo de release', ou qualquer dúvida sobre como o workflow Rafinha-Claude funciona."
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
Versionamento (seção 10) e a camada de Validação Humana Agregada
(seção 12).

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
ISSUE WORKFLOW (inalterado)                RELEASE WORKFLOW (novo)

Fazer - Claude                             Issues concluídas
      ↓                                           ↓
Análise - Rafinha                          Agrupamento de mudanças
      ↓                                           ↓
Integração                                 Definição da versão
      ↓                                           ↓
QA - Claude                                Release Candidate
      ↓                                           ↓
Documentar                                 Validação final
      ↓                                           ↓
Análise final - Rafinha                    Tag
      ↓                                           ↓
Análise final - Claude                     GitHub Release
      ↓                                           ↓
Concluído                                  Versão publicada
```

**Regra explícita:** Release nunca vira uma nona coluna do Jira depois de
`Análise final - Claude` — misturaria duas unidades de trabalho diferentes.

### 10.2 Versionamento (SemVer)

Convenção `vMAJOR.MINOR.PATCH`:
- **MAJOR** — mudança incompatível.
- **MINOR** — nova funcionalidade compatível.
- **PATCH** — correção compatível.

Projetos em desenvolvimento inicial começam em `0.x.y` — faixa reservada
pelo próprio SemVer para quando a API/contrato ainda não é considerada
estável, não significa que o projeto está incompleto.

### 10.3 Quem decide o incremento de versão

**Sempre Rafinha** — nunca o Claude sozinho. O incremento de versão
envolve significado de produto, não é decisão puramente técnica. O Claude
pode e deve sugerir com justificativa (ex.: "recomendo MINOR porque foram
adicionadas funcionalidades compatíveis"), mas a decisão final é sempre
dele.

### 10.4 Nem toda issue concluída gera uma release

Uma release representa uma entrega de software, não uma issue. Concluir
várias issues não significa gerar uma versão para cada uma — pode virar
uma única release agrupando todas. Todo projeto **deve** ter
versionamento; nenhuma issue concluída **deve** gerar automaticamente uma
release.

### 10.5 A entidade "Release" no Jira

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

### 10.6 Release Lifecycle (processo completo)

1. Selecionar issues concluídas.
2. Definir escopo da release.
3. Definir versão.
4. Criar release branch, quando aplicável.
5. Atualizar versão do projeto.
6. Atualizar changelog.
7. Executar Release CI.
8. Criar/validar Release Candidate, quando aplicável.
9. Validar funcionalmente.
10. Merge para `main`.
11. Criar tag `vX.Y.Z`.
12. Criar GitHub Release.
13. Associar a versão no Jira.
14. Registrar documentação.

Quem executa esse ciclo na prática é a skill `jira-release-executor`,
acionada sob demanda por Rafinha (nunca por varredura automática de
coluna, já que Release não é uma etapa do issue workflow).

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

## Quando Rafinha aciona esta skill diretamente

Perguntas do tipo:
- "Qual a próxima etapa depois de X?"
- "O que a etapa Y deveria produzir?"
- "Explica o fluxo novo."
- "Essa issue devia ser Issue ou Subtask?"
- "Qual a diferença entre o que a pipeline valida e o que o QA valida?"
- "Como funciona o ciclo de release?" / "Quando uma issue concluída vira
  uma versão?"
- "O que é uma Validação Manual?" / "Ela substitui o QA?" / "O que acontece
  quando eu reprovo uma validação?"
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
  decisão é sempre de Rafinha (seção 10.3).
