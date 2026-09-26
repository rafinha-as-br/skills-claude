---
name: flutter-development-standards
description: "Padrões de arquitetura e boas práticas de Flutter/Dart de Rafinha, consolidados a partir da análise real de uma feature em produção (travel_matrix, do Compass System) combinada com boas práticas gerais. Usar sempre que Rafinha estiver escrevendo, revisando ou planejando código Flutter/Dart em qualquer um dos seus projetos (Compass System, F1 App Design Patterns, InfraCheck, Cluster Playground, Encryption Playground, ou qualquer novo projeto Flutter), incluindo pedidos como \"revisa esse código\", \"isso está de acordo com nossos padrões?\", \"cria um Controller/Widget/Repository para X\", ou qualquer implementação nova de camada, widget, estado ou modelo em Flutter. Inclui a seção 14, sobre componentes reutilizáveis e IDs canônicos do Design System (`<sigla>.<tipo>.<subtipo>`): reutilizar componente existente antes de criar, nunca recriar o que já existe, reportar divergência quando o design cita um ID que não está no código, tratar `candidate` como componente não-oficial, e documentar componente novo com o mesmo ID usado no Claude Design e no Confluence. Esta skill é um checklist de qualidade, não um gerador de boilerplate — aplique as regras ao avaliar ou escrever código, não apenas cite-as."
---

# Padrões de Desenvolvimento Flutter — Rafinha

## Como usar esta skill

Esta skill é um **checklist vivo de arquitetura e boas práticas**, não uma
lista de trivia para recitar. Ao escrever, revisar ou planejar qualquer
código Flutter/Dart neste contexto:

1. **Ao gerar código novo**: aplique as regras relevantes diretamente na
   implementação — não escreva código e só depois mencione o que poderia
   melhorar; já entregue seguindo o padrão.
2. **Ao revisar código existente**: percorra as seções abaixo e aponte
   explicitamente quais regras estão sendo violadas, citando a regra e o
   trecho do código, e proponha a correção concreta.
3. **Ao decidir arquitetura**: use as seções 1 e 3 como referência de
   camadas e fluxo de dados antes de propor qualquer estrutura nova.
4. Se uma regra conflitar com uma decisão explícita que Rafinha já tomou
   para aquele projeto específico, aponte o conflito antes de aplicar a
   regra cegamente — essas regras são o padrão-base, não algo hard-coded
   sem exceção.
5. **A seção 9 (Testes) é gate bloqueante, não recomendação.** Para issues
   de código, o Workflow Rafinha-Claude (`workflow-development-flow`) trata
   a ausência de teste correspondente ao comportamento alterado como
   bloqueio de avanço na etapa `Fazer - Claude` — não é mais um "se fizer
   sentido". Ao gerar ou revisar código, trate as regras da seção 9 com o
   mesmo peso das demais: código sem o teste correspondente não está
   pronto.

---

## 1. Arquitetura & Camadas

- **Caminho único de leitura/escrita**: toda operação que persiste ou busca
  dado passa por `UseCase → Repository (interface) → RepositoryImpl →
  DataSource`. Widget ou Controller nunca chama Service/HTTP diretamente.
- **Contrato de erro único** em toda a stack (`Result<T>` / `Either<Failure,
  T>`). Nunca misturar com `Map` cru + `try/catch` solto no meio do caminho.
- **Camadas não voltam**: `domain` nunca importa `presentation` nem `data`;
  `data` nunca importa `presentation`. Um import que "sobe" a camada é sinal
  de vazamento de responsabilidade.
- **Domain livre de Flutter**: nada de `IconData`, `Color`, `BuildContext`
  dentro de `domain/entities`. Detalhe de UI pertence ao ViewModel.
- **DTO ≠ Entity ≠ ViewModel**, sempre com mapeadores explícitos (`fromJson`,
  `toDomain`, `fromDomain`, `toJson`). Nunca serializar a entidade de domínio
  direto pra API, nem bindar DTO direto num widget.
- **Validar invariantes no construtor** de modelos agregados (`ArgumentError`
  / `assert` se o estado não pode existir), em vez de deixar o objeto nascer
  inválido e checar depois espalhado pela UI.
- **DI explícita e local ao escopo** (`MultiProvider`/`ProxyProvider` no topo
  da página, ou um repositório de DI simples) é aceitável para apps
  pequenos/médios — mas não duplique a mesma árvore de providers em várias
  páginas; extraia um builder/factory compartilhado quando o mesmo conjunto
  de providers aparecer 2+ vezes.

## 2. Widgets

- Todo widget de exibição é **"burro"**: `StatelessWidget` que recebe um
  ViewModel/BuildModel pronto + callbacks (`VoidCallback`,
  `ValueChanged<T>`). Nenhuma regra de negócio, chamada de rede ou cálculo
  pesado dentro de `build()`.
- `StatefulWidget` só para **estado efêmero de UI** (`TextEditingController`,
  `AnimationController`, foco, scroll, "campo tocado"). Estado de
  domínio/negócio nunca mora em `State`.
- `const` no construtor sempre que possível.
- `Key` em itens de lista reordenável/dinâmica (`ValueKey(item.id)`), nunca
  confiar só no índice.
- Nunca `onPressed: (){}` vazio para "desabilitar" um botão — usar
  `onPressed: null` ou trocar o widget.
- **Composição em vez de herança**: widgets pequenos combinados em vez de
  `class MeuWidget extends OutroWidget`. Extrair um widget privado (`_Foo`)
  quando um `build()` passar de ~80–100 linhas ou tiver mais de 2
  responsabilidades visuais.
- Extrair mixin/widget base para padrões repetidos de formulário (controller
  + `didUpdateWidget` de sincronização + `dispose` + validação local) em vez
  de reimplementar o mesmo boilerplate em cada `*FormWidget`.
- `RepaintBoundary`/`const`/`Selector` (ou `context.select`) para isolar
  rebuilds em árvores grandes — evitar que um `context.watch<Controller>()`
  no topo da página force rebuild de subárvores que não mudaram.

## 3. Gerenciamento de estado (Provider/ChangeNotifier ou equivalente)

- **Controller = orquestração + estado, não widget builder**: métodos do
  controller retornam dados/booleans de sucesso (`bool deleteStep(...)`) e o
  widget decide como reagir (SnackBar, dialog) — o controller nunca
  manipula `BuildContext`.
- `notifyListeners()` **uma vez por operação lógica**, não uma vez por campo
  alterado — agrupar mutações relacionadas antes de notificar.
- Sempre `dispose()` o que foi criado no controller/state
  (`TextEditingController`, `AnimationController`, `StreamSubscription`,
  `ChangeNotifier` próprio).
- Estado de tela como **objeto único e imutável**
  (`TravelViewState { isLoading, data, errorMessage }`) em vez de múltiplas
  flags booleanas soltas que podem ficar inconsistentes entre si.
- Nunca guardar `BuildContext` em campo de controller, nem usá-lo após um
  `await` sem checar `context.mounted`.

## 4. Modelagem de dados / imutabilidade

- Toda entidade/ViewModel **imutável com `copyWith`** — nunca expor setters
  públicos ou listas mutáveis diretamente (`List.unmodifiable` ou copiar
  antes de expor).
- **IDs locais desacoplados do backend** (`localId` via uuid vs.
  `backEndId` nulo até persistir) para fluxos de criação/edição otimista.
- Preferir **sealed classes + pattern matching (Dart 3)** para hierarquias
  fechadas de tipos, em vez de `is`/`as` espalhados — o compilador garante
  exaustividade quando um novo tipo é adicionado.
- Sobrescrever `==`/`hashCode` (ou usar `Equatable`/`freezed`) em
  ViewModels/Entities usados em comparações ou `Set`/`Map`.
- Quando o boilerplate entre Entity/DTO/ViewModel for idêntico, considerar
  `freezed`/`json_serializable` para gerar `copyWith`/`toJson`/igualdade
  automaticamente.

## 5. Async, erros e efeitos colaterais

- Sempre tratar os 3 estados de uma operação assíncrona: **loading, sucesso,
  erro** — nunca deixar um `Future` "solto" sem estado de carregamento
  visível ao usuário.
- Nunca fazer chamada de rede direto dentro de um widget (`build()` ou
  callback de widget) — sempre via controller/usecase.
- Cancelar/ignorar respostas de requisições obsoletas quando o usuário pode
  disparar múltiplas ações rápidas (debounce em busca, ou checar se o
  request ainda é o mais recente antes de aplicar o resultado).
- Nunca engolir exceção silenciosamente (`catch (e) {}` vazio) — sempre
  logar, propagar como `Result.failure`, ou re-lançar.
- Timeouts e mensagens de erro amigáveis para toda chamada de rede — nunca
  expor stack trace/exception bruta na UI final.

## 6. Formulários & validação

- Centralizar regras de validação reutilizáveis (obrigatório, formato de
  data, e-mail) em validators compartilhados, não reescrever
  `_validateRequiredField` em cada formulário.
- Usar `Form`/`FormFieldState`/`GlobalKey<FormState>` do próprio Flutter
  quando fizer sentido, em vez de reinventar validação campo a campo.
- Feedback de validação só depois que o campo foi "tocado" (`isTouched`) —
  nunca mostrar erro antes da interação do usuário.
- Confirmar antes de qualquer ação destrutiva/irreversível na UI (trocar
  tipo de item perdendo dados, deletar).

## 7. Navegação

- Evitar trafegar objetos complexos por `router.extra` para dados que
  precisam sobreviver a refresh/deep link (especialmente em Flutter Web) —
  preferir IDs na URL + cache/repositório que resolve o objeto.
- Rotas nomeadas centralizadas (`AppRoutes.xxx`), nunca strings de path
  soltas espalhadas pelo código.

## 8. Performance

- `ListView.builder`/`ReorderableListView.builder` para listas, nunca
  `ListView(children: [...])` com lista grande/dinâmica materializada
  inteira.
- Evitar `Container` só para decoração quando `DecoratedBox` resolve; evitar
  `Opacity`/`ClipRRect` desnecessários em árvores grandes.
- Medir antes de otimizar: usar o DevTools (Performance/Widget Rebuild)
  antes de decidir extrair `const`/`RepaintBoundary` em pontos que "parecem"
  custosos.

## 9. Testes

- Todo usecase puro (sem Flutter) tem **teste unitário obrigatório** antes
  de a feature ser considerada pronta.
- ViewModels com lógica de mapeamento (`fromDomain`/`toDomain`) têm teste de
  round-trip garantindo que os dados não se perdem na ida e volta.
- Widget tests para os fluxos críticos (criar/editar, salvar, erro de rede)
  usando `mocktail`/`mockito` para os controllers, não integração real com
  API.
- Nenhuma feature nova entra sem pelo menos um teste.

## 10. Comentários & legibilidade

- `///` doc comments em toda classe/método público, só quando agregam o
  "porquê" — proibido comentário que apenas repete o nome
  (`/// Gets the name` acima de `get name`).
- Nunca deixar código comentado morto no repositório — se uma regra foi
  desativada, remover o código e registrar o motivo no commit/PR ou numa
  issue.
- `TODO` sempre com contexto ou referência de issue
  (`// TODO(RAFAEL-123): ...)`), nunca solto sem rastreabilidade.
- Nenhum comentário órfão (doc comment sobrando de um método removido).

## 11. Nomenclatura & organização de arquivos

- Sufixo consistente por papel (`*ViewModel`, `*DTO`, `*Controller`,
  `*BuildModel`, `*Panel`, `*Card`, `*FormWidget`).
- Um widget público por arquivo; widgets privados auxiliares (`_Foo`) podem
  conviver no mesmo arquivo do widget pai que os usa exclusivamente.
- Organizar `presentation` por fluxo quando o app tiver "criar/editar" vs.
  "visualizar" bem distintos (`build/` vs `view/`), mantendo nomes de
  arquivo espelhados entre as duas árvores.

## 12. Lint, análise estática & segurança

- `analysis_options.yaml` com lint set rígido (`flutter_lints` no mínimo,
  idealmente `very_good_analysis`) e zero warnings tolerados no CI.
- Nunca logar token/senha/dado sensível, nem em `print`/`debugPrint`
  esquecido em produção.
- Strings visíveis ao usuário sempre via i18n (`.arb`/l10n), nunca
  hardcoded no widget, para todo texto que não seja puramente
  técnico/interno.
- Nenhum "número mágico"/string mágica repetida — extrair para constante
  nomeada (padrão já usado em `ItineraryStepApiFields`/
  `ItineraryStepApiValues`).

## 13. Acessibilidade

- Área de toque mínima de 48x48 em botões de ícone customizados.
- `Semantics`/tooltip em ícones sem texto (botões só com ícone precisam de
  tooltip ou `Semantics.label`).
- Contraste de cor suficiente em estados de erro/aviso, validado contra
  WCAG AA — não apenas esteticamente.

---

## 14. Componentes reutilizáveis & IDs canônicos do Design System

O Claude Design e o Claude Code **não têm integração automática**. A ponte
entre os dois é um contrato textual: o **ID canônico**.

```text
<sigla>.<tipo-do-componente>.<subtipo-do-componente>
```

A **sigla** vem da página de *Controle de workflow por produto* no Confluence
(espaço CS1). Ela é definida **manualmente** — nunca infira uma sigla a
partir do nome do produto, do repositório ou da chave do Jira.

### Reutilizar antes de criar

Antes de escrever um widget novo que pareça genérico (botão, input, card,
dialog, chip, badge, empty state…), verifique se já existe um componente
reutilizável para aquilo:

1. procure no catálogo de componentes reutilizáveis do produto, no Confluence;
2. procure no próprio código, na pasta de widgets compartilhados;
3. se o design referencia um ID canônico, **use o componente daquele ID**.

**Criar um componente que já existe é violação desta seção**, mesmo que o
novo esteja bem escrito. Duplicata de componente é dívida visual: as duas
versões divergem com o tempo e a tela fica inconsistente sem ninguém notar.

### Quando o ID não existe no código

Se o design referencia `<sigla>.<tipo>.<subtipo>` e esse componente **não
existe** no código nem no catálogo:

> **Reporte a divergência. Não crie o componente silenciosamente.**

Criar por conta própria produz um componente que ninguém documentou, com nome
que ninguém acordou, e que o próximo design não vai encontrar.

### Componentes candidatos

ID no padrão `<sigla>.candidate.<nome>` marca um componente **ainda não
oficial**. Ele:

- **não** é componente reutilizável oficial;
- **não** deve ser tratado como parte estável do Design System;
- só vira oficial depois de aprovação, implementação e entrada no catálogo.

### Documentar o componente novo

Quando um componente reutilizável **novo** for de fato criado, ele precisa
nascer documentado com o **mesmo ID canônico** usado no Claude Design e no
Confluence:

```dart
/// Design System ID: gp.button.primary
///
/// Ação principal de uma tela ou formulário.
/// Quando não usar: ação secundária ou destrutiva; item de lista.
class AppPrimaryButton extends StatelessWidget {
```

O mesmo ID precisa valer nos três lugares — Claude Design, Confluence e
código. Divergência entre eles é defeito de documentação, não detalhe.

O docstring é a parte do código; a entrada no catálogo do Confluence é
escrita pela `tech-doc-writer`, trilha `component-doc` (template
`componente-reutilizavel.md`). Quem cria o componente registra o ID no
docstring e sinaliza a entrada nova — não escreve o catálogo por conta
própria.

### Checklist desta seção

- [ ] Procurei componente existente antes de criar um novo?
- [ ] Se o design cita um ID canônico, usei o componente correspondente?
- [ ] Se o ID não existe, reportei em vez de criar?
- [ ] Tratei `candidate` como não-oficial?
- [ ] Componente novo nasceu com o ID canônico no docstring?

---

## Ao revisar código (formato de saída)

Ao aplicar esta skill como revisão, estruture o retorno por seção violada,
não por arquivo, por exemplo:

```
🏗️ Arquitetura & Camadas
  - [arquivo:linha] Controller chamando Service direto, pulando Repository. Regra: seção 1.

🧩 Widgets
  - [arquivo:linha] build() com 140 linhas e 3 responsabilidades visuais. Regra: seção 2.

✅ Sem violações: Testes, Nomenclatura
```

Só cite seções realmente relevantes ao código em questão — não force
menção às 14 seções se boa parte não se aplica ao trecho revisado.
