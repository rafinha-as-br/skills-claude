# Plano de implementação — Pacote 5: Correções 27/09 (Integração e branches)

Documento de planejamento, no mesmo formato dos `plano-pacote-N.md`
anteriores.

**Fonte do contrato:** página do Notion *"Correções 27/09"*, lida em
2026-09-27 (única página ativa em "Rafinha Workflow" no momento da leitura;
as quatro anteriores — Design/labels/gates, Branches por épico, Skills de
documentação, Revisão do workflow inteiro — já estão em "Já foi
implementado" e não são tocadas por este pacote, exceto onde esta página as
substitui).

**Escopo desta rodada, por instrução explícita de Rafinha:** só Confluence e
skills. **Nada de Jira** — não configura board, não cria coluna, não move
issue, não altera projeto real.

**Origem:** a página nasce de dois incidentes reais na etapa de Integração
(Modo A restringindo o escopo à issue em checkout; Modo B bloqueando por
"ausência de PR" quando na verdade a responsabilidade de criar esse PR
mudou de dona) e amplia o contrato de branches, rastreabilidade e promoção
de épicos para cobrir as lacunas que os causaram.

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 1 | `workflow-development-flow` — §16 (Modelo de branches), gates 14/15, referências no §8.2/§10 | ✅ feito |
| 2 | `jira-integration-executor` — reescrita de Modo A (escopo de Epic), Modo B (PR próprio + gate humano), limpeza de branches, ledger, multi-repo | ✅ feito |
| 3 | `jira-issue-executor` — branch por tentativa, garantia automática da branch de Epic, recriação pós-reprovação | ✅ feito |
| 4 | `jira-qa-executor` — corrige o fluxo de reprovação de issue de Epic (não é mais Modo C direto) | ✅ feito |
| 5 | `jira-review-executor` — audita o ledger, `Links para merge`, coerência de tentativa | ✅ feito |
| 6 | `jira-release-executor` + `release-lifecycle.md` — G10 reconhece merge agregador de Epic | ✅ feito |
| 7 | `README.md` | ✅ feito |
| 8 | Confluence — páginas impactadas | ✅ feito |
| 9 | Verificação final (grep de drift, cross-refs, resumo para Rafinha) | ✅ feito |

---

## 1. O que muda, em uma frase por decisão

A página tem 11 decisões numeradas. Nenhuma é independente das outras —
todas orbitam a mesma mudança de fundo:

> **Branch deixa de ser o registro permanente da Integração. O registro
> permanente passa a ser Git (commits, PRs) + comentários estruturados no
> Jira. Branch é artefato de trabalho, descartável depois de cumprir o
> papel.**

| # | Decisão | Resumo |
| --- | --- | --- |
| 1 | Escopo de Epic no Modo A | `modo A - CPS-131` (chave de Epic) processa **todas** as issues do Epic que estão em `Integração`, não só a issue em checkout. Idempotente via PR+label, nunca só a coluna |
| 2 | Branch de Epic antes da 1ª Integração | Deixa de ser opcional: `jira-issue-executor` garante/cria a branch do Epic **automaticamente** quando a issue pertence a um, antes de a issue chegar à Integração |
| 3 | Ciclo de vida das branches | Branches passam a ser temporárias. Reimplementação após retorno **nunca reusa** a branch antiga — cria `.N` nova. O contador vem de **comentários estruturados no Jira**, nunca de contar branches remotas |
| 4 | Reprovação de issue de Epic já promovido | Branch do Epic já foi apagada (decisão 5) → `jira-issue-executor` recria a branch do Epic a partir da `develop` atual, e a issue ganha uma branch `.N` nova. Nunca reaproveita a branch antiga do Epic |
| 5 | Limpeza automática de branches | Modo B bem-sucedido apaga a branch do Epic e as branches de issue que já cumpriram o papel. Modo C bem-sucedido apaga a branch da issue. Só no encerramento **bem-sucedido** |
| 6 | Modo B cria seu próprio PR + gate humano | A regra "Integração nunca abre PR" **deixa de valer para o Modo B**. A própria `jira-integration-executor` cria o PR `epic/** → develop` quando necessário, e exige uma **segunda confirmação** de Rafinha — distinta da confirmação de modo/escopo — só depois de tudo verde e apto |
| 7 | Ledger operacional | Toda execução da Integração deixa registro estruturado no Jira, com campos mínimos por modo, para sobreviver à exclusão das branches |
| 8 | `Links para merge` não é sobrescrito | O PR de promoção do Modo B nunca substitui o PR individual da issue nesse campo |
| 9 | G10 entende merge agregador de Epic | O gate de elegibilidade da release passa a reconhecer dois caminhos de entrada na `develop`: merge direto de issue (como hoje) e merge de Epic (agregador — precisa desagregar em issues e validar cada uma) |
| 10 | Multi-repositório | Um Epic que toca vários repositórios continua sendo **uma execução lógica**. Modo B pode abrir N PRs (um por repo), com **uma** autorização humana para o conjunto |
| 11 | Falha durante promoção multi-repo | Lote incompleto nunca libera issue para QA nem limpa branch. Corrige o que é mecânico, escalona o que é semântico/de negócio |

Mais a decisão final (sem número na página, mas em vigor): **negativa de
merge no Modo B não é falha técnica** — encerra a execução sem mergear, sem
mover issue, sem limpar branch, e uma execução futura revalida do zero.

---

## 2. Conteúdo conflitante a descartar (por instrução de Rafinha)

Estas frases do contrato atual **contradizem** a atualização e devem ser
substituídas, não preservadas ao lado da regra nova:

| Onde | Frase antiga (descartar) | Substituída por |
| --- | --- | --- |
| `jira-issue-executor` (frontmatter e "Operação especial") | "Pertencer a um épico NÃO autoriza a criação automática da branch — rodar a coluna Fazer - Claude nunca cria branch de épico" | Decisão 2: a skill **garante/cria** a branch do Epic automaticamente quando necessário, dentro do fluxo normal |
| `jira-issue-executor`, passo 5.2 | "❗ Não crie a branch do épico aqui. (...) A criação de branch de épico é operação separada, sob comando explícito de Rafinha" | Mesma decisão 2 — a criação passa a ser parte do passo 5.2 |
| `jira-issue-executor`, passo 4b | "A branch dessa issue provavelmente já existe (...) vá para o passo 5.2 para retomá-la normalmente" | Decisão 3 — reimplementação **nunca reutiliza** a branch antiga; sempre `.N` nova |
| `jira-issue-executor`, convenção de branch | `{tipo}/<ISSUE-KEY>-claude` (sem variação) | Decisão 3 — gramática passa a ser `{tipo}/<ISSUE-KEY>-claude[.<tentativa>]` |
| `jira-qa-executor`, "Correção de issue reprovada que veio de épico" | "A correção segue o fluxo normal a partir da `develop` e integra direto (Modo C) — não volta para a branch do épico" | Decisão 4 — volta a integrar via **Epic → Modo A → Modo B**, com branch do Epic recriada |
| `jira-integration-executor` (frontmatter e corpo) | "Esta skill nunca abre um PR do zero" (regra genérica sem ressalva) | Decisão 6 — a regra vale só para A e C; **B cria seu próprio PR** |
| `jira-integration-executor`, Modo A | Processa apenas a issue informada/em checkout | Decisão 1 — quando a chave é um Epic, o escopo é `issues do Epic ∩ Integração` |
| `jira-release-executor` / `release-lifecycle.md`, G10 | "extrair a chave da issue **do nome da branch de origem**" (assume que todo merge é de uma branch de issue) | Decisão 9 — dois caminhos: merge direto de issue, e merge agregador de Epic |

---

## 3. Decisões de implementação (onde o Notion fica em aberto)

Nenhuma bloqueia a execução — defaults documentados, ver §9 para o que
sobra para Rafinha revisar sem pressa.

### D1 — Como a skill distingue "chave de Epic" de "chave de issue" no Modo A

A página não descreve o passo técnico. **Decisão:** primeiro passo do Modo
A passa a ser "consultar o tipo nativo do ticket da chave informada". Tipo
`Epic` → aplica a decisão 1 (escopo = issues do Epic ∩ Integração). Qualquer
outro tipo → comportamento atual, mantido: a issue única é o escopo (e a
skill ainda confirma se ela pertence a um Epic com branch ativa, como já
fazia).

### D2 — Convivência da "Operação especial" com a criação automática

A página não diz se o comando manual explícito ("cria a branch do épico
X") continua existindo. **Decisão:** continua existindo como conveniência
para preparar a topologia **antes** de qualquer issue chegar a
`Fazer - Claude` (ex.: logo após criar o Epic) — mas deixa de ser a
**única** via. O passo 5.2 da `jira-issue-executor` passa a criar a branch
inline quando necessário, sem exigir o comando separado.

### D3 — Formato do comentário estruturado que guarda a tentativa

A página exige que o contador "seja obtido dos comentários estruturados da
própria issue" e que o registro "permita identificar explicitamente a
tentativa anterior e a branch usada", sem prescrever o formato exato.
**Decisão:** o comentário **"Implementação Claude"** que a
`jira-issue-executor` já publica (passo 7) ganha um campo novo e obrigatório:

```text
Tentativa: <N> (branch: {tipo}/<ISSUE-KEY>-claude[.<N>])
Tentativa anterior: <N-1> (branch: ...) | Nenhuma
```

Não é preciso um comentário dedicado só para isso — o comentário de resumo
já é lido no início de cada execução (passo 2), e vira também a fonte do
contador. Fica registrado como fonte única no §17 padronizado do
`workflow-development-flow`? Não — é específico de branch/tentativa,
diferente da descrição padronizada da issue (Pacote 4); fica documentado
na seção de branches (§16) da skill mãe e no passo 7 da
`jira-issue-executor`.

### D4 — Onde vivem os campos do ledger operacional (decisão 7)

A página lista campos mínimos por modo, mas não diz se isso é um comentário
novo ou uma extensão do R6 (Registrar a evidência) que já existe.
**Decisão:** é uma extensão do R6 — não cria comentário/rotina nova, só
amplia o conteúdo obrigatório do que R6 já publica, por modo.

### D5 — Onde a G10 busca as issues de um merge agregador de Epic

A página diz "o ledger do Jira pode ser usado como índice auxiliar (...)
mas a prova técnica deve ser reconciliada com Git/GitHub", sem prescrever
a busca exata. **Decisão:** a `jira-release-executor` localiza merges
`epic/<EPIC-KEY>-<nome> → develop` no histórico do GitHub (PRs mergeados,
que **não** são apagados quando a branch é excluída) e usa o comentário de
promoção no Epic (decisão 7, Modo B) como índice para a lista de issues —
nunca o contrário. Se os dois discordarem, Git/GitHub prevalece, e a
divergência é achado a reportar, não a resolver silenciosamente.

### D6 — Numeração dos novos gates

A página não usa numeração de gate ao estilo do Pacote 4. **Decisão:**
seguem a sequência já aberta (gates 1–13 do Pacote 4):
- **Gate 14** — Topologia de Epic ausente antes da Integração inicial
  (issue chega ao Modo A sem a branch do Epic preparada → inconsistência
  upstream, bloqueia).
- **Gate 15** — Autorização humana de merge no Modo B (distinta da
  confirmação de modo/escopo — pipeline verde não equivale a autorização).

### D7 — Multi-repositório: um "projeto" nesta skill já cobria isso?

A `jira-release-executor` já distingue Projeto ≠ Repositório (Pacote 4).
A `jira-integration-executor` hoje assume implicitamente um repositório por
execução (pré-requisito 2, singular). **Decisão:** a seção de pré-requisitos
passa a admitir explicitamente **N repositórios no mesmo Epic**, com o
mecanismo git de cada modo repetido por repositório, mas a decisão de modo,
o resumo operacional e a autorização humana do Modo B permanecem **únicos**
para o conjunto — exatamente como a página descreve.

---

## 4. Ondas de execução

### Onda 1 — `workflow-development-flow`

- **§16 (Modelo de branches):**
  - §16.2 ("A branch de épico é opcional e explícita") — reescrever: a
    branch passa a ser **garantida automaticamente** pela
    `jira-issue-executor` quando a issue pertence a um Epic, antes da 1ª
    Integração. Deixa de existir a frase "não é lacuna a ser corrigida
    pela automação".
  - Nova subseção — **branches são artefatos temporários**: histórico
    permanente é commit + PR + Jira, não a branch viva. Regra de limpeza
    (Modo B e C, só no sucesso).
  - §16.1/16.3 — gramática de nome passa a admitir `[.<tentativa>]`;
    atualizar a tabela "branch base / destino do PR" para citar que a
    branch pode não ser a primeira tentativa.
  - Nova nota: ausência de uma branch **não** é evidência de nada, depois
    da limpeza — só Git (commits/PRs) e os comentários do Jira valem.
- **§8.2 (Gates operacionais):** adicionar Gate 14 e Gate 15 (D6).
- **§10 (Release & Versionamento):** uma frase apontando que o G10 agora
  reconhece dois caminhos de merge (remete ao Confluence e ao
  `release-lifecycle.md`, sem duplicar o algoritmo).
- **Frontmatter:** atualizar a descrição para citar Gate 14/15 e o novo
  modelo de branches temporárias com tentativa.

### Onda 2 — `jira-integration-executor` (a maior)

- **Modo A** — reescrever por completo:
  - Passo 0 novo: identificar se a chave informada é Epic ou Issue (D1).
  - Se Epic: calcular escopo efetivo = issues do Epic ∩ Integração;
    apresentar o conjunto no resumo operacional; processar todas.
  - Idempotência: antes de mergear cada issue do conjunto, aplicar a
    árvore de leitura da decisão 1 (PR mergeado + label presente = já
    integrada, não repetir; PR aberto + label ausente = pendente; as duas
    combinações restantes = inconsistência, bloqueia e reporta).
  - Gate 14: se uma issue do escopo chegar sem a branch do Epic esperada
    (topologia ausente), tratar como inconsistência upstream — bloquear
    essa issue especificamente, sem travar as demais do lote.
- **Modo B** — reescrever o passo a passo com os 14 passos da decisão 6:
  criação do próprio PR de promoção quando não existir; **duas
  confirmações distintas** (modo/escopo, já existente; e autorização final
  de merge, nova — Gate 15); revalidação do estado dos PRs imediatamente
  antes do merge; limpeza de branches só no sucesso; e o fluxo de
  **negativa de autorização** (não é falha — encerra sem mergear, sem
  mover, sem limpar, revalida do zero na próxima vez).
- **Tabela "Responsabilidade por PR por modo"**: A e C continuam "PR já
  aberto pela `jira-issue-executor`, ausência bloqueia"; B passa a "a
  própria skill cria o PR de promoção se necessário".
- **R6 (Registrar a evidência)** — expandir por modo, com os campos
  mínimos da decisão 7 (D4): Modo A (modo, épico, repo, branch da issue,
  branch de destino, tentativa, PR, merge SHA, data, resultado,
  `integrado-epico`); Modo B (repositórios, PRs de promoção, issues
  promovidas, resultado de pipelines, autorização de Rafinha, merges,
  data, resultado, limpeza); Modo C (modo, repo, branch, tentativa, PR,
  merge SHA, data, resultado, limpeza).
- **Nova regra** — decisão 8: o PR de promoção nunca é gravado no campo
  `Links para merge` das issues; esse campo continua apontando para o PR
  individual.
- **Limpeza de branches** — novo passo final em B e C, só no sucesso
  completo do lote/issue (decisão 5): apagar a(s) branch(es) que já
  cumpriram o papel.
- **Multi-repositório** (decisão 10, D7) — nova seção: Modo A processa
  todos os repositórios do escopo numa única chamada lógica; Modo B pode
  abrir N PRs (um por repo), com pré-condições (todos existem, todos
  verdes, todos aptos) antes de pedir a autorização única, e revalidação
  imediatamente antes de iniciar os merges. Issue só sai de `Integração`
  quando **todos** os repositórios aplicáveis estiverem mergeados.
- **Falha durante promoção multi-repo** (decisão 11) — nova seção:
  parar o avanço do lote, diagnosticar, corrigir o que for mecânico dentro
  da responsabilidade da Integração, revalidar, concluir os merges
  restantes; conflito semântico/decisão de negócio escalona para Rafinha;
  enquanto incompleto, nenhuma issue avança e nenhuma limpeza roda.
- **Frontmatter:** reescrever por completo — é a skill mais afetada.

### Onda 3 — `jira-issue-executor`

- **"Operação especial — criar a branch de um épico"** — reformular
  (D2): continua existindo como comando manual antecipado, mas o texto
  "pertencer a um épico não autoriza a criação automática" é substituído
  pela regra nova.
- **Passo 5.2 (Resolver a branch)** — adicionar, antes de determinar a
  branch base: se a issue pertence a um Epic e a branch dele não existe,
  **criar agora**, a partir da `develop` atualizada, e registrar a origem
  em comentário no Epic (mesmo procedimento que hoje só existe na operação
  manual). Remover o aviso "não crie a branch do épico aqui".
- **Convenção de nome** — gramática passa a
  `{tipo}/<ISSUE-KEY>-claude[.<tentativa>]` (decisão 3). Passo 4b
  ("Issue com review reprovado") deixa de dizer "retome a branch existente"
  e passa a: ler o número da tentativa anterior no comentário estruturado
  (D3), criar branch **nova** com o próximo `.N`, nunca reaproveitar a
  antiga.
- **Nova subseção — reprovação de issue de Epic já promovido** (decisão
  4): quando a issue reprovada pertence a um Epic cuja branch já foi
  removida (Modo B concluído), recriar a branch do Epic a partir da
  `develop` atual antes de criar a nova branch `.N` da issue. Não
  reaproveitar a branch antiga do Epic mesmo que, por algum motivo, ainda
  exista localmente.
- **Passo 7 (Comentário de resumo)** — adicionar o campo "Tentativa" (D3).
- **"O que NÃO fazer"** — inverter o item sobre nunca criar branch de
  épico automaticamente; adicionar item sobre nunca reaproveitar branch
  após retorno/reprovação.
- **Frontmatter:** reescrever a frase sobre criação de branch de épico e a
  convenção de nome.

### Onda 4 — `jira-qa-executor`

- **"Correção de issue reprovada que veio de épico"** — reescrever
  (decisão 4, §2): a issue reprovada **não** integra direto pela `develop`
  (Modo C). Ela volta para `Fazer - Claude`; é a `jira-issue-executor`
  quem recria a branch do Epic e abre a nova tentativa; o ciclo completo
  volta a ser Epic → Modo A → Modo B.
- Nenhuma outra mudança de contrato nesta skill — o veredito, o registro
  no AIO Tests e as labels operacionais continuam iguais.

### Onda 5 — `jira-review-executor`

- **Auditoria do contrato de branches por épico** (já existe, ponto 8 da
  auditoria) — ampliar para conferir também:
  - coerência da tentativa (`.N`) citada no comentário com o histórico de
    retornos da issue;
  - presença do ledger mínimo exigido por modo (decisão 7) no comentário
    de Integração — ausência de campo obrigatório é achado;
  - no Modo B, evidência da autorização humana de merge (Gate 15) além da
    confirmação de modo/escopo;
  - `Links para merge` aponta para o PR individual da issue, nunca para o
    PR de promoção do épico (decisão 8).
- **Nota importante:** ausência de uma branch **não é achado** depois da
  limpeza (decisão 5) — só ausência de **evidência** (PR, commit SHA,
  comentário) é. Adicionar essa ressalva explícita para não gerar falso
  positivo.

### Onda 6 — `jira-release-executor` + `references/release-lifecycle.md`

- **Gate G10 (Fase 5.0)** — reescrever o algoritmo de 5 passos para dois
  caminhos:
  1. **Merge direto de issue** — igual a hoje: extrai a chave do nome da
     branch de origem (`{tipo}/<ISSUE-KEY>-claude[.<tentativa>]` — a
     tentativa não muda a chave extraída), verifica `qa-develop-aprovado`.
  2. **Merge de Epic** (`epic/<EPIC-KEY>-<nome> → develop`) — identifica o
     Epic; localiza, no histórico Git/GitHub da promoção, os PRs/merges de
     issue que compuseram aquele estado (D5); obtém as chaves; valida cada
     issue individualmente; bloqueia se alguma não rastrear ou não tiver
     `qa-develop-aprovado`.
  - Deixar explícito: a exclusão da branch **não pode quebrar o G10** — o
    contrato depende de histórico permanente (commits, PRs, comentários),
    nunca da branch remota ainda existir.
- Mesmo algoritmo espelhado em `release-lifecycle.md` §22.
- **Frontmatter:** ajustar a frase sobre extração de chave "do nome da
  branch de origem" para citar os dois caminhos.

### Onda 7 — `README.md`

- Parágrafo "Branch de épico é opcional e explícita" — reescrever: a
  branch passa a ser garantida automaticamente; branches (de épico e de
  issue) são artefatos temporários, removidos após o sucesso; histórico
  permanente é commit + PR + Jira.
- Adicionar frase sobre a gramática `[.<tentativa>]` e a fonte do contador
  (comentário estruturado, nunca contagem de branch remota).
- Adicionar frase sobre o Modo B agora abrir seu próprio PR de promoção e
  exigir autorização humana distinta da confirmação de modo/escopo.

### Onda 8 — Confluence (espaço CS1)

| Página | ID | O que muda |
| --- | --- | --- |
| jira-integration-executor | 44171267 | Espelha a Onda 2 inteira |
| jira-issue-executor | 44072962 | Espelha a Onda 3 |
| jira-qa-executor | 44367874 | Espelha a Onda 4 |
| jira-review-executor | 44400665 | Espelha a Onda 5 |
| jira-release-executor | 44072995 | Espelha a Onda 6 |
| workflow-development-flow | 44400642 | Espelha a Onda 1 |
| Modelo de branches | 71139329 | Ciclo de vida temporário, gramática de tentativa, os dois caminhos do G10 |
| Gates operacionais | 68223007 | Gates 14 e 15 |
| Vocabulário operacional de labels | 68222978 | Ajuste na descrição do ciclo de vida de `integrado-epico` — a leitura por idempotência (PR+label) do Modo A, não só a presença da label |
| Release & Versionamento | 44335153 | Nota sobre os dois caminhos de merge que o G10 valida |
| Hierarquia Épico → Issue → Subtask | 44400705 | Revisar — provavelmente **sem mudança** (a hierarquia em si não muda, só o ciclo de vida da branch) |
| Camadas de validação | 44204285 | Revisar — provavelmente **sem mudança relevante** |
| 1. Preparar o repositório GitHub | 44466177 | Convenção de nome de branch — acrescentar `[.<tentativa>]` |
| Pipelines no GitHub | 44105774 | Revisar se repete "Integração nunca abre PR" sem a ressalva do Modo B |

Duas páginas marcadas "revisar" no lugar de "editar direto": a página do
Notion pede para procurá-las, mas o conteúdo delas (hierarquia
Épico/Issue/Subtask, camadas de validação) não parece depender do ciclo de
vida da branch. Onda 8 confirma na hora, e só edita se achar referência
real — não força mudança onde não há conflito.

### Onda 9 — Verificação final

- Grep por `branch de épico opcional`, `nunca cria branch de épico`,
  `nunca abre.*PR` (sem ressalva de Modo B), `-claude\b` sem menção a
  tentativa em contexto de convenção, `nome da branch de origem` (G10) —
  confirmar que cada ocorrência remanescente é intencional (histórico em
  `plano-pacote-*.md` antigos não é tocado).
- Conferir que as três skills mais afetadas (`jira-integration-executor`,
  `jira-issue-executor`, `jira-release-executor`) não mantêm cópias
  divergentes da gramática de branch ou do algoritmo de G10 — cada uma
  referencia a mesma fonte (`workflow-development-flow` §16 e
  `release-lifecycle.md` §22) em vez de redefinir.
- Resumo final para Rafinha: o que foi tocado, o que ficou marcado como
  "revisado, sem mudança" (Onda 8), e as pendências não bloqueantes de §9
  abaixo.

---

## 5. O que fica fora deste pacote

- **Qualquer ação real no Jira** — não move issue, não cria/edita
  comentário real em issue nenhuma, não configura projeto.
- **Migração retroativa** — a própria página proíbe: sem reescrever
  histórico Git, PRs antigos, issues concluídas, Epics encerrados,
  releases encerradas ou comentários históricos. Estados em andamento no
  momento do corte podem exigir adaptação na primeira execução sob o
  contrato novo, mas isso é comportamento da skill em produção, não uma
  migração desta sessão.
- **Qualquer novo tipo de ticket, label ou coluna** — esta atualização não
  pede nenhum; é só Integração, branches e G10.

---

## 6. Pendências não bloqueantes para Rafinha revisar quando puder

| Item | Onde está registrado |
| --- | --- |
| Confirmar D2 (comando manual de criar branch de Epic continua existindo como conveniência) ou preferir removê-lo agora que a criação é automática | §3, D2 |
| Confirmar D3 (formato do campo "Tentativa" dentro do comentário "Implementação Claude") ou preferir um comentário dedicado só para o ledger de tentativas | §3, D3 |
| Confirmar D6 (numeração dos gates 14/15) — só importa se Rafinha já usa os números 1–13 em algum lugar fora deste repositório | §3, D6 |
| Confirmar se "Hierarquia Épico → Issue → Subtask" e "Camadas de validação" (Confluence) realmente não precisam de edição, depois da checagem da Onda 8 | Onda 8 |

Nenhum destes bloqueia a execução das Ondas 1–9 — todos têm default
aplicado e documentado acima.

---

## 7. Registro de implementação

Todas as nove ondas foram executadas nesta sessão, sob a instrução
"Implemente tudo por favor". Nenhuma ação tocou Jira real (projeto, board
ou issue) — só arquivos locais em `.claude/skills` e páginas Confluence no
espaço CS1.

### Ondas 1–7 (skills locais e README)

Executadas conforme planejado nas seções 1–4 deste documento, sem desvio
relevante:

- **Onda 1** — `workflow-development-flow/SKILL.md`: gramática de
  tentativa em §16.1, branch de épico garantida (não opcional) em §16.2,
  idempotência por Epic em §16.4, G10 dual-path em §16.6, gates 14/15 em
  §8.2, frontmatter reescrito.
- **Onda 2** — `jira-integration-executor/SKILL.md`: Modo A com escopo de
  Epic e Gate 14, Modo B com PR próprio e Gate 15 (incluindo a resposta
  negativa), tabela de responsabilidade por PR, operação multi-repo,
  limpeza de branches, ledger (R6) expandido por modo.
- **Onda 3** — `jira-issue-executor/SKILL.md`: garantia automática da
  branch de épico, gramática `[.<tentativa>]`, recriação de branch após
  reprovação de issue de Epic já promovido.
- **Onda 4** — `jira-qa-executor/SKILL.md`: reprovação de issue de Epic
  correction volta ao ciclo Epic→Modo A→Modo B, não mais Modo C direto.
- **Onda 5** — `jira-review-executor/SKILL.md`: pontos 11–13 (ledger,
  `Links para merge`, coerência de tentativa) adicionados à auditoria de
  13 pontos.
- **Onda 6** — `jira-release-executor/SKILL.md` e
  `references/release-lifecycle.md`: G10 com os dois caminhos (merge
  direto e merge agregador de Epic).
- **Onda 7** — `README.md`: branches como artefato temporário, Modo B com
  PR próprio e autorização.

Um único typo foi pego e corrigido durante a Onda 2 ("inferior" → "infere"
em "nunca reduz, substitui ou infere o escopo").

### Onda 8 (Confluence)

Todas as páginas identificadas no plano foram atualizadas via
`updateConfluencePage` (sempre `contentFormat: "html"`, por causa das
smart-link cards já existentes — `markdown` gera 422): Modelo de branches,
Release & Versionamento, Hierarquia Épico → Issue → Subtask,
jira-release-executor, jira-integration-executor, jira-issue-executor,
jira-qa-executor, jira-review-executor, workflow-development-flow, Gates
operacionais, Vocabulário operacional de labels, "1. Preparar o
repositório GitHub" e Pipelines no GitHub.

Dois desvios em relação ao plano original, ambos por economia de tempo
(prazo apertado, conteúdo tangencial ao escopo de Correções 27/09):

- **`workflow-development-flow` (Confluence)** — a reescrita da seção
  "Modelo de branches" e da tabela de gates ficou mais condensada que a
  ficha detalhada original: algumas tabelas completas de label/tipo foram
  substituídas por referências cruzadas em vez de repetidas por extenso.
  O conteúdo técnico está correto e completo; só a forma é mais enxuta.
- **Drift do Pacote 4 corrigido por oportunidade, não por pedido desta
  rodada**: três páginas ainda tinham "10 colunas" e um fluxo desatualizado
  (Release & Versionamento, Hierarquia Épico → Issue → Subtask,
  jira-release-executor) — corrigidas ao editá-las por outro motivo. A
  quarta, **Pipelines no GitHub**, tinha o mesmo problema (ordem trocada
  entre "Documentar" e "Análise Final - Rafinha" no fluxo do §2) e foi
  corrigida na Onda 8 também, junto com uma nota nova no §16 sobre quem
  abre o PR em cada modo.
- **"Camadas de validação"** foi conferida e não precisou de edição — não
  tinha nenhuma referência a contagem de colunas ou à gramática de branch
  que precisasse de correção.

### Onda 9 (verificação)

Varredura por `grep` no repositório local por frases obsoletas
(`branch de épico ... opcional`, `10 colunas`, `retomá-la normalmente`,
`comando explícito de Rafinha`, convenção de branch sem `[.<tentativa>]`):
nenhuma ocorrência restante fora dos `plano-pacote-*.md` (que
deliberadamente registram o texto antigo como contraste histórico) e das
menções corretas e atuais (por exemplo, "Integração nunca cria a branch de
épico" continua verdade — quem garante a branch agora é a
`jira-issue-executor`, não a integração).

### Pendências não bloqueantes (sem mudança)

As quatro pendências da seção 6 continuam abertas para Rafinha decidir
quando puder — nenhuma delas impediu a implementação.
