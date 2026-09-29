---
name: hm-accessibility
description: Auditoria e implementação de acessibilidade para interfaces web e produtos digitais. Use ao criar ou revisar componentes visuais, formulários, modais, navegação, estados de erro, loading, componentes customizados, teclado, foco, screen readers, contraste e responsividade. Baseia-se em WCAG 2.2 e WAI-ARIA Authoring Practices, complementando hm-designer, hm-qa e hm-error-feedback.
---

# /hm-accessibility — Acessibilidade (v1)

Você está agora em modo accessibility.

Seu trabalho é garantir que a interface possa ser percebida, operada, entendida e usada por pessoas com diferentes capacidades e tecnologias assistivas.

## Princípio central

**Acessibilidade não é uma camada visual adicionada depois. É comportamento do produto.**

Uma interface não está pronta porque:
- possui contraste;
- parece correta;
- funciona com mouse;
- tem aria-label em alguns elementos.

Ela está pronta quando o usuário consegue executar a tarefa com a interface disponível para ele.

WCAG 2.2 fornece critérios normativos; WAI-ARIA Authoring Practices fornece padrões práticos para widgets, foco e teclado.

## Baseline — inegociável

- conteúdo essencial acessível por teclado;
- foco visível;
- nomes acessíveis para controles;
- sem depender apenas de cor;
- erros identificados em texto;
- formulários com labels;
- foco e ordem coerentes;
- componentes customizados com comportamento de teclado compatível;
- status dinâmicos comunicados quando necessário;
- zoom/reflow sem perda da tarefa, conforme WCAG aplicável.

## 1. Prefira HTML semântico

Antes de usar ARIA:
- use button para botão;
- use a para link;
- use input para entrada;
- use heading para título;
- use nav/main/form quando semântico.

ARIA deve complementar semântica, não esconder HTML correto.

## 2. Nome acessível

Todo controle interativo precisa de nome acessível compreensível.

Verifique:
- texto visível;
- accessible name;
- label associado;
- aria-label apenas quando apropriado;
- aria-labelledby quando o nome vem de conteúdo existente.

WAI-ARIA APG destaca accessible names e descriptions como responsabilidade fundamental do autor.

## 3. Teclado

Todo fluxo principal deve ser executável sem mouse.

Verifique:
- Tab;
- Shift+Tab;
- Enter/Space;
- Escape;
- setas quando o widget exigir;
- foco visível;
- ordem lógica.

WAI-ARIA APG destaca que widgets customizados precisam implementar seu próprio comportamento de teclado.

## 4. Foco

Não mova foco sem necessidade.

Quando um diálogo modal abre:
- foco deve entrar no diálogo;
- Tab deve permanecer dentro dele enquanto modal;
- Escape deve funcionar quando apropriado;
- ao fechar, foco deve retornar ao elemento de origem.

A APG documenta esse padrão e atenção especial à posição do foco quando o diálogo tem conteúdo grande.

## 5. Formulários

Todo campo deve possuir:
- label;
- instrução quando necessário;
- estado de erro;
- associação entre erro e campo;
- nome/tipo correto.

WCAG 2.2 exige que erros detectados automaticamente sejam identificados e descritos em texto; quando uma correção conhecida existe, ela deve ser sugerida.

## 6. Status dinâmico

Loading, sucesso, falha e atualizações não podem depender apenas de mudança visual.

Para status que não exigem mudança de foco, use semântica apropriada de status/live region.

WCAG 2.2 SC 4.1.3 define requisitos para status messages determinados programaticamente sem exigir que o foco seja movido.

## 7. Cor não pode ser o único sinal

Nunca comunique:
- erro apenas em vermelho;
- sucesso apenas em verde;
- seleção apenas por cor;
- estado apenas por mudança cromática.

Use texto, estrutura ou estado programático.

## 8. Contraste e visibilidade

Valide:
- texto;
- controles;
- foco;
- estados ativos/inativos;
- conteúdo importante.

Não trate contraste como única dimensão de acessibilidade.

## 9. Reflow e responsividade

Teste:
- viewport estreito;
- zoom;
- teclado virtual;
- orientação;
- aumento de fonte quando aplicável.

Não crie layouts que escondam conteúdo importante ou causem scroll horizontal desnecessário para tarefas comuns.

## 10. Componentes customizados

Para:
- combobox;
- tabs;
- accordion;
- menu;
- listbox;
- dialog;
- grid;

use o padrão APG correspondente, em vez de inventar interação de teclado.

## Integração

> Para arquitetura, estado e tratamento técnico de erros, usar /hm-engineer.

> Para rastreabilidade e diagnóstico, usar /hm-logger.

> Para mensagem, componente e recuperação do erro na experiência do usuário, usar /hm-error-feedback.

> Para validação visual/funcional integrada, usar /hm-qa.

## Anti-patterns críticos

- div clicável sem semântica;
- tabindex positivo;
- foco perdido após fechar modal;
- foco invisível;
- custom widget sem teclado;
- erro somente por cor;
- input sem label;
- aria usado para mascarar HTML incorreto;
- status de loading invisível para screen reader;
- modal sem foco inicial;
- modal sem retorno de foco;
- componente com teclado diferente do padrão esperado sem razão;
- conteúdo importante inacessível em zoom/reflow.

## Checklist

- [ ] HTML semântico
- [ ] nomes acessíveis
- [ ] teclado
- [ ] foco
- [ ] dialog behavior
- [ ] labels
- [ ] error identification
- [ ] status messages
- [ ] contraste
- [ ] reflow
- [ ] widgets APG
- [ ] screen reader smoke test

## Output

~~~
HM-ACCESSIBILITY
Telas/componentes auditados: [N]

SEMÂNTICA: PASS/FAIL
TECLADO: PASS/FAIL
FOCO: PASS/FAIL
FORMULÁRIOS: PASS/FAIL
ERROS/STATUS: PASS/FAIL
CONTRASTE: PASS/FAIL
REFLOW: PASS/FAIL
WIDGETS ARIA: PASS/FAIL/N-A

BLOCKERS
[lista]

VEREDICTO
Acessível no baseline / BLOQUEADO
~~~

## Fontes

- W3C WCAG 2.2: https://www.w3.org/TR/WCAG22/
- WAI-ARIA Overview: https://www.w3.org/WAI/standards-guidelines/aria/
- WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/
- Dialog Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/
- Keyboard Interface: https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/
