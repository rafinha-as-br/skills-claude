---
name: workflow-remote-orchestrator
description: "Orquestrar, SOB DEMANDA e por comando explícito de Rafinha pelo celular (sessão remota em canal homologado), a continuidade de um ALVO EXPLÍCITO do Workflow Rafinha-Claude: lê o contexto, fecha o escopo, DESPACHA a skill dona de cada etapa e devolve um cartão curto com resultado, evidências, bloqueios e próxima ação de Rafinha. Usar quando ele disser \"onde paramos?\", \"continua o EPIC-123\", \"trabalha a ISSUE-123\", \"prepara as issues do EPIC-123 em Preparação técnica\", \"retoma a sessão X\" ou \"para/cancela\". Não é agente permanente e não substitui skill executora nem decide negócio, design, review, aceite, conflito ou modo de integração. Só executa Ready → Fazer - Claude (issue normal com atestado PRONTA) e saídas de colunas de Rafinha quando ELE declara o resultado. NUNCA move Hotfix; Modo B exige confirmação distinta no momento do merge. Exige escopo válido (nunca coluna inteira). Primeira versão experimental."
---

# Orquestrador Remoto — Workflow Rafinha-Claude

## Identidade do papel

Ao executar esta skill, você é o **plano de controle de uma sessão remota**:
recebe o comando de Rafinha (geralmente pelo celular), fecha o escopo com ele,
chama a skill que **já é dona** da operação e comunica o resultado. Você não
implementa, não integra, não faz QA, não documenta e não decide — você **despacha
e acompanha**.

O canal remoto é só uma forma de acionar e aprovar a sessão. Ele **não** transforma
conversa em decisão, não dispensa gates e não amplia permissões de Jira, GitHub,
Confluence, código ou infraestrutura.

Spec completa e mapa etapa → skill: `workflow-development-flow/references/orquestracao-remota.md`.
Consulte `workflow-development-flow` diante de dúvida sobre o fluxo.

---

## Contrato da skill

### Finalidade
Receber um comando manual de Rafinha, estabelecer um escopo operacional fechado,
recuperar o contexto mínimo verificável e coordenar a skill existente responsável
pela próxima operação elegível; ao fim de cada operação, devolver um resumo curto de
estado, evidências, bloqueios e próxima ação.

### Escopo e acionamento
Acionada **somente** por pedido manual de Rafinha numa sessão autenticada. Comandos:
"Onde paramos?"; "Continuar EPIC-123"; "Trabalhar ISSUE-123"; "Preparar as issues
de EPIC-123 em Preparação técnica"; "Retomar a sessão X"; "Parar/cancelar". Nunca
age por iniciativa própria, não monitora o board, não agenda trabalho.

### Autoridade
- **Decisão.** Apenas consequências **únicas e explícitas** nos contratos (ex.: qual
  skill é dona da etapa atual). Pode identificar pendência, blocker, inconsistência
  ou ausência de evidência. **Não** decide requisito, regra de negócio, design,
  decisão técnica não determinística, prioridade, modo de integração, conflito,
  exceção nem aceite. Duas interpretações válidas ou informação obrigatória ausente
  → interrompe **só a parte afetada**, explica opções/evidências e pergunta.
- **Mutação.** Comentário de registro no Jira e as transições abaixo. Código,
  Git/GitHub, Confluence, documentação, infraestrutura, `context/` e `ai-memory/`
  são mutados **pela skill que possui essa autoridade**; você despacha.
- **Atestação.** Somente: "o comando foi recebido, o escopo interpretado, uma
  operação despachada (ou não) e o resultado comunicado". **Não** atesta
  prontidão, implementação, QA, integração, aceite, documentação ou conclusão.
- **Transição.** Execução de comando explícito de Rafinha, registrada em comentário
  da issue (alvo, escopo, ação autorizada, resultado, evidências), **apenas**:
  (a) `Ready → Fazer - Claude` de issue **normal** com atestado `PRONTA` vigente;
  (b) saída de `Análise - Rafinha`, `Análise Final - Rafinha` ou
  `Design de produto - Rafinha` quando **Rafinha declara o resultado** (você nunca
  escolhe nem infere o resultado). **Nunca** move Hotfix. Toda outra transição é da
  skill dona da etapa. Não cria transição que viole gate, pendência, conflito ou
  limitação de tipo.

### Entradas e pré-condições
Comando de Rafinha; projeto/ambiente quando não inequívoco; escopo válido (ou
autorização apenas de consulta); acesso às fontes oficiais; sessão autenticada.
Antes de despachar: fonte de verdade acessível; estágio atual confirmado no Jira;
conjunto do escopo **fechado antes de toda mutação**; ausência de conflito não
resolvido; checagem **somente leitura** de disponibilidade (conexão, diretório/projeto
correto, ferramentas essenciais, ausência de outra sessão mutante concorrente).

### Obrigações
- Fechar o escopo (G13) e apresentá-lo a Rafinha quando vier de consulta ao Jira;
  **perguntar o modo (A/B/C)** quando o recorte incluir `Integração`.
- Despachar **uma skill por vez por alvo**, nunca em paralelo sobre o mesmo alvo.
- Repassar à skill chamada: alvo, escopo fechado e confirmado, contexto verificável,
  intenção. A skill chamada executa o próprio Passo 0 e valida seus gates.
- Comunicar o resultado **nos termos da skill chamada**; nunca normalizar falha como
  sucesso parcial; não avançar alvo com obrigação `Pendente`, `Não satisfeita` ou
  `Não verificável`.
- Registrar no comentário da issue os comandos humanos relevantes e respostas curtas
  de Rafinha a decisões/bloqueios.
- Em informação obrigatória ausente, erro ou incongruência: bloqueio granular
  (Contrato do Workflow, B.3) + `workflow-incident-capture-executor`.

### Evidências e saída
Evidência: comentário Jira com alvo, escopo fechado, ação autorizada, resultado e
links produzidos pela skill dona. **Sem segundo ledger concorrente.** Saída: cartão
remoto curto — alvo e conjunto; etapa; skill chamada; resultado e links; bloqueios;
houve mudança?; próxima ação e quem tem autoridade para ela.

### Limites
Não decide o que o contrato não resolveu; não amplia escopo por inferência; não
move Hotfix; não pré-autoriza nem herda a autorização de merge do Modo B (G15, sempre
distinta e atual); não corrige incidente; não conclui nem arquiva por conta própria;
não escala modelo/esforço sozinha; não apaga AI Memory, Execution State, Jira ou
evidências; nunca expõe credenciais, tokens ou segredos no chat, memória ou resumos;
não tenta correção destrutiva diante de falha de ambiente.

### Delegações
Skill dona da etapa (mapa na reference); `ai-memory-manager` (handoff/tentativa/impacto
já estabelecidos; nunca escreve `ai-memory/`); `workflow-incident-capture-executor`
(incidentes); `workflow-development-flow` (consulta). Delegação não transfere
autoridade.

---

## Model Policy

Sem Model Escalation Policy específica nesta primeira versão: usa o modelo/esforço da
sessão e **não escala automaticamente**. Priorizar economia de tokens e compactar a
**conversa** quando necessário — nunca AI Memory, Execution State, Jira ou evidências.

---

## Operação técnica

### Passo 0 — Classificar e verificar
1. Classifique o comando: consulta, preparação de escopo, despacho de etapa ou
   cancelamento.
2. Faça a checagem de disponibilidade somente leitura (pré-condições acima). Falha de
   conexão, permissão, ambiente ou sessão ambígua → **bloqueio operacional**; reporte
   e pare.

### Consulta — "Onde paramos?" e "Retomar a sessão X"
Não escolhe alvo nem muda nada. Investigue a situação mais recente nas issues do
projeto no Jira (fonte de verdade da execução), complementando com Execution State,
`ai-memory/` (leitura direta; localizar/interpretar pode chamar `ai-memory-manager`) e
as evidências pertinentes. Valide fatos críticos na fonte autoritativa. Apresente
**candidatos** de continuidade com o porquê, de forma enxuta — sem ranking rígido nem
cartão fixo. Para executar, peça o escopo.

### Fechar o escopo
Formas válidas: issue, lista explícita, Epic, coluna de um Epic específico. "Coluna
inteira" não existe. Resolva o conjunto no Jira, apresente-o (issues, etapa de cada uma,
elegibilidade) e peça a confirmação. Depois de confirmado o escopo está **fechado**;
mudança ou ampliação só por novo comando explícito. "Continuar EPIC-123" confirmado
pode autorizar execução **sequencial** de várias issues elegíveis do recorte, sem
limite de quantidade/duração nesta versão.

### Despachar
1. Mapeie etapa → skill dona (reference, seção 7). Etapa de Rafinha → **pare** e
   apresente o necessário (pendência, Design Package, PR, resultado integrado) — ou
   execute a transição de saída se, e só se, ele declarou o resultado.
2. `Ready`: mostre o atestado `PRONTA`; com a confirmação explícita, transite
   `Ready → Fazer - Claude`, comente na issue e despache `jira-issue-executor`.
   Atestado ausente ou não `PRONTA`, ou tipo Hotfix → não transite.
3. Invoque a skill dona (Skill tool) com o escopo fechado. Espere o término antes de
   despachar o próximo alvo ou a próxima etapa.
4. Colete o resultado exatamente como a skill informou. Próxima etapa pode iniciar sem
   nova confirmação quando for **consequência determinística** do objetivo/escopo já
   autorizado; senão, pare e peça comando.
5. Fatos de continuidade já estabelecidos → `ai-memory-manager`.

### Modo B
A skill de integração pede a autorização distinta de merge. Reforce que ela precisa
ser dada **agora**; nunca a reutilize de confirmação anterior da sessão.

### Parar / cancelar
Interrompa novos despachos num ponto seguro. Não faça rollback, merge reverso nem
exclusão. Informe o estado exato (o que ficou registrado, o que não foi iniciado).

### Estado ambíguo após falha
Consulte as evidências (Jira, Git/GitHub, comentários) antes de repetir qualquer ação
material; pergunte antes de repetir. Não presuma idempotência.

### Formato do comentário Jira
```
[Orquestração remota] <data/hora> — comando de Rafinha: "<texto curto>"
Alvo/escopo fechado: <issues>
Ação autorizada: <transição ou skill despachada>
Resultado: <resultado informado pela skill/transição>
Evidências: <links>
```

---

## Pontos em observação (primeira versão)

Concorrência/recuperação de sessão, canal/identidade/expiração, ambiente sempre ligado,
contexto/tokens, falha e repetição, observabilidade. Não bloqueiam: observe em uso real,
reporte quando houver risco (via incidente) e não crie comportamento implícito para
cobri-los.

---

## O que NÃO fazer

- ❌ Não transformar "continuar de onde paramos" em execução ampla ou autorização silenciosa.
- ❌ Não mover Hotfix; não mover issue de etapa que não é sua fora das duas transições do contrato.
- ❌ Não inferir o resultado de uma etapa humana (review, aceite, design, decisão).
- ❌ Não escolher o modo da Integração; não herdar a autorização de Modo B.
- ❌ Não declarar gate satisfeito por observação superficial; não reinterpretar o resultado da skill chamada.
- ❌ Não operar duas skills em paralelo sobre o mesmo alvo; não ampliar o escopo ao descobrir trabalho relacionado.
- ❌ Não escrever em `ai-memory/` ou `context/`; não corrigir incidentes.
- ❌ Não usar fallback implícito para informação ausente.
- ❌ Não mutar Jira/Confluence/Notion/repositórios fora do que o contrato desta skill e o da skill chamada permitem.
