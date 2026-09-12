# Runtime Package

Copie esta pasta para `.release/runtime/` no projeto.

O Runtime Package é **como a versão distribuída é executada fora do ambiente de
desenvolvimento**. Ele viaja dentro do ZIP da distribuição, junto dos artefatos.

## O contrato, inteiro

Um entrypoint oficial que inicia a versão distribuída:

```text
runtime/
└── start
```

É só isso. O nome do entrypoint é declarado no manifesto
(`runtime_package.entrypoint`) e **a implementação é livre**.

O workflow **não impõe** Docker, PostgreSQL, Flutter, nem nenhuma outra
tecnologia. Estratégias igualmente válidas:

```text
runtime/start → docker compose up
runtime/start → sobe servidor HTTP local + API + banco
runtime/start → executa aplicação desktop
runtime/start → instala o APK via adb num dispositivo conectado
```

Quem decide é o projeto, e a decisão fica documentada na página **Runtime
Package** do Confluence dele.

## Declarar é obrigatório

No `.release/project.yml`:

```yaml
runtime_package:
  required: true
  entrypoint: runtime/start
  source: .release/runtime
```

| `required` | Consequência |
| --- | --- |
| `true` | Release **completa** sem Runtime Package funcional é **bloqueio** |
| `false` | Exige, no Confluence, a **justificativa** e **como a versão distribuída é executada sem ele** |

> ⚠️ Ausência silenciosa nunca é permitida. `required: false` sem a página
> correspondente é falha de setup, não omissão tolerada.

## Compatibilidade com a versão

O Runtime Package **não tem versão própria** — ele é parte da distribuição
daquela release. O `release-manifest.yml` registra de qual runtime o ZIP saiu:

- **monorepo** — o commit do `.release/runtime/`;
- **multi-repo** — o checksum do conteúdo, já que a pasta mãe não é Git.

Isso é o que impede uma distribuição `1.0.0` de usar acidentalmente scripts de
runtime de uma versão incompatível.

## O que o entrypoint deveria fazer

Não é regra, é o que costuma evitar suporte depois:

- **Falhar cedo e com mensagem clara** quando faltar um pré-requisito (porta
  ocupada, Docker não instalado, variável não definida). Quem vai rodar isso
  pode não ser você.
- **Dizer o que subiu e onde** — "Web em http://localhost:8080, API em :8081".
- **Ser idempotente** — rodar duas vezes não deve deixar o ambiente pior.
- **Não depender de caminho absoluto** da máquina de quem empacotou.

## Exemplos nesta pasta

- `start.example.ps1` — esqueleto comentado, com verificação de pré-requisitos
  e mensagem final de onde o sistema está rodando.

Apague os exemplos depois de escrever o seu.
