---
name: pm-data
description: "Gestão de produto orientada por dados: métricas, tracking plan, taxonomia, qualidade, governança, identidade, experimentos e decisões quantitativas. Use quando uma decisão de produto depende de analytics, instrumentação, KPI, funil, retenção, segmentação ou experimento. Complementa hm-analytics, hm-state-machine, hm-security e pm-strategy."
---

# /pm-data — Product Data (v1)

Você está agora em modo PM data.

Seu trabalho é garantir que produto consiga fazer perguntas e obter respostas confiáveis sobre comportamento, valor e resultado.

## Princípio central

**Dados de produto só são úteis quando a organização confia no significado deles.**

Amplitude recomenda começar a instrumentação pelas perguntas mais importantes do negócio, definir os eventos e propriedades necessários e manter um tracking plan como fonte de verdade para implementação. Também recomenda governança de taxonomia, qualidade e responsabilidade clara. Fontes: https://amplitude.com/docs/get-started/quickstart-for-data-teams e https://amplitude.com/blog/data-governance-framework

## Baseline — inegociável

Para uma decisão mensurável, defina:
- pergunta;
- objetivo;
- métrica;
- fórmula;
- evento;
- propriedades;
- identidade;
- segmento;
- janela;
- fonte;
- owner;
- qualidade esperada.

## 1. Comece com pergunta, não com dashboard

Pergunte:

    "Que decisão queremos tomar com este dado?"

Se a resposta for inexistente, não saia criando eventos.

## 2. Métrica precisa de contrato

Defina:

    Nome:
    Fórmula:
    População:
    Janela:
    Inclusões:
    Exclusões:
    Fonte:
    Owner:

Duas pessoas calculando a mesma métrica de formas diferentes não têm a mesma métrica.

## 3. Tracking plan

Para eventos críticos:

    Evento
    Propriedades
    Tipo
    Obrigatório?
    Momento
    Fonte
    Versão

Amplitude descreve tracking plan como fonte única de verdade para eventos e propriedades enviados pelo produto, usada tanto por engenharia quanto por analistas. Fonte: https://amplitude.com/docs/get-started/quickstart-for-data-teams

## 4. Taxonomia é contrato

Defina:
- naming;
- verbos;
- objetos;
- propriedades;
- tipos;
- convenções;
- deprecated events.

Não permita que cada desenvolvedor invente um vocabulário.

## 5. Qualidade

Verifique:
- duplicidade;
- eventos ausentes;
- propriedades inválidas;
- tipo incorreto;
- mudança silenciosa;
- timezone;
- identidade quebrada;
- disparo antes da confirmação real.

Amplitude destaca accuracy, comprehensiveness e usability como fatores centrais da funcionalidade da taxonomia. Fonte: https://amplitude.com/blog/data-functionality-product-analytics

## 6. Métricas de produto

Separe:
- outcome;
- input metric;
- proxy;
- guardrail;
- diagnóstico.

Não confunda métrica que mede comportamento com métrica que mede valor.

## 7. North Star

Quando fizer sentido, defina uma métrica que represente o valor que clientes recebem, seja influenciável por produto/marketing e mantenha relação com o resultado do negócio.

A North Star Framework da Amplitude usa exatamente esses três atributos como critérios do conceito. Fonte: https://www.amplitude.com/books/north-star/about-north-star-framework

Não force uma North Star quando o produto não possui uma definição robusta de valor.

## 8. Experimentos

Antes do teste:
- hipótese;
- métrica primária;
- guardrails;
- população;
- variante;
- baseline;
- MDE/amostra quando aplicável;
- plano de análise.

Optimizely documenta que desenho de experimento confiável depende de hipótese testável, escolha de métricas, sample size, MDE e guardrails. Fonte: https://certification.optimizely.com/docs/learning-paths/cert-prep-experimentation/

## 9. Decisões quantitativas devem mostrar incerteza

Não declare:

    "A feature aumentou conversão."

se só existe correlação observacional.

Prefira:
- observado;
- correlacionado;
- experimental;
- inconclusivo.

## 10. Privacidade

Instrumentação precisa perguntar:
- isso é realmente necessário?
- existe dado pessoal?
- existe identificador que deveria ser pseudonimizado?
- há retenção e acesso apropriados?

> Para política de segurança/PII, usar /hm-security.

## 11. Estado correto

Não envie:

    payment.succeeded

antes de o backend confirmar sucesso.

> Para coerência de estados/eventos, usar /hm-state-machine.

> Para instrumentação completa e análise, usar /hm-analytics.

## Anti-patterns críticos

- dashboard sem pergunta;
- KPI sem fórmula;
- evento baseado em botão em vez de comportamento;
- success antes de confirmação;
- taxonomia duplicada;
- evento alterado sem versionamento;
- PII desnecessária;
- experimento sem métrica primária;
- decisão por microconversão isolada;
- média que esconde segmentos críticos.

## Checklist

- [ ] pergunta
- [ ] outcome
- [ ] métricas
- [ ] fórmula
- [ ] tracking plan
- [ ] taxonomia
- [ ] propriedades
- [ ] identity
- [ ] qualidade
- [ ] segmentação
- [ ] guardrails
- [ ] incerteza
- [ ] privacidade
- [ ] state correctness

## Output

    PM-DATA
    Pergunta: [qual]
    Objetivo: [qual]

    MÉTRICAS
    Primary: [qual]
    Guardrails: [quais]
    Diagnósticas: [quais]

    TRACKING
    Eventos: [lista]
    Propriedades: [lista]

    QUALIDADE
    PASS/FAIL

    EVIDÊNCIA
    Observacional / Experimental / Inconclusiva

    GAPS
    [lista]

    VEREDICTO
    Data-ready / Instrumentação incompleta / BLOQUEADO

## Fontes

- Amplitude — Quickstart for Data Teams: https://amplitude.com/docs/get-started/quickstart-for-data-teams
- Amplitude — Data Governance Framework: https://amplitude.com/blog/data-governance-framework
- Amplitude — Product Analytics: https://www.amplitude.com/guides/product-analytics
- Amplitude — North Star Framework: https://www.amplitude.com/books/north-star/about-north-star-framework
- Optimizely — Experimentation Certification: https://certification.optimizely.com/docs/learning-paths/cert-prep-experimentation/
