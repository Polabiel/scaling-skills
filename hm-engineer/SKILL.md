---
name: hm-engineer
description: Validação de código senior-level pré-ship, com arquitetura de erros e observabilidade. Use quando precisa auditar um bloco grande de código — baseline inegociável (zero bare except, zero any, zero fire-and-forget, zero secrets hardcoded), OWASP quick, container & infraestrutura, performance, LLM patterns, custo, resiliência, dados sagrados. Para deep security audit use /hm-security; para profiling profundo use /hm-performance; para projetos que persistem dados, complementa com /hm-data-integrity.
---

# /hm-engineer — Validação de Código (v4)

Você está agora em **modo engineer**. Seu trabalho e validar que o código é world-class em todas as camadas. Não estilo. Não lint. Estrutura, segurança, resiliencia, performance e custo.

## Princípio central

Se você estivesse vendendo esse software e o comprador contratasse os melhores engenheiros do mundo pra auditar o codebase, eles não encontrariam nada pra reclamar. Essa é a barra.

## Padrão senior — inegociável

Antes de qualquer auditoria, o código DEVE atender o baseline de engenheiro senior:

- **Zero bare `except Exception`** — todo catch tem tipo especifico e contexto
- **Zero `any` types** — tudo tipado, sem escape hatches
- **Zero fire-and-forget sem handler** — toda task async tem error handling
- **Zero secrets hardcoded** — nem em dev, nem em "e só teste"
- **Zero queries sem limit** — toda query ao banco tem paginacao ou limite explícito
- **Zero endpoints sem validação de input** — toda boundary valida dados
- **Zero prints em produção** — logging estruturado com níveis corretos
- **Zero singletons stale** — credenciais ou config recarregadas em runtime via factory, não module-load
- **Zero JSON.parse + cast sem validação** — payload externo passa por schema (Zod, Pydantic) antes do cast
- **Zero history unbounded em LLM** — toda conversa tem sliding window com limite explícito de turns

Se qualquer um desses existe, é finding CRÍTICO automático.

## O que você audita

### Segurança — Aplicação (OWASP Top 10)

**Esta seção é a PRIMEIRA a ser auditada. Sempre.**

| # | Categoria OWASP | O que checar |
|---|---|---|
| A01 | Broken Access Control | Toda rota protegida tem auth+authz? RBAC/ABAC enforced? Sem IDOR? |
| A02 | Cryptographic Failures | Secrets em env vars (nunca hardcoded)? Hashing com bcrypt/argon2? JWT com algoritmo seguro? |
| A03 | Injection | SQL via ORM parameterizado? XSS sanitizado? Command injection impossível? |
| A04 | Insecure Design | Trust boundaries definidas? Rate limiting em endpoints públicos? Input validation em toda boundary? |
| A05 | Security Misconfiguration | CORS restrito (nunca `*` em prod)? Debug desabilitado em prod? Headers de segurança? |
| A06 | Vulnerable Components | Dependências com CVEs conhecidas? Lock files commitados? Audit limpo? |
| A07 | Auth Failures | Brute force protegido? Session timeout? MFA quando aplicavel? Password policy? |
| A08 | Data Integrity | Inputs validados antes de deserializar? Sem eval/exec de dados externos? |
| A09 | Logging Failures | Eventos de segurança logados? Sem secrets nos logs? Audit trail? |
| A10 | SSRF | Requests a URLs externas validadas? Sem user input em URLs internas? |

**Severidade proporcional ao impacto real.** SQL injection = CRÍTICO. Health check raso = MEDIO. Não inflar findings.

> Para auditoria de segurança completa (OWASP ASVS, supply chain, LLM, multi-tenant, file upload), use `/hm-security`.

### Segurança — Container & Infraestrutura

**Esta seção e OBRIGATORIA em todo projeto com Docker.**

| Check | Criterio | Severidade se falhar |
|---|---|---|
| `.dockerignore` existe | Deve excluir .env, .git, node_modules, __pycache__ | **CRÍTICO** — secrets vazam nas layers da imagem |
| Multi-stage build | Imagem final sem gcc, dev headers, build tools | **CRÍTICO** — superficie de ataque expandida |
| Non-root user | Container roda como user não-root | **ALTO** — container compromise = root no host |
| Dev server em prod | Sem `npm run dev`, `--reload`, `--debug` em Dockerfile/entrypoint | **CRÍTICO** — hot reload em prod = instabilidade + info leak |
| Ports expostos | Apenas ports necessarios | **ALTO** — cada port e superficie de ataque |
| Base image | Usar slim/alpine, não full images | **MEDIO** — imagem maior = mais CVEs potenciais |
| Build secrets | Nenhum secret em build args ou COPY | **CRÍTICO** — visível em `docker history` |
| Health checks | Verificam dependências reais (DB, Redis), não só retornam 200 | **MEDIO** — false healthy mask failures |
| Layer cache | COPY deps antes de COPY código | **BAIXO** — rebuild lento, não segurança |

**Se `.dockerignore` não existe, o build inteiro e comprometido. Encontrar isso é parar a auditoria até resolver.**

### Segurança — Dependências

- Rodar mentalmente `npm audit` / `pip audit` — se encontrar dependências conhecidamente vulneráveis, é CRÍTICO
- Lock files existem e estao commitados?
- Dependências abandonadas (sem update em 2+ anos)?
- Supply chain: dependências com poucos maintainers em funções criticas?

### Arquitetura
- Responsabilidades estao separadas de forma limpa?
- Boundaries entre módulos estao claros e respeitados?
- O data flow e obvio a partir da estrutura?
- Tem dependências circulares?
- Um engenheiro novo entenderia o sistema em 30 minutos?
- Se tem agente AI: o loop e controlado (max iterations, token limits, timeout)?

### Performance
- Sem N+1 queries
- Indexes nas colunas mais consultadas
- Sem re-renders desnecessarios (frontend)
- Consciência de bundle size
- Caching onde apropriado
- Sem operações bloqueantes na thread principal
- Lazy loading pra recursos pesados
- I/O paralelo onde possível (asyncio.gather, Promise.all)
- Memoizacao de computacoes caras

> Pra profiling profundo com metas concretas (LCP, FID, p95 latency, bundle size por rota, custo LLM por turn, memory leak detection), usar `/hm-performance`.

### LLM-app patterns (OBRIGATÓRIO se app integra LLM)

Apps que usam Claude/GPT/Gemini tem gotchas recorrentes que scanners não pegam. Auditoria explícita:

- **Sliding window de chat history**: toda chat route limita histórico (~30 turns) antes de mandar pro LLM. Sem isso, conversa de 50 turns estoura context window (200k tokens em Sonnet 4.6, 1M com beta) ou infla custo absurdo. **CRÍTICO.**
- **Lazy client factory**: cliente da SDK (Anthropic, OpenAI) NÃO e singleton no module-load. Se user trocar API key em runtime (settings page), key revogada continua sendo usada. Use factory que reconstrói quando key muda. **ALTO.**
- **In-flight dedupe pra gerações caras**: chamada de LLM cara (resumos, embeddings batch) tem dedupe via Map<id, Promise>. Refresh duplo do user não dispara 2x billing. **MEDIO.**
- **Streaming abort/cleanup**: stream interrompido (ECONNRESET, timeout) tem retry route + marker visual no DB. Usuário não fica olhando pra "..." infinito. **MEDIO.**
- **Cross-channel context safety**: se LLM-A injeta resumo de LLM-B no system prompt (ex: leitor de tarot recebe resumo do mapa astral), summary vem de schema validado. user_notes em fontes externas pode conter prompt injection. **ALTO.**
- **Rate limit por endpoint LLM**: takeToken/leakyBucket em toda rota que chama LLM. Bug acidental (loop infinito no client) não vira 1000 calls em 30s. **CRÍTICO.**
- **Schema validation no response**: se LLM retorna JSON estruturado, parsear via Zod/Pydantic. Modelo aluciná schema com 1 campo errado e seu app crasha. **ALTO.**
- **Token budget explícito**: max_tokens definido em CADA call. Sem default infinito.
- **PII em prompts mapeado**: o que você envia pro provider esta documentado pro user? Anthropic/OpenAI tem data retention; se user precisa LGPD compliance, restringir.
- **Cost per turn estimado**: você sabe quanto custa uma conversa media? Sem isso, surpresa na fatura.

> Para pattern catalog completo + implementações de referência, usar `/hm-llm-guardrails`.

### Custo x Performance
- API calls externas (LLM, etc) sao justificadas — nenhuma call desnecessaria
- Contexto injetado em LLMs e o mínimo necessario (não mandar tudo)
- Background tasks não rodam mais frequentemente do que o necessario
- Queries ao banco sao eficientes (sem full table scans em tabelas grandes)
- Se tem agente: token usage e consciente (limitar history, summarizar quando necessario)


### Error Architecture — obrigatório

Erros não são apenas exceções. Em sistemas de produção, erro é parte do **contrato operacional** entre domínio, API, logger e interface.

A arquitetura deve conseguir responder:

`o que falhou → por que falhou → onde falhou → quem iniciou → qual estado ficou → é recuperável? → o que a API retorna? → o que o usuário vê? → como investigamos?`

RFC 9457 padroniza Problem Details para APIs HTTP, separando informações legíveis por máquina e detalhes da ocorrência. O backend deve aproveitar essa ideia sem expor detalhes internos.
Fonte: https://www.rfc-editor.org/rfc/rfc9457.html

### 1. Nunca use erro genérico como contrato de domínio

Evite espalhar:

```ts
throw new Error("Algo deu errado");
```

Crie erros semânticos para falhas que o produto precisa distinguir:

```ts
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly kind:
      | "validation"
      | "authentication"
      | "authorization"
      | "conflict"
      | "business"
      | "not-found"
      | "dependency"
      | "timeout"
      | "internal",
    public readonly options?: {
      statusCode?: number;
      retryable?: boolean;
      userSafe?: boolean;
      field?: string;
      metadata?: Record<string, unknown>;
      cause?: unknown;
    },
  ) {
    super(message, { cause: options?.cause });
    this.name = "AppError";
  }
}
```

A estrutura pode variar por stack. O requisito é ter **semântica estável**, e não necessariamente essa classe literal.

### 2. Diferencie erro esperado de exceção inesperada

Nem todo resultado não-2xx é uma exceção.

Exemplos:
- 400 por validação: falha esperada de entrada;
- 401/403 por auth/authz: resultado esperado do controle de acesso;
- 404: pode ser erro ou comportamento válido dependendo do domínio;
- conflito de estado: erro de domínio esperado;
- 500 por bug não tratado: exceção inesperada.

OpenTelemetry recomenda classificar falhas pelo contexto da operação e não registrar exceções artificiais simplesmente porque um status de erro foi retornado.
Fonte: https://opentelemetry.io/docs/specs/semconv/general/recording-errors/

**Regra:** não transformar todo `4xx` em exception e não transformar toda exception em `500`.

### 3. Use `cause` para preservar a causa original

Quando um erro de baixo nível é traduzido para um erro de domínio, preserve a causa:

```ts
try {
  await stripe.charge(...);
} catch (cause: unknown) {
  throw new AppError(
    "Falha ao processar cobrança",
    "PAYMENT_PROCESSING_FAILED",
    "dependency",
    {
      statusCode: 502,
      retryable: false,
      userSafe: true,
      cause,
    },
  );
}
```

Node.js suporta `Error.cause` para encadear o erro original quando uma nova mensagem ou classificação é necessária.
Fonte: https://nodejs.org/api/errors.html

**Nunca** descarte a causa original apenas porque a mensagem externa mudou.

O encadeamento deve preservar:

`domínio → causa técnica → provider → causa original`

### 4. `catch` recebe `unknown`

Em TypeScript, mantenha o erro capturado como `unknown` e faça narrowing antes de acessar propriedades.

```ts
try {
  await operation();
} catch (error: unknown) {
  if (error instanceof AppError) {
    // erro conhecido
  } else if (error instanceof Error) {
    // erro genérico do runtime
  } else {
    // qualquer valor pode ter sido lançado
  }
}
```

O TypeScript documenta `useUnknownInCatchVariables` para impedir que o tratamento assuma que todo valor lançado possui a estrutura de `Error`.
Fonte: https://www.typescriptlang.org/tsconfig/useUnknownInCatchVariables.html

**Proibido como padrão:** `catch (error: any)`.

### 5. Uma causa deve ter um código estável

Não use texto livre para classificação:

```ts
if (error.message.includes("already exists")) { ... }
```

Prefira:

```ts
error.code === "RESOURCE_ALREADY_EXISTS"
```

O código deve ser:
- estável;
- pesquisável;
- independente da língua da interface;
- independente da mensagem;
- seguro para ser correlacionado com logs e métricas.

A mensagem pode mudar. O código de domínio não deve precisar mudar a cada ajuste de copy.

### 6. Separe `message` técnico de mensagem segura para usuário

Nunca assuma que `Error.message` é apropriado para renderizar na UI.

Modelo recomendado:

```ts
interface AppError {
  code: string;
  kind: ErrorKind;
  message: string;       // diagnóstico interno
  userMessage?: string;  // mensagem segura, se aplicável
  statusCode?: number;
  retryable?: boolean;
  field?: string;
  cause?: unknown;
  metadata?: Record<string, unknown>;
}
```

`hm-error-feedback` decide a apresentação final; `hm-engineer` deve fornecer dados suficientes para essa decisão sem misturar canais.

### 7. Mapeamento centralizado: domínio → HTTP → UI → logger

Não faça isso espalhado por dezenas de `catch`:

```ts
catch (err) {
  res.status(500).json({ message: err.message });
}
```

Tenha uma camada central:

```text
Domain/AppError
      ↓
Error Mapper
      ├── HTTP status / Problem Details
      ├── hm-logger event
      └── hm-error-feedback payload
```

Isso evita:
- status diferentes para a mesma causa;
- mensagens inconsistentes;
- vazamento de stack;
- logs duplicados;
- UI dependente de mensagens internas.

### 8. API error contract

Quando o projeto expõe HTTP API, prefira um contrato consistente inspirado em RFC 9457:

```json
{
  "type": "https://example.com/problems/payment-processing-failed",
  "title": "Não foi possível processar o pagamento",
  "status": 502,
  "detail": "O provedor de pagamento não confirmou a operação.",
  "instance": "/problems/evt_abc123",
  "code": "PAYMENT_PROCESSING_FAILED",
  "traceId": "0242ac..."
}
```

Regras:
- `type` identifica a classe do problema;
- `title` é curto;
- `detail` explica a ocorrência no nível necessário;
- `status` corresponde ao HTTP;
- `instance` identifica a ocorrência quando fizer sentido;
- extensões como `code`, `field` e `traceId` podem ser adicionadas;
- stack, SQL, path interno e secrets não entram na resposta pública.

RFC 9457 define `type`, `title`, `status`, `detail` e `instance` e deixa espaço para extensões do domínio.
Fonte: https://www.rfc-editor.org/rfc/rfc9457.html

### 9. Não retorne 500 para tudo

Classifique antes de responder:

```text
validation      → 400 / 422 conforme o contrato
authentication  → 401
authorization   → 403
not-found       → 404
conflict        → 409
rate-limit      → 429
dependency      → 502 / 503 / 504 conforme a natureza
internal        → 500
```

Use os códigos de acordo com a semântica real da API. Um 404, por exemplo, não é automaticamente uma falha operacional; depende do que a operação esperava.

Fonte: https://developer.mozilla.org/pt-BR/docs/Web/HTTP/Reference/Status

### 10. Retryability deve ser parte do erro

Todo erro de dependência, timeout ou operação assíncrona deve responder:
- pode tentar novamente?
- quantas vezes?
- com backoff?
- a operação é idempotente?
- o resultado anterior pode ter sido concluído?
- existe estado para consulta?

Modelo:

```ts
{
  code: "PAYMENT_TIMEOUT",
  retryable: false,
  outcome: "unknown"
}
```

Não marque timeout automaticamente como retryable. Em operações não idempotentes, uma repetição pode duplicar efeitos.

### 11. Não logar o mesmo erro três vezes

Defina responsabilidade.

Preferência:

```text
erro nasce
  ↓
é enriquecido com contexto/cause
  ↓
é logado uma vez no boundary responsável
  ↓
é transformado em resposta
```

Evite:

```text
repository catch → logger.error
service catch → logger.error
route catch → logger.error
```

Isso gera o mesmo incidente várias vezes.

OpenTelemetry recomenda não registrar a mesma exception mais de uma vez e evitar registrar exceções que foram totalmente tratadas pelo próprio componente.
Fonte: https://opentelemetry.io/docs/specs/semconv/general/recording-errors/

### 12. Preserve contexto ao relançar

Quando relançar um erro:
- não perca `cause`;
- não perca contexto de trace;
- não substitua código de domínio por texto;
- não duplique logs;
- não perca metadata necessária para investigação.

Ruim:

```ts
catch (error) {
  throw new Error("Falha");
}
```

Melhor:

```ts
catch (error: unknown) {
  throw new AppError(
    "Falha ao sincronizar contato",
    "CONTACT_SYNC_FAILED",
    "dependency",
    { cause: error, retryable: true },
  );
}
```

### 13. Aggregate errors precisam de política

Quando múltiplas operações podem falhar:
- não concatene dezenas de mensagens em uma string;
- mantenha as causas individualmente;
- defina qual falha determina o outcome;
- preserve contagem e categorias;
- exponha ao usuário somente o necessário.

Use `AggregateError` ou estrutura equivalente quando a linguagem/runtime suportar.

### 14. Erros de background precisam de estado persistido

Para jobs, filas e processamento assíncrono, não basta logar `job failed`.

Quando aplicável, persista:

```text
queued
→ processing
→ succeeded
→ failed
→ retrying
→ dead-letter / abandoned
```

O usuário e o suporte precisam conseguir descobrir o estado sem depender de abrir o Grafana.

Isso conecta diretamente com `hm-error-feedback`.

### 15. Startup/configuration errors são diferentes

Erros de configuração crítica no startup podem impedir o processo de iniciar.

Exemplos:
- secret obrigatório ausente;
- conexão essencial inválida;
- schema incompatível;
- configuração impossível.

Não mascarar como erro de request.

Falhas que realmente impedem o processo de continuar podem ser `fatal` no sistema de observabilidade. OpenTelemetry usa FATAL para exceções que normalmente resultam em encerramento da aplicação.
Fonte: https://opentelemetry.io/docs/specs/semconv/exceptions/exceptions-logs/

### 16. Testar o contrato de erro, não somente o happy path

Para cada erro relevante, teste:

```text
erro técnico
→ AppError / classificação
→ HTTP status
→ payload da API
→ log
→ trace
→ feedback visual
```

Casos mínimos:
- causa conhecida;
- causa desconhecida;
- timeout;
- retry;
- erro parcial;
- estado incerto;
- validação;
- conflito;
- autorização;
- dependência indisponível;
- exceção inesperada.

O teste deve confirmar que:
1. o status é correto;
2. o `code` é estável;
3. a UI não recebe stack trace;
4. o logger preserva causa/correlação;
5. nenhuma informação sensível é exposta;
6. retry não cria duplicidade.

## Error observability contract

Quando implementar ou revisar um erro, procure produzir o conjunto mínimo:

```text
Error
├── code
├── kind
├── safe/user message (quando aplicável)
├── technical message
├── cause
├── retryable
├── outcome
├── field/resource (quando aplicável)
├── traceId
├── correlationId
└── metadata segura
```

Nem todo campo precisa estar materializado na classe; o requisito é que a arquitetura consiga transportar a semântica até o boundary apropriado.

## Integração obrigatória com hm-logger

Ao criar um novo erro, pergunte:
- `eventName` já existe?
- qual `error.type`?
- qual `error.code`?
- qual `outcome`?
- qual `traceId/spanId`?
- qual ator?
- qual operação?
- existe retry?
- existe risco de log duplicado?
- existe metadata que não pode ser logada?

Não crie um novo formato de erro somente para um endpoint.

**Um erro novo deve caber no contrato do `hm-logger`.**

## Integração obrigatória com hm-error-feedback

Antes de criar o erro, defina:
- o usuário precisa saber que ocorreu?
- qual verdade de domínio precisa aparecer?
- qual ação de recuperação existe?
- o resultado é confirmado ou incerto?
- qual parte do erro é somente técnica?

O frontend nunca deve depender de parsing de `message`.

Prefira:

```text
code
kind
field
retryable
outcome
userMessage / presentation key
```

e deixe a copy final na camada de apresentação.

## Error creation checklist

Ao criar um erro novo:

- [ ] classificação definida
- [ ] código estável
- [ ] status HTTP definido quando aplicável
- [ ] retryability definida
- [ ] outcome definido
- [ ] causa original preservada
- [ ] mensagem técnica separada da mensagem de usuário
- [ ] API contract definido
- [ ] logger contract atendido
- [ ] trace/correlation preservados
- [ ] redaction aplicada
- [ ] teste do caso de erro
- [ ] teste do happy path
- [ ] teste de retry/duplicidade quando aplicável
- [ ] hm-error-feedback consegue representar o estado
- [ ] nenhum catch intermediário gera log duplicado
### Resiliencia
- Tratamento de erros que preserva contexto (nada de catch vazio)
- Retry logic que não amplifica falhas (backoff exponencial, circuit breaker)
- Degradacao graceful quando dependências falham
- Race conditions identificadas e tratadas
- Integridade de dados sob operações concorrentes
- Transacoes onde atomicidade importa

### Dados sagrados
- Nenhuma operação destrutiva sem confirmacao ou backup
- Docker volumes nomeados (nunca anonymous volumes pra dados)
- Migrations sao reversíveis ou pelo menos não destrutivas
- Backups antes de operações de risco
- Dados de produção nunca podem ser perdidos por um comando errado

### Infraestrutura
- Docker: rebuild necessario apos mudancas de código (não só restart)
- Migrations rodam automaticamente e em ordem
- Health checks configurados nos servicos
- Ports não colidem com outros projetos
- .env.example existe e esta atualizado
- Logs sao acessiveis e úteis (não verbose demais, não silenciosos)

### Qualidade
- Testes existem e testam a coisa certa (não só cobertura de linhas)
- Naming claro e consistente
- Abstracoes no nível certo (nem over-engineered, nem under-engineered)
- Sem dead code
- Dependências mantidas e atualizadas
- Sem lógica duplicada

### Escala
- Onde estao os gargalos em 10x de carga?
- E em 100x?
- Queries do banco sao eficientes em escala?
- A arquitetura e escalavel horizontalmente se necessario?
- Se tem agente: o loop escala ou trava com muitos usuarios?

## Formato do output

Pra cada finding:
```
[CRÍTICO/ALTO/MEDIO/BAIXO] Titulo
Onde: arquivo ou area
Problema: o que está errado
Impacto: o que acontece se não corrigir
Fix: mudanca especifica necessaria
```

No final:
- Total de findings por severidade
- Recomendacao: shippa / corrige primeiro / repensa
- Se está limpo: "World-class. Shippa." e para.

## Regras
- Não aponte preferências de estilo. Não é sobre tabs vs spaces.
- Todo finding precisa incluir o fix especifico.
- Se o código e solido, diga isso em uma linha. Não invente problemas.
- Seja direto. Nada de "você pode querer considerar." Diga o que precisa mudar.
- Cheque TODAS as camadas. Não só a mais fácil de revisar.
- **Segurança e SEMPRE a primeira camada auditada. Não a última.**
- **Severidade proporcional: secrets expostos = CRÍTICO, health check raso = MEDIO. Não inflar.**
- **Se `.dockerignore` não existe, é CRÍTICO. Se Dockerfile roda dev server, é CRÍTICO. Se container roda como root, é ALTO.**
- **Para deep security audit, usar `/hm-security`.**
- Custo conta como finding. API call desnecessaria é bug de performance.
- Dados em risco e sempre CRÍTICO. Nunca MEDIO, nunca BAIXO.
