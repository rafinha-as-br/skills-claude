---
name: jira-review-executor
description: "Fazer a auditoria final das issues na coluna Análise Final - Claude da sprint atual de um projeto Jira indicado por Rafinha, a última etapa antes de Concluído (recebe issues de Documentar). Usar quando ele disser \"revisa as issues do Jira X\", \"roda a coluna Análise Final - Claude\", \"faz a auditoria final do projeto Y\". Audita pendências, a Validação Humana vinculada e o contrato: tipo coerente com a entrega, labels da matriz oficial, registro de uso do Design Package, escopo não expandido, protocolo de QA, contrato de branches e integração (modo, destino, ledger, tentativas), labels operacionais (integrado-epico e qa-develop-aprovado: audita, NUNCA aplica nem remove) e o Contrato Efetivo (atestado PRONTA, fast-track, estados Satisfeita, Não aplicável, Excepcionada). Aprovação move para Concluído; reprovação para Fazer - Claude. NUNCA implementa código ou documentação. Hotfix: registra, mas NÃO move. Escopo explícito, nunca coluna inteira."
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

## Contrato da skill

### Finalidade
Executar a auditoria final em `Análise Final - Claude` antes de uma issue chegar a
`Concluído`.

### Escopo e acionamento
Opera issue por issue dentro do escopo explicitamente confirmado (issue, lista, Epic
ou coluna de um Epic específico — nunca coluna inteira).

### Autoridade
- **Decisão.** Audita o contrato e determina tecnicamente **aprovada ou reprovada**
  segundo os critérios vigentes. Quando reprovada, **para e obtém a decisão de
  Rafinha** sobre o tratamento antes da movimentação.
- **Mutação.** Comenta o resultado, mantém/apaga Execution State e move a issue
  conforme resultado e autoridade prevista. **Nunca corrige código, documentação ou
  labels durante a auditoria.**
- **Atestação.** É a autoridade da atestação **`claude review aprovado`** quando a
  auditoria completa satisfaz o contrato; pode registrar **`review reprovada por
  claude`** ao encontrar achado bloqueante.
- **Transição.** *Fluxo normal:* aprovada → `Concluído`; reprovada →
  `Fazer - Claude`, somente após tratamento/decisão de Rafinha; Validação Humana
  vinculada pendente/reprovada bloqueia a conclusão. ***Hotfix:* registra o resultado
  do review e a atestação, mas não move a issue.** Mesmo aprovada, a Hotfix
  permanece em `Análise Final - Claude` até Rafinha movê-la para `Concluído` ou
  outro destino.

### Entradas e pré-condições
Escopo; issue completa; **Contrato Efetivo resolvido**; **atestado de Preparação
Técnica** quando aplicável ao fluxo normal; **fast-track completo** quando
`Tipo = Hotfix`; registros de implementação, integração, QA, aceite e documentação
aplicáveis; evidências Git/GitHub/AIO/Confluence quando necessárias.

### Obrigações
- auditar o **Contrato Efetivo da issue** e as evidências produzidas pelas
  capacidades anteriores;
- fluxo normal: verificar o atestado de Preparação Técnica quando contratualmente
  exigido;
- Hotfix: verificar fast-track, autorização de Rafinha, estados `Satisfeita` /
  `Não aplicável` / `Excepcionada` e integração por Modo C;
- **não exigir evidência de etapa corretamente resolvida como `Não aplicável` ou
  `Excepcionada`**, e **nunca tratar `Excepcionada` como `Satisfeita`**;
- usar listas específicas apenas para verificações próprias desta capacidade ou como
  implementação técnica do contrato — **sem manter segunda taxonomia hardcoded** de
  tipos, políticas, gates e obrigações que o Contrato Efetivo já resolve;
- verificar plano documental somente quando aplicável; pendências de decisão
  residuais; evidência de integração, labels operacionais, ledger e tentativas;
- não reprovar retroativamente por regra que não valia no momento da execução; a
  Revisão do workflow 2 **não exige migração de issues existentes**, nem cria
  roteamento condicional "issue antiga × nova";
- auditar **evidência**, não a existência atual de branches efêmeras;
- consultar AI Memory apenas como contexto complementar, nunca como substituto das
  fontes oficiais; **delegar à `ai-memory-manager`** achados finais, pendências
  técnicas ou handoff com valor de continuidade;
- no fluxo normal, depois de a issue efetivamente chegar a `Concluído`, pode
  solicitar à `ai-memory-manager` o arquivamento `active → history`; **em Hotfix, a
  aprovação do review não autoriza arquivamento** — só depois que o Jira confirmar
  que Rafinha moveu a issue para estado final;
- **claim, executor e handoff:** para cada issue do escopo fechado, antes da
  primeira mutação (comentário, transição), ler os comentários e abrir o claim de
  execução (Contrato do Workflow, B.5); claim vigente de **outro** executor → não
  auditar aquela issue e reportar a Rafinha. O comentário de resultado leva
  `Executor: Claude | Codex` (A.9) e libera o claim. A frase de atestação
  (`claude review aprovado` / `review reprovada por claude`) é **nome contratual
  fixo**, inclusive quando o auditor é o Codex: ela continua abrindo o comentário e
  o `Executor` vai logo abaixo (A.10). Retomada por outro executor segue o handoff de
  B.5. A auditoria avalia **evidências nas fontes primárias**, nunca o julgamento do
  executor que implementou — esta skill não herda a conclusão de nenhum review
  automatizado anterior (`review-agent`, `/code-review`) e não o substitui. Sem
  conector Atlassian e GitHub homologados no executor, a execução **bloqueia**.

### Evidências, saída e limites
O Jira preserva o comentário de review; as evidências permanecem nas fontes
primárias. Saída: auditoria concluída com resultado **aprovado ou reprovado**.
**Limites:** nunca corrige nada; nunca aplica/remove labels operacionais; nunca
aprova sem auditoria completa; nunca executa ou decide Validação Humana; nunca move
reprovada antes do tratamento humano requerido; nunca move Hotfix; nunca escreve,
reorganiza ou arquiva `ai-memory/` diretamente.

### Delegações
AI Memory → `ai-memory-manager`.

> Passo 0 de toda execução: resolver o Contrato Efetivo
> (`workflow-development-flow/references/contrato-efetivo.md`). Defaults herdados:
> `workflow-development-flow/references/contrato-skills.md`.

---

## Model Policy

Nível padrão: 3 — Profundo · esforço padrão

Esta é a auditoria final antes de "Concluído" — o padrão já parte do nível
Profundo (não do Nível 1 global), conforme a tabela de natureza de atividade
da Model Escalation Policy ("Auditoria final → Nível 3") em
`workflow-development-flow`: o risco de deixar passar um problema para
produção é maior aqui do que numa implementação comum.

Escalar para o Nível 4 (Profundo · esforço máximo) quando:
- há inconsistências cruzadas entre múltiplas issues da mesma sprint que
  interagem entre si, exigindo comparação entre elas antes de aprovar;
- (exceção) a auditoria envolve alto risco arquitetural e o Nível 3 já
  foi considerado insuficiente para uma conclusão confiável.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Onde esta skill se encaixa no fluxo completo

Esta é a última camada antes de "Concluído", num pipeline maior de
colunas, cada uma com sua própria skill:

```
A fazer → Decisão - Rafinha → Design de produto - Rafinha
        → Preparação técnica - Claude → Ready
                          ↓
Fazer - Claude (jira-issue-executor)
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
trabalha em branch isolada). Ver `workflow-development-flow`, seção 13. O arquivo
registra `Executor` e `Handoff`: executor registrado diferente do atual é handoff
(Contrato do Workflow, B.5) — reconcilie com Jira, Git/GitHub e `ai-memory/` antes
de agir.

---

## Passo a passo

### 1. Localizar as issues elegíveis

**Gate de escopo (workflow-development-flow, princípio 11).** Antes de
buscar qualquer issue, confirme o escopo explícito com Rafinha, se ele
ainda não o deixou claro no comando: issue individual, lista de issues, Epic ou
coluna de um Epic específico — **nunca coluna inteira**. Estar na coluna correta
não autoriza uma issue fora do escopo confirmado. Escopo já fechado e confirmado
por Rafinha na sessão e repassado pela `workflow-remote-orchestrator` vale como
a confirmação (`contrato-workflow.md`, B.2).

Busque, na sprint atual do projeto identificado, as issues do escopo
confirmado na coluna **"Análise Final - Claude"**. Processe-as uma de cada
vez.

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

**Passo 0.** Resolva o Contrato Efetivo da issue
(`workflow-development-flow/references/contrato-efetivo.md`): tipo, políticas
ativas, etapa, obrigações e seus estados de satisfação. É dele — e não de uma lista
fixa nesta skill — que vem **o que** a issue exigia. Os dezesseis pontos abaixo são
as verificações **próprias** desta capacidade (evidência concreta que as skills
anteriores tinham obrigação de deixar) e a implementação técnica do contrato.

> **Vigência.** Não reprove retroativamente por regra que não valia no momento da
> execução (`contrato-workflow.md`, Bloco E). Issue trabalhada antes de uma regra
> não tem como cumpri-la — registre a observação, mas **não reprove por isso**.
> Isto vale para os contratos anteriores (branches por épico, release controlada,
> branches temporárias e ledger). Quanto à Revisão do workflow 2: **não há
> convivência com o contrato antigo nem migração de issues existentes**, e esta
> skill **não implementa** roteamento nem auditoria condicionados a "issue antiga ×
> nova" — o workflow novo é a única referência para novas execuções realizadas
> sob ele.

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
| `legacy` | O raio de alteração foi contido? |
| `needs-human-review` | A necessidade de revisão reforçada foi sinalizada? |

**5.1 Descrição padronizada sem resíduo de pendência.** A issue usa a
descrição de 9 seções (`workflow-development-flow` §17) e a seção
**Pendências de decisão** está vazia/"Nenhuma" — ela não devia ter chegado
até aqui com pendência aberta (o Gate 12 de `Fazer - Claude` já deveria ter
bloqueado antes). Resíduo aqui é achado.

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
| **A** — issue/Epic → branch do épico | PR aberto **contra a branch do épico**; branch da issue nascida da branch do épico; `integrado-epico` aplicada; a issue **não** mudou de coluna naquele momento. Se o escopo foi um Epic inteiro, o resumo operacional lista **todas** as issues do conjunto, não só uma |
| **B** — branch do épico → develop | Todas as issues obrigatórias do escopo com `integrado-epico` antes da promoção; critérios de aptidão registrados; lote movido junto; **PR de promoção existente** (aberto pela própria Integração, se necessário — Correções 27/09); **evidência da autorização humana de merge (Gate 15)**, distinta da confirmação de modo/escopo |
| **C** — issue → develop | PR aberto **contra a `develop`**; branch da issue nascida da `develop` |

Modo declarado que não bate com o destino do PR é achado — e é o tipo de
achado que só aparece aqui, porque tudo passou.

> **Resumo operacional ausente** é achado por si só. A skill de integração é
> obrigada a imprimi-lo e registrá-lo antes de qualquer merge; sem ele não há
> como saber qual operação foi entendida.

> ⚠️ **Ausência de branch não é achado (Correções 27/09).** Depois de um
> Modo B ou C bem-sucedido, a `jira-integration-executor` exclui as
> branches que já cumpriram o papel. Auditar aqui é sobre **evidência**
> (PR, commit SHA, comentário) — não sobre a branch ainda existir. Só
> falta de evidência é achado.

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

**11. O ledger operacional da Integração está completo (Correções 27/09).**
Cada modo tem campos mínimos obrigatórios no comentário da
`jira-integration-executor` (ver `workflow-development-flow` §16 e a
própria skill, R6). Campo obrigatório ausente é achado — é o mesmo
princípio do "proibido fallback silencioso" aplicado ao registro, não à
execução.

**12. `Links para merge` não foi sobrescrito pelo PR de promoção do Modo B.**
Esse campo sempre aponta para o **PR individual** da issue, aberto pela
`jira-issue-executor`. Se ele estiver apontando para o PR de promoção
`epic/** → develop`, é achado.

**13. O número da tentativa é coerente com o histórico de retornos.**
Se a issue já teve `N` reprovações/retornos registrados nos comentários
"Implementação Claude", a branch e o comentário da tentativa atual devem
citar `.N`. Tentativa reaproveitada (mesmo número ou mesma branch de uma
tentativa anterior) é achado.

**14. Atestado de Preparação Técnica (issue normal).**
Issue normal que passou por `Ready` precisa ter, entre os comentários, o
`## Preparação Técnica — Atestado` com `Resultado: PRONTA` anterior ao início da
implementação. Atestado ausente, ou implementação iniciada com o mais recente em
`BLOQUEADA` / `AGUARDANDO DECISÃO TÉCNICA`, é achado. Verifique também que, em
issue de Epic, a branch do Epic foi preparada ali (evidência no atestado, seção
**Git**) e **não** criada pelo `jira-issue-executor`.

**15. Hotfix — fast-track e estados das obrigações.**
Para `Tipo = Hotfix`: a descrição traz o fast-track completo (contexto, objetivo,
escopo, etapas aplicáveis/dispensadas com justificativa, condições, estratégia Git,
testes e validação, QA, documentação, revisão, **autorização de Rafinha**); cada
obrigação dispensada está marcada `Não aplicável` ou `Excepcionada` (nunca
`Satisfeita`), e `Excepcionada` tem autorização registrada (obrigação, motivo,
contexto); `requires-design`, quando presente, está resolvido como `Não aplicável`
ou `Excepcionada`; a branch foi `hotfix/<ISSUE-KEY>` a partir de `develop`; a
integração foi **Modo C** direto em `develop`, sem branch de Epic. **Não exija
evidência de uma etapa corretamente marcada `Não aplicável` ou `Excepcionada`** —
exigir seria achado contra o auditor. Testes e validação suficientes para provar a
correção continuam obrigatórios.

**16. Composição multi-repo e transições de Hotfix (quando aplicável).**
Em produto multi-repo, a evidência da Integração inclui o commit de composição e a
branch do Workspace correta para o modo (`workspace/epic|issue|hotfix` →
`workspace/develop`); gitlink normal não aponta para commit isolado em branch de
implementação. Em Hotfix, o histórico não mostra movimentação automática de coluna
por skill (só por Rafinha).

### 3. Decidir o resultado da revisão

#### 3a. Issue aprovada (sem pendências)

Se não há nenhuma ponta solta ou pendência:

1. Comente na issue: **"claude review aprovado"** (frase fixa, no início), com
   `Executor: Claude | Codex` logo abaixo e um breve resumo do que foi conferido.
2. **Issue normal:** mova o ticket para **"Concluído"**. **Hotfix: não mova** —
   registre a atestação e deixe a Hotfix em `Análise Final - Claude`; Rafinha a
   move para `Concluído` (ou outro destino).
3. Apague `.claude/execution-state/{CHAVE}.md` se existir — o Jira já é o
   registro permanente a partir daqui.
4. *(Opcional, fluxo normal)* Com a issue **efetivamente em `Concluído` no Jira**,
   solicite à `ai-memory-manager` o arquivamento `active → history` da memória da
   issue (e do Epic, se este foi concluído). Em Hotfix, só depois de o Jira
   confirmar que Rafinha moveu a issue para estado final.

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
   identificar issues que precisam de correção), seguido de `Executor: Claude | Codex`
   logo abaixo.
4. **Issue normal:** mova o ticket direto para **"Fazer - Claude"** — a coluna de
   espera "Review - Rafinha" foi eliminada do fluxo novo. Como a decisão de
   Rafinha já foi obtida no chat (item 1, antes mesmo de escrever o
   comentário), não há necessidade de uma parada intermediária adicional:
   a issue já pode seguir direto para a fila de execução. **Hotfix: não mova** —
   registre a reprovação e a decisão de Rafinha e deixe a Hotfix em
   `Análise Final - Claude`; ele decide e executa a próxima transição.
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
- ❌ Nunca reprovar uma issue por regra que não valia no momento da execução
  (vigência) — registre a observação e siga. Nunca implementar auditoria
  condicionada a "issue antiga × nova" para a Revisão do workflow 2.
- ❌ **Nunca mover uma Hotfix de coluna**, nem quando aprovada.
- ❌ Nunca tratar `Excepcionada` como `Satisfeita`, nem exigir evidência de etapa
  corretamente marcada `Não aplicável` ou `Excepcionada`.
- ❌ Nunca escrever, reorganizar ou arquivar `ai-memory/` diretamente
  (delegar à `ai-memory-manager`).
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
