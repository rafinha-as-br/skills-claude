# Template — Módulo

**Label:** `module-doc` · **Skill:** `tech-doc-writer`
**Fonte da verdade:** o código
**Convenção de título:** `Módulo - <nome do módulo> (<app>)` — o app entre
parênteses quando o produto tem mais de um (ex.: `Módulo - Autenticação (App
Aplicador)`, `Módulo - Viagens (RouteCraft)`). É a forma das páginas reais; o
mesmo nome de módulo existe em mais de um app, e sem o parêntese os títulos
colidem.

Estrutura **livre**. As seções abaixo são repertório, não checklist — escolha
as que o módulo precisa e não force seção vazia.

## Objetivo e escopo
*(quase sempre a seção 1)* O que o módulo cobre, o que fica fora, onde ele
vive na árvore **daquele produto**, e se existe um módulo irmão relevante.

## Estrutura de código atual
Tabela: caminho de arquivo · conteúdo · status (`Implementado`, `Implementado
como mock`, `Contrato apenas`).

## Fluxo de telas/passos
Como o processo se comporta na prática, em conjunto. **Quais** telas o módulo
tem e como se encadeiam — não o detalhe de cada uma.

## Modelo de arquitetura/segurança
Camadas, tabelas comparativas, referências a páginas mais profundas.

## Comparações com módulos irmãos
Quando há contraparte que resolve o mesmo problema de outro jeito, tabela
comunica melhor que texto.

## Observações e pontos de atenção
Gaps e inconsistências que atravessam o módulo inteiro. Diferente de nota
pontual numa seção.

## Referências
Sempre a última. Páginas filhas, técnicas relacionadas, contraparte.

## Tom
Documentação **viva**. Aqui é correto narrar estado de implementação, citar
issue que mudou algo, e marcar o que está mockado. Ao contrário da RN.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Rota, cubit, chamadas de API **de uma tela** | Página de tela, modo dev | `screen-doc-writer` |
| Campos e botões de uma tela | Página de tela, modo user | `screen-doc-writer` |
| Motivação de negócio da feature | RN ou requisito | `product-doc-writer` |
| Como o usuário opera | Guia de usuário | `user-doc-writer` |

> O desempate típico: a página de módulo diz **quais cubits existem no
> módulo**; ela não detalha qual cubit gerencia cada tela. Isso é doc de tela.
