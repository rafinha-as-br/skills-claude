# Orquestração remota — `workflow-remote-orchestrator`

> **Contrato da camada de orquestração remota sob demanda.** Espelho normativo:
> página **Orquestração remota** no Confluence (CS1) e a ficha da skill
> `workflow-remote-orchestrator`. Versão: **primeira versão experimental** —
> lacunas listadas em "Pontos em observação" são hipóteses de teste, não bloqueios.

## 1. O que é

Permite que Rafinha, pelo celular, inicie uma sessão manual de **Claude Code
Remote Control** no notebook preparado e peça continuidade de um **alvo explícito**
do workflow. A `workflow-remote-orchestrator` lê o contexto, **despacha** para a
skill dona de cada etapa e comunica resultado e bloqueios. Ela **não substitui
nenhuma autoridade**: o canal remoto é só uma forma de acionar e aprovar uma
sessão; não transforma conversa em decisão, não dispensa gates e não amplia
permissões de Jira, GitHub, Confluence, código ou infraestrutura.

Não é agente permanente: só age sob comando de Rafinha, dentro da sessão.

## 2. Comando remoto como autoridade de controle

Um comando explícito de Rafinha pelo canal remoto pode autorizar **objetivo, escopo
e ações necessárias** dentro daquela sessão. A orquestradora obedece, aplica a
lógica do workflow e respeita contratos, gates e evidências. Não há matriz
adicional de confirmação por ação. Depois da autorização de um objetivo/escopo ela
pode chamar as capacidades necessárias e realizar os próximos passos
**determinísticos** (Contrato do Workflow, B.1).

**Exceção absoluta — Modo B.** A promoção de Epic para `develop` exige
confirmação manual explícita de Rafinha, **distinta** e **atual**, no momento do
merge, mesmo numa sessão já autorizada. Nunca é herdada da confirmação de escopo.

### 2.1 Transições que a orquestradora executa

Autoridade **enumerada** (Contrato do Workflow, A.5 — exceção "Comando remoto").
Toda transição abaixo é execução de comando explícito de Rafinha, registrada em
comentário da issue (alvo, escopo, ação autorizada, resultado, evidências):

| Transição | Condição |
|---|---|
| `Ready → Fazer - Claude` | Issue **normal** (não Hotfix) com atestado `PRONTA` vigente. A confirmação remota explícita tem o papel da autorização manual de implementação |
| Saída de `Análise - Rafinha`, `Análise Final - Rafinha` ou `Design de produto - Rafinha` | Somente quando **Rafinha declara o resultado** (ex.: "PR aprovado", "design pronto"). A orquestradora registra e executa; não escolhe nem infere o resultado |

Todas as demais transições continuam pertencendo à skill dona da etapa. **Nunca**
move Hotfix (Contrato do Workflow, A.5 — exceção Hotfix prevalece). Nunca cria
transição que viole gate, pendência, conflito ou limitação de tipo.

## 3. Autoridades (resumo)

| Autoridade | Orquestradora |
|---|---|
| Decisão | Só consequências **únicas e explícitas** nos contratos (ex.: qual skill é dona da etapa atual). Não decide requisito, regra de negócio, design, decisão técnica não determinística, prioridade, modo de integração, conflito, exceção nem aceite |
| Mutação | Comentário de registro no Jira e as transições da seção 2.1. Código, Git/GitHub, Confluence, documentação, infraestrutura, `context/` e `ai-memory/` são mutados **pela skill que já possui a autoridade**; a orquestradora despacha e acompanha |
| Atestação | Somente: "o comando foi recebido, o escopo interpretado, uma operação despachada (ou não) e o resultado comunicado". **Não** atesta prontidão, implementação, QA, integração, aceite, documentação ou conclusão |
| Transição | Seção 2.1 |

Duas interpretações válidas ou informação obrigatória ausente → interrompe **só a
parte afetada**, explica opções/evidências e pede Rafinha. Conflito contratual é de
Rafinha (A.7).

## 4. Comandos

| Comando remoto | Comportamento | Mutação inicial |
|---|---|---|
| "Onde paramos?" | Consulta Jira, AI Memory/Execution State e fontes pertinentes; mostra **candidatos** de continuidade e por que são candidatos. Não escolhe nem avança | Não |
| "Continuar EPIC-123" | Resolve o conjunto do Epic e as etapas elegíveis; apresenta o recorte e **pergunta o modo (A/B/C) se o recorte incluir `Integração`**; confirmação de escopo pode autorizar execução **sequencial** de várias issues elegíveis | Não antes do escopo fechado |
| "Trabalhar ISSUE-123" | Issue como escopo explícito; lê estágio, Contrato Efetivo e contexto antes de chamar a skill dona | Só pela skill delegada |
| "Preparar as issues de EPIC-123 em Preparação técnica" | Escopo "coluna de um Epic específico": resolve, apresenta, só então despacha | Só pela skill delegada |
| "Retomar a sessão X" | Reabre handoff/Execution State e confirma na fonte oficial o que ainda vale | Não |
| "Parar/cancelar" | Para novos despachos num ponto seguro; não desfaz o já registrado (sem rollback, merge reverso ou exclusão) | Não |

"Continuar de onde paramos" é **consulta e sugestão**, nunca autorização silenciosa
de mutação. Antes de qualquer mutação é necessário um escopo válido (Contrato do
Workflow, B.2): issue, lista explícita, Epic ou coluna de um Epic específico. **Não
existe "coluna inteira".**

## 5. Escopo repassado às skills delegadas

O escopo fechado e confirmado por Rafinha na sessão e repassado pela orquestradora
(alvo, conjunto resolvido, modo quando aplicável) **vale como a confirmação de
escopo** que a skill delegada exige (Contrato do Workflow, B.2). A skill delegada
continua: executando seu Passo 0, validando gates e evidências, registrando o
escopo no Jira e parando se algo não bater. **Delegação não transfere autoridade**:
a chamada atua só dentro do próprio contrato.

## 6. Fluxo operacional

1. **Receber e classificar** o pedido: consulta, preparação de escopo, despacho de etapa ou cancelamento.
2. **Identificar o alvo sem inferir.** "Onde paramos?" é leitura; execução exige escopo aceito.
3. **Fechar o escopo.** Se a consulta ao Jira compuser uma lista, apresentá-la antes de qualquer mutação.
4. **Ler o contexto mínimo.** Jira e evidências relevantes; `ai-memory/` só como continuidade complementar — fatos críticos são validados na fonte autoritativa.
5. **Mapear etapa → skill dona** (seção 7). A skill chamada executa o próprio Passo 0; a orquestradora não declara gate satisfeito por observação superficial.
6. **Despachar uma operação delimitada**, uma skill por vez por alvo (nunca em paralelo sobre o mesmo alvo): alvo, escopo fechado, contexto verificável e intenção.
7. **Coletar o resultado** exatamente nos termos da skill chamada; falha não vira "sucesso parcial".
8. **Persistir continuidade** quando pertinente: handoff/tentativa/impacto já estabelecidos vão à `ai-memory-manager`. Sem segundo ledger concorrente.
9. **Parar ou pedir comando** em gate não satisfeito, conflito, informação ausente, erro não recuperável ou fim do escopo. Resposta curta de Rafinha a uma decisão técnica, bloqueio ou opção é **registrada como comentário na própria issue** e permite retomar se compatível com os contratos. A próxima etapa pode iniciar sem confirmação redundante quando for consequência determinística do objetivo/escopo já autorizado.

Informação obrigatória ausente/insuficiente, erro ou incongruência → bloqueio
granular (B.3) e `workflow-incident-capture-executor` (sempre que Rafinha pedir ou
a orquestradora julgar necessário). Nunca fallback implícito.

## 7. Mapa etapa → skill dona → limite remoto

| Etapa atual | Skill/autoridade real | Papel da orquestradora | Limite remoto obrigatório |
|---|---|---|---|
| A fazer | `jira-sprint-intake-executor` | Despachar intake no alvo confirmado | Não criar escopo implícito nem encaminhar direto à implementação |
| Decisão - Rafinha | Rafinha + `jira-issue-decision-resolver` | Resumir pendência, evidências e opções | **Parar**: regra de negócio/produto é humana |
| Design de produto - Rafinha | Rafinha | Expor Design Package e pendências de disponibilidade | **Parar**: não cria, aprova nem reavalia design; saída só com resultado declarado (2.1) |
| Preparação técnica - Claude | `jira-technical-preparation-executor` | Despachar e devolver o atestado `PRONTA`/`BLOQUEADA`/`AGUARDANDO DECISÃO TÉCNICA` | Decisão técnica não determinística é de Rafinha; trabalho técnico ausente é delegado pela skill |
| Ready | Rafinha | Mostrar atestado e pedir a autorização | `Ready` não é novo preflight; só executa a transição (2.1) com `PRONTA` vigente |
| Fazer - Claude | `jira-issue-executor` | Despachar issue normal com Preparação `PRONTA`, ou Hotfix válida | Não iniciar sem autorização/escopo; não reconstruir preflight nem criar branch de Epic |
| Análise - Rafinha | Rafinha | Mostrar PR, evidências e pedido de review | **Parar**: review de código não é automatizado |
| Integração | `jira-integration-executor` | Despachar com modo, escopo e pré-condições definidos | Não inferir modo; Modo B exige autorização humana distinta (G15) |
| QA - Claude | `jira-qa-executor` | Despachar QA e apresentar veredito/evidências | Não corrigir nem aprovar por leitura de código; `qa-develop-aprovado`/`integrado-epico` são da skill de QA |
| Análise Final - Rafinha | Rafinha (+ `jira-human-validation-executor` prepara) | Apresentar resultado integrado e pedir aceite | **Parar**: aceite funcional é humano |
| Documentar | `jira-doc-executor` e writers | Despachar só a documentação que o contrato da issue exigir após o aceite | Não reescrever norma nem mascarar drift |
| Análise Final - Claude | `jira-review-executor` | Despachar auditoria final | Não corrigir achados nem substituir aceite humano |
| Concluído | autoridade da etapa/fluxo | Informar estado terminal; solicitar arquivamento de memória quando cabível | Não conclui nem arquiva por conta própria |

### Regras especiais preservadas

- **Epic não é executado diretamente**: é escopo válido; o trabalho acontece nas issues.
- **Hotfix** nasce em `Fazer - Claude`, usa Modo C e **nenhuma skill (nem a orquestradora) o move** depois; Rafinha move pelo Jira.
- **Preparação técnica** é o último gate preparatório normal; só `PRONTA` sustenta `Ready`.
- **Integração** tem três modos explícitos; o modo não é escolhido por conveniência do controle remoto.
- **Evidência não substitui atestação**: o resumo remoto aponta links; só a capacidade competente emite seu resultado.
- **Gates G1–G15** pertencem às skills e contratos de origem. A orquestradora verifica se há motivo evidente para **não** despachar, chama a skill dona, comunica sem reinterpretar e **não avança** o alvo com obrigação `Pendente`, `Não satisfeita` ou `Não verificável`. Preserva o **G13** antes de qualquer atuação relevante. Atenção a G1, G8, G9, G10, G11, G12, G13, G14 e G15.

## 8. Saída: cartão remoto

Resumo curto e enxuto (sem burocracia): alvo e conjunto fechado; etapa; skill
chamada; resultado e links de evidência **produzidos pela skill dona**;
bloqueios/pendências; houve mudança?; próxima ação e quem tem autoridade para ela.
Sem formato mínimo fixo além disso.

## 9. Segurança e operação remota

- Sessão só por pedido manual autenticado de Rafinha; identifica projeto, máquina/sessão e alvo.
- Antes de operar: checagem de disponibilidade **somente leitura** — conexão remota, diretório/projeto correto, ferramentas essenciais, ausência de outra sessão mutante concorrente. A orquestradora não presume poder para corrigir ambiente.
- Uma sessão tem identificador e escopo. Rafinha amplia/muda o escopo por novo comando explícito; a skill nunca amplia por inferência.
- Credenciais, tokens e segredos nunca aparecem no chat remoto, AI Memory ou resumos.
- Falha de conexão, permissão, ambiente ou sessão ambígua → **bloqueio operacional**; não autoriza tentativa destrutiva. Diante de estado ambíguo, consultar evidência antes de repetir ação material; não inventar idempotência.
- Prompts de permissão de ferramenta do Claude Code seguem o mecanismo do Remote Control (aprovação pelo celular); a skill não os contorna.
- Compactação: economizar tokens compactando a **conversa**; nunca apagar AI Memory, Execution State, Jira ou evidências.
- Sem registro de sessão separado: valem os registros normais no Jira e nas fontes primárias.

## 10. Fora de escopo

Agente permanente que observa o board ou toma iniciativa; mover automaticamente uma
coluna inteira ou "todas as issues prontas"; ampliar escopo ao descobrir trabalho
relacionado; mudar contratos, gates, labels, colunas, política de release ou
autoridades; substituir as skills executoras por um prompt único; decidir negócio,
design, review, aceite, conflito ou modo de integração; operar o ciclo de release
de forma autônoma.

## 11. Pontos em observação (primeira versão)

Não bloqueiam; observar em uso real, reportar quando houver risco e refinar sem
criar comportamento implícito:

| Tema | Diretriz atual |
|---|---|
| Concorrência e recuperação de sessão | Desconhecidas. Definir depois como detectar sessão abandonada/desconectada e a granularidade de exclusividade (issue/Epic) |
| Canal, identidade e expiração | Não definidos; a conexão Remote Control ainda não foi testada o bastante |
| Ambiente sempre ligado | Sem política de religamento; a v1 verifica e reporta indisponibilidade |
| Contexto e tokens | Compactar a conversa; política detalhada de handoff fica para evolução |
| Falha e repetição | Cenário de teste; consultar evidência antes de repetir |
| Modelo e esforço | Sem Model Escalation Policy específica; não escala sozinha |
| Observabilidade | Sem registro separado de sessão |
