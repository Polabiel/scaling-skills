---
name: hm-conversion
description: Orientação de produto e UX focada em conversão para o hm-designer. Use ao criar, revisar ou modificar interfaces que influenciam aquisição, ativação, cadastro, teste, upgrade, checkout, captura de leads, onboarding, preços, CTAs, formulários, modais ou outros fluxos de conversão. Trate fricção de interação desnecessária como um risco de conversão e exija justificativa explícita para fricções que afetem a ação principal.
---

# HM Conversion

## Objetivo

Tornar a conversão uma restrição de primeira classe no design sem reduzir o design a táticas agressivas de crescimento.

Esta skill complementa:
- `hm-designer`: protege qualidade visual, hierarquia, consistência, responsividade e fidelidade de implementação.
- `hm-conversion`: avalia se o design torna a ação desejada pelo cliente fácil de entender e executar.
- `hm-ux-flow`: avalia o fluxo cognitivo e de interação mais amplo.

Quando uma alteração afetar um fluxo de conversão, aplique as três perspectivas.

## Princípio central

**Não adicione fricção no momento de intenção sem uma razão clara.**

Uma interface pode ser visualmente refinada e tecnicamente correta e ainda assim criar fricção de conversão. O objetivo é identificar essa fricção antes do lançamento.

Pense nesta sequência:

`atenção → compreensão → confiança → ação`

Cada interação desnecessária entre essas etapas é um possível ponto de abandono.

## Regras fundamentais

### 1. A ação principal deve ser alcançável sem rolagem desnecessária

Para superfícies de alta intenção, como:
- cadastro
- checkout
- upgrade
- compra
- ativação de teste
- captura de lead
- seleção de plano/preço
- confirmação de uma ação comercial

o CTA principal e as informações necessárias para tomar a decisão devem estar visíveis ou ser imediatamente acessíveis.

**Não faça o usuário rolar dentro de uma modal apenas porque o conteúdo não cabe no viewport.**

Padrão ruim:
- a modal abre
- conteúdo importante fica abaixo do viewport
- o usuário precisa rolar dentro da modal para descobrir o CTA
- o CTA não está disponível à primeira vista

Padrões preferíveis:
- reduzir conteúdo não essencial
- reorganizar a hierarquia
- usar divulgação progressiva
- mover conteúdo secundário para fora do fluxo crítico
- tornar a modal responsiva ao viewport
- manter o CTA em um rodapé persistente quando apropriado
- dividir uma tarefa genuinamente complexa em etapas explícitas

Exceção:
Rolagem interna pode ser apropriada quando o conteúdo é realmente necessário e não pode ser condensado de forma razoável, como termos legais, listas longas, configurações avançadas ou fluxos genuinamente complexos. Mesmo nesses casos, mantenha a ação principal e o modelo de navegação óbvios.

### 2. Nunca confunda completude visual com qualidade de conversão

Um design não é melhor simplesmente porque contém mais informações.

Antes de adicionar uma interface, pergunte:
- Isso ajuda o usuário a decidir?
- Isso reduz incerteza?
- Isso aumenta confiança?
- Isso ajuda o usuário a concluir a ação desejada?

Se não, considere remover, recolher ou mover esse conteúdo para fora do caminho crítico.

### 3. Minimize o custo de interação

Para ações críticas de conversão, analise:
- quantidade de cliques/toques
- quantidade de texto digitado
- rolagem necessária
- troca de contexto
- informações repetidas
- confirmações desnecessárias
- CTAs ocultos
- estados desabilitados sem causa clara
- campos que não são necessários para o objetivo imediato

Não otimize para o menor número teórico de interações sacrificando clareza ou confiança. O objetivo é **baixa fricção desnecessária**, e não simplesmente menos etapas.

### 4. Preserve o contexto da decisão

O usuário deve entender:
- o que está fazendo
- por que está fazendo
- o que acontecerá depois
- o que a ação principal causará

Evite interfaces em que o usuário precisa fechar uma modal, memorizar informações, navegar para outro lugar e retornar para concluir a decisão.

### 5. Mobile é uma superfície de conversão, não um desktop menor

Para mobile:
- considere o menor espaço vertical
- teste a altura da modal
- verifique se o CTA continua acessível
- evite rolagens aninhadas quando possível
- garanta que o teclado não esconda a ação
- verifique se CTAs fixos não cobrem conteúdo
- confira o tamanho das áreas de toque
- teste o fluxo completo, não apenas o viewport inicial

## Checklist de fricção de conversão

Ao revisar um design, verifique explicitamente:

### Visibilidade
- O CTA principal está visível?
- A proposta de valor está visível?
- A próxima ação é óbvia?
- Preço, compromisso ou informação importante está visível antes da ação?

### Fricção
- O usuário precisa rolar para agir?
- Precisa abrir outro elemento para entender a decisão?
- Existem campos desnecessários?
- Existem etapas desnecessárias?
- Existe um container de rolagem aninhado?
- Existe uma modal dentro de outra modal?
- O usuário é obrigado a repetir informações?

### Confiança
- A ação é compreensível?
- Custos, compromissos, limitações ou consequências importantes estão claros?
- Os erros podem ser recuperados?
- A interface é previsível?

### Hierarquia
- Existe uma única ação claramente primária?
- As ações secundárias estão visualmente subordinadas?
- Elementos decorativos competem com o CTA?
- Informações importantes estão escondidas abaixo de conteúdo de baixo valor?

## Como reportar um problema de conversão

Não diga apenas "essa UX é ruim".

Informe:

1. **Observação** — o que a interface faz atualmente.
2. **Fricção** — qual esforço adicional o usuário precisa realizar.
3. **Risco de conversão** — como essa fricção pode interromper a ação desejada.
4. **Recomendação** — a menor alteração que remove ou reduz a fricção.
5. **Validação** — como verificar a alteração no viewport/dispositivo real.

Exemplo:

> **Observação:** A modal de upgrade é mais alta que o viewport e o CTA fica abaixo da área visível.
>
> **Fricção:** O usuário precisa rolar dentro da modal antes de continuar.
>
> **Risco de conversão:** A ação principal fica separada do contexto inicial da decisão, criando uma interação desnecessária em um momento de alta intenção.
>
> **Recomendação:** Reduza conteúdo secundário e mantenha o CTA visível em um rodapé persistente da modal. Se todo o conteúdo for obrigatório, divida o fluxo em etapas explícitas.
>
> **Validação:** Teste nos viewports desktop e mobile-alvo e verifique se o usuário consegue entender a oferta e chegar ao CTA principal sem rolagem interna acidental.

## Severidade

Use estes rótulos de forma descritiva, não como pontuações:

- **Bloqueador:** a ação principal de conversão está inacessível, quebrada, obstruída ou efetivamente escondida.
- **Alta:** existe fricção significativa e desnecessária diretamente antes da ação de conversão.
- **Média:** problemas de fricção ou hierarquia podem atrasar compreensão ou ação, mas não impedem a conclusão.
- **Baixa:** oportunidades menores de refinamento com efeito limitado no caminho crítico.

## Comportamento obrigatório do hm-designer

Quando o `hm-designer` revisar uma tela relacionada à conversão:

1. Identifique a ação que o usuário deve realizar.
2. Identifique o CTA principal.
3. Determine se o CTA e as informações críticas para a decisão estão acessíveis no viewport inicial.
4. Inspecione todos os containers de rolagem, especialmente modais e drawers.
5. Verifique mobile separadamente.
6. Identifique fricções desnecessárias.
7. Recomende a menor alteração que preserve a qualidade visual enquanto reduz a fricção.
8. Não afirme que uma alteração aumentará a conversão sem evidência mensurada. Sem evidência, use termos como "risco de conversão", "fricção" ou "hipótese".

## Anti-padrões

Sinalize quando relevante:

- CTA escondido abaixo da rolagem da modal
- rolagem aninhada em diálogos críticos de conversão
- excesso de campos antes de estabelecer o valor
- CTA principal com baixo contraste ou rótulo ambíguo
- múltiplos CTAs competindo como ação principal
- preço ou compromisso importante escondido atrás de uma interação
- telas de confirmação desnecessárias
- ações destrutivas ou comerciais com rótulos pouco claros
- informações obrigatórias misturadas com opcionais sem distinção
- copy promocional que ofusca a ação real
- layout desktop que se torna inutilizável no mobile
- UI fixa cobrindo CTA ou campos do formulário
- estados de carregamento sem feedback durante uma ação de alta intenção

## Disciplina de evidência

Uma recomendação de conversão deve distinguir entre:
- restrições de usabilidade estabelecidas
- heurísticas de design
- suposições sobre o produto
- analytics mensurados
- evidências de testes A/B

Nunca invente um percentual de aumento de conversão.

Se houver analytics disponíveis, solicite ou analise:
- abertura da modal → taxa de clique no CTA
- clique no CTA → taxa de conclusão
- início do formulário → taxa de conclusão
- abandono etapa a etapa
- conversão mobile vs. desktop
- taxa de erro
- tempo para conclusão

Use dados reais do produto para validar hipóteses sempre que possível.

## Princípios de conversão baseados em evidências

Use os seguintes achados como **heurísticas baseadas em evidências**, não como leis universais. O efeito depende do produto, público, dispositivo, intenção, origem do tráfego e implementação. Valide recomendações importantes com analytics ou experimentos do próprio produto.

### 1. Reduza a complexidade desnecessária do checkout

A pesquisa de checkout da Baymard de 2026 relata que 17% dos compradores online dos EUA disseram ter abandonado um pedido no trimestre anterior porque o checkout era longo ou complicado. O benchmark encontrou uma média de 23,48 elementos de formulário exibidos por padrão, enquanto a pesquisa de usabilidade indica que muitos checkouts podem ser reduzidos para aproximadamente 12–14 elementos (7–8 campos efetivos).

**Implicação de design:** minimize campos e decisões que não sejam necessários para concluir a ação imediata. Não otimize simplesmente para menos "etapas"; a quantidade de informação que o usuário precisa processar e inserir também importa.

**Fonte:** Baymard Institute — "Reasons for Cart Abandonment" e "Checkout Optimization: Minimize Form Fields".

### 2. Trate rolagem desnecessária como fricção em superfícies de alta intenção

As evidências **não** estabelecem que toda modal com rolagem reduz conversão. A regra defensável é mais específica:

> Quando a ação principal ou as informações necessárias para a decisão ficam escondidas atrás de uma rolagem desnecessária, a interface adiciona custo de interação em um momento de alta intenção.

A NN/G relata que usuários dedicam menos atenção a conteúdo abaixo da área inicial visível e documenta problemas relacionados à rolagem excessiva em mobile.

**Implicação de design:** em modais de cadastro, upgrade, checkout, compra e captura de leads, tente primeiro manter o contexto da decisão e o CTA principal acessíveis sem rolagem interna. Se o conteúdo realmente não couber, use divulgação progressiva, uma área de ação persistente ou um fluxo dedicado em múltiplas etapas/páginas.

Isso é uma **heurística**, não uma afirmação de aumento fixo de conversão.

**Fontes:** Nielsen Norman Group — "Scrolling and Scrollbars"; "Mobile Web 2009 = Desktop Web 1998".

### 3. Modais possuem um custo de interação

A NN/G descreve modais como interrupções que exigem atenção imediata, interrompem o fluxo de trabalho, podem causar perda de contexto e adicionam um objetivo extra: dispensar ou concluir o diálogo. A NN/G recomenda especificamente evitar modais desnecessárias em processos de alto risco, como checkout.

**Implicação de design:** uma modal de conversão deve justificar a interrupção. Se o usuário precisa pesquisar ou consultar informações complexas fora da modal para tomar a decisão, prefira uma página ou fluxo não modal.

**Fonte:** Nielsen Norman Group — "Modal & Nonmodal Dialogs: When (& When Not) to Use Them".

### 4. Simplifique formulários, mas não transforme quantidade de campos em regra absoluta

A NN/G cita um estudo da CHI em que formulários que seguiam princípios básicos de usabilidade obtiveram 78% de submissões na primeira tentativa, contra 42% nos formulários que violavam esses princípios. A NN/G também ressalta que remover um campo pode melhorar a conclusão, mas o valor comercial da informação coletada precisa ser considerado.

A Baymard também aponta que a quantidade de campos do formulário tem impacto maior na usabilidade do checkout do que simplesmente a quantidade de etapas.

**Implicação de design:** elimine campos que não apoiem o objetivo imediato do usuário ou do negócio; automatize informações quando possível; adie coleta de dados opcionais até depois da conversão principal.

**Fontes:** Nielsen Norman Group — "Website Forms Usability"; Baymard Institute — "Checkout Optimization: Minimize Form Fields".

### 5. Mantenha labels e recuperação de erros persistentes

A pesquisa da NN/G sobre formulários indica que labels que existem apenas como placeholder dificultam lembrar o que pertence ao campo, revisar informações inseridas e recuperar-se de erros. Os testes da Baymard também relacionam tratamento pouco claro de campos obrigatórios/opcionais a erros de validação, confusão, checkout mais lento e abandono.

**Implicação de design:** use labels persistentes, estados obrigatório/opcional explícitos quando apropriado, mensagens de erro locais e caminhos de recuperação que preservem os dados já preenchidos.

**Fontes:** Nielsen Norman Group — "Placeholders in Form Fields Are Harmful"; Baymard Institute — "Required and Optional Form Fields".

### 6. Otimize esforço percebido, não uma quantidade arbitrária de etapas

A Baymard alerta explicitamente que a quantidade de etapas do checkout é um alvo ruim de otimização por si só. Um fluxo mais longo pode ser usável quando cada etapa é focada; um fluxo curto ainda pode ser difícil quando cada tela contém campos ou decisões demais.

**Implicação de design:** avalie:
- campos
- escolhas
- digitação
- rolagem
- trocas de contexto
- recuperação de erros
- incerteza
- informações repetidas

Não aplique "uma página é sempre melhor" ou "menos etapas é sempre melhor" como regras universais.

**Fonte:** Baymard Institute — "Checkout Optimization: Minimize Form Fields".

### 7. Velocidade faz parte do design de conversão

A pesquisa mobile da Google/SOASTA de 2017 encontrou que, conforme o tempo de carregamento aumentava de 1 para 3 segundos, a probabilidade de bounce aumentava 32%; de 1 para 5 segundos, aumentava 90%. Esses são dados históricos agregados de mobile, não uma curva universal de conversão.

**Implicação de design:** trate performance de carregamento como parte da experiência de conversão. Meça a performance de usuários reais e priorize atrasos que acontecem imediatamente antes ou durante uma ação de conversão.

**Fonte:** pesquisa mobile Google/SOASTA, 2017.

### 8. Testes A/B podem derrubar "boas práticas" de UX

A HubSpot documentou um experimento em que um formulário de leads com duas colunas converteu 22% melhor do que a variante de uma coluna, com 99% de confiança. A própria HubSpot observa que o resultado era específico daquele formulário longo de 13 campos e não deve ser generalizado como "duas colunas são melhores".

A VWO publica estudos de caso em que redesigns produziram mudanças mensuráveis, incluindo o aumento reportado de 20,45% na conversão mobile de formulário da ForestView após reduzir rolagem para cima/baixo e alterar a navegação de produtos.

**Implicação de design:** use pesquisas para gerar hipóteses, não para eliminar a necessidade de experimentação. Uma convenção que normalmente ajuda pode perder quando tarefa, densidade de conteúdo, público ou objetivo comercial mudam.

**Fontes:** HubSpot — "Disproving Best Practices: The One- vs. Two-Column Form Test"; VWO — "ForestView improved form conversion by 20.45%".

### 9. Use evidência específica do negócio antes de declarar uma vitória de conversão

Um aumento reportado em um case study de fornecedor é evidência sobre aquele experimento, não um percentual transferível para qualquer produto.

Ao validar uma alteração, prefira:
1. teste A/B controlado com métrica principal definida
2. resultados segmentados por dispositivo e intenção do tráfego
3. métricas do funil, não apenas cliques
4. incerteza estatística/confiança reportada pela plataforma de experimento
5. resultados posteriores do negócio, não apenas microconversões

Métricas úteis:
- exposição → clique no CTA
- clique no CTA → conclusão
- início do formulário → conclusão
- abandono entre etapas
- conclusão mobile vs. desktop
- taxa de erro
- tempo para conclusão
- receita por visitante / taxa de lead qualificado quando relevante

## Hierarquia de evidências

Ao fazer uma recomendação de conversão, dê este peso às evidências:

1. **Experimento do próprio produto ou dados comportamentais da interface real**
2. **Testes de usabilidade diretamente com o público-alvo**
3. **Pesquisa independente de UX em larga escala**
4. **Pesquisa acadêmica revisada por pares**
5. **Cases de fornecedores com metodologia divulgada**
6. **Heurísticas de especialistas**
7. **Intuição do designer**

Não apresente os níveis 5–7 como se fossem prova causal.

## O que estas evidências NÃO justificam

Não transforme estas afirmações em regras universais:

- "Toda modal nunca deve ter rolagem."
- "Tudo precisa estar acima da dobra."
- "Menos campos sempre significa mais receita."
- "Formulários de uma coluna sempre convertem melhor."
- "Menos etapas de checkout sempre convertem melhor."
- "Uma determinada cor de CTA aumenta conversão."
- "Uma alteração de UX aumentará conversão em um percentual específico."

Em vez disso, aplique o mecanismo subjacente:

**Reduza esforço desnecessário, preserve o contexto da decisão, torne a ação principal fácil de descobrir e executar e valide alterações relevantes com dados reais dos usuários.**

## Formato de saída

Para uma revisão focada em conversão, use:

### Intenção de conversão
Qual ação o usuário deve realizar?

### Fricção encontrada
O que torna essa ação mais difícil do que deveria?

### Risco
Por que essa fricção pode interromper o fluxo desejado?

### Alteração recomendada
O que deve mudar?

### Validação
Qual viewport, dispositivo, interação ou métrica deve ser verificada?

Mantenha as recomendações concretas e orientadas à implementação.
