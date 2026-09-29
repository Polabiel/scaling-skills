---
name: hm-api-contract
description: Validação e desenho de contratos de API entre backend e clientes. Use ao criar ou alterar endpoints HTTP, webhooks, schemas, responses, erros, autenticação, paginação, versionamento, idempotência ou integrações frontend/backend. Garante contratos explícitos, tipados, versionáveis, compatíveis e observáveis, complementando hm-engineer, hm-logger, hm-error-feedback e hm-qa.
---

# /hm-api-contract — Contrato de API (v1)

Você está agora em modo API contract.

Seu trabalho é garantir que backend e cliente concordem explicitamente sobre o formato, semântica, estados de erro, compatibilidade e evolução da API.

## Princípio central

**Uma API é um contrato, não apenas uma rota funcionando.**

Se o backend retorna uma estrutura e o frontend precisa adivinhar:
- qual campo existe;
- quando pode ser null;
- qual erro ocorreu;
- se pode tentar novamente;
- qual status significa conflito;
- se uma operação terminou ou está pendente;

o contrato está incompleto.

OpenAPI define operações, responses, schemas e componentes reutilizáveis. A especificação atual também permite respostas por códigos explícitos e por faixas.

## Baseline — inegociável

Para cada API alterada:

- request schema definido;
- response schema definido;
- erros conhecidos documentados;
- HTTP status coerente;
- campos obrigatórios e opcionais explícitos;
- nullability explícita;
- nomes estáveis;
- contrato validado automaticamente quando a stack suportar;
- breaking changes identificadas antes do merge;
- exemplos válidos quando o contrato for público ou consumido por múltiplos clientes.

## 1. Uma operação deve ter identidade estável

Toda operação deve possuir:
- método HTTP;
- rota;
- operationId quando OpenAPI estiver em uso;
- propósito claro;
- request/response previsíveis.

OpenAPI recomenda operationId único para identificar operações e permitir uso por ferramentas e bibliotecas.

## 2. Schema é contrato executável

Não trate documentação como texto separado do runtime.

Prefira:
- OpenAPI;
- JSON Schema;
- Zod;
- Pydantic;
- Valibot;
- equivalente da stack.

O mesmo contrato deve ser usado, quando possível, para:
- validação;
- geração de tipos;
- documentação;
- testes;
- mocks.

## 3. Request e response devem ser previsíveis

Evite:
- campo que muda de tipo;
- objeto que às vezes é array;
- string que às vezes representa null;
- response cujo formato depende de mensagens internas;
- campos obrigatórios que surgem sem versionamento.

## 4. Erros fazem parte do contrato

Uma operação deve documentar:
- sucesso;
- erros conhecidos;
- erro padrão inesperado.

OpenAPI define que responses documentem a resposta de sucesso e os erros conhecidos da operação.

Para APIs HTTP, prefira um contrato estruturado inspirado em RFC 9457:

~~~json
{
  "type": "https://example.com/problems/resource-conflict",
  "title": "Não foi possível concluir a operação",
  "status": 409,
  "detail": "O recurso foi alterado por outra operação.",
  "instance": "/problems/evt_123",
  "code": "RESOURCE_CONFLICT",
  "traceId": "..."
}
~~~

Não exponha stack, SQL, path interno ou segredo.

Para arquitetura detalhada de erros, consultar /hm-engineer.

Para apresentação do erro ao usuário, consultar /hm-error-feedback.

Para observabilidade do erro, consultar /hm-logger.

## 5. HTTP status deve representar semântica

Use o código de status de acordo com o contrato real.

Exemplos comuns:
- 400/422 para entrada inválida, conforme o contrato;
- 401 para autenticação;
- 403 para autorização;
- 404 para recurso não encontrado;
- 409 para conflito;
- 429 para rate limiting;
- 5xx para falhas do servidor/dependências conforme a natureza.

Não use 200 com um campo error para esconder falha de transporte, a menos que isso seja uma decisão explícita de protocolo.

## 6. Nullability é contrato

Diferencie:
- campo ausente;
- campo presente = null;
- campo presente = valor vazio;
- campo presente = default.

O frontend não deve precisar inferir a diferença.

## 7. Compatibilidade

Antes de alterar uma API, pergunte:
- clientes antigos continuam funcionando?
- removi campo?
- mudei tipo?
- mudei semântica?
- mudei status?
- mudei erro?
- transformei opcional em obrigatório?
- alterei ordenação/paginação?
- alterei comportamento default?

Mudanças incompatíveis devem ser tratadas como breaking change, com estratégia de migração/versionamento.

## 8. Idempotência

Operações que podem produzir efeitos duplicados devem responder:
- podem ser repetidas?
- existe idempotency key?
- como o servidor reconhece repetição?
- qual resposta retorna para repetição?
- existe janela de validade?
- timeout deixa o estado incerto?

Especialmente importante em:
- pagamentos;
- criação de entidades;
- webhooks;
- envio de mensagens;
- jobs.

## 9. Paginação e ordenação

Nunca deixe o consumidor adivinhar como grandes coleções funcionam.

Defina:
- limite default;
- limite máximo;
- ordenação default;
- cursor ou paginação utilizada;
- comportamento quando não há próxima página;
- estabilidade da ordenação.

Evite endpoints que retornam coleções potencialmente ilimitadas.

## 10. Webhooks também são APIs

Para webhook:
- payload versionado;
- event type estável;
- event id;
- timestamp;
- assinatura/autenticação;
- retry;
- idempotência;
- resposta esperada;
- comportamento quando o consumidor demora.

Não confunda eventId do provider com traceId.

## 11. Testes de contrato

Quando dois serviços ou um frontend/backend evoluem separadamente, teste:
- response real contra schema;
- request inválido;
- cada erro conhecido;
- campos opcionais;
- null;
- compatibilidade com cliente anterior;
- breaking change.

Contract test é diferente de apenas unit test.

## 12. Gerenciamento central de erros

Evite:

~~~ts
catch (error) {
  return res.status(500).json({ message: error.message });
}
~~~

Prefira:

~~~text
domain error
→ API mapper
→ HTTP response
→ hm-logger
→ hm-error-feedback
~~~

Isso elimina divergências entre endpoints.

## Integração

> Para arquitetura detalhada de criação, classificação, causa, retry e tratamento de erros, usar /hm-engineer.

> Para observabilidade, correlação, eventName, Loki/Grafana e tracing, usar /hm-logger.

> Para tradução do contrato técnico em feedback visual, usar /hm-error-feedback.

> Para validação prática do contrato contra implementação real, usar /hm-qa.

## Anti-patterns críticos

- response sem schema;
- erro dependente de parsing da message;
- 200 representando falha sem semântica definida;
- campo mudando de tipo silenciosamente;
- campo removido sem estratégia;
- nullability implícita;
- collection sem limite;
- retry sem idempotência em operação não idempotente;
- webhook sem eventId;
- webhook sem proteção contra duplicidade;
- API pública retornando stack trace;
- contratos diferentes para o mesmo erro em endpoints equivalentes;
- OpenAPI dizendo uma coisa e runtime entregando outra.

## Checklist de revisão

- [ ] operationId/identidade definida
- [ ] request schema
- [ ] success response schema
- [ ] known error responses
- [ ] status codes
- [ ] nullability
- [ ] breaking changes
- [ ] idempotência
- [ ] paginação
- [ ] webhook contract quando aplicável
- [ ] testes de contrato
- [ ] integração hm-engineer
- [ ] integração hm-logger
- [ ] integração hm-error-feedback

## Output

~~~
HM-API-CONTRACT
Operações auditadas: [N]

CONTRATO
Request: PASS/FAIL
Response: PASS/FAIL
Errors: PASS/FAIL
HTTP semantics: PASS/FAIL
Nullability: PASS/FAIL

COMPATIBILIDADE
Backward compatible: SIM/NÃO
Breaking changes: [list]

RESILIÊNCIA
Idempotência: PASS/FAIL/N-A
Retry: PASS/FAIL/N-A
Webhooks: PASS/FAIL/N-A

TESTES
Contract tests: PASS/FAIL
Schema/runtime parity: PASS/FAIL

VEREDICTO
Contract-ready / BLOQUEADO
~~~

## Fontes

- OpenAPI Specification v3.2.1: https://spec.openapis.org/oas/v3.2.1.html
- RFC 9457 — Problem Details: https://www.rfc-editor.org/rfc/rfc9457.html
