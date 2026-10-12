# Contrato de Política

> **Regras condicionais** ativadas quando uma condição verificável está presente.
> Uma política *adiciona, modifica, restringe ou especializa* obrigações; ela não
> define a natureza do trabalho (Tipo) nem substitui o Contrato do Workflow.
> Espelho: página **Contrato de Política** no Confluence (CS1). A lista completa
> de labels, com significado, continua na página **Vocabulário operacional de
> labels** (CS1).

## Regra central

**Nem toda label é política.** Uma label ativa política só se sua presença tem
**efeito contratual explícito**: altera estratégia de execução, adiciona
obrigação, modifica gate, seleciona executor, exige evidência adicional, altera
rota operacional, introduz restrição ou altera critérios de validação/revisão.
Labels classificatórias/contextuais não criam comportamento por si, e a
existência de uma label não autoriza a skill a inferir política não documentada.

## Estrutura de uma política

Condição/identificador de ativação · finalidade · contexto · obrigações
adicionadas · obrigações modificadas · gates ativados/alterados · evidências
adicionais · skills/etapas afetadas · condições de desativação · efeitos
persistentes · interações com outras políticas. Determinística: mesma condição e
contexto → mesmo conjunto de obrigações.

## Ativação

Só participa do Contrato Efetivo quando a condição é verificável em fonte oficial
(labels oficiais, estado da issue, contexto do produto, decisão humana
registrada, resultado de etapa anterior, regra de outro contrato). Ativação não
verificável → `contrato-workflow.md` B.3 (bloqueia).

## Famílias

| Família | Labels / condição | Efeito contratual |
|---|---|---|
| **Plataforma** | `web` · `mobile` · `desktop` · `android` · `ios` · `api-only` | Selecionam o **executor** de QA. Ausente/ambígua quando necessária → Gate 4 |
| **Protocolo de QA** | `functional-qa` · `visual-qa` · `regression-qa` · `e2e-qa` · `smoke-qa` · `manual-qa` · `maestro` | Selecionam a **estratégia** dentro do executor; combinam quando compatíveis |
| **Design** | `requires-design` | Ativa dependência de Design Package, Gate de Design antes da implementação, registro de uso do pacote; permanece como marcador histórico. **Só Rafinha confirma.** `ui` e `correcao-ui` não ativam. Especialização para Hotfix abaixo |
| **Validação Humana** | `validacao-humana` (ativação/roteamento da trilha); `validacao-reprovada` e `validacao-bloqueada` (**estado** do ciclo, não política); `acceptance-check`, `visual-check`, `business-flow-check`, `copy-check`, `usability-check` (especializam o foco dos cenários, só dentro da Validação Humana) | Preservar a distinção: nem toda label da família é política |
| **Risco e controle** | `high-risk` · `breaking-change` · `legacy` · `needs-human-review` · `do-not-expand-scope` · `needs-evidence` · `intermittent` · `reproducible` · `regression` | Adicionam contexto de risco/controle/revisão/evidência para as skills do vocabulário. Ex.: `high-risk` e `breaking-change` → executor, review, release; `needs-evidence` torna a evidência obrigatória; `needs-human-review` reforça revisão humana; `intermittent`/`reproducible`/`regression` alteram o contexto de QA/review |
| **Documentação** | `rn-doc` · `module-doc` · `screen-doc` · `component-doc` · `api-doc` · `architecture-doc` · `user-doc` · `workflow-doc` · `skill-doc` · `release-doc` · `readme` · `adr` · `confluence` · `qa-doc` | Roteiam a trilha e selecionam o writer (tabela em SKILL.md §3.3). Tipo Documentação sem trilha → Gate 3. `qa-doc` é válida mas sem writer: única trilha → bloqueia |
| **Estado operacional de integração** | `integrado-epico` · `qa-develop-aprovado` | **Estado**, não política: fatos do ciclo de integração/QA (SKILL.md §16.4) |
| **Topologia do produto** | mono-repo / multi-repo, lida do campo **Topologia** do produto | Ver abaixo |
| **Fast-track de Hotfix** | `Tipo = Hotfix` com fast-track autorizado | Ver abaixo |

**Não são política por existirem:** área técnica, natureza do defeito,
refatoração técnica, produto/módulo/feature (fonte própria: página de Controle
de workflow do produto). Só ganham efeito quando um contrato o declara.

**Pendências herdadas (não resolvidas por esta atualização):** `qa-doc` sem
writer; `design-system` sem classificação definitiva (label de produto vs. trilha
`component-doc`). Não autorizam fallback nem inferência.

## Política de topologia

Mono-repo e multi-repo são **Política**, não camada separada.

**Mono-repo:** `context/` e `ai-memory/` dentro do próprio repositório; sem
Workspace; composição Git direta; regras de branch no próprio repositório.

**Multi-repo:** ativa o Workspace Git superior; Git Submodules e gitlinks;
`context/` transversal e `ai-memory/` no Workspace; branches `workspace/develop`,
`workspace/epic/<EPIC-KEY>`, `workspace/issue/<ISSUE-KEY>`,
`workspace/hotfix/<ISSUE-KEY>`; preparação determinística de branches de Epic;
regras de composição e avanço de gitlinks; Design Package nos **repositórios
afetados** (nunca no Workspace); exceção temporária de composição para Hotfix;
integração final da composição em `workspace/develop`.
Detalhes: `contexto-memoria-workspace.md`.

**Autoridade de composição (multi-repo).** A `jira-integration-executor` é a
capacidade responsável pela **composição Git do Workspace produzida por uma
integração**: integrar as branches nos repositórios componentes, obter os
commits realmente integrados, atualizar gitlinks na branch correta do Workspace,
criar commits de composição, promover a branch de composição quando aplicável e
validar que `workspace/develop` representa a composição efetivamente integrada.
Fora desta autoridade: bootstrap inicial do Workspace (Rafinha), preparação de
branches de Epic (`jira-technical-preparation-executor`), `context/`
(`engineering-context-manager`), AI Memory (`ai-memory-manager`) e mudanças de
composição fora de integração autorizada.

A política de topologia especializa apenas o que depende da arquitetura do
produto; não duplica regras universais de Tipo, Etapa ou Workflow.

## Fast-track de Hotfix como modificação contratual

O fast-track autorizado por Rafinha **modifica** obrigações sem apagá-las. Cada
obrigação dispensada é `Não aplicável` (não faz sentido) ou `Excepcionada`
(normalmente aplicaria, mas há autorização válida de dispensa). A autorização
identifica obrigação, motivo e contexto no ticket. O fast-track não autoriza a
skill a inventar exceções nem a dispensar requisitos mínimos de segurança e
validação. **`requires-design` em Hotfix:** `Não aplicável` quando design não faz
sentido; `Excepcionada` quando Rafinha autoriza a dispensa emergencial; ausência
de Design Package não bloqueia quando a dispensa é válida e não compromete a
implementação e validação seguras. Isso não enfraquece a política global.
`Excepcionada` nunca é convertida em `Satisfeita`.

## Interação entre políticas

Composição **aditiva** por padrão; políticas compatíveis acumulam obrigações. Só
modifica/substitui obrigação existente quando a relação é declarada. Obrigações
incompatíveis sem regra explícita → conflito contratual → Rafinha decide.
