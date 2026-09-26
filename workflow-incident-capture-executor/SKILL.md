---
name: workflow-incident-capture-executor
description: "Capturar, num arquivo .md local, uma incongruência, cenário não previsto ou falha de contrato percebida DURANTE a execução normal do Workflow Rafinha-Claude — sem interromper o trabalho em andamento nem obrigar Rafinha a analisar o problema naquele momento. Usar quando ele disser \"registra esse incidente\", \"guarda isso pra analisar depois\", \"isso não devia ter acontecido, anota\", ou quando qualquer skill do pipeline encontrar um comportamento que contradiz o contrato documentado (workflow-development-flow, gates, labels, ou qualquer SKILL.md) e Rafinha pedir para capturar em vez de resolver agora. Identifica o contexto do incidente (projeto, issue, épico, skill em execução, coluna, branch, PR, página ou artefato envolvido), descreve o esperado pelo workflow, descreve o que aconteceu de forma inesperada, coleta evidências (mensagens, comentários, labels, status, links, comandos, erros, trechos de saída, divergências observadas), aponta quais regras/gates/skills/páginas parecem estar em conflito ou insuficientes, e registra o impacto potencial SEM decidir a correção. Gera um arquivo .md em `.claude/workflow-incidents/AAAA-MM-DD-<PROJETO-OU-ISSUE>-<resumo-curto>.md`, preferencialmente fora do versionamento por padrão (sugere adicionar a pasta ao .gitignore do projeto, na primeira execução). NUNCA corrige o incidente, nunca altera Jira, Confluence, Notion, GitHub, branches, PRs, labels, issues, páginas ou código, nunca decide nova regra de workflow, nunca move issue e nunca cria ticket. É observação pura, para retomada posterior por Rafinha com calma."
---

# Capturador de Incidentes Operacionais — Workflow Rafinha-Claude

## Identidade do papel

Ao executar esta skill, seu único trabalho é **descrever** um incidente
operacional num arquivo `.md` local — nunca corrigi-lo, nunca decidir o que
fazer sobre ele, e nunca tocar em nenhum sistema externo (Jira, Confluence,
Notion, GitHub, git, código).

Esta skill existe para capturar o problema **enquanto o contexto está
fresco**, não para resolvê-lo durante a execução. Ela não interrompe o
trabalho principal que estava em andamento quando o incidente apareceu — o
registro é rápido e a skill/sessão que a acionou pode continuar depois
(sujeita ao que Rafinha decidir fazer com aquele incidente).

Consulte `workflow-development-flow` quando precisar confirmar se algo é
mesmo uma divergência do contrato documentado, antes de descrevê-la como
tal.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o incidente envolve múltiplos sistemas (ex.: Jira + Git + Confluence) e
  reconstruir a sequência exata dos eventos exige cruzar várias fontes.

Escalonar para Opus quando:
- não se aplica normalmente — esta skill descreve, não diagnostica nem
  decide.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto

Se já estiver claro pelo contexto da conversa (a skill que encontrou o
incidente já sabe o projeto), use sem perguntar. Caso contrário, pergunte.

### 2. `.gitignore` do projeto

Na primeira vez que esta skill gerar um arquivo num projeto, confirme que
`.claude/workflow-incidents/` está no `.gitignore` do repositório. Se não
estiver, adicione essa linha (mesmo padrão de `.claude/design-packages/` e
`.claude/execution-state/`) e avise Rafinha do que foi feito.

---

## Passo a passo

### 1. Coletar o contexto do incidente

Reúna, do que estiver disponível na conversa/sessão atual:
- **Projeto** — nome/chave.
- **Issue, épico, ou artefato envolvido** — chave da issue, nome do épico,
  link da página do Confluence, número do PR, ou o que for aplicável.
- **Skill em execução** quando o incidente ocorreu, se houver uma.
- **Coluna do Jira** em que a issue estava, se aplicável.
- **Branch/PR** envolvidos, se aplicável.

Não invente contexto que não está disponível — registre como "não
observado" em vez de assumir.

### 2. Descrever o esperado vs. o que aconteceu

- **Esperado pelo workflow:** o que o contrato documentado (SKILL.md da
  skill envolvida, `workflow-development-flow`, ou página do Confluence)
  diz que deveria ter acontecido. Cite a seção/gate específico quando
  souber qual é.
- **O que aconteceu:** descrição objetiva do comportamento real observado,
  sem já embutir uma explicação de causa — isso é análise, não captura.

### 3. Coletar evidências

Anexe ao registro qualquer evidência disponível e relevante: trecho de
mensagem, comentário do Jira, label aplicada/ausente, status da issue,
link, comando executado, mensagem de erro, trecho de saída de log, ou a
divergência específica observada entre dois artefatos (ex.: `SKILL.md` diz
uma coisa, ficha do Confluence diz outra).

### 4. Apontar o conflito ou lacuna de contrato

Liste quais regras, gates, skills, páginas ou decisões parecem estar em
conflito entre si, ou insuficientes para o cenário observado. Isso é
**apontamento**, não correção — não proponha a mudança de contrato aqui,
só descreva onde a lacuna parece estar.

### 5. Registrar o impacto potencial

Descreva o que pode dar errado se o incidente se repetir ou não for
tratado — sem decidir se isso é grave o bastante para priorizar. Essa
avaliação é de Rafinha.

### 6. Gerar o arquivo

Escreva em:

```text
.claude/workflow-incidents/AAAA-MM-DD-<PROJETO-OU-ISSUE>-<resumo-curto>.md
```

Usando esta estrutura:

```markdown
# Incidente — <resumo curto>

## Contexto
- Projeto:
- Issue/épico/artefato:
- Skill em execução:
- Coluna:
- Branch/PR:

## Esperado pelo workflow
<descrição, com referência ao contrato citado>

## O que aconteceu
<descrição objetiva>

## Evidências
<trechos, links, comandos, erros>

## Conflito ou lacuna de contrato apontada
<regras/gates/skills/páginas em conflito ou insuficientes>

## Impacto potencial
<o que pode dar errado se isso se repetir>

## Data de captura
<AAAA-MM-DD>
```

Seção sem conteúdo real usa "Não observado" — nunca inventar conteúdo só
para preencher o template.

### 7. Confirmar a Rafinha

Avise que o incidente foi capturado, com o caminho do arquivo, e retome (ou
deixe explícito que retoma) o trabalho que estava em andamento antes da
captura — a menos que Rafinha peça para parar por outro motivo.

---

## O que NÃO fazer

- ❌ Nunca corrigir o incidente — nem o código, nem a documentação, nem o
  contrato.
- ❌ Nunca alterar Jira, Confluence, Notion, GitHub, branches, PRs, labels,
  issues, páginas ou código.
- ❌ Nunca decidir uma nova regra de workflow a partir do incidente
  observado — isso é decisão de Rafinha, em outra conversa.
- ❌ Nunca mover issue de coluna nem criar ticket a partir do incidente —
  se o incidente sugerir uma issue nova, sinalize isso no registro, mas a
  criação formal é sempre da `jira-issue-creator`, sob pedido de Rafinha.
- ❌ Nunca inventar contexto ou evidência que não está disponível — registre
  a lacuna como "não observado".
- ❌ Nunca deixar de sugerir a entrada no `.gitignore` na primeira execução
  num projeto novo.
