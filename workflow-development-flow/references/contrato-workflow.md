# Contrato do Workflow — regras universais

> **Fonte única das regras universais do Workflow Rafinha-Claude.** Toda skill
> consome este contrato; nenhuma o redefine. Camadas irmãs: Tipo (SKILL.md §3),
> Política (`politicas.md`), Etapa (SKILL.md §4–5 e §5.13–5.14), Contrato
> Efetivo (`contrato-efetivo.md`), Contrato das skills (`contrato-skills.md`).
> Espelho normativo: página **Contrato do Workflow** no Confluence (CS1).

Este contrato não substitui o procedimento técnico de nenhuma skill. Ele define
as restrições e garantias que esses procedimentos precisam obedecer. Regras
universais podem aparecer no `SKILL.md` como verificação de execução, mas a
definição normativa mora aqui.

---

## Bloco A — Autoridade

### A.1 Autoridade de informação

1. **Confluence** — autoridade normativa sobre as definições do workflow.
2. **Jira** — estado e histórico operacional das issues e da execução do
   workflow. O ticket é a fonte de verdade operacional consumida pelas skills.
3. **Código** — estado técnico atual da implementação.
4. **Git/GitHub** — versionamento, branches, commits, integração e histórico
   técnico.
5. **Workspace + Git Submodules** (quando a Política multi-repo estiver ativa)
   — composição versionada do produto e seus gitlinks.
6. **`context/`** — realidade técnica atual e conhecimento de engenharia,
   governado pela `engineering-context-manager`. Não substitui Código, Git nem
   documentação normativa.
7. **AI Memory** (`ai-memory/`) — continuidade operacional e handoff, governada
   pela `ai-memory-manager`. Não é fonte de verdade de Jira, Git ou produto.
8. **`SKILL.md`** — comportamento operacional *efetivamente implementado* de
   cada skill. Demonstra o que a skill executa; não tem autoridade normativa
   para sobrescrever em silêncio uma regra aprovada.
9. **AIO Tests** — registro detalhado da execução de QA. O Jira continua sendo
   a autoridade sobre o estado e histórico operacional do QA no workflow.

**Confluence × `SKILL.md`.** O Confluence define o que *deve* ser; o `SKILL.md`
revela o que *é*. Quando divergem há **drift**, e a divergência nunca se resolve
escolhendo um lado automaticamente:

1. Se for só detalhe técnico compatível com o contrato → sincronizar a descrição.
2. Se tocar autoridade, obrigação, gate, evidência, transição, satisfação,
   política ou outro comportamento normativo → **drift contratual**.
3. Não alterar a norma para justificar o comportamento implementado.
4. Não declarar o comportamento implementado correto só porque está no `SKILL.md`.
5. Reconciliar a implementação com o contrato aprovado, ou encaminhar a decisão
   quando a intenção normativa não estiver clara.

### A.2 Autoridade de decisão

Pertence à **skill responsável pela capacidade em execução**, nos limites do
seu próprio contrato. Coluna, estado ou informação no Jira não concedem
autoridade de decisão. Cada skill declara o que decide sozinha e o que exige
autoridade externa. Decisão fora dos limites é encaminhada à autoridade
competente e só depois usada como entrada válida.

### A.3 Autoridade de mutação

Pertence à skill responsável, nos limites do seu contrato. Acesso técnico
(token, ferramenta, permissão) **não** é autoridade para modificar. Mutação
necessária fora dos limites é encaminhada à capacidade competente.

### A.4 Autoridade de atestação

Pertence à autoridade explicitamente definida para a condição validada.
Atestar é declarar oficialmente que uma condição foi satisfeita. O Jira
*registra* o atestado, mas não o produz. Git/GitHub e AIO Tests fornecem
evidência; a conclusão é emitida pela autoridade da capacidade. Uma skill não
transforma evidência observada em certificação que pertença a outra capacidade.
Atestação humana (ou externa) nunca é substituída por skill: ela coleta
evidências, prepara contexto e registra o resultado depois.

### A.5 Autoridade de transição

Pertence à skill responsável, dentro do contrato: estado de origem permitido,
destinos possíveis e condições que autorizam cada movimento. Acesso técnico ao
Jira não concede autoridade sobre qualquer transição. A skill não move issue de
etapa que não é sua, não escolhe destino não autorizado, não pula etapas e não
antecipa transição de outra capacidade. Sem condição satisfeita, mantém a issue
no estado apropriado, sem inventar destino alternativo.

**Exceção oficial — Comando remoto.** Numa sessão remota iniciada por Rafinha em
**canal remoto homologado** (A.10), a `workflow-remote-orchestrator` executa, **como execução de comando
explícito de Rafinha registrado em comentário da issue**, apenas: (a)
`Ready → Fazer - Claude` de issue normal com atestado `PRONTA` vigente; (b) a saída
de `Análise - Rafinha`, `Análise Final - Rafinha` ou `Design de produto - Rafinha`
quando **Rafinha declara o resultado** (a orquestradora nunca escolhe nem infere o
resultado). Toda outra transição continua da skill dona da etapa. Esta exceção
**não** alcança Hotfix e **não** substitui a autorização distinta de merge do
Modo B (G15). Detalhes: `orquestracao-remota.md`.

**Exceção oficial — Hotfix.** Com `Tipo = Hotfix`, **toda autoridade automática
de transição entre colunas fica suspensa.** As skills executam só a
responsabilidade da coluna atual, registram evidências e atestações normalmente,
**não movem a Hotfix** e a mantêm na coluna em que foram acionadas. Toda
movimentação física posterior é manual, de **Rafinha**. Isso não altera
autoridades técnicas internas da etapa (ex.: em `Integração` a skill continua
resolvendo Modo C e integrando em `develop`; só não move a issue).

### A.6 Autoridade de exceção e override

Uma exceção tem duas origens possíveis: (1) autoridade formalmente delegada ao
contrato de uma skill, ou (2) autorização explícita de Rafinha. Skill sem
autoridade de exceção declarada **não cria, assume ou infere exceção** — só
consome exceção válida já autorizada ou encaminha.

Toda exceção possui, no mínimo: origem da autorização; regra/obrigação
excepcionada; escopo; motivo; vigência; registro operacional no Jira. A exceção
modifica só o que foi autorizado, não altera o workflow permanentemente e, se
recorrente, vira candidata a evolução de contrato (não precedente). Nenhuma regra
está classificada como absolutamente não excepcionável hoje.

### A.7 Autoridade de resolução de conflito

Pertence exclusivamente a **Rafinha**. Conflito = duas ou mais regras, contratos,
políticas, autoridades, evidências, interpretações ou caminhos com resultados
incompatíveis. A skill interrompe a decisão afetada, apresenta o que conflita,
reúne evidência e alternativas e **não escolhe**. A decisão é registrada na issue
(quando relacionada a uma) e não vira precedente nem altera contratos. Problema
puramente mecânico, sem escolha entre regras, não é conflito decisório.

### A.8 Autoridade humana × automatizada

Decisões reservadas a Rafinha (a automação apoia, não substitui):

1. Regra de negócio — `Decisão - Rafinha`.
2. Design de produto — `Design de produto - Rafinha`.
3. Decisão técnica não determinística — durante `Preparação técnica - Claude`
   (a issue permanece na etapa; **não** vai para `Decisão - Rafinha`).
4. Revisão de código — `Análise - Rafinha`.
5. Revisão de produto — `Análise Final - Rafinha`.

Colunas não têm autoridade por si; só representam onde a autoridade é exercida.

### A.9 Autoridade de evidência

Toda capacidade que executa operação relevante sobre uma issue/etapa produz o
registro operacional no Jira (comentário estruturado: o que foi executado, o
resultado, qual autoridade realizou/atestou, onde está a evidência) **e** possui
evidência verificável na fonte primária. Capacidades compartilhadas que operam
fora de issue (`engineering-context-manager`, `ai-memory-manager`) preservam
evidência na fonte primária e só geram registro Jira quando o contrato da
skill chamadora exige.

| Fonte primária | Evidências reconhecidas | Comprova |
|---|---|---|
| Git/GitHub | commits, diffs, PRs, merges, merge SHA, checks/Actions | versionamento, alterações, integração, checks técnicos |
| Código | estado atual dos arquivos/config/artefatos | estado técnico atual |
| AIO Tests | Cycles, Runs, casos, resultados, anexos | execução detalhada de QA |
| Confluence | páginas, conteúdo, histórico | existência e estado da documentação oficial |
| Jira | comentários, histórico, decisões registradas | estado/histórico operacional, decisões, autorizações |

Evidência só comprova fatos do escopo da sua fonte: Actions verde não prova QA
funcional nem aceite humano. Cada contrato de skill define quais evidências são
obrigatórias para considerar a execução concluída ou emitir atestado.

**Registro mínimo por operação relevante.** Todo registro operacional no Jira
carrega, no mínimo: `Executor` (Claude | Codex — quem de fato executou, A.10),
`Tentativa` (quando aplicável), `Escopo fechado` (as issues efetivamente
processadas), `Evidências` (links, SHAs, runs, páginas) e `Handoff` (origem e
destino, quando houve). O campo `Executor` não substitui o título contratual do
comentário (A.10).

### A.10 Executor técnico

**Claude Code e Codex são executores técnicos alternativos.** A escolha do
executor **não altera** a autoridade, o escopo, os gates, as evidências nem as
transições permitidas para a skill: o contrato vale igual para qualquer executor.
Ferramenta, conector, plugin ou token de um executor continuam não sendo
autoridade (A.3).

- **Nomes contratuais históricos.** Nomes de coluna (`Fazer - Claude`,
  `QA - Claude`, `Preparação técnica - Claude`, `Análise Final - Claude`), o
  sufixo `-claude` da branch, o título de comentário estruturado (ex.:
  "Implementação Claude") e as labels operacionais são **nomes do contrato**, não
  indicam o executor, e não mudam quando o executor muda — o contador de
  tentativa e o recovery dependem deles. Quem de fato agiu consta no campo
  `Executor` (A.9).
- **Capacidade ausente é bloqueio.** Se o executor não tem capacidade homologada
  que uma etapa ou gate exige (ex.: executor web para QA visual, conector
  Jira/Confluence/GitHub/AIO Tests, revisão de código), o gate permanece não
  satisfeito. Não há fallback silencioso nem troca de ferramenta que o contrato
  não preveja (B.3).
- **Homologação.** Um executor só opera uma capacidade depois de passar pelos três
  testes — seleção, execução permitida e negativa/gate — em projeto de laboratório
  e de Rafinha declarar a homologação. Sem essa declaração, a capacidade permanece
  apenas no executor já homologado.
- **Canais remotos e executor web.** Referências a canal remoto e a navegador de QA
  Web significam **canal remoto homologado** e **executor web homologado**, nunca
  uma ferramenta presumida. Enquanto o executor web de um executor não for
  homologado, o QA visual por ele permanece bloqueado.
- **Nível, não modelo.** A política de modelo é expressa em níveis neutros
  (SKILL.md §11); cada executor mapeia o nível para sua configuração. O executor
  recomenda, Rafinha decide; não há escalonamento autônomo.

---

## Bloco B — Execução segura

### B.1 Resolução determinística × inferência

A skill não escolhe por preferência, conveniência ou probabilidade o que o
contrato não resolveu. Mas, quando Workflow + Tipo + Políticas + Etapa +
exceções válidas produzirem **uma única consequência**, ela resolve sem pedir
confirmação redundante. Exemplos: `Tipo = Hotfix` + base `develop` + destino
`develop` → Modo C; criação preparatória de branch com existência, base e nome
determinados pelo workflow.

### B.2 Escopo operacional

Toda execução relevante tem **escopo explícito e fechado antes de qualquer
atuação**. Formas válidas:

1. **Issue individual**;
2. **Lista explícita de issues**;
3. **Epic** — issues do Epic selecionadas conforme os critérios da operação;
4. **Coluna de um Epic específico** — issues de um Epic determinado que estejam
   numa coluna específica.

**Não existe escopo "coluna inteira".** Issues sem Epic só entram por issue
individual ou lista explícita. Quando o escopo exige consulta ao Jira, a skill
resolve o conjunto, **apresenta para confirmação** e, depois disso, o escopo
está **fechado**.

- **Escopo repassado.** Escopo já resolvido e **confirmado por Rafinha na sessão**
  (ex.: pela `workflow-remote-orchestrator`) e repassado à skill delegada com o
  conjunto fechado vale como a confirmação exigida; a skill delegada ainda valida
  gates e evidências e registra o escopo no Jira. O modo da Integração e a
  autorização de merge do Modo B nunca são herdados dessa confirmação.
- **Sem ampliação automática.** Descoberta posterior (bug, refatoração,
  documentação, problema estrutural) não entra no escopo; é registrada/reportada.
  Descoberta não é autorização.
- **Consulta fora do escopo** é permitida (contexto, evidência, dependência),
  mas não inclui o elemento no escopo; qualquer **mutação** fora dele é proibida
  sem exceção explícita.
- **Alcance sobre artefatos necessários.** O escopo cobre os artefatos cuja
  alteração é legitimamente necessária aos alvos (código, testes, config, docs,
  branches, commits, registros). Acessibilidade técnica não autoriza mutação
  desnecessária.
- **Registro do escopo.** Toda execução registra o conjunto efetivamente fechado
  no histórico operacional (Jira).

### B.3 Ausência ou insuficiência de informação

A skill usa só informação suficiente e verificável. Informação obrigatória é
buscada na **fonte oficial competente** antes de concluir que falta. Há falha de
informação quando: não existe na fonte oficial; existe mas é insuficiente; a
fonte oficial está indisponível; não pode ser comprovada pelas regras de
autoridade/evidência.

- **Proibido inferir ou usar fallback implícito** (suposição, comportamento
  histórico, convenção informal, valor padrão não previsto). Só vale exceção/
  override previamente autorizado e aplicável.
- **É incidente do workflow.** Registrar pelo mecanismo oficial de captura
  (`workflow-incident-capture-executor`): informação ausente/insuficiente; por que
  era obrigatória; que contrato/gate a exigia; fontes consultadas e resultado de
  cada consulta; issue/etapa/skill afetada; parte bloqueada; evidências.
- **Granularidade do bloqueio.** Bloqueia imediatamente a operação/alvo que
  depende da informação. Outros alvos do escopo podem seguir se: não dependem
  dela; a falha não compromete regra/política/config/contexto compartilhado; a
  continuidade não propaga a inconsistência; cada alvo restante tem informação
  suficiente. Falha de impacto compartilhado (config do produto, política, Epic,
  branch base, regra contratual) bloqueia toda a parte afetada.
- **Retomada.** Só quando a informação passar a existir de forma suficiente e
  verificável na fonte oficial, ou exceção válida autorizar outro tratamento. O
  incidente original permanece registrado.
- **Não confundir com conflito.** Informação inexistente → esta regra.
  Informações válidas incompatíveis → A.7.

### B.4 Gates e condições de continuidade

Gates são condições bloqueantes formais; condições de continuidade são todas as
pré-condições obrigatórias que precisam permanecer válidas para a skill prosseguir.
O Contrato do Workflow define só a **semântica global de bloqueio**; os gates
concretos são definidos pelos contratos de origem (Tipo, Política, Etapa). O
catálogo de índice está em SKILL.md §8.2 e na página **Gates operacionais**.

- Autoridade de transição ou mutação **não basta** para continuar: os gates e
  condições aplicáveis ao próximo passo precisam estar satisfeitos.
- Gate não pode ser dado como cumprido porque "parece correto" ou porque a skill
  consegue prosseguir tecnicamente: a satisfação é verificável por autoridade,
  atestação e evidência (Bloco C).
- Gate não satisfeito: a operação dependente permanece bloqueada. A skill não
  ignora o gate, não infere satisfação, não substitui evidência/atestação por
  outra não prevista, não avança só por ter permissão técnica, não cria fallback.
  Só continua com exceção válida aplicável àquela obrigação.
- Bloqueio atinge só alvos/operações dependentes (mesmos critérios de B.3);
  gate de impacto compartilhado bloqueia toda a parte dependente.

### B.5 Concorrência, claim e handoff entre executores

**Uma issue não pode ter dois executores (ou duas sessões) mutando a mesma etapa
ao mesmo tempo.**

**Claim.** Toda execução que **muta** uma issue ou o trabalho dela (preparar,
implementar, integrar, QA, documentar, auditar, criar ou atualizar issue) abre,
**depois de fechar o escopo (B.2) e antes da primeira mutação**, um comentário de
claim no Jira, por issue:

```text
[Claim de execução] <data/hora>
Executor: Claude | Codex
Etapa/skill: <coluna e skill>
Escopo fechado: <issues>
Tentativa: <n, quando aplicável>
```

- Antes de abrir o claim a skill lê os comentários da issue. **Claim vigente de
  outro executor** (sem resultado nem liberação registrados) → a skill **para e
  reporta a Rafinha**. Nunca disputa, sobrescreve nem presume abandono. Não há
  prazo de expiração: só Rafinha declara um claim abandonado ou liberado (comentário
  na issue).
- O claim **termina** com o comentário estruturado de resultado da própria etapa
  (que já carrega `Executor`, A.9) ou com liberação registrada por Rafinha.
  Etapa interrompida sem resultado mantém o claim vigente até retomada ou liberação.
- **Mesmo executor, sessão nova** (quota, troca de conta, reinício): é retomada, não
  disputa — aplica-se o recovery check (SKILL.md §13.4) e o novo claim registra que
  retoma o anterior. Qualquer dúvida se a sessão anterior ainda está ativa → para e
  pergunta a Rafinha.
- Capacidades sem mutação de issue (consulta, `context/`, `ai-memory/`, captura de
  incidente) não abrem claim.

**Retomada por outro executor (handoff).** Exige, nesta ordem:

1. claim anterior concluído ou liberado por Rafinha;
2. **recovery check** completo: ler Jira (estado, coluna, comentários, claims),
   Git/GitHub (branch, commits, PRs, checks), Execution State, `context/` e
   `ai-memory/` — e **reconciliar** o estado local com as fontes primárias antes de
   agir; nada é assumido que essas fontes não comprovem;
3. registrar o handoff no Jira (`Handoff: Claude → Codex` ou inverso, motivo,
   estado verificado, próxima ação) e persistir o fato operacional pela
   `ai-memory-manager` quando relevante;
4. novo claim do executor de destino.

Divergência que arrisque decisão ou trabalho → para e pergunta a Rafinha (A.7 se for
conflito). Mutação já registrada pelo executor anterior nunca é refeita sem checar a
evidência. O Execution State e o claim não substituem Jira, Git e GitHub: eles
indicam o que provavelmente aconteceu; a skill confirma antes de agir.

---

## Bloco C — Satisfação de contrato

Toda obrigação do Contrato Efetivo tem um estado de satisfação determinístico,
verificável e rastreável.

| Estado | Significado |
|---|---|
| **Pendente** | Aplicável, mas ainda não exigível ou em andamento legítimo. Não é falha |
| **Satisfeita** | Todos os requisitos cumpridos e, quando exigido, comprovados por evidência válida e/ou atestados pela autoridade competente |
| **Não satisfeita** | Aplicável e avaliada como não cumprida |
| **Não aplicável** | A obrigação existe na arquitetura, mas as condições para aplicá-la não estão presentes naquele contexto. Não bloqueia |
| **Não verificável** | Deveria poder ser avaliada, mas faltam informação/evidência/fonte. Segue B.3 (bloqueio + incidente). **Não** equivale a Pendente |
| **Excepcionada** | Aplicável, mas o cumprimento normal foi dispensado por exceção/override válido (escopo e vigência). **Não** equivale a Satisfeita |

**Critérios para Satisfeita:** obrigação aplicável; resultado efetivamente
alcançado; evidências obrigatórias das fontes reconhecidas; atestação da
autoridade competente quando exigida; nenhum evento posterior invalidante;
nenhum conflito não resolvido. O contrato responsável define quais elementos
(evidência, atestação, ambos) a obrigação exige.

Não é Satisfeita só porque: a issue está numa coluna; a transição é possível;
etapa anterior parece concluída; há evidência parcial; há registro sem a
evidência exigida; há evidência sem a atestação exigida; a skill acha provável.

**Obrigações compostas:** só Satisfeita com todos os componentes obrigatórios
aplicáveis compatíveis; componente Pendente/Não satisfeito/Não verificável
impede. Componentes Não aplicáveis saem da avaliação; componentes cobertos por
exceção permanecem identificados como Excepcionados.

**Invalidação:** Satisfeita pode perder validade (código alterado após QA, nova
integração, artefato-evidência alterado, requisito/decisão alterado, exceção
revogada). Obrigação invalidada não sustenta gate sem nova avaliação, e o
histórico da satisfação anterior é preservado (nunca reescrito).

**Registro:** toda determinação relevante deixa rastro no Jira — obrigação,
estado, autoridade, evidências, fontes consultadas, quando, issue/etapa,
exceção usada, invalidação posterior — de modo que uma skill de auditoria saiba
*por que* a obrigação recebeu aquele estado.

---

## Bloco D — Composição

O **Contrato Efetivo do Ticket** é a composição determinística de:

1. Contrato do Workflow (sempre);
2. Contrato de Tipo de Ticket (pelo tipo nativo);
3. Contratos de Política (quando a condição de ativação é verificável);
4. Contrato de Etapa (pela etapa atual);
5. demais regras explicitamente aplicáveis (exceções/overrides válidos).

- **Aditiva por padrão.** Operações reconhecidas: adicionar, modificar,
  substituir uma condição, restringir, tornar não aplicável — todas só quando
  **explicitamente declaradas**. Nenhuma alteração é inferida por "parecer
  relacionada".
- **Identidade e deduplicação.** Obrigações logicamente equivalentes viram uma
  só, preservando todas as proveniências; diferenças materiais mantêm separadas.
- **Conflitos.** Sem precedência implícita (política > tipo, etapa > política,
  específica vence, recente vence — nada disso se assume). Incompatibilidade sem
  regra explícita → A.7 (Rafinha decide), e a operação dependente fica bloqueada.
- **Proveniência.** Toda obrigação é rastreável: contrato de origem, contratos
  adicionais, política/regra modificadora, condição de ativação, etapa, exceções.
- **Recomputação** quando mudar: etapa, tipo, política ativa, condição de
  aplicabilidade, exceção (aplicada/expirada/revogada), conflito resolvido.
  Preserva o histórico; **sem retroatividade automática**. Obrigação nova passa
  por avaliação do Bloco C antes de sustentar continuidade.
- Quando a ativação de um contrato não puder ser verificada, vale B.3.

---

## Bloco E — Vigência e atualização

Atualizações do workflow ocorrem preferencialmente **antes de uma nova sprint**,
para que as issues rodem sob uma versão coerente do workflow.

**Revisão do workflow 2 (esta atualização).** Tratada como **reset/reconfiguração
operacional** do Jira e das skills: **não existe convivência** entre contrato
antigo e novo, nem migração de issues existentes. Nenhuma skill implementa
roteamento, review ou fallback condicionados a "issue antiga × nova". Depois da
ativação, o workflow novo é a única referência para novas execuções. Execuções
já concluídas permanecem como registro histórico e não são reescritas.

**Princípio:** sempre que possível, uma sprint começa com o workflow já
atualizado e permanece estável durante sua execução.
