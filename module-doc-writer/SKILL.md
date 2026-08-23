---
name: "module-doc-writer"
description: "Elaborar ou atualizar páginas de documentação de módulo no Confluence do Rafael (ex.: \"Módulo - Gerenciamento de Administradores\", \"Módulo - Autenticação\") — documentação técnica/arquitetural detalhada de uma feature ou área do Geoprag, com estrutura livre (objetivo/escopo, estrutura de código, fluxos, tabelas de status, comparações), diferente da estrutura fixa de 4 seções da business-rule-writer. Usar sempre que Rafinha disser \"documenta esse módulo\", \"cria a página do módulo X\", \"atualiza a doc do módulo Y\", enviar um link de página de módulo do Confluence, ou pedir para descrever a arquitetura/estrutura/estado atual de uma feature do Geoprag. Não usar para páginas de regra de negócio (RN) — essas são sempre business-rule-writer."
---

---
name: module-doc-writer
description: "Elaborar ou atualizar páginas de documentação de módulo no Confluence do Rafael (ex.: \"Módulo - Gerenciamento de Administradores\", \"Módulo - Autenticação\") — documentação técnica/arquitetural detalhada de uma feature ou área do Geoprag, com estrutura livre (objetivo/escopo, estrutura de código, fluxos, tabelas de status, comparações), diferente da estrutura fixa de 4 seções da business-rule-writer. Usar sempre que Rafinha disser \"documenta esse módulo\", \"cria a página do módulo X\", \"atualiza a doc do módulo Y\", enviar um link de página de módulo do Confluence, ou pedir para descrever a arquitetura/estrutura/estado atual de uma feature do Geoprag. Não usar para páginas de regra de negócio (RN) — essas são sempre business-rule-writer."
---

# Escritor de Documentação de Módulo — Confluence do Rafael

## Identidade do papel

Ao executar esta skill, você transforma o conhecimento que Rafinha tem sobre
um módulo do Geoprag (Portal Administrador, App Aplicador, ou qualquer outra
área) em uma **página de documentação técnica** no Confluence — escrevendo ou
atualizando diretamente a página cujo link ele fornecer.

Diferente da `business-rule-writer`, esta skill não segue uma estrutura fixa
de 4 seções. Documentação de módulo cobre arquitetura, estrutura de código,
fluxos de tela em conjunto, modelo de segurança, estado de implementação —
o formato se adapta ao que o módulo realmente precisa documentar. Se a
página é sobre **uma regra de negócio isolada**, a skill certa é
`business-rule-writer`; se é sobre **os campos, componentes e estados de
uma única tela específica** (em vez do módulo como um todo), a skill certa
é `screen-doc-writer`. Se ficar em dúvida sobre qual das três se aplica,
pergunte a Rafinha antes de começar a escrever.

Quando você tem acesso real ao repositório do módulo (rodando via Claude
Code, tipicamente no mesmo contexto de `jira-issue-executor`), esta skill
também sincroniza a pasta `docs/` correspondente no código, depois de
publicar a página do Confluence — ver passo 9. Consulte a skill
`workflow-development-flow` para dúvidas sobre como a etapa "Documentar" se
encaixa no fluxo geral do pipeline.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- o módulo tem muitas seções cruzadas para reconciliar, ou a sincronização
  da pasta `docs/` no código (passo 9) não é trivial.

Escalonar para Opus quando:
- não se aplica normalmente — documentação de módulo descreve estado
  atual já implementado, não decide arquitetura.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Como esta documentação difere de uma página de RN

Isso importa porque muda o tom de escrita:

- **Página de RN** (`business-rule-writer`): descreve o estado atual de uma
  regra, sem nunca narrar histórico ("antes era assim, agora é assado").
- **Página de módulo** (esta skill): é documentação viva de algo que está
  sendo construído. Aqui **é esperado e correto** narrar o estado de
  implementação, citar issues do Jira que mudaram alguma coisa (ex.:
  "Atualização (GEOPRAG-30): a camada de apresentação passou a usar um
  Cubit..."), e deixar explícito o que já está implementado, o que está
  mockado, e o que ainda depende de outra definição. Rafinha volta a essas
  páginas ao longo do desenvolvimento do módulo — elas precisam refletir o
  estado real do código, não um instantâneo congelado do dia em que foram
  escritas.

## Passo a passo

### 1. Obter o conteúdo bruto e o link da página

Se Rafinha enviou um link do Confluence, use o Atlassian Rovo para buscar a
página (`getConfluencePage` ou equivalente) e verificar se já existe conteúdo
— nesse caso é atualização, não criação do zero. Se o link ainda não foi
enviado, pergunte por ele antes de prosseguir — esta skill sempre escreve
diretamente na página, nunca devolve texto solto no chat como entrega final.

Antes de escrever, vale a pena olhar 1-2 páginas de módulo já existentes no
espaço Geoprag (via `getPagesInConfluenceSpace` ou pelas referências da
página-mãe) para manter consistência de tom e estrutura com o que Rafinha já
tem publicado.

### 2. Levantar as seções relevantes

Não existe uma lista fixa de seções — decida com base no que o módulo
realmente precisa comunicar. Os padrões abaixo aparecem com frequência nas
páginas de módulo do Rafinha e servem de repertório, não de checklist
obrigatório:

- **Objetivo e escopo** (praticamente sempre a seção 1) — o que o módulo
  cobre, o que fica fora, onde ele vive na árvore do Geoprag (Portal
  Administrador, App Aplicador, etc.), e se existe um módulo irmão/contraparte
  relevante.
- **Estrutura de código atual** — tabela com caminho de arquivo, conteúdo e
  status de implementação (ex.: "Implementado", "Implementado como mock",
  "Contrato apenas").
- **Fluxo de telas/passos** — sequência numerada de como o usuário navega ou
  como o processo se comporta na prática.
- **Modelo de arquitetura/segurança** — camadas, tabelas comparativas,
  referências a páginas técnicas mais profundas quando o detalhe não cabe
  aqui.
- **Comparações com módulos irmãos** — quando o módulo tem uma contraparte
  (ex.: Portal Administrador vs. App Aplicador) que resolve o mesmo problema
  de forma diferente, uma tabela comparativa costuma comunicar isso melhor
  que texto corrido.
- **Observações e pontos de atenção (coerência)** — seção quase sempre
  próxima do final, reunindo gaps ou inconsistências que atravessam o módulo
  inteiro (ex.: "página-mãe não menciona o refresh token", "falta contrato de
  API formal para este fluxo"). Isso é diferente de uma nota pontual dentro
  de uma seção específica — é para observações que não pertencem a um único
  trecho.
- **Referências** — sempre a última seção. Links para páginas filhas, páginas
  técnicas relacionadas, e a contraparte do módulo se houver.

Escolha as seções que fazem sentido para o módulo em questão — não force uma
seção vazia só para seguir a lista acima.

### 3. Extrair e organizar as informações

A partir do que Rafinha descreveu:

- O que foi dito com clareza → vai direto para a seção correspondente.
- O que ficou ambíguo, incompleto, ou que você não tem certeza de como
  encaixar → **não decida sozinho e não marque como pendência diretamente.**
  Invoque a skill `doc-pendency-resolver`, que conduz a pergunta a Rafinha com
  opções objetivas (incluindo sempre a opção de deixar como pendência a
  resolver depois). Só volte a escrever aquela seção depois da resposta dele.
- Um gap real do sistema que **Rafinha já confirmou** (ex.: "essa parte está
  mockada", "falta fechar o contrato com o backend") não passa pelo
  `doc-pendency-resolver` — isso não é uma incerteza sua, é conteúdo. Escreva
  como uma observação normal (ver formato de painéis abaixo).

### 4. Uso de painéis (macros de callout do Confluence)

Diferente da RN, aqui os painéis têm mais de um papel:

- **Painel inline, junto ao trecho específico que ele anota** — para uma nota
  ou aviso que só faz sentido ali (ex.: uma ressalva sobre um termo usado no
  parágrafo, um link para a issue que originou aquela decisão).
- **Atualização de status** (`panel-info` ou `panel-success`) — para registrar
  que algo mudou desde a última versão da página, sempre citando a issue
  responsável. Isso é aceitável e esperado aqui, diferente da RN.
- **Gap/mock conhecido** (`panel-warning`) — para deixar claro que uma parte
  do módulo está implementada parcialmente, mockada, ou aguardando definição
  externa.
- **Observação de coerência** (`panel-note`) — usada dentro da seção
  "Observações e pontos de atenção" para inconsistências entre páginas ou
  gaps que atravessam o módulo inteiro.

Toda vez que o painel expressar uma incerteza sua (não um fato que Rafinha já
confirmou), ele só deve existir depois de passar pelo `doc-pendency-resolver`
— ver passo 3.

### 5. Tabelas

Use tabelas sempre que a informação for naturalmente comparativa ou
estruturada em colunas fixas — estrutura de código (caminho/conteúdo/status),
camadas de segurança, comparação entre módulos irmãos. Tabelas comunicam esse
tipo de informação de forma muito mais rápida que texto corrido; não hesite
em usá-las mesmo que a página já tenha outras.

### 6. Trechos de código

Quando fizer sentido mostrar uma rota, um nome de classe/arquivo, ou um
trecho pequeno e ilustrativo (ex.: registro de rotas no `MaterialApp`), use
blocos de código com a linguagem correta. Não é necessário nem esperado
reproduzir a implementação inteira — o objetivo é situar quem lê, não
substituir o código-fonte.

### 7. Regras de redação (tom e estilo)

- Escreva como documentação viva: é normal e correto referenciar o estado
  atual de implementação, mockups, TODOs, e issues do Jira que motivaram uma
  mudança — ao contrário da `business-rule-writer`, aqui isso é esperado, não
  proibido.
- Ainda assim, seja objetivo e técnico — narrar o estado de implementação não
  é o mesmo que escrever em tom de changelog solto; cada menção a uma issue
  ou mudança deve servir para orientar quem lê sobre o que existe hoje.
- Linguagem técnica, direta, sem eliminar informação necessária para
  entendimento completo do módulo.

### 8. Publicar a página no Confluence

Crie ou atualize a página no Confluence com o conteúdo formatado (usando
`createConfluencePage` ou `updateConfluencePage` conforme o caso).

### 9. Sincronizar a documentação em `docs/` no código (quando aplicável)

Além da página do Confluence, cada módulo pode possuir uma pasta `docs/`
própria dentro do código:

```
module/
├── data/
├── domain/
├── presentation/
└── docs/
    ├── overview.md
    ├── architecture.md
    ├── state-management.md
    ├── api.md
    ├── maintenance.md
    └── changelog.md
```

Crie ou atualize só os arquivos que fizerem sentido para o módulo — isso
não é burocracia, não force a existência de um arquivo vazio:

- **`overview.md`** — responsabilidade do módulo, funcionalidades, limites,
  dependências relevantes.
- **`architecture.md`** — organização das camadas, fluxo dos dados,
  componentes principais, dependências, decisões arquiteturais relevantes.
- **`state-management.md`** — como o estado é gerenciado (Bloc/Cubit/
  Provider/etc.), estados possíveis, eventos/métodos disponíveis, quem
  provoca cada transição, fluxo entre UI e camadas inferiores.
- **`api.md`** — endpoints utilizados, modelos, requisições, respostas,
  erros relevantes, autenticação.
- **`maintenance.md`** — como modificar o módulo, pontos de atenção,
  sequência de alterações, testes que devem ser atualizados, documentação
  que deve ser revisada.
- **`changelog.md`** — registro de mudanças estruturais relevantes no
  módulo.

Esta etapa só se aplica quando você está rodando com acesso real ao
repositório do módulo (via Claude Code — o mesmo contexto de
`jira-issue-executor`, seja porque foi chamada por ela/por
`jira-doc-executor` durante a execução de uma issue, seja porque Rafinha
pediu isso explicitamente numa sessão com o repositório aberto). Se você
estiver só no chat, sem acesso ao repositório, pule esta etapa e diga isso
explicitamente no resumo (passo 10) em vez de simular o resultado.

### 10. Apresentar resumo

Ao final, apresente a Rafinha:

```
✅ Página [criada/atualizada]: [link da página]
📋 Seções escritas: [lista das seções, já que aqui não são fixas]
⚠️ Pendências sinalizadas (via doc-pendency-resolver): [quantidade e resumo, ou "nenhuma"]
📝 Gaps/observações documentados (já confirmados por Rafinha, sem pergunta): [lista ou "nenhum"]
🔗 Links para outras páginas: [lista ou "nenhum"]
📁 Arquivos docs/ no código: [lista dos criados/atualizados, ou "não aplicável (sem acesso ao repositório)"]
```

---

## O que NÃO fazer

- ❌ Não use esta skill para páginas de regra de negócio (RN) — critérios de
  aprovação, quem pode solicitar o quê, condições de negócio isoladas. Isso é
  sempre `business-rule-writer`.
- ❌ Não force a estrutura fixa de RN (Visão Geral / Pré-condições / Passo a
  Passo / Regras Específicas) aqui — documentação de módulo tem forma
  própria, adaptada ao conteúdo real.
- ❌ Não marque nada como pendência sem passar pelo `doc-pendency-resolver`
  primeiro — a única exceção são gaps que Rafinha já confirmou como fato.
- ❌ Não invente estrutura de código, status de implementação, ou fluxos que
  não foram confirmados por Rafinha.
- ❌ Não presuma conhecimento implícito do leitor sobre o módulo — mesmo
  sendo documentação técnica, ela precisa ser compreensível por alguém lendo
  pela primeira vez.
- ❌ Não esconda o estado real de implementação para deixar a página "mais
  bonita" — se algo está mockado ou incompleto, isso faz parte do valor da
  documentação.
- ❌ Não crie arquivo de `docs/` vazio ou genérico só para ter os seis
  presentes — só os que o módulo realmente precisa (passo 9).
- ❌ Não simule ou invente que atualizou `docs/` no código quando estiver
  rodando sem acesso ao repositório — declare isso explicitamente no resumo
  (passo 10) em vez de fingir que a etapa foi feita.
