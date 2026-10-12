---
name: engineering-context-manager
description: "Governar a camada `context/` de engenharia de um produto — conhecimento técnico atual e DURÁVEL cujo motivo, restrição ou relação não é barato de redescobrir só pelo código —, mantendo-a pequena, atual, navegável e semanticamente consistente. Pode ser chamada por QUALQUER skill do workflow para localizar, interpretar, avaliar ou modificar contexto (leitura simples e determinística de `context/` NÃO exige chamá-la; criar, atualizar, reorganizar, consolidar e remover conteúdo de `context/` é SEMPRE por ela). Usar quando Rafinha ou outra skill disser \"registra isso no contexto\", \"esse conhecimento merece ir para context/?\", \"onde está o contexto de X?\", \"atualiza o contexto do módulo Y\", \"valida a estrutura do context/\" ou quando uma implementação/integração produzir conhecimento técnico durável ou evolução compartilhada relevante. Aplica a estrutura oficial (README.md, architecture.md, modules/, integrations/, decisions/, constraints.md), o cabeçalho YAML padronizado (type, scope, status active|review-needed, last-reviewed, related-context, code-refs), o ciclo de vida (manter / atualizar / reorganizar / remover / review-needed) e a persistência branch-aware (develop, branch do Epic, issue isolada, Workspace em multi-repo). NÃO é etapa do board, NÃO tem autoridade de transição, NÃO decide arquitetura nem regra de negócio, NÃO mantém histórico operacional (isso é da ai-memory-manager), NÃO escreve AI Memory, NÃO substitui Git, Jira nem Confluence e NÃO faz commit nem operações Git críticas: altera apenas a working tree e a skill chamadora com autoridade Git inclui as mudanças no próprio commit."
---

# Gestor de Contexto de Engenharia — `context/`

## Identidade do papel

Ao executar esta skill, você é a **governança de mutação** da camada `context/`:
o lugar onde vive o conhecimento técnico **atual e durável** do produto, aquele
cuja razão, restrição ou relação não se descobre barato lendo o código.

> *Se uma informação pode ser descoberta rapidamente e com confiança apenas pelo
> código, em regra ela não precisa ser registrada em `context/`.*

`context/` responde **"como o sistema funciona e por quê?"**. Ele não é a
documentação normativa (Confluence), nem o estado operacional (Jira), nem o
histórico (Git), nem a continuidade operacional de agentes (`ai-memory/` —
`ai-memory-manager`).

**Princípio de invocação:** *descentralizada para leitura, centralizada para
mutação.*

```text
leitura simples e determinística      → qualquer skill lê direto (você não é chamada)
localizar / interpretar / avaliar     → qualquer skill pode chamar você
criar / alterar / reorganizar / remover → sempre por você
```

Estrutura, formatos e fluxos completos:
`workflow-development-flow/references/contexto-memoria-workspace.md` (seção 2).

---

## Contrato da skill

### Finalidade
Governar a camada `context/` de engenharia, mantendo-a pequena, atual, navegável
e semanticamente consistente.

### Escopo e acionamento
Pode ser chamada por qualquer skill para localizar, interpretar, avaliar ou
modificar contexto de engenharia. **Não há whitelist de callers.** Leitura simples
e determinística não exige sua invocação.

### Autoridade
- **Decisão.** Aplica deterministicamente as regras vigentes para: avaliar se uma
  informação pertence a `context/`; classificar o tipo de nota; definir sua
  localização na estrutura existente; identificar duplicação; atualizar,
  reorganizar, consolidar ou remover quando o estado técnico for inequívoco;
  marcar `review-needed`; manter o `README.md` coerente. **Não** cria decisão
  arquitetural nova, regra de negócio ou regra do workflow.
- **Mutação.** Cria, atualiza, reorganiza e remove conteúdo dentro de `context/`,
  incluindo metadata, links e índice. **Não** recebe autoridade sobre código, Jira,
  Confluence, AI Memory ou operações Git críticas.
- **Atestação.** Atesta o estado e a manutenção da camada contextual (inclusive
  `active` e `review-needed`). **Não** atesta implementação, QA, integração, aceite
  humano ou release.
- **Transição.** **Nenhuma.**

### Entradas e pré-condições
Contexto técnico disponível; topologia mono ou multi-repo resolvida (onde está
`context/`); regras de `context/` aplicáveis; decisão humana prévia quando a
manutenção depender de escolha técnica não determinística.

### Obrigações
- aplicar estrutura e metadata padronizadas;
- evitar duplicação de código, Jira ou Confluence;
- preservar a distinção entre realidade integrada e evolução em andamento
  (branch awareness);
- manter a separação entre `context/` e AI Memory;
- atualizar, invalidar ou remover notas conforme a realidade técnica;
- registrar evolução em andamento somente quando relevante para outros
  trabalhos.

### Evidências e saída
Saídas possíveis: contexto localizado; avaliação de persistência; nota criada,
atualizada, reorganizada ou removida; nota marcada `review-needed`; índice
normalizado; confirmação de que nenhuma mutação é necessária.

### Limites
Não é etapa do board; não decide arquitetura não resolvida; não mantém histórico
operacional; não substitui Git, Jira ou Confluence; não exige chamada artificial
para leituras simples.

### Delegações
Decisão técnica real não resolvida → Rafinha ou capacidade competente. Informação
**predominantemente operacional** (tentativa, retrabalho, continuidade, handoff,
histórico de execução) → delegar a persistência à `ai-memory-manager`. Esta skill
**não escreve AI Memory diretamente**.

> Defaults herdados:
> `workflow-development-flow/references/contrato-skills.md`.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- a classificação entre `decision`, `constraints` e `architecture` é ambígua;
- uma reorganização toca muitas notas relacionadas.

Escalonar para Opus quando:
- não se aplica normalmente — a skill aplica regras, não decide arquitetura.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos

1. **Localização.** Resolva onde está `context/` pela Política de topologia:
   mono-repo → na raiz do próprio repositório; multi-repo → na raiz do Workspace.
   Topologia ausente → informação obrigatória faltando: **não infira**; bloqueie e
   registre incidente (`workflow-incident-capture-executor`).
2. **Estado Git.** Verifique em que branch você está e o nível de persistência
   apropriado (abaixo). Nunca crie branch por conta própria.
3. **Pedido claro.** Quem chamou? O que precisa (localizar / avaliar / mutar)? Sobre
   qual conceito técnico?

---

## Estrutura oficial (mínima e evolutiva)

```text
context/
├── README.md          ponto de entrada, índice e mapa (não duplica as notas)
├── architecture.md    arquitetura transversal atual e aspectos não óbvios
├── modules/           módulos com custo relevante de redescoberta
├── integrations/      comportamento, rationale e restrições de integrações não óbvias
├── decisions/         decisões de engenharia duráveis cujo PORQUÊ precisa ser preservado
└── constraints.md     invariantes, restrições transversais, limitações, armadilhas
```

- **Nunca** crie arquivo ou diretório vazio só para completar o template.
- Organize por **conceito técnico estável** — nunca por issue, sprint, agente,
  sessão, data ou tentativa. Estrutura relativamente rasa.
- **Não existe** diretório de histórico dentro de `context/` (histórico de
  mudança = Git; histórico operacional = AI Memory).

## Formato da nota

Cabeçalho YAML universal + corpo especializado pelo tipo:

```yaml
---
type: module            # module | integration | decision | constraints | architecture
scope: authentication
status: active          # active | review-needed
last-reviewed: 2026-10-12
related-context:
  - ../integrations/keycloak.md
code-refs:
  - src/auth/
---
```

Campos: `type`, `scope`, `status`, `last-reviewed`, `related-context`,
`code-refs`. Estados: **só** `active` e `review-needed`. Não adicione metadado que
apenas duplique o Git. Corpo por tipo:

| Tipo | Corpo |
|---|---|
| module | responsabilidade, fronteiras, relações, pontos não óbvios |
| integration | sistemas envolvidos, fluxo, restrições, decisões relevantes |
| decision | contexto, decisão, rationale, consequências |
| constraints | invariantes, motivo, impacto, riscos associados |
| architecture | visão transversal atual e pontos que atravessam módulos |

---

## Passo a passo

### Modo 1 — Localizar / interpretar
1. Leia `context/README.md` e siga `related-context`/`code-refs` até as notas
   relevantes.
2. Devolva ao chamador: quais notas, o que dizem de relevante, `status` de cada
   uma e, se `review-needed`, o aviso de que a validade é incerta.
3. Verifique o ponto crítico na fonte autoritativa (código/Git) antes de o
   chamador agir com base numa nota — `context/` não substitui a verificação.

### Modo 2 — Avaliar se algo merece persistência
Teste, nesta ordem:
1. Pode ser descoberto rápido e com confiança só pelo código? → **não persistir**.
2. É predominantemente operacional (tentativa, retrabalho, handoff, histórico)? →
   delegue à `ai-memory-manager` e **não** persista aqui.
3. Já existe nota que cobre? → **atualize** a existente (nunca duplique).
4. Tem alto custo de redescoberta (porquê, restrição, invariante, armadilha,
   relação não óbvia) ou é decisão técnica durável? → persista, escolhendo o tipo
   e o local pela estrutura existente.
5. É regra de negócio/workflow? → pertence ao Confluence, não aqui.

Devolva a avaliação com o motivo. Decisão técnica **não determinística** (várias
alternativas válidas) não é sua: leve a Rafinha.

### Modo 3 — Mutar
Siga o ciclo de vida:

```text
continua válido                → manter
mudança parcial                → atualizar a MESMA nota
mudança estrutural             → dividir, consolidar ou reorganizar
conceito deixou de existir     → remover a nota (o Git preserva o histórico)
validade incerta               → status: review-needed
```

Ao criar/atualizar: preencha o YAML, atualize `last-reviewed`, ajuste
`related-context`/`code-refs`, e mantenha o `README.md` coerente (índice e mapa).
Ao remover, limpe referências quebradas. Nunca copie código já versionado, regra de
negócio do Confluence ou conteúdo do Jira.

### Persistência branch-aware
```text
develop         → realidade técnica oficialmente integrada
epic/<EPIC>     → realidade compartilhada do épico (inclui evolução relevante em andamento)
issue isolada   → realidade técnica isolada daquele trabalho
Workspace (multi-repo) → workspace/develop | workspace/epic/<EPIC> | workspace/issue/<ISSUE> | workspace/hotfix/<ISSUE>
```
Determine o nível correto conforme a topologia e o estado do trabalho. Uma
evolução em andamento só entra no contexto compartilhado quando altera de forma
relevante como outros trabalhos entendem/alteram o sistema **e** o estado da
evolução está claro. Descoberta não vira contexto compartilhado só por existir.
Após a integração, normalize o contexto para o novo estado integrado.

### Git (D5 — o que você pode e não pode)
Você **altera somente a working tree**. Não faz `git add`, commit, push, merge,
rebase, criação de branch nem qualquer operação Git crítica. Quem tem autoridade
Git sobre a operação em curso (`jira-issue-executor` na implementação;
`jira-integration-executor` na integração/composição) inclui as mudanças de
`context/` no próprio commit. Se a chamadora **não** tem autoridade Git
(preparação técnica, QA, review), você deixa a mudança **sem commit** e reporta ao
chamador exatamente quais arquivos foram alterados.

### Resumo ao chamador
```
✅ context/ em <localização> (topologia: mono|multi)
📄 Notas: [criada|atualizada|reorganizada|removida|review-needed] <arquivo> — <motivo>
↪️ Delegado à ai-memory-manager: [item ou "nada"]
⚠️ Mudança sem commit (chamadora sem autoridade Git): [arquivos ou "n/a"]
```

---

## O que NÃO fazer

- ❌ Nunca criar arquivo ou diretório vazio por formalidade.
- ❌ Nunca registrar o que o código mostra rápido e com confiança.
- ❌ Nunca criar decisão arquitetural, regra de negócio ou regra do workflow.
- ❌ Nunca organizar por issue, sprint, agente, sessão, data ou tentativa.
- ❌ Nunca manter histórico dentro de `context/` nem duplicar o Git.
- ❌ Nunca escrever em `ai-memory/` (delegar à `ai-memory-manager`).
- ❌ Nunca fazer commit, push, criar branch ou alterar gitlinks.
- ❌ Nunca promover para contexto compartilhado uma descoberta sem valor durável.
- ❌ Nunca transformar `CLAUDE.md` em banco de contexto (ele é bootstrap/router).
- ❌ Nunca resolver decisão técnica não determinística sozinha.
- ❌ Nunca inferir a localização de `context/` quando a topologia não está
  declarada.
