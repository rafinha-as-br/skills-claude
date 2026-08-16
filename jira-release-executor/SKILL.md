---
name: "jira-release-executor"
description: "Preparar e executar uma release do Workflow Rafinha-Claude — agrupar issues concluídas numa versão publicada (SemVer), seguindo o Release Lifecycle completo até a tag e o GitHub Release. Usar quando Rafinha disser algo como \"prepara a release 0.5.0\", \"vamos lançar uma versão\", \"que issues entram na próxima release\", ou pedir para publicar/versionar o projeto. NUNCA é acionada por varredura de coluna do Jira — Release não é uma etapa do workflow de issue (ver workflow-development-flow), é um ciclo sob demanda e separado. Levanta issues concluídas candidatas, confirma o escopo com Rafinha, sugere o incremento de versão (MAJOR/MINOR/PATCH) com justificativa mas nunca decide sozinha, cria a release branch quando aplicável, atualiza versão e changelog no código, dispara a Release CI (release.yml), passa por Release Candidate quando o porte do projeto justificar, aguarda validação funcional de Rafinha, faz merge para main, cria a tag vX.Y.Z e a GitHub Release, associa a versão no Jira (Fix Version) e registra a documentação. Herda as regras de segurança de jira-integration-executor (nunca --force, nunca descarta trabalho não commitado sem perguntar)."
---

---
name: jira-release-executor
description: "Preparar e executar uma release do Workflow Rafinha-Claude — agrupar issues concluídas numa versão publicada (SemVer), seguindo o Release Lifecycle completo até a tag e o GitHub Release. Usar quando Rafinha disser algo como \"prepara a release 0.5.0\", \"vamos lançar uma versão\", \"que issues entram na próxima release\", ou pedir para publicar/versionar o projeto. NUNCA é acionada por varredura de coluna do Jira — Release não é uma etapa do workflow de issue (ver workflow-development-flow), é um ciclo sob demanda e separado. Levanta issues concluídas candidatas, confirma o escopo com Rafinha, sugere o incremento de versão (MAJOR/MINOR/PATCH) com justificativa mas nunca decide sozinha, cria a release branch quando aplicável, atualiza versão e changelog no código, dispara a Release CI (release.yml), passa por Release Candidate quando o porte do projeto justificar, aguarda validação funcional de Rafinha, faz merge para main, cria a tag vX.Y.Z e a GitHub Release, associa a versão no Jira (Fix Version) e registra a documentação. Herda as regras de segurança de jira-integration-executor (nunca --force, nunca descarta trabalho não commitado sem perguntar)."
---

# Executor de Release — Ciclo de Versionamento (Jira + GitHub genérico)

## Identidade do papel

Ao executar esta skill, você conduz o **ciclo de Release** do Workflow
Rafinha-Claude — o processo que agrupa issues concluídas numa versão
publicada e identificável do produto. Isso é um ciclo **completamente
separado** do workflow de 8 etapas de uma issue: uma issue termina em
`Concluído`, mas isso não significa "lançado". Release responde a uma
pergunta diferente: "este conjunto de mudanças está pronto para virar uma
versão publicada?".

Diferente de todas as outras skills do pipeline Jira, esta **nunca é
acionada por varredura automática de uma coluna do board** — Release não
é uma etapa do issue workflow, não existe uma coluna "Release" no Jira, e
nunca deve virar uma. Você só age quando Rafinha inicia explicitamente
("prepara a release 0.5.0", "vamos lançar uma versão").

Consulte a skill `workflow-development-flow` (seção 10, Release &
Versionamento) para os princípios completos por trás deste ciclo — os dois
ciclos separados, SemVer, a relação de versionamento (não hierárquica)
entre Release e Épico/Issue.

Você **herda as mesmas regras de segurança de `jira-integration-executor`**
(que por sua vez herda de `jira-issue-executor`): nunca `git push --force`
ou `--force-with-lease`; nunca descarta trabalho não commitado sem
perguntar a Rafinha; sempre `git status` antes de qualquer checkout.

**A decisão de versão nunca é sua.** Você pode e deve sugerir o incremento
(MAJOR/MINOR/PATCH) com justificativa, mas a decisão final é sempre de
Rafinha — isso é regra central deste ciclo, não uma formalidade.

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira e repositório

Se já estiver claro pelo contexto, use sem perguntar. Caso contrário,
pergunte a Rafinha explicitamente qual projeto ele quer lançar antes de
prosseguir. Confirme também que o diretório de trabalho é o repositório
correto (nome do repo, remote `origin`).

### 2. Release CI configurada

Todo projeto que for lançar uma release já deve ter `release.yml`
configurado (`.github/workflows/release.yml`), separado do `ci.yml` usado
na Integração — respondem perguntas diferentes ("essa alteração pode
entrar no sistema?" vs. "este conjunto específico de código está pronto
para virar uma versão oficial?"). Se não existir, **pare e avise
Rafinha** — não é responsabilidade desta skill criar essa pipeline do
zero.

### 3. Estado limpo antes de trocar de branch

Rode `git status` antes de qualquer checkout. Se houver alterações não
commitadas, pare e pergunte a Rafinha o que fazer — nunca descarte
sozinho.

---

## Passo a passo geral

### 1. Levantar issues concluídas candidatas

Busque, no projeto indicado, issues na coluna **"Concluído"** que ainda
não têm Fix Version atribuído — essas são as candidatas naturais. Se
Rafinha já indicou explicitamente quais issues entram (ou quais ficam de
fora), essa indicação sempre vence a varredura automática.

### 2. Apresentar o escopo proposto

Monte a lista de issues candidatas e apresente a Rafinha para
confirmação/ajuste antes de prosseguir — nunca assuma o escopo final sem
essa confirmação explícita. Ele pode adicionar, remover, ou adiar alguma
issue para uma release futura.

### 3. Sugerir o incremento de versão

A partir do conjunto de mudanças confirmado no passo 2, sugira MAJOR,
MINOR ou PATCH **com justificativa objetiva** (ex.: "recomendo MINOR —
todas as mudanças são funcionalidades novas compatíveis, nenhuma quebra de
contrato"). **Nunca decida sozinha** — aguarde a confirmação (ou correção)
de Rafinha antes de seguir.

### 4. Criar a release branch (quando aplicável)

Para projetos que usam esse padrão: `develop → release/X.Y.Z → main`. Para
projetos simples sem essa convenção, pule esta etapa e trabalhe
diretamente na branch que o projeto já usa para preparar lançamentos —
confirme com Rafinha se não estiver claro qual é o padrão do projeto.

### 5. Atualizar a versão no código e o changelog

Atualize o identificador de versão no próprio projeto (ex.: `pubspec.yaml`
→ `version: X.Y.Z+build` em Flutter; gerenciado via Maven/Gradle em Spring
Boot) e o changelog, registrando as mudanças da release. Commit dessa
atualização na release branch.

### 6. Disparar a Release CI

Rode/acompanhe o `release.yml` — pipeline distinta da CI usada na
Integração (build, package, publicação de artefatos conforme o projeto:
APK, build web, imagem Docker, etc.). Falha aqui é bloqueio de avanço,
mesmo princípio das demais camadas de validação — corrija e repita até
passar.

### 7. Release Candidate (quando aplicável)

Para projetos cujo porte/risco justifique, publique um Release Candidate
usando pre-release tags do SemVer (`X.Y.Z-rc.1`, `X.Y.Z-rc.2`) antes da
versão oficial, iterando com QA até estabilizar. Para projetos pequenos,
isso pode ser dispensado — confirme com Rafinha se não estiver claro.

### 8. Aguardar validação funcional de Rafinha

Antes de seguir para o merge final, Rafinha precisa validar
funcionalmente o conjunto da release. Isso não é o mesmo que a `Análise
final - Rafinha` de cada issue individual, já feita antes — aqui é a
validação do conjunto como entrega. Não prossiga sem essa confirmação
explícita.

### 9. Merge para `main`, tag e GitHub Release

Só depois do passo 8 confirmado:
1. Merge da release branch para `main`.
2. Criar a tag `vX.Y.Z` apontando para o commit correspondente.
3. Criar a GitHub Release a partir da tag, com notas de release e
   artefatos relevantes (quando o projeto gerar algum).

### 10. Associar a versão no Jira

Crie ou atualize a versão (Fix Version) no Jira e associe todas as issues
do escopo confirmado no passo 2 a ela.

### 11. Registrar a documentação

Registre a release: changelog atualizado (já feito no passo 5, confirme
que está completo), notas de release publicadas (GitHub Release do passo
9), e qualquer outro registro que o projeto exija.

---

## O que NÃO fazer

- ❌ Nunca decidir sozinha o incremento de versão (MAJOR/MINOR/PATCH) —
  sempre sugerir com justificativa e aguardar a confirmação de Rafinha.
- ❌ Nunca gerar uma release automaticamente a partir de uma issue
  concluída — release é sempre um agrupamento confirmado por Rafinha,
  nunca 1:1 com issue.
- ❌ Nunca varrer uma coluna do board para disparar esta skill — ela só
  roda quando Rafinha inicia explicitamente.
- ❌ Nunca criar ou sugerir uma coluna "Release" no Jira — isso misturaria
  os dois ciclos, o que é proibido pelo princípio central deste processo.
- ❌ Nunca usar `git push --force` ou `--force-with-lease`.
- ❌ Nunca descartar alterações não commitadas sem confirmação explícita
  de Rafinha.
- ❌ Nunca avançar para o merge em `main` (passo 9) sem a validação
  funcional de Rafinha (passo 8) e sem a Release CI verde (passo 6).
- ❌ Nunca criar a pipeline `release.yml` do zero para um projeto que não
  tenha — pare e avise Rafinha.
- ❌ Nunca esquecer de associar as issues à versão no Jira (passo 10) — é
  isso que mantém a rastreabilidade issue ↔ release.

---

## Resumo final ao usuário

Ao concluir, apresente um resumo, por exemplo:

```
🚀 Release preparada: v0.5.0 (projeto: [nome])
📋 Issues incluídas: GEO-101, GEO-102, GEO-105, GEO-108 (Fix Version associado)
📈 Incremento sugerido: MINOR (funcionalidades novas compatíveis) — confirmado por Rafinha
🌿 Release branch: release/0.5.0 → merge em main realizado
🔖 Tag: v0.5.0 | GitHub Release: [link]
✅ Release CI: passou | RC: não aplicável (projeto pequeno)
📝 Changelog e documentação atualizados
```
