---
name: task-creator-trabalho
description: >
  Criar tarefa e artefatos de contexto para trabalhos acadêmicos ou projetos
  quando Rafael pedir. Usar sempre que ele disser "cria uma tarefa para o
  trabalho de X", "tenho um trabalho novo", "me ajuda a registrar esse
  projeto", ou enviar um arquivo/briefing de trabalho da faculdade. Também
  usar quando ele disser explicitamente "é um trabalho" ao pedir para criar
  uma tarefa.
---

# Task Creator — Trabalhos e Projetos do Rafael

## Identidade do papel

Ao executar esta skill, você transforma um briefing bruto (arquivo, descrição
oral, PDF, etc.) em:

1. **Uma única tarefa** no Todoist (projeto correto, prazo correto)
2. **Um briefing estruturado** salvo em arquivo, pronto para guiar agentes ou
   o próprio Rafael quando for executar

---

## O que NÃO fazer

- ❌ Não criar projetos novos para o trabalho
- ❌ Não criar subtarefas ou "passo a passo" — Rafael divide isso ele mesmo
- ❌ Não perguntar detalhes que já estão no arquivo/briefing fornecido
- ❌ Não criar múltiplas tasks para o mesmo trabalho

---

## Passo a passo

### 1. Extrair informações do briefing

Leia o arquivo ou descrição fornecidos e extraia:

| Campo | Onde encontrar |
|-------|---------------|
| **Nome do trabalho** | Título do arquivo ou descrição |
| **Disciplina** | Cabeçalho, nome do professor, contexto |
| **Prazo de entrega** | Datas no arquivo; se não houver, Rafael colocará no título da task |
| **Datas de eventos** | Apresentações, reuniões de grupo, entregas parciais |
| **Objetivo** | O que deve ser produzido/entregue |
| **Tecnologias/restrições** | Linguagens, frameworks, regras impostas |
| **Contexto técnico** | Arquitetura esperada, padrões exigidos |

### 2. Criar a tarefa no Todoist

- **Projeto**: 🎓 Faculdade (sempre, para trabalhos acadêmicos)
- **Título**: `[NOME DO TRABALHO] — entrega: DD/MM` (se houver prazo)
  - Se Rafael já informou o prazo no título ao pedir → use exatamente como ele
    informou
  - Se não há prazo definido → título sem data, Rafael ajusta depois
- **Prioridade**: P2 por padrão (trabalhos acadêmicos têm peso)
- **Labels**: `faculdade` + tecnologia principal (ex: `flutter`, `nodejs`)
- **Data de vencimento**: data de entrega real, se existir no briefing
- **Descrição da task**: resumo em 3–5 linhas do que precisa ser feito

### 3. Registrar eventos no Google Calendar

Se o briefing contiver datas de:
- Apresentação → criar evento "Apresentação: [nome do trabalho]"
- Reunião de grupo → criar evento com título e participantes se informados
- Entrega parcial → criar evento "Entrega parcial: [nome]"
- Prazo final → criar evento "⚠️ Entrega: [nome do trabalho]"

Para cada evento: título claro, data correta, descrição resumida do contexto.

### 4. Criar o briefing estruturado

Salve um arquivo `.md` em `/mnt/user-data/outputs/` com o seguinte formato:

```markdown
# Briefing: [Nome do Trabalho]

## Contexto
- **Disciplina**: ...
- **Professor**: ...
- **Prazo de entrega**: ...
- **Equipe**: solo / dupla / grupo de X

## Objetivo
[O que deve ser produzido. Uma a três frases diretas.]

## Requisitos
[Lista dos requisitos funcionais e técnicos impostos pelo professor/enunciado.]

## Restrições Técnicas
[Linguagens, frameworks, padrões obrigatórios ou proibidos.]

## Arquitetura Esperada
[Se o briefing descrever uma arquitetura — componentes, fluxos, integrações.]

## Critérios de Avaliação
[O que será avaliado, se informado.]

## Datas Importantes
| Evento | Data |
|--------|------|
| ... | ... |

## Observações
[Qualquer informação relevante que não se encaixou acima.]
```

### 5. Apresentar resumo

Ao final, mostre ao Rafael:

```
✅ Tarefa criada: [título] — [projeto] — vence [data ou "sem data"]
📅 Eventos criados: [lista ou "nenhum"]
📄 Briefing: [link do arquivo]

⚠️ Atenção: [qualquer ambiguidade, dado faltante ou ponto que Rafael deve confirmar]
```

---

## Regras importantes

- Se o briefing não tiver prazo → crie a task sem data e sinalize no resumo
  que Rafael precisa definir.
- Se houver dúvida sobre a disciplina → use o que estiver mais explícito no
  arquivo. Não invente.
- O briefing deve ser autocontido: qualquer agente ou o Rafael em outra sessão
  deve conseguir entender o trabalho só lendo o arquivo.
- Escreva o briefing em português, de forma técnica mas direta.
