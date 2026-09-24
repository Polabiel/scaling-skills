---
name: hm-logger
description: Logging estruturado obrigatório — todo log carrega traceId, user (com estratégia de fallback em cascata) e contexto HTTP, nunca uma linha solta sem rastro. Use sempre que escrever, adicionar ou revisar uma chamada de log (logger.warn/error/info/debug) em rota de API, webhook, handler de agente/IA, job em background ou integração externa; ao fazer setup de logging num projeto ou serviço novo; ao investigar um incidente onde o log existente não permite saber quem fez o quê; ou ao auditar uma base de código atrás de logs órfãos (console.log, strings interpoladas sem payload). Cobre contrato de payload fechado, caçador de usuário multi-camada, contexto HTTP com latência, erro serializado, comparação before/after pra mutação concorrente entre usuário e IA, e captura de body com redação. Complementa — não substitui — `/hm-security` DOMÍNIO 8 e `/hm-performance`.
---

# /hm-logger — Logging Estruturado (v1)

Você está agora em **modo logging estruturado**. Seu trabalho é garantir que nenhum log do sistema seja uma linha órfã — todo `logger.warn`, `.error`, `.info` ou `.debug` carrega quem agiu, onde, e com qual trace, mesmo quando quem agiu foi um agente de IA processando um webhook sem sessão de usuário nenhuma. Isso não é sobre O QUE deve ser logado por razão de segurança, nem sobre o que nunca pode aparecer num log — isso é `/hm-security` DOMÍNIO 8. hm-logger garante a FORMA: estrutura fechada, rastreável, nunca genérica.

## Princípio central

Um log sem `user`, sem `http` e sem `traceId` é um log órfão — existe no terminal no momento em que aconteceu, mas não serve pra nada quando alguém precisa reconstruir um incidente dias depois. Isso fica crítico em sistemas onde um agente de IA age sobre os mesmos dados que o usuário: se o log não distingue quem disparou a ação, toda investigação vira arqueologia. `logger.warn('[WebhookBlocked] ...')` sem payload estruturado é tão inútil quanto não logar nada — pior, ainda dá a falsa sensação de que o evento está rastreado.

A régua: qualquer log, aberto no Datadog/BetterStack meses depois, precisa responder sozinho — quem, onde, em resposta a quê, e o que mudou — sem exigir que alguém abra o código-fonte pra entender o contexto.

## Quando usar

- Ao escrever, adicionar ou revisar qualquer chamada de log (`logger.warn/error/info/debug`) em rota de API, webhook, handler de agente/IA, job em background ou integração externa
- Ao fazer setup de logging num projeto ou serviço novo (complementa `/hm-init`)
- Ao investigar um incidente onde o log existente não permite saber quem fez o quê, quando, ou em qual request
- Ao auditar uma base de código atrás de logs órfãos — `console.log`, strings interpoladas, `logger.warn` sem payload (modo auditoria, ver seção Output)
- Sempre que usuário humano e agente de IA podem agir sobre o mesmo dado ao mesmo tempo e é preciso provar depois quem fez o quê primeiro

**Quando NÃO usar (isso é outra skill):**

- Decidir O QUE deve ser logado por política de segurança/compliance (login failures, permission denials, audit trail) ou o que NUNCA pode aparecer num log (senha, token, PII) — isso é `/hm-security` DOMÍNIO 8. As duas se complementam: hm-security decide o conteúdo permitido, hm-logger garante que esse conteúdo chega com `traceId`/`user`/`http` do lado.
- Medir latência/performance a partir dos números do log — isso é `/hm-performance` domínio 3 (backend — API latency). O campo `http.latencyMs` que essa skill gera é exatamente o dado que `/hm-performance` consome.
- Checklist geral de qualidade de código — "zero prints em produção" é item do `/hm-engineer`. hm-logger é a implementação de referência desse item, não a auditoria em si.

## O contrato (StructuredLogPayload)

Todo log estruturado do sistema segue esse formato. `user` é o único campo verdadeiramente obrigatório — é o que separa um log rastreável de um log solto.

```ts
export interface StructuredLogPayload {
  traceId: string;
  user: LogUserContext;        // OBRIGATÓRIO — nunca opcional, nunca undefined
  http?: LogHttpContext;
  error?: LogErrorContext;
  meta?: LogMetaContext;
  reqBody?: unknown;           // só com captureBody habilitado (pattern 6)
  resBody?: unknown;
  [key: string]: unknown;
}

export interface LogUserContext {
  id: string;                  // sempre preenchido — ver pattern 2
  email?: string;
  orgId?: string;
}

export interface LogHttpContext {
  method: string;
  url: string;
  route?: string;
  statusCode: number;
  latencyMs: number;
  params?: Record<string, unknown>;
  query?: Record<string, unknown>;
}

export interface LogErrorContext {
  message: string;
  type: string;
  stack?: string;
  code?: string;
}

export interface LogMetaContext {
  before?: Record<string, unknown>;
  after?: Record<string, unknown>;
  [key: string]: unknown;
}
```

## Patterns obrigatórios

### 1. Caçador de usuário (cascata de fallback)

**Problema:** rota autenticada tem `req.session`. Webhook não tem. Handler de agente de IA processando uma fila também não tem. Se o logger exige `user` mas só sabe pegar de `req.session.user`, metade dos logs do sistema quebra ou vira `user: undefined` — voltando pra estaca zero.

**Pattern:**
```ts
export function huntUserContext(req: any, explicitUser?: Partial<LogUserContext>): LogUserContext {
  const session = req?.session;
  let userId = session?.user?.id || session?.userId;
  let userEmail = session?.user?.email;
  let orgId = session?.organization?.id || session?.orgId;

  // Middleware que já decodificou token (req.user)
  if (!userId && req?.user) {
    userId = req.user.id || req.user.sub;
    userEmail = req.user.email;
    orgId = req.user.orgId;
  }

  // Webhooks e chamadas disparadas por agente: usuário vem no corpo ou na query
  if (!userId) {
    userId = req?.body?.userId || req?.body?.user?.id || req?.query?.userId || req?.body?.actorId;
    orgId = orgId || req?.body?.orgId || req?.body?.organizationId || req?.query?.orgId;
  }

  // Override explícito sempre vence os fallbacks
  if (explicitUser) {
    userId = explicitUser.id || userId;
    userEmail = explicitUser.email || userEmail;
    orgId = explicitUser.orgId || orgId;
  }

  // Nunca undefined: se não achou ninguém, é a IA agindo sozinha — e isso também é um fato que precisa ficar registrado
  return {
    id: userId ?? "system-ai-context",
    ...(userEmail ? { email: userEmail } : {}),
    ...(orgId ? { orgId } : {}),
  };
}
```

A ordem da cascata importa: sessão → token decodificado → body/query → override explícito. `explicitUser` sempre vence porque é o chamador dizendo "eu já sei quem é, não precisa adivinhar."

**Adaptar por projeto:** os nomes dos campos (`session.user.id`, `req.user.sub`, `body.actorId`) mudam conforme o provider de auth (NextAuth, Clerk, JWT customizado). O que não muda é a ordem de fallback e o "nunca fica undefined".

### 2. Contexto HTTP automático, com latência

**Problema:** "esse endpoint tá lento" é uma reclamação que ninguém prova sem `latencyMs` gravado por request. Sem `method`/`url`/`statusCode`, cada log de erro exige abrir o código pra saber de qual rota ele veio.

**Pattern:**
```ts
let http: LogHttpContext | undefined;
if (req && req.method) {
  http = {
    method: req.method,
    url: req.url || "",
    route: req.route || req.baseUrl,   // ver nota de framework abaixo
    statusCode: res?.statusCode || 200,
    latencyMs: startTime ? Date.now() - startTime : 0,
    params: req.params && Object.keys(req.params).length ? req.params : undefined,
    query: req.query && Object.keys(req.query).length ? req.query : undefined,
  };
}
```

`startTime = Date.now()` é capturado no início do handler e passado pro log no fim — sem isso, `latencyMs` fica sempre 0. **Nota de framework:** `req.route` é um objeto no Express (`req.route.path`); em outros frameworks pode nem existir. Ajustar a extração pro framework do projeto — o que não muda é `latencyMs` sempre presente, porque é o dado que alimenta `/hm-performance`.

### 3. Erro serializado, nunca stack cru interpolado

**Problema:** `logger.error('Falhou: ' + err.message)` perde o `stack`, o `type` e qualquer `code` customizado. Quando o mesmo erro se repete em produção, não dá pra agrupar ocorrências porque cada mensagem interpolada sai levemente diferente.

**Pattern:**
```ts
let errorPayload: LogErrorContext | undefined;
if (error) {
  const serialized = serializeError(error, true); // helper da infra de logging do projeto
  errorPayload = {
    message: serialized.message,
    type: serialized.type,
    stack: serialized.stack,
    code: (error as any).code || serialized.code,
  };
}
```

Passa o objeto `error` inteiro pro logger, nunca `error.message` isolado — quem decide o que preservar é a serialização, não o call site.

### 4. Meta comparativo (before/after) pra mutação concorrente

**Problema:** usuário muda uma config na tela enquanto a IA insere dado na mesma tabela. Sem snapshot, o pós-morte vira "acho que foi X" — ninguém prova o que realmente mudou nem quem mudou primeiro.

**Pattern:**
```ts
export function buildCompareMeta(oldData: Record<string, unknown> | null, newData: Record<string, unknown> | null) {
  if (!oldData || !newData) return undefined;
  return { before: oldData, after: newData };
}

// uso:
hmLogger.logEvent("info", "Upgrade de plano efetuado concorrentemente", {
  req,
  startTime,
  meta: buildCompareMeta(dadosAntigos, dadosNovos),
});
```

Reservado pra mutação de estado real (upgrade de plano, mudança de permissão, config alterada) — não é lugar pra despejo de debug genérico. Se o antes/depois não importa pro incidente, não força o padrão.

### 5. Redação e captura de body — opt-in, nunca cru

**Problema:** logar `req.body` inteiro por padrão é vazamento de dado sensível esperando pra acontecer, e ainda estoura o custo de storage do provedor de log.

**Pattern:**
```ts
const config = getRuntimeConfig();
if (config.captureBody && req?.body) {
  payload.reqBody = truncateIfNeeded(req.body, config.maxBodyBytes);
}
```

Captura de body é **opt-in por config**, nunca padrão, e sempre truncada. Antes de truncar, o campo já deve ter passado por `redactSensitiveFields` — a lista do que precisa ser mascarado (senha, token, cartão, header de Authorization) é definida em `/hm-security` DOMÍNIO 8.2, não aqui. hm-logger garante que a captura é limitada e passa pela redação; o que entra na lista de redação é decisão de segurança.

### 6. TraceId herdado, não regerado

**Problema:** cada serviço numa arquitetura com múltiplas integrações externas gera seu próprio `traceId` do zero — uma requisição que atravessa vários serviços vira vários traces desconectados, e correlacionar o caminho completo de um evento exige adivinhação.

**Pattern:**
```ts
const traceId = req?.headers?.["x-request-id"] || req?.requestId || randomUUID();
```

Sempre tenta herdar antes de gerar. Se o serviço upstream já mandou um `x-request-id`, esse é o trace que importa — gerar um novo quebra a cadeia de correlação.

## O motor: `HigherMindLogger.logEvent`

Os patterns acima se juntam num único ponto de entrada. Toda chamada de log do projeto passa por aqui — nunca direto no logger base.

```ts
export class HigherMindLogger {
  private logger: Logger;
  constructor(baseLogger: Logger) { this.logger = baseLogger; }

  public logEvent(
    level: "info" | "warn" | "error" | "debug",
    message: string,
    context: {
      req: any; res?: any; startTime?: number;
      explicitUser?: Partial<LogUserContext>;
      meta?: Record<string, unknown> & { before?: any; after?: any };
      error?: unknown;
    }
  ) {
    const { req, res, startTime, explicitUser, meta, error } = context;
    const traceId = req?.headers?.["x-request-id"] || req?.requestId || randomUUID();
    const user = huntUserContext(req, explicitUser);
    // ... monta http (pattern 2), errorPayload (pattern 3), captura body opt-in (pattern 5)

    const payload: StructuredLogPayload = {
      traceId,
      user,
      ...(http ? { http } : {}),
      ...(errorPayload ? { error: errorPayload } : {}),
      ...(meta ? { meta } : {}),
    };

    this.logger[level](payload, `[HM-LOGGER] ${message}`);
  }
}

// acopla à infra de logging (Pino, Winston, etc.) já existente no projeto — não cria uma segunda instância paralela
export const hmLogger = new HigherMindLogger(basePinoLogger);
```

Se o projeto ainda não tem uma infra base de logging (`serializeError`, `truncateIfNeeded`, `redactSensitiveFields`, `getRuntimeConfig`), criar uma versão mínima antes de acoplar o `hmLogger` — não reimplementar essas funções toda vez que a skill roda. Pra fundação de projeto novo, ver `/hm-init`.

**Saída final** (o que chega no provedor de log):
```json
{
  "timestamp": "2026-07-01T22:15:30.123Z",
  "level": "warn",
  "service": "nome-do-servico",
  "traceId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "user": { "id": "usr_9923847293847", "orgId": "org_exemplo" },
  "http": { "method": "POST", "url": "/api/webhooks/trigger", "statusCode": 400, "latencyMs": 42 },
  "meta": { "agentId": "agent_gpt4_optimizer", "reason": "SecurityDomainPolicyViolation" },
  "msg": "[HM-LOGGER] Tentativa de envio de webhook para URL bloqueada"
}
```

## Exemplo: antes vs depois

### ❌ Log solto, sem contexto
```ts
logger.warn(
  `[WebhookBlocked] Tentativa de envio para URL bloqueada | Agent: ${data.agentId} | URL: ${rawUrl.substring(0, 50)}...`
);
```
Só existe enquanto alguém está olhando o terminal em tempo real. Depois disso, é ruído.

### ✅ Log estruturado, rastreável
```ts
const startTime = Date.now();
try {
  if (isBlockedUrl(rawUrl)) {
    hmLogger.logEvent("warn", "Tentativa de envio de webhook para URL bloqueada", {
      req,
      startTime,
      meta: { agentId: data.agentId, blockedUrl: rawUrl, reason: "SecurityDomainPolicyViolation" },
    });
    return res.status(400).json({ error: "Blocked URL" });
  }
} catch (err) {
  hmLogger.logEvent("error", "Falha crítica na execução do webhook da IA", { req, startTime, error: err });
}
```
`req` sozinho já entrega usuário, rota e latência — o dev só adiciona o que é específico do evento em `meta`.

## Anti-patterns (rejeitar imediato)

- `logger.warn()` com template literal interpolado (estilo `[Tag] valor: ${x}`) em vez de payload estruturado
- `console.log(...)` em rota de API, webhook ou job — proibido em produção (ver `/hm-engineer`)
- Log dentro de contexto de request/webhook sem `traceId`
- `user.id` deixado `undefined` quando existe qualquer fonte disponível (sessão, JWT, body, query) — sempre cai no fallback `system-ai-context`, nunca fica vazio
- `req.body` inteiro logado sem truncamento nem redação prévia
- Secret, token, senha ou PII dentro de `meta`/`reqBody` — ver `/hm-security` DOMÍNIO 8.2
- `meta.before`/`meta.after` usado como despejo de debug genérico em vez de snapshot de mutação real
- Novo `traceId` gerado quando já existe `x-request-id` upstream

## Output (modo auditoria)

Quando o pedido é auditar logging existente — não escrever um log novo — reportar nesse formato:

```
HM-LOGGER AUDIT
Projeto: [nome]
Logger base detectado: [Pino / Winston / console / nenhum]
Arquivos/rotas varridos: [count]

LOGS ÓRFÃOS ENCONTRADOS
[arquivo:linha] — [trecho do log] — falta: [traceId / user / http / error serializado]
  Fix: migrar pra hmLogger.logEvent(...)
[repetir por ocorrência relevante]

COBERTURA DO CONTRATO
traceId presente: PASS/FAIL (X% dos logs auditados)
user via huntUserContext: PASS/FAIL
contexto http com latencyMs: PASS/FAIL
erro serializado (não string crua): PASS/FAIL
redação de campo sensível: PASS/FAIL (ver /hm-security DOMÍNIO 8.2)

VEREDICTO
Logging rastreável / Logging órfão — bloqueante pra debug em produção
```

## Regras

- `user` nunca fica `undefined`. Se a cascata de fallback não achar ninguém, cai em `"system-ai-context"` — isso também é informação (a IA agiu sem ator humano identificável).
- `console.log`/`print` em path de produção é bloqueante — mesma régua do `/hm-engineer`.
- `traceId` sempre tenta herdar do header upstream antes de gerar um novo.
- Nenhum secret, token, senha ou PII em `meta`/`reqBody` — a lista do que redigir é do `/hm-security` DOMÍNIO 8.2; não reinventar aqui.
- Captura de `reqBody`/`resBody` é opt-in por config, sempre truncada, nunca o corpo cru por padrão.
- `meta.before`/`meta.after` só entra quando existe mutação de estado real disputável entre usuário e agente — não é campo de debug solto.
- `http.latencyMs` sempre presente quando `startTime` existe — é o dado que alimenta `/hm-performance`.
- Sempre rodar antes de shippar rota nova com webhook ou handler de agente/IA.
