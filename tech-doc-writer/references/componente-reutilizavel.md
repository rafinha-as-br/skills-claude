# Template — Componente reutilizável

**Label:** `component-doc` · **Skill:** `tech-doc-writer`
**Fonte da verdade:** o código do componente
**Convenção de título:** `Componente - <nome>`

Cada componente é uma entrada no catálogo do produto. O **ID canônico** é a
ponte entre o Claude Design e o Claude Code — ele é o campo mais importante
desta página.

## ID canônico
```
<sigla>.<tipo>.<subtipo>        ex.: gp.button.primary
<sigla>.candidate.<nome>        componente ainda não oficial
```
A **sigla** vem da página de *Controle de workflow* daquele produto, e é
definida manualmente — nunca inferida do nome do produto ou do repositório.

## Nome e finalidade
Como o componente é chamado no código, e o problema que ele resolve.

## Caminho no código
Arquivo e, quando houver, o barrel/export por onde se importa.

## Propriedades
Tabela: nome · tipo · obrigatório · padrão · efeito.

## Variações
As variantes previstas e quando usar cada uma.

## Estados
Normal, hover, foco, desabilitado, carregando, erro — os que existirem.

## Regras de uso
Quando usar. Composição esperada com outros componentes.

## Quando NÃO usar
A seção que mais evita retrabalho. Casos em que outro componente é o certo.

## Exemplos
Trecho de código real de uso, curto.

## Relação com o Design System
O que existe no Claude Design sob o mesmo ID, e divergências conhecidas.

## Prints
Quando o componente for visual. Ver a rotina de anexo de prints.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Como uma tela específica usa o componente | Página de tela | `screen-doc-writer` |
| Arquitetura do Design System inteiro | Arquitetura | `tech-doc-writer`, template `arquitetura-dev.md` |

> Se o ID citado num Design Package não existe no código nem aqui, isso é
> **divergência a reportar**, nunca componente a recriar (gate 7).
