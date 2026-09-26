# Template — Regra de negócio

**Label:** `rn-doc` · **Skill:** `product-doc-writer`
**Fonte da verdade:** decisão de produto, explicação de Rafinha
**Convenção de título:** `Regra de Negócio - <nome da regra>` — a forma usada
nas páginas reais do Geoprag e do Compass. Algumas páginas antigas do Geoprag
usam "Regra de negócio" em minúscula; isso é variação, não convenção: página
nova usa "Negócio" com maiúscula, e ao reescrever uma antiga, alinhe o título.

Estrutura **fixa**. As quatro seções são obrigatórias e nesta ordem.

## Visão Geral
O que é a regra e para que serve. 2–4 frases. Sem passos, sem exceções.

## Pré-condições
Tudo que precisa existir para a regra ser aplicável. Uma condição por item,
redigida de forma verificável: *"O cliente deve possuir cadastro ativo"*, não
*"cliente válido"*.

## Passo a Passo da Regra de Negócio
Sequência numerada do início ao fim. Cada passo é uma ação ou verificação
concreta — nada de *"processar solicitação"* sem dizer o que isso envolve.

## Regras Específicas do Negócio
Lista **enumerada**. Cada item: autocontido se der, ou link para a RN
relacionada mais 1–2 frases de contexto — nunca repetindo o conteúdo da outra.

## Tom
Imperativo, estado atual. **Proibido** narrar histórico ("antes era", "passou
a"). Chave de issue não entra no corpo do texto.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Camadas, estrutura de código, contrato de API | Página de módulo | `tech-doc-writer` |
| Campos e botões de uma tela | Página de tela | `screen-doc-writer` |
| Passo a passo de como o usuário opera | Guia de usuário | `user-doc-writer` |

> O passo a passo daqui é o da **regra**, não o da interface. Se você está
> escrevendo "clique em Salvar", é guia de usuário.
