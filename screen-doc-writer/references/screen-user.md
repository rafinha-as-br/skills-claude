# Template — Tela, modo usuário

**Label:** `screen-doc` · **Modo:** `screen-doc:user` · **Skill:** `screen-doc-writer`
**Fonte da verdade:** a tela rodando
**Convenção de título:** `Tela - <nome>`
**Público:** quem usa o sistema, não quem o constrói.

## Para que serve esta tela
Duas ou três frases, na linguagem de quem usa. Sem nome de classe, sem rota.

## Como chegar aqui
O caminho pelo menu ou pela tela anterior.

## Campos
Tabela: campo · o que preencher · obrigatório · observação. Use o rótulo que
aparece na tela, exatamente como está escrito.

## Botões e ações
O que cada um faz, e para onde leva.

## Mensagens
As que o usuário vê: confirmação, aviso, erro. Texto real, não paráfrase.

## Erros visíveis
O que pode dar errado nesta tela, como aparece, e o que fazer.

## Fluxo esperado
A sequência normal, do jeito que a pessoa vai seguir.

## Tom
Direto e sem jargão técnico. Se a frase só faz sentido para quem conhece o
código, ela está no template errado.

## O que NÃO vai em NENHUMA página de tela

| Conteúdo | Vai em | Skill |
|---|---|---|
| Arquitetura do módulo, camadas, quais cubits o módulo tem | Página de módulo | `tech-doc-writer` |
| Regra de negócio que a tela aplica | RN | `product-doc-writer` |
| Tarefa que atravessa mais de uma tela | Guia de usuário | `user-doc-writer` |

> **A fonte da verdade desta skill é a UI rodando.** O que você não consegue
> confirmar navegando a tela de verdade, ou não pertence aqui, ou passa pelo
> `doc-pendency-resolver` antes de virar texto.
