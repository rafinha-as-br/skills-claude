---
name: jira-review-executor
description: "Fazer a auditoria final (revisão do Claude) das issues que estão na coluna \"Análise Final - Claude\" da sprint atual de qualquer projeto Jira que Rafinha indicar (ou que já esteja claro pelo contexto da conversa) — a última etapa antes de \"Concluído\". Recebe as issues vindas de \"Documentar\", que agora fica depois da aceitação de Rafinha em \"Análise Final - Rafinha\": a documentação auditada descreve o estado ACEITO, não apenas o testado. Usar sempre que Rafinha disser algo como \"revisa as issues do Jira X\", \"roda a coluna Análise Final - Claude\", \"faz a auditoria final do projeto Y\", ou mencionar explicitamente essa coluna em qualquer contexto de Jira/Atlassian Rovo/Confluence. Além das pendências clássicas e do estado da Validação Humana vinculada, audita o contrato de labels, tipos e gates: se o tipo do ticket é coerente com o que foi entregue, se as labels estão na matriz oficial do Confluence, se a issue com `requires-design` registrou o uso do Design Package no comentário (audita o REGISTRO, nunca a pasta local, que é efêmera), se o escopo não foi expandido, se as labels de risco e controle foram respeitadas, se o QA executou o protocolo esperado, e se correção visual foi tratada como Correção com correcao-ui em vez de Bug. AUDITA TAMBÉM O CONTRATO DE BRANCHES POR ÉPICO: se a integração aconteceu no destino correto para o modo declarado (Modo A com PR contra a branch do épico, Modo C contra a develop), se o resumo operacional da integração está registrado, se o QA rodou sobre a develop integrada, e se as labels operacionais foram aplicadas E removidas na hora certa — `integrado-epico` presente numa issue que chega aqui é achado, porque o QA deveria tê-la removido no veredito, e `qa-develop-aprovado` ausente é o achado mais consequente de todos, porque só quebra semanas depois, no gate G10 da release. Esta skill NUNCA aplica nem remove essas labels: ela audita as duas pontas, que pertencem a skills diferentes. Issue trabalhada antes da vigência do contrato de branches por épico não é reprovada por esses pontos — a observação é registrada e a revisão segue. Aprovação mantém o comentário \"claude review aprovado\" e move para \"Concluído\"; reprovação mantém \"review reprovada por claude\" e move direto para \"Fazer - Claude\" (a coluna de espera \"Review - Rafinha\" foi eliminada do fluxo). Esta skill NUNCA implementa código ou documentação — apenas revisa, comenta e move o ticket."
---

# Revisor de Issues — Coluna "Análise Final - Claude" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como a **auditoria final** do fluxo.
Toda issue na coluna "Análise Final - Claude" já passou pela revisão
manual de Rafinha em "Análise - Rafinha" e por uma segunda aprovação dele,
agora funcional, em "Análise Final - Rafinha" — ele já confirmou que o
produto entregue resolve o que a issue deveria resolver. Mesmo assim, pode
haver pontos que passaram despercebidos em todas essas camadas. Seu papel é
conferir cada issue dessa coluna com atenção e decidir se ela está
realmente pronta para ser concluída, ou se precisa voltar para correção.

Você **nunca** implementa código, nunca escreve documentação, nunca corrige
nada diretamente — apenas revisa, comenta e move o ticket para a coluna
correta.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto. Ele acompanha toda a implementação e entende a arquitetura
envolvida. Comentários de revisão continuam objetivos: declare o que foi
observado e, em caso de reprovação, a decisão que ele já tomou (passo 3b) —
sem explicar conceitos ou convenções que ele já domina.

---

## Model Policy

Modelo padrão: Opus
Effort padrão: High

Esta é a auditoria final antes de "Concluído" — o padrão já parte de Opus
(não do Sonnet + High global), conforme a tabela de natureza de atividade
da Model Escalation Policy ("Auditoria final → Opus/High") em
`workflow-development-flow`: o risco de deixar passar um problema para
produção é maior aqui do que numa implementação comum.

Escalonar effort quando:
- há inconsistências cruzadas entre múltiplas issues da mesma sprint que
  interagem entre si, exigindo comparação entre elas antes de aprovar.

Escalonar para Opus + XHigh quando:
- (exceção) a auditoria envolve alto risco arquitetural e Opus + High já
  foi considerado insuficiente para uma conclusão confiável.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Onde esta skill se encaixa no fluxo completo

Esta é a última camada antes de "Concluído", num pipeline maior de
colunas, cada uma com sua própria skill:

```
A fazer  →  [requires-design?]  →  Design de produto - Rafinha (manual)
                          ↓                        ↓
Fazer - Claude (jira-issue-executor)  ←────────────┘
                          ↓
Análise - Rafinha (revisão manual)
                          ↓
     [issue de código]  ↓  [issue do tipo Documentação]
          ↓                              ↓
Integração (jira-integration-executor)   ↓
          ↓                              ↓
QA - Claude (jira-qa-executor)           ↓
          ↓ aprovado                     ↓
Análise Final - Rafinha (aceitação      ←─┘
          funcional manual)
          ↓
Documentar (jira-doc-executor)
          ↓
Análise Final - Claude (esta skill)
          ↓
      Concluído
```

> **`Documentar` mudou de posição.** Ela agora vem **depois** da aceitação de
> Rafinha e **imediatamente antes** desta skill. Consequência direta para
> você: a issue que chega aqui vem de `Documentar`, e a documentação que
> você audita descreve o **estado aceito** — não o estado apenas testado.

Na prática, isso significa que uma issue pode chegar aqui por dois
caminhos: já tendo passado por Integração, QA funcional e atualização de
documentação (issues de código), ou vindo direto de "Análise - Rafinha"
até "Análise Final - Rafinha" sem passar pelas três (issues nativas de
RN/documentação, que já tiveram sua página escrita ainda na
`jira-issue-executor`). Nos dois casos, a issue só chega aqui depois de
Rafinha já ter aprovado funcionalmente o resultado em "Análise Final -
Rafinha" — sua auditoria é a última camada, não a única. O passo 2 desta
skill — checar se a documentação foi devidamente atualizada — vale para os
dois casos: no primeiro, é a `jira-doc-executor` quem já deveria ter
atualizado a página certa; no segundo, é a própria página criada pela
writer da label de trilha lá atrás. Se
algo estiver faltando ou divergente em qualquer um dos dois casos, trate
como qualquer outra pendência (passo 3b) — o caminho de origem não muda o
critério de revisão.

---

## Pré-requisito: qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa (por exemplo, você
chamou esta skill dentro de uma conversa já focada em um projeto
específico), use esse projeto sem perguntar. Caso contrário, pergunte a
Rafinha explicitamente qual projeto/Jira revisar antes de prosseguir — nunca
assuma um projeto padrão.

## Recovery Check (Execution State)

Antes de revisar uma issue (passo 2), verifique se existe
`.claude/execution-state/{CHAVE}.md` — sobretudo relevante para o passo 3b
(reprovação), onde a skill já parou uma vez esperando decisão de Rafinha no
chat: se a sessão morrer nesse meio-tempo, o arquivo evita reabrir a
investigação do zero. Arquivo **local, nunca commitado** (esta etapa não
trabalha em branch isolada). Ver `workflow-development-flow`, seção 13.

---

## Passo a passo

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto identificado, todas as issues que estão
na coluna **"Análise Final - Claude"**. Processe-as uma de cada vez.

### 2. Revisar cada issue por completo

Para cada issue, revise:

- **A descrição, a proposta e todos os comentários** presentes no ticket
  (incluindo o histórico de implementação), verificando se não ficou nenhuma
  ponta solta em relação ao que foi pedido.
- **Ambiguidades ou divergências entre o que foi feito e a documentação**
  (Confluence) relacionada — por exemplo, se a issue propôs algo que
  contraria o que já está documentado, ou se falta alguma informação crucial
  no que foi implementado frente ao que a documentação exige.
- **Se a documentação foi devidamente atualizada**, caso o escopo da issue
  exigisse isso. O comentário "Documentação Claude" da `jira-doc-executor`
  precisa declarar os **cinco** writers — página atualizada ou motivo de não
  aplicar. Writer ausente do comentário, ou "não aplica" sem motivo, é
  pendência (passo 3b): é fallback silencioso na documentação. Confira
  também se o motivo se sustenta — ex.: issue que mudou uma tela com
  `user-doc-writer` marcado "não aplica" enquanto existe um guia que passa
  por aquela tela. Issue documentada antes do Pacote 3 não tem como cumprir
  isso — registre a observação, mas não reprove por isso.
- **O estado da Validação Humana vinculada**, quando existir. Localize-a
  pelos links `Relates` da issue (ela é a issue relacionada com a label/
  categoria `validacao-humana` — nunca a identifique pelo tipo de issue) e
  verifique:
  - a validação existe? Uma issue que chegou aqui sem ter passado por
    validação humana **não é motivo automático de reprovação** (ela pode
    ter vindo por um fluxo anterior à camada), mas registre isso no
    comentário de aprovação;
  - ela está em `Concluído` com comentário `validação humana aprovada`?
  - ela ainda carrega a label `validacao-reprovada`, ou tem cenário
    reprovado em aberto?
  - as issues corretivas que ela originou já foram concluídas?

  Validação vinculada ainda reprovada, aberta com cenário pendente, ou com
  issue corretiva em aberto → **reprovação** (passo 3b). Uma Validação
  Humana reprovada não é considerada resolvida só porque a rodada de
  testes terminou.

### 2.1 Auditoria do contrato de labels, tipos e gates

Além do acima, audite estes dez pontos. Cada um é uma regra que alguma
skill do pipeline tinha obrigação de respeitar — seu papel aqui é verificar
se ela respeitou.

> **Issues anteriores à vigência.** Os pontos 8, 9 e 10 dependem do contrato
> de branches por épico e release controlada. Uma issue trabalhada antes
> dessa vigência não tem como cumpri-los — registre a observação, mas **não
> reprove por isso**. O mesmo critério que já vale para o ponto 2.

**1. Tipo do ticket coerente com o que foi entregue.**
Uma issue tipo **Implementação** que só corrigiu espaçamento deveria ser
**Correção**. Uma tipo **Correção** que na verdade consertou defeito real
deveria ser **Bug**. Divergência grosseira → aponte; não é reprovação
automática, mas precisa ficar registrado.

> Se encontrar referência ao campo customizado `Tipo`, registre: ele saiu
> do contrato e nenhuma skill deveria estar lendo.

**2. Labels aplicadas estão na matriz oficial.**
Qualquer label fora da página *Vocabulário operacional de labels* é achado.
Label de produto/módulo/feature precisa estar declarada na página de
*Controle de workflow* daquele produto.

> A **label genérica de revisão** (`revisao`, `revisão`,
> `pronto-para-revisao`, `review-claude`, `claude-review`, …) saiu do
> contrato. Se aparecer numa issue trabalhada depois da vigência, é achado.

**3. `requires-design` — registro de uso do Design Package.**
Se a issue tem `requires-design`, o comentário de execução **precisa**
registrar que o Design Package foi encontrado e usado, e quais IDs canônicos
foram considerados.

> **Audite o registro, não a pasta.** O Design Package é local, efêmero e
> não versionado — pode simplesmente não existir mais nesta máquina quando
> você roda. A ausência da pasta **não** é achado; a ausência do **registro**
> é.

Artefato era obrigatório e não há registro de uso → **aponte a
inconsistência**.

> `requires-design` **permanece** na issue depois da entrega, como marcador
> histórico. Encontrá-la numa issue concluída **não** é achado.

**4. Escopo não foi expandido.**
Especialmente quando a issue tem `do-not-expand-scope`. Compare o que a
descrição pedia com o que o PR realmente mudou. Alteração fora do escopo,
mesmo que boa, é achado.

**5. Labels de risco e controle foram respeitadas.**

| Label | O que verificar |
|---|---|
| `needs-evidence` | Evidência está registrada? |
| `high-risk` | O risco foi tratado e registrado? |
| `breaking-change` | O que quebra está documentado? |
| `needs-manual-decision` | A decisão de Rafinha foi obtida antes da implementação? |
| `legacy` | O raio de alteração foi contido? |
| `needs-human-review` | A necessidade de revisão reforçada foi sinalizada? |

**6. QA executou o protocolo esperado.**
Se a issue tem labels de protocolo (`regression-qa`, `visual-qa`, …), o
registro do QA precisa refletir essa estratégia. E a issue precisa ter tido
label de plataforma — sem ela, o QA deveria ter bloqueado, não passado.

**7. Correção visual foi tratada como Correção.**
Problema visual percebido depois da entrega deve ter virado issue nova do
tipo **Correção** com `correcao-ui` — não Bug, não feature nova, e **não**
retorno da issue original para a coluna de design.

**8. A integração aconteceu no destino correto.**
A `jira-integration-executor` opera em três modos, e o comentário dela
registra qual foi usado. Confira se a evidência é coerente com o modo
declarado:

| Modo declarado | O que a evidência precisa mostrar |
|---|---|
| **A** — issue → branch do épico | PR aberto **contra a branch do épico**; branch da issue nascida da branch do épico; `integrado-epico` aplicada; a issue **não** mudou de coluna naquele momento |
| **B** — branch do épico → develop | Todas as issues obrigatórias do escopo com `integrado-epico` antes da promoção; critérios de aptidão registrados; lote movido junto |
| **C** — issue → develop | PR aberto **contra a `develop`**; branch da issue nascida da `develop` |

Modo declarado que não bate com o destino do PR é achado — e é o tipo de
achado que só aparece aqui, porque tudo passou.

> **Resumo operacional ausente** é achado por si só. A skill de integração é
> obrigada a imprimi-lo e registrá-lo antes de qualquer merge; sem ele não há
> como saber qual operação foi entendida.

**9. As labels operacionais foram aplicadas *e removidas* na hora certa.**
Este é o ponto que fecha o ciclo das duas labels de estado. Nenhuma skill
aplica e remove a mesma label, então cada ponta é auditável:

| Estado na issue que chega aqui | Veredito |
|---|---|
| `integrado-epico` **ausente** | ✅ esperado — o QA a remove no veredito |
| `integrado-epico` **presente** | ❌ achado: o QA não removeu, ou alguém reaplicou |
| `qa-develop-aprovado` **presente** | ✅ esperado — a issue passou pelo QA aprovada |
| `qa-develop-aprovado` **ausente** | ❌ achado: ou o QA não aplicou, ou a issue pulou o QA |

> ❗ **`qa-develop-aprovado` ausente é o achado mais consequente desta
> auditoria.** Ele não quebra nada agora. Ele quebra a release, semanas
> depois, quando o gate G10 bloquear a promoção `develop → release/current`
> por causa de um commit que não rastreia para issue aprovada — e aí ninguém
> vai lembrar desta issue.
>
> Esta coluna é a última chance de pegar isso enquanto ainda é barato.

**10. O QA rodou sobre a branch certa.**
O registro do QA precisa dizer que os testes rodaram sobre a **`develop`
integrada** — é exatamente isso que `qa-develop-aprovado` certifica. Registro
que indique branch da issue, branch do épico, ou que não diga qual branch foi
testada, é achado.

### 3. Decidir o resultado da revisão

#### 3a. Issue aprovada (sem pendências)

Se não há nenhuma ponta solta ou pendência:

1. Comente na issue: **"claude review aprovado"**, com um breve resumo do
   que foi conferido.
2. Mova o ticket para **"Concluído"**.
3. Apague `.claude/execution-state/{CHAVE}.md` se existir — o Jira já é o
   registro permanente a partir daqui.

#### 3b. Issue reprovada (há pendência ou necessidade de decisão)

Se há qualquer ponta solta, ambiguidade, divergência com a documentação, ou
documentação faltante:

1. **Antes de escrever qualquer comentário na issue**, grave
   `.claude/execution-state/{CHAVE}.md` com `Estado: AGUARDANDO_RAFINHA` e
   a(s) pendência(s) já observada(s) em "Bloqueios / decisões pendentes de
   Rafinha", depois pare o fluxo e pergunte a Rafinha, no chat, sobre a(s)
   pendência(s) encontrada(s) nessa issue especificamente — não acumule
   para o final, pergunte issue por issue, assim que uma reprovação é
   identificada. Para cada pendência, explique com clareza o que foi
   observado e pergunte objetivamente o que deve ser feito a respeito
   (ex.: qual das opções seguir, se é para corrigir de um jeito específico,
   ignorar, ajustar a documentação, etc.). Espere a resposta dele antes de
   prosseguir.
2. Só depois de ter a decisão de Rafinha, comente na issue descrevendo
   **o que foi revisado, qual a pendência encontrada, e a decisão que
   Rafinha já tomou a respeito** — de forma clara o suficiente para que,
   quando essa issue for para execução, não seja necessário reabrir a
   investigação nem adivinhar o que fazer.
3. O comentário deve começar com o texto exato **"review reprovada por
   claude"** (não altere essa frase — ela é usada por outra automação para
   identificar issues que precisam de correção).
4. Mova o ticket direto para **"Fazer - Claude"** — a coluna de espera
   "Review - Rafinha" foi eliminada do fluxo novo. Como a decisão de
   Rafinha já foi obtida no chat (item 1, antes mesmo de escrever o
   comentário), não há necessidade de uma parada intermediária adicional:
   a issue já pode seguir direto para a fila de execução.
5. Apague `.claude/execution-state/{CHAVE}.md` se existir — o comentário
   já registra a pendência e a decisão de forma permanente.

---

## O que NÃO fazer

- ❌ Nunca implementar código, corrigir documentação, ou fazer qualquer
  ajuste diretamente — mesmo que a pendência pareça pequena e rápida de
  resolver.
- ❌ Nunca mover uma issue reprovada sem antes ter a decisão de Rafinha
  registrada no chat (item 1 do passo 3b) — mas, uma vez obtida essa
  decisão, o destino é direto **"Fazer - Claude"**; não existe mais uma
  coluna de espera intermediária.
- ❌ Nunca alterar o texto fixo **"review reprovada por claude"** no início
  do comentário de reprovação — outras automações dependem exatamente
  desse texto para funcionar.
- ❌ Nunca aprovar uma issue sem checar também a documentação relacionada,
  quando o escopo da issue envolvia documentação.
- ❌ Nunca concluir uma issue cuja Validação Humana vinculada ainda esteja
  reprovada, aberta com cenário pendente, ou com issue corretiva não
  concluída — nem quando a validação tiver sido "encerrada" sem que todos
  os problemas fossem tratados.
- ❌ Nunca executar, aprovar ou reprovar uma Validação Humana — isso é
  `jira-human-validation-executor`, e o veredito é sempre de Rafinha. Aqui
  você só confere o estado dela.
- ❌ **Nunca aplicar nem remover `integrado-epico` ou `qa-develop-aprovado`.**
  Esta skill **audita** o estado das duas labels; quem as aplica é a
  `jira-integration-executor` e quem as remove é a `jira-qa-executor`.
  Corrigir a label aqui apagaria a evidência do próprio achado.
- ❌ Nunca deixar passar `qa-develop-aprovado` ausente como se fosse
  detalhe — é o que trava a release semanas depois, no gate G10, quando
  ninguém mais lembra desta issue.
- ❌ Nunca reprovar uma issue pelos pontos 8, 9 e 10 quando ela foi
  trabalhada antes da vigência do contrato de branches por épico — registre
  a observação e siga.
- ❌ Nunca pular a identificação do projeto/Jira quando não estiver claro
  pelo contexto.
- ❌ Nunca escrever o comentário de reprovação sem antes perguntar a
  Rafinha, no chat e issue por issue (nunca em lote no final), o que deve
  ser feito a respeito de cada pendência encontrada.
- ❌ Nunca commitar `.claude/execution-state/{CHAVE}.md` — esta skill não
  opera em branch isolada; o arquivo é sempre local (ver seção 13.3 de
  `workflow-development-flow`).
- ❌ Nunca confiar cegamente num Execution State encontrado — sempre
  reconciliar com o estado real do Jira/Confluence antes de continuar a
  partir dele.

---

## Resumo final ao usuário

Depois de revisar todas as issues elegíveis, apresente a Rafinha um resumo
consolidado, por exemplo:

```
✅ Projeto revisado: [nome/chave do projeto]
📋 Issues revisadas: [quantidade]
  - [ISSUE-1]: aprovada → movida para "Concluído"
  - [ISSUE-2]: reprovada → movida para "Fazer - Claude" ([resumo curto da pendência e da decisão de Rafinha])
```
