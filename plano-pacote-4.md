# Plano de implementação — Pacote 4: Revisão do workflow inteiro

Documento de planejamento e **registro de implementação**, no mesmo formato
dos `plano-pacote-2.md` e `plano-pacote-3.md`.

**Fonte do contrato:** página do Notion *"Atualização - Revisão do workflow
inteiro"*, lida em 2026-09-26 (única página ativa em "Rafinha Workflow" no
momento da leitura; as três anteriores — Design/labels/gates, Branches por
épico, Skills de documentação — já estão implementadas em `master` e não são
tocadas por este pacote, exceto onde esta página as substitui).

**Escopo desta rodada, por instrução explícita de Rafinha:** só Confluence e
skills. **Nada de Jira** — não configura board, não cria coluna, não move
issue, não altera projeto real. As páginas de Confluence que descrevem "como
montar um projeto novo" (passo a passo de setup) são atualizadas como
documentação de contrato-alvo, não como ação sobre um projeto existente.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-26 | Versão inicial. Plano criado |
| 2026-09-26 | Ondas 1–6 executadas de uma vez, a pedido de Rafinha. Pacote implementado por completo nas skills e no Confluence |

---

## 0. Status de implementação

| Onda | O quê | Status |
| --- | --- | --- |
| 1 | `workflow-development-flow` — fonte normativa (12 colunas, novo princípio de escopo, renumeração §5.1–5.12, gates 12/13, §17 descrição padronizada) | ✅ ver §7 |
| 2 | Skills existentes do pipeline de issues (creator, executor passivo + Gate de Pendência, e o gate de escopo nas 5 skills de varredura de coluna) | ✅ ver §7 |
| 3 | Três skills novas (`jira-sprint-intake-executor`, `jira-issue-decision-resolver`, `workflow-incident-capture-executor`) | ✅ ver §7 |
| 4 | `README.md` — índice, diagrama, contagens | ✅ ver §7 |
| 5 | Confluence — 16 páginas existentes atualizadas + 3 fichas novas criadas | ✅ ver §7 |
| 6 | Verificação final (grep de drift, cross-refs, resumo para Rafinha) | ✅ ver §7 |

---

## 1. Por que este pacote é grande numa passagem só

A página do Notion não tem pendências abertas nem "status: em construção" —
ao contrário do Pacote 3, ela se declara **decisão vigente**, sem ressalva.
Isso significa que não há bloqueio formal esperando resposta de Rafinha; o
tamanho vem do número de arquivos que a mudança realmente toca, não de
incerteza no conteúdo.

Três mudanças estruturais se propagam por quase todo o repositório:

1. **10 → 12 colunas**, com duas novas entrando *no meio* da lista
   (`Decisão - Rafinha` na posição 2, `Ready` na posição 4) — isso desloca a
   numeração interna de `workflow-development-flow` §5 inteira, e todo lugar
   que cita "seção 5.7", "5.9" etc. por número precisa ser conferido.
2. **Descrição padronizada da issue** (9 seções fixas) é um contrato novo que
   `jira-issue-creator` passa a produzir e `jira-issue-decision-resolver`
   passa a editar — precisa de UMA fonte única, não duas cópias divergentes.
3. **Princípio de escopo explícito** ("nenhuma skill executora roda às
   ciegas") é transversal a seis skills que hoje varrem coluna inteira sem
   confirmar escopo primeiro.

Nenhuma pendência encontrada é crítica a ponto de travar a operação — as
decisões que a página do Notion deixa implícitas (ver §2) têm default seguro
e ficam registradas, não bloqueiam a onda.

---

## 2. Decisões de implementação

Pontos que a página do Notion não fecha explicitamente. Nenhum bloqueia
operação — são defaults razoáveis, registrados para Rafinha corrigir se
quiser, sem esperar por essa correção para prosseguir.

### D1 — Quem move a issue de `Ready` para `Fazer - Claude`

A página não declara isso (diferente da transição `Design → Ready`, que é
explicitamente manual). **Decisão:** manual, por Rafinha — mesmo padrão já
usado em `Design de produto - Rafinha → Ready`. Nenhuma skill varre `Ready`
para empurrar issues adiante automaticamente. Se Rafinha quiser automatizar
isso depois (ex.: `jira-issue-executor` pegando direto de `Ready` quando
`Fazer - Claude` estiver vazia), é decisão nova, fora deste pacote.

### D2 — Gate defensivo de pendência em `Fazer - Claude`

A página diz que "`Fazer - Claude` não é lugar para fechar decisões de
produto, regra de negócio ou escopo" mas não pede um gate técnico que
verifique isso. **Decisão:** `jira-issue-executor` ganha um gate leve — antes
de implementar, olha a seção **Pendências de decisão** da descrição; se não
estiver vazia/"Nenhuma", **para e reporta**, em vez de implementar com
decisão pendente. É a mesma lógica do gate de Design (seção 3.1 hoje), agora
usando a descrição em vez de uma pasta local, e cobre o caso de uma issue ter
avançado para `Fazer - Claude` sem passar pela maturação esperada.

### D3 — Onde vive o "Princípio operacional" de escopo explícito

A página descreve a regra em prosa, sem dizer onde ela mora no contrato
formal. **Decisão:** entra como **novo princípio (11)** na seção 2
("Princípios do fluxo") de `workflow-development-flow` — é o lugar que já
concentra regras válidas "para todas as etapas, sem exceção". As seis skills
afetadas (§4, Onda 2) passam a referenciar esse princípio em vez de duplicar
o texto, mesmo padrão da tabela de roteamento documental (§3.3) e da Model
Escalation Policy (§11).

### D4 — Descrição padronizada da issue mora em `workflow-development-flow`

A página define a estrutura de 9 seções mas não diz onde ela é a fonte
única. **Decisão:** nova seção (17) em `workflow-development-flow`, pelo
mesmo motivo de D3 — evita que `jira-issue-creator` e
`jira-issue-decision-resolver` divirjam com o tempo sobre o formato exato.

### D5 — Renumeração de `workflow-development-flow` §5

Ver mapa completo em §3 abaixo. Decisão mecânica, não de conteúdo: os novos
itens entram nas posições que a própria página do Notion define (`Decisão -
Rafinha` logo após `A fazer`; `Ready` logo antes de `Fazer - Claude`), e todo
o resto desliza. Onda 1 inclui uma varredura de grep por `seção 5\.`, `§5\.`
e números isolados (`5.7`, `5.9`, etc.) antes de considerar a onda concluída
— renumeração manual tem histórico de deixar referência órfã (foi o próprio
erro que o Pacote 3 corrigiu de passagem na D6).

### D6 — `jira-contingency-executor` fica fora deste pacote

A página menciona "a decisão de contingência permanece válida" — mas essa
skill **não existe** no repositório hoje, e a própria página não a lista em
"Pendências de aplicação futura". É referência de contexto a uma decisão
anterior, não um pedido de criação. **Decisão:** não criar `jira-
contingency-executor` neste pacote. Se for pendência real, é pedido
separado.

### D7 — Model Policy das três skills novas

Nenhuma delas é "implementação" no sentido da tabela §11.6 existente.
**Decisão:** três linhas novas na tabela, todas Sonnet (nenhuma exige
raciocínio arquitetural por padrão):

| Tipo de atividade | Modelo | Effort |
| --- | --- | --- |
| Triagem e maturação de issue (intake) | Sonnet | Medium |
| Resolução de decisão em conversa (decision resolver) | Sonnet | Medium |
| Captura de incidente operacional | Sonnet | Medium |

### D8 — Nenhuma das três skills novas usa Execution State

Todas operam de forma síncrona, numa sessão de conversa com Rafinha, sem
branch de código nem trabalho que atravesse sessões — o Jira (intake/
decision resolver) ou o arquivo `.md` local (incident capture) já é o
registro. Não entram na tabela §13.5.

---

## 3. Mapa de colunas — 10 → 12

| # antigo | # novo | Coluna | Nota |
| --- | --- | --- | --- |
| 1 | 1 | A fazer | Sem mudança de papel — continua entrada bruta |
| — | **2** | **Decisão - Rafinha** | **Nova.** Maturação humana de pendências |
| 2 | 3 | Design de produto - Rafinha | Sem mudança de papel |
| — | **4** | **Ready** | **Nova.** Fila de issues prontas para `Fazer - Claude` |
| 3 | 5 | Fazer - Claude | Passa a receber só de `Ready` |
| 4 | 6 | Análise - Rafinha | Sem mudança |
| 5 | 7 | Integração | Sem mudança |
| 6 | 8 | QA - Claude | Sem mudança |
| 7 | 9 | Análise Final - Rafinha | Sem mudança |
| 8 | 10 | Documentar | Sem mudança |
| 9 | 11 | Análise Final - Claude | Sem mudança |
| 10 | 12 | Concluído | Sem mudança |

`workflow-development-flow` §5 segue a mesma renumeração (5.1 a 5.12).

---

## 4. Ondas de execução

### Onda 1 — `workflow-development-flow`, a fonte normativa

Único arquivo, mas é o que mais muda. Nesta ordem:

1. **Frontmatter (`description`)** — trocar "10 colunas" por "12 colunas",
   listar as duas novas, mencionar as três skills novas, remover
   `needs-manual-decision` da lista de labels citadas.
2. **Seção 2 (Princípios)** — adicionar princípio 11 (D3): escopo explícito
   obrigatório, com as três formas (Épico / lista / coluna confirmada) e a
   frase de fechamento: "Estar na coluna correta não autoriza uma issue fora
   do escopo. Estar no escopo, mas em estado incompatível, também não
   autoriza execução."
3. **Seção 4 (Fluxo geral)** — novo diagrama de 12 colunas; atualizar a nota
   "duas mudanças em relação ao fluxo anterior" para três; adicionar a regra
   de destino a partir de `A fazer` (→ `Decisão - Rafinha` quando há
   pendência real; → `Design de produto - Rafinha` ou `Ready` quando não há).
4. **Seção 5 (Etapas em detalhe)** — renumerar 5.1–5.10 → 5.1–5.12 (mapa em
   §3), inserindo:
   - **5.2 Decisão - Rafinha** (nova): objetivo, quem atua
     (`jira-issue-decision-resolver`, conversando com Rafinha), critério de
     saída (nenhuma pendência de decisão aberta na descrição).
   - **5.4 Ready** (nova): objetivo, critério de entrada (decisão fechada e,
     quando aplicável, design feito), quem pode mover para lá
     (`jira-sprint-intake-executor` no caso excepcional, `jira-issue-
     decision-resolver` depois de resolver, ou Rafinha manualmente após
     design).
   - Ajustar a seção **5.5 Fazer - Claude** (era 5.3): adicionar o Gate de
     Pendência (D2) antes do Gate de Design existente.
5. **Seção 8 (Gates)** — atualizar o diagrama 8.1 com as duas etapas novas;
   adicionar a **Gate 12 — Pendência de decisão** (D2) e a **Gate 13 —
   Escopo operacional** (D3) na tabela 8.2.
6. **Seção 9 (Responsabilidade por etapa)** — duas linhas novas (`Decisão -
   Rafinha`, `Ready`).
7. **Seção 11.6 (Model Escalation)** — três linhas novas (D7).
8. **Seção 15.3 (Vocabulário de labels)** — remover `needs-manual-decision`
   da linha "Risco e controle"; seção 15.4 ("O que saiu do contrato") ganha
   uma linha nova para ela, com motivo ("substituída por coluna + descrição
   padronizada").
9. **Nova seção 17 — Descrição padronizada da issue** (D4): o template de 9
   seções, a regra de coerência com a coluna (pendência aberta permitida só
   em `Decisão - Rafinha`; proibida em `Ready` e depois), e quem escreve/edita
   cada seção (creator escreve a base; decision resolver fecha Pendências →
   Decisões registradas).
10. **Varredura final da onda** — grep por `seção 5\.`, `§5\.`, `5\.7`,
    `5\.8`, `5\.9` no próprio arquivo (as referências das seções 12 e 13 ao
    número antigo das etapas) e corrigir cada uma para o número novo.

### Onda 2 — Skills existentes do pipeline de issues

**`jira-issue-creator`**
- Passo 5 (rascunho) e passo 7 (criação): trocar o corpo `Contexto`/`Objetivo`
  pela descrição padronizada de 9 seções (§17 nova). Pendências de decisão
  que o rascunho identificar entram já preenchidas nessa seção — é o gancho
  que leva a issue para `Decisão - Rafinha` depois.
- Passo 6 (destino): nenhuma mudança de lógica — continua `A fazer` ou
  backlog. Só ajustar o texto que descreve o que vem depois de `A fazer`,
  já que agora pode ser `Decisão - Rafinha`, não só Design/Fazer-Claude.
- Frontmatter: sem mudança estrutural relevante (já cria em `A fazer`).

**`jira-issue-executor`**
- Frontmatter: remover `needs-manual-decision` da lista de labels
  respeitadas; ajustar a frase de abertura para deixar claro que a skill é
  **passiva** (implementa o que já foi decidido, não decompõe escopo nem
  fecha regra de negócio).
- Seção 3.2 (labels de risco): remover a linha `needs-manual-decision`.
- Novo **passo 3.1a — Gate de Pendência** (D2), antes do Gate de Design
  (3.1): olha `## Pendências de decisão` na descrição; se não estiver vazia,
  bloqueia e reporta — mesmo formato de mensagem do bloqueio de Design.
- Passo 1 (Localizar issues elegíveis): adicionar a confirmação de escopo
  explícito (D3/princípio 11) antes de buscar a coluna inteira — ver texto-
  padrão abaixo, reaproveitado nas cinco skills seguintes.
- "O que NÃO fazer": remover a entrada de `needs-manual-decision`; adicionar
  "nunca implementar issue com Pendências de decisão não resolvidas".

**Texto-padrão do Gate de Escopo (D3), inserido no início do passo de
localizar issues em `jira-issue-executor`, `jira-integration-executor`,
`jira-qa-executor`, `jira-doc-executor`, `jira-human-validation-executor` e
`jira-review-executor`:**

```text
Antes de buscar qualquer issue, confirme o escopo desta execução com
Rafinha, se ainda não estiver explícito na mensagem dele:
  1. Épico — só as issues daquele épico;
  2. Lista de issues — só os códigos informados;
  3. Coluna inteira — só quando Rafinha confirmar explicitamente que é
     para processar a coluna toda.
Estar na coluna correta não autoriza uma issue fora do escopo confirmado.
Ver workflow-development-flow, princípio 11.
```

`jira-integration-executor` já exige modo + escopo explícito por contrato
(seção "Regra de escopo" existente) — só recebe uma referência ao princípio
11 para não duplicar a régua, sem mudança de comportamento real.

**`jira-review-executor`**
- Tabela de auditoria de labels de risco e controle: remover a linha
  `needs-manual-decision`.
- Adicionar a régua de escopo (texto-padrão acima).
- Adicionar um item de auditoria: issue documentada com a descrição
  padronizada (9 seções) e sem `## Pendências de decisão` residual.

**`jira-qa-executor`, `jira-doc-executor`, `jira-human-validation-executor`**
- Só a régua de escopo (texto-padrão acima) no ponto em que hoje buscam
  "todas as issues da coluna X". Nenhuma outra mudança de contrato — nenhuma
  delas cita `needs-manual-decision` nem depende da numeração de colunas por
  posição (comparam por nome literal, que não mudou).

### Onda 3 — Três skills novas

Cada uma é uma pasta nova com `SKILL.md` próprio, seguindo a mesma estrutura
das skills existentes (Identidade do papel, Model Policy, Pré-requisitos,
Passo a passo, O que NÃO fazer).

**`jira-sprint-intake-executor`**
- Papel: amadurece épicos/issues no escopo informado por Rafinha, explicita
  lacunas, registra `## Pendências de decisão`, decide o próximo destino
  (`Decisão - Rafinha`, `Design de produto - Rafinha` ou, excepcionalmente,
  `Ready`). Nunca cria regra de negócio nem decide entre alternativas de
  produto.
- Limite oficial (citação literal da página): não pode alterar a intenção
  original do épico/issue.
- Referencia `workflow-development-flow` para a descrição padronizada (§17)
  e para o princípio de escopo (11) — a skill em si já opera sob escopo
  explícito por natureza (Rafinha sempre informa épico/issues/conjunto).

**`jira-issue-decision-resolver`**
- Papel: resolve pendências de **uma issue por vez**, em conversa — não é
  linha de produção, não varre coluna. Atualiza a descrição (fecha
  `Pendências de decisão`, preenche `Decisões registradas`), move para
  `Design de produto - Rafinha` ou `Ready`.
- Explicitamente **não** implementa, não cria PR, não faz QA, não documenta,
  não cria issues, não decide sozinha sem Rafinha.
- Nota de fronteira: decisão durável de regra de negócio/arquitetura que
  nasce aqui é sinalizada para o artefato certo (RN no Confluence, ADR,
  etc.) — a resolução da issue não substitui a documentação futura que
  `jira-doc-executor` vai acionar depois.
- Também é o segundo ponto (além de `jira-issue-creator`) onde
  `requires-design` pode ser confirmada explicitamente por Rafinha — nunca
  aplicada por inferência.

**`workflow-incident-capture-executor`**
- Papel: gera **só** um arquivo `.md` local em
  `.claude/workflow-incidents/AAAA-MM-DD-<PROJETO-OU-ISSUE>-<resumo>.md`
  descrevendo um incidente operacional (contexto, esperado vs. acontecido,
  evidências, conflito de contrato, impacto potencial).
- Não corrige nada, não altera Jira/Confluence/Notion/GitHub/branches/PRs/
  labels/issues/páginas/código, não decide regra nova, não move issue, não
  cria ticket. É observação pura, para retomada posterior por Rafinha.
- Sugerir, na própria skill, adicionar `.claude/workflow-incidents/` ao
  `.gitignore` do projeto na primeira execução (mesmo padrão de
  `design-packages/` e `execution-state/`).

### Onda 4 — `README.md`

- Diagrama mermaid: 12 nós, incluindo `Decisão - Rafinha` e `Ready`.
- Banner de vigência: acrescentar "Pacote 4 (revisão do workflow inteiro)"
  à lista de pacotes em vigor, quando o corte acontecer — **não** marcar como
  vigente antes do merge real (mesmo cuidado do Pacote 3, §"drift" da onda 4
  daquele plano).
- Tabela "Pipeline Jira": três linhas novas (intake, decision resolver,
  incident capture) — decidir se `workflow-incident-capture-executor` entra
  em "Pipeline Jira" ou em "Qualidade & produtividade" (ela não pertence ao
  fluxo de issue, é observação transversal) → **decisão: "Qualidade &
  produtividade"**, junto de `flutter-development-standards`.
- Recontar o total de skills no texto corrido (hoje a página do Confluence
  "2. Sincronizar as skills" cita 16 — a onda 5 recalcula esse número junto
  com a atualização daquela página, para não duplicar a contagem em dois
  lugares divergentes).
- Remover/ajustar qualquer menção a `needs-manual-decision` (nenhuma
  encontrada no `README.md` hoje — confirmar de novo na varredura da Onda 6).

### Onda 5 — Confluence (espaço CS1)

**Páginas existentes a atualizar:**

| Página | ID | O que muda |
| --- | --- | --- |
| Visão geral do fluxo | 44302381 | Diagrama de 12 colunas |
| Nomenclatura de colunas do board | 44302402 | Lista canônica com as duas novas |
| Gates operacionais | 68223007 | Gates 12 e 13 (D2/D3) |
| Vocabulário operacional de labels | 68222978 | Remove `needs-manual-decision`, registra motivo |
| Claude Skills (home) | 44204199 | "pipeline de 10 etapas" → 12 |
| Skills (índice) | 44105730 | Três entradas novas |
| jira-issue-creator | 44335131 | Descrição padronizada (9 seções) |
| jira-issue-executor | 44072962 | Gate de Pendência, escopo explícito, remove needs-manual-decision |
| jira-integration-executor | 44171267 | Referência ao princípio 11 |
| jira-qa-executor | 44367874 | Régua de escopo |
| jira-doc-executor | 44204245 | Régua de escopo |
| jira-human-validation-executor | 50855937 | Régua de escopo |
| jira-review-executor | 44400665 | Remove needs-manual-decision, régua de escopo, novo item de auditoria |
| workflow-development-flow | 44400642 | Espelha a Onda 1 inteira |
| 2. Sincronizar as skills | 44302422 | Recontagem de skills |
| 3. Configurar o board do Jira | 44105796 | 12 colunas no passo a passo de setup de projeto novo |

**Páginas novas (via `workflow-doc-writer`, template `skill-page.md`,
filhas de "Skills"):**
- `jira-sprint-intake-executor`
- `jira-issue-decision-resolver`
- `workflow-incident-capture-executor`

**Checagem de drift.** Cada ficha atualizada nesta onda roda a checagem de
drift da `workflow-doc-writer` (o `SKILL.md` real vence sempre) — inclusive
nas seis páginas que só ganham a régua de escopo, para não deixar nenhuma
delas descrevendo um comportamento antigo.

### Onda 6 — Verificação final

- Grep de `needs-manual-decision` no repositório inteiro — deve sobrar zero
  ocorrência fora deste plano e do histórico do Notion.
- Grep de `10 colunas` / `dez colunas` — mesma verificação.
- Conferência manual dos cross-refs numéricos de `workflow-development-flow`
  §5 (ver passo 10 da Onda 1).
- Resumo final para Rafinha: o que foi tocado, o que ficou de fora (§5), e a
  lista de pendências não bloqueantes (§6).

---

## 5. O que fica fora deste pacote

- **Qualquer configuração real de Jira** — criar as colunas `Decisão -
  Rafinha` e `Ready` no board, ajustar transições, mover issues existentes.
  Isso é manual, feito por Rafinha, em sessão separada — mesmo modelo já
  usado nos pacotes anteriores para configuração de projeto.
- **Remoção da label `needs-manual-decision` de issues já existentes** no
  Jira — as skills simplesmente deixam de exigi-la; a limpeza de dados é
  decisão de Rafinha, não deste pacote.
- **`jira-contingency-executor`** (D6) — citada na página como decisão já
  válida, mas não pedida como criação nova aqui.
- **Automações, filtros e validações do Jira** que dependam da lista antiga
  de 10 colunas (item que a própria página do Notion lista em "Pendências de
  aplicação futura") — fora do escopo Confluence+skills desta sessão.

---

## 6. Pendências não bloqueantes para Rafinha revisar quando puder

| Item | Onde está registrado |
| --- | --- |
| Confirmar D1 (transição manual `Ready → Fazer - Claude`) ou pedir automação | §2, D1 |
| Confirmar D2 (Gate de Pendência) como comportamento desejado, ou preferir sem esse gate extra | §2, D2 |
| Decidir se `jira-contingency-executor` deve ser criada (D6) | §2, D6 |
| Confirmar a classificação de `workflow-incident-capture-executor` em "Qualidade & produtividade" no README, e não em "Pipeline Jira" | Onda 4 |

Nenhum destes bloqueia a execução das Ondas 1–6 — todos têm default
aplicado e documentado acima.

---

## 7. Registro de implementação (2026-09-26)

Todas as ondas rodaram numa passagem só, a pedido explícito de Rafinha
("Pode implementar tudo de uma vez só"). Registro do que de fato aconteceu,
com os desvios em relação ao previsto em §4.

### Onda 1 — `workflow-development-flow`

Executada como planejado: princípio 11 (escopo explícito) na seção 2;
seção 4 com o novo eixo de entrada; seção 5 renumerada 5.1–5.12 com
`Decisão - Rafinha` (5.2) e `Ready` (5.4) novas; gates 12 e 13 na seção 8.2;
duas linhas novas na seção 9; três linhas novas na Model Escalation (11.6);
`needs-manual-decision` removida da seção 15.3 e registrada na 15.4; seção
17 nova com a descrição padronizada. Varredura de `seção 5\.` encontrou e
corrigiu três cross-refs órfãs nas seções 12.6 e 12.7 (apontavam para 5.7 e
5.9 do numeramento antigo).

### Onda 2 — Skills existentes

`jira-issue-creator`: rascunho e criação passaram a usar a descrição de 9
seções; texto do destino atualizado para citar `Decisão - Rafinha`/`Ready`.

`jira-issue-executor`: passou a se descrever como passiva; novo gate 3.1
(Pendência de decisão) inserido antes do Gate de Design, que se renumerou
para 3.2 (labels de risco para 3.3) — três cross-refs internas corrigidas
junto. `needs-manual-decision` removida da tabela 3.3 (antiga 3.2) e da
lista "O que NÃO fazer".

Gate de escopo explícito adicionado ao passo de localizar issues em
`jira-issue-executor`, `jira-qa-executor`, `jira-doc-executor` e
`jira-human-validation-executor`. Em `jira-integration-executor` foi só uma
referência ao princípio 11 — a skill já exigia modo+escopo explícitos.
`jira-review-executor` recebeu o gate de escopo, a remoção de
`needs-manual-decision` da tabela de auditoria (item 5) e um novo item 5.1
que audita a seção Pendências de decisão vazia.

### Onda 3 — Três skills novas

`jira-sprint-intake-executor`, `jira-issue-decision-resolver` e
`workflow-incident-capture-executor` criadas conforme desenhado em §4, sem
desvio de conteúdo relevante.

### Onda 4 — `README.md`

Diagrama mermaid com 12 nós; parágrafo novo sobre `Decisão - Rafinha`/`Ready`
e sobre escopo explícito; duas linhas novas na tabela "Pipeline Jira"
(intake, decision resolver) e uma em "Qualidade & produtividade" (incident
capture, conforme decidido em §4); banner de vigência atualizado para citar
o Pacote 4 como implementado nas skills e no Confluence, com a ressalva de
que a configuração real do board continua manual.

### Onda 5 — Confluence

As 16 páginas listadas em §4 foram atualizadas e as 3 fichas novas criadas
como filhas de "Skills". Uma descoberta de implementação: o body em
Markdown não pôde ser usado para substituição completa nas páginas que já
tinham links como *smart cards* inline (Confluence recusa com erro 422,
"markdown body replacement would cause data loss") — todas as atualizações
desta onda foram feitas em HTML (`contentFormat: "html"`), com
`data-card-appearance="inline"` nos links que já eram cartões (normalmente
as listas "Ver também") e `<a href>` simples nos links citados dentro de
frases.

**Recontagem de skills.** A página "2. Sincronizar as skills" citava 16
skills — número já defasado desde o Pacote 3 (que trouxe o total a 18) e
não corrigido até agora. Corrigido para 21 (18 anteriores + 3 novas deste
pacote), com a nota de que a contagem estava desatualizada.

### Onda 6 — Verificação final

Grep por `needs-manual-decision` — sobram só as três menções intencionais
(explicando a remoção): `workflow-development-flow/SKILL.md`,
`jira-issue-executor/SKILL.md` e este plano.

Grep por `10 colunas`/`dez colunas` encontrou duas ocorrências fora dos
planos antigos (que não são tocados) e foram corrigidas: `jira-release-
executor/SKILL.md` ("workflow de 10 colunas" → 12) e
`workflow-development-flow/references/release-lifecycle.md` (idem).

Achado adicional fora do escopo original: o diagrama de
"Onde esta skill se encaixa no fluxo completo" em
`jira-review-executor/SKILL.md` ainda mostrava `A fazer → [requires-design?]
→ Design de produto - Rafinha → Fazer - Claude` (fluxo antigo) — corrigido
para citar `Decisão - Rafinha` e `Ready`. O diagrama comparativo em
`release-lifecycle.md` §1 (issue workflow vs. release workfow, lado a lado)
foi condensado (duas linhas antigas em uma) para caber as duas colunas
novas sem desalinhar a comparação com o lado do release.

**O que ficou de fora**, confirmando §5: nenhuma ação no Jira de produto,
`jira-contingency-executor` não criada, e as pendências não-bloqueantes de
§6 continuam abertas para Rafinha decidir quando quiser — nenhuma delas
exigiu escolha durante a execução porque os defaults documentados em §2 se
sustentaram.
