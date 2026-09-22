# Plano de implementação — Pacote 2: Branches por épico e release controlada

Documento de planejamento e **registro de implementação**, no mesmo formato do
`plano-release-lifecycle.md`.

**Fonte do contrato:** página do Notion *"Atualização — Branches por épico e
release controlada"*, lida em 2026-09-22. Este documento não a substitui —
registra as decisões de implementação que ela deixou em aberto ou contraditas,
e o estado de cada fase.

**Histórico de revisões**

| Data | O que mudou |
| --- | --- |
| 2026-09-22 | Versão inicial. D1 e D2 decididas por Rafinha. Fase 1 concluída |
| 2026-09-22 | Fase 2 concluída. D3 aplicada na `jira-integration-executor` |

---

## 0. Status de implementação

| Fase | O quê | Status |
| --- | --- | --- |
| 1 | Labels `integrado-epico` e `qa-develop-aprovado` na matriz oficial | ✅ ver §5 |
| 2 | `jira-integration-executor` — modos A/B/C, smoke test, subtarefas | ✅ ver §6 |
| 3 | `jira-issue-executor` — branch de épico, Execution State | ⬜ |
| 4 | `jira-qa-executor` — aplica `qa-develop-aprovado`, remove `integrado-epico` | ⬜ |
| 5 | `jira-release-executor` — `release/current`, manifest, bump | ⬜ |
| 6 | `jira-review-executor` — auditoria de destino e labels | ⬜ |
| 7 | `workflow-development-flow` — consolidação | ⬜ |
| 8 | CI e branch protection (`epic/**`, `release/current`) | ⬜ manual, Rafinha |
| 9 | Confluence — fichas das skills tocadas | ⬜ |

**Estado do contrato: `preparado`.** Esta branch descreve o contrato de destino
do Pacote 2. O merge em `master` é o corte de vigência. Até lá, o pipeline
opera com o contrato do Pacote 1.

---

## 1. Decisões de implementação

### D1 — A `jira-integration-executor` tem três modos, não dois

**Decidida em 2026-09-22 por Rafinha.**

A página do Notion se contradiz. Quatro seções falam de modos, e duas ficaram
numa versão anterior:

| Seção da página | Modos que declara |
| --- | --- |
| Decisões consolidadas #8 | A: issue→épico · B: épico→develop · C: issue→develop |
| **Modos finais da jira-integration-executor** | A: issue→épico · B: épico→develop · C: issue→develop |
| Skills afetadas → `jira-integration-executor` | A: issue→épico · B: issue→develop *(dois modos)* |
| Complemento — modo de integração sempre explícito | A: issue→épico · B: issue→develop *(dois modos)* |

**Decisão:** vale a matriz de **três modos**.

```
Modo A: issue → branch do épico
Modo B: branch do épico → develop
Modo C: issue → develop
```

**Motivo:** a seção "Modos finais" é a mais tardia da página, declara-se
explicitamente final ("A matriz final de modos fica") e é a única em que a
promoção do épico para `develop` tem um modo próprio. Na versão de dois modos,
a promoção do épico não tem operação que a execute — o que contradiz as
decisões #8, #14 e #15 e a seção inteira de "Promoção do épico para develop".

As duas seções de dois modos são resíduo de uma rodada anterior. Não devem ser
usadas como contrato.

### D2 — Como a release prova que a `develop` só carrega trabalho aprovado

**Decidida em 2026-09-22 por Rafinha,** sobre proposta registrada aqui.

A página estabelece a regra e o bloqueio, mas não o mecanismo:

> A skill de release não pode mergear `develop → release/current` se a
> `develop` contiver alterações não aprovadas que seriam levadas junto para
> `release/current`.

Era a única das seis "Pendências remanescentes" que a rodada de fechamento não
encerrou.

**Mecanismo decidido — rastreio por chave de issue no intervalo de commits:**

1. Calcular o intervalo `release/current..develop`.
2. Para cada merge commit do intervalo, extrair a chave da issue do **nome da
   branch de origem**. A convenção `{tipo}/<ISSUE-KEY>-claude`, mantida pela
   decisão #11 da página, garante que a chave esteja lá.
3. Para cada chave extraída, verificar a presença de `qa-develop-aprovado`.
4. **Bloquear** em qualquer um destes casos:
   - commit no intervalo sem chave de issue extraível (inclui commit direto na
     `develop`, sem PR);
   - chave extraída cuja issue não tem `qa-develop-aprovado`;
   - chave extraída que não resolve para uma issue existente.
5. Registrar o mapeamento completo — commit → issue → estado da label — como
   evidência da promoção, aprovada ou bloqueada.

**Por que este mecanismo:** ele usa duas coisas que já existem e não inventa
estrutura nova. A convenção de nome de branch já carrega a chave, e a
`jira-release-executor` já faz o caminho issue → componente pelos arquivos do
PR. O que faltava era o caminho inverso, commit → issue, e ele sai do mesmo
dado.

**Consequência aceita:** commit direto na `develop` sem Pull Request passa a
bloquear a promoção. É deliberado — um commit sem PR é, por construção, um
commit que não passou por QA, e a regra da página é justamente não levar
trabalho não aprovado para `release/current`.

**Escape:** a exceção manual já prevista na página. Rafinha autoriza
explicitamente, e a skill registra qual issue/épico ficou fora, qual risco foi
aceito, a frase de autorização e o impacto esperado.

### D3 — Ausência de `integrado-epico` é bloqueio, não "ainda não integrada"

**Decidida em 2026-09-22.**

A decisão #4 da página descarta a criação de uma coluna `Integração - Épico`.
O efeito é que uma issue mergeada na branch do épico e uma mergeada na
`develop` ocupam **a mesma posição no board**. A label `integrado-epico` é o
único discriminador entre os dois estados.

**Decisão:** no Modo B, uma issue obrigatória do escopo sem `integrado-epico`
faz a skill **parar e perguntar**, em vez de concluir que ela não foi
integrada.

**Motivo:** as duas leituras possíveis da ausência — "não foi integrada" e "foi
integrada mas a label falhou" — têm consequências opostas, e a skill não tem
como distinguir. Assumir a primeira faz a skill reportar um épico incompleto
que está completo; assumir a segunda faz promover um épico furado. É o mesmo
princípio do gate "proibido fallback silencioso" do Pacote 1.

---

## 2. O que o Pacote 1 já entregou e este pacote consome

Verificado no Jira em 2026-09-22, nos projetos CPS e GEOPRAG.

| Pré-requisito | Estado |
| --- | --- |
| Board canônico de 10 colunas | ✅ aplicado nos dois projetos |
| `Documentar` depois de `Análise Final - Rafinha` | ✅ é a ordem vigente |
| `Análise - Rafinha` como nome oficial da revisão humana | ✅ |
| `Integração` genérica, sem coluna por épico | ✅ |
| Matriz oficial de labels no Confluence | ✅ página 68222978 |

O sequenciamento definido na página do Notion (§ Sequenciamento com o pacote de
Design/labels/gates) está satisfeito até o passo 2. Este pacote começa no
passo 3.

---

## 3. Divergências menores registradas

**Caixa de "Análise Final".** A página do Notion escreve `Análise final -
Rafinha` e `Análise final - Claude`, com "f" minúsculo. O Jira tem `Análise
Final` com F maiúsculo, nos dois projetos. **Vale o Jira** — é o que as
consultas por nome precisam casar.

---

## 4. Fora do escopo deste pacote

- Coluna nova de qualquer tipo. Decisões #4, #5 e #6 são explícitas.
- Skill `jira-epic-promotion-executor`. Decisão #9.
- Mudança na convenção de nome da branch de issue. Decisão #11.
- Issues existentes de CPS e GEOPRAG — nenhum épico tem branch, e criar uma
  exige comando explícito de Rafinha (decisão #12).
- Colunas legadas, campo `Tipo` e nome do tipo `Validação Manual`. São trilha
  separada, levantada em 2026-09-22 e ainda em aberto.

---

## 5. Registro — Fase 1

**Concluída em 2026-09-22.**

### O que foi feito

| Onde | Mudança |
| --- | --- |
| Confluence 68222978 — *Vocabulário operacional de labels* | Nova **categoria 11 — Estado operacional de integração**, com as duas labels, tabela de quem aplica e quem remove, justificativa de não-redundância, ciclo de vida de cada uma, painel de bloqueio da D3 e nota de ordem de vigência. v4 |
| Confluence 68222978 — seção *Labels deliberadamente fora da matriz → Revisão* | Parágrafo novo explicando por que a categoria 11 não é exceção à regra que tirou a label de revisão do contrato |
| `README.md` | "10 categorias" → "11 categorias", mais o parágrafo da categoria nova |
| `workflow-development-flow/SKILL.md` §15.3 | "As 10 categorias" → "As 11 categorias", linha nova na tabela, parágrafo de estado-vs-natureza e painel de bloqueio da D3 |

### Por que a categoria é nova em vez de entrar na 6

A categoria 6 (*Risco e controle operacional*) agrupa sinais que as skills
devem **respeitar** ao decidir como agir. As duas labels novas não pedem
comportamento — elas **registram um fato** sobre onde o código está. Misturá-las
com `high-risk` ou `do-not-expand-scope` apagaria essa diferença.

Entrar como 11 também evita renumerar a categoria 10, que é referenciada como
"a décima categoria" no `README.md`, na skill mãe e na própria matriz.

### Decisão de ordem

As labels entram na matriz **antes** das skills que as aplicam. Isso não é
formalidade: a regra central da matriz diz que nenhuma skill pode aplicar label
não documentada. Escrever a skill primeiro criaria uma janela em que a skill
viola a matriz que ela mesma deve respeitar.

Enquanto as fases 2 a 7 não estiverem em vigência, as duas labels existem na
documentação e em nenhuma issue real. Isso é esperado.

### Verificação

A página foi relida depois do update. As 10 categorias originais, as duas
seções de labels fora da matriz, a tabela de pendências e a seção "Ver também"
continuam presentes e inalteradas.

### Uma imperfeição conhecida

O parágrafo novo na seção *Revisão* foi escrito com um link âncora para a
seção 11 da mesma página. O Confluence descartou a âncora e manteve o texto.
A frase funciona sem o link — a seção 11 fica logo acima —, mas o link não
existe. Não foi refeito para não gastar uma versão da página só nisso.

---

## 6. Registro — Fase 2

**Concluída em 2026-09-22.**

`jira-integration-executor/SKILL.md`: 262 → 577 linhas.

### Estrutura escolhida: rotinas compartilhadas, não três fluxos paralelos

Os três modos têm muito em comum — confirmar PR, checar CI, reconciliar por
merge, registrar evidência. Escrever cada modo do começo ao fim triplicaria o
texto e criaria três lugares para a mesma regra divergir.

A skill ficou com seis rotinas definidas uma vez:

| Rotina | O quê |
| --- | --- |
| R1 | Confirmar o Pull Request e **que ele aponta para o destino do modo** |
| R2 | Verificar o GitHub Actions |
| R3 | Reconciliar com a branch de destino, por merge |
| R4 | Smoke test mínimo (10 checks) |
| R5 | Verificar subtarefas |
| R6 | Registrar evidência |

Cada modo virou uma sequência curta que chama as rotinas e acrescenta o que é
só dele.

### Decisões tomadas dentro da fase

**O Modo A não move a issue de coluna.** A página do Notion lista as
responsabilidades do Modo A e termina em "aplicar `integrado-epico`" — sem
transição. O Modo B é que move o lote para `QA - Claude`. Isso é coerente com
a finalidade declarada da label: "evidência visual temporária no board
enquanto o épico ainda não foi promovido". Se a issue saísse de `Integração`
no Modo A, não haveria board onde a evidência fosse visível.

**R1 verifica o destino do PR, não só a existência.** Um PR aberto contra a
`develop` não serve para o Modo A. Sem essa checagem, o Modo A mergearia
usando um PR que descreve outra operação. A skill para e pergunta; não
reaponta o PR sozinha.

**Conflito semântico no Modo B não devolve issue nenhuma.** Nos modos A e C a
válvula é mover a issue de volta para `Análise - Rafinha`. No Modo B o
conflito é entre a branch do épico e a `develop` — não há issue única a quem
atribuí-lo. A skill para, registra e pede decisão, sem mexer em coluna.

**A branch da issue precisa ter nascido da branch do épico.** Verificação
acrescentada ao Modo A que não estava explícita na página. Se a branch nasceu
da `develop` e for mergeada no épico, ela traz a `develop` inteira para dentro
do épico — o que contamina o escopo da promoção e quebra o critério de
aptidão nº 10.

### Fora da skill

`workflow-development-flow` §1 dizia que as skills posteriores "já recebem a
Issue certa e não precisam reaplicar essa decisão". Com R5, a Integração passa
a inspecionar subtarefas — o que é diferente de reaplicar a decisão de nível,
mas perto o bastante para confundir. Acrescentado um aviso em §1 separando as
duas coisas.

O tratamento completo do modelo de branches na skill mãe continua sendo da
fase 7. O aviso de §1 entrou agora só para não abrir uma janela de contradição
entre as fases 2 e 7.

### Defeito pré-existente corrigido de passagem

O arquivo tinha **frontmatter duplicado**: um bloco válido nas linhas 1–4 e um
segundo bloco nas linhas 6–9, que o parser tratava como corpo. Como o arquivo
foi reescrito por inteiro, o bloco morto saiu junto.

**O mesmo defeito existe em outras três skills** e não foi tocado aqui:
`business-rule-writer`, `module-doc-writer` e `doc-pendency-resolver`. Não faz
parte do Pacote 2.
