# Template — Tela, modo dev

**Label:** `screen-doc` · **Modo:** `screen-doc:dev` · **Skill:** `screen-doc-writer`
**Fonte da verdade:** a tela rodando **mais o código dela**
**Convenção de título:** `Tela - <nome> (dev)`
**Público:** quem vai mexer nesta tela.

## Rota
O caminho registrado e os parâmetros que ela recebe.

## Estado
Qual cubit/bloc/provider **desta tela**, os estados possíveis, e o que provoca
cada transição.

## Permissões
Quem pode abrir, e o que acontece com quem não pode.

## Chamadas de API
Tabela: quando · método e caminho · o que faz com a resposta · o que faz no
erro. Link para a página de API quando existir.

## Componentes usados
IDs canônicos dos componentes reutilizáveis. Divergência entre o ID citado no
design e o que existe no código é **achado a reportar**, não componente a
criar.

## Regras de exibição
O que aparece condicionalmente, e sob que condição.

## Validações
Por campo: regra, quando dispara, mensagem exibida.

## Dependências técnicas
O que precisa estar de pé para a tela funcionar.

## O que NÃO vai em NENHUMA página de tela

| Conteúdo | Vai em | Skill |
|---|---|---|
| Arquitetura do módulo, camadas, quais cubits o módulo tem | Página de módulo | `tech-doc-writer` |
| Regra de negócio que a tela aplica | RN | `product-doc-writer` |
| Tarefa que atravessa mais de uma tela | Guia de usuário | `user-doc-writer` |

> **A fonte da verdade desta skill é a UI rodando.** O que você não consegue
> confirmar navegando a tela de verdade, ou não pertence aqui, ou passa pelo
> `doc-pendency-resolver` antes de virar texto.
