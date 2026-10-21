# Contrato das skills

> **Interface contratual de cada capacidade do workflow.** A skill final é
> **Contrato + Operação técnica**: o contrato diz *o que a skill está autorizada
> e obrigada a fazer*; a operação diz *como*. Nenhuma das camadas substitui a
> outra. Espelho: página **Contrato das skills** no Confluence (CS1) e a ficha de
> cada skill.

## Anatomia obrigatória

```text
SKILL
├── CONTRATO                          (bloco "## Contrato da skill" no SKILL.md)
│   ├── finalidade
│   ├── escopo e acionamento
│   ├── autoridade de decisão
│   ├── autoridade de mutação
│   ├── autoridade de atestação
│   ├── autoridade de transição
│   ├── entradas e pré-condições
│   ├── obrigações
│   ├── evidências e registros
│   ├── saída
│   ├── limites
│   └── delegações
└── OPERAÇÃO TÉCNICA                  (o resto do SKILL.md)
    ├── passo a passo, ferramentas, comandos, integrações
    ├── formatos, templates, rotinas, fallbacks técnicos autorizados
    └── Model Policy (nível 0–4), recovery, detalhes específicos
```

O contrato **não repete** sequência de comandos, chamadas de ferramenta, sintaxe
de API, passo a passo de Git, templates extensos, recovery ou algoritmos — isso é
operação. A operação **não pode** ampliar a autoridade da skill, dispensar
obrigação contratual, inventar transição ou criar fallback que o contrato não
permita.

## Classificação de mudanças (para manutenção)

- **A — contratual:** altera autoridade, obrigação, limite, evidência, atestação,
  transição ou delegação. Deve aparecer no contrato documentado **e** no
  comportamento executável.
- **B — operacional:** novo passo, ferramenta, comando, formato, algoritmo.
  Respeita o contrato.
- **C — compatível:** procedimento que já cumpre o contrato é preservado, não
  reescrito.

Procedimento técnico que permita o que o contrato proíbe → corrigir. Contrato que
exige o que a operação não faz → ampliar a operação. Contradição ou lacuna
*dentro* do contrato → registrar e levar a Rafinha (nunca decidir em silêncio).

## Defaults herdados por TODAS as skills

(valem mesmo sem repetição no contrato individual)

- **Silêncio não concede autoridade.** Mutação, decisão, atestação ou transição
  não coberta pelo contrato não pode ser assumida.
- **Acesso técnico não é autoridade.** Ferramenta, token, permissão ou comando
  disponível não amplia o contrato.
- **Exceção própria é opt-in.** Só há autoridade autônoma de exceção/override
  quando expressamente declarada. Sem declaração, a autoridade é nenhuma: a skill
  pode *consumir* exceção válida ou *solicitar* decisão, nunca criá-la.
- **Conflito contratual não é resolvido pela skill.** Duas regras válidas
  incompatíveis → Rafinha decide.
- **Problema mecânico dentro da capacidade não é conflito.** Pode ser resolvido
  quando o contrato permitir explicitamente.
- **Delegação não transfere autoridade.** A chamadora continua limitada ao
  próprio contrato; a chamada atua só dentro do dela.
- **Evidência não substitui atestação.** Observar evidência não dá autoridade
  para declarar o resultado de outra capacidade.
- **Operação técnica não cria autoridade.** Nenhum passo, script ou ferramenta
  concede poder que o contrato não reconheça.
- **Chamada pela orquestradora remota.** Quando a `workflow-remote-orchestrator`
  despacha uma skill, a skill chamada executa o próprio Passo 0, gates e registros
  normalmente; o escopo repassado conta como confirmado (Contrato do Workflow,
  B.2), mas o modo da Integração e a autorização de Modo B nunca são herdados.
- **O executor não é autoridade.** Claude Code e Codex são executores alternativos
  (Contrato do Workflow, A.10): trocar de executor não troca autoridade, escopo,
  gates, evidências nem transições. Capacidade que o executor não tem homologada
  bloqueia o gate; não há fallback silencioso.
- **Identidade do executor.** Todo registro operacional no Jira inclui `Executor`
  (e, quando aplicável, `Tentativa`, `Escopo fechado`, `Evidências`, `Handoff` —
  A.9). O título contratual do comentário não muda por causa do executor.
- **Claim antes de mutar.** Skill que muta issue abre o claim de execução depois de
  fechar o escopo e antes da primeira mutação, e para diante de claim vigente de
  outro executor (Contrato do Workflow, B.5).
- **Reconciliar antes de retomar.** Retomada — pelo mesmo executor em sessão nova
  ou por outro executor — exige recovery check e reconciliação do estado local
  (Execution State, `ai-memory/`) com Jira, Git e GitHub; handoff entre executores
  é registrado (B.5). O estado local nunca é instrução cega.
- **Nível, não modelo.** A skill declara na `## Model Policy` um **nível** (0–4,
  `workflow-development-flow` §11); cada executor o mapeia para a própria
  configuração. A skill recomenda o escalonamento e Rafinha decide.

Estes defaults são **referenciados**, não copiados para cada `SKILL.md`.

## Regra de leitura durante a execução

O contrato da skill se lê junto com: Contrato do Workflow → Tipo aplicável →
Políticas ativas → Etapa atual → Contrato Efetivo do ticket (Passo 0,
`contrato-efetivo.md`) → escopo operacional da execução.

- **Contrato Efetivo:** o que a issue exige.
- **Contrato da skill:** quais partes a skill pode decidir, executar, mutar,
  atestar e transicionar.
- **Corpo operacional:** como realiza.
- **Escopo operacional:** sobre quais alvos, nesta execução.

## O que o `SKILL.md` contém

- as regras contratuais **locais** que a skill precisa para obedecer sua
  autoridade;
- as verificações para consumir Workflow, Tipo, Política, Etapa e Contrato
  Efetivo (Passo 0);
- todo o procedimento técnico da capacidade.

Ele **não copia** o Contrato do Workflow, todos os tipos ou todas as políticas.

## Drift

- **Confluence** define normativamente como a skill se comporta; **`SKILL.md`**
  demonstra o implementado. Diferença é drift.
- Regra no `SKILL.md` não autoriza alterar o Confluence para aceitá-la; regra do
  Confluence não implementada não está cumprida. Drift contratual é reconciliado,
  não mascarado.

## Escopo — skills incluídas e excluídas

Incluídas (24): `workflow-development-flow`, `workflow-remote-orchestrator`, `jira-sprint-intake-executor`,
`jira-issue-decision-resolver`, `jira-technical-preparation-executor`,
`jira-hotfix-creator`, `jira-issue-creator`, `jira-issue-executor`,
`jira-integration-executor`, `jira-qa-executor`,
`jira-human-validation-executor`, `jira-doc-executor`, `jira-review-executor`,
`jira-release-executor`, `engineering-context-manager`, `ai-memory-manager`,
`product-doc-writer`, `tech-doc-writer`, `screen-doc-writer`, `user-doc-writer`,
`workflow-doc-writer`, `doc-pendency-resolver`, `flutter-development-standards`,
`workflow-incident-capture-executor`.

**Excluídas** (classificadas no Confluence como não relacionadas ao workflow de
desenvolvimento): `task-creator-trabalho`, `weekly-organizer`.

## Capacidades de suporte à contextualização

Leitura simples e determinística de `context/` ou `ai-memory/` → qualquer skill,
direto. Localizar/interpretar/avaliar → pode chamar a skill especializada.
Criar/alterar/reorganizar/remover/arquivar → **sempre** pela
`engineering-context-manager` (contexto) ou `ai-memory-manager` (memória). As
skills consumidoras produzem fatos operacionais e leem direto, mas não escrevem,
reorganizam nem arquivam essas camadas por conta própria. Ver
`contexto-memoria-workspace.md`.
