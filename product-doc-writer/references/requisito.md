# Template — Requisito

**Skill:** `product-doc-writer`
**Fonte da verdade:** decisão de produto, explicação de Rafinha
**Convenção de título:** `Requisito - <nome>`

## Contexto
Que problema de produto este requisito atende, e por quê. Sem solução ainda.

## Declaração
Uma frase, verificável, no presente. *"O sistema deve permitir que o
Administrador revogue o acesso de um Aplicador sem excluir o cadastro."*

## Escopo
O que entra e, explicitamente, **o que fica fora**. A segunda lista costuma
valer mais que a primeira.

## Regras associadas
Links para as RNs que detalham o comportamento. O requisito diz *o quê*; a RN
diz *como se comporta*.

## Dependências
Outros requisitos, módulos ou decisões que precisam existir antes.

## Pendências funcionais
Só via `doc-pendency-resolver`. Posicionadas na seção a que se referem.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Como a regra se processa, passo a passo | RN | `product-doc-writer`, template `rn.md` |
| Decisão técnica de implementação | Página de módulo ou ADR | `tech-doc-writer` |
| Critério de teste | Critérios de aceitação | `product-doc-writer`, template `criterios-aceitacao.md` |
