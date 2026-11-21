# Convenção de `AGENTS.md`

> Referência operacional compartilhada do Workflow Rafinha-Claude. Define como localizar, interpretar e manter instruções locais para agentes; não cria fonte de autoridade paralela ao Confluence, Jira, contratos, Código ou Git.

## Finalidade e autoridade

`AGENTS.md` contém instruções duráveis de atuação que ajudam o agente a operar com segurança numa área técnica: responsabilidades, invariantes não óbvios, comandos de verificação e limites locais. O arquivo principal também apresenta a identidade do produto e o mapa local da infraestrutura Atlassian já declarada. Ele **não** é especificação de produto, histórico, registro de execução nem banco de contexto.

Sua informação é subordinada à ordem de autoridade do Contrato do Workflow: Confluence e contratos vigentes, Jira, Código, Git/GitHub, Workspace, `context/` e AI Memory continuam sendo as fontes aplicáveis. Um `AGENTS.md` não pode criar gate, mudar transição, ampliar escopo, conceder permissão Git/Jira, dispensar evidência nem decidir regra de negócio ou arquitetura aberta.

## Níveis e critérios de criação

```text
Workspace (multi-repo, se existir)
└── repositório componente
    └── módulo ou diretório de fronteira técnica
```

| Nível | Conteúdo permitido | Criar quando |
|---|---|---|
| Workspace | produto, topologia, mapa de repositórios, composição, integrações transversais e fontes oficiais | há produto multi-repo com instruções que atravessam componentes |
| Repositório | responsabilidade técnica, arquitetura local, padrões, limites, dependências, verificações e documentos relevantes | há instruções estáveis que se aplicam ao repositório como um todo |
| Módulo | responsabilidade local, invariantes, dependências e pontos de atenção específicos | a regra é materialmente diferente da raiz e evita redescoberta ou erro relevante |

Ausência de qualquer nível é válida e **não cria gate**. Nunca criar arquivo para completar uma árvore, duplicar conteúdo superior ou registrar informação que o código, `context/`, Jira ou Confluence já expressam melhor. Remova o arquivo quando sua área deixa de ter regras locais materiais; atualize a camada superior quando a regra se tornar transversal.

Todo produto novo configurado para o Workflow possui um AGENTS principal: raiz do
monorepo ou raiz do Workspace oficial em topologia multi-repo. Produto legado sem
arquivo não é bloqueado quando as fontes oficiais são suficientes; registre a
adequação como pendência, sem migração automática.

## Herança e instruções conflitantes

Para cada caminho que será lido ou alterado, identifique somente os `AGENTS.md` ancestrais aplicáveis: Workspace, raiz do repositório e diretórios entre ela e o caminho. Não presuma que iniciar o executor na raiz carregará automaticamente instruções de módulo.

Uma instrução mais próxima pode **especializar ou restringir** uma instrução mais ampla apenas quando as duas forem compatíveis. Ela nunca a revoga por ser mais próxima. Esta é a regra explícita de conflito:

1. Conflito com Confluence, contrato, Jira, escopo fechado, Código ou Git: a fonte autoritativa prevalece. Não siga a instrução conflitante, não a corrija durante a execução da issue e reporte o conflito à autoridade competente.
2. Conflito material entre Workspace, repositório e módulo sem fonte que o resolva: **não há precedência implícita**. Pare apenas a ação afetada, preserve o escopo e peça decisão a Rafinha; a `engineering-context-manager` pode avaliar a manutenção documental depois da decisão.
3. Regra local compatível e mais específica: aplique-a só aos caminhos sob sua árvore. O nível superior continua valendo no restante do produto.
4. Texto ambíguo, obsoleto ou sem evidência de aplicabilidade é informação insuficiente, não autorização para inventar interpretação.

O conflito deve registrar os três elementos: arquivos/instruções envolvidos, caminho afetado e fonte de autoridade consultada. Preparação, implementação e revisão usam a sua classificação contratual existente; esta regra não cria transição ou gate novo.

## Estrutura obrigatória do AGENTS principal

O arquivo principal usa o marcador estável `<!-- rafinha-workflow-agents: v1 -->`
e estas seis seções, nesta ordem. Os rótulos de campos em negrito são a
representação mínima estável; só a `engineering-context-manager` muda o esquema
em evolução contratual aprovada.

```markdown
<!-- rafinha-workflow-agents: v1 -->
# <Nome oficial do produto>

## 1. Identidade do projeto
- **Nome oficial:** <nome>
- **Identificador oficial:** <sigla ou “não declarado”>
- **Descrição:** <descrição objetiva>
- **Problema resolvido:** <problema confirmado>
- **Usuários e atores:** <público e atores>
- **Capacidades principais:** <lista concisa>
- **Conceitos de domínio:** <termos relevantes>

## 2. Infraestrutura Atlassian
- **Site Atlassian oficial:** <https://site.atlassian.net>
- **Configuração MCP lógica (opcional):** <identificador, se declarado>
- **Projetos Jira:**
  - **Nome:** <nome> | **Chave:** <chave> | **URL:** <URL>
- **Espaços Confluence:**
  - **Nome:** <nome> | **Chave:** <chave> | **URL:** <URL> | **Finalidade:** <finalidade>
- **Início da documentação oficial:** <URL>
- **Cadastro normativo do produto:** <URL para Controle de workflow por produto>

## 3. Arquitetura e repositórios
- **Topologia:** <monorepo|multi-repo>
- **Workspace:** <caminho ou “não aplicável”>
- **Componentes:** <repositório, responsabilidade e tecnologia>
- **Integrações, dependências e fronteiras:** <somente o necessário>

## 4. Estratégias específicas do produto
- <diretriz arquitetural, estratégia, limitação ou referência aprovada>

## 5. Fontes de verdade
- **Regras e requisitos:** <fonte normativa>
- **Arquitetura, documentação técnica e APIs:** <fontes>
- **Contexto de engenharia:** <context/ ou referência>
- **Instruções locais:** <AGENTS de repositório/módulo aplicável>

## 6. Orientações para agentes
- <como localizar instruções e fronteiras; como agir sem informação ou em conflito>
```

O template comporta múltiplos projetos Jira e espaços Confluence. O nome local
de conector é apenas uma dica lógica opcional, nunca identidade universal do
site. Não inclua credenciais, tokens, senhas, dados pessoais desnecessários,
histórico de execução ou cópia extensa de documentação normativa. Para
resolver um conector, aplique `resolucao-atlassian.md`; nunca presuma que
produtos compartilham o mesmo site.

## Conteúdo e templates concisos

Use só seções com conteúdo real. Links devem apontar para a fonte adequada, não copiar seu conteúdo.

### Workspace

```markdown
# Instruções do Workspace

## Produto e topologia
- <produto e composição confirmados>

## Repositórios
- `<repo>/`: <responsabilidade>

## Integrações e fontes oficiais
- <fonte e quando consultá-la>

## Restrições transversais
- <invariante ou limite não óbvio>
```

### Repositório

```markdown
# Instruções do repositório

## Responsabilidade e fronteiras
- <responsabilidade confirmada>

## Convenções e verificações
- <padrão ou comando relevante>

## Dependências e documentos
- <dependência ou referência, quando relevante>
```

### Módulo

```markdown
# Instruções do módulo

## Responsabilidade local
- <fronteira confirmada>

## Invariantes e pontos de atenção
- <regra local que não pode ser inferida facilmente>
```

## Relação com `CLAUDE.md`, `context/` e `ai-memory/`

Para Codex, `AGENTS.md` é a instrução local. Claude Code também o suporta, mas a configuração e a presença de `CLAUDE.md` podem alterar o carregamento. Quando for necessária compatibilidade explícita com Claude Code, um `CLAUDE.md` vizinho pode importar `@AGENTS.md`; em Windows, prefira esse import a symlink. Não crie nem altere adaptadores `CLAUDE.md` por padrão: avalie a versão, a configuração e as instruções existentes do projeto.

`context/` preserva conhecimento técnico atual e durável; `ai-memory/`, continuidade e handoff. `AGENTS.md` pode encaminhar para ambos quando relevante, mas não os duplica nem os substitui.

## Consumo, delegação e manutenção

O agente principal resolve as instruções aplicáveis antes de uma alteração e reavalia quando passar a tocar um novo módulo. Ao delegar, envia: escopo fechado, caminhos autorizados, lista dos `AGENTS.md` aplicáveis, referências necessárias e a proibição de ampliar escopo ou tratar uma instrução local como autoridade superior. O subagente devolve conflito ou lacuna; não a resolve por conta própria.

A `engineering-context-manager` governa a mutação de `AGENTS.md`: avalia materialidade, cria, atualiza, reorganiza ou remove os arquivos. Ela compara as fontes autoritativas, preserva as seções e campos do arquivo principal e só sincroniza divergência determinística. Ela não decide arquitetura, não toca em `context/` sem necessidade e não recebe autoridade de Git. Quem já possui a autoridade Git da operação pode incluir a mudança no commit; os demais apenas a deixam na working tree e reportam.

Não há migração retroativa: projetos legados continuam válidos sem `AGENTS.md`. A adoção ocorre sob demanda, em mudança autorizada e com conteúdo confirmado.
