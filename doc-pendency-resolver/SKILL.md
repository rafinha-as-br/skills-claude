---
name: "doc-pendency-resolver"
description: "Define como lidar com qualquer ponto de informação incerto, ambíguo, incompleto, ou marcado como \"a verificar\" ao escrever ou editar documentação do Confluence do Rafael (páginas de regra de negócio, documentação de módulo, ou qualquer outra doc formal). Use esta skill SEMPRE que, executando outra skill de documentação (como business-rule-writer ou module-doc-writer) ou qualquer tarefa de escrita de doc, você estiver prestes a marcar algo como \"pendência\" sem antes ter perguntado a Rafinha — isso nunca deve acontecer sem passar por aqui primeiro. Também use quando Rafinha pedir para criar/atualizar uma página e a descrição dele deixar lacunas, contradições, ou decisões não especificadas. Esta skill não escreve a página em si — ela resolve, via perguntas objetivas no chat, o que vai para dentro dela quando há incerteza."
---

---
name: doc-pendency-resolver
description: "Define como lidar com qualquer ponto de informação incerto, ambíguo, incompleto, ou marcado como \"a verificar\" ao escrever ou editar documentação do Confluence do Rafael (páginas de regra de negócio, documentação de módulo, ou qualquer outra doc formal). Use esta skill SEMPRE que, executando outra skill de documentação (como business-rule-writer ou module-doc-writer) ou qualquer tarefa de escrita de doc, você estiver prestes a marcar algo como \"pendência\" sem antes ter perguntado a Rafinha — isso nunca deve acontecer sem passar por aqui primeiro. Também use quando Rafinha pedir para criar/atualizar uma página e a descrição dele deixar lacunas, contradições, ou decisões não especificadas. Esta skill não escreve a página em si — ela resolve, via perguntas objetivas no chat, o que vai para dentro dela quando há incerteza."
---

# Resolvedor de Pendências de Documentação

## Identidade do papel

Esta skill é chamada de dentro de outra skill de documentação (business-rule-writer,
module-doc-writer, ou qualquer skill futura que escreva páginas formais no
Confluence do Rafael). Ela não produz conteúdo de página sozinha — ela resolve,
via conversa no chat, o que fazer com um ponto de informação que a skill
anfitriã não tem como preencher sozinha com segurança.

## Por que esta skill existe

Documentação de regra de negócio ou de módulo vira fonte de verdade para quem
implementa depois. Uma pendência marcada sem que Rafinha tenha sido consultado
é, na prática, uma decisão tomada por adivinhação — e decisões erradas na
documentação se propagam para o código, para outras páginas que linkam essa
página, e para quem lê meses depois sem o contexto da conversa original.

Por isso o padrão aqui é inverter a ordem: perguntar antes de escrever, não
escrever e sinalizar depois. Isso também dá a Rafinha controle real sobre o
que fica pendente — ele decide explicitamente que um ponto não bloqueia a
publicação, em vez de descobrir depois de publicado que algo passou
despercebido.

## Quando usar

Sempre que, escrevendo ou editando uma página de documentação, você encontrar
um destes casos:

- Falta uma informação necessária para a seção que está sendo escrita.
- Existe mais de uma forma plausível de implementar/interpretar algo, e
  nenhuma foi explicitada.
- Rafinha marcou algo como "a verificar" no material bruto que ele enviou.
- Uma issue do Jira (ou outra fonte) menciona um comportamento sem detalhar
  como ele funciona de fato.

Em qualquer um desses casos, **pare antes de escrever essa parte da página**
e siga o processo abaixo. Nunca escreva um painel de pendência diretamente na
página sem ter passado por essa conversa primeiro.

**Não é o mesmo caso quando** Rafinha já descreveu um gap real e conhecido do
sistema (ex.: "essa parte ainda está mockada", "falta fechar o contrato dessa
API") — isso não é uma incerteza sua, é conteúdo que ele já confirmou. Nesse
caso apenas documente o gap normalmente, seguindo o formato que a skill
anfitriã usa para isso; não há pergunta a fazer.

## Como perguntar

1. **Formule a pergunta em torno do ponto exato que falta.** Título curto
   (vira o cabeçalho da pergunta) + a pergunta completa, sem jargão
   desnecessário.

2. **Ofereça respostas concretas, não abertas.** Pense em 2 a 4 alternativas
   genuinamente plausíveis dado o contexto que você já tem (a página-mãe,
   páginas relacionadas, o domínio do sistema) — não opções genéricas tipo
   "sim/não" sem explicação. Se você tem uma recomendação técnica clara,
   coloque-a como primeira opção, marcada como recomendada, com o porquê.

3. **Se o ponto envolver um trade-off técnico não óbvio** (ex.: duas
   arquiteturas possíveis, dois algoritmos de cálculo), explique com um
   exemplo concreto — não presuma que os rótulos das opções bastam sozinhos.
   Rafinha pode pedir para você reexplicar em vez de responder direto; nesse
   caso, dê um exemplo numérico ou de fluxo real (ex.: "imagine que existem 6
   Administradores...") antes de perguntar de novo.

4. **Sempre inclua, entre as opções, a alternativa de deixar como
   pendência.** Essa opção precisa deixar claro que:
   - o ponto **não bloqueia** a publicação da página;
   - ele será registrado como um painel de pendência formal, na seção exata
     a que se refere (nunca centralizado no fim da página);
   - fica marcado para revisão futura, não é uma decisão definitiva.

   Rafinha usa essa opção para os pontos que ele considera de fato
   não-bloqueantes — é diferente de você decidir isso por ele.

5. **Agrupe perguntas relacionadas na mesma rodada** quando fizer sentido (até
   4 por chamada da ferramenta de pergunta), em vez de perguntar um ponto,
   esperar resposta, perguntar o próximo. Isso reduz idas e vindas. Não
   agrupe pontos sem relação entre si só para economizar uma rodada — cada
   pergunta deve fazer sentido isolada.

## Depois da resposta

- Se Rafinha escolheu uma resposta concreta → escreva essa resposta
  diretamente como conteúdo confirmado da seção, sem nenhum aviso de
  pendência.
- Se Rafinha escolheu "deixar como pendência" → escreva o painel de aviso na
  seção correspondente, seguindo o formato de pendência já usado pela skill
  que está escrevendo a página.
- Se a resposta dele revelar que você entendeu errado o contexto, ou que
  existe uma opção que nem tinha sido considerada → ajuste a pergunta e
  pergunte de novo antes de escrever qualquer coisa. Nunca force a resposta
  dele em uma das opções originais se ela não se encaixa.

## O que NÃO fazer

- ❌ Nunca marque algo como pendência na página sem ter perguntado antes —
  mesmo que pareça um detalhe pequeno.
- ❌ Nunca invente uma resposta e a apresente como se fosse confirmada por
  Rafinha.
- ❌ Nunca omita a opção de "deixar como pendência" — mesmo quando você tem
  certeza de que o ponto é importante, a decisão de bloquear ou não é dele,
  não sua.
- ❌ Nunca junte vários pontos não relacionados em uma única pergunta/opção
  só para simplificar — isso obscurece o que está sendo de fato decidido.
- ❌ Nunca decida sozinho que um ponto "não importa" e por isso pule a
  pergunta — se você notou a lacuna, ela precisa passar por aqui.
- ❌ Nunca transforme um gap de sistema já confirmado por Rafinha (ex.: algo
  que ele mesmo disse que está mockado ou incompleto) em uma pergunta —
  isso já é conteúdo, não incerteza sua.

