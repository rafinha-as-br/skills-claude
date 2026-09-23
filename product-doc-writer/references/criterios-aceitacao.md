# Template — Critérios de aceitação

**Skill:** `product-doc-writer`
**Fonte da verdade:** decisão de produto
**Convenção de título:** `Critérios de aceitação - <requisito ou entrega>`

## O que está sendo aceito
Link para o requisito, a RN ou a entrega. Uma frase de contexto.

## Critérios
Lista **numerada**. Cada critério é verificável por observação, e escrito de
forma que duas pessoas cheguem ao mesmo veredito.

```
Dado <contexto>
Quando <ação>
Então <resultado observável>
```

Critério que depende de interpretação não é critério — é pendência.

## Fora do aceite
O que explicitamente **não** está sendo avaliado nesta entrega.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Caso de teste executável, evidência, resultado | AIO Tests | `jira-qa-executor` |
| Cenário de validação humana | Issue de Validação Humana | `jira-human-validation-executor` |

> **Critério de aceitação ≠ caso de teste.** O critério diz o que precisa ser
> verdade; o caso de teste diz como verificar. O segundo vive no AIO Tests,
> não no Confluence.
