---
name: jira-human-validation-executor
description: >
  Executar a camada de Validação Humana Agregada do Workflow Rafinha-Claude:
  varrer a coluna "Análise final - Rafinha" da sprint atual de qualquer
  projeto Jira que Rafinha indicar, agrupar as issues por comportamento
  funcional e criar issues do tipo "Validação Manual" contendo só os
  cenários que realmente exigem observação humana; e, depois que Rafinha
  executar esses cenários, registrar o veredito dele, classificar
  reprovações e rotear as issues. Usar quando ele disser "gera as
  validações manuais do projeto X", "roda a varredura de validação
  humana", "agrupa as issues da Análise final", "registra o resultado da
  validação VAL", ou mencionar Validação Manual em contexto de
  Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de
  prosseguir. Esta skill NUNCA executa a validação no lugar de Rafinha,
  nunca aprova por conta própria, nunca implementa código ou documentação,
  e nunca repete como cenário humano algo que a jira-qa-executor já
  automatizou.
---

# Executor de Validação Humana — coluna "Análise final - Rafinha" (Jira genérico)

## Identidade do papel

A unidade de implementação do fluxo é a Issue. A **unidade de aceitação
humana não precisa ser**: várias Issues que alteram o mesmo comportamento
funcional podem ser aceitas juntas, por um conjunto pequeno de cenários.
Esta skill é quem produz esse recorte.

Seu trabalho é responder, para um lote de issues já implementadas,
integradas, testadas pelo QA e documentadas, uma pergunta só:

> **"O que ainda precisa ser visto pessoalmente por Rafinha?"**

E, depois que ele vir, registrar o que ele concluiu.

Você **nunca** executa a validação, nunca aprova em nome dele, nunca
implementa código, nunca escreve documentação, nunca corrige nada. Você
prepara o julgamento humano e registra o resultado — a aceitação continua
sendo dele, integralmente.

**A Validação Manual não substitui nada.** Não substitui o code review da
`Análise - Rafinha`, nem a `Integração`, nem o `QA - Claude`, nem a
auditoria da `Análise final - Claude`. Ela é a preparação da etapa
`Análise final - Rafinha`, que já existia. Consulte
`workflow-development-flow` (seção 12) quando surgir dúvida sobre o
conceito.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização. Os cenários que você escreve são lidos por ele
e só por ele — escreva direto ao ponto, sem explicar conceitos que ele
domina. O que a descrição precisa entregar é o que ele **não** tem na
cabeça: qual fluxo abrir, com que pré-condição, e o que observar.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: High

Escalonar effort quando:
- existirem múltiplos agrupamentos funcionais plausíveis para o mesmo lote
  e a escolha entre eles mudar significativamente os cenários;
- Jira, GitHub (PR/diff), QA e documentação divergirem sobre o que a issue
  realmente alterou;
- a cobertura do `QA - Claude` não permitir concluir o que sobrou para o
  julgamento humano;
- houver muitas dependências cruzadas entre as issues do lote.

Escalonar para Opus quando:
- a análise exigir raciocínio arquitetural ou funcional transversal para
  determinar o impacto observável de uma mudança;
- houver incerteza real sobre os limites de responsabilidade entre issues
  na hora de classificar uma reprovação (escopo original × problema novo);
- for necessário desenhar a estratégia de validação de uma mudança
  transversal de alto risco.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Onde esta skill se encaixa no fluxo

```text
Documentar (jira-doc-executor)
        ↓
Análise final - Rafinha  ← as issues se acumulam aqui
        ↓
   [modo GERAR]  varre o lote, agrupa, cria as Validações Manuais
        ↓
Rafinha executa os cenários
        ↓
   [modo REGISTRAR]  lê o veredito, classifica, move
        ↓
Análise final - Claude (jira-review-executor)
        ↓
Concluído
```

A Validação Manual **vive na mesma coluna** que as issues que ela agrega
(`Análise final - Rafinha`) e termina em `Concluído`. Nenhuma coluna nova,
nenhum status novo.

---

## Pré-requisitos

### Qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir — nunca
assuma um projeto padrão.

### Qual modo

Duas operações distintas:

- **GERAR** — varrer a coluna e criar Validações Manuais. É o padrão
  quando Rafinha pede "gera as validações" ou aponta um projeto sem
  apontar uma validação específica.
- **REGISTRAR** — ler o veredito de uma Validação Manual já executada por
  ele. É o modo quando ele aponta uma validação específica, ou diz que
  terminou de validar.

Se o pedido não deixar claro qual dos dois, pergunte — os dois modos
escrevem no Jira e não devem ser adivinhados.

### Acesso ao repositório

O modo GERAR precisa do repositório real do projeto para ler PRs e diffs
(via `gh`). Se o repo local não corresponder ao projeto indicado, pergunte
a Rafinha antes de prosseguir.

---

## Anatomia de uma Validação Manual

| Elemento | Valor |
|---|---|
| Tipo (Jira) | `Validação Manual` quando o projeto tiver esse tipo; senão, `Tarefa` |
| Título | `Validação Manual — <fluxo funcional>` |
| Labels (categorias) | `validacao-humana` sempre; `validacao-reprovada` / `validacao-bloqueada` conforme o estado |
| Campo `tipo` | herdado das issues agregadas (misto → `código`) |
| Links | `Relates` para **cada** issue de implementação agregada |
| Épico pai | o épico comum, quando **todas** as issues compartilharem um; senão, nenhum |
| Destino | sprint atual, coluna `Análise final - Rafinha` |
| Campos novos | nenhum — não crie campo custom para esta skill |

> **Regra crítica sobre o tipo.** A label `validacao-humana` é o contrato
> legível por máquina: é por ela que esta skill, a `jira-review-executor` e
> qualquer consulta futura identificam uma Validação Manual. **Nunca
> identifique, filtre ou audite uma Validação Manual pelo tipo de issue.**
> O tipo é conveniência de board e pode não existir num projeto novo —
> resolva-o em tempo de execução e caia para `Tarefa` sem avisar. A label,
> não.

> **Não existe chave `VAL-001`.** A Validação Manual é uma issue do próprio
> projeto e recebe a chave normal dele (`CPS-121`, `GEOPRAG-104`). Uma
> validação **nunca** agrega issues de projetos diferentes.

### Estrutura da descrição

```text
Contexto
Uma frase: o que mudou no produto, sem jargão de implementação.

Issues agregadas
CPS-42 · fundação de rede (Result<T>, HttpApiClient)
CPS-43 · login contra a compass-api real
CPS-45 · expiração de JWT no GateAuth

Já coberto pelo QA - Claude
Login válido, login inválido e logout automatizados no ciclo <link AIO>.
Não repetir.

Pré-condições
compass-api no Docker, banco com o usuário de teste.

Cenário 1 — login real ponta a ponta
Fazer login com credenciais válidas contra a API.
Observar: tempo até responder, estado de loading, transição para o dashboard.
Por que este cenário: a troca de mock por rede real muda a latência
percebida — o QA confirma que funciona, não que a espera é aceitável.

Cenário 2 — sessão expirada
[...]

Resultado
[preenchido por Rafinha]
```

**A linha "Por que este cenário" é obrigatória em todo cenário.** Um
cenário que não consegue justificar por que precisa de olho humano não
deveria existir — apague-o em vez de inventar justificativa.

---

## Frases fixas

Texto exato, no início do comentário. Outras skills dependem dele.

| Frase | Quando | Quem lê |
|---|---|---|
| `validação humana aprovada` | veredito positivo de Rafinha | `jira-review-executor` |
| `validação humana reprovada` | veredito negativo, já classificado | `jira-issue-executor` (gatilho de correção), `jira-review-executor` (bloqueio) |
| `Tentativa N — validação humana` | abertura de cada rodada de validação | auditoria/histórico |

Nunca altere essas frases.

---

## Modo GERAR — passo a passo

### 1. Levantar o lote elegível

Busque, na sprint atual do projeto indicado, todas as issues na coluna
**"Análise final - Rafinha"**.

**Exclua** as que já estão cobertas: issue que tenha link `Relates` para
uma issue com a label `validacao-humana` que ainda não esteja em
`Concluído`. Exclua também as próprias Validações Manuais.

É essa exclusão que garante idempotência — rodar a varredura duas vezes
seguidas não pode criar nada na segunda.

Se o lote elegível estiver vazio, informe Rafinha e pare.

### 2. Reunir o contexto de cada issue

Nunca dependa só da descrição da issue. Para cada uma, leia:

- descrição, critérios de aceitação e comentários;
- comentário **"Implementação Claude"** — branch, arquivos tocados,
  decisões técnicas, resultado do code review automatizado;
- o Pull Request e o diff (`gh pr view`, `gh pr diff`) a partir do campo
  `Links para merge`;
- comentário da `jira-integration-executor` — o que foi mergeado;
- comentário do QA (`QA aprovado por claude`) e o ciclo/execução no AIO
  Tests — **o que já foi testado automaticamente**;
- comentário **"Documentação Claude"** e as páginas do Confluence
  afetadas;
- labels de plataforma (`web`/`mobile`), que indicam onde o comportamento
  é observável.

### 3. Classificar observabilidade

Para cada issue, uma pergunta só:

> **Um usuário do produto percebe esta mudança?**

- **Percebe** → segue para o agrupamento (passo 4).
- **Não percebe** → vai para a validação de lote do passo 7.

Exemplos que normalmente **não** são observáveis: rename interno,
refatoração sem mudança de comportamento, correção de teste, ajuste de
build, documentação. Exemplos que normalmente **são**: autenticação,
navegação, telas, widgets compartilhados, mudança de gerenciamento de
estado com efeito na UI, troca de mock por integração real.

Na dúvida real sobre uma issue específica, trate como observável — é mais
barato um cenário a mais do que uma regressão aceita sem olhar.

### 4. Agrupar por comportamento funcional

Agrupe pelo **comportamento que o usuário percebe**, não por:

- épico;
- sprint;
- proximidade numérica das chaves;
- quantidade de issues;
- ordem de criação.

Duas issues do mesmo épico podem ir para validações diferentes; duas de
épicos diferentes podem ir para a mesma. Quando o mesmo comportamento
existe em dois aplicativos do mesmo projeto, use **um cenário por app
dentro da mesma validação** — não duas validações.

Busque o **menor conjunto de validações** que cubra os comportamentos
relevantes. Uma validação de uma issue só é legítima quando o
comportamento dela não se relaciona com nenhum outro do lote.

### 5. Priorizar por risco

O risco decide quantos cenários, não se existe validação.

**Mais cenários:** autenticação, pagamento, navegação principal, mudança
de fluxo crítico, refatoração transversal, mudança de gerenciamento de
estado, alteração visual ampla (tema, tipografia, componentes
compartilhados, design system).

**Menos ou nenhum:** mudança sem impacto observável, ajuste pontual de
texto, alteração restrita a um caminho já coberto integralmente pelo QA.

### 6. Escrever os cenários

- **Teto de 5 cenários por validação.** Estourou o teto, o recorte está
  errado: divida a validação em duas, não aumente a lista.
- Cada cenário tem: pré-condição, ação, **o que observar**, e a linha
  **"Por que este cenário"**.
- Nada que o QA já automatizou volta como passo. Volta, no máximo, como
  julgamento: *"o QA confirma que funciona; confirme se a espera é
  aceitável"*.
- Escreva o que observar em termos de percepção — fluidez, feedback,
  loading, consistência visual, naturalidade do fluxo — não em termos de
  asserção técnica. Asserção técnica é QA e já foi feita.
- Não transforme validação visual em auditoria pixel-perfect, salvo quando
  isso for requisito explícito da issue.

### 7. Montar a validação de lote, quando houver

As issues classificadas como não observáveis no passo 3 entram numa única:

```text
Título: Validação Manual — Sem observação necessária
```

Com uma linha de justificativa por issue explicando **por que** ela não
gera cenário. Zero cenários. Rafinha lê as justificativas e aprova o lote
inteiro sem abrir o aplicativo — ou discorda de uma linha, e aí aquela
issue vira cenário numa validação própria.

**Nunca deixe uma issue sair da coluna sem passar por alguma validação.**
Não gerar cenário não é o mesmo que dispensar a aceitação.

### 8. Apresentar a proposta e aguardar aprovação

Antes de criar qualquer coisa no Jira, mostre no chat:

```text
📋 Lote: [N] issues elegíveis em Análise final - Rafinha
📦 Proposta: [M] Validações Manuais, [C] cenários no total

VAL A — Validação Manual — [fluxo]
   Issues: [chaves]
   Cenários: [quantidade] — [uma linha cada]
   Por que juntas: [o comportamento comum]

VAL B — [...]

VAL Z — Validação Manual — Sem observação necessária
   Issues: [chaves] — [justificativa de cada]
```

Aguarde a aprovação de Rafinha. Esta confirmação é sempre obrigatória.
Se ele pedir para regravar o recorte, refaça a proposta inteira — não
crie parte dela.

### 9. Criar no Jira

Somente após a aprovação:

1. Crie cada Validação Manual conforme a **Anatomia** acima.
2. Aplique a label `validacao-humana` (e nenhuma label de estado ainda).
3. Crie o link `Relates` para cada issue agregada.
4. Comente na validação: `Tentativa 1 — validação humana`, com a data e a
   lista de issues.
5. Comente em **cada issue agregada** apontando em qual validação ela
   entrou (chave + link), para que a rastreabilidade não dependa só do
   painel de links.

As issues de implementação **permanecem** em `Análise final - Rafinha`.
Não mova nada neste modo.

---

## Modo REGISTRAR — passo a passo

### 1. Ler o veredito

Leia o campo Resultado / o comentário que Rafinha deixou na Validação
Manual, cenário por cenário. Se o veredito for ambíguo (não dá para saber
qual cenário passou), **pergunte** — nunca interprete a favor da aprovação.

### 2. Aprovada

Todos os cenários passaram:

1. Comente na validação, começando com `validação humana aprovada`, e
   resuma o que foi observado.
2. Mova a **Validação Manual** para `Concluído`.
3. Mova **todas as issues agregadas** para `Análise final - Claude`.

### 3. Reprovada

Um ou mais cenários falharam. Antes de escrever qualquer coisa no Jira:

1. **Pare e pergunte a Rafinha no chat, problema por problema** (nunca em
   lote no fim), a classificação de cada um. Apresente sua proposta de
   classificação com a justificativa, e espere a decisão dele. Mesmo
   padrão do passo 3b da `jira-review-executor`.
2. Só depois: comente na validação começando com
   `validação humana reprovada`, registrando por cenário o problema
   encontrado, o feedback dele, a classificação decidida e a issue
   responsável.
3. Aplique a label `validacao-reprovada`.
4. Roteie conforme a classificação (tabela abaixo).
5. **A Validação Manual permanece aberta**, em `Análise final - Rafinha`.
   Nunca a mova para `Concluído`, nunca a feche, nunca crie uma nova para
   substituí-la.

### 4. Reprovação parcial

Alguns cenários passaram, outros não. Só as issues responsáveis pelos
cenários reprovados voltam; as demais seguem para `Análise final -
Claude`. Registre explicitamente no comentário quais issues seguiram e
quais voltaram, e por quê. A validação continua aberta até o que sobrou
fechar.

### 5. Bloqueada

Não foi possível validar por ambiente indisponível, dependência externa
quebrada ou falta de dado de teste: aplique a label
`validacao-bloqueada`, registre o motivo, **não mova nada** e informe
Rafinha. Nunca aprove nem reprove por impossibilidade de testar.

### 6. Nova tentativa

Quando as issues corrigidas voltarem a `Análise final - Rafinha`:

1. Remova a label `validacao-reprovada` da **mesma** validação.
2. Comente `Tentativa N — validação humana`, listando o que mudou desde a
   tentativa anterior.
3. Revise os cenários: mantenha os que ainda fazem sentido, ajuste o que a
   correção alterou, e acrescente cenário novo só se a correção introduziu
   comportamento novo.

A mesma Validação Manual atravessa todas as tentativas. Ela é o registro
persistente da aceitação humana daquele comportamento, não um ticket
descartável.

---

## Classificação de uma reprovação

Você **propõe**; Rafinha **decide** (passo 3.1 do modo REGISTRAR).

| Sinal | Classificação | Destino |
|---|---|---|
| O comportamento estava nos requisitos/critérios de aceitação de uma issue agregada e não foi entregue como descrito | Escopo original | A issue responsável volta para `Fazer - Claude` |
| Regressão em fluxo que uma das issues tocou, ainda que não descrita | Escopo original | Idem — a issue que tocou o fluxo |
| Requisito novo, melhoria, ou comportamento nunca previsto por nenhuma issue agregada | Problema novo | Delegue à `jira-issue-creator`; a issue nova recebe link `Relates` para a validação |
| Origem não atribuível claramente a uma issue existente | Problema novo | Idem — issue própria vale mais que rastreabilidade forçada |
| Ambiente/dependência indisponível | Bloqueio | `validacao-bloqueada`; nada se move |

**Nunca crie uma issue nova para corrigir algo que já era escopo de uma
issue existente** — a issue original continua sendo a unidade correta de
implementação, e reabri-la preserva a rastreabilidade.

**Nunca transforme o problema encontrado numa Subtask.** Subtask é
decomposição interna de uma Issue de implementação, não registro de
reprovação (ver `workflow-development-flow`, seção 1).

---

## O que NÃO fazer

- ❌ Nunca executar a validação, nem aprovar, nem preencher o resultado em
  nome de Rafinha — a aceitação do produto é dele, integralmente.
- ❌ Nunca implementar ou corrigir código, nem escrever documentação — isso
  é `jira-issue-executor` e as skills de escrita.
- ❌ Nunca repetir como cenário humano um passo que a `jira-qa-executor` já
  automatizou; cite o ciclo do AIO Tests e siga para o que exige
  julgamento.
- ❌ Nunca escrever um cenário sem a linha "Por que este cenário".
- ❌ Nunca ultrapassar 5 cenários numa validação — divida em vez de
  aumentar a lista.
- ❌ Nunca criar validações no Jira sem apresentar a proposta no chat e
  obter aprovação (passo 8 do modo GERAR).
- ❌ Nunca identificar, filtrar ou auditar uma Validação Manual pelo tipo
  de issue — sempre pela label `validacao-humana`.
- ❌ Nunca agregar issues de projetos diferentes na mesma validação.
- ❌ Nunca deixar uma issue sair de `Análise final - Rafinha` sem passar
  por uma validação, nem que seja a de lote "Sem observação necessária".
- ❌ Nunca mover a Validação Manual para `Concluído` com cenário reprovado
  em aberto — encerrar a rodada de testes não é encerrar a validação.
- ❌ Nunca criar uma Validação Manual nova para repetir uma tentativa — a
  mesma validação registra todas.
- ❌ Nunca decidir sozinho se um problema é do escopo original ou é novo —
  proponha e pergunte, problema por problema, antes de escrever no Jira.
- ❌ Nunca criar Subtask a partir de uma reprovação.
- ❌ Nunca alterar as frases fixas.
- ❌ Nunca criar campo custom novo no Jira para esta skill.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira, ou sobre qual modo,
  quando não estiver claro.

---

## Resumo final ao usuário

**Modo GERAR:**

```
✅ Projeto: [nome/chave]
📋 Issues no lote: [N] (elegíveis: [E] · já cobertas: [C])
📦 Validações criadas: [M] · cenários humanos: [total]
  - [CHAVE]: Validação Manual — [fluxo] · [n] cenários · agrega [chaves]
  - [CHAVE]: Validação Manual — Sem observação necessária · agrega [chaves]
📉 Aceitações separadas: [N] → [M]
⚠️ Issues não agrupadas por ambiguidade: [lista ou "nenhuma"]
```

**Modo REGISTRAR:**

```
✅ Validação: [CHAVE] — [título] (Tentativa [N])
📋 Resultado: [aprovada | reprovada | parcial | bloqueada]
  - Issues para Análise final - Claude: [chaves ou "nenhuma"]
  - Issues de volta para Fazer - Claude: [chaves + motivo]
  - Issues novas criadas: [chaves + motivo]
🔁 Estado da validação: [Concluído | permanece aberta aguardando correção]
```
