# Template — Tela, modo híbrido

**Label:** `screen-doc` · **Modo:** `screen-doc:hybrid` · **Skill:** `screen-doc-writer`
**Fonte da verdade:** a tela rodando, mais o código
**Convenção de título:** `Tela - <nome>`

Use quando a tela **não justifica duas páginas separadas** — tela interna,
simples, ou de público único que é ao mesmo tempo quem opera e quem mantém.

> **Na dúvida entre híbrido e separado:** híbrido. Duas páginas que ninguém
> mantém são piores que uma página que serve a dois leitores. Separar depois
> é barato; reconciliar duas páginas divergentes não é.

## Para que serve esta tela
Linguagem de quem usa. Duas ou três frases.

## Como chegar aqui
Caminho pelo menu, e a rota entre parênteses.

## Campos
Tabela: campo · o que preencher · obrigatório · **validação** · observação.
A coluna de validação é o que funde os dois públicos numa tabela só.

## Botões e ações
O que cada um faz, para onde leva, e — entre parênteses — o que dispara no
código quando não for óbvio.

## Mensagens e erros
Texto real exibido, mais a condição técnica que o produz.

## Detalhes técnicos
Bloco único no fim: estado, permissões, chamadas de API, componentes usados,
dependências. Separado do resto para quem só quer usar a tela poder parar
antes.

## O que NÃO vai em NENHUMA página de tela

| Conteúdo | Vai em | Skill |
|---|---|---|
| Arquitetura do módulo, camadas, quais cubits o módulo tem | Página de módulo | `tech-doc-writer` |
| Regra de negócio que a tela aplica | RN | `product-doc-writer` |
| Tarefa que atravessa mais de uma tela | Guia de usuário | `user-doc-writer` |

> **A fonte da verdade desta skill é a UI rodando.** O que você não consegue
> confirmar navegando a tela de verdade, ou não pertence aqui, ou passa pelo
> `doc-pendency-resolver` antes de virar texto.
