# Template — Arquitetura para desenvolvedores

**Label:** `architecture-doc` · **Skill:** `tech-doc-writer`
**Fonte da verdade:** o código e a estrutura real
**Convenção de título:** `Arquitetura - <área ou produto>`

> ⚠️ `architecture-doc` pode ser **de produto**. Se o conteúdo é decisão e
> motivação de negócio, a skill é `product-doc-writer`. Aqui é a versão para
> quem vai mexer no código. Na dúvida, pergunte.

## Visão geral
O desenho em 3–5 frases e um diagrama.

## Camadas
Uma subseção por camada: responsabilidade, o que pode depender de quê, e o
que é proibido atravessar.

## Fluxo de dados
Como um pedido entra, atravessa as camadas e volta.

## Decisões estruturantes
Tabela: decisão · alternativa descartada · por quê. Decisão sem alternativa
registrada é difícil de revisitar depois.

## Convenções de codificação
As que valem neste escopo e não são óbvias pelo lint.

## Dependências externas
O que o código depende e por quê. Versão quando importar.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Estrutura de um módulo específico | Página de módulo | `tech-doc-writer`, template `modulo.md` |
| Contrato de endpoint | Página de API | `tech-doc-writer`, template `api.md` |
| Motivação de produto da arquitetura | Requisito ou RN | `product-doc-writer` |
