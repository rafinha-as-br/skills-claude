# Plano de implementação — Pacote 3: Skills de documentação

Documento de planejamento e **registro de implementação**, no mesmo formato do
`plano-pacote-2.md`.

**Fonte do contrato:** página do Notion *"Atualização — Skills de
documentação"*, lida em 2026-09-23.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-23 | Versão inicial. D1 decidida por Rafinha. Onda 1 concluída |
| 2026-09-23 | **D3 decidida por Rafinha — Pendência 4 fechada.** Onda 2 concluída |
| 2026-09-24 | Onda 3 concluída |
| 2026-09-24 | **D5 e D6 decididas durante a implementação.** Onda 4 concluída |

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 1 | Higiene das skills atuais + rename | ✅ ver §3 |
| 2 | Taxonomia e templates em `references/` | ✅ ver §6 (mapa pendente) |
| 3 | Ampliação dos writers (product, tech, screen com modos) | ✅ ver §6.1 |
| 4 | Novas skills: `user-doc-writer`, `workflow-doc-writer` | ✅ ver §6.2 |
| 5 | Integração com o fluxo Jira (`jira-doc-executor`) | ⬜ |
| 6 | Componentes reutilizáveis e piloto | ⬜ |

---

## 1. Por que este pacote não sai numa passagem

O Pacote 2 tinha uma seção explícita de **"Pendências encerradas nesta
rodada"**. Este não tem: a página se declara `Status: Definição oficial em
construção`, com **quatro pendências abertas**.

Duas delas bloqueiam trabalho de verdade.

### Pendência 1 — nome das skills → **DECIDIDA**

Ver §2.

### Pendência 4 — fronteira módulo × tela × usuário → **FECHADA**

Ver D3 em §2. Era o único bloqueio real do pacote.

### Pendência 2 — destino de `qa-doc`

`qa-doc` segue como label válida sem writer. Não bloqueia nada; só não pode
ser delegada.

### Pendência 3 — quando criar a `workflow-doc-writer`

Antes da janela de migração (para já escrever as páginas novas) ou depois
(para manutenção recorrente). Decisão de sequenciamento, não de conteúdo.

---

## 2. Decisões de implementação

### D1 — Renomear as duas skills

**Decidida em 2026-09-23 por Rafinha.**

```text
business-rule-writer  →  product-doc-writer
module-doc-writer     →  tech-doc-writer
```

**Por que isso vinha primeiro:** o nome decide o nome do diretório, todas as
referências cruzadas entre skills, os títulos das fichas no Confluence e o
que a `jira-doc-executor` invoca. Tudo depois da Onda 1 dependia dessa
escolha.

**Consequência de sequenciamento:** a ordem sugerida no Notion coloca o
rename na Onda 3. Como a decisão foi fechada antes, o rename foi **dobrado
dentro da Onda 1** — fazer a higiene num arquivo que mudaria de nome depois
seria passar duas vezes no mesmo lugar.

### D2 — Nome-alvo com escopo declarado, não escopo inventado

**Decidida em 2026-09-23, durante a Onda 1.**

O rename criou um problema imediato: a skill passa a se chamar
`product-doc-writer`, mas só sabe escrever regra de negócio. O nome promete
mais do que o conteúdo entrega — que é exatamente o defeito que o rename
deveria corrigir, invertido.

**Decisão:** cada writer ganha uma seção **Escopo** declarando, em tabela, o
que já tem template e o que não tem.

| Skill | Implementado hoje | Pendente de template |
| --- | --- | --- |
| `product-doc-writer` | `rn-doc` | requisito, caso de uso, fluxo de produto, critérios de aceitação |
| `tech-doc-writer` | `module-doc` + pasta `docs/` | `api-doc`, `component-doc`, `readme`, `adr` |

E a regra que fecha o buraco:

> Se Rafinha pedir uma trilha sem template, a skill **diz que o template não
> existe** e pergunta se ele quer a estrutura implementada adaptada, ou
> prefere esperar. Nunca improvisa uma estrutura nova nem a apresenta como
> oficial.

**Motivo:** estrutura inventada vira precedente, e precedente inventado é
mais difícil de corrigir do que uma lacuna declarada. É o mesmo princípio do
gate "proibido fallback silencioso" do Pacote 1, aplicado a template em vez
de label.

### D3 — Documentar é job composto, não escolha de página

**Decidida em 2026-09-23 por Rafinha.** Fecha a Pendência 4.

Eu tinha formulado a pendência como *"qual das quatro páginas este pedido
vira?"* — uma escolha excludente. **A formulação estava errada.**

> Quando se pede para documentar uma tela, o agente aciona **o conjunto** de
> skills. Documentar uma tela é um trabalho composto, e cada skill faz a
> sua parte.

**O que isso resolve.** O roteamento deixa de ser uma decisão: não existe
"qual writer", existe "quais writers, e o que cabe a cada um".

**O que eu tinha calculado errado.** Eu temia uma explosão de páginas — 30
telas × 4 páginas. Não acontece, porque **as granularidades são
diferentes**:

| Skill | Uma página por... |
| --- | --- |
| `tech-doc-writer` | **módulo** |
| `screen-doc-writer` | **tela** (modo dev, user ou híbrido) |
| `user-doc-writer` | **tarefa de usuário**, que atravessa telas |

Documentar uma tela nova **atualiza** a página do módulo que já existe e
**entra** no guia que já existe, enquanto cria ou atualiza a página dela
própria. O fan-out real é pequeno.

Isso também responde à dúvida de fronteira que restava: tarefa que atravessa
telas → guia; tarefa que mora numa tela só → a própria página de tela em
modo `user`.

**A regra anti-duplicação**, derivada do princípio que a própria página do
Notion declara (*"uma skill por fonte da verdade"*):

| Skill | Fonte da verdade | Escreve |
| --- | --- | --- |
| `tech-doc-writer` | o código | arquitetura do módulo, camadas, como as telas se encaixam nele |
| `screen-doc:dev` | a tela rodando + o código dela | rota, cubit, chamadas de API **daquela tela** |
| `screen-doc:user` | a tela rodando | campos, botões, mensagens, erros visíveis |
| `user-doc-writer` | o produto funcionando | a tarefa ponta a ponta |

```text
Cada writer escreve só o que a sua fonte da verdade entrega,
e linka em vez de repetir.
```

Exemplo do desempate: *"qual cubit gerencia esta tela"* é `screen-doc:dev`.
A página de módulo diz quais cubits existem no módulo; não detalha cada tela.

**Consequência de peso.** Isso desloca trabalho para a
`jira-doc-executor`: ela deixa de ser "label → writer" e passa a montar um
**conjunto de delegações por job**, decidindo quais das skills se aplicam e
declarando quais pulou e por quê — mesmo princípio do proibido fallback
silencioso. **A Onda 5 fica maior do que a página do Notion previa.**

### D5 — `user-doc-writer` não navega a UI; lê o que a `screen-doc-writer` já publicou

**Decidida em 2026-09-24, durante a Onda 4.**

A página do Notion declara a fonte da verdade do `user-doc-writer` como "o
produto funcionando" — o mesmo termo usado para a `screen-doc-writer`, que
navega a UI ao vivo via Claude in Chrome. Ela não diz, no entanto, **como**
o `user-doc-writer` deveria confirmar esse "produto funcionando": navegando
ele mesmo, ou se apoiando no que outra skill já observou.

**Decisão:** o `user-doc-writer` não replica a navegação ao vivo. Ele lê as
páginas `screen-doc:user` já publicadas (a fonte primária de campo/botão/
mensagem) e linka em vez de repetir; quando uma tela envolvida não tem
página publicada, isso é uma **dependência a declarar**, não algo para
observar por conta própria.

**Motivo:** navegar de novo seria duplicar um trabalho que a
`screen-doc-writer` já faz — a UI já foi observada por quem tem esse
trabalho. É a mesma regra "linka em vez de repetir" da D3, aplicada à fonte
primária em vez de ao conteúdo final. Duplicar a máquina de pré-requisitos
inteira da `screen-doc-writer` (Chrome, ambiente local, estado limpo) numa
segunda skill também violaria a lógica de "uma skill por fonte da verdade" —
a fonte primária de UI é uma só.

**Consequência prática:** se Rafinha pedir um guia para uma tarefa cujas
telas ainda não têm doc de tela publicada, a ordem natural do trabalho
composto é a `screen-doc-writer` rodar primeiro. O `user-doc-writer` declara
essa dependência em vez de decidir sozinho qual vem primeiro.

### D6 — mapeamento dos três templates da `workflow-doc-writer`, e quem vence no drift

**Decidida em 2026-09-24, durante a Onda 4.**

A página do Notion prevê só três templates (`workflow-page.md`,
`skill-page.md`, `release-doc.md`) para uma lista maior de páginas a cobrir:
ficha de skill, página de fluxo, página de labels, página de tipos de
ticket, controle por produto, CI/CD, release. Coube à implementação decidir
o mapeamento — sem inventar um quarto template.

**Decisão:**
| O que a página documenta | Template |
| --- | --- |
| Uma skill específica | `skill-page.md` |
| Uma distribuição específica (release) | `release-doc.md` |
| Tudo o mais sobre o pipeline em si (branches, gates, hierarquia, labels, tipos de ticket, controle por produto, CI/CD) | `workflow-page.md` |

`workflow-page.md` é deliberadamente um template guarda-chuva com seções
livres (mesma lógica do `modulo.md` da `tech-doc-writer`) — os assuntos que
ele cobre são estruturalmente diferentes entre si (uma tabela de labels e
uma lista de gates não têm a mesma forma), e forçar uma estrutura fixa
comum produziria seções vazias com mais frequência do que conteúdo real.

**Segunda decisão, sobre a checagem de drift** (papel que o Notion atribuiu
à `workflow-doc-writer`, mas não detalhou): quando o `SKILL.md` real e a
ficha do Confluence divergem, **o `SKILL.md` vence sempre**, e a correção da
ficha não passa por `doc-pendency-resolver` — não é uma incerteza da skill,
é um fato verificável por leitura direta do arquivo. `doc-pendency-resolver`
só entra quando o próprio `SKILL.md` for ambíguo o bastante para não dar
para determinar o comportamento real. **Motivo:** o `SKILL.md` é o que
executa; a ficha só documenta. Perguntar "qual dos dois está certo" toda vez
que os dois divergem tornaria a checagem de drift inútil na prática — o
propósito dela é justamente parar de depender de alguém notar a divergência
manualmente.

---

## 3. Registro — Onda 1

**Concluída em 2026-09-23.**

### O que foi feito

| Item | Onde |
| --- | --- |
| **Rename** | `git mv` nos dois diretórios, `name:` no frontmatter, e todas as referências cruzadas em 8 arquivos |
| **Frontmatter duplicado** | Removido em `tech-doc-writer` e `doc-pendency-resolver` (o de `product-doc-writer` já tinha saído) |
| **"Rafael" → "Rafinha"** | 16 ocorrências no `product-doc-writer`, 2 no `tech-doc-writer`, 2 no `doc-pendency-resolver` |
| **Multi-produto** | 4 pontos do `tech-doc-writer` que assumiam GeoPrag |
| **`doc-pendency-resolver`** | Passa a listar as três writers em tabela, incluindo a `screen-doc-writer`, que não era citada |
| **Seção Escopo** | Nova nos dois writers renomeados (D2) |

### A generalização multi-produto era pior do que parecia

A `module-doc-writer` não só citava o GeoPrag como exemplo — ela mandava
"olhar 1-2 páginas já existentes **no espaço Geoprag**" para manter
consistência de tom. Rodando no Compass System, a skill importaria a
convenção do produto errado.

O texto agora manda olhar o espaço **daquele produto**, e diz explicitamente
que convenção de um produto não se importa para outro sem confirmar.

### `Rafael` ficou de fora em duas skills

`task-creator-trabalho` (11 ocorrências) e `weekly-organizer` (8) também
escrevem "Rafael". **Não foram tocadas**: a página do Notion cita o
`business-rule-writer` nominalmente, e essas duas não são skills de
documentação do workflow — são pessoais, de outro contexto. Se o "Rafinha"
for para valer em todo lugar, é uma decisão à parte.

### O que a Onda 1 deliberadamente NÃO fez

- Não ampliou o escopo de writer nenhum. Isso é Onda 3 e depende dos
  templates da Onda 2.
- Não tocou na `screen-doc-writer` além do rename das referências. Os modos
  `screen-doc:user` / `:dev` / `:hybrid` são Onda 3.
- Não criou skill nova. Onda 4, bloqueada pela Pendência 4.
- Não atualizou o Confluence. As fichas `business-rule-writer` e
  `module-doc-writer` ficaram com o nome antigo — ver §4.

---

## 4. Pendência imediata criada por esta onda

O rename deixou **onze páginas do Confluence** com os nomes antigos.
Levantado por CQL em 2026-09-23 — a estimativa inicial deste documento dizia
"duas fichas mais o índice", e estava errada.

**Fichas que precisam mudar de título e de conteúdo:**

| Página | ID |
| --- | --- |
| `business-rule-writer` | 44433409 |
| `module-doc-writer` | 44302341 |

**Páginas que só citam os nomes:**

| Página | ID |
| --- | --- |
| Skills (índice) | 44105730 |
| Claude Skills (home do espaço) | 44204199 |
| jira-doc-executor | 44204245 |
| screen-doc-writer | 44204265 |
| doc-pendency-resolver | 44138502 |
| jira-issue-executor | 44072962 |
| Visão geral do fluxo | 44302381 |
| Vocabulário operacional de labels | 68222978 |
| Gates operacionais | 68223007 |

Isso é drift criado por mim nesta onda, não drift herdado. Precisa ser
resolvido antes do corte de vigência do Pacote 3 — ou na Onda 2, ou numa
passada dedicada de Confluence.

---

## 5. Fora do escopo deste pacote

- Renomear "Rafael" nas skills pessoais (`task-creator-trabalho`,
  `weekly-organizer`).
- Definir destino de `qa-doc` (Pendência 2 da página de origem).

---

## 6. Registro — Onda 2

**Concluída em 2026-09-23**, exceto o mapa de taxonomia (ver §7).

### 12 templates, não 16

Os quatro restantes — `user-guide.md`, `workflow-page.md`, `skill-page.md` e
`release-doc.md` — pertencem a skills que **ainda não existem**. Criá-los
agora deixaria arquivo órfão em `references/` de skill nenhuma.

Eles nascem na Onda 4, junto com a `user-doc-writer` e a
`workflow-doc-writer`.

| Writer | Templates |
| --- | --- |
| `product-doc-writer` | `rn.md`, `requisito.md`, `caso-de-uso.md`, `fluxo-produto.md`, `criterios-aceitacao.md` |
| `tech-doc-writer` | `modulo.md`, `api.md`, `arquitetura-dev.md`, `componente-reutilizavel.md` |
| `screen-doc-writer` | `screen-dev.md`, `screen-user.md`, `screen-hybrid.md` |

### A seção que faz o modelo composto funcionar

Todo template termina com uma tabela **"O que NÃO vai nesta página"**,
apontando conteúdo por conteúdo para a skill dona.

Sem ela, o modelo da D3 não fecha: se as quatro skills rodam juntas no mesmo
job, e nenhuma sabe o que não é dela, todas escrevem tudo. A tabela é a
aplicação prática de *"uma skill por fonte da verdade"*.

Exemplo, do `modulo.md`:

> A página de módulo diz **quais cubits existem no módulo**; ela não detalha
> qual cubit gerencia cada tela. Isso é doc de tela.

### Modos da `screen-doc-writer`

Os três modos entraram nesta onda junto com os templates — separar "criar o
template" de "ligar a skill ao template" deixaria a skill num meio-termo
inútil.

Regra de desempate registrada:

> **Na dúvida, `hybrid`.** Duas páginas que ninguém mantém são piores que uma
> que serve a dois leitores. Separar depois é barato; reconciliar duas páginas
> que divergiram não é.

E o modo **nunca é inferido do nome da tela** — mesmo princípio do modo de
integração do Pacote 2.

### Uma lacuna da página de origem, declarada e não preenchida

As labels **`readme` e `adr`** existem na matriz oficial de labels, mas
**ficaram de fora da lista de 16 templates** da atualização. Não são
esquecimento meu.

Registrei as duas na tabela de escopo da `tech-doc-writer` marcadas como
**sem template**, com a instrução de declarar a lacuna e perguntar. Preencher
por conta própria seria inventar estrutura — exatamente o que a D2 proíbe.

---

## 6.1. Registro — Onda 3

**Concluída em 2026-09-24.**

### O problema que esta onda resolveu

Onda 2 criou os 12 templates e declarou os três modos da `screen-doc-writer`,
mas **não conectou nenhum dos dois às skills que de fato escrevem**. O
`SKILL.md` de cada writer continuava com o "Passo a passo" apontando para a
trilha original (RN / módulo / a estrutura única de 7 seções de tela),
porque foi escrito antes de a Onda 2 existir. Templates prontos sem skill
que os carregue são documentação morta — a ampliação real é ligar os dois.

### `product-doc-writer`

O passo "Escrever a página" estava hardcoded nas quatro seções da RN. Agora
o passo 1 exige identificar a trilha (RN, requisito, caso de uso, fluxo de
produto, critérios de aceitação) e carregar o template correspondente antes
de escrever; o passo 3 segue a estrutura do template, não mais uma lista
fixa embutida no `SKILL.md`. A estrutura da RN foi **removida** do
`SKILL.md` e passou a viver só em `references/rn.md` — evita duas versões da
mesma verdade, mesmo princípio da tabela "o que NÃO vai nesta página".

### `tech-doc-writer`

Mesmo problema, ao contrário: o passo 2 ("Levantar as seções relevantes") é
o texto certo para módulo, mas **não existia ramificação** para API,
arquitetura-dev e componente — três trilhas com template fixo que a skill
ganhou na Onda 2 e nunca aprendeu a rotear. Passo 1 agora
identifica a trilha e, para as três com template, manda pular o passo 2
inteiro. O passo 9 (sincronizar `docs/` no código) também não deixava claro
que é exclusivo de módulo — README, ADR, API, arquitetura e componente não
têm pasta `docs/` correspondente.

### `screen-doc-writer` — a contradição mais séria da onda

Esta não era uma lacuna, era uma **contradição ativa**. A seção "Os três
modos" (Onda 2) mandava carregar o template do modo antes de escrever. O
"Passo a passo" (herdado da primeira versão da skill, anterior aos modos)
mandava escrever "estas 7 seções" incondicionalmente — sem perguntar o
modo, sem citar o template. Rodar a skill como estava no `master` teria
produzido a estrutura antiga de sempre, nunca uma das três novas.

Mais grave: a regra de tom antiga proibia "jargão técnico... nome de classe,
provider, rota de código, endpoint" **em qualquer página de tela**. Isso
contradiz o próprio `screen-dev.md`, cujas seções são exatamente rota,
estado (cubit/provider), chamadas de API e IDs de componente — é o conteúdo
que o modo `dev` existe para registrar.

Corrigido:
- Pré-requisito novo (1): confirmar o modo e carregar o template, antes de
  qualquer outra coisa — inclusive antes de abrir o Chrome.
- Passo "Escrever a página" reescrito para apontar ao template do modo, sem
  reproduzir seção nenhuma no `SKILL.md`.
- Regra de tom dividida por modo: `user` (e a metade de usuário do
  `hybrid`) proíbe jargão técnico; `dev` (e o bloco técnico do `hybrid`) o
  exige — é o oposto do que o texto antigo dizia.
- "Nota de origem" atualizada para deixar explícito que a estrutura de 7
  seções foi **substituída**, não que ainda é a estrutura de trabalho.

### O que isso ensina sobre a sequência do pacote

A Onda 2 pareceu completa porque os templates existiam e as descrições dos
três `SKILL.md` já citavam as trilhas novas. Mas descrição (frontmatter) e
comportamento (Passo a passo) são coisas diferentes, e só a segunda executa.
Nenhuma trilha nova esteve de fato utilizável até esta onda — vale registrar
para não repetir o padrão nas Ondas 4/5 (`user-doc-writer`,
`workflow-doc-writer`, `jira-doc-executor`): criar o template e citá-lo na
descrição não é o mesmo que ligá-lo ao passo a passo.

---

## 6.2. Registro — Onda 4

**Concluída em 2026-09-24.**

### `user-doc-writer`, skill nova

Uma trilha, um template (`references/user-guide.md`), granularidade tarefa
(D3). Ver D5 para a decisão de não navegar a UI diretamente. "Manual" e
"FAQ solta" — dois dos sete itens que o Notion listou como cobertura desta
skill — não viraram templates próprios; ficaram declarados em Escopo como
casos sem estrutura própria (manual é página-índice nativa do Confluence,
FAQ solta é candidata a pergunta via `doc-pendency-resolver`), seguindo D2.

### `workflow-doc-writer`, skill nova

Três templates (`skill-page.md`, `workflow-page.md`, `release-doc.md`) — ver
D6 para o mapeamento e para a regra de autoridade no drift. Esta é a única
skill de documentação cuja fonte da verdade primária é outro artefato do
próprio workflow (o `SKILL.md` de outra skill), não o produto sendo
construído — por isso ela ganhou uma etapa que nenhuma outra tem: checagem
de drift antes de escrever a ficha.

### `doc-pendency-resolver` e `README.md` atualizados

A tabela de skills anfitriãs do `doc-pendency-resolver` agora lista as
cinco — item que o Notion já previa em "Pontos de implementação já
identificados", mas que só podia ser feito depois que as duas skills
existissem. O `README.md` ganhou as duas linhas novas na tabela de
Documentação, e as descrições de `product-doc-writer`/`tech-doc-writer`/
`screen-doc-writer` ali foram corrigidas — ainda diziam "regra de negócio,
estrutura fixa" e "de um módulo", desatualizadas desde a Onda 2.

### Um drift que não é desta onda, mas foi corrigido de passagem

O banner "Estado do contrato" no topo do `README.md` ainda dizia que o
Pacote 2 estava `preparado` (não mergeado) e que "o merge desta branch é o
corte de vigência" — mas o Pacote 2 **já foi mergeado em `master`** antes
desta branch existir (commit `75c4a69`). Corrigido para refletir os dois
pacotes em vigência, sem afirmar que a configuração de CI/branch protection
manual (Fase 8 do Pacote 2) já rodou — isso continua sendo confirmado por
Rafinha, não assumido.

### O que a Onda 4 deliberadamente não fez

- Não tocou em `jira-doc-executor` — ela continua sem saber que as duas
  skills novas existem. É Onda 5, e a lição da Onda 3 vale de novo: criar a
  skill e citá-la em outro lugar não é o mesmo que ligá-la ao fluxo que a
  aciona.
- Não fechou a Pendência 3 do Notion (prioridade da `workflow-doc-writer`
  em relação à janela de migração) — a skill foi criada nesta onda porque é
  a ordem que o próprio Notion sugere ("Onda 4 — novas skills"), não porque
  a pendência foi resolvida.
- Não escreveu nenhuma página de Confluence com os templates novos — isso é
  trabalho de execução real (ex.: rodar `workflow-doc-writer` numa skill de
  verdade), não parte da implementação do pacote.

---

## 7. O que falta

| Item | Onda | Bloqueio |
| --- | --- | --- |
| Mapa tipo de página → página-mãe → convenção de título | 2 | nenhum — é trabalho de Confluence |
| `jira-doc-executor` como orquestradora de conjuntos (Trilhas A e B) | 5 | nenhum |
| Ligar `jira-release-executor` ao `release-doc.md` da `workflow-doc-writer` | 5 (ou avulso) | nenhum — descoberto na Onda 4, não estava no `plano-pacote-2.md` nem no Notion |
| Componentes reutilizáveis e piloto | 6 | nenhum — o template já existe |
| 11 páginas do Confluence com nome antigo (drift da Onda 1) | — | nenhum |
| Fichas novas no Confluence para `user-doc-writer` e `workflow-doc-writer` | — | nenhum |
| Corte de vigência (merge) | — | tudo acima |

A convenção de título de cada tipo de página **já está dentro do template**
— o mapa do Confluence passa a ser o índice disso, não a fonte.
