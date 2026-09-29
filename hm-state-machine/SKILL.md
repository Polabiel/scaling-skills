---
name: hm-state-machine
description: Modelagem e validação de estados, eventos e transições em interfaces, APIs, jobs, filas, integrações e fluxos assíncronos. Use quando um recurso possui loading, sucesso, erro, retry, timeout, conflito, cancelamento, processamento em background ou múltiplos caminhos de execução. Complementa hm-engineer, hm-qa, hm-api-contract e hm-error-feedback.
---

# /hm-state-machine — Estados e Transições (v1)

Você está agora em modo state machine.

Seu trabalho é garantir que o sistema tenha estados explícitos e transições válidas, evitando combinações impossíveis, booleanos conflitantes e UIs que não representam a realidade do backend.

## Princípio central

**Todo comportamento complexo já é uma máquina de estados — a diferença é se ela foi modelada ou deixada implícita.**

Uma máquina descreve:
- estados;
- eventos;
- transições;
- guards;
- ações;
- estados finais.

State machines ajudam a tornar estados e transições explícitos, determinísticos e testáveis e ajudam a encontrar estados impossíveis. Fonte: https://stately.ai/docs/state-machines-and-statecharts

## Baseline — inegociável

Antes de implementar fluxo complexo, responda:
- quais são os estados?
- quais eventos podem acontecer?
- quais transições são válidas?
- quais são impossíveis?
- qual é o estado inicial?
- quais são estados terminais?
- o que acontece quando uma dependência falha?
- o que acontece quando o mesmo evento chega duas vezes?
- o que acontece após refresh/reconnect?

## 1. Estado descreve o que está acontecendo agora

Bom:

~~~text
idle
submitting
success
failure
~~~

Ruim:

~~~text
isLoading = false
isError = true
isSuccess = true
isRetrying = false
~~~

quando várias combinações impossíveis podem existir.

## 2. Eventos descrevem o que aconteceu

Estado:

~~~text
processing
~~~

Evento:

~~~text
payment.completed
~~~

Não faça evento significar estado.

Eventos podem ter dados:

~~~text
search.submitted(query)
upload.failed(reason)
payment.completed(transactionId)
~~~

## 3. Toda transição deve ser explicável

Uma transição é:

~~~text
estado atual + evento → próximo estado
~~~

A transição deve ser determinística quando não houver guards diferentes.

Fonte: https://stately.ai/docs/transitions

## 4. Não invente estados impossíveis

Pergunte:
- loading + success simultaneamente existe?
- failed + processing simultaneamente existe?
- cancelado + concluído simultaneamente existe?
- retry pode acontecer depois de sucesso?
- refresh pode retornar para idle e apagar um estado real?

Se o domínio não permite a combinação, a modelagem não deve permitir.

## 5. Async precisa de estados explícitos

Para jobs:

~~~text
queued
→ processing
→ succeeded
→ failed
→ retrying
→ dead-letter
~~~

Para operações com resultado incerto:

~~~text
submitting
→ unknown
→ querying-status
→ succeeded
~~~

ou:

~~~text
submitting
→ failed
~~~

Não trate timeout como sinônimo universal de failed.

## 6. UI deve representar o estado real

Backend:

~~~text
processing
~~~

Frontend:

~~~text
spinner
~~~

Backend:

~~~text
failed
~~~

Frontend:

~~~text
button disabled forever
~~~

é um gap de estado.

## 7. Estados compostos

Quando o fluxo cresce, considere:
- parent/child states;
- parallel states;
- guards;
- delayed transitions;
- actors.

XState/Stately documentam esses conceitos para modelar sistemas complexos. Fonte: https://stately.ai/docs/editor-states-and-transitions

Não introduza uma biblioteca apenas porque existe. A modelagem pode ser feita com tipos/unions simples quando o domínio for pequeno.

## 8. Estado deve atravessar camadas

Quando aplicável:

~~~text
Backend state
↓
API state
↓
Client state
↓
Visual state
~~~

Se o backend possui estado que o cliente não consegue observar, o cliente precisa de:
- polling;
- websocket/SSE;
- reconsulta;
- endpoint de status;
- ou decisão explícita de não representar o estado.

## 9. Eventos duplicados

Teste:
- double click;
- duplicate webhook;
- reconnect;
- retry;
- reprocessamento de fila.

Toda transição deve responder o que acontece com evento repetido.

## 10. Persistência de estado

Estados importantes não podem existir somente em memória quando o usuário depende deles após:
- refresh;
- restart;
- reconexão;
- troca de dispositivo;
- reprocessamento de job.

## Integração

> Para causa técnica, invariantes e resiliência, usar /hm-engineer.

> Para contrato entre estados backend/frontend, usar /hm-api-contract.

> Para validação de cada transição e edge case, usar /hm-qa.

> Para representação visual de success/error/unknown/retry, usar /hm-error-feedback.

## Anti-patterns críticos

- múltiplos booleans representando uma máquina complexa;
- estado visual inventado pelo frontend;
- timeout sempre convertido em failed;
- evento duplicado gerando efeito duplicado;
- retry após sucesso sem idempotência;
- estado perdido em refresh;
- transição implícita em condições espalhadas;
- estados sem caminho de saída;
- estados sem UI;
- UI sem estado correspondente no domínio.

## Checklist

- [ ] estados definidos
- [ ] eventos definidos
- [ ] transições definidas
- [ ] guards definidas
- [ ] impossibilidades identificadas
- [ ] async states
- [ ] retry
- [ ] timeout/unknown
- [ ] duplicidade
- [ ] persistência quando necessária
- [ ] backend/client parity
- [ ] testes de transição

## Output

~~~
HM-STATE-MACHINE
Domínio: [nome]

ESTADOS
[lista]

EVENTOS
[lista]

TRANSIÇÕES
[PASS/FAIL]

IMPOSSÍVEIS
[lista]

ASYNC/RETRY
[PASS/FAIL]

BACKEND → API → UI
[PASS/FAIL]

TESTES
[PASS/FAIL]

VEREDICTO
Modelado / GAP / BLOQUEADO
~~~

## Fontes

- Stately — State Machines and Statecharts: https://stately.ai/docs/state-machines-and-statecharts
- Stately — Events and Transitions: https://stately.ai/docs/transitions
- XState: https://stately.ai/docs/xstate
