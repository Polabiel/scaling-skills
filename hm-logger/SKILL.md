---
name: hm-logger
description: Logging estruturado de produção com correlação distribuída, contexto de ator, eventos nomeados, severidade, erro serializado, redaction, limites de payload e rastreabilidade ponta a ponta. Use ao escrever, revisar ou auditar logs em APIs, webhooks, jobs, filas, agentes/IA, integrações externas, tarefas assíncronas e eventos de domínio; ao investigar incidentes; ou ao definir a infraestrutura de observabilidade de um serviço. Complementa hm-security (o que pode ser registrado), hm-performance (o que medir) e hm-error-feedback (o que o usuário vê).
---

# /hm-logger — Logging Estruturado de Produção (v2)

Você está agora em modo logging estruturado.

Seu trabalho é fazer com que os logs sejam **pesquisáveis, correlacionáveis, seguros, semanticamente úteis e suficientes para reconstruir um evento sem abrir o código-fonte**.

A régua não é "tem um log".

A régua é:

**quem/ator → o quê → onde → quando → resultado → impacto → correlação → evidência**

## Princípio central

**Log deve registrar eventos relevantes como dados estruturados, não frases decorativas para o terminal.**

Um bom log permite:
- agrupar ocorrências do mesmo evento;
- correlacionar uma requisição entre serviços;
- localizar a operação exata que falhou;
- distinguir usuário, serviço, IA e sistema como atores;
- identificar sucesso, falha ou estado incerto;
- reconstruir uma mutação importante;
- investigar sem expor secrets ou PII desnecessária.

OpenTelemetry define um modelo de log com timestamp, trace ID, span ID, severidade, body, resource e attributes; também define nomes semânticos para exceções e eventos. Use essa ideia como referência mesmo quando o projeto não utiliza OpenTelemetry.

## Escopo e responsabilidades

### hm-logger decide a FORMA

Esta skill define:
- estrutura do log;
- correlação;
- actor context;
- nome do evento;
- severidade;
- contexto HTTP/job;
- serialização de erro;
- redaction;
- limites de tamanho;
- cardinalidade;
- deduplicação/amostragem quando apropriado;
- regras para auditoria e diagnóstico.

### hm-security decide o CONTEÚDO PERMITIDO

hm-security define o que nunca deve entrar em logs por segurança, privacidade ou compliance.

hm-logger garante que a informação permitida seja estruturada e rastreável.

### hm-performance decide o QUE MEDIR

Latência, p95/p99, throughput, consumo e custo são responsabilidade de hm-performance.

hm-logger fornece os dados necessários para essas análises.

### hm-error-feedback decide o QUE O USUÁRIO VÊ

O stack trace, código interno e contexto de infraestrutura pertencem ao canal técnico.

A mensagem visual pertence ao canal do produto.

## Correção importante: identidade de correlação

**Não trate x-request-id como traceId automaticamente.**

São conceitos diferentes.

### traceId

Identifica a operação distribuída inteira e deve seguir o formato/propagação do W3C Trace Context quando tracing distribuído estiver em uso.

### spanId

Identifica uma operação específica dentro do trace.

### requestId

Identifica uma requisição local ou identificador legado do sistema.

### correlationId

Pode existir para correlacionar uma operação de negócio quando ela atravessa múltiplas requisições ou processos.

### jobId / messageId

Identifica uma execução assíncrona ou mensagem/fila específica.

Um evento pode ter:

traceId + spanId + requestId + correlationId + jobId

sem que esses valores sejam equivalentes.

A especificação W3C define traceparent como mecanismo padrão de propagação distribuída e separa trace-id de parent-id; o trace ID identifica o trace completo.

## Contrato principal

Prefira um contrato compatível conceitualmente com OpenTelemetry:

    export interface StructuredLogPayload {
      timestamp?: string;
      level: "trace" | "debug" | "info" | "warn" | "error" | "fatal";
      eventName: string;
      message?: string;

      traceId?: string;
      spanId?: string;
      requestId?: string;
      correlationId?: string;

      actor?: LogActorContext;
      service?: LogServiceContext;
      http?: LogHttpContext;
      job?: LogJobContext;

      outcome?: "success" | "failure" | "partial" | "timeout" | "cancelled" | "unknown";

      durationMs?: number;
      error?: LogErrorContext;
      attributes?: Record<string, unknown>;
    }

    export interface LogActorContext {
      type: "user" | "service" | "ai" | "system" | "anonymous";
      id?: string;
      orgId?: string;
      source?: string;
    }

    export interface LogServiceContext {
      name: string;
      version?: string;
      environment?: string;
      instanceId?: string;
    }

    export interface LogHttpContext {
      method: string;
      route?: string;
      statusCode?: number;
      requestSizeBytes?: number;
      responseSizeBytes?: number;
    }

    export interface LogJobContext {
      queue?: string;
      jobId?: string;
      attempt?: number;
      parentJobId?: string;
    }

    export interface LogErrorContext {
      type: string;
      message: string;
      stack?: string;
      code?: string;
    }

### Campos obrigatórios

Não existe uma obrigação universal de todos os logs terem usuário.

**Todo log deve ter contexto suficiente para explicar sua origem e seu evento.**

Para eventos de request humano:
- actor.type = user;
- actor.id quando identificado;
- traceId quando houver tracing;
- eventName;
- level.

Para webhook sem usuário:
- actor.type = service ou system conforme a realidade;
- identificação da integração/origem;
- eventName;
- correlação disponível.

Para IA:
- actor.type = ai;
- identifique o agente/modelo quando isso for útil;
- preserve também o ator humano original se houver um.

**Não use "system-ai-context" como substituto de identidade.** Isso mistura ator, fallback e contexto técnico em uma string impossível de consultar semanticamente.

## Actor context: quem realmente fez a ação?

Não confunda:
- quem iniciou a requisição;
- quem executou a ação;
- qual sistema processou;
- qual agente de IA tomou a decisão.

Quando uma ação é iniciada pelo usuário e executada por uma IA, registre os dois quando possível:

    {
      "actor": {
        "type": "ai",
        "id": "agent_123",
        "source": "workflow"
      },
      "initiatedBy": {
        "type": "user",
        "id": "usr_456"
      }
    }

Se o projeto prefere um contrato diferente, preserve a mesma semântica.

## Trace context e propagação

### Entrada HTTP

Ao receber uma requisição:
1. leia e valide traceparent;
2. preserve tracestate quando o stack de tracing suportar;
3. associe o contexto ao request atual;
4. gere novo trace somente quando não houver um contexto válido;
5. gere um novo span para a operação local quando existir tracing.

Não confie em qualquer header arbitrário como se fosse um W3C trace válido.

### Saída HTTP

Ao chamar outro serviço:
- propague traceparent;
- propague tracestate quando aplicável;
- registre a operação externa como evento/log e/ou span;
- mantenha correlationId se a lógica de negócio exigir.

### Webhooks e integrações externas

Se a integração fornece um ID próprio:
- guarde-o como externalEventId, providerEventId ou equivalente;
- não substitua traceId por esse identificador;
- correlacione os dois.

## Event name: pare de usar mensagem como identificador

Não use a mensagem humana como chave principal de agrupamento.

Ruim:

    logger.warn("Falha ao enviar webhook para cliente X");

Melhor:

    logger.warn(
      {
        eventName: "webhook.delivery.failed",
        provider: "meta",
        outcome: "failure"
      },
      "Falha ao entregar webhook"
    );

eventName deve ser estável, curto, pesquisável e sem valores dinâmicos.

O OpenTelemetry recomenda nomes de eventos que identifiquem a classe/tipo do evento e atributos estruturados para detalhes da ocorrência.

Exemplos de nomes úteis:

    auth.login.failed
    auth.session.expired
    payment.charge.failed
    payment.charge.succeeded
    webhook.delivery.started
    webhook.delivery.succeeded
    webhook.delivery.failed
    agent.tool.call.started
    agent.tool.call.failed
    agent.tool.call.succeeded
    database.mutation.conflict
    job.processing.started
    job.processing.failed
    job.processing.succeeded
    file.upload.failed
    integration.timeout

## Severidade: use impacto, não emoção

Defina uma política clara:

### trace
Detalhe extremamente granular, normalmente desligado em produção.

### debug
Informação detalhada útil durante desenvolvimento/investigação.

### info
Evento normal de negócio/operação que pode ser útil para reconstruir o fluxo.

### warn
Algo anormal aconteceu, mas o sistema continuou ou houve degradação recuperável.

### error
Uma operação esperada falhou e precisa de investigação/correção.

### fatal
O processo ou serviço não consegue continuar corretamente.

Não use error apenas porque uma condição foi inesperada pelo desenvolvedor.

Não use fatal para qualquer exceção.

## Resultado da operação

Não deixe o leitor deduzir o resultado pela mensagem.

Use:

    outcome: "success"

ou:

    outcome: "failure"

Para casos especiais:

    partial
    timeout
    cancelled
    unknown

unknown é importante quando o sistema não conseguiu confirmar se a operação foi concluída.

Isso é especialmente crítico para:
- pagamentos;
- criação de recursos;
- comandos assíncronos;
- chamadas externas sem idempotência;
- timeouts;
- conexões interrompidas.

## Erros: preservar diagnóstico sem vazar segredo

Um erro deve ser estruturado.

Referência conceitual:

    {
      "error": {
        "type": "PrismaClientKnownRequestError",
        "message": "Unique constraint failed",
        "code": "P2002",
        "stack": "..."
      }
    }

OpenTelemetry define convenções próprias para atributos de exceções, incluindo exception.message e exception.type.

### Regras

- nunca criar logger.error("Falha: " + err.message) como única evidência;
- preserve o objeto/estrutura de erro quando o logger suportar;
- serialize de forma consistente;
- normalize tipos/códigos;
- preserve stack no canal técnico apropriado;
- aplique redaction antes de enviar o payload ao backend de logs.

error.message sozinho não é diagnóstico suficiente.

## Redaction: segurança por padrão

**Nunca logue req.body inteiro como padrão.**

A lista de campos sensíveis deve ser centralizada.

Exemplos típicos que devem ser removidos, mascarados ou transformados conforme a política do produto:

    password
    passwordConfirmation
    access_token
    refresh_token
    authorization
    cookie
    set-cookie
    apiKey
    secret
    privateKey
    creditCardNumber
    cvv
    sessionToken
    databaseUrl

Dependendo do domínio, também podem existir dados pessoais que precisem de minimização, hash ou remoção.

OWASP recomenda não registrar diretamente passwords, access tokens, chaves, connection strings e dados pessoais/sensíveis; quando necessário, devem ser mascarados, sanitizados, hasheados ou protegidos.

### Redaction deve acontecer antes do transporte

Não dependa do dashboard de logs para esconder o dado.

O payload já deve chegar sanitizado ao sink.

## Data minimization

Pergunte sempre:

**Preciso registrar esse valor inteiro para investigar o evento?**

Se não:
- não registre;
- registre somente propriedades derivadas;
- faça hash quando a correlação exigir;
- trunque strings longas;
- registre comprimento, tipo ou categoria em vez do conteúdo.

Exemplo:

Ruim:

    {
      "attributes": {
        "prompt": "conteúdo inteiro de 80.000 tokens..."
      }
    }

Melhor:

    {
      "attributes": {
        "promptLength": 80000,
        "promptSource": "agent-context"
      }
    }

## Limites de tamanho

Todo logger de produção deve ter limites.

Defina limites para:
- mensagem;
- strings individuais;
- arrays;
- objetos aninhados;
- body;
- stack trace;
- quantidade de atributos;
- tamanho total do evento.

Quando truncar:
- preserve a estrutura;
- indique que houve truncamento;
- não faça truncamento silencioso quando isso puder confundir investigação.

Exemplo:

    {
      "attributes": {
        "payload": "[TRUNCATED]",
        "payloadBytes": 183920
      }
    }

## Cardinalidade

Nem todo campo deve ser indexado ou usado para agregação.

Evite usar como dimensão permanente:
- texto livre;
- stack trace;
- URL completa com query string;
- prompt;
- corpo HTTP;
- IDs altamente variados em dashboards de agregação, quando não forem necessários.

Prefira atributos estáveis:
- eventName;
- service.name;
- environment;
- statusCode;
- outcome;
- provider;
- operation;
- error.type;
- error.code.

IDs podem existir para busca pontual, mas não devem virar dimensões de métricas sem necessidade.

## HTTP context

Registre contexto HTTP útil sem reproduzir a requisição inteira.

Preferido:

    {
      "http": {
        "method": "POST",
        "route": "/api/webhooks/[id]",
        "statusCode": 500
      }
    }

Evite:
- URL completa com query string sensível;
- headers inteiros;
- cookies;
- body bruto.

Se o framework fornecer uma rota normalizada, prefira a rota à URL concreta para evitar cardinalidade desnecessária.

durationMs deve medir a operação real.

## Request lifecycle

Para endpoints importantes, pense em estados:

    request.received
    →
    operation.started
    →
    operation.succeeded

ou:

    request.received
    →
    operation.started
    →
    operation.failed

Não gere três logs para cada endpoint por padrão apenas para "ter rastreabilidade".

**O objetivo é sinalizar eventos úteis, não aumentar volume.**

Um único log final de erro com contexto suficiente pode ser melhor que cinco logs redundantes.

## Jobs, filas e assíncrono

Requests HTTP não são o único contexto importante.

Para jobs, registre quando necessário:

    {
      "job": {
        "queue": "webhooks",
        "jobId": "job_123",
        "attempt": 2,
        "parentJobId": "job_099"
      }
    }

Quando uma requisição coloca uma mensagem em fila:
- mantenha correlação com a origem;
- associe jobId/messageId;
- não gere um contexto completamente desconectado.

Quando o processamento continua depois que a requisição termina, o log deve permitir responder:

**"Qual request/ação originou este job?"**

## Eventos assíncronos e IA

Para agente/LLM, registre eventos significativos, não cada token.

Bons candidatos:
- geração iniciada;
- tool call iniciada;
- tool call concluída;
- tool call falhou;
- retry;
- limite de tokens atingido;
- timeout;
- mudança importante de estado;
- custo/tokens agregados, quando relevante;
- resultado final.

Evite:
- prompt completo;
- resposta completa se contiver PII ou conteúdo sensível;
- cada chunk do streaming;
- logs por token;
- dumps gigantes do contexto.

## Before/after: use somente em mutações reais

Snapshots são úteis para:
- mudança de plano;
- permissão;
- configuração;
- mudança de status;
- operação concorrente.

Não use:

    "before": { "objeto inteiro" },
    "after": { "objeto inteiro" }

como substituto para debugging.

Prefira um diff mínimo:

    {
      "changes": {
        "plan": {
          "before": "pro",
          "after": "enterprise"
        },
        "status": {
          "before": "active",
          "after": "pending"
        }
      }
    }

Sempre aplique redaction.

## Audit log ≠ diagnostic log

Não trate todos os logs como equivalentes.

### Diagnostic log

Serve para:
- debugging;
- incident response;
- performance;
- falhas de integração.

Pode conter stack/contexto técnico apropriado e normalmente tem retenção diferente.

### Audit log

Serve para:
- provar ações relevantes;
- mudanças de permissão;
- ações administrativas;
- eventos regulatórios;
- operações destrutivas.

Deve ter semântica de auditoria própria e política de retenção/integridade adequada.

hm-logger pode estruturar ambos, mas não deve presumir que a mesma retenção, acesso ou conteúdo serve para os dois.

## Deduplicação, flood e sampling

Logs de erro em loop podem derrubar o próprio sistema de observabilidade.

Para eventos altamente repetitivos:
- agregue quando possível;
- faça rate limit de eventos idênticos;
- use sampling para debug de alto volume;
- preserve contadores/resumos;
- nunca sample um evento de auditoria que tenha requisito de completude.

Exemplo:

Em vez de emitir 50.000 vezes:

    integration.timeout

durante um minuto, pode fazer sentido ter:
- logs representativos;
- contador de ocorrências;
- primeiro/último timestamp;
- serviço/provedor afetado.

A estratégia precisa preservar a capacidade de responder "isso está acontecendo em escala?" sem gerar um log storm.

## Logger habilitado: não construa payload caro à toa

Quando o nível de log estiver desabilitado, evite construir:
- serializações gigantes;
- JSON.stringify de objetos enormes;
- diffs caros;
- queries apenas para montar log;
- dumps completos.

OpenTelemetry documenta uma API Enabled justamente para evitar trabalho computacional caro quando um log daquela severidade não será registrado.

## Context propagation no código

Prefira contexto implícito/escopado quando a infraestrutura suportar, para evitar passar traceId manualmente por dezenas de funções.

Exemplo conceitual:

    withLogContext(
      {
        actor,
        traceId,
        correlationId,
      },
      async () => {
        // todas as funções internas podem emitir logs correlacionados
      }
    );

Em Node.js, mecanismos de contexto assíncrono podem ser usados para isso, desde que o projeto valide propagação em:
- Promise chains;
- callbacks;
- workers;
- filas;
- jobs;
- streams.

Não crie estado global mutável compartilhado entre requests.

## Exemplo completo

    hmLogger.error({
      eventName: "payment.charge.failed",
      message: "Falha ao processar cobrança",
      traceId,
      spanId,
      requestId,
      correlationId,
      actor: {
        type: "user",
        id: user.id,
        orgId: organization.id,
      },
      http: {
        method: req.method,
        route: "/api/payments/charge",
        statusCode: 402,
      },
      outcome: "failure",
      durationMs: Date.now() - startTime,
      attributes: {
        provider: "stripe",
        operation: "charge",
        retryable: false,
      },
      error: {
        type: "CardDeclinedError",
        message: "Pagamento recusado",
        code: "card_declined",
      },
    );

A implementação concreta pode usar Pino, Winston, OpenTelemetry ou outro logger, desde que preserve a semântica.

## Exemplo: antes vs. depois

### Ruim

    logger.error(
      "[WebhookBlocked] Agent: " + data.agentId + " URL: " + rawUrl + " Error: " + err
    );

Problemas:
- evento não estruturado;
- dados dinâmicos misturados com mensagem;
- possível exposição de URL;
- impossível agrupar corretamente;
- correlação ausente;
- erro não normalizado.

### Bom

    hmLogger.error({
      eventName: "webhook.delivery.blocked",
      message: "Tentativa de envio de webhook bloqueada",
      traceId,
      actor: {
        type: "ai",
        id: data.agentId,
      },
      outcome: "failure",
      attributes: {
        reason: "security-policy",
        provider: "custom",
      },
    });

Se a causa técnica for relevante:

    error: serializeError(err)


# Guia Grafana + Loki

O `hm-logger` deve produzir logs que sejam bons não apenas no código, mas também no **Grafana Explore, Loki, dashboards, alertas e correlação com traces**.

Loki organiza streams por labels e recomenda mantê-las com baixa cardinalidade. Valores como `traceId`, `userId`, `customerId`, `orderId`, IP e outros identificadores altamente variáveis devem ficar como conteúdo estruturado ou **structured metadata**, não como labels indexadas. Isso reduz fragmentação de streams, custo e problemas de performance. Fonte: https://grafana.com/docs/loki/latest/get-started/labels/cardinality/

## Contrato recomendado para Loki

Uma saída JSON de aplicação deve permitir que o Grafana filtre rapidamente por origem, enquanto os detalhes permanecem estruturados:

```json
{
  "timestamp": "2026-09-29T03:12:44.123Z",
  "level": "error",
  "service_name": "chatvolt-api",
  "environment": "production",
  "eventName": "payment.charge.failed",
  "message": "Falha ao processar cobrança",
  "traceId": "0242ac120002",
  "spanId": "89f2",
  "requestId": "req_123",
  "correlationId": "checkout_456",
  "actor": {
    "type": "user",
    "id": "usr_789",
    "orgId": "org_321"
  },
  "http": {
    "method": "POST",
    "route": "/api/payments/charge",
    "statusCode": 402
  },
  "outcome": "failure",
  "durationMs": 842,
  "attributes": {
    "provider": "stripe",
    "operation": "charge",
    "retryable": false
  },
  "error": {
    "type": "CardDeclinedError",
    "code": "card_declined",
    "message": "Pagamento recusado"
  }
}
```

### O que vira label Loki

Use poucas labels, estáveis e de baixa cardinalidade, por exemplo:

```text
service_name
environment
cluster
namespace
container
region
```

Dependendo da infraestrutura, `service_name`, `service_namespace`, cluster/namespace e outros atributos de origem podem ser promovidos para labels. A documentação atual do Loki recomenda selecionar apenas os atributos de recurso necessários como index labels e manter o restante como structured metadata. Fonte: https://grafana.com/docs/loki/latest/send-data/otel/

### O que NÃO vira label por padrão

Nunca promova automaticamente:

```text
traceId
spanId
requestId
correlationId
userId
orgId
customerId
orderId
jobId
messageId
ip
email
URL completa
erro.message
stack
prompt
```

Loki recomenda explicitamente não usar trace ID, order ID ou user ID como labels indexadas. Para esses casos, use structured metadata. Fonte: https://grafana.com/docs/loki/latest/get-started/labels/cardinality/

## Structured metadata

Use structured metadata para metadata frequentemente consultada, mas de alta cardinalidade, como `trace_id`, `span_id`, `request_id`, `correlation_id`, `user_id`, `org_id`, `job_id` e `provider_event_id`.

Structured metadata não cria novos streams e continua disponível para filtros no LogQL. Para ingestão OTLP, structured metadata é parte importante do modelo moderno do Loki. Fonte: https://grafana.com/docs/loki/latest/get-started/labels/structured-metadata/

**Pré-requisito:** valide a configuração do Loki antes de assumir suporte a structured metadata; a documentação relaciona o recurso ao chunk format V4, schema adequado e TSDB. Fonte: https://grafana.com/docs/loki/latest/get-started/labels/structured-metadata/

## Compatibilidade com OpenTelemetry

Quando o projeto usa OpenTelemetry Collector ou Grafana Alloy:
- prefira resource attributes para identificar o serviço;
- mantenha `service.name`, `service.namespace` e `deployment.environment.name` coerentes;
- deixe atributos de alta cardinalidade fora das index labels;
- permita que o collector/Loki faça o mapeamento para structured metadata.

O Loki atual promove automaticamente determinados resource attributes de OpenTelemetry para labels e mantém os demais como structured metadata. Como o Loki tem limite de labels indexadas, não promova todos os atributos. Fonte: https://grafana.com/docs/loki/latest/send-data/otel/

## Nomenclatura para Grafana

Para facilitar consultas:
- `eventName` deve ser estável;
- `outcome` deve ter valores limitados;
- `level` deve ser um valor limitado;
- `statusCode` deve ser numérico;
- `durationMs` deve ser numérico;
- `error.type` e `error.code` devem ser categorizáveis;
- IDs devem ficar como metadata;
- não coloque valores dinâmicos dentro de `message`.

O Loki também pode descobrir níveis de log automaticamente e armazená-los como structured metadata quando habilitado. Não crie uma label dinâmica de `level` só para facilitar filtro; a própria documentação do Loki recomenda evitar labels dinâmicas desnecessárias. Fontes: https://grafana.com/docs/loki/latest/configure/ e https://grafana.com/docs/loki/latest/get-started/labels/bp-labels/

## LogQL: consultas que a skill deve saber produzir

### Todos os erros de um serviço

```logql
{service_name="chatvolt-api", environment="production"} | json | level="error"
```

### Um evento específico

```logql
{service_name="chatvolt-api", environment="production"} | json | eventName="payment.charge.failed"
```

### Uma ocorrência por trace

Quando `trace_id` estiver em structured metadata:

```logql
{service_name="chatvolt-api", environment="production"} | trace_id="0242ac120002"
```

Se o trace estiver dentro do JSON do log, faça parsing antes do filtro:

```logql
{service_name="chatvolt-api", environment="production"} | json | traceId="0242ac120002"
```

### Erros por evento

```logql
sum by (eventName) (count_over_time({service_name="chatvolt-api", environment="production"} | json | level="error" [5m]))
```

### Taxa de erros para alertas

```logql
sum(rate({service_name="chatvolt-api", environment="production"} | json | level="error" [5m]))
```

### Requests lentas

Se `durationMs` estiver no formato numérico aceito pelo parser, filtre no pipeline e adapte a unidade ao formato real:

```logql
sum(count_over_time({service_name="chatvolt-api", environment="production"} | json | durationMs > 1000 [5m]))
```

### Falhas de integração

```logql
sum by (provider) (count_over_time({service_name="chatvolt-api", environment="production"} | json | eventName=~"integration.*" | outcome="failure" [10m]))
```

LogQL oferece `rate`, `count_over_time`, `bytes_rate`, `bytes_over_time` e `absent_over_time` para transformar logs em séries numéricas úteis para dashboards e alertas. Fonte: https://grafana.com/docs/loki/latest/query/metric_queries/

## Grafana Explore: o log precisa ser investigável

Ao abrir uma linha no Explore, deve ser fácil responder:

**O que aconteceu?** `eventName`, `message`, `outcome`

**Quem estava envolvido?** `actor.type`, `actor.id`, `actor.orgId`

**Onde aconteceu?** `service_name`, `environment`, `http.route`

**Qual operação?** `requestId`, `correlationId`, `jobId`

**Como encontro o trace?** `traceId`, `spanId`

**O que falhou?** `error.type`, `error.code`, `error.message`

## Grafana → Tempo: correlação de logs com traces

Uma implementação madura deve permitir navegar:

```text
Grafana Log
   ↓ traceId
Tempo Trace
   ↓ spanId
Span / ação
```

Grafana suporta **derived fields** para extrair um trace ID de logs e criar um link para o datasource de tracing. O trace precisa existir no backend de traces, como Tempo, e o valor extraído precisa corresponder ao trace ID armazenado nele. Fonte: https://grafana.com/docs/grafana/latest/datasources/loki/configure/

### Regra prática

O log precisa ter um campo de trace claramente identificável e estável. Use um único padrão entre serviços sempre que possível (`traceId`, `trace_id` ou `traceID`). Para formatos legados diferentes, configure derived fields específicos em vez de criar labels de alta cardinalidade. Fonte: https://grafana.com/docs/grafana/latest/datasources/tempo/configure-tempo-data-source/configure-trace-to-logs/

## Grafana → usuário

Quando `hm-error-feedback` fornecer ao usuário um código de referência, esse código deve apontar para uma correlação técnica segura.

Exemplo:

```text
Usuário:
"Não foi possível concluir o pagamento.
 Código de referência: 0242ac120002"

Grafana/Loki:
traceId=0242ac120002

Tempo:
traceId=0242ac120002
```

Não use e-mail, CPF, cartão ou outro dado pessoal como código de referência.

## Dashboards que o hm-logger deve suportar

### Saúde da aplicação
- volume de logs por serviço;
- erros por minuto;
- warnings por minuto;
- distribuição por outcome;
- serviços que deveriam estar emitindo logs, mas pararam.

### API
- erros 4xx/5xx;
- operações lentas;
- latência por rota quando disponível;
- falhas por endpoint.

### Integrações
- sucesso/falha por provider;
- timeout por provider;
- retries;
- falhas externas.

### Jobs
- jobs processados;
- jobs falhos;
- retries;
- jobs presos ou sem progresso.

### IA
- tool calls falhas;
- timeouts;
- limites de tokens;
- erros por provider/modelo;
- custo agregado, quando disponível.

## Alertas Grafana

O `hm-logger` deve estruturar eventos de modo que o time consiga criar alertas sem regex frágil.

Prefira:

```text
eventName + outcome + statusCode + error.code
```

a depender de texto livre como:

```text
"Falha ao salvar coisa X..."
```

Alertas possíveis:
- taxa de `*.failed` acima do baseline;
- HTTP 5xx sustentado;
- timeout de integração;
- aumento de `payment.charge.failed`;
- job failure rate;
- ausência de logs de um serviço esperado.

Grafana recomenda testar a query no Explore antes de transformá-la em alert rule e usar um pending period para reduzir falsos positivos de picos transitórios. Fonte: https://grafana.com/docs/grafana/latest/datasources/loki/alerting/

### Não alertar em cima de uma única linha

Evite:

```text
"se apareceu error, alerta"
```

Prefira:

```text
rate/count em janela temporal
+ threshold
+ pending period
```

Uma query de logs simples retorna linhas; alertas precisam de uma **LogQL metric query** que produza dados numéricos, como `rate` ou `count_over_time`. Fonte: https://grafana.com/docs/grafana/latest/datasources/loki/alerting/

## Saúde do próprio pipeline de logs

Observabilidade também precisa observar o observador.

Em ambientes Loki, monitore:
- logs descartados;
- bytes descartados;
- rate limit;
- erros de ingestão;
- cardinalidade de streams;
- tamanho excessivo de structured metadata;
- problemas de query.

Loki expõe métricas como `loki_discarded_samples_total` e `loki_discarded_bytes_total` e recomenda alertas/dashboards para detectar rejeições de ingestão e rate limits. Fonte: https://grafana.com/docs/loki/latest/operations/request-validation-rate-limits/

## Regra de arquitetura para Grafana/Loki

Pense em três camadas:

```text
LABELS
↓
origem estável e baixa cardinalidade

STRUCTURED METADATA
↓
campos pesquisáveis de alta cardinalidade

LOG BODY
↓
detalhes ricos do evento
```

Exemplo:

```text
Labels:
service_name=chatvolt-api
environment=production
namespace=chatvolt

Structured metadata:
trace_id=...
span_id=...
user_id=...
org_id=...
request_id=...
job_id=...

Body JSON:
eventName
outcome
http
error
attributes
message
```

**Não inverter essas camadas.**

## Anti-patterns críticos

Rejeite imediatamente:

- console.log/print em código de produção;
- mensagem dinâmica usada como único identificador do evento;
- x-request-id tratado como traceId sem validação/semântica;
- geração de novo trace quando existe contexto W3C válido;
- log do req.body cru;
- log de headers/cookies inteiros;
- access token, password, API key ou secret em log;
- erro bruto renderizado no logger sem redaction/serialização;
- stack trace na mensagem humana do log;
- logging por token/chunk de streaming;
- dumps gigantes de prompt/contexto de LLM;
- before/after contendo objeto inteiro sem necessidade;
- campos altamente variáveis usados como dimensões permanentes de métricas;
- retry automático que gera milhares de logs iguais;
- construção cara de payload quando o nível está desabilitado;
- contexto armazenado em singleton/global mutável por request;
- identificação do ator reduzida a uma string genérica como "system-ai-context" quando a estrutura pode distinguir user/service/ai/system;
- log de sucesso para operação que ainda está em estado incerto.

## Checklist de revisão

### Correlação
- [ ] traceId propagado/gerado corretamente
- [ ] spanId preservado quando houver tracing
- [ ] requestId separado de traceId
- [ ] correlationId usado quando houver operação de negócio distribuída
- [ ] jobId/messageId presente em fluxos assíncronos

### Identidade
- [ ] actor type explícito
- [ ] ator humano preservado quando uma IA executa em seu nome
- [ ] serviço/origem identificados quando não existe usuário
- [ ] nenhum fallback genérico substituindo semântica real

### Estrutura
- [ ] eventName estável
- [ ] level coerente
- [ ] outcome explícito
- [ ] timestamp disponível
- [ ] atributos estruturados
- [ ] mensagem humana opcional e curta

### HTTP / async
- [ ] rota normalizada
- [ ] status
- [ ] duração
- [ ] job/message context quando necessário
- [ ] sem query/header/body sensível cru

### Erros
- [ ] error type
- [ ] error message
- [ ] code quando existir
- [ ] stack no canal técnico
- [ ] serialização consistente
- [ ] redaction aplicada

### Volume
- [ ] limites de payload
- [ ] truncation explícita
- [ ] cardinalidade revisada
- [ ] dedup/sampling quando necessário
- [ ] nenhum payload caro construído sem necessidade

### Segurança
- [ ] secrets removidos
- [ ] PII minimizada
- [ ] cookies/tokens removidos
- [ ] logs de auditoria separados conceitualmente dos diagnósticos

## Output — auditoria

Quando o pedido é auditar logging existente, reporte:

    HM-LOGGER AUDIT
    Projeto: [nome]
    Logger base: [Pino / Winston / OpenTelemetry / console / outro]
    Arquivos/rotas/jobs auditados: [count]

    CORRELAÇÃO
    traceId: PASS/FAIL
    spanId: PASS/FAIL/N-A
    requestId separado: PASS/FAIL
    correlationId: PASS/FAIL/N-A
    job/message correlation: PASS/FAIL/N-A

    ATOR
    user/service/ai/system semanticamente distinguíveis: PASS/FAIL
    ator original preservado em automações: PASS/FAIL/N-A

    ESTRUTURA
    eventName estável: PASS/FAIL
    outcome explícito: PASS/FAIL
    severidade coerente: PASS/FAIL
    HTTP/job context: PASS/FAIL
    erro serializado: PASS/FAIL

    SEGURANÇA
    redaction: PASS/FAIL
    secrets: CLEAN/EXPOSED
    PII minimizada: PASS/FAIL
    body/header logging: PASS/FAIL

    VOLUME
    limites de payload: PASS/FAIL
    cardinalidade: PASS/FAIL
    dedup/sampling: PASS/FAIL/N-A
    payload lazy: PASS/FAIL

    LOGS ÓRFÃOS
    [arquivo:linha] — [evento] — problema: [...]
    Fix: [...]

    VEREDICTO
    Rastreável / Parcialmente rastreável / Órfão
    Bloqueadores: [count]

## Regras finais

- **Estruture eventos; não cole contexto em strings.**
- **Não confunda requestId, correlationId e traceId.**
- **Propague contexto W3C quando tracing distribuído estiver presente.**
- **Nem todo log precisa de usuário; todo log precisa de ator/origem semanticamente correta quando esse contexto existe.**
- **Não invente identidade para preencher campo obrigatório.**
- **Nunca logue secrets por conveniência.**
- **Capture body somente com opt-in, redaction e limite de tamanho.**
- **Prefira evento estável + atributos estruturados a mensagens dinâmicas.**
- **Registre resultado da operação explicitamente.**
- **Trate timeout como estado potencialmente incerto.**
- **Preserve correlação entre HTTP → fila → job → serviço externo.**
- **Use before/after apenas para mudanças importantes e com diff mínimo.**
- **Não transforme logs em métricas de alta cardinalidade.**
- **Controle flood, deduplicate e sample diagnósticos de alto volume quando apropriado.**
- **Não construa payload caro quando o nível estiver desabilitado.**
- **Separe canal de diagnóstico do canal de auditoria.**

## Fontes

- OpenTelemetry — Logs Data Model: https://opentelemetry.io/docs/specs/otel/logs/data-model/
- OpenTelemetry — Logs API / Enabled: https://opentelemetry.io/docs/specs/otel/logs/api/
- OpenTelemetry — Semantic Conventions for Events: https://opentelemetry.io/docs/specs/semconv/general/events/
- OpenTelemetry — Exceptions in Logs: https://opentelemetry.io/docs/specs/semconv/exceptions/exceptions-logs/
- OpenTelemetry — Trace Context in non-OTLP Log Formats: https://opentelemetry.io/docs/specs/otel/compatibility/logging_trace_context/
- W3C — Trace Context: https://www.w3.org/TR/trace-context/
- OWASP — Logging Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## Regra final

**O log não existe para dizer que algo aconteceu. Ele existe para permitir provar o que aconteceu.**
