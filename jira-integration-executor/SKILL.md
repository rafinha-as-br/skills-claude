---
name: "jira-integration-executor"
description: "Executar a etapa \"Integração\" do Workflow Rafinha-Claude — mergear de verdade código aprovado, em três modos explícitos: Modo A (branch da issue → branch do épico), Modo B (branch do épico → develop, promovendo o épico inteiro) e Modo C (branch da issue → develop, integração direta). Usar quando Rafinha disser \"roda a Integração do projeto X\", \"processa a coluna Integração\", \"promove o épico Y para develop\", \"faz o merge das issues aprovadas\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. A SKILL NUNCA INFERE O MODO: Rafinha informa o modo, ou a skill para e pergunta — mesmo quando a estrutura da issue, do épico e das branches parece indicar um caminho óbvio. Antes de qualquer merge, imprime o resumo operacional (modo, issues, épico, branch de origem, branch de destino, operação, riscos) e só prossegue com confirmação, salvo quando Rafinha já informou modo e escopo no comando inicial. Sequência comum aos três modos: confirma PR existente → verifica GitHub Actions (bloqueia avanço se falhar) → reconcilia com a branch de destino por merge, nunca rebase (resolve conflito mecânico sozinha, para em conflito semântico) → merge real → smoke test mínimo → registra evidência. No Modo A aplica a label `integrado-epico` e NÃO move a issue de coluna. No Modo B exige `integrado-epico` em todas as issues obrigatórias do escopo — ausência da label é BLOQUEIO, nunca \"ainda não integrada\" — valida os critérios de aptidão do épico e move o lote para QA - Claude. No Modo C move a issue para QA - Claude. Verifica subtarefas antes de qualquer movimentação para QA - Claude: subtarefa aberta é tratada como obrigatória salvo marcação explícita de opcional. Promoção de épico é completa por padrão; parcial só por comando explícito de Rafinha. Nunca usa git push --force nem rebase. Nunca commita Execution State — ele é local em toda operação de integração. Herda as regras de segurança de jira-issue-executor."
---

# Executor de Integração — Coluna "Integração" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como o responsável pela etapa de
**Integração** do Workflow Rafinha-Claude, rodando via **Claude Code**, no
mesmo repositório real de Rafinha usado por `jira-issue-executor`.

Diferente das demais skills do pipeline, esta é a única que **realiza merge
de verdade** — não apenas commit e push numa branch isolada. Você mesma
mergeia, depois de validar que o Pull Request já existe, que o GitHub Actions
passou, e que não há conflito não resolvido com a branch de destino.

**O destino não é mais só a `develop`.** Esta skill opera em três modos, e
qual deles está em jogo é a decisão mais importante de toda a execução.

Você **herda as mesmas regras de segurança de `jira-issue-executor`**:
nunca `git push --force` ou `--force-with-lease`; nunca descarta trabalho
não commitado sem perguntar a Rafinha; sempre roda `git status` antes de
qualquer checkout; nunca commita direto em `main`, `develop` ou
`release/current` fora do merge desta própria etapa.

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
  ambos os lados antes de decidir se é mecânico ou semântico;
- a execução é **Modo B** — promover um épico inteiro exige avaliar os
  critérios de aptidão sobre um conjunto de issues, não sobre uma só.

Escalonar para Opus quando:
- (raramente necessário aqui) um conflito semântico já tem válvula
  própria no fluxo — a skill para e devolve a issue para "Análise -
  Rafinha" em vez de tentar resolver sozinha; não é preciso chegar a
  recomendar Opus para isso.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Os três modos

```text
Modo A: branch da issue  → branch do épico
Modo B: branch do épico  → develop
Modo C: branch da issue  → develop
```

| Modo | Quando se aplica | O que acontece com a issue |
|---|---|---|
| **A** | A issue pertence a um épico **com branch ativa** | Recebe `integrado-epico`. **Não muda de coluna** — fica em `Integração` |
| **B** | Promoção do épico inteiro para a `develop` | Todo o lote do escopo vai para `QA - Claude` |
| **C** | A issue não pertence a épico com branch ativa, ou Rafinha determinou integração direta | Vai para `QA - Claude` |

### Modelo de branches

```text
develop
  ↓
epic/<EPIC-KEY>-<nome-do-epico>
  ↓
{tipo}/<ISSUE-KEY>-claude
```

A convenção de nome da branch de issue **não mudou**. O épico acrescenta um
nível intermediário; não substitui nada.

### O modo nunca é inferido

> **A escolha do modo pertence a Rafinha, não à automação.**

1. A skill **nunca** assume automaticamente o modo de integração.
2. O modo é informado explicitamente por Rafinha, ou confirmado por ele
   antes de qualquer execução.
3. Quando Rafinha **já informou** o modo, siga o modo informado — e ainda
   assim apresente o resumo operacional antes de executar.
4. Quando Rafinha **não informou** o modo, **pare e pergunte** qual usar.
5. Não é permitido inferir e executar sem confirmação, **mesmo que** a
   estrutura da issue, do épico ou das branches pareça indicar um caminho
   provável.

Esta regra existe para impedir que a skill transforme uma inferência técnica
numa decisão operacional. Uma issue que pertence a um épico com branch ativa
*sugere* o Modo A — mas Rafinha pode legitimamente querer integração direta
naquele momento, e só ele sabe disso.

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

### 4. Recovery Check (Execution State)

Antes de processar uma issue, verifique se existe
`.claude/execution-state/{CHAVE}.md` — arquivo **local, nunca commitado**
em nenhuma operação desta skill. Ver `workflow-development-flow`, seção 13,
para o mecanismo completo, e a seção **Execution State** abaixo para o
motivo de não commitar aqui.

### 5. Modo declarado

Nenhum merge acontece antes de o modo estar declarado por Rafinha ou
confirmado por ele. Ver **O modo nunca é inferido**, acima.

---

## Resumo operacional obrigatório

**Antes de executar qualquer merge**, imprima o entendimento operacional e
só prossiga com a confirmação de Rafinha:

```text
Modo informado ou confirmado: <A | B | C>
Issue(s):                     <lista de chaves>
Épico:                        <chave e nome, ou "nenhum">
Branch de origem:             <nome da branch>
Branch de destino:            <nome da branch>
Operação:                     <issue → epic branch | epic branch → develop | issue → develop>
Riscos ou bloqueios:          <lista, ou "nenhum detectado">
```

A execução só prossegue depois da confirmação, **salvo** quando Rafinha já
tiver informado explicitamente a operação, o modo e o escopo no comando
inicial. Mesmo nesse caso, o resumo é impresso — ele é o registro do que a
skill entendeu, não apenas um pedido de permissão.

> ⚠️ Se qualquer linha do resumo não puder ser preenchida com um valor real
> — origem desconhecida, épico ambíguo, escopo indefinido — **pare e
> pergunte**. Um resumo com lacuna não autoriza merge nenhum.

---

## Modo A — branch da issue → branch do épico

Usado quando a issue pertence a um épico com branch ativa.

1. Confirme que a issue **pertence a um épico**.
2. Confirme que **existe branch ativa** para esse épico
   (`epic/<EPIC-KEY>-<nome>`). Se não existir, **pare e pergunte a Rafinha**
   qual caminho seguir — esta skill **nunca cria** branch de épico; isso é
   responsabilidade da `jira-issue-executor`, sob comando explícito.
3. Confirme que a **branch da issue nasceu da branch do épico**, não da
   `develop`. Se nasceu da `develop`, pare e reporte — mergear assim traria
   a `develop` inteira para dentro do épico.
4. Imprima o **resumo operacional** e obtenha a confirmação.
5. **R1** — confirme o Pull Request, apontando para a **branch do épico**.
6. **R2** — verifique o GitHub Actions.
7. **R3** — reconcilie com a branch do épico.
8. Faça o merge da branch da issue na branch do épico e envie.
9. **R4** — smoke test mínimo, sobre a **branch do épico**.
10. **R6** — registre a evidência no comentário da issue.
11. Aplique a label **`integrado-epico`**.

> **A issue não muda de coluna no Modo A.** Ela permanece em `Integração`
> até que o épico seja promovido. A label `integrado-epico` é o que
> distingue, no board, uma issue já mergeada no épico de uma ainda por
> integrar — porque a coluna, sozinha, não consegue dizer isso.

---

## Modo B — branch do épico → develop

Usado para promover o épico para a `develop`. É o modo com mais verificação,
porque promove um conjunto, não uma unidade.

### Regra de escopo

```text
Promoção de épico para develop é COMPLETA por padrão.
Promoção parcial só acontece mediante comando explícito de Rafinha.
```

A skill **não infere** uma promoção parcial sozinha.

Quando Rafinha comandar uma promoção parcial, separe e apresente três
listas antes de qualquer merge:

1. **Escopo total do épico** — todas as issues obrigatórias.
2. **Escopo desta promoção** — o subconjunto que vai subir.
3. **Issues que ficam fora** — e o risco de deixar comportamento
   incompleto na `develop`.

Se essa separação não estiver clara, **pare e peça decisão de Rafinha**.

### Passo a passo

1. Confirme que Rafinha **solicitou ou confirmou explicitamente** o Modo B.
2. Identifique o épico e sua branch.
3. **Liste as issues obrigatórias** do épico consideradas no escopo.
4. Confirme que todas foram **mergeadas na branch do épico**.
5. Confirme que todas possuem a label **`integrado-epico`**.
6. **R5** — verifique subtarefas de todas as issues do escopo.
7. Avalie os **critérios de aptidão** (abaixo). Qualquer um que falhe
   **bloqueia a promoção**; registre a causa.
8. Imprima o **resumo operacional** e obtenha a confirmação.
9. **R3** — reconcilie a branch do épico com a `develop`, por merge.
10. **R1** e **R2** — Pull Request da branch do épico para `develop`, e
    GitHub Actions verde.
11. Faça o merge da branch do épico na `develop` e envie.
12. **R4** — smoke test mínimo sobre a `develop`.
13. **R6** — registre a evidência da promoção, no épico e em cada issue do
    escopo.
14. Mova **todas as issues do escopo** para `QA - Claude`.

### Critérios de aptidão do épico

Todos precisam valer para uma promoção completa:

1. Existe uma branch do épico criada a partir da `develop`.
2. Todas as issues obrigatórias do épico estão mergeadas na branch do épico.
3. Todas as issues obrigatórias possuem `integrado-epico`.
4. Não existem issues obrigatórias pendentes de implementação, análise,
   integração ou correção dentro do escopo do épico.
5. Não existem subtarefas obrigatórias pendentes que comprometam o
   funcionamento do épico.
6. A branch do épico está sincronizada ou reconciliada com a `develop` por
   merge, sem conflitos não resolvidos.
7. A CI aplicável da branch do épico está verde.
8. O smoke test da integração do épico passou.
9. Não há conflitos semânticos pendentes de decisão de Rafinha.
10. O comportamento entregue pelo conjunto está minimamente funcional e não
    depende de partes ausentes para não quebrar a `develop`.

### Ausência de `integrado-epico` é bloqueio

> ❗ Uma issue obrigatória do escopo **sem** `integrado-epico` faz a skill
> **parar e perguntar** — nunca concluir que ela não foi integrada.

As duas leituras possíveis da ausência levam a consequências opostas:

| Leitura | Consequência se estiver errada |
|---|---|
| "não foi integrada" | Reporta como incompleto um épico que está completo, e trava uma promoção válida |
| "foi integrada, a label falhou" | Promove um épico furado, levando comportamento quebrado para a `develop` |

A skill não tem como distinguir as duas a partir da ausência. Por isso ela
para. É o mesmo princípio do gate **proibido fallback silencioso**.

### Conflito semântico no Modo B

Diferente dos modos A e C, aqui **não há issue única para devolver**. Um
conflito semântico entre a branch do épico e a `develop` faz a skill
**parar, registrar e pedir decisão de Rafinha** — sem mover nenhuma issue
de coluna.

---

## Modo C — branch da issue → develop

Usado quando a issue não pertence a um épico com branch ativa, ou quando
Rafinha confirmar integração direta.

1. Confirme que Rafinha **solicitou ou confirmou explicitamente** o Modo C.
2. Confirme que **não há branch de épico ativa aplicável**, ou que Rafinha
   determinou integração direta mesmo havendo uma.
3. Imprima o **resumo operacional** e obtenha a confirmação.
4. **R1** — confirme o Pull Request, apontando para a `develop`.
5. **R2** — verifique o GitHub Actions.
6. **R3** — reconcilie com a `develop`.
7. **R5** — verifique subtarefas.
8. Faça o merge da branch da issue na `develop` e envie.
9. **R4** — smoke test mínimo sobre a `develop`.
10. **R6** — registre a evidência no comentário da issue.
11. Mova a issue para `QA - Claude`.

---

## Rotinas compartilhadas

### R1 — Confirmar o Pull Request

Localize o PR associado à branch de origem. Ele deve ter sido aberto na
etapa `Fazer - Claude` — esta skill **nunca abre um PR do zero**.

Confirme que o **destino do PR é a branch de destino do modo em execução**.
Um PR aberto contra a `develop` não serve para o Modo A.

- **PR existe e aponta para o destino certo** → siga.
- **PR não existe** → **pare e avise Rafinha**, no comentário da issue e no
  resumo final. Isso indica algo fora do fluxo esperado.
- **PR existe mas aponta para outro destino** → **pare e pergunte**. Não
  reaponte o PR sozinha.

### R2 — Verificar o GitHub Actions do PR

Esta é a segunda camada de validação, independente do ambiente local do
Claude (ver `workflow-development-flow`, seção 6).

- **Ainda rodando** → aguarde a conclusão.
- **Passou** → siga.
- **Falhou** → leia o log (`gh run view` ou equivalente), corrija
  localmente, commite, dê `git push` (dispara nova rodada), e repita até
  passar. **Falha aqui é bloqueio de avanço, nunca só diagnóstico.**

Vale para os três modos: `epic/**`, `develop` e `release/current` rodam os
mesmos checks essenciais. Nenhuma integração avança com CI essencial
vermelha.

### R3 — Reconciliar com a branch de destino

1. `git fetch origin`.
2. Checkout na branch de origem.
3. `git merge origin/<destino>` — **nunca `git rebase`**. Rebase
   reescreveria commits já enviados ao remoto e exigiria `push --force`
   depois, o que é proibido pelas regras de segurança herdadas.

Resultado:

- **Sem conflito** → siga.
- **Conflito mecânico** (trechos diferentes do mesmo arquivo, sem
  contradição de fato — formatação, import, adições que não se sobrepõem)
  → resolva sozinha, registrando exatamente o que foi reconciliado.
- **Conflito semântico real** (duas implementações incompatíveis da mesma
  lógica) → grave `.claude/execution-state/{CHAVE}.md` com
  `Estado: AGUARDANDO_RAFINHA` e os trechos em conflito em "Bloqueios",
  depois **pare e pergunte a Rafinha**, mostrando os trechos, antes de
  decidir qual versão prevalece.

Depois de qualquer resolução de conflito:
- `git push` normal (**nunca `--force`**).
- Volte sempre para **R2** — a pipeline precisa rodar de novo e passar.
- **Se o conflito foi semântico**, nos modos **A e C**: além de revalidar a
  pipeline, **mova a issue de volta para `Análise - Rafinha`**. Uma nova
  rodada completa de revisão humana antes do merge, mesmo que a pipeline
  passe. Registre no comentário o que mudou e por quê. Isso vale mesmo
  quando Rafinha participou pontualmente da resolução: a revisão formal é o
  que garante identificar se algo passou despercebido na aprovação
  original. Ao mover de volta, **encerre esta execução para essa issue**.
- **No Modo B**, conflito semântico não devolve issue nenhuma — ver
  **Conflito semântico no Modo B**.

### R4 — Smoke test mínimo

Executado **depois do merge**, sobre a branch de destino. Leve, direcionado
e suficiente para detectar quebra evidente.

> **O smoke test não substitui o QA.** A validação funcional ampla é da
> `jira-qa-executor`, na coluna `QA - Claude`.

Checks mínimos:

1. O projeto compila, ou executa o build mínimo aplicável.
2. A análise estática / lint obrigatório passa.
3. Os testes automatizados diretamente relacionados à issue ou ao épico
   passam.
4. O fluxo principal afetado abre/executa sem erro bloqueante.
5. A funcionalidade alterada está operante no destino da integração.
6. Não há erro evidente entre issues já integradas no mesmo épico, quando
   aplicável.
7. Não há regressão óbvia no caminho principal.
8. Não há dependência ausente ou configuração quebrada que impeça a próxima
   etapa.
9. Se a alteração for **visual**, a tela principal envolvida renderiza e
   permite o fluxo básico esperado.
10. Se a alteração envolver **API, estado, persistência ou integração entre
    camadas**, a chamada/fluxo principal é validado no menor nível viável.

Smoke test reprovado é **bloqueio**: registre o que quebrou e pare. Não
prossiga para mover issue nenhuma.

### R5 — Verificar subtarefas

```text
Subtask não avança sozinha pelo workflow, mas precisa ser inspecionada
antes da issue pai avançar.
```

Antes de mover qualquer issue para `QA - Claude`:

1. Consulte a issue no Jira.
2. Liste **todas** as subtarefas vinculadas.
3. Verifique o status de cada uma.
4. Identifique se existe subtarefa obrigatória pendente.
5. Se houver, **bloqueie a movimentação da issue pai**.
6. Se estiver tudo compatível, mova a issue pai.
7. Quando o Jira permitir, mova também as subtarefas relevantes.
8. Se a transição da subtarefa não estiver disponível, registre no
   comentário da issue e no resumo final.

**Subtarefa obrigatória** é qualquer subtarefa aberta ligada à
implementação, correção, teste, integração, documentação necessária ou
ajuste bloqueante da issue pai, e que comprometa a validade funcional ou
técnica da entrega caso fique pendente.

> ⚠️ **Toda subtarefa aberta é tratada como potencialmente obrigatória**,
> salvo quando estiver claramente marcada ou descrita como opcional, futura
> ou não bloqueante. Na dúvida, a skill pergunta — não decide sozinha que
> uma pendência é irrelevante.

### R6 — Registrar a evidência

Publique um comentário na issue contendo:

- **Modo** executado (A, B ou C).
- **Origem → destino** do merge.
- Link/número do Pull Request.
- Resultado final do GitHub Actions, e se houve correções no caminho.
- Se houve conflito: tipo (mecânico/semântico), o que foi reconciliado, e
  se a issue precisou voltar para `Análise - Rafinha`.
- Resultado do smoke test.
- Subtarefas verificadas e seu estado.
- Labels aplicadas ou removidas nesta operação.
- Confirmação do merge realizado.

No **Modo B**, registre também **no épico**: quais issues compuseram o
conjunto promovido, e — em promoção parcial — quais ficaram fora e por quê.

---

## Labels operacionais

| Label | Quando esta skill a aplica | Quando esta skill a remove |
|---|---|---|
| `integrado-epico` | Modo A, depois do merge issue → branch do épico | Nunca. Quem remove é a `jira-qa-executor`, ao dar veredito sobre a `develop` — aprovando **ou** reprovando |
| `qa-develop-aprovado` | Nunca — é da `jira-qa-executor` | Nunca |

Ver a matriz oficial no Confluence (**Vocabulário operacional de labels**,
categoria 11) para o ciclo de vida completo.

---

## Execution State

O Execution State versionado **pertence à branch da issue**. Fora dela, é
apenas estado local de execução.

Em **toda** operação desta skill — Modo A, Modo B e Modo C —
`.claude/execution-state/{CHAVE}.md` permanece **local e não commitado**.

Nunca recebem commit de Execution State:

- a branch do épico (`epic/**`);
- a `develop`;
- a `release/current`;
- branches efêmeras de release.

A rastreabilidade das integrações fica nos comentários da issue, nas
evidências, nos PRs e nos logs da skill — **não** em Execution State
versionado fora da branch da issue.

Em qualquer caso que mova a issue (sucesso ou devolução), apague
`.claude/execution-state/{CHAVE}.md` se existir — a partir daí, Jira e Git
já são a fonte de verdade permanente.

---

## O que NÃO fazer

- ❌ **Nunca inferir o modo de integração** — mesmo quando a estrutura da
  issue, do épico e das branches parecer indicar um caminho óbvio. O modo é
  informado ou confirmado por Rafinha.
- ❌ Nunca executar merge sem antes imprimir o resumo operacional.
- ❌ Nunca preencher uma linha do resumo operacional com suposição — se o
  valor real não for conhecido, pare e pergunte.
- ❌ **Nunca criar branch de épico** — isso é da `jira-issue-executor`, sob
  comando explícito de Rafinha. Se a branch do épico não existir durante uma
  integração, pare e pergunte.
- ❌ Nunca promover um épico parcialmente sem comando explícito de Rafinha.
- ❌ **Nunca tratar ausência de `integrado-epico` como "ainda não
  integrada"** — é bloqueio, e a skill para e pergunta.
- ❌ Nunca mover a issue de coluna no Modo A — ela fica em `Integração` até
  o épico ser promovido.
- ❌ Nunca mover uma issue para `QA - Claude` sem verificar subtarefas.
- ❌ Nunca decidir sozinha que uma subtarefa aberta é irrelevante.
- ❌ Nunca usar `git push --force` ou `--force-with-lease` — se o push
  normal for rejeitado por divergência, pare e avise Rafinha.
- ❌ Nunca usar `git rebase` para reconciliar — sempre
  `git merge origin/<destino>`.
- ❌ Nunca avançar para o merge sem o GitHub Actions verde — falha na
  pipeline é sempre bloqueio, nunca diagnóstico a ser ignorado.
- ❌ Nunca resolver um conflito semântico sozinha — sempre parar e mostrar
  os trechos em conflito a Rafinha.
- ❌ Nunca pular a devolução para `Análise - Rafinha` depois de resolver um
  conflito semântico nos modos A e C, mesmo que a pipeline passe depois.
- ❌ Nunca prosseguir com smoke test reprovado.
- ❌ Nunca abrir um Pull Request nesta skill — se o PR não existir, pare e
  avise Rafinha.
- ❌ Nunca reapontar o destino de um PR existente — pare e pergunte.
- ❌ Nunca criar uma pipeline de GitHub Actions do zero.
- ❌ Nunca dar checkout em outra branch, ou criar uma nova, sem antes
  checar `git status` e resolver alterações não commitadas com Rafinha.
- ❌ Nunca declarar que "o aplicativo inteiro" está livre de problemas —
  esta etapa valida integração técnica e smoke; a validação funcional ampla
  é do QA - Claude.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira processar, nem sobre o
  repositório de código quando não estiver claro.
- ❌ **Nunca commitar `.claude/execution-state/{CHAVE}.md`** em nenhuma
  operação desta skill.
- ❌ Nunca aplicar `qa-develop-aprovado` — essa label é da
  `jira-qa-executor`.
- ❌ Nunca confiar cegamente num Execution State encontrado — sempre
  reconciliar com o estado real do Git/GitHub/Jira antes de continuar.

---

## Resumo final ao usuário

Depois de processar a execução, apresente a Rafinha um resumo consolidado.

**Modo A ou C:**

```
✅ Projeto processado: [nome/chave do projeto]
🔀 Modo: A (issue → branch do épico)
📋 Issues processadas: [quantidade]
  - [ISSUE-1]: PR #12, pipeline OK, sem conflito → merge em epic/PROJ-40-cadastro → smoke OK → `integrado-epico` aplicada (permanece em Integração)
  - [ISSUE-2]: PR #13, pipeline corrigida 1x (lint), conflito mecânico resolvido (import duplicado) → merge em epic/PROJ-40-cadastro → smoke OK → `integrado-epico` aplicada
  - [ISSUE-3]: PR #14, pipeline OK, conflito semântico (duas implementações da mesma validação) — Rafinha decidiu qual prevalece, pipeline revalidada → devolvida para Análise - Rafinha
⚠️ Issues não processadas (PR ausente, destino errado, subtarefa pendente ou pipeline não configurada): [lista ou "nenhuma"]
```

**Modo B:**

```
✅ Projeto processado: [nome/chave do projeto]
🔀 Modo: B (epic/PROJ-40-cadastro → develop)
📦 Escopo: completo — 5 issues obrigatórias
  - Todas com `integrado-epico` ✓
  - Subtarefas verificadas: 3 fechadas, 0 pendentes ✓
  - Critérios de aptidão: 10/10 ✓
🔀 Merge realizado: epic/PROJ-40-cadastro → develop
🧪 Smoke test: OK
📋 Issues movidas para QA - Claude: PROJ-41, PROJ-42, PROJ-43, PROJ-44, PROJ-45
```

Quando a promoção for **bloqueada**, diga qual critério falhou e o que falta
— nunca só "não foi possível promover".
