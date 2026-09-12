# Release Orchestrator

Copie esta pasta para `.release/scripts/` no projeto.

O Orchestrator é o mecanismo **determinístico local** que produz uma
distribuição do projeto. Roda em **todo projeto** — monorepo e multi-repo.

```powershell
.\orchestrate.ps1 -Request ..\requests\2026-09-12-final.yml
```

## O que ele faz

```text
1. validar o manifesto (schema, ciclos em depends_on, repositórios declarados)
2. conferir o escopo efetivo do request contra a resolução de dependências
3. validar o estado local dos repositórios (existe, limpo, no commit esperado)
4. disparar as Release Actions necessárias
5. aguardar os resultados
6. coletar os artefatos publicados
7. montar artifacts/<componente>/
8. incluir o Runtime Package
9. gerar release-manifest.yml + copiar o release-request.yml
10. gerar o ZIP, nomeado com a versão do produto
```

## O que ele nunca faz

Ler o Jira para decidir · decidir versão · decidir escopo de negócio · inventar
dependência · escolher MAJOR/MINOR/PATCH · aprovar produto · executar análise
humana · substituir a skill.

> **Ele dispara, mas não decide.** Recebe um Release Request já fechado — tipo,
> escopo, versões e commits decididos por Rafinha antes. Toda decisão de negócio
> aconteceu antes dele.

## Antes de rodar de verdade

```powershell
.\orchestrate.ps1 -Request ..\requests\2026-09-12-final.yml -Validate
```

`-Validate` executa só os passos 1–3 e sai. Não dispara nada, não baixa nada,
não toca na rede. É a checagem que falha se o manifesto tiver ciclo, componente
órfão, repositório sujo ou escopo efetivo inconsistente com as dependências
declaradas.

**Rode isso sempre que mexer no `project.yml`.**

## Outros modos

| Flag | Para quê |
| --- | --- |
| `-SkipDispatch` | As Actions já rodaram (você disparou pela aba Actions, ou está remontando o ZIP). Pula direto para a coleta |
| `-KeepStaging` | Não apaga `dist/` antes de montar |

## De onde vêm os artefatos

Depende do tipo, e isso é consequência direta da regra de quando se cria GitHub
Release:

| Situação | Origem do artefato |
| --- | --- |
| `FINAL` | GitHub Release do componente (`gh release download`) |
| `PRE_RELEASE` | Artefato da execução (`gh run download`) — não existe Release |
| `carried` | Sempre de uma versão **já publicada** |

> ⚠️ **Componente `carried` sem versão publicada bloqueia a release.** O script
> para com mensagem explícita. Nunca fabrique a dependência nem aponte para
> código local não publicado: publique aquela versão antes, ou inclua o
> componente no `version_scope`.

Um efeito prático de artefato de pre-release ser efêmero: se o artefato da
execução expirou, o rc não pode mais ser remontado a partir do GitHub. Quem
guarda um rc a longo prazo é o **ZIP no Drive**.

## Dependências

- `gh` CLI autenticado
- `git`
- módulo `powershell-yaml`:

```powershell
Install-Module powershell-yaml -Scope CurrentUser
```

O módulo existe porque o Windows PowerShell 5.1 não tem `ConvertFrom-Yaml`
nativo. Escrever um parser de YAML aqui seria pior que a dependência — se o
módulo virar problema, a saída é migrar manifesto e request para JSON, não
escrever o parser.

## O que adaptar

Quase nada: o script é dirigido pelo `.release/project.yml`, então componentes,
repositórios, dependências e runtime saem de lá. Os pontos que podem precisar de
ajuste num projeto específico:

- o nome do workflow, se não for `release.yml`;
- como um artefato precisa ser pós-processado antes de entrar no pacote
  (descompactar, renomear, reorganizar) — hoje o script copia como veio;
- a estratégia de espera, se algum repositório tiver build muito longo.

## Depois que o ZIP existe

O script não faz, e não deve fazer:

1. Rafinha executa a distribuição **fora da IDE** e valida.
2. O ZIP vai para o Drive.
3. O conteúdo do `release-manifest.yml` é registrado no Confluence.
4. Se era pre-release e foi aprovada, ela é promovida para FINAL.
