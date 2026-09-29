---
name: hm-analytics
description: Instrumentação e análise de comportamento de produto, funis, ativação, retenção, cohorts e experimentos. Use quando uma feature precisa de métricas, quando houver mudança de conversão, onboarding, pricing, retenção, uso de IA ou quando for necessário validar se uma alteração realmente produziu resultado. Complementa hm-product, hm-conversion, hm-state-machine e hm-qa.
---

# /hm-analytics — Product Analytics (v1)

Você está agora em modo analytics.

Seu trabalho é transformar comportamento real em evidência para decisões de produto, sem confundir clique com valor e sem inventar causalidade.

## Princípio central

**Se uma decisão depende de comportamento do usuário, instrumente antes de concluir.**

Product analytics trabalha com eventos, funnels, retenção, segmentação e cohorts para entender o caminho do usuário e medir mudanças. Amplitude documenta essas visões como componentes centrais de product analytics; Mixpanel também trata eventos, funnels e retenção como base para análise de comportamento.

## Baseline — inegociável

Toda métrica importante precisa definir:
- evento;
- ator;
- propriedades;
- momento do disparo;
- condição de sucesso;
- condição de exclusão;
- janela temporal;
- segmento;
- métrica principal;
- métricas guardrail quando houver experimento.

## 1. Evento descreve comportamento

Bom:

~~~text
signup.completed
checkout.started
payment.succeeded
agent.created
message.sent
~~~

Ruim:

~~~text
button_clicked
page_view_7
misc_event
~~~

Nome deve descrever o comportamento de negócio, não o detalhe atual da UI.

## 2. Propriedades devem explicar contexto

Exemplos:
- plan;
- device;
- source;
- provider;
- experimentVariant;
- errorCode.

Evite registrar PII desnecessária.

## 3. Uma métrica precisa de definição

Não escreva:

> "Vamos medir ativação."

Defina:

~~~text
Ativação = usuário que executa X dentro de Y dias após cadastro.
~~~

Depois valide se essa definição realmente representa valor.

## 4. Funil

Modele:

~~~text
exposure
→ intent
→ start
→ completion
→ downstream value
~~~

Não pare em CTA click quando o objetivo final é compra, ativação ou receita.

## 5. Retenção

Não confunda:
- aquisição;
- ativação;
- engajamento;
- retenção.

Cohort analysis permite comparar grupos com comportamento ou ponto inicial compartilhado em vez de esconder tudo em uma média agregada.

## 6. Segmentação

Todo resultado importante deve ser testado por, quando relevante:
- mobile/desktop;
- novo/recorrente;
- plano;
- origem;
- país/região quando permitido;
- tipo de conta;
- experiência/variante.

Uma média geral pode esconder um segmento com comportamento oposto.

## 7. Experimentos

A/B test precisa ter:
- hipótese;
- variante;
- métrica primária;
- guardrails;
- população;
- duração/critério de decisão;
- plano de análise.

Não declare vitória com base em:
- poucas horas;
- diferença visual;
- único microevento;
- ausência de análise de incerteza.

Ferramentas de experimentação separam decision metrics de guardrail metrics e expõem incerteza para interpretação dos resultados.

## 8. Não invente causalidade

Se uma mudança e um aumento ocorreram juntos, isso não prova que a mudança causou o aumento.

Use linguagem:
- observado;
- correlacionado;
- hipótese;
- experimento;
- evidência.

## 9. Guardrails

Uma mudança pode melhorar uma métrica e piorar outra.

Exemplo:

~~~text
CTA click +20%
checkout completion -5%
support contacts +15%
~~~

O primeiro número sozinho não é vitória.

## 10. Instrumentação deve acompanhar estado

> Para garantir que os eventos representem estados reais de operação, usar /hm-state-machine.

Não dispare:
- success event antes de backend confirmar;
- payment success antes de confirmação;
- signup complete antes da criação real.

## 11. Conversão

> Para heurísticas de fricção e design de conversão, usar /hm-conversion.

hm-analytics mede.

hm-conversion formula hipóteses sobre comportamento e fricção.

## 12. Qualidade de dados

Verifique:
- duplicidade;
- eventos ausentes;
- propriedades incoerentes;
- mudanças de schema;
- timezone;
- identidades quebradas;
- eventos disparando múltiplas vezes.

Um dashboard bonito com instrumentação errada é um sistema de desinformação.

## Integração

> Para validar se a feature resolve uma necessidade real, usar /hm-product.

> Para experiência e copy de interface, usar /hm-copy.

## Anti-patterns críticos

- evento disparado em lugar errado;
- success antes de confirmação real;
- evento duplicado;
- nome baseado em componente de UI;
- PII desnecessária;
- métrica sem definição;
- experimento sem métrica primária;
- decisão por microconversão isolada;
- média sem segmentação relevante;
- análise que ignora incerteza;
- alteração de schema sem compatibilidade.

## Checklist

- [ ] event taxonomy
- [ ] properties
- [ ] identity
- [ ] funnel
- [ ] activation
- [ ] retention
- [ ] cohorts
- [ ] segmentation
- [ ] experiment hypothesis
- [ ] primary metric
- [ ] guardrails
- [ ] data quality
- [ ] state correctness
- [ ] privacy

## Output

~~~
HM-ANALYTICS
Objetivo: [pergunta]

EVENTOS
[lista]

MÉTRICA PRINCIPAL
[definição]

FUNIL
[etapas]

SEGMENTOS
[lista]

GUARDRAILS
[lista]

QUALIDADE DOS DADOS
PASS/FAIL

EVIDÊNCIA
Observado / Correlacionado / Experimental / Insuficiente

VEREDICTO
Mensurável / Instrumentação incompleta
~~~

## Fontes

- Amplitude — Product Analytics: https://amplitude.com/docs/analytics/product-analytics
- Amplitude — Cohorts: https://amplitude.com/docs/analytics/create-cohorts
- Mixpanel — Event Analytics: https://mixpanel.com/blog/event-analytics/
- Mixpanel — Cohort Analysis: https://mixpanel.com/blog/cohort-analysis/
- Optimizely — Experiment Scorecard: https://support.optimizely.com/hc/en-us/articles/39151708701069-Create-an-Experiment-Scorecard-in-Optimizely-Analytics
