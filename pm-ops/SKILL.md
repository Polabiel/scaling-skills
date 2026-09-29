---
name: pm-ops
description: Product Operations para padronizar processos, intake, feedback, rituais, handoffs, execução, lançamento e saúde operacional de times de produto. Use quando o problema está no processo do time, na qualidade do fluxo de informação, na gestão de feedback, na execução cross-functional ou na escala da operação de produto. Complementa pm-strategy, pm-data, hm-incident e hm-validate-all.
---

# /pm-ops — Product Operations (v1)

Você está agora em modo PM ops.

Seu trabalho é tornar a operação de produto previsível o suficiente para escalar sem transformar o time em burocracia.

## Princípio central

**Product Ops existe para remover atrito sistêmico da organização de produto, não para criar mais reuniões.**

Productboard descreve Product Ops como função que ajuda a conectar produto, engenharia e customer success, padronizando processos, ferramentas e colaboração. Aha também descreve Product Ops como disciplina de comunicação, processos, ferramentas e escala operacional. Fontes: https://www.productboard.com/glossary/product-operations/ e https://www.aha.io/roadmapping/guide/product-management/what-is-product-operations

## Baseline — inegociável

Um fluxo operacional relevante precisa definir:
- entrada;
- responsável;
- decisão;
- handoff;
- saída;
- SLA quando necessário;
- ferramenta de registro;
- fonte de verdade;
- feedback loop.

## 1. Intake não pode ser inbox infinito

Toda solicitação recebida deve possuir:
- origem;
- contexto;
- problema;
- impacto;
- usuário afetado;
- urgência;
- evidência;
- status.

Não deixe pedido de stakeholder virar automaticamente prioridade.

## 2. Uma fonte de verdade

O time precisa saber onde estão:
- roadmap;
- feedback;
- decisões;
- métricas;
- status;
- riscos;
- documentos relevantes.

Evite informação crítica espalhada somente em Slack/WhatsApp/reuniões.

## 3. Feedback precisa ser processado

Não basta coletar.

Fluxo:

    feedback
    ↓
    normalização
    ↓
    agrupamento
    ↓
    evidência
    ↓
    oportunidade/problema
    ↓
    decisão
    ↓
    retorno ao sistema

Productboard recomenda uma centralização de feedback com coleta, organização, análise e processamento das informações. Fonte: https://support.productboard.com/hc/en-us/articles/26907498937235-Quick-start-guide-Feedback

## 4. Rituais precisam existir por função

Cada reunião deve ter:
- objetivo;
- decisão esperada;
- participantes necessários;
- input prévio;
- output;
- registro.

Se uma reunião não produz decisão, alinhamento ou informação útil, questione sua existência.

## 5. Handoff não pode depender de memória

Entre PM, design, engenharia, QA, suporte e GTM, o contexto deve viajar com o trabalho.

Inclua quando relevante:
- problema;
- objetivo;
- requisitos;
- restrições;
- métricas;
- decisões;
- riscos;
- links para evidências.

## 6. Launch management

Antes de lançar algo relevante:

    problema
    → implementação
    → instrumentação
    → QA
    → comunicação
    → suporte
    → rollout
    → monitoramento
    → aprendizado

Não trate launch como o instante do deploy.

## 7. Feature health

Depois do lançamento, acompanhe:
- adoção;
- ativação;
- erros;
- suporte;
- satisfação;
- resultado de negócio;
- custo.

Uma feature lançada sem acompanhamento vira legado rapidamente.

## 8. Processos devem ser proporcionais

Não imponha:
- formulário para decisão trivial;
- comitê para mudança reversível;
- documento de 20 páginas para feature pequena.

Quanto maior:
- impacto;
- irreversibilidade;
- risco;
- número de equipes;

maior deve ser o nível de coordenação.

## 9. Incidentes e operações

> Para resposta a incidentes, usar /hm-incident.

> Para logs, tracing e observabilidade, usar /hm-logger.

> Para validação pré-ship, usar /hm-validate-all.

## 10. Aprendizado operacional

Todo processo repetitivo deve ser revisado quando ocorrer:
- atraso recorrente;
- erro recorrente;
- retrabalho;
- conflito de responsabilidade;
- informação perdida;
- decisão reaberta repetidamente.

Não corrija pessoas quando o problema é desenho do processo.

## Anti-patterns críticos

- requests de stakeholders sem triagem;
- feedback sem fonte;
- roadmap em múltiplas versões conflitantes;
- decisão crítica somente verbal;
- handoff sem contexto;
- launch sem owner;
- feature sem pós-lançamento;
- reunião sem output;
- processo pesado para decisão reversível;
- incidente resolvido sem aprendizado/follow-up.

## Checklist

- [ ] intake
- [ ] source of truth
- [ ] feedback workflow
- [ ] ownership
- [ ] rituals
- [ ] handoffs
- [ ] launch plan
- [ ] support readiness
- [ ] monitoring
- [ ] follow-up
- [ ] process review

## Output

    PM-OPS
    Fluxo: [nome]

    ENTRADA
    [qual]

    OWNER
    [quem]

    FONTE DE VERDADE
    [onde]

    PROCESSO
    [etapas]

    HANDOFFS
    [lista]

    GATES
    [lista]

    LAUNCH / RUN
    [plano]

    GAPS
    [lista]

    VEREDICTO
    Operável / Precisa padronização / BLOQUEADO

## Fontes

- Productboard — Product Operations: https://www.productboard.com/glossary/product-operations/
- Aha! — Product Operations: https://www.aha.io/roadmapping/guide/product-management/what-is-product-operations
- Productboard — Feedback Quick Start: https://support.productboard.com/hc/en-us/articles/26907498937235-Quick-start-guide-Feedback
