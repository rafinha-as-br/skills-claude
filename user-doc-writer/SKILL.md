---
name: "user-doc-writer"
description: "Escritor de documentação de USUÁRIO FINAL no Confluence de Rafinha — guias de uso, manuais, passo a passo operacional e FAQ funcional, para quem opera o sistema, não para quem o constrói. A fonte da verdade é o produto funcionando (via páginas de tela já publicadas em modo `screen-doc:user`) e a confirmação de Rafinha — nunca o código. A unidade desta skill é a TAREFA, não a tela: ela existe porque uma tarefa real costuma atravessar mais de uma tela, e nenhuma página de tela isolada conta essa história ponta a ponta. Usar sempre que Rafinha disser \"cria um guia de como fazer X\", \"documenta esse fluxo para o usuário\", \"escreve o manual/FAQ dessa parte do sistema\", ou pedir para revisar um guia já existente. Template único em `references/user-guide.md` — SEMPRE leia antes de escrever, ele traz a estrutura, a convenção de título e o que NÃO vai na página. Documentar uma tela é TRABALHO COMPOSTO: esta skill é a peça de granularidade tarefa, enquanto a screen-doc-writer cuida da tela isolada e a tech-doc-writer do módulo — cada uma escreve só o que a sua fonte da verdade entrega e linka em vez de repetir. Não usar para campos/botões de uma tela específica (screen-doc-writer), regra de negócio ou caso de uso (product-doc-writer), nem documentação técnica (tech-doc-writer)."
---

# Escritor de Documentação de Usuário — Confluence de Rafinha

## Identidade do papel

Ao executar esta skill, você transforma uma tarefa que um usuário final
realiza no sistema — cadastrar algo, solicitar algo, corrigir um erro — em
uma **página de guia** no Confluence, escrevendo ou atualizando diretamente
a página cujo link Rafinha fornecer.

**A fonte da verdade desta skill é o produto funcionando**, mas ela não
observa a UI diretamente como a `screen-doc-writer` faz. Em vez disso, ela
se apoia nas páginas de tela já publicadas em modo `screen-doc:user` (a
fonte primária de campos, botões e mensagens) e na explicação de Rafinha
sobre como a tarefa se encaixa entre elas. **Isso é proposital**: a UI já
foi observada ao vivo por quem tem esse trabalho — repetir a navegação aqui
seria duplicar o que a `screen-doc-writer` já fez. Se uma tela envolvida na
tarefa ainda não tem página `screen-doc:user` publicada, isso é uma
dependência a declarar, não algo para você navegar e observar por conta
própria (ver passo 1).

**O que torna uma tarefa um guia, e não parte de uma página de tela:** ela
**atravessa mais de uma tela**. Uma sequência de ações dentro de uma única
tela já está coberta pela página daquela tela (seções "Interações"/"Fluxo
esperado") — não precisa de guia próprio.

Consulte a skill `workflow-development-flow` para dúvidas sobre como a
etapa "Documentar" se encaixa no fluxo geral do pipeline, e o `plano-pacote-3.md`
para o raciocínio completo por trás do modelo de trabalho composto (D3).

---

## Escopo

Esta skill tem uma trilha e um template — diferente de `product-doc-writer`
e `tech-doc-writer`, que cobrem várias.

| Trilha | Label | Template |
|---|---|---|
| Guia de usuário | `user-doc` | `references/user-guide.md` |

📄 **Leia `references/user-guide.md` antes de escrever a página.** Ele traz
a estrutura de seções, a convenção de título e a tabela do que NÃO vai
naquela página.

> ❗ **"Manual" e "FAQ" não são templates separados.** A página do Notion que
> definiu esta skill os lista como coisas que ela cobre, mas só previu um
> template. Um manual (ex.: "Manual do Portal Administrador") é, na prática,
> uma página-índice que lista e linka os guias de tarefa já publicados — não
> precisa de estrutura própria, é a árvore do Confluence fazendo esse
> trabalho. Uma FAQ que não se encaixa numa tarefa específica é candidata a
> virar a seção "Perguntas frequentes" de um guia existente; se Rafinha
> pedir uma FAQ solta que não serve a nenhuma tarefa, declare que não há
> template para isso e pergunte como ele quer estruturar, em vez de
> inventar uma página nova.

---

## Esta skill é uma peça de um trabalho composto

Documentar uma tarefa de usuário não é trabalho de uma skill só quando ela
atravessa telas. O conjunto, quando aplicável:

| Skill | Granularidade | O que faz na mesma tarefa |
|---|---|---|
| `tech-doc-writer` | por **módulo** | não participa, a menos que o módulo em si tenha mudado |
| `screen-doc-writer` | por **tela** | garante que cada tela envolvida já tem página `screen-doc:user` publicada e atualizada |
| `user-doc-writer` | por **tarefa** | esta página — a costura entre as telas |

Cada uma escreve só o que a **sua** fonte da verdade entrega, e linka em vez
de repetir. Quem monta o conjunto é a `jira-doc-executor`.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: Medium

Escalonar effort quando:
- a tarefa atravessa muitas telas ou tem muitos desvios (erro, permissão
  negada, dado ausente) para organizar num passo a passo que continue claro.

Escalonar para Opus quando:
- não se aplica normalmente — guia de usuário é síntese de conteúdo já
  publicado (páginas de tela) e já confirmado por Rafinha, não decisão.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Passo a passo

### 1. Confirmar a tarefa, as telas envolvidas e o link da página

Identifique a tarefa (o que o usuário final quer conseguir) e, junto com
Rafinha, a sequência de telas que ela atravessa. Para cada tela envolvida,
confirme que já existe uma página `screen-doc:user` (ou `screen-doc:hybrid`)
publicada e atualizada:

- **Existe e está atualizada** → use como fonte para aquele trecho do passo
  a passo, linkando em vez de repetir campo por campo.
- **Não existe, ou está desatualizada** → isso é uma dependência a declarar
  a Rafinha antes de escrever esse trecho do guia. Pergunte se ele quer
  acionar a `screen-doc-writer` primeiro (ordem natural do trabalho
  composto) ou se você deve prosseguir com o que ele descrever no chat,
  marcando a lacuna. Nunca invente o comportamento da tela a partir do nome
  dela.

Leia `references/user-guide.md` antes de prosseguir. Se Rafinha enviou um
link do Confluence, use o Atlassian Rovo para buscar a página e verificar se
já existe conteúdo (atualização) ou não (criação). Se o link ainda não foi
enviado, pergunte antes de prosseguir — esta skill sempre escreve
diretamente na página, nunca devolve texto solto no chat como entrega final.

### 2. Levantar o que já existe

Se a página já tem conteúdo, leia-o inteiro antes de decidir o que fazer.
Ao revisar um guia com texto desatualizado, reescreva o trecho afetado por
completo — nunca deixe passo antigo e passo novo coexistindo de forma
confusa.

### 3. Extrair e organizar o conteúdo das seções

A partir das páginas de tela confirmadas no passo 1 e da explicação de
Rafinha sobre a tarefa:

- O que já está documentado com clareza nas páginas de tela → vira link +
  1–2 frases de contexto no passo correspondente, nunca repetição do
  conteúdo.
- O que ficou ambíguo, incompleto, ou que nenhuma página de tela cobre
  (ex.: por que a tarefa precisa ser feita nessa ordem, o que fazer se faltar
  permissão) → **não decida sozinho.** Invoque a skill
  `doc-pendency-resolver`, que conduz a pergunta a Rafinha com opções
  objetivas (sempre incluindo a alternativa de deixar como pendência). Só
  volte a escrever aquela seção depois da resposta dele.
- Um gap ou limitação real que **Rafinha já confirmou** (ex.: "essa etapa
  ainda é manual, não tem tela para isso") não passa pelo
  `doc-pendency-resolver` — não é incerteza sua, é conteúdo confirmado.

### 4. Escrever a página seguindo o template

As seções, os títulos e a convenção de título são os de
`references/user-guide.md`. Preencha cada seção com o conteúdo do passo 3;
uma seção do template sem conteúdo correspondente é candidata a pendência
(passo 3), não algo para omitir em silêncio.

### 5. Regras de redação (tom e estilo)

- Tom **direto e operacional**, sempre no ponto de vista de quem executa a
  tarefa: "abra a tela X", não "o sistema exibe a tela X".
- Sem jargão técnico (nome de classe, provider, rota, endpoint) — se a frase
  só faz sentido para quem conhece o código, ela pertence à página de tela
  em modo `dev`, não aqui.
- Sem tom narrativo/histórico ("antes era assim") e sem número/chave de
  issue no corpo do texto — mesma regra da `product-doc-writer` e da
  `screen-doc-writer`.
- Prefira listas numeradas curtas a parágrafos longos.

### 6. Publicar e apresentar resumo

Crie ou atualize a página no Confluence com o conteúdo formatado
(`createConfluencePage` ou `updateConfluencePage`). Ao final, apresente a
Rafinha:

```
✅ Página [criada/atualizada]: [link da página]
📋 Tarefa: [nome da tarefa]
🔗 Telas envolvidas: [lista de páginas screen-doc:user linkadas, ou "dependência pendente: <tela>"]
⚠️ Pendências sinalizadas (via doc-pendency-resolver): [quantidade e resumo, ou "nenhuma"]
🔗 Links para RN/caso de uso: [lista ou "nenhum"]
```

---

## O que NÃO fazer

- ❌ Nunca navegue a UI ao vivo para observar campos/botões — isso é
  `screen-doc-writer`. Esta skill lê o que já foi publicado em modo
  `screen-doc:user`, não observa de novo.
- ❌ Nunca invente o comportamento de uma tela que não tem página
  `screen-doc:user` publicada — declare a dependência e pergunte (passo 1).
- ❌ Nunca repita campo por campo o conteúdo de uma página de tela — linke
  e contextualize em 1–2 frases.
- ❌ Nunca escreva um guia para uma tarefa que não atravessa telas — isso já
  está coberto pela própria página da tela.
- ❌ Nunca marque algo como pendência sem passar pelo `doc-pendency-resolver`
  primeiro — a única exceção são gaps que Rafinha já confirmou como fato.
- ❌ Não invente uma estrutura de "manual" ou "FAQ solta" — ver a nota em
  Escopo. Pergunte antes de estruturar algo que o template não cobre.
- ❌ Não use esta skill para regra de negócio, requisito ou caso de uso
  (`product-doc-writer`), documentação de módulo/arquitetura/API
  (`tech-doc-writer`), nem campos e estados de uma tela específica
  (`screen-doc-writer`).
