---
name: screen-doc-writer
description: "Elaborar ou reescrever páginas de documentação de tela/UI no Confluence de Rafinha (ex.: Tela - Cadastro de Viagem): campos, componentes, interações, estados e regras de exibição de uma tela Flutter, em tom de estado atual, sem histórico nem citar issues. Usar quando Rafinha disser \"documenta essa tela\", \"atualiza a doc da tela X\", \"revisa o texto dessa página\", enviar link de página de tela, apontar issue em Documentar de alteração de tela/UI, ou pedir print de tela anexado à documentação. Navega a tela de verdade, com o executor web homologado, para tirar prints reais e embuti-los. Três modos com template em references/: screen-doc:dev, screen-doc:user e screen-doc:hybrid; na dúvida, hybrid. O modo nunca é inferido: Rafinha informa, ou a skill pergunta (página existente mantém o modo dela). SEMPRE leia o template do modo. Não usar para regra de negócio isolada (product-doc-writer) nem módulo, arquitetura ou código (tech-doc-writer)."
---

# Escritor de Documentação de Tela/UI — Confluence de Rafinha

## Identidade do papel

> **Nota de origem:** quando esta skill foi planejada pela primeira vez,
> junto com o pipeline de QA automatizado (`jira-qa-executor` → coluna
> "Documentar" → esta skill / `product-doc-writer` / `tech-doc-writer`),
> Rafinha confirmou o **tom de redação** (estado atual, sem histórico — igual
> à `product-doc-writer`) e a **forma dos prints** (embutidos inline, dentro
> da seção a que se referem) — os dois continuam valendo. A estrutura de
> página única de 7 seções daquela primeira versão foi **substituída pelos
> três modos** (`dev`/`user`/`hybrid`) quando a Pendência 4 do Pacote 3 foi
> fechada — ver "Os três modos" logo abaixo. As seções de cada modo vivem
> nos templates em `references/`, não mais aqui.

Ao executar esta skill, você transforma o estado real de uma tela de um
app Flutter (campos, comportamento, estados visuais, regras de exibição)
em uma **página de documentação técnica** no Confluence — escrevendo ou
atualizando diretamente a página cujo link Rafinha fornecer.

O que torna esta skill diferente das outras duas de documentação:

- **Você não parte só da descrição de Rafinha.** Você **navega a tela de
  verdade** com o **executor web homologado** — no Claude Code, o **Claude in
  Chrome** (Chrome real da máquina, não o navegador embutido do Claude Code), mesma
  extensão que a `jira-qa-executor` usa; no Codex, **nenhum está homologado ainda**
  e a skill bloqueia (pré-requisito 3, Contrato do Workflow A.10) — pra observar o
  estado real da UI e tirar os prints que vão pra página. Isso existe justamente para resolver o problema que motivou a
  criação desta skill: documentação que vai ficando desatualizada, com
  texto fraco ou rastros de uma versão antiga da tela, porque foi escrita
  de memória em vez de a partir do que está de fato implementado.
- **O tom é de estado atual, sem histórico.** Diferente da
  `tech-doc-writer` (que narra mudanças e cita issues como documentação
  viva), esta skill escreve como a `product-doc-writer`: frases
  afirmativas sobre como a tela funciona **hoje**, nunca "antes fazia X,
  agora faz Y", e nunca uma referência a número de issue no corpo do
  texto. Isso é proposital — a página precisa ser compreensível por um
  usuário final do sistema, que não tem contexto nenhum sobre Jira.
- **Escopo é comportamento visível da tela, não código.** Nomes de classe,
  arquivo, provider, endpoint — isso é `tech-doc-writer`. Aqui você
  descreve o que qualquer pessoa vê e faz ao usar a tela.

Consulte a skill `workflow-development-flow` para dúvidas sobre como a
etapa "Documentar" se encaixa no fluxo geral do pipeline.

---

---

## Os três modos

A fonte da verdade desta skill é **a UI rodando**, mas o público muda o que
entra na página. Por isso a skill tem três modos, cada um com seu template:

| Modo | Template | Público | Título |
|---|---|---|---|
| `screen-doc:dev` | `references/screen-dev.md` | quem vai mexer na tela | `Tela - <nome> (dev)` |
| `screen-doc:user` | `references/screen-user.md` | quem usa o sistema | `Tela - <nome>` |
| `screen-doc:hybrid` | `references/screen-hybrid.md` | os dois | `Tela - <nome>` |

📄 **Leia o template do modo antes de escrever.** Ele traz as seções, a
convenção de título e a tabela do **que NÃO vai na página** — que é o que
impede esta skill de escrever o que pertence à `tech-doc-writer` ou à
`user-doc-writer`.

### Qual modo usar

> **Na dúvida, `hybrid`.** Duas páginas que ninguém mantém são piores que uma
> página que serve a dois leitores. Separar depois é barato; reconciliar duas
> páginas que divergiram não é.

Use `dev` e `user` separados quando a tela tem **os dois públicos de
verdade** e o conteúdo de um atrapalha a leitura do outro — tela operacional
do produto, usada por quem não conhece o código.

Use `hybrid` em tela interna, simples, ou de público único que é ao mesmo
tempo quem opera e quem mantém.

**O modo nunca é inferido do nome da tela.** Rafinha informa, ou a skill
pergunta. Se a página já existe, o modo dela é o que está escrito lá — não
mude de modo sem confirmar.

### Esta skill é uma peça de um trabalho composto

Documentar uma tela não é trabalho de uma skill só. O conjunto completo é:

| Skill | Granularidade | O que faz na mesma tarefa |
|---|---|---|
| `tech-doc-writer` | por **módulo** | atualiza a página do módulo onde a tela vive |
| `screen-doc-writer` | por **tela** | esta página |
| `user-doc-writer` | por **tarefa** | entra no guia, se a tarefa atravessa telas |

Cada uma escreve só o que a **sua** fonte da verdade entrega, e linka em vez
de repetir. Quem monta o conjunto é a `jira-doc-executor`.

## Contrato da skill

### Finalidade
Documentar uma tela no Confluence a partir da UI rodando de verdade, incluindo
evidências visuais e conteúdo adequado ao público.

### Escopo e acionamento
Opera nos modos `dev`, `user` ou `hybrid`, conforme pedido/delegação ou modo já
estabelecido na página existente.

### Autoridade
- **Decisão.** Observa a UI e seleciona o conteúdo correspondente ao modo. **Não**
  decide ambiguidade de produto. O modo **não** é inferido em silêncio: se não
  estiver definido, é confirmado conforme esta skill.
- **Mutação.** Cria/atualiza a página da tela no Confluence e anexa/substitui os
  screenshots necessários.
- **Atestação.** Atesta o estado visual/funcional **observado** na UI usada durante a
  documentação. Não atesta a arquitetura do módulo inteiro nem o aceite do produto.
- **Transição.** Nenhuma transição Jira por autoridade própria.

### Entradas, obrigações e saída
Entradas: tela e produto; modo documental; ambiente local/dev funcional; executor web
homologado disponível; página/página-mãe; código da tela quando modo `dev`. Obrigações:
navegar a UI real; tirar e embutir prints relevantes; respeitar a separação de
público; usar estado atual; evitar jargão no modo `user`; limitar detalhe técnico ao
escopo da tela; encaminhar informação não observável ao `doc-pendency-resolver`.
Saída: página de tela criada/atualizada no modo correto, com screenshots pertinentes,
limitada ao público e ao escopo da tela. A página e seus screenshots no Confluence
são o artefato documental. **Executor:** a página descreve só o estado atual — nunca
registra executor, tentativa nem histórico; a identidade (Claude | Codex) consta no
comentário Jira de quem delega (Contrato do Workflow, A.9), e o claim da issue é dessa
skill. **Documentação observacional é bloqueada no Codex** até a homologação do executor
visual (captura, anexação e incorporação dos prints verificadas); não existe fallback
para escrever "de memória", do código ou de outro navegador.

### Limites e delegações
Não usa produção; não realiza ação que altere dado real sem confirmação; não inventa
comportamento não observado; não substitui documentação de módulo; não escolhe o modo
em silêncio. Dependências: executor web homologado (Claude in Chrome no Claude Code);
`doc-pendency-resolver`; utilitário de anexos.

> Defaults herdados (silêncio não concede autoridade, acesso técnico não é
> autoridade, delegação não transfere autoridade etc.):
> `workflow-development-flow/references/contrato-skills.md`.

---

## Model Policy

Nível padrão: 0 — Rotina · esforço baixo

Escalar o esforço quando:
- a tela tem muitos estados/condicionais de exibição a reconciliar com o
  que foi observado ao vivo na navegação real.

Escalar para Profundo quando:
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
  `product-doc-writer`.
- Documentação de arquitetura, estrutura de código, ou de um módulo
  inteiro → `tech-doc-writer`.
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

### 1. Confirmar o modo e carregar o template

Antes de qualquer outra coisa, confirme o modo (`dev`, `user` ou `hybrid`) —
ver "Os três modos" acima. **Não infira do nome da tela.** Se a página já
existe, o modo dela é o que já está escrito lá; se é página nova e Rafinha
não informou o modo, pergunte, com `hybrid` como recomendação padrão na
dúvida.

Com o modo confirmado, **leia o template correspondente em `references/`**
antes de prosseguir — ele traz as seções exatas, a convenção de título e o
que não vai na página.

### 2. Link da página do Confluence

Se Rafinha enviou o link, use o conector Atlassian homologado do executor (Rovo no
Claude Code: `getConfluencePage`; no Codex, a operação equivalente) para buscar a
página e checar se já existe conteúdo (atualização) ou não
(criação). Se ele não enviou o link (nem o da página-mãe, no caso de
página nova), pergunte antes de prosseguir — esta skill sempre escreve
diretamente na página, nunca devolve o conteúdo só no chat como entrega
final.

### 3. Executor web homologado

O executor web é **o do seu executor**, e só vale se estiver **homologado**
(Contrato do Workflow, A.10):

| Executor | Executor web | Situação |
|---|---|---|
| Claude Code | **Claude in Chrome** — Chrome real aberto com a extensão instalada e ativa; mesmo pré-requisito da `jira-qa-executor`. **Não** o navegador embutido do Claude Code, porque é o que comprovadamente funciona de forma consistente entre notebooks/ambientes | Homologado |
| Codex | Candidatos: Browser, Computer Use ou extensão do Chrome do Codex | **Nenhum homologado — esta skill bloqueia no Codex** |

Confirme a disponibilidade antes de navegar (passo 2 do fluxo abaixo). Se o executor
web não estiver disponível, ativo ou homologado, **pare e avise Rafinha** — nunca
tente outro navegador, nunca documente "de memória" nem a partir do código no lugar
da observação (B.3: sem fallback silencioso). Para homologar um executor web, a
verificação precisa cobrir de ponta a ponta: **navegar a tela, capturar, anexar na
página do Confluence e incorporar o print inline**, com evidência verificável; só
Rafinha declara a homologação.

### 4. Como chegar na tela, ao vivo

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

### 5. Estado limpo antes de interagir com a tela

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

Usando o executor web homologado (Claude in Chrome no Claude Code, mesma integração
da `jira-qa-executor`):

1. Abra o ambiente confirmado no pré-requisito 4 e navegue até a tela.
2. Leia a tela como ela está: campos visíveis, rótulos, botões, textos de
   ajuda, valores padrão, o que está habilitado/desabilitado no estado
   inicial.
3. Explore as interações relevantes para entender o comportamento real —
   preenchendo campos com dados de exemplo, dessa forma provocando
   validações, mensagens de erro, mudanças de estado — sempre respeitando
   o limite do pré-requisito 5 (nunca submeter uma ação destrutiva/real
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

### 4. Escrever a página seguindo o template do modo

As seções, os títulos e a convenção de título são os do template carregado
no pré-requisito 1 (`references/screen-dev.md`, `screen-user.md` ou
`screen-hybrid.md`, conforme o modo confirmado). Preencha cada seção com o
que foi observado ao vivo (passo 2) ou já confirmado por Rafinha — nunca
improvise uma ordem ou um título que pareça mais natural. Uma seção do
template sem conteúdo correspondente é candidata a pendência (passo 3), não
algo para omitir em silêncio.

Print inline entra nas seções onde o template pede algo visível (campos,
botões, mensagens, estados) — normalmente as primeiras seções nos templates
`user` e `hybrid`. O modo `dev` é predominantemente texto/tabela (rota,
estado, chamadas de API); só leva print quando algo visual for
genuinamente necessário para esclarecer o comportamento técnico.

### 5. Prints: capturar, anexar e embutir

O Atlassian Rovo disponível hoje **não tem uma ferramenta de anexar
arquivo** (nem no Jira, nem no Confluence) — isso já foi confirmado ao
desenhar a `jira-qa-executor`; se o conector do Codex tem uma, isso ainda **não foi
verificado**. O caminho comprovado é a API REST do Confluence, pelo utilitário
compartilhado desta skill (executor-neutro; use o diretório da skill no seu executor —
`~/.claude/skills/` ou `~/.codex/skills/`):

```bash
~/.claude/skills/screen-doc-writer/scripts/anexar-print.sh <pageId> print1.png [print2.png ...]
```

As credenciais (`JIRA_API_EMAIL`/`JIRA_API_TOKEN`) precisam estar no ambiente do
shell do executor; **nunca** as imprima, ecoe ou grave em chat, log, comentário ou
Execution State. Variável ausente = bloqueio: peça a Rafinha, não improvise
credencial.

Ele usa as variáveis `JIRA_API_EMAIL`/`JIRA_API_TOKEN` (as mesmas do anexo no
Jira), converte o caminho para o formato Windows quando roda no Git Bash, e
usa `PUT` — que **substitui** o anexo de mesmo nome em vez de falhar. Isso
importa ao revisar uma página: o print novo da mesma região mantém o nome, e
a macro de imagem que já o referencia continua valendo. O site padrão é
`rafinha84dev.atlassian.net`; `ATLASSIAN_SITE` sobrescreve.

O mesmo utilitário serve a `tech-doc-writer` quando uma página de componente
reutilizável leva print — por isso ele é um script, não um bloco de comando
repetido em cada skill.

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
(`createConfluencePage` ou `updateConfluencePage` no Rovo; a operação equivalente do
conector no Codex). Sem conector Confluence homologado no executor, a publicação
**bloqueia** (A.10). Ao final, apresente a Rafinha:

```
✅ Página [criada/atualizada]: [link da página]
📸 Prints anexados e embutidos: [quantidade] — [em quais seções]
📋 Modo: [dev / user / hybrid] — Seções escritas: [lista, conforme o template do modo]
⚠️ Pendências sinalizadas (via doc-pendency-resolver): [quantidade e resumo, ou "nenhuma"]
🔗 Referências (RN/módulo): [lista ou "nenhuma"]
```

---

## Regras de redação (tom e estilo)

- Tom **imperativo e descritivo do estado atual** — como a `product-doc-writer`.
  Proibido "passou a", "agora a tela faz", "diferente de antes", ou
  qualquer referência a número/chave de issue no corpo do texto.
- **No modo `user`** (e na metade "para quem usa" do `hybrid`): escreva para
  quem opera a tela, não para quem a mantém — linguagem direta, sem jargão
  técnico desnecessário (nada de nome de classe, provider, rota de código,
  endpoint), mas sem eliminar detalhe que muda o comportamento percebido.
- **No modo `dev`** (e no bloco "Detalhes técnicos" do `hybrid`): o oposto
  vale — rota, cubit/provider, chamadas de API e IDs de componente são
  exatamente o que o template pede. O que continua fora, nos três modos, é a
  arquitetura do **módulo inteiro** (isso é sempre `tech-doc-writer`) — aqui
  o escopo técnico é só o que pertence a **esta tela**.
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
  exemplo é permitido, submissão real não é (ver pré-requisito 5).
- ❌ Nunca abrir um ambiente de produção para navegar/capturar prints —
  sempre local/dev, e sempre confirmado com Rafinha se não estiver claro.
- ❌ Nunca prosseguir sem confirmar que o executor web **homologado** está disponível
  (Pré-requisito 3) — no Claude Code, a extensão Claude in Chrome ativa; nunca tente
  o navegador embutido do Claude Code nem outro navegador como alternativa; no Codex,
  enquanto nenhum executor web estiver homologado, a skill não roda. Pare e avise
  Rafinha.
- ❌ Nunca expor `JIRA_API_TOKEN` (nem outra credencial) em chat, log, comentário ou
  Execution State ao anexar prints.
- ❌ Nunca mudar de modo, ou escrever sem ter confirmado um, mesmo quando o
  nome da tela parecer sugerir claramente qual seria (ver pré-requisito 1).
- ❌ Nunca escrever em tom narrativo/histórico ou citar número de issue no
  corpo da página — isso é exclusivo da `tech-doc-writer`.
- ❌ **No modo `user`**, não incluir detalhe de código (classe, arquivo,
  provider, endpoint, rota interna) — isso é comportamento visível, não
  implementação. **No modo `dev`**, o oposto é o erro: omitir rota, estado,
  chamadas de API ou IDs de componente que o template pede é deixar a
  página incompleta.
- ❌ Em nenhum modo, documentar a arquitetura do **módulo inteiro** onde a
  tela vive (camadas, todos os cubits do módulo) — isso é sempre
  `tech-doc-writer`, mesmo no modo `dev`, que só cobre o que é específico
  desta tela.
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
  (`product-doc-writer`) ou documentação de módulo/arquitetura
  (`tech-doc-writer`).
- ❌ Nunca classifique sozinha se uma issue da coluna "Documentar" é sobre
  tela — isso é sempre confirmado por Rafinha antes de você agir.
