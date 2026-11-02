---
name: flutter-frontend-package-builder
description: Criar Flutter Frontend Packages novos ou reconstruí-los a partir de protótipos e projetos existentes, com application, features, core e design_system. Diagnosticar e propor escopo antes de construir; gerar cinco AGENTS.md específicos do resultado. Usar por invocação explícita para construção de packages, não para correções pontuais ou funcionalidades sem requisitos.
disable-model-invocation: true
---

# Flutter Frontend Package Builder

## Distribuição autocontida para Claude

Este arquivo reúne o conteúdo operacional completo: instruções, sete referências, cinco templates e código integral do verificador estrutural. As referências internas apontam para seções deste próprio documento. Os templates são roteiros a preencher, não documentos prontos do projeto.

As seções de compatibilidade também descrevem a edição modular original. Nesta edição de arquivo único, não exigir diretórios references/, assets/ ou scripts/ preexistentes. Para executar check_package.py, usar o código integral da seção Verificador incorporado: somente após aprovação da construção, salvá-lo em arquivo temporário próprio fora dos repositórios-alvo, usar Python 3.9+ e passar o caminho absoluto do package. Não sobrescrever helpers ou outros arquivos existentes. Se o ambiente não permitir execução, verificar manualmente e registrar que o script não foi executado.

Esta edição preserva as regras da skill instalada; adapta somente a apresentação para um arquivo. Não inclui ferramentas de desenvolvimento/distribuição, ícones ou logs de avaliação, pois eles não são necessários à operação no Claude.

## Limites permanentes

- Atuar somente por invocação explícita, nos diretórios e repositórios autorizados. A invocação inicia diagnóstico; não aprova construção indefinida.
- Aplicar quatro camadas e Clean Architecture Intermediária proporcional às responsabilidades reais. Não inventar funcionalidades, consumidores, contratos, componentes ou dependências.
- Respeitar decisões sobre estado, rotas, DI, HTTP, persistência e autenticação. Não impor bibliotecas nem perguntar por escolhas que o escopo não exige.
- Separar diagnóstico, proposta, aprovação e execução. Reutilizar aprovação anterior que cubra o plano, sem perguntar novamente por rotina. Aguardar lacuna relevante apenas para a parte dependente.
- Não exigir Rafinha Workflow, Jira, Confluence, MCP, hooks, plugins ou agentes paralelos.
- Não modificar consumidores, back-end ou repositórios adjacentes sem autorização explícita. Não corrigir achados fora do escopo automaticamente.
- Não executar comandos dinâmicos ao carregar a skill. Não alterar configurações globais, instalar SDK ou publicar por inferência.

## 1. Receber contexto

Identificar cenário novo/existente, nome real, destino, referências, objetivos, consumidores conhecidos, tecnologias decididas e limites. Ler instruções aplicáveis do repositório, respeitando a hierarquia do executor. Referência não equivale a alvo de escrita.

Consultar [compatibilidade](#referencia-tool-compatibility) para identificar executor, descoberta e instruções locais. Nesta edição autocontida, consultar os recursos incorporados nas seções abaixo; não procurar arquivos auxiliares externos. Se precisar identificar a origem da skill, usar o SKILL.md efetivamente carregado, mesmo que sua pasta tenha sido renomeada pelo host. Usar caminhos absolutos resolvidos e argumentos separados/escapados; não interpolar entradas em código shell.

Perguntar somente o necessário para evitar decisão relevante indevida ou alvo ambíguo. Um package estrutural sem integração não precisa escolher estado, HTTP, armazenamento ou roteador.

## 2. Diagnosticar em leitura

Consultar [arquitetura](#referencia-architecture) e a referência pertinente:

- [Package novo](#referencia-new-package): destino, SDK e mínimos sem inventar implementação.
- [Projeto existente](#referencia-existing-project): código, requisitos, contratos, dependências e testes; separar capacidades confirmadas de experimentos e hipóteses.
- [Segurança Git](#referencia-git-safety): raiz, base, trabalho local, branches e worktrees quando houver Git.

Registrar evidências por caminho/contrato/documento ou confirmação. Não tratar todo comportamento do protótipo como requisito nem inferir comportamento invisível de imagens.

Antes da aprovação, não criar branch, worktree, diretórios de destino nem executar comandos que gerem arquivos no projeto, incluindo resolução de dependências. Inspeções de SDK que inicializem caches ficam para a fase autorizada; reconhecer a limitação.

## 3. Propor e obter aprovação

Apresentar primeiro cenário/destino/referências, escopo incluído, exclusões, impacto retroativo (nenhum por padrão), riscos e pendências. Mapear responsabilidades às quatro camadas, justificar estrutura interna, preservar tecnologias e expor decisões pendentes. No cenário existente, incluir branch, SHA de base, worktree e tratamento de alterações locais. Definir API necessária, compatibilidade, checks e critério de suficiência.

Não construir sem aprovação que cubra essa proposta. Se já houver aprovação dos elementos concretos, declarar o escopo e prosseguir sem confirmação repetida. Atualizar a parte afetada quando houver ampliação relevante.

## 4. Construir o aprovado

Seguir cenário e estratégia Git aprovados; conferir destino/branch antes de escrever. Reaproveitar o adequado e reimplementar o autorizado. Preservar o protótipo conforme base e estratégia aprovadas.

Manter `AGENTS.md`, `pubspec.yaml`, `lib/<nome_real>.dart`, `test/` e estes quatro caminhos:

- `lib/src/application/AGENTS.md`.
- `lib/src/features/AGENTS.md`.
- `lib/src/core/AGENTS.md`.
- `lib/src/design_system/AGENTS.md`.

Os próprios documentos preservam as camadas no Git. Usar `test/.gitkeep` apenas sem testes reais; não criar camadas internas vazias. No cenário novo, permitir entrada pública somente documental e registrar ausência de features/serviços/componentes.

Exportar somente o necessário aos consumidores confirmados. Composição seleciona/integra features sem duplicar implementação; não é autorização de acesso nem garantia de exclusão de código do binário.

## 5. Documentar

Consultar [contrato documental](#referencia-agents-contract) e os roteiros:

- [Raiz](#template-root).
- [Application](#template-application).
- [Features](#template-features).
- [Core](#template-core).
- [Design System](#template-design-system).

Preencher a partir do resultado real; substituir/remover todos os campos. Descrever ausências como ausências. Não copiar regras genéricas nem inventar caminhos, consumidores, bibliotecas ou comandos verificados. Preservar instruções existentes pertinentes.

Adaptadores CLAUDE.md somente quando necessários, autorizados e verificados conforme compatibilidade. Não apagar documentos adicionais preexistentes para forçar contagem de cinco.

## 6. Validar e entregar

Consultar [validação](#referencia-validation). Executar `scripts/check_package.py` com Python 3, `--package-root`, `--package-name` e opcional `--format json`. O script é somente de leitura e verifica estrutura/documentos; não prova arquitetura nem comportamento.

Executar checks SDK/análise/testes aplicáveis no alvo autorizado; conferir dependências efetivas, API, requisitos e documentos. Revisar diff e fronteiras de escrita. Não criar testes tautológicos, app example ou integração remota para parecer validado.

Relatar destino/branch/base, implementado versus aprovado, escolhas efetivas, cinco documentos, checks/resultados, limitações e pendências. Distinguir aprovado, falhou, não executado e não aplicável. Não declarar teste funcional/compatibilidade por mera busca textual.

Na falha, preservar parcial e corrigir somente dentro do escopo, sem rollback destrutivo. Na retomada, reler Git, arquivos/instruções, referências e aprovação vigente; não reinicializar cegamente.

## Referencia architecture

## Arquitetura-base

Aplicar as decisões do Documento Mestre aprovado, sem substituí-las por preferências próprias. Manter quatro camadas em lib/src/: application, features, core e design_system. Organizar capacidades por feature, reutilizáveis por múltiplos aplicativos.

| Camada | Conter | Evitar |
| --- | --- | --- |
| Application | Composições reais, integração/seleção de features e entradas pertinentes | Telas duplicadas, negócio e roteador obrigatório |
| Features | Capacidades funcionais com estrutura proporcional | Negócio em widgets e imports indiscriminados de outras features |
| Core | Infraestrutura técnica reutilizável necessária | Negócio específico e serviços globais sem finalidade |
| Design System | Tokens, temas, componentes e padrões visuais reais | Dependência de features/negócio e wrappers de todos os widgets Flutter |

Composição não é sinônimo de roteamento. Criar admin/, applicator/ ou outras apenas para consumidores confirmados. Seleção não é controle de acesso, isolamento de segurança ou garantia de tree shaking.

### Clean Architecture Intermediária

| Elemento | Criar quando |
| --- | --- |
| presentation/ | Houver UI ou estado de apresentação |
| data/ | Houver API, armazenamento, banco ou fonte externa |
| domain/ | Regras/conceitos de negócio precisarem de isolamento |
| entities/ | Conceitos de domínio exigirem representação própria |
| models/ | Contratos externos, como JSON, exigirem representação |
| repositories/ | Encapsular obtenção/persistência tiver utilidade concreta |
| datasources/ | Separar acesso à fonte do repositório tiver responsabilidade distinta |
| usecases/ | Operação exigir regras, coordenação ou validações próprias |
| state/, bloc/, cubit/ etc. | Tecnologia adotada e estado real justificarem |

Não criar pastas vazias, interfaces, entidades para DTOs simples ou casos de uso pass-through sem finalidade. Consultar granularidade quando separar/agrupar afetar contratos ou reutilização; não fixar feature por tela.

Quando houver domain/, mantê-lo independente de Flutter e infraestrutura concreta. Posicionar contratos conforme responsabilidade; dados pode implementá-los e composição conectá-los. Conferir imports/chamadas efetivos, não somente nomes de pastas.

Sem domínio separado, apresentação pode usar dados em casos simples. Documentar o acoplamento pragmático e isolar regras quando elas justificarem a separação.

### Dependências e evolução

Não impor uma cadeia linear universal. Application pode usar features/recursos necessários à composição. Features podem usar Core e DS. Core não depende de capacidade particular para cumprir papel técnico. DS não depende de features/negócio. Avaliar outras relações, como recurso técnico do Core no DS, por responsabilidade/extração futura.

Estado, rotas, DI, HTTP, persistência e autenticação são escolhas contextuais. Respeitar bibliotecas/contratos estabelecidos. Projetar inicialização, compartilhamento e descarte para aquele projeto sem módulo universal, registro dinâmico ou service locator obrigatório.

Manter lib/<nome_real>.dart identificável, com exports mínimos. Entradas adicionais só por necessidade demonstrada. Preservar imports internos consistentes ou propor convenção quando faltar. Consumidores usam API pública acordada; src é intenção de encapsulamento, não barreira de segurança.

Avaliar impacto de contratos compartilhados; não editar consumidores/back-end fora do escopo. Widget ligado ao domínio fica na feature; componente visual reutilizável pode ficar no DS.

Facilitar extração manual futura do DS, sem automatizá-la: exigirá pubspec, dependências, imports e API adequados. Não prometer copiar e executar.

## Referencia new-package

## Cenário novo

1. Resolver nome real, destino, finalidade e SDK/contexto. Esclarecer conflito Flutter versus Dart puro, sem substituir a escolha do projeto. Identificar consumidores/plataformas apenas se existirem.
2. Verificar destino/fronteira Git em leitura. Se ocupado, esclarecer preservação e escopo antes de sobrescrever.
3. Propor configuração mínima, quatro camadas, cinco AGENTS.md, entrada pública e checks. Não exigir tecnologias ainda desnecessárias.
4. Após aprovação, criar package usando SDK disponível ou arquivos mínimos equivalentes; conferir versões compatíveis. Não instalar/atualizar SDK global. Sem SDK, declarar validade não certificada pela ferramenta.
5. Inspecionar gerados e retirar demos/classes/testes/dependências de exemplo sem finalidade no escopo, sem remover trabalho preexistente.
6. Manter pubspec.yaml, lib/<nome_real>.dart, quatro camadas com AGENTS.md e test/. A entrada pública pode conter somente documentação enquanto não houver exports reais.
7. Usar test/.gitkeep só sem testes reais. Os documentos locais preservam as camadas; não criar placeholders internos adicionais.
8. Documentar ausência de features, infraestrutura, componentes e consumidores. Não inventar tema, paleta ou telas.
9. Validar o aplicável; sem comportamento, não criar teste tautológico nem exigir app executável. Registrar bloqueios.

Suficiência: estrutura mínima coerente/configurada para o contexto, cinco documentos específicos e nenhuma funcionalidade ou biblioteca contextual inventada.

Inicializar Git fora de repositório apenas se incluído no plano. Se houver Git, seguir segurança antes de mutações.

## Referencia existing-project

## Cenário existente ou protótipo

### Diagnóstico

Inspecionar instruções locais, pubspec, entradas, UI, estado, integrações, contratos, armazenamento, testes e documentação relevantes. Evitar leitura indiscriminada de gerados/dependências. Referência visual não comprova comportamento invisível.

Mapear capacidades com evidência (caminho/contrato/teste/documento/confirmação), estado (confirmado/experimental/hipótese/pendente), destino (feature/composição/Core/DS), tratamento (reaproveitar/reimplementar/retirar do resultado/aguardar) e validação esperada.

Não transformar experimento em requisito nem exigir preservação linha a linha. Reaproveitar partes adequadas e reconstruir o aprovado.

### Proposta e execução

Especificar funcionalidades incluídas/excluídas, fidelidade visual/comportamental, consumidores conhecidos, APIs compatíveis, bibliotecas preservadas e mudanças de contratos. Identificar diretórios substituídos na branch e preservação do protótipo.

Seguir branch/base/worktree aprovados. Não construir na branch original por conveniência. Sem Git que permita branch separada, esclarecer antes de escrever.

Reorganização completa só se delimitada. Não trocar bibliotecas por preferência nem adaptar repositórios adjacentes automaticamente. Retirar experimento do resultado não autoriza apagar referência.

Confrontar resultado com requisitos aprovados. Com mocks, validar o possível e registrar integração real não exercitada. Não migrar testes experimentais como contrato definitivo sem análise. Diante de lacuna de negócio, perguntar pela parte afetada, sem inventar regra para fechar teste.

## Referencia git-safety

## Branch, base e preservação

### Diagnóstico

Resolver raiz Git real, destino, branch/HEAD, status incluindo não rastreados e worktrees. Usar leitura com argumentos seguros, restrita ao repositório identificado. Inspecionar conflitos/operações que afetem a estratégia.

Não pressupor main/master ou remoto atualizado. Identificar base local por SHA; acesso remoto essencial requer contexto autorizado. Não atualizar refs/alternar branches como diagnóstico sem considerar efeitos.

### Reconstrução

Preferir branch nova frontend-package/<identificador> em worktree separado a partir do SHA escolhido. Incluir nome, base, localização e fronteiras no plano; respeitar convenção existente. Worktree separa a árvore, não é backup nem inclui mudanças não commitadas.

| Situação | Ação |
| --- | --- |
| Árvore limpa | Propor branch/worktree do SHA identificado |
| Mudanças locais não necessárias | Deixar intactas e explicar que a base é o commit aprovado |
| Escopo depende de mudanças locais | Identificar arquivos/versões e aprovar referência/incorporação; não copiar ignorados, segredos ou artefatos indiscriminadamente |
| Branch/caminho existe | Inspecionar e propor alternativa ou seleção autorizada; não forçar |
| Branch em outro worktree | Respeitar ocupação, sem desmontar trabalho |
| Conflito/operação em andamento | Não resolver por inferência; avaliar alternativa isolada segura ou pausar parte afetada |
| Worktree inviável | Propor branch na árvore atual apenas com preservação segura |
| Existente sem Git | Esclarecer repositório/destino; cópia de pasta não satisfaz branch |

### Após aprovação

Revalidar SHA/status/colisões antes de criar o aprovado; podem ter mudado. Confirmar raiz/branch no destino antes de escrever. Se depender de mudanças locais, incorporá-las apenas conforme decisão específica.

Não executar automaticamente reset destrutivo, clean, stash, commit de mudanças do usuário, merge, rebase, force-push, publicação ou mudanças em repositórios adjacentes. Commit/push do resultado não são passos obrigatórios.

Informar branch/base/localização ao terminar; não remover worktree por limpeza automática. Preservar parcial. Na retomada, reler Git/diff/instruções/aprovação e continuar somente no escopo vigente. No cenário novo fora de Git, inicializar repositório só se desejado/aprovado.

## Referencia agents-contract

## Contrato dos cinco AGENTS.md

Gerar na raiz e em lib/src/application/, features/, core/ e design_system/. Não criar por feature por rotina. Inventariar adicionais preexistentes e preservar conteúdo pertinente, sem apagar para satisfazer contagem.

Usar templates como roteiro, não conteúdo pronto. Campos seguem `{{NOME_DO_CAMPO}}`; substituir/remover todos. Preencher por evidências reais e decisões confirmadas. Ausência de recurso é informação válida, não razão para implementá-lo.

| Documento | Conteúdo contextualizado |
| --- | --- |
| Raiz | Nome/finalidade, consumidores ou ausência, mapa das camadas, tecnologias, entradas/imports/API, navegação, comandos/diretórios verificados, evolução e links dos quatro documentos |
| Application | Composições ou ausência, integração/seleção por consumidor, ciclo de vida quando definido, navegação real ou ausência, entradas e limites |
| Features | Capacidades/limites, critérios de Clean intermediária, estrutura adotada, dependências, estado/erros/testes e evolução proporcional |
| Core | Infraestrutura ou ausência, contratos/ciclo de vida conhecidos, reutilização, impacto compartilhado e exclusão de negócio específico |
| Design System | Tokens/temas/componentes ou ausência, referências visuais confirmadas, reutilização, widgets de feature, dependências e extração manual |

Features pode ser mais detalhado sem copiar o mestre. Locais complementam a raiz sem contradições. A raiz exige ler documento da camada antes de editar; links não são importação automática universal.

Conferir caminhos/símbolos/exports/bibliotecas/consumidores. Distinguir orientação futura do estado atual. Marcar comandos como verificados somente após executar e conhecer resultado/diretório; limitações são explícitas. Sugestões não executadas ficam como pendências no relatório. Sem consumidor executável, não inventar comando de rodar app.

Usar links relativos e excluir credenciais/caminhos pessoais. Documentar escolhas pragmáticas concretas. Preservar políticas locais; conflitos relevantes exigem esclarecimento da parte afetada, respeitando a hierarquia. Não prometer segurança por composição ou DS portátil por cópia.

Adaptadores Claude, quando necessários, seguem compatibilidade e só importam documentos; não duplicam regras.

## Referencia tool-compatibility

## Compatibilidade de executores

Base documental: 30/10/2026. Revalidar na versão/configuração efetiva; documentação não equivale a teste funcional.

| Executor | Pessoal local | Projeto | Invocação |
| --- | --- | --- | --- |
| Claude Code | ~/.claude/skills/<nome>/ | .claude/skills/<nome>/ | /flutter-frontend-package-builder |
| Codex CLI/IDE | ~/.agents/skills/<nome>/ | .agents/skills/<nome>/ | $flutter-frontend-package-builder ou /skills |

Uma fonte canônica usa name/description. Distribuição Claude adiciona disable-model-invocation: true; Codex usa policy.allow_implicit_invocation: false em agents/openai.yaml. Corpo/recursos são idênticos. Não editar gerados manualmente nem exigir symlinks no Windows.

Invocação não substitui aprovação. Instalação pessoal é preferida para ferramenta independente; projeto requer destino autorizado. Hosts gerenciados podem ter instalação própria: respeitá-la sem supor que pastas locais certifiquem cloud/plugins.

### Claude Code e AGENTS.md

Documentação atual: suporte direto desde v2.1.277, condicionado a configuração e presença de CLAUDE.md/CLAUDE.local.md na hierarquia. Instruções locais carregam ao ler arquivos na área; /context ajuda a verificar. Alternativa: CLAUDE.md vizinho importando @AGENTS.md.

Preferir cinco AGENTS.md sem extras se suporte nativo comprovado. Inspecionar versão/configurações/instruções existentes. Se preciso, propor cinco adaptadores CLAUDE.md, um por documento, somente com import relativo; preservar conteúdo existente e aprovar mudanças. Import na raiz não garante leitura de camadas. Não alterar configurações globais nem contornar bloqueio organizacional.

### Codex e AGENTS.md

Documentação descreve cadeia raiz até diretório de trabalho, proximidade prevalecente, AGENTS.override.md antes de AGENTS.md no mesmo diretório e limite combinado padrão de 32 KiB. Iniciar na raiz não prova pré-carregamento das quatro camadas.

A raiz deve exigir leitura local antes de editar a camada. Inspecionar overrides/truncamentos sem apagar políticas. Verificar sessões da raiz e de cada camada; links Markdown não são imports universais.

### Verificar

Registrar executor/versão/configuração, fontes e resultado por camada. Usar fixtures/sessões novas, sem segredos. Conferir evidências de contexto/leitura e aplicação da regra; autodeclaração do agente não basta. Testar invocação explícita e não invocação em pedido genérico Flutter. Separar suporte documental, estrutura validada e comportamento exercitado.

Resolver recursos relativamente ao SKILL.md carregado, sem pressupor nome de pasta. Não usar interpolação específica do executor no corpo comum.

### Fontes oficiais

- [Claude — Skills](https://code.claude.com/docs/en/skills).
- [Claude — Memória](https://code.claude.com/docs/en/memory).
- [OpenAI — Skills](https://learn.chatgpt.com/docs/build-skills).
- [OpenAI — AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## Referencia validation

## Validação e falhas

Planejar checks na proposta e executar no alvo aprovado. Distinguir aprovado, falhou, não executado e não aplicável.

### Script estrutural

Executar scripts/check_package.py com Python 3.9 ou posterior, caminho absoluto resolvido, --package-root <destino>, --package-name <nome_real> e opcional --format json (padrão text). Se indisponível, conferir estrutura manualmente e registrar que o script não foi executado.

Usar biblioteca padrão, sem escrita, rede ou execução do projeto. Conferir camadas/documentos/pubspec/entrada/test/, campos não preenchidos e links locais. Não seguir symlink para fora do alvo silenciosamente. Não validar YAML/Dart, âncoras Markdown, arquitetura ou comportamento.

Códigos: 0 = sem erro estrutural; 1 = falhas estruturais; 2 = entrada/ambiente inválido. Examinar avisos, inclusive documentos adicionais e limitações de links. Parser suporta links inline/referências Markdown usuais; não é CommonMark completo. Forms não reconhecidas devem gerar aviso quando detectáveis.

### Checks complementares

| Check | Aplicação |
| --- | --- |
| Configuração | SDK/versões e pubspec com ferramenta adequada; resolução na fase aprovada |
| Formatação/análise | Ferramentas confirmadas (flutter analyze para Flutter); alterações no escopo |
| Testes | Comportamentos reais/regras pertinentes; sem teste tautológico no esqueleto |
| API | Exports/imports e consumo público quando houver API/harness aprovado |
| Dependências | Direção efetiva: domínio sem Flutter/infra, DS sem features/negócio, Core técnico |
| Comportamento/UI | Requisitos e referências; distinguir mocks de integração real |
| Documentação | Cinco documentos versus código, símbolos, tecnologias e comandos executados |
| Fronteiras | Diff, branch/base, não rastreados e repositórios atingidos |

Biblioteca não exige app executável/example/build de plataformas. Usar consumidor/harness existente ou aprovado. Sem SDK/serviço/credencial, relatar bloqueio sem instalar globalmente ou fabricar sucesso.

Na falha, registrar causa/efeito, corrigir somente no escopo e repetir check afetado. Achado externo é relatado separadamente. Preservar parcial sem rollback destrutivo e indicar retomada segura.

Relatório: destino/branch/base; implementado versus aprovado; escolhas efetivas; cinco caminhos; comandos/diretórios/resultados; limites, pendências e desvios. Não dizer todos os testes passaram quando ausentes nem compatibilidade testada em executor indisponível.

## Template root

Destino e uso: preencher este roteiro conforme o contrato dos cinco AGENTS.md.

````markdown
# {{PACKAGE_NAME}} — orientação do package

## Finalidade e estado atual

{{PURPOSE_AND_ACTUAL_SCOPE}}

## Consumidores e tecnologias

{{KNOWN_CONSUMERS_OR_ABSENCE}}

{{ADOPTED_TECHNOLOGIES_AND_UNADOPTED_AREAS}}

## Navegação e responsabilidades

Antes de editar uma camada, ler seu documento local; não presumir carregamento automático:

- [Application](lib/src/application/AGENTS.md): composições.
- [Features](lib/src/features/AGENTS.md): capacidades e estrutura proporcional.
- [Core](lib/src/core/AGENTS.md): infraestrutura técnica.
- [Design System](lib/src/design_system/AGENTS.md): padrões visuais.

{{ACTUAL_CODE_MAP_AND_ENTRYPOINTS}}

## API e imports

{{VERIFIED_PUBLIC_API_AND_IMPORT_CONVENTIONS}}

## Comandos e validação

{{EXECUTED_COMMANDS_WITH_DIRECTORY_RESULTS_OR_LIMITATIONS}}

## Adicionar funcionalidades

{{PROJECT_SPECIFIC_EXTENSION_GUIDANCE_AND_LIMITS}}
````

## Template application

Destino e uso: preencher este roteiro conforme o contrato dos cinco AGENTS.md.

````markdown
# Application — {{PACKAGE_NAME}}

## Composições presentes

{{REAL_COMPOSITIONS_CONSUMERS_OR_ABSENCE}}

## Integração e inicialização

{{FEATURE_SELECTION_REUSE_DEPENDENCY_LIFECYCLE_OR_ABSENCE}}

## Navegação e entradas

{{ACTUAL_NAVIGATION_PUBLIC_ENTRIES_OR_ABSENCE}}

## Limites e evolução

{{SPECIFIC_BOUNDARIES_NO_DUPLICATION_OR_BUSINESS_RULES}}
````

## Template features

Destino e uso: preencher este roteiro conforme o contrato dos cinco AGENTS.md.

````markdown
# Features — {{PACKAGE_NAME}}

## Capacidades e limites

{{REAL_FEATURES_RESPONSIBILITIES_PATHS_OR_ABSENCE}}

## Estrutura proporcional

{{ACTUAL_PRESENTATION_DATA_DOMAIN_CHOICES_AND_REASONS}}

{{CRITERIA_ENTITIES_MODELS_REPOSITORIES_DATASOURCES_USECASES_STATE}}

## Dependências e encapsulamento

{{ACTUAL_DEPENDENCIES_CROSS_FEATURE_CONTRACTS_DOMAIN_ISOLATION}}

## Estado, erros e testes

{{ADOPTED_CONVENTIONS_REAL_TESTS_OR_ABSENCE}}

## Adicionar feature

{{SPECIFIC_STEPS_WITHOUT_EMPTY_LAYERS_OR_UNJUSTIFIED_ABSTRACTIONS}}
````

## Template core

Destino e uso: preencher este roteiro conforme o contrato dos cinco AGENTS.md.

````markdown
# Core — {{PACKAGE_NAME}}

## Infraestrutura atual

{{REAL_TECHNICAL_RESOURCES_CONTRACTS_PATHS_OR_ABSENCE}}

## Inicialização e reutilização

{{ACTUAL_DEPENDENCY_OWNERSHIP_LIFECYCLE_REUSE_OR_ABSENCE}}

## Alterações compartilhadas

{{CONTRACT_CHANGE_IMPACT_AND_PROJECT_VERIFICATION}}

## Limites

{{TECHNICAL_BOUNDARIES_AND_FEATURE_BUSINESS_RULE_EXCLUSIONS}}
````

## Template design-system

Destino e uso: preencher este roteiro conforme o contrato dos cinco AGENTS.md.

````markdown
# Design System — {{PACKAGE_NAME}}

## Padrões presentes

{{REAL_TOKENS_THEMES_COMPONENTS_PATHS_OR_ABSENCE}}

## Referências e reutilização

{{CONFIRMED_VISUAL_CONVENTIONS_REUSE_OR_ABSENCE}}

## Limites e dependências

{{ACTUAL_DEPENDENCIES_AND_DISTINCTION_FROM_FEATURE_WIDGETS}}

## Evolução e extração manual

{{PROJECT_EXTENSION_GUIDANCE_AND_EXTRACTION_CONSIDERATIONS}}
````

## Verificador incorporado

Código completo de check_package.py. Usar somente como helper temporário próprio, conforme a seção Distribuição autocontida para Claude. Não é código de funcionalidade do package.

````python
#!/usr/bin/env python3
"""Read-only structural checks; no YAML/Dart or architecture validation."""
import argparse
import json
import os
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


LAYERS = ("application", "features", "core", "design_system")
PLACEHOLDER = re.compile(r"\{\{\s*[A-Z][A-Z0-9_]*\s*\}\}")
DEFINITION = re.compile(r"^ {0,3}\[([^\]]+)\]:\s*(.*)$")


def visible_markdown(text):
    """Hide fenced/inline code and comments, preserving line breaks for diagnostics."""
    lines = []
    fence = None
    for line in text.splitlines(keepends=True):
        opening = re.match(r"^ {0,3}(`{3,}|~{3,})", line)
        if fence:
            closing = re.match(r"^ {0,3}(" + re.escape(fence[0]) + r"{" + str(fence[1]) + r",})\s*$", line)
            if closing:
                fence = None
            lines.append("\n" if line.endswith("\n") else "")
        elif opening:
            fence = (opening[1][0], len(opening[1]))
            lines.append("\n" if line.endswith("\n") else "")
        else:
            lines.append(line)
    text = "".join(lines)
    text = re.sub(r"<!--[\s\S]*?-->", "", text)
    return re.sub(r"(`+)([^`]*?)\1", "", text)


def destination(value):
    """Parse common Markdown destination, ignoring optional link title."""
    value = value.strip()
    if not value:
        return ""
    if value.startswith("<"):
        end = value.find(">")
        return value[1:end] if end >= 0 else None
    depth = 0
    result = []
    escaped = False
    for ch in value:
        if escaped:
            result.append(ch)
            escaped = False
        elif ch == "\\":
            escaped = True
        elif ch.isspace() and depth == 0:
            break
        else:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth < 0:
                    return None
            result.append(ch)
    if depth or escaped:
        return None
    return "".join(result)


def markdown_links(text):
    """Common inline/reference links, not a full CommonMark implementation."""
    text = visible_markdown(text)
    definitions = {}
    found = []
    warnings = []
    body = []
    for line in text.splitlines():
        match = DEFINITION.match(line)
        if match:
            label = " ".join(match[1].casefold().split())
            target = destination(match[2])
            if target is None or not match[2].strip():
                warnings.append("Destino de referência Markdown não reconhecido: " + match[1])
            else:
                definitions.setdefault(label, target)
                found.append(target)
            body.append("")
        else:
            body.append(line)
    text = "\n".join(body)
    # Handles images as links as well. Nested labels/multiline definitions are not complete CommonMark.
    label_pattern = re.compile(r"(?<!\\)\[([^\]\n]*)\]")
    position = 0
    while True:
        match = label_pattern.search(text, position)
        if not match:
            break
        end = match.end()
        if end < len(text) and text[end] == "(":
            cursor = end + 1
            depth = 1
            escaped = False
            angled = False
            while cursor < len(text):
                ch = text[cursor]
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == "<":
                    angled = True
                elif ch == ">":
                    angled = False
                elif not angled and ch == "(":
                    depth += 1
                elif not angled and ch == ")":
                    depth -= 1
                    if depth == 0:
                        break
                cursor += 1
            if depth:
                warnings.append("Link inline Markdown sem fechamento reconhecido: " + match[1])
                position = end + 1
                continue
            target = destination(text[end + 1:cursor])
            if target is None:
                warnings.append("Destino inline Markdown não reconhecido: " + match[1])
            else:
                found.append(target)
            position = cursor + 1
        elif end < len(text) and text[end] == "[":
            close = text.find("]", end + 1)
            if close < 0:
                warnings.append("Referência Markdown sem fechamento: " + match[1])
                position = end + 1
                continue
            label = text[end + 1:close] or match[1]
            key = " ".join(label.casefold().split())
            if key not in definitions:
                warnings.append("Referência Markdown não resolvida: " + label)
            position = close + 1
        else:
            # A known shortcut reference was already checked through its definition.
            position = end
    if re.search(r"<(?:a|img)\b", text, re.I):
        warnings.append("Links HTML não são validados; conferir manualmente.")
    return found, warnings


def check(root, package_name):
    items = []

    def add(level, code, path, message):
        items.append({"level": level, "code": code, "path": str(path), "message": message})

    def safe(path):
        resolved = path.resolve()
        if not resolved.is_relative_to(root):
            add("error", "outside_target", path.relative_to(root), "Caminho escapa do package; conteúdo não lido.")
            return False
        return True

    for relative in [Path("test")] + [Path("lib/src") / layer for layer in LAYERS]:
        path = root / relative
        if safe(path) and not path.is_dir():
            add("error", "missing_directory", relative, "Diretório obrigatório ausente.")

    docs = [Path("AGENTS.md")] + [Path("lib/src") / layer / "AGENTS.md" for layer in LAYERS]
    required = [Path("pubspec.yaml"), Path("lib") / (package_name + ".dart")] + docs
    contents = {}
    for relative in required:
        path = root / relative
        if not safe(path):
            continue
        if not path.is_file():
            add("error", "missing_file", relative, "Arquivo obrigatório ausente.")
            continue
        data = path.read_text(encoding="utf-8")
        contents[relative] = data
        if not data.strip():
            add("error", "empty_file", relative, "Arquivo obrigatório vazio.")
    for relative in docs:
        if relative not in contents:
            continue
        data = contents[relative]
        for match in sorted(set(PLACEHOLDER.findall(data))):
            add("error", "unresolved_placeholder", relative, "Campo de template não preenchido: " + match)
        links, warnings = markdown_links(data)
        for message in warnings:
            add("warning", "markdown_limit", relative, message)
        for target in sorted(set(links)):
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            decoded = unquote(parsed.path)
            if re.match(r"^[A-Za-z]:[\\/]", decoded) or "\\" in decoded:
                add("warning", "nonportable_link", relative, "Conferir caminho não portátil: " + target)
                continue
            linked = (root / relative.parent / decoded).resolve()
            if not linked.is_relative_to(root):
                add("error", "outside_link", relative, "Link local fora do package: " + target)
            elif not linked.exists():
                add("error", "broken_link", relative, "Destino local inexistente: " + target)

    expected = set(docs)
    for folder, directories, filenames in os.walk(root, followlinks=False):
        directories[:] = sorted(d for d in directories if d not in {".git", ".dart_tool", "build"} and not (Path(folder) / d).is_symlink())
        if "AGENTS.md" in filenames:
            relative = (Path(folder) / "AGENTS.md").relative_to(root)
            if relative not in expected:
                add("warning", "additional_agents", relative, "Documento adicional preservado; avaliar instruções aplicáveis.")
    return items


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-root", required=True, type=Path)
    parser.add_argument("--package-name", required=True)
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args(argv)
    items = []
    try:
        if sys.version_info < (3, 9):
            raise ValueError("Usar Python 3.9 ou posterior para este verificador.")
        if not re.fullmatch(r"[a-z][a-z0-9_]*", args.package_name):
            raise ValueError("Nome inválido: informar identificador de package em snake_case.")
        root = args.package_root.resolve(strict=True)
        if not root.is_dir():
            raise ValueError("O alvo deve ser um diretório existente.")
        items = check(root, args.package_name)
        code = 1 if any(item["level"] == "error" for item in items) else 0
    except (OSError, ValueError, RuntimeError, UnicodeError) as exc:
        items.append({"level": "error", "code": "invalid_environment", "path": str(args.package_root), "message": str(exc)})
        code = 2
    result = {"status": {0: "passed", 1: "failed", 2: "invalid"}[code], "exit_code": code,
              "scope": "structural_only", "items": items}
    if args.format == "json":
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print("Resultado estrutural: " + result["status"])
        for item in items:
            print(f'{item["level"]}: {item["path"]}: {item["message"]}')
        print("Não valida YAML/Dart, arquitetura, comportamento ou compatibilidade funcional.")
    return code


if __name__ == "__main__":
    sys.exit(main())
````
