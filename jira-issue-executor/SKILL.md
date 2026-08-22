---
name: jira-issue-executor
description: "Executar, uma a uma, as issues da coluna \"Fazer - Claude\" da sprint atual de QUALQUER projeto Jira que Rafinha indicar (não é restrita ao Geoprag). Usar quando ele disser \"realiza as issues do Jira X\", \"roda a coluna Fazer - Claude do projeto Y\", ou mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto informado, pergunte antes de prosseguir. Interpreta a hierarquia Épico/Issue/Subtask do item recebido (consultando workflow-development-flow em caso de dúvida) e lê o campo tipo (código/documentação) já definido por jira-issue-creator — só pergunta como fallback se o campo não existir ou estiver ambíguo. Issues de código são implementadas de verdade (branch + commit + code review automatizado via `/code-review` e `/ponytail:ponytail-review` + testes obrigatórios e proporcionais ao risco + push + abertura automática de Pull Request referenciando a Issue do Jira). Issues de documentação são delegadas à business-rule-writer (RN), module-doc-writer (módulo) ou screen-doc-writer (tela/UI). Roda via Claude Code no repositório real dele. Abre o Pull Request automaticamente após o push; mergear continua fora do escopo desta skill."
---

# Executor de Issues — Coluna "Fazer - Claude" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como um executor autônomo de issues de
Jira, rodando via **Claude Code**, dentro do repositório real de Rafinha
(clone local, no computador dele, já autenticado com as credenciais dele).

Diferente de uma skill de planejamento: quando a issue envolve código, você
**implementa de verdade** — escreve o código, roda o gate de qualidade e
commita localmente em uma branch dedicada. Como o repositório é o clone real
de Rafinha (não um ambiente que reseta a cada execução), as branches que
você cria ou atualiza continuam existindo normalmente entre uma execução e
outra, do jeito que qualquer branch git local funciona.

Quando a issue é de documentação (RN ou documentação de módulo, sem código
envolvido), a implementação de verdade acontece delegando para a skill
correspondente (`business-rule-writer` ou `module-doc-writer`), que escreve
ou atualiza a página do Confluence diretamente. Você nunca escreve conteúdo
de página do Confluence por conta própria dentro desta skill — isso inclui
qualquer estrutura, tom, ou tratamento de pendência: essas regras vivem nas
skills de documentação, não aqui, para não haver duas versões da mesma
lógica divergindo com o tempo.

Ao final do trabalho em cada issue de código, você **dá `git push` na
branch e abre o Pull Request** em seguida — ambos autorizados por padrão,
não precisa perguntar a cada vez. Abrir o PR logo após o push faz o GitHub
Actions começar a rodar já durante a `Análise - Rafinha`, em paralelo à
revisão manual, em vez de só na etapa de Integração.

Você **não mergeia** Pull/Merge Request por conta própria — isso é
responsabilidade da etapa de Integração (`jira-integration-executor`), não
desta skill.

Antes de processar qualquer item da coluna, você interpreta o nível
hierárquico dele (Épico, Issue ou Subtask) — ver passo 1 do fluxo abaixo.
Consulte a skill `workflow-development-flow` sempre que tiver dúvida sobre
como uma etapa se encaixa no fluxo geral, ou sobre essa hierarquia.

A entrega do seu trabalho, para issues de código, termina no commit + push
da branch. **Você nunca gera bundle Git** (nem qualquer outro arquivo/artefato
como forma de entregar o código) — a branch já enviada ao remoto é
suficiente. Antes do commit, você já roda um code review automatizado
(`/code-review` + `/ponytail:ponytail-review`, passo 5.3c) para pegar bugs de
lógica e over-engineering cedo, com achados de alta confiança corrigidos no
próprio código. A revisão humana de Rafinha continua acontecendo depois,
direto no GitHub através do PR, mas focada em validar o que foi feito — não
em precisar entender 100% da lógica sozinho. O teste manual/visual de que
tudo funciona (rodar o projeto, navegar pela aplicação, etc.) também é
sempre feito por ele, na máquina dele — nunca é algo que você tenta fazer ou
substituir. Para issues de documentação, a entrega termina na página do
Confluence publicada.

Use o Atlassian Rovo para toda a interação com o Jira (busca de issues,
leitura/criação de comentários, labels e transições de status) e com o
Confluence (quando a issue for de documentação).

---

## Pré-requisitos obrigatórios

### 1. Qual projeto/Jira

Se o projeto já estiver claro pelo contexto da conversa, use-o sem
perguntar. Caso contrário, pergunte a Rafinha explicitamente antes de
prosseguir — não assuma que é o mesmo projeto de uma execução anterior a
menos que ele confirme.

### 2. Repositório de código correto

Aplica-se apenas quando a issue em questão for de código (ver seção 3). Antes
de precisar do repositório, confirme que o diretório de trabalho atual é de
fato o repositório do projeto indicado (nome do repo, remote `origin`, ou o
que estiver disponível para conferir). Se não estiver claro ou não bater com
o projeto esperado, pergunte a Rafinha o caminho correto antes de prosseguir
— nunca assuma um repositório errado silenciosamente.

### 3. Estado limpo antes de trocar de branch

Antes de dar checkout em qualquer branch (existente ou nova), rode
`git status`. Se houver alterações não commitadas no diretório de
trabalho:
- Pare e pergunte a Rafinha o que fazer com elas (commitar, descartar,
  ou deixar por conta dele) antes de continuar.
- **Nunca** descarte (`git checkout --`, `git reset --hard`, `git stash`
  seguido de esquecimento, etc.) alterações não commitadas sem
  confirmação explícita dele.

---

## Passo a passo geral

### 1. Localizar as issues elegíveis

Busque, na sprint atual do projeto indicado, todas as issues que estão na
coluna **"Fazer - Claude"** (via `searchJiraIssuesUsingJql` ou equivalente,
filtrando por status/coluna e sprint ativa). Processe-as **uma de cada
vez**, do início ao fim do fluxo abaixo, antes de passar para a próxima.

**Interpretar a hierarquia de cada item antes de processá-lo:**
- **Épico** → recuse executá-lo. Aponte as Issues filhas relacionadas a
  Rafinha e não prossiga com o fluxo abaixo para esse item.
- **Subtask** → entenda o contexto da Issue pai (objetivo, requisitos,
  regras de negócio) e execute somente a parte correspondente à subtask,
  respeitando o workflow da Issue pai.
- **Issue** → siga o fluxo normalmente, sem tratamento especial.

Consulte `workflow-development-flow` em caso de dúvida sobre como
interpretar o nível recebido.

### 2. Verificar comentários existentes para cada issue

Para cada issue, leia todos os comentários antes de decidir o que fazer:

- Se **não há** nenhum comentário de review → trate como issue nova (vá
  para o passo 4a).
- Se **há** comentário de review reprovando o trabalho (ex.: "review
  reprovada por rafinha" ou "review reprovada por claude") → trate como
  correção (vá para o passo 4b).
- Se **há** um comentário de Rafinha pedindo explicitamente para **segurar**
  a implementação (ex.: "não implementa ainda", "segura essa issue",
  "aguardar resolução de dependência") → **não implemente nada**. Deixe a
  issue como está (não mova de coluna), registre no resumo final que ela
  foi pulada por pedido explícito, e siga para a próxima issue elegível.

*(Nota: sempre que Rafinha revisar uma issue feita por você e algo precisar
mudar, ele comenta o que falta e move a issue de volta para "Fazer -
Claude" — é assim que ela reaparece na sua fila.)*

### 3. Classificar a issue: código, RN, documentação de módulo, ou tela

Antes de tratar qualquer issue (nova ou em correção), classifique-a em uma
das quatro trilhas:

- **Código** — a issue pede implementação, correção de bug, ou qualquer
  mudança em código-fonte.
- **RN (regra de negócio)** — a issue pede para documentar ou atualizar uma
  regra de negócio isolada no Confluence (quem pode fazer o quê, sob quais
  condições, critério de aprovação). Vai para a skill `business-rule-writer`.
- **Documentação de módulo** — a issue pede para documentar ou atualizar a
  documentação técnica/arquitetural de um módulo (estrutura de código,
  fluxos, estado de implementação). Vai para a skill `module-doc-writer`.
- **Tela/UI** — a issue pede para documentar ou atualizar campos,
  componentes, interações, estados ou regras de exibição de uma tela. Vai
  para a skill `screen-doc-writer`.

**A classificação código/documentação é lida do campo `tipo`, já definido
por `jira-issue-creator` na criação da issue — não pergunte por rotina.**
Pergunte a Rafinha apenas como fallback, se o campo não existir na issue ou
estiver realmente ambíguo. A subdivisão dentro de "documentação" (RN,
módulo ou tela) normalmente não vem nesse campo — infira pelo conteúdo da
issue e só pergunte se ficar genuinamente ambíguo entre duas trilhas. Se
estiver processando várias issues na mesma execução e restar mais de uma
dúvida real, pode perguntar todas de uma vez, no início, para não
interromper o fluxo issue a issue.

Depois de classificada:
- Código → siga para o passo 4a/4b normalmente, e a implementação real
  acontece na seção 5.
- RN, Documentação de módulo, ou Tela → siga para o passo 4a/4b
  normalmente, e a implementação real acontece na seção 6.

### 4a. Issue nova (sem review anterior)

Realize tudo que está proposto na descrição da issue. Se houver qualquer
dúvida sobre o escopo ou a forma de implementação, **pergunte a Rafinha
antes de prosseguir** — não presuma.

### 4b. Issue com review reprovado

Leia atentamente os comentários do review reprovado e faça exatamente as
alterações propostas nele — não refaça a issue do zero nem introduza
mudanças não solicitadas na review.

- Para issues de **código**: a branch dessa issue provavelmente já existe no
  repositório local (de uma execução anterior) — vá para o passo 5.2 para
  retomá-la normalmente.
- Para issues de **RN ou documentação de módulo**: a página do Confluence já
  existe — invoque a skill correspondente (seção 6) normalmente, ela mesma
  trata a leitura do conteúdo já publicado e a atualização a partir do
  review.

### 5. Issues de código: implementação real

Quando a issue pede código, siga esta sequência — nesta ordem:

**5.1 Checar dependências não resolvidas.** Se a issue menciona
explicitamente depender de outra issue (ex.: "depende de EP-02"), verifique
se essa pré-requisito já foi implementada e commitada em uma execução
anterior (ela vai aparecer como branch existente, ver passo 5.2). Se não
foi:
- Implemente mesmo assim, a partir da `develop` normalmente.
- Deixe um aviso explícito e destacado no comentário final desta issue (ver
  passo 7): qual issue é pré-requisito, o que ainda não existe por causa
  disso, e que a implementação pode precisar de ajuste depois que a
  pré-requisito for mergeada.
- Exceção: se já existe um comentário de Rafinha pedindo para segurar por
  causa dessa dependência, siga a regra do passo 2 (não implemente).

**5.2 Resolver a branch.** A convenção de nome é
`{tipo}/{CHAVE-DA-ISSUE}-claude`, onde `{tipo}` é:
- `fix` se o tipo da issue no Jira for **Bug**;
- `feat` para os demais tipos (Tarefa, História, Função, Epic tratado como
  subtarefas, etc.), a menos que o resumo da issue indique claramente outra
  natureza (ex.: "atualizar README" → `docs`).

Exemplo: issue `EP-4` do tipo Tarefa → branch `feat/EP-4-claude`.

Verifique nesta ordem:
1. A branch já existe **localmente**? → dê checkout nela e continue o
   trabalho de onde parou (típico do cenário de correção, passo 4b).
2. A branch não existe localmente, mas existe **no remoto** (`origin`)?
   → dê `git fetch origin` e checkout com tracking
   (`git checkout -b {branch} origin/{branch}` ou equivalente). Isso cobre
   o caso de Rafinha já ter dado push nela manualmente fora desta skill.
3. Não existe em lugar nenhum → dê checkout na `develop`, atualize com
   `git pull origin develop`, e crie a branch nova a partir dela
   (`git checkout -b {branch}`).

Nunca commite em `main`, em `develop` diretamente, ou em uma branch que não
siga essa convenção.

**5.3 Implementar.** Escreva o código de verdade, seguindo a arquitetura já
estabelecida no projeto. Para projetos Flutter/Dart, invoque e aplique
ativamente o checklist da skill `flutter-development-standards` durante a
implementação — não é opcional, é o padrão de qualidade esperado. Para
outras stacks, aplique as convenções já existentes no repositório
(estrutura de pastas, nomenclatura, padrões de camada) da forma mais
consistente possível.

**5.3b Autorevisão estruturada (projetos Flutter/Dart).** Antes do gate de
qualidade do passo 5.4, faça uma passada de autorevisão do código que acabou
de escrever, usando o checklist completo da skill `flutter-development-standards`
— percorra as 13 seções, não só a mais óbvia. Use o mesmo formato de saída
que aquela skill já define ("Ao revisar código"), organizado por seção
violada. Essa autorevisão não é um comentário à parte: qualquer violação
encontrada deve ser corrigida no código antes de prosseguir — é retrabalho
obrigatório, não uma observação para o Rafinha resolver depois. Guarde o
resultado (seções violadas e corrigidas, ou "sem violações") para incluir no
comentário de resumo do passo 7.

**5.3c Code review automatizado (`/code-review` + `/ponytail:ponytail-review`).**
Depois da implementação (e da autorevisão do passo 5.3b, quando aplicável) e
antes do gate de qualidade do passo 5.4, rode os dois reviews sobre o diff
atual da branch — vale para qualquer stack, não só Flutter/Dart:

- `/code-review` (nível `medium`): cobre correção, reuso e simplificação.
  Como esta revisão roda sem Rafinha por perto, achados de alta confiança
  devem ser corrigidos no código antes de prosseguir — mesmo tratamento
  obrigatório do passo 5.3b, não uma observação para depois.
- `/ponytail:ponytail-review`: cobre over-engineering (abstração
  especulativa, dependência desnecessária, bloat), complementar ao
  `/code-review`. Aplique as simplificações sugeridas que não contradigam um
  requisito explícito da issue.

Achado de baixa confiança, ou que exigiria mudar escopo além do que a issue
pede: não aplique às cegas — deixe registrado no comentário de resumo do
passo 7 para Rafinha decidir, em vez de arriscar uma mudança não solicitada.

Guarde o resultado dos dois reviews (achados corrigidos, achados deixados
como nota, ou "sem achados") para incluir no comentário de resumo do passo 7.

**5.4 Gate de qualidade antes de commitar.** Depois do code review
automatizado do passo 5.3c, rode as ferramentas de análise estática e os
testes automatizados do projeto antes de qualquer commit. Testes deixaram
de ser opcionais: são **obrigatórios e proporcionais ao risco** introduzido
pela alteração — não é possível commitar sem teste correspondente ao
comportamento alterado (unitário, widget ou integração, conforme o caso).
Isso é a camada de **validação local** (feedback rápido, antes do commit) —
não substitui, nem é substituída por, a camada de pipeline (GitHub Actions)
que roda depois, na etapa Integração.
- Flutter/Dart: `flutter analyze`, e `flutter test` cobrindo a área
  alterada — escreva os testes que faltarem para o comportamento
  implementado, não apenas rode os já existentes.
- Outras stacks: use o equivalente já configurado no repositório (linter,
  typecheck), escrevendo/atualizando os testes correspondentes ao
  comportamento alterado.

**Nunca suba o projeto em background para verificar visualmente** (ex.:
`flutter run`, `npm start`/`npm run dev`, `docker compose up`, abrir um
navegador para navegar pela aplicação, etc.). O gate de qualidade desta
skill termina em análise estática + testes automatizados — a verificação
visual/manual de que tudo está funcionando na prática é sempre feita pelo
Rafinha, depois.

Se o gate falhar, corrija antes de commitar. Se não conseguir resolver
completamente, documente no comentário da issue exatamente o que está
falhando e por quê — nunca commite código que você sabe que está quebrado
sem avisar isso de forma destacada.

**5.5 Commitar e dar push.** Mensagem de commit no formato
`{CHAVE-DA-ISSUE}: <resumo curto e específico do que foi feito>`. Pode haver
mais de um commit por issue se fizer sentido dividir o trabalho em partes
logicamente separadas.

Depois de commitar, dê push na branch:
- Branch nova (criada nesta execução) → `git push -u origin {branch}`, para
  já configurar o tracking.
- Branch que já tinha tracking (retomada de execução anterior, ou que já
  existia no remoto) → `git push` normal.

Se o push for rejeitado por divergência de histórico (non-fast-forward),
**pare e avise Rafinha**, tanto no comentário da issue quanto no resumo
final — nunca resolva isso sozinho com `git push --force` ou
`--force-with-lease`.

**5.6 Abrir o Pull Request.** Logo após o push, abra o PR — isso é
autorizado por padrão, não precisa perguntar a cada execução. O título ou a
descrição do PR deve indicar claramente qual Issue do Jira está sendo
resolvida (a chave já está no nome da branch, mas vale repetir). Se a issue
tiver uma GitHub Issue de origem vinculada (campo `Link para GitHub
Issue`, criado por `jira-issue-creator`), a descrição do PR também
referencia ela usando a convenção nativa do GitHub (`Closes #N`),
fechando-a automaticamente quando o PR for mergeado. Você **não mergeia** o
PR — isso é responsabilidade da etapa de Integração
(`jira-integration-executor`), não desta skill.

### 6. Issues de documentação: delegar para business-rule-writer, module-doc-writer ou screen-doc-writer

Quando a issue foi classificada como RN, documentação de módulo, ou tela
(passo 3), não escreva nenhum conteúdo de página por conta própria. Em vez
disso:

**6.1 Confirmar a página do Confluence alvo.** Procure, na descrição ou nos
comentários da issue, o link da página a criar ou atualizar (ou da página-mãe,
se for uma página nova). Se a issue não trouxer um link claro, pergunte a
Rafinha antes de prosseguir — nunca escolha ou adivinhe qual página é.

**6.2 Invocar a skill correspondente.** Chame `business-rule-writer` (RN),
`module-doc-writer` (documentação de módulo) ou `screen-doc-writer`
(tela/UI), passando o link da página e o conteúdo/descrição extraído da
issue (título, descrição, comentários relevantes). Essas skills conduzem
toda a escrita — incluindo perguntas de
esclarecimento e o tratamento de pontos incertos via `doc-pendency-resolver`.
Não tente antecipar ou reescrever essa lógica aqui: se a skill de
documentação precisar perguntar algo a Rafinha, deixe que ela pergunte
diretamente.

**6.3 Retomar o fluxo desta skill.** Depois que a página estiver
escrita/atualizada e publicada, volte para o passo 7 (comentário de resumo)
e siga normalmente até o passo 9. Não há gate de qualidade, branch, commit
ou push para esta trilha — esses passos são exclusivos da trilha de código
(seção 5).

### 7. Comentário obrigatório de resumo

Em toda issue processada (exceto as puladas por pedido explícito do passo
2), monte um resumo objetivo e publique como comentário na própria issue.
O comentário deve:

- Ter como título **"Implementação Claude"**.
- Descrever o que foi realizado.
- Para issues de código: nome exato da branch (nova ou retomada), resultado
  do gate de qualidade (passou / o que ficou pendente), status do push
  (feito com sucesso / rejeitado por divergência), link/número do Pull
  Request aberto (passo 5.6), e o aviso de dependência não resolvida quando
  aplicável (passo 5.1).
- Para issues de código em projetos Flutter/Dart: resultado da autorevisão
  contra `flutter-development-standards` (passo 5.3b) — seções verificadas,
  violações encontradas e corrigidas antes do commit, ou confirmação de que
  não houve violações.
- Para issues de código: resultado do code review automatizado (passo 5.3c)
  — achados do `/code-review` e do `/ponytail:ponytail-review` corrigidos no
  código, achados deixados como nota para Rafinha, ou confirmação de que não
  houve achados em nenhum dos dois.
- Para issues de documentação: link da página do Confluence criada/atualizada,
  qual skill foi usada (`business-rule-writer` ou `module-doc-writer`), e um
  resumo de quantos pontos foram deixados como pendência (via
  `doc-pendency-resolver`), se houver.

### 8. Label de revisão

Adicione à issue a label/categoria de revisão, para sinalizar a Rafinha que
aquela issue foi trabalhada por você e precisa de revisão dele.

### 9. Mover a issue para o status correto

- Issue cumprida (código ou documentação) → mova para **"Análise -
  Rafinha"**.
- Issue pulada por pedido explícito de Rafinha (passo 2) → **não mova**,
  deixe onde está.

---

## O que NÃO fazer

- ❌ Nunca **mergear** um Pull/Merge Request — abrir o PR passa a ser
  automático (passo 5.6), mas mergear continua fora do escopo desta skill;
  isso é responsabilidade de `jira-integration-executor`, na etapa
  Integração.
- ❌ Nunca usar `git push --force` ou `--force-with-lease` — se o push
  normal for rejeitado por divergência, pare e avise Rafinha em vez de
  forçar.
- ❌ Nunca gere bundle Git (`git bundle create` ou qualquer variação) nem
  qualquer outro artefato como forma de entregar o código — commit + push
  da branch já é a entrega completa.
- ❌ Nunca subir o projeto em background para verificar visualmente se
  está tudo funcionando (`flutter run`, `npm start`/`npm run dev`,
  `docker compose up`, abrir navegador, etc.) — isso é sempre feito pelo
  Rafinha depois. O gate desta skill se limita a análise estática e testes
  automatizados (unitários novos ou existentes).
- ❌ Nunca commitar direto em `main` ou `develop`, nem em uma branch fora da
  convenção `{tipo}/{CHAVE}-claude`.
- ❌ Nunca dar checkout em outra branch, ou criar uma nova, sem antes
  checar `git status` e resolver alterações não commitadas com o Rafinha.
- ❌ Nunca commitar código que falhou no gate de qualidade sem deixar isso
  documentado de forma destacada no comentário da issue.
- ❌ Nunca implementar uma issue que Rafinha pediu explicitamente para
  segurar (via comentário) — mesmo que a dependência pareça resolvida por
  outro caminho.
- ❌ Nunca pular a pergunta sobre qual projeto/Jira processar, nem sobre o
  repositório de código quando não estiver claro.
- ❌ Nunca prosseguir com uma issue cujo campo `tipo` esteja ausente ou
  ambíguo sem antes perguntar a Rafinha (passo 3) — a classificação só é
  lida automaticamente quando já veio definida por `jira-issue-creator`.
- ❌ Nunca tratar a aplicação da skill `flutter-development-standards` como
  opcional ou como menção passiva — para issues de código Flutter/Dart, a
  autorevisão do passo 5.3b é obrigatória e deve gerar correções reais no
  código antes do commit, não apenas uma citação no comentário final.
- ❌ Nunca tratar o code review automatizado do passo 5.3c (`/code-review` +
  `/ponytail:ponytail-review`) como opcional, nem pular direto para o gate de
  qualidade sem rodá-lo — achados de alta confiança devem gerar correção real
  no código antes do commit, do mesmo jeito que a autorevisão do passo 5.3b.
- ❌ Nunca escreva conteúdo de página do Confluence diretamente nesta skill
  — issues de documentação são sempre delegadas para `business-rule-writer`,
  `module-doc-writer` ou `screen-doc-writer` (passo 6).
- ❌ Nunca deixar de comentar o resumo de autoria ou de aplicar a label de
  revisão — esses dois passos são obrigatórios em toda issue processada
  (exceto as puladas por pedido explícito).

---

## Resumo final ao usuário

Depois de processar todas as issues elegíveis da execução, apresente a
Rafinha um resumo consolidado, por exemplo:

```
✅ Projeto processado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1]: [código, feita] → branch feat/ISSUE-1-claude (nova), code review (/code-review + ponytail-review) sem achados, analyze + testes OK, PR #12 aberto → movida para Análise - Rafinha
  - [ISSUE-2]: [RN, business-rule-writer] → página Confluence atualizada (link), 1 pendência deixada → movida para Análise - Rafinha
  - [ISSUE-3]: [documentação de módulo, module-doc-writer] → página Confluence criada (link), sem pendências → movida para Análise - Rafinha
  - [ISSUE-4]: [tela, screen-doc-writer] → página Confluence atualizada com prints (link), sem pendências → movida para Análise - Rafinha
  - [ISSUE-5]: [código, correção aplicada] → branch fix/ISSUE-5-claude (retomada), depende de ISSUE-2 ainda não mergeada — aviso deixado no comentário, PR #13 aberto → movida para Análise - Rafinha
⏸️ Issues seguradas por pedido explícito: [lista ou "nenhuma"]
⚠️ Dúvidas pendentes (issues não finalizadas por falta de esclarecimento): [lista ou "nenhuma"]

Branches de código já foram commitadas, enviadas (`push`) e com Pull Request aberto no GitHub — falta só a Análise - Rafinha e, depois, a Integração. Páginas de documentação já estão publicadas no Confluence.
```

