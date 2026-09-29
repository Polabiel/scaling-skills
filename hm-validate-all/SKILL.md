---
name: hm-validate-all
description: Orquestrador pré-ship que dispara as 21 skills de validação (align, sequoia, security, data-integrity, engineer, llm-guardrails, logger, qa, performance, ux-flow, designer, deploy) em ondas com gates duros, convoca council pra empate/override, consolida findings priorizados em UM único report e declara baseline-ready (Dev Team) ou BLOQUEADO. Use antes de qualquer ship pra produção, após sprint grande, ou quando quer confiança de "está pronto" em uma checagem só. Product-ready continua sendo prerrogativa do Owner.
---

# /hm-validate-all — Validação Completa Pré-Ship (v2)

Você está agora em **modo orquestrador**. Seu trabalho e disparar as skills de validação aplicáveis em ondas otimizadas, consolidar findings, e entregar UM único report priorizado que diz: **baseline-ready** (Dev Team pode entregar pro Owner) OU **BLOQUEADO**.

## Princípio central

Validação manual passo-a-passo perde tempo. Orquestracao ganha. Mesma barra de qualidade que rodar cada skill isolada, sem o overhead de checkin manual entre cada uma. **Bloqueante ship e tratado como bloqueante. Technical debt e tratado como debt.**

Cobertura parcial e a armadilha: código limpo com dado em risco não shippa. Interface bonita com fluxo indecifravel não shippa. Feature perfeita construída pro passado não deveria nem ter sido construída. Validar "tudo" significa **estratégia + fundação + código + execução + experiência + entrega**, não só as cinco checagens mais óbvias.

## Esta skill declara baseline-ready, não product-ready

- **Baseline-ready** = Dev Team validou os 5 checks abaixo + as auditorias técnicas aplicáveis. Skill declara.
- **Product-ready** = Owner validou UX, fit com tese, qualidade visual end-to-end. **Só Owner declara.**
- **Estratégia** (`/hm-align`, `/hm-sequoia`) nunca bloqueia baseline-ready. Vai pra seção DECISÃO DE OWNER. Você reporta o desalinhamento, Owner crava.

Os 5 checks obrigatorios do baseline-ready (do `~/.claude/CLAUDE.md` global) já sao cobertos pelo `/hm-qa` v4. Esta skill consolida + adiciona as outras 11 camadas:

1. **typecheck verde** — coberto por `/hm-qa` + `/hm-engineer`
2. **lint verde** — coberto por `/hm-qa` + `/hm-engineer`
3. **smoke test rodado pelo Dev Team** — coberto por `/hm-qa`
4. **zero `console.error` em código novo** — coberto por `/hm-qa`
5. **zero TODO CRÍTICO em código novo** — coberto por `/hm-qa`

Se qualquer um dos 5 falhar, veredicto e BLOQUEADO. Sem exceção. Owner não valida produto enquanto baseline não esta verde.

## Quando usar

- Antes de qualquer ship pra produção (interno ou externo)
- Apos sprint grande (multi-features, refactors estruturais)
- Antes de owner aprovar entrega final
- Quando quer confiança de "esta pronto" em uma checagem só

**Não usar pra:** validação parcial (ex: só segurança → use `/hm-security` direto), debug de bug especifico, code review de PR pequena (use `/review`).

## Mapa de responsabilidade

Cada skill e dona de uma pergunta. Não há sobreposição de veredicto — há sobreposição de varredura, resolvida na seção Anti-duplicação.

| # | Skill | Pergunta que responde | Aplicável quando |
|---|---|---|---|
| 1 | `/hm-align` | Isso e a coisa certa pra construir? | Sempre |
| 2 | `/hm-sequoia` | Isso aponta pro futuro ou otimiza o passado? | Ship com aposta estratégica (feature nova, pivô, stack nova) |
| 3 | `/hm-security` | Alguém consegue invadir, vazar ou abusar? | Sempre |
| 4 | `/hm-data-integrity` | O dado do user pode ser perdido? | Projeto persiste qualquer coisa (DB, files, blob) |
| 5 | `/hm-engineer` | O código aguenta ser mantido e escalado? | Sempre |
| 6 | `/hm-llm-guardrails` | A integração LLM e produto ou demo? | App chama LLM (Claude/GPT/Gemini/Bedrock/Llama) |
| 7 | `/hm-logger` | Dá pra reconstruir um incidente depois? | Existe rota de API, webhook, job ou handler de agente |
| 8 | `/hm-qa` | Funciona na prática, não na teoria? | Sempre |
| 9 | `/hm-performance` | Os números estão dentro do alvo? | Tem frontend, endpoint user-facing ou custo de LLM |
| 10 | `/hm-ux-flow` | O user decide com clareza, na ordem certa? | Existe fluxo multi-step (UI ou CLI) |
| 11 | `/hm-designer` | A interface atende a barra visual? | Existe interface gráfica |
| 12 | `/hm-deploy` | Sobe do zero, reprodutível, sem surpresa? | Sempre que existe artefato de distribuicao |
| 13 | `/hm-product` | Estamos resolvendo um problema real para um usuário real? | Feature nova, requisito ambíguo ou mudança de produto |
| 14 | `/hm-api-contract` | Backend e clientes compartilham um contrato explícito? | API, webhook, schema ou integração alterados |
| 15 | `/hm-state-machine` | Todos os estados e transições são possíveis e testáveis? | Fluxo com async, loading, retry, timeout, conflito ou múltiplos estados |
| 16 | `/hm-analytics` | Conseguimos medir comportamento e resultado real? | Feature user-facing, conversão, onboarding, retenção ou experimento |
| 17 | `/hm-accessibility` | A interface pode ser percebida e operada por diferentes usuários? | Existe interface gráfica |
| 18 | `/hm-copy` | O texto torna a ação e o estado claros? | Existe copy significativa em UI |
| 19 | `/hm-error-feedback` | O erro real chega ao usuário de forma fiel e acionável? | Existe mudança em estado de erro/user feedback |
| 20 | `/hm-conversion` | Existe fricção desnecessária no caminho de conversão? | Aquisição, ativação, pricing, signup, checkout, upgrade ou lead capture |
| 21 | `/hm-incident` | O incidente está sendo contido, recuperado e aprendido corretamente? | Hotfix/remediação de incidente ou investigação pós-incidente |
| — | `council` | Qual decisão tomar quando as skills empatam? | Conflito real, override de Owner, ou estratégia vs prontidão |

## Detecção de aplicabilidade

Antes de despachar, varra o repo e decida o que roda. Sinais concretos — não suposição:

- **LLM** (`/hm-llm-guardrails`): deps `@anthropic-ai/sdk`, `openai`, `@google/genai`, `ai`, `@aws-sdk/client-bedrock-runtime`, `ollama`; ou rota que faz streaming de texto
- **Logging** (`/hm-logger`): `app/api/`, `pages/api/`, router de Express/Fastify/Hono, dir de webhooks, worker de fila/cron, handler de agente
- **Dados** (`/hm-data-integrity`): schema Prisma/Drizzle/Knex, dir de migrations, `better-sqlite3`, Postgres/Supabase, SDK de S3/blob, escrita em `userData`
- **Performance** (`/hm-performance`): build de frontend (Next/Vite/Webpack), endpoint HTTP user-facing, ou qualquer call de LLM
- **Interface** (`/hm-designer`): `.tsx`/`.vue`/`.svelte` com componente visual, CSS/Tailwind. Headless ou lib pura → N/A
- **Fluxo** (`/hm-ux-flow`): qualquer jornada de 2+ passos, incluindo CLI interativo
- **Deploy** (`/hm-deploy`): `Dockerfile`, workflow de CI, `vercel.json`, config de `electron-builder`/Tauri, publicação npm
- **Estratégia** (`/hm-align`, `/hm-sequoia`): align sempre. Sequoia pula em ship de manutenção pura (bugfix, bump de dep, refactor sem mudança de direção) — anota "N/A: sem aposta estratégica nesse ship"

Skill não aplicável **não some do report** — entra na seção N/A com o motivo. Silêncio vira dúvida depois.

## Escopos

- **`full`** (default) — todas as skills aplicáveis. Use pra ship de verdade.
- **`core`** — só `/hm-security`, `/hm-engineer`, `/hm-qa`, `/hm-designer`, `/hm-deploy`. Atalho pra revalidação rápida depois de fix pontual. **Não vale como validação de ship.**
- **subset explícito** — Owner nomeia as skills. Você roda só essas e marca no report que a cobertura foi parcial.

Se o Owner pediu "valida tudo", e `full`. Não reduza escopo por conta própria pra economizar tempo.

## Ondas de execução (a ordem importa)

Skills não independem entre si. Ordem certa evita retrabalho. Dentro de cada onda, dispare em paralelo. Entre ondas, respeite o gate.

**Onda 0 — Estratégia (antes de auditar execução)**
1. `/hm-align` — isso deveria existir?
2. `/hm-sequoia` — isso aponta pra onde o mundo vai?

Gate: nenhum. Estratégia informa, não bloqueia. Mas se align retorna "Não construa", **avise no topo do report** — auditar em detalhe algo que não deveria existir e desperdício que o Owner precisa saber antes de pagar.

**Onda 1 — Fundação (gates duros)**
3. `/hm-security` — security gate bloqueia tudo
4. `/hm-data-integrity` — perda de dado e sempre CRÍTICO

Gate: CRÍTICO em `/hm-security` DOMÍNIO 1 (Container & Infra) ou DOMÍNIO 7 (Secrets) → **PARA**. CRÍTICO em `/hm-data-integrity` → continua a varredura mas o veredicto final já e BLOQUEADO.

**Onda 2 — Código + Contratos + Estados**
5. `/hm-engineer` — código fundamenta funcionalidade. Bug estrutural invalida QA passing
6. `/hm-api-contract` — em paralelo quando houver API/webhook/schema
7. `/hm-state-machine` — em paralelo quando houver múltiplos estados/async
8. `/hm-llm-guardrails` — em paralelo com engineer quando houver LLM
9. `/hm-logger` — em paralelo. Roda antes de performance: `http.latencyMs` do logger e o dado que performance consome

Gate: pattern obrigatório de LLM faltando (1-9, 12, 13) = bloqueante de produção. Continua, mas marca.

**Onda 3 — Execução + Medição**
10. `/hm-qa` — funcionalidade validada após segurança + código OK. Dono dos 5 checks de baseline
11. `/hm-performance` — números concretos depois que a feature comprovadamente funciona
12. `/hm-analytics` — instrumentação, funil e métricas quando aplicável

Gate: qualquer um dos 5 checks de baseline falhando = BLOQUEADO. Sem compensação.

**Onda 4 — Experiência**
13. `/hm-ux-flow` — decisão antes de pixel. Polir visual de fluxo que vai ser reestruturado e retrabalho
14. `/hm-error-feedback` — estados de erro e recuperação quando aplicável
15. `/hm-accessibility` — teclado, foco, semântica e status quando existe UI
16. `/hm-copy` — clareza e consistência da copy quando existe copy relevante
17. `/hm-conversion` — fricção de conversão quando aplicável
18. `/hm-designer` — design polish vale após funcional + fluxo resolvido

**Onda 5 — Entrega**
19. `/hm-deploy` — deploy gate só importa após tudo acima OK

**Onda 6 — Incident / Council (condicional)**
20. `/hm-incident` — só em remediação de incidente ou pós-incidente
21. `council` — só se um dos gatilhos da seção Council disparar

**Exceção:** se o ship e urgente e o owner pediu "valida tudo", roda tudo mesmo com criticos no caminho — pra ter mapa completo do estado, não pra shippar. Owner decide.

## Como executar

Pra cada skill, use a Skill tool com argumentos especificos do projeto. Os argumentos devem incluir:
- Paths dos módulos/dirs principais
- Foco da validação (ex: "novo módulo astro + multi-rodada do tarot")
- Tipo de distribuicao (Docker / Electron / Vercel / library / etc)
- Nível quando a skill tem nível (`/hm-security` L1/L2/L3, `/hm-data-integrity` local/produção pessoal/multi-user/produção pública)

```
Skill(hm-align, "Validar se a feature Y deveria existir. Visão do produto: [tese]. Usuario ideal: [quem]. Repo em /path/to/repo")

Skill(hm-sequoia, "Validar direção estratégica da aposta em [tecnologia/modelo]. Horizonte pretendido: [3-10 anos]. Repo em /path/to/repo")

Skill(hm-security, "Auditoria L2 do projeto X. Foco: novo módulo Y, integra LLM, processa dados pessoais. Repo em /path/to/repo")

Skill(hm-data-integrity, "Nível = produção pessoal. App Electron com DB em userData. Foco: migration nova + reset de profile. Repo em /path/to/repo")

Skill(hm-engineer, "Validar bloco grande de código Z. Foco senior-level, LLM patterns, performance. Repo em /path/to/repo")

Skill(hm-llm-guardrails, "Auditar os 14 patterns. Provider principal = Anthropic, N endpoints de streaming, tem tool calling. Repo em /path/to/repo")

Skill(hm-logger, "Modo auditoria. Varrer rotas de API, webhooks e handlers de agente atrás de log órfão. Repo em /path/to/repo")

Skill(hm-qa, "QA pass pré-uso real. Edge cases, error states, fluxos: A, B, C. Repo em /path/to/repo")

Skill(hm-performance, "Profile alvo = [Local app / Internal SaaS / Public SaaS]. Auditar bundle, p95 das rotas quentes, custo por turn de LLM. Repo em /path/to/repo")

Skill(hm-ux-flow, "Percorrer fluxos criticos: onboarding, checkout, [fluxo novo]. Repo em /path/to/repo")

Skill(hm-designer, "Validar interface das telas novas: D, E, F. Padrão Linear/Stripe/A24. Repo em /path/to/repo")

Skill(hm-deploy, "Validar deploy pré-ship. Distribuicao = X. Repo em /path/to/repo")
```

Cada skill retorna findings no vocabulário dela. Você coleta tudo e traduz.

## Council — quando convocar

`council` não e skill de validação. Não produz findings, produz **decisão**. Convoque só quando existe uma escolha real na mesa:

- **Conflito irreconciliável entre skills.** Ex: `/hm-performance` pede cache agressivo, `/hm-security` proíbe cachear aquele payload. A regra da severidade MAIOR não resolve — e tradeoff, não severidade.
- **Override de Owner.** Owner quer shippar com CRÍTICO aberto. Council faz o stress test da decisão antes do Owner cravar.
- **Estratégia vs prontidão.** `/hm-align` retorna "Construa diferente" ou `/hm-sequoia` retorna 🔴, mas o código está tecnicamente pronto pra shippar.
- **Custo de fix vs data de ship** sem resposta óbvia.

Invocação (o slug registrado e `council`, mesmo o diretório sendo `agent-council`):

```
Skill(council, "Ship com SEC-003 aberto ou atrasa 3 dias? Contexto: [findings + prazo + exposição]. --profile execution-lean --triad ship-now")
```

Triads úteis aqui: `ship-now` (torvalds, feynman, aurelius — correção prática com guardrail de risco), `risk` no profile `classic` (sun-tzu, aurelius, feynman), `stability` no `execution-lean` (ada, feynman, aurelius).

**Guardrail:** council não revoga gate. Perda potencial de dado e CRÍTICO de segurança não sao debatíveis por painel — são fatos. Council opina sobre prioridade, custo e sequência, nunca sobre rebaixar severidade. Por default **não roda** — painel sem decisão na mesa e teatro.

## Tradução de severidade

As 21 skills de validação falam vocabulários diferentes. Traduza pra escala comum (CRÍTICO / ALTO / MEDIO / BAIXO) antes de consolidar:

| Skill | Vocabulário nativo | Tradução |
|---|---|---|
| `/hm-align` | Construa / Construa diferente / Não construa | Fora da escala técnica → DECISÃO DE OWNER. Nunca auto-bloqueia |
| `/hm-sequoia` | 🟢 / 🟡 / 🔴 + horizonte | Fora da escala técnica → DECISÃO DE OWNER. 🔴 e 🟡 vêm com reposicionamento proposto |
| `/hm-security` | CRÍTICO/ALTO/MEDIO + PASS/FAIL por domínio + APROVADO/BLOQUEADO | Direto. CRÍTICO em DOMÍNIO 1 ou 7 = circuit breaker |
| `/hm-data-integrity` | PASS/FAIL por domínio + Dados protegidos / EM RISCO | **Qualquer FAIL = CRÍTICO.** Regra da própria skill: sem MEDIO, sem BAIXO. Proibido rebaixar |
| `/hm-engineer` | CRÍTICO/ALTO/MEDIO/BAIXO + shippa / corrige primeiro / repensa | Direto |
| `/hm-llm-guardrails` | PASS/FAIL nos 14 patterns + PRODUCTION READY / DEMO ONLY | FAIL em pattern 1-9, 12, 13 = CRÍTICO. FAIL em 10, 11, 14 = MEDIO (debt aceitável em MVP). DEMO ONLY = BLOQUEANTE SHIP |
| `/hm-logger` | PASS/FAIL de cobertura + Logging rastreável / órfão | Secret ou PII em log = CRÍTICO (atribui a `/hm-security` D8.2). `console.log` em path de produção = ALTO. Log sem `traceId`/`user` em webhook ou handler de IA = ALTO. Resto = MEDIO |
| `/hm-qa` | PASSED/FAILED nos 5 checks + PRONTO PRA OWNER / BLOQUEADO | Qualquer um dos 5 FAILED = BLOQUEADO direto, sem ponderação |
| `/hm-performance` | PASS/FAIL por métrica + Performance OK / OPTIMIZE | Os 4 bloqueios da skill (bundle 2x do alvo, índice faltando em query quente, p99 >1s user-facing, memory leak em processo background) = ALTO bloqueante. Resto = MEDIO |
| `/hm-ux-flow` | PASS / OPTIMIZE / REDESIGN por fluxo | REDESIGN em fluxo crítico = ALTO. OPTIMIZE = MEDIO. Empty state faltando = MEDIO. Spinner genérico = BAIXO |
| `/hm-designer` | Atende a barra / reprovou + issues | Reprovou em tela de fluxo crítico = ALTO. Resto = MEDIO/BAIXO conforme o princípio violado |
| `/hm-deploy` | OK/falhou por área + Pronto pra deploy / X issues | Secret exposto ou dado em risco = CRÍTICO (regra da skill). Não sobe do zero = ALTO. Resto = MEDIO |

### Reconciliação

Se duas skills marcaram a mesma issue com severidades diferentes, usa a MAIOR. Ex: `/hm-security` flag MEDIO e `/hm-engineer` marca o mesmo como ALTO → conta como ALTO.

Exceção que não admite ponderação: **dado em risco e CRÍTICO** mesmo que só uma skill tenha visto, e mesmo que outra tenha marcado menor. `/hm-data-integrity`, `/hm-engineer` e `/hm-deploy` convergem nessa regra.

## Anti-duplicação

12 skills varrem áreas que se cruzam. Sem dono definido, o total de findings infla e a priorização perde sentido. Um finding, um dono, um número:

| Área cruzada | Dono do finding | Papel das outras |
|---|---|---|
| typecheck / lint | `/hm-qa` | `/hm-engineer` corrobora — conta uma vez |
| `console.log` em produção | `/hm-engineer` (regra) | `/hm-logger` fornece o fix — finding único, citando as duas |
| Secret / PII em log | `/hm-security` D8.2 (conteúdo) | `/hm-logger` cobre a forma (`traceId`/`user`/`http`) |
| Custo de LLM | `/hm-llm-guardrails` (existe tracking?) | `/hm-performance` dá o número, `/hm-qa` faz o scan rápido |
| Performance | `/hm-performance` (número medido) | `/hm-qa` check 8 e `/hm-engineer` são scan raso — mantém o número do performance |
| Integridade de dados | `/hm-data-integrity` | `/hm-qa` seção 6 e `/hm-deploy` são scan raso |
| Container / secrets | `/hm-security` D1 e D7 | `/hm-engineer` e `/hm-deploy` corroboram |
| Visual vs decisão | `/hm-designer` (visual), `/hm-ux-flow` (decisão) | Não se sobrepõem — se um finding e sobre pixel, e designer; sobre ordem de decisão, e ux-flow |
| Estratégia | `/hm-align` (isso deveria existir?), `/hm-sequoia` (aponta pro futuro?) | Complementares. Align olha o agora, sequoia olha o horizonte |

## Consolidacao do output

Apos rodar as ondas, produza UM report consolidado:

```
/hm-validate-all REPORT
Projeto: [nome]
Data: [data]
Escopo: full / core / subset
Skills rodadas: [lista]
Skills N/A: [lista com motivo]
Skills que falharam tecnicamente: [lista, se houver]

BASELINE-READY GATE (5 checks obrigatorios)
1. typecheck: PASS/FAIL
2. lint: PASS/FAIL
3. smoke test (Dev Team rodou): PASS/FAIL/NOT_RUN
4. console.error em código novo: zero/N
5. TODO CRÍTICO em código novo: zero/N
Baseline-ready: SIM / NÃO

GATES DUROS
Security gate (D1 Container / D7 Secrets): PASS/FAIL
Dados sagrados (qualquer FAIL = CRÍTICO): PASS/FAIL
LLM patterns obrigatorios (1-9, 12, 13): PASS/FAIL/N/A
Logging rastreável (traceId + user em webhook/agente): PASS/FAIL/N/A
Performance — bloqueios duros (bundle 2x, índice quente, p99 >1s, memory leak): PASS/FAIL/N/A
Deploy — sobe do zero: PASS/FAIL

EXECUTIVE SUMMARY
Total findings: X CRÍTICO, Y ALTO, Z MEDIO, W BAIXO
Veredicto: BASELINE-READY (pronto pra Owner avaliar product-ready) / BLOQUEADO

BLOQUEANTE SHIP (CRITICOS + ALTOS de segurança + qualquer dado em risco)
1. [SKILL] [ID] Titulo curto — fix em 1 linha
2. ...

CORRIGIR ANTES DE USO REAL (ALTOS funcionais)
1. ...

TECHNICAL DEBT ACEITÁVEL (MEDIOS + BAIXOS)
1. ...

DECISÃO DE OWNER (estratégia — não bloqueia baseline)
hm-align: Construa / Construa diferente / Não construa — [razão em uma frase]
hm-sequoia: 🟢/🟡/🔴 — horizonte otimizado: [curto/médio/longo] — aposta oculta: [qual]
Reposicionamento proposto (se 🟡/🔴 ou "Construa diferente"): [qual]

COUNCIL (se convocado)
Questão: [decisão levada ao painel]
Painel: [membros] — [profile/triad]
Veredicto: [posição final compacta]

PASS (o que está sólido — celebrar de leve)
- [SKILL]: DOMÍNIO X, DOMÍNIO Y, DOMÍNIO Z

PRÓXIMOS PASSOS
1. [Owner action 1]
2. [Owner action 2]
```

### Regras de classificação

- **BLOQUEANTE SHIP**: qualquer CRÍTICO de segurança, qualquer ALTO de segurança, qualquer FAIL de `/hm-data-integrity`, pattern obrigatório de LLM faltando, secret exposto em log ou deploy, qualquer ALTO funcional que afete fluxo CRÍTICO
- **CORRIGIR ANTES USO REAL**: ALTO funcional em fluxo não-CRÍTICO, MEDIO de segurança que pode virar exploit, REDESIGN de fluxo em `/hm-ux-flow`, bloqueio duro de performance em rota quente
- **TECHNICAL DEBT**: MEDIO funcional, BAIXO de qualquer skill, patterns recomendados de LLM (10, 11, 14) faltando
- **DECISÃO DE OWNER**: todo output de `/hm-align` e `/hm-sequoia`, mais qualquer veredicto de council
- **PASS**: dominios sem findings
- **N/A**: skill não aplicável, com o motivo declarado

## Otimizações

- Se `/hm-security` retorna CRÍTICO no Security Gate (DOMÍNIO 1 ou 7), **PARA** e reporta. Não roda o resto — perda de tempo. Owner fixa CRÍTICO primeiro.
- Se `/hm-align` retorna "Não construa", avise no topo antes de gastar as outras 11 auditorias. Owner decide se quer o mapa completo mesmo assim.
- Dispare em paralelo dentro da onda. Sequencial só entre ondas, pra respeitar os gates.
- Se projeto e novo (sem features grandes recentes), valida tudo mesmo. Tendência de bugs em código novo > código estável.
- Se projeto e single-user local-only, pula sub-dominios irrelevantes (multi-tenant, file upload público, DR geo-redundante). Documenta no report ("N/A: local single-user"). **Atenção:** app instalado com DB em `userData` e produção pessoal, não dev — `/hm-data-integrity` roda em nível produção.
- Ship de manutenção pura (bugfix, bump de dep): `/hm-sequoia` e N/A. `/hm-align` continua valendo.

## Regras

- Você NÃO e a skill de validação. Você DESPACHA outras skills e CONSOLIDA. Não re-faz auditoria que já foi feita.
- **Você declara apenas baseline-ready.** Product-ready e Owner. Nunca pule essa distinção.
- Os 5 checks baseline-ready sao obrigatorios. Se algum falhar = BLOQUEADO. Não tente compensar com "passou nos outros dominios".
- Estratégia (`/hm-align`, `/hm-sequoia`) informa, não bloqueia. Código tecnicamente pronto + estratégia desalinhada = BASELINE-READY com alerta na seção DECISÃO DE OWNER.
- Dado em risco e CRÍTICO sempre. Nenhuma skill, nenhum council, nenhuma pressa rebaixa isso.
- Skill não aplicável vai pra N/A com motivo. Nunca omita silenciosamente.
- Se uma skill falha tecnicamente (Skill tool error), reporta no consolidated mas não bloqueia as outras.
- Owner pode pedir override ("ship mesmo com X aberto"). Você reporta o estado, owner decide. Não bloqueie autoritariamente — você informa, owner crava. Se o override envolve CRÍTICO, ofereça `council` antes.
- Tempo medio: 35-50 min no escopo `full` pra projeto medio (12 skills, paralelismo dentro das ondas). `core` fica em 15-20 min. Maior se tiver muitos findings pra processar.
- Mantenha o consolidated report **denso e priorizado**, não concatenado raw das 12 outputs. Se o report ficou maior que a soma das partes, você falhou em consolidar.
