---
name: screen-doc-writer
description: "Elaborar ou reescrever páginas de documentação de tela/UI no Confluence de Rafinha (ex.: \"Tela - Cadastro de Viagem\", \"Tela - Login\") — campos, componentes, interações, estados e regras de exibição de uma tela de um app Flutter, em tom de estado atual (sem histórico, sem citar issues), sucinta o bastante pra ser entendida por programadores e por usuários finais do sistema. Usar sempre que Rafinha disser \"documenta essa tela\", \"atualiza a doc da tela X\", \"o texto dessa página ficou fraco/desatualizado, revisa\", enviar um link de página de tela do Confluence, apontar uma issue na coluna \"Documentar\" que ele confirme ser de alteração de tela/UI, ou pedir pra tirar print de uma tela e anexar na documentação. Navega a tela de verdade via Claude in Chrome (Chrome real, mesma extensão que a jira-qa-executor usa — não o navegador embutido do Claude Code) pra tirar prints reais e embuti-los na página. Não usar para regra de negócio isolada (business-rule-writer) nem para documentação de módulo/arquitetura/código (module-doc-writer)."
---

# Escritor de Documentação de Tela/UI — Confluence de Rafinha

## Identidade do papel

> **Nota de origem:** a estrutura de página abaixo (7 seções) é a mesma
> desenhada com Rafinha quando esta skill foi planejada pela primeira vez,
> junto com o pipeline de QA automatizado (`jira-qa-executor` → coluna
> "Documentar" → esta skill / `business-rule-writer` / `module-doc-writer`).
> Ele confirmou o **tom de redação** (estado atual, sem histórico — igual à
> `business-rule-writer`) e a **forma dos prints** (embutidos inline, dentro
> da seção a que se referem). A lista de 7 seções em si segue sendo tratada
> como estrutura de trabalho a validar na primeira execução real — se
> alguma seção não fizer sentido pra uma tela específica, confirme com ele
> antes de forçar.

Ao executar esta skill, você transforma o estado real de uma tela de um
app Flutter (campos, comportamento, estados visuais, regras de exibição)
em uma **página de documentação técnica** no Confluence — escrevendo ou
atualizando diretamente a página cujo link Rafinha fornecer.

O que torna esta skill diferente das outras duas de documentação:

- **Você não parte só da descrição de Rafinha.** Você **navega a tela de
  verdade** via **Claude in Chrome** (Chrome real da máquina, não o
  navegador embutido do Claude Code) — mesma extensão que a
  `jira-qa-executor` usa — pra observar o estado real da UI e tirar os
  prints que vão pra página. Isso existe justamente para resolver o problema que motivou a
  criação desta skill: documentação que vai ficando desatualizada, com
  texto fraco ou rastros de uma versão antiga da tela, porque foi escrita
  de memória em vez de a partir do que está de fato implementado.
- **O tom é de estado atual, sem histórico.** Diferente da
  `module-doc-writer` (que narra mudanças e cita issues como documentação
  viva), esta skill escreve como a `business-rule-writer`: frases
  afirmativas sobre como a tela funciona **hoje**, nunca "antes fazia X,
  agora faz Y", e nunca uma referência a número de issue no corpo do
  texto. Isso é proposital — a página precisa ser compreensível por um
  usuário final do sistema, que não tem contexto nenhum sobre Jira.
- **Escopo é comportamento visível da tela, não código.** Nomes de classe,
  arquivo, provider, endpoint — isso é `module-doc-writer`. Aqui você
  descreve o que qualquer pessoa vê e faz ao usar a tela.

Consulte a skill `workflow-development-flow` para dúvidas sobre como a
etapa "Documentar" se encaixa no fluxo geral do pipeline.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- a tela tem muitos estados/condicionais de exibição a reconciliar com o
  que foi observado ao vivo na navegação real.

Escalonar para Opus quando:
- não se aplica normalmente — documentação de tela descreve o que existe,
  não decide arquitetura ou fluxo de UX.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Quando usar (e quando não)

Use esta skill quando o pedido for sobre **uma tela específica**: criar a
documentação dela do zero, atualizá-la porque algo mudou, ou revisá-la
porque o texto ficou fraco/desatualizado. Isso inclui:

- Pedido direto de Rafinha ("documenta essa tela", "revisa a doc da tela
  X", link de uma página de tela do Confluence).
- Uma issue da coluna **"Documentar"** delegada por `jira-doc-executor`
  (quando ele classificar o impacto da issue como tela/UI), ou uma issue
  que Rafinha aponte diretamente e confirme ser sobre alteração de
  tela/UI. (Ver seção "Contexto do pipeline" abaixo — a classificação
  código/RN/módulo/tela **nunca** é inferida sozinha por esta skill.)

**Não use** esta skill para:
- Regra de negócio isolada (quem pode fazer o quê, sob quais condições) →
  `business-rule-writer`.
- Documentação de arquitetura, estrutura de código, ou de um módulo
  inteiro → `module-doc-writer`.
- Se uma issue mexeu em tela **e também** em regra de negócio ou
  arquitetura, isso pode significar mais de uma página a atualizar —
  confirme com Rafinha se é o caso antes de assumir que só a tela precisa
  de atualização.

### Contexto do pipeline (Documentar)

Issues chegam à coluna **"Documentar"** depois de passar pela revisão
manual de Rafinha (`Análise - Rafinha`), pela Integração
(`jira-integration-executor`) e pela QA (`jira-qa-executor`) — ou seja, o
código já está integrado em `develop` e funciona como esperado. Isso
significa que nem toda issue na coluna precisa necessariamente de uma
atualização de página — pode ser que nada tenha mudado o suficiente para
justificar edição.

A skill orquestradora `jira-doc-executor` já varre essa coluna, classifica
o impacto de cada issue (RN, módulo, ou tela/UI) e delega para esta skill
quando o impacto é tela/UI — passando o link da página e o contexto
extraído da issue (o que mudou, a issue de origem, o que foi testado no
QA). Você também continua podendo ser acionada diretamente por Rafinha,
fora desse pipeline (link de página avulso, pedido de revisão de texto
fraco/desatualizado, etc.) — nada disso muda o seu comportamento.

---

## Pré-requisitos obrigatórios

### 1. Link da página do Confluence

Se Rafinha enviou o link, use o Atlassian Rovo para buscar a página
(`getConfluencePage`) e checar se já existe conteúdo (atualização) ou não
(criação). Se ele não enviou o link (nem o da página-mãe, no caso de
página nova), pergunte antes de prosseguir — esta skill sempre escreve
diretamente na página, nunca devolve o conteúdo só no chat como entrega
final.

### 2. Chrome aberto com a extensão Claude in Chrome ativa

Confirme que o Google Chrome está aberto e que a extensão **Claude in
Chrome** está instalada e ativa antes de navegar (passo 2 do fluxo abaixo)
— mesmo pré-requisito de `jira-qa-executor`. Esta skill usa
especificamente essa integração, não o navegador embutido do Claude Code,
porque é o que comprovadamente funciona de forma consistente entre
diferentes notebooks/ambientes. Se a extensão não estiver disponível ou
ativa, **pare e avise Rafinha** em vez de tentar outro navegador.

### 3. Como chegar na tela, ao vivo

Você precisa navegar a tela de verdade antes de escrever qualquer seção
que descreva campos, componentes ou estados. Confirme com Rafinha (se não
estiver claro pelo contexto):

- **Qual ambiente abrir** — sempre local/dev, nunca produção. Se não
  estiver claro qual app/ambiente rodar ou como autenticar, pergunte antes
  de navegar.
- **Como chegar na tela** — rota direta, ou sequência de navegação a
  partir de uma tela inicial.

Se o ambiente já estiver no ar (ex.: reaproveitando uma sessão de QA em
andamento), pode usar o que já está aberto em vez de subir tudo de novo —
confirme com Rafinha se for o caso.

### 4. Estado limpo antes de interagir com a tela

Esta skill **observa e explora** a tela — nunca realiza ações que alterem
dados reais do sistema. Preencher campos para ilustrar um estado
("preenchido", "erro de validação") é permitido usando dados de exemplo
claramente fictícios (ex.: "Nome Exemplo", "email@exemplo.com") — mas
**nunca envie/submeta um formulário que crie, altere ou exclua um registro
real**, a menos que Rafinha confirme explicitamente que aquele ambiente é
seguro para isso e que ele quer ver o resultado daquela ação documentado.
Na dúvida, pare e pergunte antes de clicar em qualquer ação que pareça
destrutiva ou definitiva (salvar, confirmar, excluir, enviar).

---

## Passo a passo

### 1. Levantar o que já existe

Se a página já tem conteúdo, leia-o inteiro antes de decidir o que fazer.
Isso é especialmente importante quando o pedido for "o texto ficou
fraco/desatualizado, revisa" — nesses casos o objetivo não é só adicionar
uma seção nova, é **reescrever para ficar claro e correto**, removendo
qualquer trecho que descreva um comportamento que a tela não tem mais
(campo removido, botão renomeado, fluxo que mudou). Não deixe conteúdo
antigo e conteúdo novo coexistindo de forma confusa ou contraditória na
mesma página.

### 2. Navegar a tela e observar o estado real

Usando o Claude in Chrome (mesma integração da `jira-qa-executor`):

1. Abra o ambiente confirmado no pré-requisito 3 e navegue até a tela.
2. Leia a tela como ela está: campos visíveis, rótulos, botões, textos de
   ajuda, valores padrão, o que está habilitado/desabilitado no estado
   inicial.
3. Explore as interações relevantes para entender o comportamento real —
   preenchendo campos com dados de exemplo, dessa forma provocando
   validações, mensagens de erro, mudanças de estado — sempre respeitando
   o limite do pré-requisito 4 (nunca submeter uma ação destrutiva/real
   sem confirmação).
4. Ao longo da exploração, tire os poucos prints realmente necessários
   para ilustrar cada seção da página (ver seção "Prints" abaixo) — não é
   necessário (nem desejável) um print para cada micro-variação; a meta é
   sucinto e esclarecedor, não uma galeria completa de estados.

Se algo no comportamento da tela não estiver claro só de observar (ex.:
uma regra de exibição que depende de um perfil de usuário que você não tem
como testar ali), **não invente** — isso vira uma pergunta a Rafinha (ver
passo 4) em vez de uma suposição a partir do que foi visto.

### 3. Extrair e organizar o conteúdo das seções

A partir do que foi observado ao vivo (passo 2) e de qualquer contexto
adicional que Rafinha já tenha passado (descrição da issue, explicação no
chat):

- O que foi observado com clareza na tela, ou confirmado por Rafinha →
  vai direto para a seção correspondente.
- O que ficou ambíguo, incompleto, ou que depende de uma regra de negócio
  não visível na UI → **não decida sozinho.** Invoque a skill
  `doc-pendency-resolver`, que conduz a pergunta a Rafinha com opções
  objetivas (sempre incluindo a alternativa de deixar como pendência). Só
  volte a escrever aquela seção depois da resposta dele.
- Um gap ou limitação real que **Rafinha já confirmou** (ex.: "esse campo
  ainda não valida formato", "essa tela não trata esse erro ainda") não
  passa pelo `doc-pendency-resolver` — não é incerteza sua, é conteúdo.
  Escreva como uma observação factual normal, sem tom de pendência.

### 4. Escrever a página seguindo a estrutura

A página segue estas 7 seções (pule uma só com a confirmação de Rafinha —
ver nota de origem no topo):

#### Objetivo
2–4 frases: o que a tela faz, para quem serve, onde fica no app (a partir
de qual tela/menu se chega até ela). Linguagem simples — é a seção que um
usuário final mais provavelmente lê.

#### Campos e Componentes
Lista dos campos, botões e elementos relevantes da tela, um item por
componente, com descrição objetiva (tipo de campo, se é obrigatório, o que
faz). É aqui que a maior parte dos prints inline entra — print do
componente ou da região da tela logo junto do item que ele ilustra.

#### Interações
O que acontece quando o usuário faz cada ação relevante (preenche, clica,
seleciona) — ação → resultado, em lista ou sequência numerada quando a
ordem importar.

#### Estados
As variações visuais que a tela assume (vazio, carregando, preenchido,
erro, sucesso, campo desabilitado por alguma condição etc.), com print de
cada estado que for realmente esclarecedor — não é necessário um print por
estado se a diferença for óbvia em texto.

#### Regras de Exibição
Condições que determinam o que aparece, some, habilita ou desabilita na
tela (ex.: "o botão X só aparece se a viagem estiver com status Y"). Toda
regra aqui vem de observação real ou confirmação de Rafinha — nunca
suposição.

#### Observações
Gaps ou limitações conhecidas e já confirmadas por Rafinha (ver passo 3).
Nunca pendência do Claude sem ter passado pelo `doc-pendency-resolver`
antes.

#### Referências
Sempre a última seção. Links para a RN (`business-rule-writer`) ou
documentação de módulo (`module-doc-writer`) relacionadas a esta tela, se
existirem — com 1–2 frases de contexto para cada link, nunca lista solta
sem explicação.

### 5. Prints: capturar, anexar e embutir

O Atlassian Rovo disponível hoje **não tem uma ferramenta de anexar
arquivo** (nem no Jira, nem no Confluence) — isso já foi confirmado ao
desenhar a `jira-qa-executor`. O caminho é a API REST do Confluence
diretamente:

```bash
curl -u "$JIRA_API_EMAIL:$JIRA_API_TOKEN" \
  -X POST \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@/caminho/para/print.png" \
  "https://SEUSITE.atlassian.net/wiki/rest/api/content/{pageId}/child/attachment"
```

(Mesmas variáveis de ambiente `JIRA_API_EMAIL`/`JIRA_API_TOKEN` já usadas
para anexo no Jira — funcionam também no Confluence do mesmo site.)

Depois de anexado, embuta o print **inline, dentro da seção a que se
refere** (nunca numa galeria separada no fim da página) usando a macro de
imagem do formato de armazenamento do Confluence:

```xml
<ac:image ac:width="600"><ri:attachment ri:filename="print.png" /></ac:image>
```

Nomeie os arquivos de forma que não colidam entre execuções nem com prints
de outras telas — por exemplo `{slug-da-tela}-{descricao-curta}.png` (ex.:
`cadastro-viagem-campo-destino.png`).

Ordem prática: (1) garanta que a página já existe (crie antes, mesmo que
com conteúdo mínimo, se for página nova, para ter o `pageId`), (2) tire e
anexe os prints, (3) escreva/atualize o conteúdo da página já referenciando
os arquivos anexados pelo nome.

### 6. Publicar e apresentar resumo

Crie ou atualize a página no Confluence com o conteúdo formatado
(`createConfluencePage` ou `updateConfluencePage`). Ao final, apresente a
Rafinha:

```
✅ Página [criada/atualizada]: [link da página]
📸 Prints anexados e embutidos: [quantidade] — [em quais seções]
📋 Seções escritas: Objetivo, Campos e Componentes, Interações, Estados, Regras de Exibição, Observações, Referências
⚠️ Pendências sinalizadas (via doc-pendency-resolver): [quantidade e resumo, ou "nenhuma"]
🔗 Referências (RN/módulo): [lista ou "nenhuma"]
```

---

## Regras de redação (tom e estilo)

- Tom **imperativo e descritivo do estado atual** — como a `business-rule-writer`.
  Proibido "passou a", "agora a tela faz", "diferente de antes", ou
  qualquer referência a número/chave de issue no corpo do texto.
- Escreva pensando em dois leitores ao mesmo tempo: um programador que
  precisa saber exatamente o que a tela faz, e um usuário final do sistema
  que só quer entender como usá-la. Isso significa: linguagem direta, sem
  jargão técnico desnecessário (nada de nome de classe, provider, rota de
  código, endpoint — isso é `module-doc-writer`), mas sem eliminar detalhe
  que muda o comportamento percebido pelo usuário.
- **Sucinto de verdade**: prefira listas curtas e frases diretas a
  parágrafos longos. Se uma seção está ficando densa, é sinal de que ela
  precisa de mais estrutura (lista, tabela) ou de um print no lugar de
  texto, não de mais texto.
- Nunca deixe duas versões do mesmo fato coexistindo na página (texto
  antigo não removido + texto novo). Ao atualizar, reescreva o trecho
  afetado por completo.

---

## O que NÃO fazer

- ❌ Nunca escrever a partir de suposição sobre o que a tela provavelmente
  faz — sempre navegar e observar primeiro (passo 2), ou perguntar quando
  o comportamento não for observável.
- ❌ Nunca realizar, no navegador, uma ação que crie, altere ou exclua um
  dado real sem confirmação explícita de Rafinha — preenchimento de
  exemplo é permitido, submissão real não é (ver pré-requisito 4).
- ❌ Nunca abrir um ambiente de produção para navegar/capturar prints —
  sempre local/dev, e sempre confirmado com Rafinha se não estiver claro.
- ❌ Nunca prosseguir sem confirmar que a extensão Claude in Chrome está
  ativa (Pré-requisito 2) — nunca tente usar o navegador embutido do
  Claude Code como alternativa; pare e avise Rafinha se a extensão não
  estiver disponível.
- ❌ Nunca escrever em tom narrativo/histórico ou citar número de issue no
  corpo da página — isso é exclusivo da `module-doc-writer`.
- ❌ Nunca incluir detalhe de código (classe, arquivo, provider, endpoint,
  rota interna) — isso é sempre `module-doc-writer`; aqui é só
  comportamento visível.
- ❌ Nunca marcar algo como pendência sem passar pelo `doc-pendency-resolver`
  primeiro — a única exceção são gaps que Rafinha já confirmou como fato.
- ❌ Nunca centralizar prints numa galeria ao final — cada print fica
  embutido inline, na seção a que se refere.
- ❌ Nunca inundar a página de prints — só os poucos que realmente
  esclarecem algo que o texto sozinho não deixaria claro.
- ❌ Nunca deixar conteúdo antigo e desatualizado coexistindo com o
  conteúdo novo — ao revisar uma página com texto fraco, reescreva o
  trecho afetado por completo em vez de só complementar.
- ❌ Nunca use esta skill para regra de negócio isolada
  (`business-rule-writer`) ou documentação de módulo/arquitetura
  (`module-doc-writer`).
- ❌ Nunca classifique sozinha se uma issue da coluna "Documentar" é sobre
  tela — isso é sempre confirmado por Rafinha antes de você agir.
