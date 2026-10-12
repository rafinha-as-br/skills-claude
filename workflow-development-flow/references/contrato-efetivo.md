# Contrato Efetivo do Ticket

> **Estrutura lógica derivada, não nova fonte normativa.** O Contrato Efetivo é a
> projeção determinística e rastreável de todas as obrigações aplicáveis a uma
> issue no contexto atual. Consolida o que precisa ser cumprido; não cria
> regras, autoridades nem evidências. Composição: `contrato-workflow.md`, Bloco D.
> Espelho: página **Contrato Efetivo do Ticket** no Confluence (CS1).

**Não há engine, arquivo ou campo Jira que materialize o contrato.** A
resolução é um procedimento que a própria skill executa no **Passo 0** da sua
operação, lendo as fontes oficiais. Qualquer cache ou materialização futura não
pode virar fonte de verdade concorrente.

## Fórmula

```text
Contrato do Workflow
+ Tipo de Ticket
+ Políticas aplicáveis
+ Etapa atual
(+ exceções / overrides válidos)
= Contrato Efetivo do Ticket                    → o que a ISSUE exige

Contrato Efetivo do Ticket
+ Contrato da skill responsável
+ Escopo operacional da execução
= capacidade efetivamente autorizada naquela execução
```

O **Contrato da skill não é camada do Contrato Efetivo.** Um dado de uma
obrigação existir na issue não autoriza qualquer skill a executá-la.

## Passo 0 — procedimento de resolução (executado por toda skill do fluxo)

1. Identificar a issue e ler seu estado oficial no Jira (chave, **tipo nativo**,
   Epic, coluna atual, labels oficiais, descrição, comentários estruturados).
2. Aplicar o Contrato do Workflow (`contrato-workflow.md`).
3. Resolver o Tipo de Ticket (SKILL.md §3; tipo ausente/incompatível → Gate 2).
4. Identificar condições e labels com **efeito de Política** (`politicas.md`);
   labels classificatórias não viram política.
5. Ativar **só** as políticas cuja condição esteja comprovada em fonte oficial.
   Topologia (mono/multi-repo) vem do campo **Topologia** da página de Controle
   de workflow do produto (Confluence).
6. Identificar a Etapa atual (SKILL.md §4–5, §5.13–5.14).
7. Carregar as obrigações correspondentes (tipo + políticas + etapa).
8. Deduplicar obrigações equivalentes preservando proveniência.
9. Aplicar modificações **explicitamente declaradas**.
10. Detectar conflitos (sem precedência implícita; conflito → Rafinha, bloqueia a
    parte dependente).
11. Incorporar exceções/overrides válidos (origem, escopo, motivo, vigência).
12. Determinar o estado de satisfação possível de cada obrigação (Bloco C).
13. Expor gates, autoridades, evidências e condições de continuidade.

Resolução depende de informação não encontrada na fonte oficial → B.3
(bloqueia, não infere, registra incidente).

**Resolução barata.** Para a maioria das execuções, o Passo 0 se resume a ler a
issue e confirmar tipo, labels com efeito de política, etapa e escopo; os
contratos de Workflow, Tipo, Política e Etapa são lidos de `references/` e do
SKILL.md mãe, não reconstruídos de memória.

## O que a visão resolvida expõe

- **Contratos ativos** (e por que cada um está ativo).
- **Obrigações efetivas:** identidade lógica, descrição, origem, contratos que
  também a exigem, modificações sofridas, condição de aplicabilidade,
  autoridade responsável, evidência necessária, gate relacionado, estado de
  satisfação, eventos que a invalidam, exceção relacionada.
- **Gates e condições de continuidade** (condição, obrigação que sustenta, quem
  valida, evidência, estado atual). Estar na coluna não significa gate satisfeito.
- **Políticas ativas** (condição que ativou; obrigações adicionadas/modificadas).
- **Autoridades aplicáveis** (decisão, mutação, atestação, transição, exceção,
  humana obrigatória, evidência). O Contrato Efetivo não cria autoridade nova.
- **Evidências e registros** (permanecem nas fontes primárias; Jira rastreia).
- **Estados de satisfação** e **exceções/overrides válidos** (obrigação,
  origem, escopo, motivo, vigência, efeito). `Excepcionada` nunca vira
  `Satisfeita` em silêncio.

## Resolução de topologia

A topologia entra pelo **Contrato de Política** (`politicas.md`, "Topologia").
O contrato resolve deterministicamente: mono ou multi-repo; onde está `context/`
e `ai-memory/`; se existe Workspace; regras de gitlink/composição; como branches
e Design Package são interpretados. Mutação de AI Memory é sempre da
`ai-memory-manager`; as demais skills leem direto e delegam persistência.

## Resolução de Hotfix e fast-track

Com `Tipo = Hotfix`, o Contrato Efetivo incorpora o **fast-track autorizado** da
descrição da issue. Obrigações anteriores à criação direta em `Fazer - Claude`
**não desaparecem** só porque colunas foram puladas; cada uma é resolvida como
`Satisfeita`, `Não aplicável`, `Excepcionada` ou outro estado do Bloco C
(Pendente / Não verificável). Consequências determinísticas com contrato válido:

| Consequência | Valor |
|---|---|
| Destino inicial da issue | `Fazer - Claude` |
| Branch | `hotfix/<ISSUE-KEY>` |
| Base / destino final | `develop` / `develop` |
| Modo de integração | **Modo C**, sem pedir a Rafinha |
| Branch de Epic | não participa |
| Multi-repo | `workspace/hotfix/<ISSUE-KEY>` na composição temporária |
| Transição entre colunas | exclusivamente de **Rafinha** |

A **próxima coluna** de uma Hotfix nunca é resolvida pelo Contrato Efetivo.

## Escopo operacional da execução

O contrato pertence à issue; cada execução ocorre num **escopo fechado**. Uma
obrigação aplicável à issue não autoriza mutação fora do escopo da execução.

## Recomputação

Recomputar quando houver mudança relevante: etapa, tipo, política ativada/
desativada, label com efeito contratual, condição de aplicabilidade, exceção
aplicada/expirada/revogada, conflito resolvido. A recomputação preserva o
histórico e não dá retroatividade automática.

## Consumo pelas skills

- **Contrato Efetivo** → o que a issue exige.
- **Contrato da skill** → o que ela pode decidir, mutar, atestar, transicionar.
- **Escopo operacional** → sobre quais alvos, nesta execução.

A skill carrega no `SKILL.md` só as autoridades/obrigações/limites **locais** e as
verificações para consumir as camadas compartilhadas; não copia nem redefine o
Contrato do Workflow, a taxonomia de tipos, as políticas ou as etapas.

## Relação com as fontes oficiais

O Contrato Efetivo não substitui: Jira (estado/histórico), Confluence (norma),
Git/GitHub (versionamento/integração), Código (estado técnico), AIO Tests
(registro de QA), `SKILL.md` (comportamento real).
