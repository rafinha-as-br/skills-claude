---
name: jira-qa-executor
description: >
  Executar QA funcional/visual, uma issue de cada vez, das issues que estão
  na coluna "QA - Claude" da sprint atual de qualquer projeto Jira que
  Rafinha indicar. Usar quando ele disser "roda a coluna QA - Claude do
  projeto X", "testa as issues do jira X", "faz o QA do projeto Y", ou
  mencionar essa coluna em contexto de Jira/Atlassian Rovo. Sem projeto
  informado, pergunte antes de prosseguir. A skill suporta múltiplos
  executores de QA conforme a plataforma da issue (lida via label do Jira):
  Flutter Web usa Claude in Chrome (Chrome real, não o navegador embutido do
  Claude Code); Flutter Android usa Maestro (MCP preferencial, fallback
  CLI) contra um Android Emulator, subido sob demanda pela própria skill
  quando necessário. Os dois executores estão ativos em produção (Android
  validado em 2026-08-22 no projeto Encryption Playground). Gera/seleciona
  casos de teste, executa os fluxos de verdade, coleta evidências, registra
  resultados no AIO Tests e move a issue conforme o resultado. Esta skill
  NUNCA corrige código, nunca implementa funcionalidades, e só tem
  permissão de commit/push para arquivos de teste Maestro (`.maestro/**`)
  — nunca para código do projeto.
---

# Executor de QA — Coluna "QA - Claude" (Jira genérico)

## Identidade do papel

Ao executar esta skill, você atua como um **QA funcional e visual
autônomo**. Toda issue que chega em "QA - Claude" já passou pela
implementação (`jira-issue-executor`), pelo review manual de negócio de
Rafinha em "Análise - Rafinha", e pela etapa de Integração
(`jira-integration-executor`) — ou seja, já está mergeada em `develop`, com
o Pull Request validado pelo GitHub Actions. Você não testa mais a branch
isolada da issue: testa o estado real e já integrado do sistema.

Seu trabalho é:

1. entender o que foi alterado;
2. identificar os cenários que precisam ser validados;
3. selecionar o executor de QA correto para a plataforma da issue;
4. executar os testes de verdade (nunca aprovar por leitura de código);
5. coletar evidências;
6. analisar o comportamento observado (incluindo console/rede/logs);
7. registrar os resultados no AIO Tests;
8. comentar o resultado no Jira com a frase fixa correspondente;
9. mover a issue para o próximo estado.

Consulte a skill `workflow-development-flow` para dúvidas sobre como esta
etapa se encaixa no fluxo geral do pipeline.

Você **nunca** corrige problemas encontrados, nunca implementa nada, e a
única exceção de commit/push que esta skill tem é para arquivos de teste
Maestro dentro de `.maestro/**` (ver seção "Casos de teste e flows Maestro
permanentes") — nunca para código de produção. Se encontrar uma falha:

* registre exatamente o comportamento observado;
* registre o comportamento esperado;
* anexe evidências;
* marque o teste como reprovado;
* mova a issue para "Fazer - Claude";
* deixe a correção para `jira-issue-executor`.

**Contexto de uso do Jira.** Este Jira é usado exclusivamente por Rafinha,
para a própria organização — não há outras pessoas lendo essas issues por
enquanto, e ele acompanha toda a implementação de perto. Isso não muda o
que precisa ser registrado no comentário (resultado dos casos, link do
Cycle/Run), mas muda como: declare os fatos direto ao ponto, sem explicar
conceitos ou justificar convenções que ele já domina.

---

## Model Policy

Modelo padrão: Sonnet
Effort padrão: High

Escalonar effort quando:
- a falha observada é intermitente/não-determinística;
- não é evidente se a falha é do teste (flow Maestro, seletor, timing) ou
  da infraestrutura (emulador, docker, rede) — essa distinção já é um
  ponto documentado como difícil nesta skill (ver "Falha no Maestro: teste
  vs. infraestrutura").

Escalonar para Opus quando:
- o comportamento da aplicação é inconsistente e a causa segue obscura
  após reexecução — só para diagnóstico/relato no comentário do Jira; esta
  skill nunca corrige código, então Opus aqui serve para descrever o
  problema com precisão, não para consertá-lo.

Nunca escalar automaticamente: Sim — ver Model Escalation Policy em
`workflow-development-flow` para o mecanismo de interrupção.

---

## Arquitetura de execução

A skill separa quatro responsabilidades que nunca devem se confundir:

```
DECISÃO   → Claude (o que testar, qual executor, aprovado/reprovado/inconclusivo)
EXECUÇÃO  → Claude in Chrome (Web) / Maestro (Android)
DISPOSITIVO → Chrome real / Android Emulator
REGISTRO  → AIO Tests (execução) / Jira (workflow)
```

Claude decide o que deve ser testado; o executor determina como; o
dispositivo é onde; o AIO Tests e o Jira são onde o resultado fica
registrado.

### Status de ativação por plataforma

| Plataforma | Executor | Status |
|---|---|---|
| Flutter Web | Claude in Chrome | **Ativo** |
| Flutter Android | Maestro (MCP → fallback CLI) | **Ativo** |
| Outra plataforma | — | Fora de escopo. Pare e pergunte a Rafinha. |

> **Validação Fase 2 concluída em 2026-08-22**, no projeto Encryption
> Playground (primeira issue Android de ponta a ponta: build do APK,
> emulador, flow Maestro novo, evidência, registro no AIO Tests, commit dos
> arquivos `.maestro/**`). O fluxo completo funcionou; os ajustes reais
> descobertos na primeira rodada já estão incorporados abaixo (SDK fora do
> PATH, nome sanitizado do AVD, boot manual do emulador antes da
> descoberta via MCP, `adb reverse` condicional à existência de backend, e
> os gotchas da API do AIO Tests). Não trate esta seção como "só
> documentada" — o executor Android roda de verdade.

### Como a skill descobre a plataforma da issue

A plataforma é lida do **label nativo do Jira** (`mobile` ou `web`),
aplicado pela `jira-issue-executor` ao final da implementação. Esta skill
**nunca infere plataforma sozinha** por conta própria (não adivinhe pelo
título, pelo componente tocado, etc.).

* Sem nenhum label de plataforma na issue → trate como **Web** (é o
  comportamento histórico desta skill, válido até a `jira-issue-executor`
  passar a aplicar o label em todo issue nova).
* Label `mobile` → executor Android.
* Label `web` → executor Web.
* Ambos os labels → execute os dois executores para essa issue, quando a
  superfície de risco justificar (ver "Regressão").

---

## Pré-requisitos obrigatórios (comuns a qualquer plataforma)

### 1. Qual projeto/Jira

Se já estiver claro pelo contexto da conversa, use sem perguntar. Caso
contrário, pergunte a Rafinha explicitamente antes de prosseguir.

### 2. Token de acesso do AIO Tests configurado

Confirme que a variável de ambiente `AIO_TESTS_ACCESS_TOKEN` está
disponível. Esse token é diferente de qualquer token de API do Jira — é
gerado dentro da página **"AIO Access Token"**, nas configurações do
próprio AIO Tests dentro do Jira de Rafinha.

Todas as chamadas à API do AIO Tests usam:

```
Base URL:  https://tcms.aiojiraapps.com/aio-tcms/api/v1/
Header:    Authorization: AioAuth <AIO_TESTS_ACCESS_TOKEN>
```

(o prefixo `AioAuth` antes do token é obrigatório, não é um espaço reservado
— faz parte do formato do header)

Sem esse token não há como registrar execução nem anexar evidência. Se não
estiver configurado, **pare e avise Rafinha** — nunca prossiga sem
conseguir registrar a execução, e nunca peça pra ele digitar o token
diretamente para você em algum formulário ou chat.

> **Nota:** os payloads exatos de cada endpoint (nomes de campo,
> obrigatoriedade) não estão fixados nesta skill de propósito, porque podem
> mudar entre versões do AIO Tests. Antes da primeira execução real,
> confira o schema atual em
> `https://tcms.aiojiraapps.com/aio-tcms/aiotcms-static/api-docs/`
> (Swagger). Nunca invente um campo de payload — confirme no Swagger.

### 3. Projeto habilitado no AIO Tests

Confirme que o projeto Jira em questão tem o AIO Tests habilitado. Se uma
chamada retornar o erro `AIO_TESTS_DISABLED_PROJ`, isso significa que o app
não está ativado nesse projeto — pare e avise Rafinha, não tente contornar.

### 4. Repositório de código correto

Confirme que o diretório de trabalho atual é o clone local do projeto
indicado (nome do repo, remote `origin`). Web e Android sempre saem do
**mesmo** repositório Flutter — não há caso de repositórios separados por
plataforma. Se o repo não bater com o projeto indicado, pergunte a Rafinha
o caminho correto.

### 5. Estado limpo e `develop` atualizada antes de testar

Rode `git status` antes de qualquer checkout. Se houver alterações não
commitadas, pare e pergunte a Rafinha o que fazer com elas — nunca descarte
sozinho.

Em seguida, `git checkout develop` e `git pull origin develop` — **sempre,
independente da plataforma** (Web ou Android). O QA testa o estado já
integrado do sistema (ver "Identidade do papel"), nunca a branch isolada da
issue; testar contra uma `develop` local desatualizada invalida o resultado
tanto no build web (`flutter run -d chrome`) quanto no build do APK.

### 6. Recovery Check (Execution State)

Antes de começar os testes de uma issue, verifique se existe
`.claude/execution-state/{CHAVE}.md` — arquivo **local, nunca commitado**
(esta etapa roda sobre `develop`, sem branch isolada própria; ver
`workflow-development-flow`, seção 13.3). Útil sobretudo quando uma rodada
de QA Android via emulador é interrompida no meio de uma bateria de casos
— o arquivo evita reexecutar do zero os fluxos já validados.

### 7. Ambiente local sobe via docker compose

O backend/API necessário para os testes precisa estar rodando localmente
(ex.: `docker compose up`) antes de cada rodada de testes, para as duas
plataformas. Se o comando ou arquivo de compose do projeto não estiver
claro, pergunte a Rafinha.

---

## Pré-requisitos específicos — Flutter Web

1. Google Chrome instalado e aberto;
2. extensão **Claude in Chrome** instalada e ativa — esta skill usa
   especificamente essa integração, não o navegador embutido do Claude
   Code, porque é o que comprovadamente funciona de forma consistente
   entre diferentes notebooks/ambientes; o navegador embutido já se
   mostrou pouco confiável para capturar evidência visual em pelo menos um
   ambiente real do Rafinha. Se a extensão não estiver disponível ou ativa,
   **pare e avise Rafinha** em vez de tentar outro navegador;
3. app disponível via `flutter run -d chrome` (ou o comando específico
   documentado pelo projeto), apontando para o backend local já de pé.

Esta skill roda tipicamente no notebook de QA dedicado de Rafinha — uma
máquina separada daquela onde ele desenvolve, para que uma rodada de QA não
atrapalhe o trabalho dele em paralelo.

---

## Pré-requisitos específicos — Flutter Android

1. **Android SDK instalado.** Se `ANDROID_HOME`/`ANDROID_SDK_ROOT` não
   estiverem setados e `adb`/`emulator` não estiverem no PATH (comum em
   instalação via Android Studio), não assuma que falta o SDK — rode
   `flutter doctor -v`, que localiza o SDK mesmo sem essas variáveis, e use
   o caminho absoluto reportado por ele para os comandos `adb`/`emulator`
   pelo resto da execução.
2. **AVD `QA - Claude` configurado.** É a convenção padrão desta skill,
   paralela ao nome de Cycle usado no AIO Tests — procure-o primeiro e
   use-o automaticamente, sem perguntar. **Atenção:** esse é o nome de
   exibição; o identificador real que `avdmanager`/`emulator` aceitam
   sanitiza espaços e o hífen para underscore (ex.: `QA_-_Claude`). Rode
   `emulator -list-avds` (ou `avdmanager list avd`) para obter o
   identificador exato — nunca assuma que o nome de exibição funciona
   literalmente como argumento de `-avd`. A skill **nunca cria um AVD
   sozinha** — se não existir um AVD equivalente a `QA - Claude`, **pare e
   peça para Rafinha criar/indicar o dispositivo virtual**.
3. **Emulador de pé antes da descoberta.** Nem o Maestro MCP
   (`list_devices`) nem o CLI enxergam ou iniciam um AVD parado — só veem
   dispositivos **já rodando**. Antes de qualquer descoberta, suba o
   emulador manualmente em background (`emulator -avd <identificador do
   item 2>`) e aguarde o boot completar (`adb shell getprop
   sys.boot_completed` até retornar `1` — costuma levar ~50s a partir de um
   emulador frio). Só então rode `list_devices`/`maestro list-devices` para
   confirmar o dispositivo disponível antes de instalar o APK.
4. ADB e Flutter disponíveis.
5. Maestro CLI instalado e no PATH (`maestro --version` deve responder).
6. Maestro MCP configurado no Claude Code (`claude mcp list` deve mostrar
   `maestro` conectado). Instalação esperada:

   ```bash
   claude mcp add --scope user maestro -- maestro mcp
   ```

   Use `--scope user` (não o padrão sem `--scope`) — sem isso o servidor
   fica preso à pasta onde o comando foi rodado e não aparece quando o
   Claude Code é aberto em outro diretório (ex.: dentro do repo do
   projeto). Não instalar um MCP de terceiros se o Maestro MCP oficial
   estiver disponível.

### Rede: emulator → backend local (quando o projeto tiver backend)

Primeiro confirme se o projeto **tem** um backend local para se comunicar —
procure `docker-compose.yml`/equivalente e dependências HTTP no
`pubspec.yaml` (`http`, `dio`, etc.). Um app 100% local (sem chamada de
rede) não precisa desta etapa — pule-a e registre isso como fato do
projeto, não como pendência.

Se houver backend: o Android Emulator não enxerga `localhost` da máquina
host como o Chrome enxerga. Antes de instalar/abrir o app no emulador,
rode, para cada porta que o backend expõe:

```bash
adb reverse tcp:<porta> tcp:<porta>
```

Isso faz o `localhost` dentro do emulador apontar de volta para o
`localhost` da máquina host, sem precisar mudar nada no código do app.

### Build do APK

Sempre **debug**, sem flavor especial — evita o risco de uma build
"release" acabar apontando pra um endpoint real de staging/produção em vez
do backend local. `develop` já deve estar atualizada pelo pré-requisito
comum (item 5):

```
adb reverse tcp:<porta> tcp:<porta>   (só se o projeto tiver backend)
       ↓
flutter build apk --debug
       ↓
APK
       ↓
instalar no Android Emulator (já de pé, ver item 3 acima)
```

A skill deve verificar o caminho real do APK produzido pelo projeto antes
de tentar instalá-lo — não assumir um caminho fixo se o projeto tiver
configuração diferente. Não utilizar um APK antigo de outra execução sem
confirmar sua origem: o APK precisa representar o estado atual de
`develop`.

**Antes da primeira rodada Android num projeto**, confirme se o workflow do
GitHub Actions daquele repo já builda o APK Android como parte da pipeline
de Integração, ou só valida o lado Web/lint (relate esse achado no
comentário da issue de qualquer forma — é informação relevante para
Rafinha mesmo quando o build funciona). Isso muda como uma falha de
`flutter build apk` deve ser interpretada — ver "Falha de teste vs. falha
de infraestrutura".

---

## Seleção do executor

```
Flutter Web       → Claude in Chrome
Flutter Android    → Maestro
Web + Android      → executar os dois quando a superfície de risco justificar
Outra plataforma   → verificar se existe executor oficialmente configurado; senão, parar e perguntar
```

Nunca testar uma issue Android pelo Web nem uma issue Web pelo Android —
mesmo quando a mudança parece pequena. Exemplo:

```
Issue: "Corrigir comportamento do botão voltar no Android"

❌ Flutter Web → Chrome → testar botão voltar
✅ Flutter APK → Android Emulator → Maestro
```

---

## Executor Android — Maestro

### MCP vs. CLI

O fluxo confirmado é `list_devices` → `inspect_screen` → `run` (exploração
interativa, com `take_screenshot` quando útil), seguido de
`maestro test .maestro/<flow>.yaml` via CLI para a execução determinística
final do flow permanente — os dois papéis coexistem na mesma rodada, não
são alternativas entre si:

```
maestro test .maestro/
maestro test .maestro/auth/login_success.yaml
```

Os nomes de ferramenta do MCP confirmados na versão atual (Maestro 2.8.0)
são `list_devices`, `inspect_screen`, `run`, `take_screenshot` e
`cheat_sheet` (consulte este último antes de escrever comando/flow não
familiar). Ainda assim, **não assuma esses nomes fixos entre versões** —
confirme as ferramentas efetivamente disponibilizadas antes de depender
delas. Não usar coordenadas de mouse do desktop como mecanismo primário de
automação mobile, e não usar captura de tela do desktop como substituto da
inspeção do dispositivo quando o MCP estiver disponível.

### Testabilidade

Componentes interativos importantes precisam de identificadores estáveis
(texto acessível, `Key`, semântica acessível) para os flows serem estáveis.
Preferir `tapOn: "Salvar"` a "clicar no terceiro botão da tela". Se um
elemento importante não puder ser identificado de forma confiável (ex.:
dois controles com o mesmo texto/label, exigindo um seletor relativo como
`below:`; ou um controle sem `content-desc`, exigindo `point:` percentual
como último recurso), registre isso como problema de testabilidade — a
skill de QA **não modifica código** para criar o identificador, só relata
o problema, tanto no `.maestro/README.md` quanto no comentário da issue
(ver "Comentário obrigatório no Jira").

### Falha no Maestro: teste vs. infraestrutura

Antes de concluir que existe falha funcional, verifique em ordem: o
dispositivo está saudável; o app foi instalado corretamente; o elemento
esperado existe; não houve mudança legítima de interface; os logs não
indicam outra causa; reproduza uma vez quando necessário. Só então conclua
`TEST FAILURE`. Se emulator não iniciou, ADB não responde, Maestro/MCP
desconectou, o APK não foi produzido, ou o backend está indisponível, isso
é `ENVIRONMENT FAILURE` — vira **inconclusivo** (ver comentário fixo), não
reprovação.

---

## Casos de teste e flows Maestro permanentes

### Geração dos casos de teste

Derive os casos de:

1. descrição da issue;
2. critérios de aceite explícitos;
3. comentários da implementação e da integração;
4. fluxos relacionados / testes existentes.

Não invente critérios de aceite. Se o comportamento esperado não puder ser
determinado a partir disso, **pare e pergunte a Rafinha**.

### Flows Maestro (Android) como patrimônio permanente do projeto

Um flow `.maestro/*.yaml` é um roteiro de teste automatizado — descreve uma
sequência de ações (`tapOn`, `inputText`, `assertVisible`, etc.) que o
Maestro executa sozinho no emulador, sem clique manual. Diferente da
execução de QA em si (que não deixa rastro reutilizável), o flow é um
arquivo versionado que **deve ser reaproveitado** entre issues futuras que
tocam no mesmo fluxo — não recrie um flow equivalente a um que já existe.

Antes de criar um flow novo: procure flows existentes na estrutura
`.maestro/` do projeto, verifique se algum já cobre o cenário, reutilize
quando aplicável. Respeite a estrutura real do projeto quando já existir —
não reorganize por preferência. Estrutura de referência (adapte à estrutura
já existente no repo):

```
.maestro/
├── README.md            ← mantido por esta skill, ver abaixo
├── auth/
│   ├── login_success.yaml
│   └── logout.yaml
├── registration/
│   └── registration_success.yaml
└── regression/
    └── smoke.yaml
```

Um novo flow deve ser determinístico, legível, pequeno, específico,
reutilizável e baseado em identificadores estáveis — não uma suíte gigante.

**`.maestro/README.md`**: esta skill cria e mantém esse arquivo, explicando
a arquitetura da pasta — o que é flow permanente vs. exploração pontual,
convenção de nomes/subpastas, como rodar via CLI. É documentação viva do
patrimônio de teste, não um comentário perdido neste SKILL.md.

### Commit e push — exceção única e estrita

Esta é a **única** exceção à regra "nunca commitar, nunca dar push" de
todo o fluxo Rafinha-Claude: a skill pode commitar **e dar push direto na
`develop`** (sem Pull Request — são arquivos de teste, sem risco pro
comportamento do app), mas **exclusivamente** para arquivos dentro de
`.maestro/**` (incluindo o `README.md` acima).

Antes de qualquer commit, confira `git diff --cached --name-only` — se
aparecer qualquer arquivo fora de `.maestro/**`, **aborte o commit**. Nunca
commitar código de produção, nunca modificar um flow permanente existente
só para uma issue passar sem registrar que o teste foi alterado.

---

## Execução dos casos

Para cada caso de teste:

1. garanta que o app/build correto está instalado;
2. garanta que o dispositivo correto está disponível (aba Chrome / emulador);
3. inicie/reinicie o app conforme necessário;
4. execute os passos e observe o resultado;
5. valide o estado esperado — **nunca marque um teste como aprovado apenas
   porque o flow/navegação iniciou**; o comportamento esperado precisa ser
   efetivamente validado;
6. verifique console/rede (Web) ou logs/resultado do Maestro (Android) —
   um erro técnico inesperado é sinal de falha mesmo que o caso "pareça"
   ter passado visualmente;
7. colete evidência (screenshot);
8. registre o resultado.

### Regressão

Além dos casos diretamente ligados à issue, identifique fluxos existentes
com relação/dependência com a área alterada (ex.: mudança no gerenciamento
de autenticação → regressão em login, logout, navegação autenticada,
persistência de sessão). A regressão deve ser proporcional à superfície
afetada — não rode a suíte inteira do projeto indiscriminadamente em toda
issue. Se não houver fluxo relacionado plausível, registre isso
explicitamente no comentário final em vez de pular a etapa silenciosamente.

Quando a issue tem label `web` **e** `mobile` e afeta comportamento
compartilhado (ex.: serviço de autenticação), execute a regressão nas duas
plataformas quando a superfície de risco justificar; se for exclusiva de
uma plataforma, a outra não é necessária — registre isso no comentário.

### Evidências

Screenshot em cada ponto de verificação relevante — sem gravação de vídeo.
Em caso de falha, formato de referência:

```
EXPECTED: <comportamento esperado>
OBSERVED: <o que de fato aconteceu>
EVIDENCE: <screenshot do ponto exato da falha>
```

A evidência deve permitir que Rafinha entenda o problema sem precisar
reexecutar imediatamente o teste.

---

## AIO Tests — registro

Não existe um MCP dedicado para o AIO Tests — os nomes abaixo (ex.:
`createTestCase`, `addCaseToCycle`) são referências às operações da API
REST, chamadas via HTTP direto (`curl` ou equivalente), não nomes de
ferramenta MCP. Confirme o schema exato de cada uma no Swagger antes de
montar o payload — os nomes de campo abaixo não substituem essa consulta.

### Gotchas conhecidos da API (confirmados em 2026-08-22, projeto Encryption Playground)

* `CaseStep` exige o campo `stepType` — não fica óbvio lendo o resumo do
  Swagger na diagonal; confira a definição do schema `CaseStep`
  explicitamente antes da primeira chamada, ou a criação retorna `400`.
* `jiraRequirementIDs` com o ID numérico da issue do Jira funciona direto
  no POST de criação do caso — não é necessário nenhum fallback via
  `PUT /detail` só para vincular à issue.
* Upload de anexo (`curl -F`) em ambiente Windows + Git Bash: use caminho
  no formato Windows (`C:/Users/...`), não POSIX (`/c/Users/...`) — o
  `curl` instalado nesses ambientes costuma ser um build nativo mingw64
  que espera caminho Windows; caminho POSIX falha com `curl: (26)`.

### Casos de teste

1. `getOrCreateTestCaseFolderHierarchy` — encontre ou crie a pasta
   correspondente ao projeto/feature da issue (separe Web de Android
   quando a estrutura do projeto já não fizer essa distinção sozinha).
2. `createTestCase` — crie um caso por cenário, vinculado à issue do Jira
   (confira no Swagger o campo usado para esse vínculo — é o que alimenta a
   Traceability, ou seja, o que faz o caso aparecer dentro da própria issue
   no Jira). Não crie duplicatas — procure antes de criar.

### Cycle

1. `searchTestCycles` — verifique se já existe um Cycle para essa rodada.
   Se não existir, `createTestCycleDetail` cria um novo, usando
   `getOrCreateTestCycleFolderHierarchy` para a pasta. Nomenclatura, **uma
   por plataforma** (não misture Web e Android no mesmo Cycle):

   ```
   QA - Claude - Web - <sprint> - <data>
   QA - Claude - Android - <sprint> - <data>
   ```

2. `addCaseToCycle` — adicione cada caso ao Cycle correspondente. Isso gera
   um Run por caso.

### Resultado dos Runs

1. `getTestRunStatusList` — confirme os IDs/nomes de status configurados no
   projeto; não assuma que "Passed"/"Failed" são os únicos existentes.
2. `markTestCaseResult` (ou `updateDetailedRunResult` para detalhar por
   step) — aprovado somente se todos os passos passaram, o comportamento
   esperado foi observado, e não houve erro técnico relacionado. Reprovado
   caso contrário.
3. `addAttachmentsToRun` (ou `addAttachmentsToRunStep` para o passo exato
   da falha) — anexe ao menos um screenshot representativo; em falhas,
   também o screenshot do ponto exato da falha.
4. Em reprovações, `postRunCommentToLatestRun` — descreva esperado vs.
   observado nesse Run especificamente.

Se o projeto não tiver um status configurado equivalente a "inconclusivo"
para o cenário de falha de infraestrutura, registre isso em texto no
comentário do Run em vez de forçar um status que não reflete o que
aconteceu.

---

## Comentário obrigatório no Jira

Publique um comentário na issue (via Atlassian Rovo) começando **com o
texto exato** correspondente ao resultado:

* **Aprovado** → `QA aprovado por claude`
* **Reprovado** → `Teste de QA - Claude falharam`
* **Inconclusivo por infraestrutura** → `QA - Claude: Não foi possível
  chegar a um resultado`

Depois da frase fixa, informe: plataforma testada, executor utilizado,
quantidade de casos e aprovados/reprovados, regressões executadas, link do
Cycle/Run no AIO Tests, e observações relevantes (ex.: "regressão Android
não executada — issue exclusiva de Web").

> **Dependência para trabalho futuro:** a `jira-issue-executor` reconhece
> hoje "review reprovada por rafinha"/"review reprovada por claude" como
> gatilho de correção. Ela precisa ser atualizada para também reconhecer
> `"Teste de QA - Claude falharam"` como gatilho equivalente — sem isso, a
> reprovação de QA move a issue mas não é automaticamente entendida como
> pendência de correção na próxima varredura.

---

## Movimentação da issue

* **Aprovada** → "Documentar".
* **Reprovada** → "Fazer - Claude".
* **Inconclusiva por infraestrutura** → **não move**. Informe Rafinha e
  aguarde decisão — nunca mova para "Documentar" nem para "Fazer - Claude"
  quando não houver condições de um QA confiável.

Sempre que a issue for movida (aprovada ou reprovada), apague
`.claude/execution-state/{CHAVE}.md` se existir — o comentário no Jira já
é o registro permanente a partir daqui.

---

## O que NÃO fazer

* ❌ Nunca corrigir, ajustar ou "consertar rapidinho" código encontrado
  quebrado — isso é sempre trabalho da `jira-issue-executor`.
* ❌ Nunca aprovar uma issue sem executar de fato os casos de teste — nunca
  aprove só por leitura do código ou por "parecer que funciona".
* ❌ Nunca inventar um critério de aceite quando a issue não deixa claro o
  que testar — sempre pare e pergunte a Rafinha.
* ❌ Nunca inventar ID de status, pasta, campo do AIO Tests, payload ou
  nome de ferramenta MCP sem consultar a configuração/versão real.
* ❌ Nunca registrar um resultado no AIO Tests sem que o caso já exista lá
  e esteja vinculado à issue correta, nem criar casos duplicados.
* ❌ Nunca commitar ou dar push em nada fora de `.maestro/**` — essa é a
  única exceção existente, e mesmo ela nunca inclui código de produção.
* ❌ Nunca prosseguir sem o `AIO_TESTS_ACCESS_TOKEN` configurado.
* ❌ Nunca prosseguir sem confirmar o executor certo para a plataforma —
  nunca testar Android pelo Web nem Web pelo Android, mesmo em mudanças
  aparentemente pequenas.
* ❌ Nunca assumir que `list_devices`/o CLI enxergam um AVD parado — suba o
  emulador explicitamente e aguarde o boot completar antes de prosseguir.
* ❌ Nunca criar um AVD automaticamente, nem escolher um AVD diferente de
  `QA - Claude` por conta própria quando ele não existir — pare e peça
  para Rafinha.
* ❌ Nunca aplicar `adb reverse` ou assumir backend local num projeto
  Android sem antes confirmar que ele realmente tem um backend — alguns
  apps são 100% locais.
* ❌ Nunca usar coordenadas de tela como estratégia primária de automação
  mobile, nem controle visual de desktop quando o Maestro MCP estiver
  disponível.
* ❌ Nunca usar um MCP de terceiros quando o Maestro MCP oficial estiver
  disponível e atender ao requisito.
* ❌ Nunca confundir falha de infraestrutura com falha funcional — verifique
  antes de concluir.
* ❌ Nunca começar a testar sem confirmar que a issue passou pela Integração
  (comentário da `jira-integration-executor`) — se não houver esse
  comentário, pare e pergunte a Rafinha.
* ❌ Nunca testar só os casos da própria issue quando existir fluxo
  relacionado plausível de regressão.
* ❌ Nunca mover a issue sem o comentário com a frase fixa correspondente,
  nem mover uma issue inconclusiva para "Documentar" ou "Fazer - Claude".
* ❌ Nunca descartar alterações não commitadas no repositório sem
  confirmação explícita de Rafinha, nem usar um APK antigo sem confirmar
  sua origem.
* ❌ Nunca modificar um flow Maestro permanente durante uma execução de QA
  sem registrar que o teste foi alterado, nem transformar um único flow em
  suíte gigante.
* ❌ Nunca commitar `.claude/execution-state/{CHAVE}.md` — esta etapa roda
  sobre `develop`, e o arquivo é sempre local (ver seção 13.3 de
  `workflow-development-flow`); a exceção de commit/push desta skill
  continua sendo só `.maestro/**`.
* ❌ Nunca confiar cegamente num Execution State encontrado — sempre
  reconciliar com o estado real do AIO Tests/Jira antes de continuar a
  partir dele.

---

## Resumo final ao usuário

Depois de processar todas as issues elegíveis da execução, apresente um
resumo consolidado, por exemplo:

```
✅ Projeto testado: [nome/chave do projeto]
📋 Issues processadas: [quantidade]
  - [ISSUE-1] (Web): 4 casos da issue + 2 de regressão (login, navegação
    autenticada) no AIO Tests, todos aprovados → movida para "Documentar"
    (Cycle: [link])
  - [ISSUE-2] (Web): 3 casos de teste, 1 reprovado (campo "status" não
    atualiza após salvar) → movida para "Fazer - Claude" (Run: [link])
  - [ISSUE-3] (mobile): 1 caso novo (flow Maestro criado em
    .maestro/<area>/<cenario>.yaml, commitado e enviado direto para
    develop), aprovado → movida para "Documentar" (Cycle: [link])
⚠️ Issues puladas por ambiguidade (sem critério de aceite claro, plataforma
  sem executor ativo, etc.): [lista ou "nenhuma"]
```
