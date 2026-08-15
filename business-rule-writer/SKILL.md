---
name: "business-rule-writer"
description: "Elaborar ou reescrever páginas de regra de negócio (RN) no Confluence do Rafael, seguindo uma estrutura fixa (Visão Geral, Pré-condições, Passo a Passo, Regras Específicas do Negócio) e um tom estritamente imperativo/descritivo do estado atual. Usar sempre que Rafael disser \"cria uma regra de negócio\", \"documenta essa regra\", \"escreve essa RN no Confluence\", enviar um link de página do Confluence junto com uma descrição de regra, ou pedir para revisar/reescrever uma regra de negócio já existente. Também usar quando ele mencionar \"pendência\" ou \"a verificar\" dentro do contexto de uma regra de negócio que está sendo escrita. Exclusiva para regras de negócio isoladas (quem pode fazer o quê, sob quais condições) — não usar para documentação geral de módulo, arquitetura ou estrutura de código; para isso, use a skill module-doc-writer."
---

---
name: business-rule-writer
description: "Elaborar ou reescrever páginas de regra de negócio (RN) no Confluence do Rafael, seguindo uma estrutura fixa (Visão Geral, Pré-condições, Passo a Passo, Regras Específicas do Negócio) e um tom estritamente imperativo/descritivo do estado atual. Usar sempre que Rafael disser \"cria uma regra de negócio\", \"documenta essa regra\", \"escreve essa RN no Confluence\", enviar um link de página do Confluence junto com uma descrição de regra, ou pedir para revisar/reescrever uma regra de negócio já existente. Também usar quando ele mencionar \"pendência\" ou \"a verificar\" dentro do contexto de uma regra de negócio que está sendo escrita. Exclusiva para regras de negócio isoladas (quem pode fazer o quê, sob quais condições) — não usar para documentação geral de módulo, arquitetura ou estrutura de código; para isso, use a skill module-doc-writer."
---

# Escritor de Regras de Negócio — Confluence do Rafael

## Identidade do papel

Ao executar esta skill, você transforma uma descrição bruta de regra de
negócio (texto corrido, rascunho, anotações soltas, áudio transcrito) em uma
**página do Confluence** formal, estruturada e pronta para consulta —
escrevendo/atualizando diretamente na página cujo link Rafael fornecer.

Esta skill é exclusiva para **regras de negócio isoladas** — quem pode
solicitar/executar o quê, sob quais condições, com qual critério de
aprovação. Se o pedido for para documentar um módulo inteiro (arquitetura,
estrutura de código, fluxos de tela, estado de implementação), isso é
`module-doc-writer`; se for sobre campos, componentes e estados de uma
tela específica, isso é `screen-doc-writer` — nenhuma das duas usa a
estrutura fixa de 4 seções abaixo. Se ficar em dúvida sobre qual das três
se aplica, pergunte a Rafael antes de começar a escrever.

Rafael sempre envia o **link da página do Confluence** junto com o pedido.
Use o Atlassian Rovo para ler a página (se já existir conteúdo) e para
criar/atualizar o conteúdo formatado diretamente nela.

Consulte a skill `workflow-development-flow` para dúvidas sobre como a
documentação de regras de negócio se encaixa no fluxo geral do pipeline
(hierarquia, etapas, classificação código/documentação).

---

## O que NÃO fazer

- ❌ Nunca escrever em tom narrativo ou histórico ("antes era assim, agora
  mudou para..."). O leitor não precisa saber que houve alteração — só
  precisa saber como funciona **hoje**.
- ❌ Não inventar pré-condições, passos ou regras que não foram informados
  por Rafael. Se algo não foi confirmado, pare e pergunte via
  `doc-pendency-resolver` antes de decidir o que escrever — nunca marque
  como pendência sem ter perguntado primeiro (ver seção "Tratamento de
  pendências").
- ❌ Não resumir demais as Regras Específicas — cada uma deve ser enumerada
  e detalhada individualmente.
- ❌ Não centralizar avisos de pendência em um bloco único no fim da página —
  cada pendência fica posicionada exatamente na seção a que se refere.
- ❌ Não presumir conhecimento implícito do leitor sobre o negócio.
- ❌ Não use esta skill para documentação de módulo, arquitetura, estrutura
  de código, fluxos de tela, ou estado de implementação — isso é sempre
  `module-doc-writer`. Esta skill serve só para regras de negócio isoladas.

---

## Passo a passo

### 1. Obter o conteúdo bruto e o link da página

Se Rafael enviou um link do Confluence, use o Atlassian Rovo para buscar a
página (`getConfluencePage` ou equivalente) e verificar se já existe conteúdo
— nesse caso, trata-se de uma reescrita/atualização, não de criação do zero.

Se o link ainda não foi enviado nesta interação, pergunte por ele antes de
prosseguir — esta skill sempre escreve diretamente na página, nunca apenas
devolve texto solto no chat como entrega final.

### 2. Extrair e organizar as informações

A partir da descrição de Rafael, identifique o conteúdo correspondente a
cada uma das quatro seções obrigatórias (ver estrutura abaixo). Separe
mentalmente:
- O que foi dito com clareza → vai direto para a seção correspondente.
- O que Rafael marcou como incerto, "a verificar", ou que ficou ambíguo →
  precisa passar pela skill `doc-pendency-resolver` antes de virar conteúdo
  ou pendência na página (ver seção 4).
- Regras específicas que remetem a outra regra de negócio já documentada →
  precisam de link + contextualização breve (ver seção 4).

### 3. Escrever a página seguindo a estrutura fixa

A página **sempre** segue esta ordem e estas quatro seções:

#### Visão Geral
Resumo objetivo do que é a regra e para que serve. 2–4 frases, sem
detalhamento de passos ou exceções — isso vem nas seções seguintes.

#### Pré-condições
Lista de todas as condições que devem existir para que a regra seja
aplicável/executável. Uma condição por item, redigida de forma verificável
(ex.: "O cliente deve possuir cadastro ativo no sistema").

#### Passo a Passo da Regra de Negócio
Sequência numerada e detalhada de como a regra se processa do início ao
fim. Cada passo deve ser uma ação ou verificação clara — evite passos vagos
como "processar solicitação" sem explicar o que isso envolve.

#### Regras Específicas do Negócio
Lista **enumerada** de regras específicas que compõem ou detalham a regra
principal. Para cada item:
- Se for autocontido → descreva a regra específica por completo.
- Se depender de/relacionar-se com outra regra de negócio já documentada →
  insira o link da página relacionada e acrescente 1–2 frases de
  contextualização (nunca repita o conteúdo da outra página).

### 4. Tratamento de pendências

Toda informação não confirmada, incerta, ou explicitamente marcada por
Rafael como "a verificar" **nunca vira pendência diretamente na página**.
Antes de escrever qualquer painel de aviso, invoque a skill
`doc-pendency-resolver` — ela conduz a pergunta a Rafael com opções
objetivas e concretas, incluindo sempre a alternativa explícita de deixar
aquele ponto como pendência a resolver depois. Só depois da resposta dele
você decide o que vai para a página:

- Resposta concreta → vira conteúdo confirmado na seção correspondente, sem
  nenhum aviso de pendência.
- Escolha explícita de "deixar como pendência" → vira o painel de
  observação abaixo, posicionado exatamente na seção a que se refere (nunca
  centralizado no fim da página).

Formato do painel (macro de aviso/callout do Confluence — tipo "Info" ou
"Warning"):
> ⚠️ **Pendência**: [descrição objetiva do que falta confirmar]. [Link para
> página relacionada, se aplicável].

### 5. Regras de redação (tom e estilo)

- Tom **imperativo e descritivo do estado atual** — frases afirmativas
  sobre como o sistema/negócio funciona.
- Proibido qualquer referência a mudança de regra, versão anterior, ou
  histórico ("passou a", "agora o sistema faz", "diferente de antes").
- Linguagem técnica, direta, sem rodeios — mas sem eliminar informação
  necessária para entendimento completo e independente da regra.

### 6. Publicar e apresentar resumo

Crie ou atualize a página no Confluence com o conteúdo formatado (usando
`createConfluencePage` ou `updateConfluencePage` conforme o caso). Ao final,
apresente a Rafael:

```
✅ Página [criada/atualizada]: [link da página]
📋 Seções preenchidas: Visão Geral, Pré-condições, Passo a Passo, Regras Específicas
⚠️ Pendências sinalizadas: [quantidade e resumo breve de cada uma, ou "nenhuma"]
🔗 Links para outras regras: [lista ou "nenhum"]
```

---

## Regras importantes

- Sempre exija o link da página do Confluence antes de escrever — não gere
  conteúdo solto no chat como entrega final desta skill.
- Se o texto de Rafael já contiver links ou nomes de outras regras de
  negócio, procure a página relacionada no Confluence antes de linkar, para
  confirmar que o link está correto.
- Nunca marque algo como pendência sem antes ter perguntado via
  `doc-pendency-resolver` — ver seção 4. Pendência só existe na página
  depois que Rafael escolheu explicitamente deixar aquele ponto em aberto.
- Nunca elimine uma pendência já registrada por conta própria assumindo uma
  resposta — pendência só é resolvida quando Rafael confirma a informação.
- Escreva sempre em português.
