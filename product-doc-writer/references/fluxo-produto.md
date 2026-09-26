# Template — Fluxo de produto

**Skill:** `product-doc-writer`
**Fonte da verdade:** decisão de produto
**Convenção de título:** `Fluxo - <nome do processo>`

Use quando o processo **atravessa atores, módulos ou momentos no tempo** — e
por isso não cabe num caso de uso nem numa RN.

## Visão geral
O processo em 3–5 frases, do começo ao fim.

## Diagrama
Sequência em texto ou Mermaid. Mostre os atores e os pontos de decisão.

## Etapas
Uma subseção por etapa: quem age, o que acontece, o que precisa estar
verdadeiro para avançar, e o que acontece se não estiver.

## Estados
Tabela dos estados que a entidade principal assume ao longo do fluxo, e o que
provoca cada transição.

## Regras que governam o fluxo
Links para as RNs. O fluxo mostra a sequência; a RN governa cada decisão.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Implementação da máquina de estados | Página de módulo | `tech-doc-writer` |
| Telas por onde o fluxo passa | Páginas de tela | `screen-doc-writer` |
| Como o usuário executa na prática | Guia de usuário | `user-doc-writer` |
