# Template — API

**Label:** `api-doc` · **Skill:** `tech-doc-writer`
**Fonte da verdade:** o contrato real da API
**Convenção de título:** `API - <nome do serviço ou recurso>`

## Visão geral
O que esta API expõe e quem a consome.

## Autenticação
Esquema, onde o token viaja, e o que acontece quando ele expira.

## Endpoints
Uma subseção por endpoint:

```
<MÉTODO> /caminho/{param}
```

- **Para que serve** — uma frase.
- **Parâmetros** — tabela: nome · tipo · obrigatório · descrição.
- **Corpo da requisição** — exemplo real, não inventado.
- **Resposta** — exemplo real, com o código de status.
- **Erros** — tabela: status · quando acontece · o que o cliente deve fazer.

## Modelos
Tabela por entidade: campo · tipo · nulo? · observação.

## Versionamento
Como a API versiona, e o que quebra compatibilidade.

## O que NÃO vai nesta página

| Conteúdo | Vai em | Skill |
|---|---|---|
| Regra de negócio que o endpoint aplica | RN | `product-doc-writer` |
| Onde o cliente chama, na tela | Página de tela, modo dev | `screen-doc-writer` |
| Arquitetura interna do serviço | Página de módulo | `tech-doc-writer`, template `modulo.md` |

> Exemplo de requisição e resposta vem de chamada **real**. Payload inventado
> que não bate com o contrato é pior que ausência de exemplo.
