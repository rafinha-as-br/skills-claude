# AGENTS.md — repositório de skills do Rafinha-Claude

Guia para qualquer agente (Claude Code, Codex ou outro) que leia ou edite as skills deste repositório. Visão geral do sistema: [README.md](README.md).

## O que é este repositório

É a implementação do **Rafinha-Claude**, um workflow de engenharia de software orquestrado por IA, como skills. O board do Jira é o mapa do processo (13 etapas) e cada etapa tem uma skill dona. O agente faz o trabalho operacional; **Rafinha decide** regra de negócio, design, decisão técnica não determinística, aceitação e o modo de cada integração. A autonomia é operacional e supervisionada, nunca total.

Este diretório é o clone de referência: é aqui que as skills são **editadas, commitadas e publicadas**. `~/.claude/skills` e este repositório são a mesma coisa.

## Mapa

Cada pasta na raiz é uma skill. Todas têm `SKILL.md` com `name` (igual ao nome da pasta) e `description`; algumas têm `references/`, `templates/` ou `scripts/`.

| Grupo | Skills |
|---|---|
| **Workflow (24)** | `workflow-development-flow` (skill mãe, só consulta), `workflow-remote-orchestrator`, `jira-*` (uma por etapa do board), `engineering-context-manager`, `ai-memory-manager`, `*-doc-writer`, `doc-pendency-resolver`, `flutter-development-standards`, `workflow-incident-capture-executor` |
| **Fora do workflow (2)** | `task-creator-trabalho`, `flutter-frontend-package-builder` |

Catálogo completo com a função de cada skill: seção *Catálogo de skills* do [README.md](README.md).

## Antes de agir: de onde vem a autoridade

1. O **Confluence** é a norma; o `SKILL.md` demonstra o que está implementado. Diferença entre os dois é *drift*: reconcilie, não mascare.
2. Os contratos vivem em [`workflow-development-flow/references/`](workflow-development-flow/references/). Leia nesta ordem: Contrato do Workflow → Tipo da issue → Políticas ativas → Etapa → Contrato Efetivo (Passo 0, [`contrato-efetivo.md`](workflow-development-flow/references/contrato-efetivo.md)) → escopo da execução.
3. Para saber onde uma issue está, o que vem antes ou depois, ou qual gate vale, consulte [`workflow-development-flow/SKILL.md`](workflow-development-flow/SKILL.md). Ela é só referência: não executa nada.
4. Cada skill do workflow tem um bloco `## Contrato da skill` (o que pode decidir, mutar, atestar e transicionar) seguido da operação técnica. **Leia o contrato antes da operação.** A anatomia está em [`contrato-skills.md`](workflow-development-flow/references/contrato-skills.md).

## Regras que valem para todas as skills do workflow

- **Silêncio não concede autoridade.** Acesso técnico (token, ferramenta, permissão) também não. Se o contrato não cobre a ação, ela não é sua.
- **Informação ausente bloqueia.** Não improvise valor, status, label ou regra. Pergunte a Rafinha.
- **Escopo explícito.** Nunca varra uma coluna inteira do Jira; atue só no que Rafinha indicou.
- **Conflito ou lacuna no contrato** se registra e vai a Rafinha. Nunca decida em silêncio.
- **Nomes que não mudam por executor:** colunas (`Fazer - Claude`…), sufixo `-claude` das branches e títulos de comentário.
- **Nunca** mergear, fazer force push, aplicar `requires-design`, mover issue ou criar exceção fora do que o contrato da skill autoriza.

## Como editar as skills

Classifique a mudança antes de fazê-la:

- **A — contratual** (autoridade, obrigação, limite, evidência, atestação, transição, delegação): precisa aparecer no contrato **e** no comportamento. Peça confirmação a Rafinha.
- **B — operacional** (passo, ferramenta, comando, formato): respeite o contrato; a operação nunca amplia a autoridade da skill.
- **C — compatível:** procedimento que já cumpre o contrato é preservado, não reescrito.

Ao tocar numa skill:

- Texto em português do Brasil; `name` em kebab-case, igual à pasta.
- A `description` começa pelo **gatilho** e fica abaixo de **1024 caracteres**, sem `<` nem `>` (o Codex trunca o índice em cerca de 380 caracteres e o validador dele rejeita o excesso).
- Não copie contratos para dentro das skills; **referencie** (os defaults herdados valem sem repetição).
- Declare o **nível** (0–4) na `## Model Policy`, não um modelo.
- Ao adicionar ou remover uma skill, atualize juntos: o catálogo e a contagem no [README.md](README.md) e a lista de *Escopo* em `contrato-skills.md`.
- Procure referências cruzadas antes de apagar ou renomear qualquer arquivo (`grep` pelo nome em todo o repositório).

## Executores: Claude Code e Codex

Os dois são executores alternativos (Contrato do Workflow, A.10) e **trocar de executor não troca autoridade, escopo, gates nem transições**. A matriz de capacidades e a homologação declarada estão em [`executores.md`](workflow-development-flow/references/executores.md).

- **Claude Code:** executor atual, com todas as capacidades que o workflow usa.
- **Codex:** o texto está adaptado, mas **não está habilitado** e **nenhuma capacidade foi homologada**. Capacidade sem homologação declarada por Rafinha é bloqueio, não fallback.
- Todo registro no Jira inclui `Executor`; abra o *claim* antes da primeira mutação e pare diante de claim vigente de outro executor (B.5).
- `~/.codex/skills` é um clone **somente leitura** (`git pull --ff-only`). Nunca edite lá.

## Skills fora do workflow

Coexistem aqui, mas não fazem parte do pipeline nem de seus contratos. Não as acione de dentro de uma etapa do board, não as cite como capacidade do workflow e não aplique a elas o bloco `## Contrato da skill`.

- `task-creator-trabalho` — tarefas de trabalhos acadêmicos.
- `flutter-frontend-package-builder` — criar ou reconstruir Flutter Frontend Packages. **Só por invocação explícita** (`disable-model-invocation`). É uma edição de arquivo único: as sete referências, os cinco templates e o código do verificador estão embutidos no próprio `SKILL.md`. Mantenha-a assim e não a separe em `references/` ou `scripts/` sem pedido. Para padrões de código Flutter do dia a dia, use `flutter-development-standards`, que é outra skill.

## Git e publicação

- **Commit e push só quando Rafinha pedir**, a cada vez. Inclua sempre a linha `Co-Authored-By` do agente executor na mensagem.
- **Publicar em sistema externo** (Confluence, Jira, Notion) exige "sim" explícito de Rafinha e é feito **página por página**, relendo cada uma antes de atualizar.
- Nunca grave segredos, tokens ou credenciais em arquivos do repositório; registros de ambiente anotam só a *presença* de variáveis.
- O histórico das decisões e das revisões do workflow está no Git (`git log`). Não é preciso manter arquivos de plano na raiz.
- Relate com honestidade o que foi e o que não foi verificado; Rafinha prefere lacunas listadas a afirmações de conclusão.
