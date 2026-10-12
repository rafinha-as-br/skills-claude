# Preparação técnica e Hotfix

> Contratos operacionais da etapa `Preparação técnica - Claude`
> (`jira-technical-preparation-executor`) e do tipo **Hotfix**
> (`jira-hotfix-creator`). Espelho: páginas **Preparação técnica e atestado** e
> **Hotfix e fast-track** no Confluence (CS1).

---

## Parte 1 — Preparação técnica - Claude

### Princípio

```text
maturação funcional    → saber o que precisa ser feito          (intake)
decisão humana         → decisões reservadas a Rafinha          (Decisão - Rafinha)
design                 → material visual aprovado               (Design de produto - Rafinha)
preparação técnica     → verificar e preparar condições técnicas conhecidas
Ready                  → trabalho normal pronto para autorização de implementação
execução               → implementar o que já está preparado    (Fazer - Claude)
Hotfix                 → execução emergencial controlada
```

> `Fazer - Claude` não é o lugar normal para descobrir requisitos técnicos
> previsíveis, dependências conhecíveis, design obrigatório ausente, topologia
> Git não preparada ou condições de ambiente que poderiam ter sido verificadas
> antes. **Issue normal é preparada para entrar no fluxo. Hotfix entra no fluxo
> porque não pode esperar a preparação normal.**

Pergunta central da etapa: *existem condições técnicas conhecidas e suficientes
para que esta issue seja executada agora sem que o executor precise descobrir ou
preparar problemas previsíveis durante a implementação?*

### Limites

A skill é responsável por **prontidão técnica**. Não implementa a feature; não
absorve trabalho de outra issue; não cria/altera/aprova design; não redefine
regra de negócio; não toma decisão reservada a Rafinha; não executa QA completo
nem code review; não muda produto/infra de forma persistente sem autoridade
explícita; não transforma impedimento em alteração escondida de código; não
reabre histórico por inferência.

### Relação com as etapas vizinhas

- **Intake** → maturação funcional; pode identificar requisitos técnicos citados
  na issue, mas verificar disponibilidade real é desta etapa. Issue madura **não
  vai direto a `Ready`**.
- **`Decisão - Rafinha`** → só decisão funcional/de produto. Decisão **técnica**
  descoberta aqui permanece aqui: a skill pergunta diretamente a Rafinha; se ele
  decidir, registra e continua; se não, registra a pendência, **mantém a issue em
  `Preparação técnica - Claude`** e não a move para `Decisão - Rafinha`.
- **`Design de produto - Rafinha`** → a skill valida só a *disponibilidade
  operacional* do material já aprovado (evidência de aprovação, existência do
  Design Package, correspondência com a issue, arquivos necessários, localização
  correta). Não reavalia qualidade visual. Em multi-repo o pacote fica no
  repositório afetado: `repo-afetado/.claude/design-packages/<ISSUE-KEY>/`.
- **`context/` e AI Memory** → leitura direta quando a localização é
  determinística; avaliação/localização via `engineering-context-manager`;
  mutações de contexto pela `engineering-context-manager`; mutações de AI Memory
  pela `ai-memory-manager`.

### Unidade de análise

A issue permanece a unidade movimentada no quadro. A skill pode consultar Epic
pai, issues relacionadas, dependências, `context/`, AI Memory, Git, Jira, ambiente,
serviços e recursos técnicos. Isso não autoriza expandir o escopo da issue.

### Dependências técnicas

Princípios: `develop` é a base mais forte quando a dependência já está integrada;
issues do mesmo Epic podem consumir trabalho já integrado à branch do Epic;
branches de issues **não** dependem diretamente umas das outras; dependência
entre Epics diferentes exige disponibilidade em `develop`; Jira, eventos Git e o
próprio Git são reconciliados na divergência.

A skill: identifica a dependência; verifica se já existe issue que a representa;
verifica disponibilidade; identifica blocker direto ou propagado; impede `Ready`
quando a base necessária não está disponível; não faz pergunta humana quando o
contrato já determina a resposta.

### Topologia Git — criação autônoma de branches

Autoridade explícita para criar branches cuja **existência, base e nomenclatura**
sejam determinadas de forma inequívoca pelo workflow e necessárias à issue.
Caso principal: **branch de Epic** (a partir da `develop` vigente, publicada no
remoto quando faz parte da preparação normal). Em multi-repo: branch de Epic do
Workspace (`workspace/epic/<EPIC-KEY>`) e as branches de Epic nos repositórios
afetados. Registrar evidência no atestado. Isto é *preparação estrutural
autorizada*, não "trabalho técnico ausente".

Não recebe: merge, deleção arbitrária de branch, `force push`, rebase de
trabalho existente, reescrita de histórico, resolução de conflito de integração,
mudança de base de branch já usada, criação de branch não determinada pelo
workflow.

```text
criar estrutura Git que o contrato já determina → Preparação Técnica pode fazer
alterar trabalho Git existente ou decidir integração → não pertence a ela
```

**Retrabalho após promoção de Epic (D4).** Quando uma issue reprovada pertence a
um Epic já promovido (branch de Epic excluída), ela retorna para
`Preparação técnica - Claude`: a skill **recria a branch de Epic a partir da
`develop` vigente**, revalida a prontidão e só então libera novo `Ready`. A
`jira-issue-executor` nunca recria branch de Epic.

### Bootstrap de Workspace

A skill **não cria Workspace do zero.** O bootstrap inicial multi-repo é
manual de Rafinha (guia *Como montar um projeto*, passo 1). Ela pode validar
Workspace existente, Submodules, topologia e preparar branches operacionais
permitidas. Workspace obrigatório inexistente ou inconsistente de forma que
impeça execução segura → a issue permanece em Preparação técnica e aponta o
procedimento manual.

### Ambiente e infraestrutura

Verificar pré-requisitos técnicos relevantes quando a disponibilidade pode ser
determinada razoavelmente antes da execução (Docker, containers, banco, Kafka,
RabbitMQ, Redis, serviços locais/remotos, APIs externas, runtimes, SDKs,
ferramentas, configurações, acessos, artefatos, recursos de infra). Constar na
descrição não comprova disponibilidade. Os comandos concretos são detalhe
operacional e não criam autoridade.

### Classificação dos achados (toda constatação relevante cai em uma)

1. **Determinístico** — há regra vigente que resolve: aplicar, registrar evidência
   se necessário, continuar, não interromper Rafinha.
2. **Impedimento operacional** — condição de ambiente/operação que não é novo
   trabalho de engenharia. Resolve sozinha só se a ação já for autorizada pelo
   contrato **e** for segura, reversível, preparatória e objetiva (ex.: criar
   branch determinística). Sem autorização expressa, não ganha autoridade por
   inferência; se exigir trabalho persistente real de engenharia, reclassifica.
3. **Trabalho técnico ausente** — trabalho real de engenharia ainda não
   representado no fluxo. A skill **não executa**. Primeiro procura issue Jira
   equivalente:
   - existe → reutiliza, registra a dependência, evita duplicação, mantém a
     original bloqueada quando necessário;
   - não existe → determina semanticamente o tipo oficial, prepara o contexto e
     **delega a criação a `jira-issue-creator`**. Sem whitelist de tipos: pode
     originar necessidade de qualquer tipo oficial desde que a classificação seja
     semanticamente correta e os contratos do tipo sejam respeitados. Descrição
     do trabalho derivado preserva: issue de origem, origem na Preparação
     Técnica, trabalho necessário, motivo, dependência/blocker, impacto, contexto
     técnico, evidências (links de dependência nativos do Jira podem
     complementar). Se houver urgência compatível com Hotfix → encaminha à
     `jira-hotfix-creator`, que qualifica; o `jira-issue-creator` materializa.
4. **Decisão técnica** — mais de uma alternativa válida sem resolução
   determinística: perguntar diretamente a Rafinha; registrar a decisão; continuar
   se possível; senão manter em Preparação técnica (não move para `Decisão`).

### Blockers

> **Blocker pede resolução de condição; decisão pede escolha.**

- **Direto:** o problema pertence à própria issue.
- **Propagado:** decorre de dependência bloqueada.

Um blocker impede avanço a `Ready`, é registrado, não precisa interromper a
preparação de issues independentes e não autoriza execução fora do escopo.

### Atestado da Preparação Técnica

Toda execução relevante deixa **um novo comentário estruturado na própria
issue**. Registra só o necessário para provar se a issue está ou não
tecnicamente pronta. A chave da issue não precisa ser repetida; o Epic aparece
quando relevante (dependência, branch, blocker, contexto). Informação não
aplicável: `N/A`. Não existe identificador customizado de revalidação — cada
nova execução gera novo comentário e o histórico cronológico do Jira dá a
rastreabilidade.

```markdown
## Preparação Técnica — Atestado

**Resultado:** PRONTA | BLOQUEADA | AGUARDANDO DECISÃO TÉCNICA

### Dependências
- <dependências relevantes e disponibilidade>

### Design
- <OK | N/A | impedimento relevante>

### Infraestrutura / Ambiente
- <OK | N/A | impedimento relevante>

### Git
- <condição relevante de branch/topologia>

### Blockers
- Diretos: <nenhum ou descrição>
- Propagados: <nenhum ou descrição>

### Decisões técnicas
- <nenhuma | decisões resolvidas | pendências>

### Trabalho derivado
- <nenhum | issues existentes reutilizadas | issues originadas>

### Pendências
- <nenhuma ou itens que impedem Ready>
```

Trabalho derivado registra reutilização e criação, ex.:
`ABC-120 — reutilizada como dependência existente`;
`ABC-125 — originada nesta preparação para criar infraestrutura X`.

**Resultados formais e transição:**

```text
PRONTA                       → pode avançar para Ready
BLOQUEADA                    → permanece em Preparação técnica - Claude
AGUARDANDO DECISÃO TÉCNICA   → permanece em Preparação técnica - Claude
```

### Relação com `jira-issue-executor`

Para fluxo normal, o executor assume que issue vinda de `Ready` concluiu a
Preparação Técnica; faz apenas verificações defensivas mínimas e **não
reconstrói o preflight**. Não cria branch de Epic. Cria só a branch de trabalho da
própria implementação, conforme a política Git e o Contrato de Tipo. Evidência
obrigatória da Preparação ausente numa issue normal que veio de `Ready` é
**quebra de fluxo** (a execução para e reporta; não é um gate numerado novo).

---

## Parte 2 — Hotfix

### Definição

> Hotfix é trabalho emergencial, não planejado para o ciclo normal de
> seleção/preparação, que precisa ser implementado, testado, validado e integrado
> rapidamente porque não pode esperar o fluxo normal.

Alta prioridade, por si só, **não** faz uma Hotfix. Trabalho ausente não vira
Hotfix automaticamente; se puder seguir o fluxo normal sem dano operacional
imediato, é criado como o tipo normal adequado.

**Elegibilidade.** Necessidade imediata de: corrigir problema urgente;
desbloquear desenvolvimento, testes ou conclusão de trabalho; corrigir falha
operacional relevante; ou atender determinação explícita de Rafinha. Pode estar
vinculada a Epic ou existir sem Epic (vínculo organizacional, não altera o fluxo
Git).

### Quem faz o quê

```text
jira-technical-preparation-executor → pode identificar necessidade candidata a Hotfix
jira-hotfix-creator                 → qualifica e prepara a Hotfix (fast-track)
jira-issue-creator                  → materializa a issue (nunca a hotfix-creator)
jira-issue-executor                 → implementa
```

Rafinha também pode pedir uma Hotfix diretamente.

### Criação no Jira

Depois da qualificação, a `jira-issue-creator` cria a Hotfix **diretamente em
`Fazer - Claude`** — exceção explícita e estreita à regra de que tickets novos
nascem em `A fazer`/backlog. Criar em `Fazer - Claude` **não apaga** as
obrigações das etapas anteriores; o fast-track registra como cada uma foi tratada.

### Plano de fast-track — fica integralmente na descrição

```markdown
## Contexto da Hotfix

<problema urgente, impacto e motivo pelo qual não pode seguir o fluxo normal>

## Objetivo

<resultado que precisa ser alcançado>

## Escopo

<o que será alterado e limites da Hotfix>

## Fast-track

### Etapas aplicáveis
- <etapas que serão mantidas>

### Etapas dispensadas
- <etapa> — <justificativa>

## Condições para implementação

- <pré-requisitos realmente necessários>
- <dependências críticas>
- <condições técnicas mínimas>

## Estratégia Git

- Branch base: develop
- Branch: hotfix/<ISSUE-KEY>
- Destino final: develop

## Testes e validação

- <testes necessários>
- <forma de validar a correção>
- <regressões relevantes>

## QA

<como o QA será tratado>

## Documentação

<necessária | dispensada | realizada posteriormente>

## Revisão

<como a revisão será tratada>

## Autorização do fast-track

<contexto da autorização ou aprovação aplicável>
```

Algo não aplicável: registrar objetivamente `N/A`. A estrutura não pode virar
formulário burocrático.

**Descrição × comentários.** Descrição = definição do trabalho, contexto
emergencial, plano de fast-track, etapas aplicáveis/dispensadas, condições,
estratégia de teste/validação, autorização. Comentários = evidências durante/
depois da execução, resultados de teste, acontecimentos operacionais, registros
posteriores. O plano inicial **não** se fragmenta em comentários.

### Estados das obrigações no fast-track

| Estado | Quando usar |
|---|---|
| **Não aplicável** | A obrigação não faz sentido para aquela Hotfix (ex.: documentação realmente não se aplica) |
| **Excepcionada** | A obrigação normalmente seria aplicável, mas Rafinha autorizou explicitamente a dispensa (ex.: `requires-design` ativo, design normalmente exigido, Rafinha autoriza seguir sem Design Package) |
| **Satisfeita** | A obrigação já foi efetivamente cumprida |

`Satisfeita ≠ Não aplicável ≠ Excepcionada`. Obrigação dispensada nunca é marcada
como satisfeita.

### Autoridade sobre o fast-track

Rafinha é a autoridade final: define o fast-track, aprova proposta da IA, mantém
uma etapa aplicável, autoriza dispensa quando não compromete a segurança da
entrega. A autorização fica registrada na descrição da Hotfix.

### Qualidade e segurança

Hotfix acelera o fluxo, **não reduz o rigor técnico**. Podem ser dispensados
conforme o caso: Design Package, vínculo com Epic, metadata não essencial,
preparação/documentação concluível depois sem risco. **Não podem ser ignorados:**
segurança técnica mínima, testes necessários, validação suficiente para comprovar
a correção, escopo da Hotfix, integração controlada.

### Política Git da Hotfix

```text
develop → hotfix/<ISSUE-KEY> → testes/validação → develop
```

Convenção `hotfix/<ISSUE-KEY>` (ex.: `hotfix/GEO-123`). Base sempre `develop`;
branch de Epic **nunca** é base; vínculo com Epic não altera o fluxo Git; destino
final sempre `develop`. Multi-repo: `workspace/hotfix/<ISSUE-KEY>` representa
temporariamente a composição completa (ver `contexto-memoria-workspace.md`).

### Integração da Hotfix

O tipo determina contratualmente **Modo C — integração direta em `develop`**; a
`jira-integration-executor` não pergunta o modo a Rafinha. Depois de integrar,
registra o resultado, preserva as evidências e **mantém a Hotfix em
`Integração`**: não envia automaticamente para `QA - Claude` nem outra coluna.

### QA, documentação, revisão e validação em Hotfix

Não há dispensa global automática só pelo tipo. O fast-track registra quais
continuam aplicáveis e quais são satisfeitas / não aplicáveis / excepcionadas. A
Hotfix não atravessa etapa inútil por formalidade, mas etapa necessária à
segurança e comprovação da correção não é omitida só por urgência.

### Governança manual das transições

Para Hotfix, **Rafinha controla todas as transições físicas entre colunas.**
Quando ele posiciona a Hotfix numa coluna, a skill da etapa: executa só sua
responsabilidade; registra resultado e evidências; **não move**; deixa a Hotfix na
mesma coluna. Vale para implementação, análise/revisão humana, integração, QA,
validação, documentação, review final e conclusão. QA aprovado não move; QA
reprovado não devolve a `Fazer - Claude`; documentação concluída não envia a
review; review aprovado não move para `Concluído`. O fast-track determina quais
obrigações se aplicam, **não a próxima coluna**.

### Relação Preparação Técnica ↔ Hotfix

1. procura issue existente que já cubra a necessidade; 2. se existir, reutiliza;
3. senão, classifica o tipo adequado; 4. trabalho normal → prepara contexto e
delega ao `jira-issue-creator`; 5. urgência compatível com Hotfix → encaminha à
`jira-hotfix-creator`; 6. ela qualifica e prepara; 7. `jira-issue-creator`
materializa; 8. a issue original permanece bloqueada até a dependência ser
resolvida; 9. depois, a Preparação Técnica reexecuta e produz novo atestado.

### Retroatividade

Não autoriza: migrar issues concluídas; reabrir releases; alterar histórico por
causa do significado antigo de `Ready`; transformar trabalhos antigos em Hotfix;
criar nova política de release; dar à Preparação Técnica administração Git
irrestrita; dar à Hotfix bypass ilimitado de segurança.
