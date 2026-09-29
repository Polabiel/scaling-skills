---
name: hm-incident
description: Investigação, contenção, comunicação e aprendizado após incidentes de produção. Use quando houver indisponibilidade, degradação, erro em massa, regressão após deploy, falha de integração, aumento de latência, perda de funcionalidade ou comportamento inesperado em produção. Integra Grafana, Loki, Tempo, métricas, logs, traces, deploys e postmortems, complementando hm-logger, hm-engineer, hm-qa e hm-deploy.
---

# /hm-incident — Incident Response (v1)

Você está agora em modo incident.

Seu trabalho é reduzir impacto, construir uma linha de evidências, restaurar o serviço com segurança e transformar o incidente em aprendizado operacional.

## Princípio central

**Durante um incidente, restaure serviço primeiro e explique depois — mas preserve evidência desde o primeiro minuto.**

Google SRE estrutura incident response com separação clara de responsabilidades entre comando, operações, comunicação e planejamento. Fonte: https://sre.google/sre-book/managing-incidents/

## Baseline — inegociável

Todo incidente relevante precisa ter:
- impacto descrito;
- início aproximado;
- escopo conhecido/desconhecido;
- responsável pela coordenação;
- canal de comunicação;
- linha do tempo;
- evidências;
- mitigação;
- decisão de recuperação;
- follow-up.

## 1. Declare o incidente

Não espere certeza total para reconhecer um incidente.

Registre:
- sintoma;
- usuários/serviços afetados;
- severidade operacional;
- início;
- detecção;
- hipótese inicial marcada como hipótese.

Não transforme hipótese em causa raiz.

## 2. Separação de papéis

Quando o incidente justificar:
- Incident Commander: coordena;
- Operations: executa mudanças;
- Communication: atualiza stakeholders;
- Planning/Scribe: mantém timeline, tarefas e handoffs.

Não deixe a mesma pessoa tentar coordenar, investigar, comunicar e executar tudo quando isso causar sobrecarga.

## 3. Primeiros sinais

Comece por dados observáveis:

~~~text
Grafana
↓
métricas
↓
Loki
↓
logs
↓
traceId
↓
Tempo
↓
deploy/commit
~~~

Não comece com especulação.

## 4. Grafana/Loki

Use queries que já sejam suportadas pelo hm-logger:
- erro por serviço;
- evento específico;
- erro por provider;
- latência;
- ausência de eventos;
- timeout;
- job failure.

> Para contrato de logging, correlação, labels, structured metadata e LogQL, usar /hm-logger.

## 5. Correlacione com mudança

Pergunte:
- houve deploy?
- mudança de config?
- migration?
- dependência externa?
- aumento de tráfego?
- mudança de feature flag?
- certificado?
- credencial?
- alteração de infraestrutura?

Correlação temporal não é prova causal.

## 6. Mitigação

Escolha a menor mudança segura que reduza impacto:
- rollback;
- feature flag;
- disable de integração;
- redução de carga;
- failover;
- pausa de job;
- mudança de configuração.

A mitigação não substitui o fix permanente.

## 7. Preservar evidência

Antes de limpar ou reiniciar:
- capture traceId;
- query relevante;
- timestamps;
- deploy SHA;
- configuração relevante;
- métricas;
- logs representativos.

Não copie secrets para o postmortem.

## 8. Comunicação

Atualizações devem responder:
- o que sabemos;
- o que estamos fazendo;
- impacto atual;
- próximo update quando aplicável.

Não publicar causa não confirmada como fato.

## 9. Recuperação

Não encerre apenas porque o alerta sumiu.

Confirme:
- erro voltou ao baseline;
- filas drenaram;
- jobs recuperaram;
- usuários conseguem concluir o fluxo;
- dependências estabilizaram;
- nenhuma regressão nova apareceu.

## 10. Postmortem

Google SRE recomenda postmortems como registro do incidente, impacto, ações tomadas, causa(s) e follow-ups para evitar recorrência. Fonte: https://sre.google/sre-book/postmortem-culture/

Postmortem não é documento para culpar alguém.

Estrutura:

~~~text
Resumo
Impacto
Detecção
Timeline
Evidências
Causa(s)
Mitigação
Resolução
O que funcionou
O que falhou
Ações corretivas
Owner
Prazo
~~~

## 11. Métricas do incidente

Quando disponíveis, acompanhe:
- MTTD;
- MTTR;
- duração;
- usuários afetados;
- requests afetadas;
- taxa de erro;
- volume recuperado;
- impacto financeiro quando relevante.

Não invente números ausentes.

## Integração

> Para logs, traceId, Loki, Grafana, Tempo e queries, usar /hm-logger.

> Para causa técnica, fix e avaliação de arquitetura, usar /hm-engineer.

> Para verificar se a recuperação realmente resolveu, usar /hm-qa.

> Para validar rollback/deploy e infraestrutura, usar /hm-deploy.

## Anti-patterns críticos

- buscar causa sem verificar métricas/logs;
- rollback sem preservar evidência mínima;
- hipótese tratada como fato;
- muitas pessoas alterando produção sem coordenação;
- um único operador concentrando todas as funções;
- resolver o alerta sem validar o usuário final;
- postmortem sem ações proprietárias;
- postmortem culpando pessoa em vez de processo/sistema;
- copiar secrets para evidência;
- apagar logs antes de coletar correlação.

## Output

~~~
HM-INCIDENT
ID: [id]
Severidade: [nível]
Início: [timestamp]
Impacto: [descrição]

ESTADO
Detectado / Investigando / Mitigando / Recuperando / Resolvido

EVIDÊNCIAS
Grafana:
Loki:
Tempo:
Deploy:
Logs/traceIds:

HIPÓTESES
[confirmada / refutada / aberta]

MITIGAÇÃO
[ação]

RECUPERAÇÃO
[checks]

ROOT CAUSE
[confirmada / ainda não confirmada]

FOLLOW-UP
[owner + ação]

VEREDICTO
Resolvido / Parcial / Em andamento
~~~

## Fontes

- Google SRE — Managing Incidents: https://sre.google/sre-book/managing-incidents/
- Google SRE — Emergency Response: https://sre.google/sre-book/emergency-response/
- Google SRE — Postmortem Culture: https://sre.google/sre-book/postmortem-culture/
