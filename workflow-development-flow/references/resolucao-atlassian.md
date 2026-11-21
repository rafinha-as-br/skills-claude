# Resolução de identidade Atlassian por produto

> Referência operacional compartilhada do Workflow Rafinha-Claude. Define como
> uma skill identifica o site, o recurso e o conector Atlassian corretos antes
> de uma leitura ou mutação. Não concede autoridade de Jira, Confluence, Git
> ou produto, nem substitui o cadastro normativo **Controle de workflow por
> produto**.

## Cadastro e fontes

Cada produto que usa o Workflow possui um site Atlassian **próprio e
explicitamente declarado**. Um site (`https://<site>.atlassian.net`) pode ter
vários projetos Jira e espaços Confluence; não é sinônimo de projeto, espaço ou
nome de conector.

O cadastro normativo global é a página **Controle de workflow por produto** no
Confluence. Ela declara, para cada produto: URL do site; cada projeto Jira
(nome, chave e URL); cada espaço Confluence (nome, chave, URL e finalidade); e
a página inicial oficial. O `AGENTS.md` principal apenas disponibiliza esse
mapa para a execução local, com a mesma proveniência; ele não se torna um
segundo cadastro normativo.

Dados ausentes, URLs antigas ou divergência entre o AGENTS e o cadastro não são
autorização para deduzir domínio, chave, espaço, conector ou fallback.

## Procedimento obrigatório

Antes de qualquer operação Atlassian autorizada:

1. Identifique o produto e localize o seu `AGENTS.md` principal (raiz do
   monorepo ou do Workspace multi-repo).
2. Leia a URL do site e o projeto Jira ou espaço Confluence exigido pela
   operação. Consulte o cadastro normativo para confirmar ou resolver conflito.
3. Descubra os conectores disponíveis no executor atual e selecione somente um
   candidato que declare ou permita verificar acesso ao site informado.
4. Valide a identidade retornada pelo provedor, quando houver (URL/base URL,
   cloud/site ID, projeto ou espaço). O nome de uma ferramenta MCP não prova
   que ela aponta para o site correto.
5. Valide que o recurso solicitado existe naquele site e que a permissão é
   suficiente para a operação específica. Só então leia ou execute a mutação
   que já esteja autorizada pelo contrato da skill.

Registre no resultado operacional o site e recurso validados sem expor tokens,
credenciais ou identificadores sensíveis. A validação de destino não substitui
claim, escopo fechado, gate ou autoridade de mutação.

## Falhas e granularidade

| Situação | Tratamento |
|---|---|
| Produto, site ou recurso não declarado | Informação insuficiente: bloqueie somente a operação dependente e registre o incidente aplicável. |
| Conflito entre AGENTS e cadastro normativo | Conflito de autoridade: não escolha nem altere a fonte durante a operação; encaminhe a Rafinha. |
| Conector correspondente ausente ou sem acesso | Capacidade ausente: bloqueie a operação; não use outro site como fallback. |
| Projeto/espaço não encontrado no site validado | Informação ou configuração insuficiente: bloqueie a operação dependente e reporte a evidência. |
| Leitura permitida, escrita negada | Leitura pode continuar se for suficiente; a mutação fica bloqueada. |
| Site validado, mas a skill não possui autoridade | Não execute a mutação; a capacidade técnica não amplia o contrato. |

Nunca escolha o primeiro conector/site disponível, derive domínio pela chave
Jira, crie URL por convenção, crie site, migre dados ou use outro produto como
fallback. Projetos legados sem AGENTS continuam possíveis quando as fontes
oficiais bastarem; a ausência do arquivo não cria gate.

## Consumo pelas skills

Toda skill que usa Jira ou Confluence herda este procedimento pelo Contrato do
Workflow. A skill o referencia no ponto de consumo quando precisa de um
lembrete específico; não copia o algoritmo. A `engineering-context-manager`
mantém o mapa local de forma determinística. A `workflow-doc-writer` mantém a
documentação do próprio workflow; nenhuma das duas cria, migra ou reconfigura
sites/conectores.
