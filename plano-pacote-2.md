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
| 2026-09-22 | Fase 3 concluída. Branch de épico e base da branch da issue |
| 2026-09-22 | Fase 4 concluída. D4 e D5 decididas — remoção de label no veredito |
| 2026-09-22 | Fase 5 concluída. D2 implementada como gate G10; D6 decidida |

---

## 0. Status de implementação

| Fase | O quê | Status |
| --- | --- | --- |
| 1 | Labels `integrado-epico` e `qa-develop-aprovado` na matriz oficial | ✅ ver §5 |
| 2 | `jira-integration-executor` — modos A/B/C, smoke test, subtarefas | ✅ ver §6 |
| 3 | `jira-issue-executor` — branch de épico, Execution State | ✅ ver §7 |
| 4 | `jira-qa-executor` — aplica `qa-develop-aprovado`, remove `integrado-epico` | ✅ ver §8 |
| 5 | `jira-release-executor` — `release/current`, manifest, bump | ✅ ver §9 |
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

### D4 — `integrado-epico` sai no veredito, não só na aprovação

**Decidida em 2026-09-22, durante a fase 4.**

A página do Notion fecha o momento de remoção da label na lista de
"Pendências encerradas nesta rodada" (item 7), mas o texto só descreve **um**
caminho:

> Quando a issue for aprovada no QA sobre a `develop` e receber
> `qa-develop-aprovado`, a label `integrado-epico` deve ser removida.

**A reprovação ficou sem regra.** Seguir a página ao pé da letra deixaria a
label numa issue reprovada.

**Decisão:** a label sai no **veredito**, qualquer que seja ele.

| Veredito | `qa-develop-aprovado` | `integrado-epico` |
| --- | --- | --- |
| Aprovado | aplica | remove |
| Reprovado | não aplica | remove |
| Inconclusivo por infraestrutura | não aplica | **não mexe** |

**Motivo:** a label significa *"o código desta issue está na branch do épico
e ainda não foi validado na `develop`"*. Quando a issue chega ao QA, o épico
já foi promovido — esse estado acabou, independente do veredito.

**O risco concreto de não remover:** numa promoção parcial posterior do mesmo
épico, uma issue reprovada carregando `integrado-epico` satisfaria o critério
de aptidão nº 3 sem ter sido reintegrada. A skill de integração leria uma
label verdadeira sobre um estado que não existe mais, e promoveria código não
corrigido.

**Inconclusivo não mexe em nada** porque não houve veredito. A issue nem muda
de coluna; alterar label registraria um julgamento que não aconteceu.

Esta decisão **estende** a página, não a contradiz: o caminho que ela
especifica continua valendo exatamente como está.

### D5 — Correção de issue reprovada que veio de épico integra direto

**Decidida em 2026-09-22, durante a fase 4.**

A página não trata do que acontece quando uma issue reprova no QA **depois**
de o épico já ter sido promovido.

**Decisão:** a correção nasce da `develop` e integra direto, pelo Modo C.
Não volta para a branch do épico.

**Motivo:** quando o épico foi promovido, o código da issue passou a residir
na `develop`. A branch do épico cumpriu o papel. Reabri-la para uma correção
criaria uma segunda promoção do mesmo épico, com escopo de uma issue só — que
é exatamente a promoção parcial que a página trata como exceção.

A skill não decide isso sozinha se Rafinha pedir outro caminho, mas também
não sugere reabrir a branch do épico como se fosse o padrão.

### D6 — O bump é dividido: versão semântica na `release/current`, build number na Action

**Decidida em 2026-09-22, durante a fase 5.**

A página do Notion diz que *"o commit de bump de versão deve ser feito
diretamente na branch `release/current`"*, e que a branch efêmera nasce dela
já preparada. Mas a Action de cada repositório **também** tem um step de bump,
e a página não diz o que acontece com ele.

Ler a página ao pé da letra levaria a uma de duas conclusões erradas: que o
step da Action virou redundante e deve ser removido, ou que o bump acontece
duas vezes.

**Decisão:** o bump tem duas partes, em lugares diferentes, sem duplicação.

| Parte | Onde | Quem aplica | Por quê |
| --- | --- | --- | --- |
| Versão semântica (`1.2.0`) | commit na `release/current` | a skill | É decisão de produto e pertence à linha persistente |
| Metadado de build (`+<run_number>`) | branch efêmera | a Action | Só existe no contexto daquela execução |

**Por que isso funciona sem mexer no `release.yml`:** o template já é
idempotente. O step de bump roda `versions:set` com a mesma versão que já está
no arquivo, não gera diff semântico, e o `git diff --quiet` existente resolve:

```yaml
- name: Commit e push da release branch
  run: |
    if git diff --quiet; then
      echo "Nenhum bump de versao nesta rodada."
    else
      git commit -am "release: bump de versao (run ${{ github.run_number }})"
    fi
```

Em stacks com build number (Flutter, Android), o `+${{ github.run_number }}`
ainda gera diff — e é exatamente o que deve ser commitado na branch efêmera.

**Consequência registrada nas duas skills e na referência:** ninguém deve
"consertar" o step de bump da Action achando que ele virou redundante.

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

---

## 7. Registro — Fase 3

**Concluída em 2026-09-22.**

`jira-issue-executor/SKILL.md`: 755 → 865 linhas.

### O acoplamento que essa fase tinha que acertar

A fase 2 fez a `jira-integration-executor` verificar, na rotina R1, que o
destino do Pull Request bate com o modo em execução. Isso só funciona se
quem **abre** o PR apontar para o lugar certo desde o começo.

Se a `jira-issue-executor` continuasse abrindo todo PR contra a `develop`, o
Modo A bloquearia **sempre**, em toda issue de épico. A fase 3 é o outro lado
desse contrato.

```text
base da branch da issue  =  destino do PR  =  destino que a Integração valida
```

### O que mudou

| Passo | Mudança |
| --- | --- |
| Nova seção **Operação especial** | Criação de branch de épico, sob comando explícito, nascida da `develop`, com origem registrada em comentário no épico |
| **5.2 Resolver a branch** | Tabela de qual é a branch base: épico com branch ativa → `epic/<EPIC-KEY>-<nome>`; senão → `develop` |
| **5.6 Abrir o PR** | O destino do PR acompanha a base |
| **5.7 Encerrar Execution State** | A branch da issue é a única que recebe commit de Execution State |

### Decisões tomadas dentro da fase

**Duas branches do mesmo épico é bloqueio.** A página não previu o caso.
Escolher sozinha entre `epic/PROJ-40-cadastro` e `epic/PROJ-40-cadastros`
significaria decidir onde o trabalho vai parar — e a issue errada num épico
errado só aparece na promoção, muito depois. A skill para e pergunta.

**A branch base fica registrada, não é deduzida depois.** A Integração precisa
validar, no Modo A, que a branch da issue nasceu da branch do épico. Dá para
descobrir isso escavando `git merge-base`, mas é frágil quando o épico já
recebeu merges. Registrar no Execution State e no comentário da issue troca
arqueologia por leitura.

**Issue de épico sem branch usa a `develop` e segue.** É comportamento
esperado, não lacuna. A skill não cria a branch do épico para "consertar" a
situação — isso violaria a decisão #12 da página, que reserva a criação ao
comando explícito de Rafinha.

### Fora da skill

`workflow-development-flow` §13.3 dizia que o Execution State é removido "para
nunca chegar a `develop` por merge", e que as etapas pós-merge operam "direto
sobre `develop`/`main`". Com branch de épico no meio, as duas frases ficaram
incompletas.

§13.3 foi atualizada: a regra agora é enunciada como *"Execution State
versionado pertence à branch da issue; fora dela, é apenas estado local"*, e
`epic/**`, `release/current` e branches efêmeras de release entram
explicitamente na lista do que nunca recebe commit.

Mesmo critério das fases anteriores: o tratamento completo do modelo de
branches na skill mãe é da fase 7, mas a frase que virou falsa agora foi
corrigida agora.

### Verificação de coerência entre as duas skills

| Pergunta | `jira-issue-executor` | `jira-integration-executor` |
| --- | --- | --- |
| Quem cria branch de épico | "é a **única** que cria" | "esta skill **nunca cria**" |
| Destino do PR | acompanha a base da branch | validado na R1 |
| Execution State | commita só na branch da issue | nunca commita |

---

## 8. Registro — Fase 4

**Concluída em 2026-09-22.**

`jira-qa-executor/SKILL.md`: 760 → 866 linhas.

### A fase mais curta em código e a mais densa em decisão

A skill já testava contra a `develop` — o pré-requisito 5 sempre exigiu
`git checkout develop` e `git pull`. Isso é exatamente o que
`qa-develop-aprovado` certifica, então a label não pediu mudança nenhuma de
comportamento de teste. Foi só dar nome ao que já acontecia.

O trabalho real da fase foi achar os dois buracos que a página deixou.

### O que mudou

| Onde | Mudança |
| --- | --- |
| Nova seção **Labels operacionais de integração** | Tabela dos três vereditos, justificativa da remoção na reprovação, caso da issue sem `integrado-epico`, caminho da correção |
| Nova seção **QA de lote por épico** | Veredito por issue, evidência por issue, conjunto registrado no épico, reprovação não contagia o lote |
| **Comentário obrigatório** | Passa a citar labels aplicadas/removidas e o conjunto do épico |
| **Movimentação da issue** | Cada veredito diz o que acontece com as labels |

### Alinhamento retroativo

D4 tornou falso o que a fase 1 escreveu em dois lugares. Corrigidos no mesmo
commit:

- Confluence 68222978, categoria 11 — tabela "quem remove" e item 4 do ciclo
  de vida. Acrescentado painel explicando a remoção na reprovação e a subseção
  de QA de lote. **v5.**
- `jira-integration-executor/SKILL.md`, tabela de labels operacionais.

Vale registrar que o erro foi meu na fase 1: eu copiei o ciclo de vida da
página do Notion sem notar que ele só cobria o caminho feliz.

### Divisão de responsabilidade sobre as duas labels

| Skill | `integrado-epico` | `qa-develop-aprovado` |
| --- | --- | --- |
| `jira-integration-executor` | **aplica** (Modo A), **lê** (Modo B) | — |
| `jira-qa-executor` | **remove** (veredito) | **aplica** (só aprovação) |
| `jira-release-executor` | — | **lê** (elegibilidade) |

Nenhuma skill aplica e remove a mesma label. Isso não foi planejado, mas é
uma propriedade boa: quem cria um estado nunca é quem o encerra, e as duas
pontas ficam auditáveis pela `jira-review-executor` na fase 6.

---

## 9. Registro — Fase 5

**Concluída em 2026-09-22.** A fase de maior superfície, como previsto — e a
primeira que tocou código executável, não só contrato.

### Arquivos tocados

| Arquivo | Mudança |
| --- | --- |
| `references/release-lifecycle.md` | §1 ganha as três branches; §8 ganha `eligibility`; §21 ganha G10; **nova §22** com o mecanismo da D2 |
| `jira-release-executor/SKILL.md` | Fase 5 ganha os passos 5.0 (promoção) e 5.1 (bump); 5.1→5.2 e 5.2→5.3 |
| `templates/orchestrator/release-request.example.yml` | `ref: release/current`, bloco `eligibility` |
| `templates/orchestrator/orchestrate.ps1` | **Validação do gate G10** |
| `templates/release.yml` | **nenhuma** — ver D6 |

### D2 virou o gate G10

O mecanismo que você aprovou está implementado em três camadas:

1. **Contrato** — §22 da referência descreve o algoritmo.
2. **Skill** — passo 5.0 executa e monta o bloco `eligibility`.
3. **Orchestrator** — recusa o request se o bloco faltar, se `checked_range`
   faltar, se `exceptions` estiver ausente (e não apenas vazia), ou se `ref`
   for diferente de `release/current` sem exceção registrada.

A terceira camada não estava no plano. Acrescentei porque o Orchestrator já
tem o idioma — a validação de `runtime_package.required` usa exatamente a
frase *"Ausência silenciosa não é permitida"*. Um gate que depende da skill
lembrar de rodá-lo não é um gate.

### A exceção ganhou schema

A página fala em registrar quatro coisas na exceção autorizada. Em prosa, isso
vira "alguém escreve um parágrafo". Virou quatro campos obrigatórios —
`item`, `risco`, `autorizacao`, `impacto` — validados pelo Orchestrator um a
um.

`exceptions: []` é obrigatório mesmo vazio. A lista vazia afirma "verifiquei e
não houve exceção"; o campo ausente não afirma nada.

### Duas contradições internas corrigidas

Mover o bump para a skill quebrou duas frases que já existiam no arquivo:

| Onde | Dizia | Passou a dizer |
| --- | --- | --- |
| *O princípio que organiza esta skill* | "Criar branch, bump, build, artefato, tag e Release é da Action. Você **não** faz nada disso na mão" | A branch efêmera, build, artefato, tag e Release continuam da Action; o bump semântico é da skill |
| *O que NÃO fazer* | "❌ Nunca criar branch de release, bump, build… na mão" | Mesma proibição, com exceção única e explícita para o bump semântico na `release/current` |

Se eu tivesse só acrescentado o passo 5.1, a skill teria uma instrução no meio
do arquivo e duas proibições dela no começo e no fim.

### Drift do Pacote 1 encontrado de passagem

A §1 da referência ainda descrevia o issue workflow como **"as 8 etapas"**, com
o diagrama na ordem antiga — `Documentar` antes de `Análise Final - Rafinha`.
O Pacote 1 inverteu essas duas colunas e essa página não foi atualizada.

Corrigido: 10 colunas, ordem vigente, e a coluna da direita agora mostra os
dois passos novos do ciclo de release.
