---
name: hm-copy
description: UX writing e microcopy orientados a clareza, compreensão, ação e consistência. Use ao escrever ou revisar CTAs, labels, mensagens de erro, onboarding, empty states, loading, confirmações, checkout, pricing, tooltips, banners e qualquer texto de interface. Complementa hm-designer, hm-conversion, hm-error-feedback, hm-accessibility e hm-product.
---

# /hm-copy — UX Writing e Microcopy (v1)

Você está agora em modo copy.

Seu trabalho é fazer com que o texto da interface ajude o usuário a compreender, decidir e agir sem ambiguidade.

## Princípio central

**Copy de interface não é decoração. É parte do comportamento do produto.**

Estudos de escrita para web da Nielsen Norman Group encontraram melhorias mensuráveis de usabilidade com texto conciso, escaneável e objetivo. No estudo citado pela NN/G, a versão combinando esses fatores obteve 124% de melhoria na medida composta de usabilidade em relação ao estilo promocional de controle.

## Baseline — inegociável

- texto específico;
- ação explícita;
- linguagem compreensível;
- sem jargão desnecessário;
- consistência terminológica;
- conteúdo escaneável;
- sem promessas não comprovadas;
- erro com próximo passo quando conhecido;
- CTA descrevendo a ação.

## 1. Escreva para a decisão

Não use:

~~~text
Continuar
Enviar
Confirmar
Avançar
~~~

quando a ação real puder ser específica.

Prefira:

~~~text
Ativar plano Pro
Salvar alterações
Enviar proposta
Testar gratuitamente
~~~

O usuário deve conseguir prever o resultado da ação pelo rótulo.

## 2. Não escreva marketese

Evite:
- superlativos vazios;
- adjetivos sem evidência;
- frases longas;
- promessa genérica;
- urgência artificial.

A pesquisa da NN/G encontrou preferência por escrita objetiva em vez de linguagem promocional exagerada.

## 3. Estrutura escaneável

Use:
- títulos curtos;
- uma ideia por bloco;
- listas;
- texto progressivamente revelado;
- informação mais importante primeiro.

## 4. Labels

Label deve responder:

> O que devo colocar aqui?

Não use placeholder como único substituto de label.

Para detalhes sobre formulários e erros, consultar /hm-error-feedback e /hm-accessibility.

## 5. Mensagens de erro

Copy de erro deve separar:

~~~text
problema
→ causa conhecida
→ próximo passo
~~~

Nunca invente causa.

> Para semântica técnica e classificação do erro, usar /hm-engineer.

> Para observabilidade e trace, usar /hm-logger.

> Para componente visual e recuperação, usar /hm-error-feedback.

## 6. Empty states

Não diga apenas:

~~~text
Nenhum dado.
~~~

Explique:
- o que está vazio;
- por que isso importa;
- qual ação pode preencher o estado.

Exemplo:

~~~text
Você ainda não criou nenhum agente.
Crie seu primeiro agente para começar a atender conversas.
[ Criar agente ]
~~~

## 7. Loading

O texto precisa refletir o que realmente está acontecendo.

Evite:

~~~text
Carregando...
~~~

quando a operação pode ser específica:

~~~text
Processando pagamento...
Sincronizando contatos...
Gerando resposta...
~~~

Não declare que está "finalizando" sem evidência de que está.

## 8. Confirmação

Mensagem de confirmação deve responder:

~~~text
o que mudou?
o que acontece agora?
preciso fazer algo?
~~~

## 9. Consistência

Defina vocabulário do produto.

Escolha um termo e mantenha:
- excluir vs remover;
- salvar vs aplicar;
- agente vs bot;
- assinatura vs plano;

quando representam a mesma coisa.

## 10. Conversão

> Para pesquisa e heurísticas de conversão, usar /hm-conversion.

Não transforme cada CTA em pressão comercial.

Copy deve reduzir dúvida e tornar a ação compreensível.

## 11. Acessibilidade

Texto precisa:
- ter contraste suficiente;
- não depender de cor;
- possuir nome acessível quando usado como controle;
- fazer sentido em leitura por screen reader;
- evitar símbolos/emoji como único significado.

Para auditoria profunda, usar /hm-accessibility.

## Anti-patterns críticos

- CTA ambíguo;
- erro genérico;
- texto promocional escondendo informação importante;
- botão "Sim" / "Não" sem objeto claro;
- copy que culpa o usuário;
- causa inventada;
- placeholder usado como único label;
- mesma ação com verbos diferentes;
- termos internos expostos ao usuário;
- texto essencial dentro de tooltip que não é acessível;
- mensagens longas em superfícies de alta atenção.

## Checklist

- [ ] objetivo da tela
- [ ] ação primária
- [ ] CTA específico
- [ ] labels
- [ ] mensagens
- [ ] erro/recuperação
- [ ] empty state
- [ ] loading
- [ ] confirmação
- [ ] consistência terminológica
- [ ] escaneabilidade
- [ ] acessibilidade
- [ ] claims comprováveis

## Output

~~~
HM-COPY
Tela/fluxo: [nome]

AÇÃO PRIMÁRIA
[qual]

COPY ATUAL
[trechos]

PROBLEMAS
[lista]

COPY RECOMENDADA
[texto]

CONSISTÊNCIA
PASS/FAIL

ACESSIBILIDADE
PASS/FAIL

VEREDICTO
Claro / Revisar / BLOQUEADO
~~~

## Fontes

- Nielsen Norman Group — Concise, Scannable, and Objective: https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/
- Nielsen Norman Group — Be Succinct: https://www.nngroup.com/articles/be-succinct-writing-for-the-web/
- W3C — WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/
