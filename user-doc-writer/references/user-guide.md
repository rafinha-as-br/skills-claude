# Template — Guia de usuário

**Label:** `user-doc` · **Skill:** `user-doc-writer`
**Fonte da verdade:** o produto funcionando — via páginas de tela (`screen-doc:user`) já publicadas, mais a confirmação de Rafinha
**Convenção de título:** `Guia - <tarefa>`

## Objetivo da tarefa
O que o usuário final consegue fazer ao final do guia. Uma frase, no ponto de
vista de quem executa — não do sistema.

## Quando usar
A situação ou necessidade que leva alguém a seguir este guia.

## Pré-requisitos
O que precisa existir ou estar configurado antes de começar: perfil, permissão,
cadastro prévio, dado que precisa já estar cadastrado.

## Passo a passo
Sequência numerada, atravessando as telas que a tarefa exige. Cada passo linka
a página de tela (`screen-doc:user`) envolvida em vez de repetir campo por
campo — aqui só entra o que muda de uma tela para outra: "abra X", "preencha Y
e confirme", "avance para Z".

## Perguntas frequentes
Só quando houver dúvidas reais e recorrentes sobre esta tarefa — seção
opcional, não force. Formato pergunta/resposta direta.

## O que fazer se der errado
Erros comuns nesta tarefa e o que fazer diante deles. Complementar às
mensagens de erro já documentadas na página de cada tela, nunca repetição
delas.

## Referências
Sempre a última seção. Links para as páginas de tela (`screen-doc:user`)
envolvidas e para a RN/caso de uso relacionados, cada um com 1–2 frases de
contexto — nunca uma lista solta sem explicação.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Campo, botão, mensagem de uma tela específica | Página de tela | `screen-doc-writer`, modo `user` |
| Regra de negócio isolada | RN | `product-doc-writer` |
| Interação em termos de domínio, sem ser passo a passo operacional | Caso de uso | `product-doc-writer` |
| Rota, cubit, chamada de API | Página de tela, modo `dev` | `screen-doc-writer` |

> Guia de usuário é a tarefa **ponta a ponta**. Se o texto só faz sentido
> numa tela só, é doc de tela, não guia — a tarefa **atravessar telas** é o
> que justifica esta página existir separada da página de tela.
