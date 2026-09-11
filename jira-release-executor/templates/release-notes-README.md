# Notas de release

Um arquivo por componente e versão, no formato:

```
.github/release-notes/<componente>-<versao>.md
```

Exemplo: `.github/release-notes/routecraft_app-1.1.0.md`

O `release.yml` procura esse arquivo ao criar a GitHub Release e o usa
como corpo (`gh release create --notes-file`). Se não encontrar, cai no
`--generate-notes` automático do GitHub — que produz a lista de Pull
Requests mergeados. Isso mantém o dispatch manual funcionando sem o
Claude no circuito, mas com notas bem piores.

O nome inclui a versão de propósito: sem isso, um arquivo esquecido de
uma release anterior seria usado na seguinte.

## Como escrever

Quem normalmente escreve esses arquivos é a skill `jira-release-executor`,
a partir do campo `Resumo` das issues incluídas na release. O commit
acontece antes do dispatch, para que o arquivo esteja presente no código
que a Action vai buildar.

**O texto é para qualquer pessoa ler** — inclusive quem não acompanhou a
sprint, não sabe o que é CPS-107 e não vai abrir Pull Request nenhum.

- Descreva o que mudou **do ponto de vista de quem usa o sistema**, não do
  ponto de vista do código.
- Não liste issues ou PRs como se fossem o conteúdo. Se citar uma issue,
  que seja no fim, como referência — nunca no lugar da explicação.
- Agrupe por tema, não por issue. Três issues que juntas melhoraram o
  cadastro de roteiro viram um parágrafo sobre cadastro de roteiro.
- Nada de mensagem de commit, nome de branch, nome de arquivo ou termo
  interno que só faça sentido para quem desenvolveu.

## Exemplo do tom esperado

```markdown
## Novidades

O cadastro de roteiro agora mostra o itinerário completo enquanto você
monta a viagem, em vez de só ao final. Dá para voltar e ajustar qualquer
dia sem perder o que já foi preenchido.

A tela inicial passou a exibir as estatísticas da sua conta — total de
viagens, quantas estão em andamento e quantas já foram concluídas.

## Correções

Viagens abertas sem conexão deixaram de aparecer vazias: o app agora usa
a última versão que tinha salva e avisa que está mostrando dados offline.

O campo de telefone parou de recusar números válidos com DDD de duas
casas.

---
Issues: CPS-98, CPS-107, CPS-119
```
