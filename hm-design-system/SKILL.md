---
name: hm-design-system
description: Criação, evolução e governança de design systems com tokens, componentes, padrões, acessibilidade, documentação, versionamento e reuso. Use quando criar ou alterar componentes compartilhados, tokens visuais, primitives, padrões de interação, temas ou bibliotecas de UI. É a camada sistêmica complementar ao hm-designer, hm-accessibility, hm-copy e hm-conversion.
---

# /hm-design-system — Design System (v1)

Você está agora em modo design system.

Seu trabalho é garantir que a interface não seja apenas consistente em uma tela, mas consistente e evolutiva em toda a superfície do produto.

## Princípio central

**Design system não é uma coleção de componentes. É um sistema compartilhado de decisões, código, tokens, padrões e regras de evolução.**

USWDS descreve tokens como blocos básicos de cor, espaçamento, tipografia e outros valores; componentes são soluções reutilizáveis e consistentes para necessidades comuns. Fonte: https://designsystem.digital.gov/how-to-use-uswds/

## Baseline — inegociável

Um design system maduro precisa ter:
- tokens;
- componentes reutilizáveis;
- padrões;
- estados;
- acessibilidade;
- responsividade;
- documentação;
- exemplos;
- ownership;
- versionamento;
- estratégia de depreciação;
- processo de contribuição.

## 1. Comece pelo que já existe

Antes de criar:
- procure componente equivalente;
- procure primitive;
- procure token;
- procure padrão;
- procure comportamento já usado.

GOV.UK recomenda começar pelo que existe e reutilizar antes de criar algo novo. Fonte: https://design-system.service.gov.uk/community/community-principles/

Duplicar um componente com diferença cosmética pequena cria divergência futura.

## 2. Tokens antes de valores soltos

Evite:

    margin: 13px
    color: #7342E8

quando existe um token correspondente.

Tokens devem representar decisões semânticas, não somente valores crus:

    color.text.primary
    color.surface.default
    spacing.3
    radius.md
    typography.body.sm

USWDS usa tokens discretos para reduzir escolhas arbitrárias e melhorar eficiência e comunicação entre design e desenvolvimento. Fonte: https://designsystem.digital.gov/design-tokens/

## 3. Tokens devem possuir semântica

Separe quando fizer sentido:

    primitive token
    ↓
    semantic token
    ↓
    component token

Exemplo:

    purple.500
    ↓
    color.action.primary
    ↓
    button.primary.background

Assim um tema ou redesign pode trocar implementação sem reescrever todas as telas.

## 4. Componentes precisam de contrato

Para cada componente relevante, defina:
- propósito;
- anatomy;
- variants;
- sizes;
- states;
- behavior;
- responsive behavior;
- accessibility;
- content constraints;
- when to use;
- when not to use.

Um botão não é somente CSS.

## 5. Variants precisam de motivo

Não crie:

    ButtonBlue
    ButtonBlueDark
    ButtonBlueSmall
    ButtonBlueForModal

quando diferenças podem ser resolvidas pelo contrato do mesmo componente.

Cada variant nova aumenta:
- API;
- documentação;
- testes;
- manutenção;
- combinações possíveis.

## 6. Estados são parte do componente

Considere:

    default
    hover
    focus
    active
    disabled
    loading
    success
    error

Nem todo componente terá todos os estados, mas os estados relevantes devem ser definidos.

> Para modelagem profunda de estados, usar /hm-state-machine.

## 7. Acessibilidade é requisito do sistema

Um componente compartilhado deve ser acessível por padrão, não exigir que cada consumidor descubra como corrigir acessibilidade.

USWDS documenta testes com screen readers, teclado, zoom, touch, múltiplos browsers/OS e ferramentas automatizadas como parte do processo de seus componentes. Fonte: https://designsystem.digital.gov/documentation/accessibility/

> Para auditoria profunda, usar /hm-accessibility.

## 8. Padrões são diferentes de componentes

Componente:

    Button

Padrão:

    Confirm destructive action

Padrão combina:
- componentes;
- copy;
- fluxo;
- acessibilidade;
- contexto;
- comportamento.

GOV.UK diferencia components de patterns e usa patterns como soluções para tarefas específicas. Fonte: https://design-system.service.gov.uk/patterns/

## 9. Não crie componente para resolver problema de produto

Antes de adicionar um componente:

- qual problema ele resolve?
- quantos contextos realmente precisam dele?
- existe componente existente?
- existe evidência?
- existe diferença real?

GOV.UK exige evidência de utilidade e unicidade para propostas de componentes/patterns no sistema. Fonte: https://design-system.service.gov.uk/community/contribution-criteria/

## 10. Design system decision records

Para decisões sistêmicas relevantes, registre:
- contexto;
- decisão;
- alternativas;
- pesquisa;
- experimento;
- consequência;
- data.

Thoughtworks relata o uso de registros de decisão de design system para documentar justificativa, pesquisa e resultados de experimentos. Fonte: https://www.thoughtworks.com/radar/techniques/design-system-decision-records

## 11. Versionamento

Ao alterar componente compartilhado, avalie:
- breaking change;
- consumidores afetados;
- migration path;
- deprecation;
- codemod quando possível;
- changelog;
- rollout.

Não quebrar 50 telas para corrigir uma propriedade sem estratégia.

## 12. Extensão deve ser controlada

Quando o consumidor precisa customizar um componente:
- exponha API intencional;
- evite override CSS arbitrário;
- preserve acessibilidade;
- documente extensão.

GOV.UK recomenda pequenos modifications e naming/namespace específicos para evitar colisões e fragilidade. Fonte: https://design-system.service.gov.uk/get-started/extending-and-modifying-components/

## 13. Documentação é parte do produto interno

Cada componente importante precisa permitir responder rapidamente:
- o que é?
- quando usar?
- quando não usar?
- quais variants existem?
- quais estados existem?
- como acessibilizar?
- qual implementação correta?

## 14. Teste visual e comportamento

Componentes compartilhados devem ser testados em:
- diferentes tamanhos;
- estados;
- conteúdo curto/longo;
- teclado;
- mobile;
- temas;
- contraste;
- edge cases.

> Para validação visual final, usar /hm-designer.

> Para UX e conversão, usar /hm-conversion.

## 15. Governança

Defina:
- owner;
- processo de proposta;
- review;
- critérios de publicação;
- suporte;
- deprecation;
- breaking changes;
- métricas de uso quando disponível.

Um componente sem owner tende a virar código abandonado.

## Anti-patterns críticos

- componente duplicado;
- cor/spacing hardcoded quando existe token;
- variant para cada exceção;
- componente sem estados;
- componente compartilhado sem acessibilidade;
- componente sem documentação;
- API quebrada sem migração;
- override CSS arbitrário em consumidor;
- design decision sem registro;
- componente novo sem evidência de necessidade;
- pattern implementado de forma diferente em cada produto.

## Checklist

- [ ] reutilização pesquisada
- [ ] tokens
- [ ] semântica dos tokens
- [ ] component contract
- [ ] variants
- [ ] states
- [ ] accessibility
- [ ] responsive
- [ ] patterns
- [ ] docs
- [ ] tests
- [ ] ownership
- [ ] versioning
- [ ] deprecation
- [ ] decision record

## Output

    HM-DESIGN-SYSTEM
    Artefato: [token / component / pattern / foundation]

    EXISTENTE
    [o que já existe]

    DECISÃO
    [reutilizar / estender / criar]

    CONTRATO
    [variants + states + behavior]

    TOKENS
    [lista]

    ACESSIBILIDADE
    PASS/FAIL

    DOCUMENTAÇÃO
    PASS/FAIL

    VERSIONAMENTO
    [impacto]

    GOVERNANÇA
    [owner + review]

    VEREDICTO
    System-ready / Precisa revisão / BLOQUEADO

## Fontes

- U.S. Web Design System — How to use USWDS: https://designsystem.digital.gov/how-to-use-uswds/
- U.S. Web Design System — Design Tokens: https://designsystem.digital.gov/design-tokens/
- U.S. Web Design System — Accessibility: https://designsystem.digital.gov/documentation/accessibility/
- GOV.UK Design System — Community Principles: https://design-system.service.gov.uk/community/community-principles/
- GOV.UK Design System — Components: https://design-system.service.gov.uk/components/
- GOV.UK Design System — Patterns: https://design-system.service.gov.uk/patterns/
- GOV.UK Design System — Contribution Criteria: https://design-system.service.gov.uk/community/contribution-criteria/
- GOV.UK Design System — Extending Components: https://design-system.service.gov.uk/get-started/extending-and-modifying-components/
- Thoughtworks — Design System Decision Records: https://www.thoughtworks.com/radar/techniques/design-system-decision-records
