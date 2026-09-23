# Template — Caso de uso

**Skill:** `product-doc-writer`
**Fonte da verdade:** decisão de produto, explicação de Rafinha
**Convenção de título:** `Caso de uso - <ator> <ação>`

## Ator
Quem executa. Use o papel do domínio (Administrador, Aplicador, Agente), não
"usuário" genérico.

## Objetivo
O que o ator quer conseguir. Uma frase, do ponto de vista dele.

## Pré-condições
Estado do sistema antes de começar.

## Fluxo principal
Sequência numerada do caminho feliz.

## Fluxos alternativos
Variações legítimas que ainda atingem o objetivo.

## Fluxos de exceção
O que acontece quando dá errado, e onde o ator fica.

## Pós-condições
Estado do sistema depois, no fluxo principal.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Nome de campo, botão, mensagem de tela | Página de tela | `screen-doc-writer` |
| Instrução operacional ("clique aqui") | Guia de usuário | `user-doc-writer` |
| Condição de negócio isolada | RN | `product-doc-writer`, template `rn.md` |

> Caso de uso descreve **a interação em termos de domínio**, não a navegação
> na interface. Se o texto só faz sentido olhando a tela, é doc de tela.
