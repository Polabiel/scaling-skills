
---
name: hm-error-feedback
description: Converte erros reais do sistema em feedback visual fiel, claro, acionável e acessível para o usuário. Use junto com hm-qa, hm-engineer e hm-logger ao corrigir ou criar estados de erro em formulários, modais, páginas, toasts, banners, uploads, pagamentos, integrações, streaming, jobs e fluxos assíncronos. A skill exige que a UI represente corretamente o estado real da operação, traduza a causa conhecida para a linguagem do usuário, preserve contexto e dados, indique recuperação quando possível e nunca exponha detalhes técnicos ou sensíveis desnecessários.
---

# /hm-error-feedback — Feedback Visual de Erros

Você está agora em **modo error feedback**.

Seu trabalho não é apenas escrever uma mensagem bonita para um erro. Seu trabalho é garantir que exista uma cadeia consistente:

erro real → diagnóstico → classificação → apresentação visual → ação de recuperação → validação

O usuário precisa receber um feedback que seja **fiel ao que realmente aconteceu**, compreensível e útil para decidir o próximo passo.

> **Nota — origem do erro:** `hm-error-feedback` não deve inferir a causa técnica pela mensagem recebida. Para a semântica do erro, estado, retryability, idempotência e contrato de API, consulte `/hm-engineer`; para rastreabilidade, `traceId`, `eventName`, erro serializado e diagnóstico, consulte `/hm-logger`. Esta skill é responsável por traduzir a verdade conhecida em feedback visual para o usuário.

## Princípio central

**A UI não deve mentir sobre o estado do sistema.**

Se uma operação falhou, não mostre sucesso.

Se a operação ainda está processando, não mostre erro definitivo.

Se a aplicação conhece a causa, não esconda a causa atrás de "Algo deu errado".

Se a aplicação não conhece a causa com segurança, não invente uma causa.

Se o sistema conhece detalhes técnicos que são úteis para diagnóstico, mantenha esses detalhes no canal técnico (hm-logger) e exponha ao usuário apenas o que é necessário para compreender e agir.

Uma boa implementação separa:

- **verdade técnica** — o que o sistema realmente detectou;
- **verdade de domínio** — o que isso significa para a operação do produto;
- **feedback de usuário** — o que a pessoa precisa saber;
- **diagnóstico interno** — o que QA, engenharia e suporte precisam rastrear.

## Relação com outras skills

Esta skill **não substitui** QA, engenharia ou logging.

### hm-engineer

Determina a causa técnica, o comportamento esperado, as condições de falha e a estratégia de tratamento.

### hm-logger

Preserva o diagnóstico técnico: traceId, contexto HTTP, erro serializado, código e dados necessários para investigação.

### hm-qa

Reproduz o erro, verifica estados de falha, edge cases, mobile, regressões e confirma o comportamento real.

### hm-error-feedback

Transforma o resultado das três camadas anteriores em **feedback visual correto para o usuário** e verifica se o estado visual corresponde ao estado real.

Fluxo recomendado:

hm-engineer → hm-logger → hm-qa → hm-error-feedback

Quando a alteração é visual, hm-designer pode entrar depois para validar consistência visual e implementação.

## Regra de ouro: erro técnico ≠ mensagem técnica

Um erro como:

    PrismaClientKnownRequestError:
    Unique constraint failed on the fields: (email)

não deve ser mostrado literalmente para um usuário final.

Mas também não devemos transformar tudo em:

    Algo deu errado.

A tradução correta preserva a verdade do problema:

> **Este e-mail já está cadastrado.**  
> Tente entrar com essa conta ou use outro e-mail.

A interface remove o jargão técnico, mas não remove a informação relevante.

## Contrato de erro

Sempre que possível, trabalhe com uma representação estruturada do erro.

Um contrato recomendado:

    interface UserFacingError {
      code: string;
      type: "validation" | "authentication" | "authorization" | "conflict" | "network" | "timeout" | "business" | "not-found" | "server" | "unknown";
      title: string;
      detail?: string;
      action?: {
        label: string;
        type: "retry" | "edit" | "login" | "contact-support" | "refresh" | "navigate" | "dismiss";
      };
      field?: string;
      traceId?: string;
      retryable?: boolean;
    }

Isso não precisa ser exatamente a estrutura do projeto. O importante é que o frontend tenha informação suficiente para distinguir:

- o tipo do problema;
- onde o problema ocorreu;
- se existe uma ação de recuperação;
- se a tentativa pode ser repetida;
- se há um identificador técnico para suporte;
- qual conteúdo é apropriado para o usuário.

RFC 9457 recomenda separar identificador do tipo de problema, resumo legível, detalhe específico da ocorrência e identificador da ocorrência. O campo detail deve ajudar o cliente a corrigir o problema, e não funcionar como dump de debugging.

## Princípio de fidelidade

A mensagem visual precisa ser a **melhor representação verdadeira do erro conhecido**, não uma interpretação arbitrária.

### Exemplo 1 — pagamento recusado

Erro técnico:

    payment_intent.payment_failed
    decline_code: insufficient_funds

Mensagem ruim:

> Erro no servidor.

Mensagem infiel:

> Sua internet caiu.

Mensagem adequada:

> **Não foi possível concluir o pagamento**  
> O pagamento foi recusado. Verifique o limite ou tente outra forma de pagamento.

A UI traduz o erro de domínio sem inventar uma causa diferente.

### Exemplo 2 — timeout

Erro técnico:

    ETIMEDOUT

Mensagem adequada quando a operação pode ser repetida:

> **A operação demorou mais que o esperado**  
> Não conseguimos concluir a solicitação. Tente novamente.

Não declarar "o servidor caiu" se isso não foi comprovado.

### Exemplo 3 — erro inesperado

Erro técnico:

    ReferenceError: foo is not defined

Mensagem de usuário:

> **Não foi possível concluir esta ação**  
> Tente novamente. Se o problema continuar, informe o código de referência ao suporte.

Internamente:

- stack completo no logger;
- traceId;
- rota;
- status HTTP;
- contexto;
- causa original.

O usuário não precisa conhecer Prisma, stack trace ou detalhes de banco para conseguir agir.

## Classificação obrigatória

Antes de escolher o componente visual, classifique o erro.

### 1. Validação de entrada

O usuário forneceu um valor inválido, incompleto ou incompatível com a regra.

Exemplos:
- e-mail inválido
- campo obrigatório vazio
- senha fora dos critérios
- formato inválido
- valor fora de faixa

**Apresentação preferida:** erro inline próximo ao campo.

Se houver múltiplos erros em um formulário:
- mostrar resumo dos erros;
- indicar cada campo;
- permitir navegação até o erro;
- manter as informações já digitadas.

WCAG 2.2 exige que erros de entrada detectados automaticamente sejam identificados e descritos em texto. Quando uma correção conhecida existe, ela também deve ser sugerida.

Fontes: WCAG 2.2 SC 3.3.1 e 3.3.3.

### 2. Regra de negócio

O dado pode estar tecnicamente válido, mas a operação não pode acontecer.

Exemplos:
- plano incompatível com a ação;
- recurso já utilizado;
- limite atingido;
- condição comercial não atendida.

**Apresentação preferida:** mensagem no contexto da ação, explicando o motivo e o próximo caminho.

Não rotule como "campo inválido" algo que é uma restrição do produto.

### 3. Autenticação

A sessão, credencial ou autenticação não é suficiente.

Exemplos:
- sessão expirada;
- token inválido;
- autenticação necessária.

**Apresentação preferida:** feedback contextual que indique o próximo passo, como entrar novamente.

Preserve o estado do trabalho sempre que possível.

### 4. Autorização

O usuário está autenticado, mas não possui permissão.

Exemplos:
- recurso sem acesso;
- ação restrita;
- permissão insuficiente.

**Apresentação preferida:** explicar que a ação não está disponível para aquela conta e, quando aplicável, indicar como solicitar acesso.

Não mostre stack trace, nomes internos de roles ou detalhes de autorização que não sejam necessários.

### 5. Conflito

O estado do recurso mudou e impede a operação.

Exemplos:
- recurso já foi alterado;
- edição concorrente;
- registro já existe;
- operação já foi executada.

**Apresentação preferida:** explicar o conflito e oferecer sincronizar, atualizar, revisar ou tentar novamente.

### 6. Rede / indisponibilidade temporária

A operação falhou por conectividade ou dependência temporariamente indisponível.

**Apresentação preferida:**
- mensagem clara;
- indicar tentativa novamente quando apropriado;
- preservar o estado local;
- evitar criar a impressão de que os dados foram perdidos.

### 7. Timeout

A aplicação não recebeu resultado dentro do limite esperado.

Não assuma automaticamente que a operação **não aconteceu**.

Esse caso é especialmente importante em pagamentos, criação de recursos e jobs assíncronos.

Antes de mostrar "falhou":
- a operação é idempotente?
- existe polling/status?
- o backend pode ter concluído depois?
- é seguro repetir?

Quando a confirmação é incerta, prefira:

> **Não conseguimos confirmar o resultado da operação.**

e ofereça consulta do estado antes de disparar uma segunda operação.

### 8. Erro inesperado do servidor

A causa é interna ou não pode ser exposta ao usuário.

**Apresentação preferida:**
- reconhecer a falha;
- dizer o que o usuário pode fazer;
- oferecer retry quando seguro;
- fornecer referência para suporte.

Nunca mostrar:
- stack trace;
- caminho de arquivo;
- SQL;
- nomes de tabela;
- credenciais;
- tokens;
- IP interno;
- variáveis de ambiente;
- detalhes de infraestrutura.

OWASP recomenda que mensagens apresentadas aos usuários não vazem dados críticos, enquanto os logs devem conter informação suficiente para suporte, QA, forensics e resposta a incidentes.

## Escolha do componente visual

O componente deve corresponder à **importância, persistência e ação necessária** do erro.

### Inline error

Use quando:
- o problema pertence a um campo;
- a correção acontece naquele mesmo contexto;
- o usuário sabe onde agir.

Exemplo:

> **E-mail inválido**  
> Digite um endereço no formato nome@dominio.com.

### Error summary

Use quando:
- existem vários erros de formulário;
- o usuário pode estar fora do campo com problema;
- é importante oferecer uma visão geral.

O padrão GOV.UK recomenda um resumo no topo junto das mensagens junto aos campos e que as mensagens sejam consistentes entre esses dois pontos.

### Alert / diálogo

Use quando:
- a informação é crítica;
- a ação exige atenção imediata;
- continuar sem ler o erro pode causar dano;
- existe uma ação clara de recuperação/decisão.

Não use modal apenas para anunciar uma informação que poderia aparecer no próprio contexto.

Apple recomenda que alerts sejam usados com parcimônia e contenham apenas informação essencial e ações úteis.

### Banner

Use quando:
- o problema afeta uma área, página ou serviço;
- o usuário precisa saber disso enquanto continua no fluxo;
- não é necessário interromper completamente a tarefa.

### Toast

Use apenas para feedback breve e não crítico.

Evite colocar erros que exigem leitura cuidadosa ou recuperação complexa em toasts temporários.

Um toast que desaparece antes de ser lido pode transformar um erro diagnosticável em um erro invisível.

### Estado persistente na interface

Use quando:
- a tarefa continua em background;
- existe streaming;
- existe upload;
- existe processamento assíncrono;
- o usuário precisa consultar o estado depois.

O erro precisa permanecer visível no contexto relevante.

## A mensagem deve responder às perguntas certas

Uma boa mensagem de erro deve responder, quando houver informação suficiente:

1. **O que aconteceu?**
2. **Por que aconteceu?**
3. **O que posso fazer agora?**

Microsoft documenta exatamente essa estrutura para mensagens de erro: problema, causa e solução, além de características como relevância, acionabilidade, linguagem centrada no usuário, brevidade, clareza e especificidade.

NN/G também orienta que mensagens sejam precisas, em linguagem compreensível e acompanhadas de uma solução construtiva.

Não obrigue o usuário a fazer troubleshooting se o sistema já consegue determinar a causa.

## Não culpe o usuário

Evite:

- "Você fez algo errado."
- "Você informou um dado incorreto."
- "Você não preencheu corretamente."

Prefira:

- "Este campo precisa de um número."
- "O e-mail informado não é válido."
- "Não foi possível salvar porque este nome já está em uso."

O erro descreve o estado do sistema ou do dado, não julga a pessoa.

## Não transforme códigos em mensagens

Evite:

    Erro 500.
    Error 329347.
    E_AUTH_1042.

Códigos podem existir como referência técnica ou identificador de suporte, mas não devem substituir a explicação humana.

NN/G recomenda esconder ou minimizar códigos obscuros e usá-los principalmente para diagnóstico.

## Erros técnicos devem ter dois canais

### Canal do usuário

Curto, compreensível, contextual e acionável.

### Canal técnico

Completo, rastreável e seguro.

Exemplo:

**Usuário**

> Não foi possível salvar as alterações. Tente novamente.  
> Código de referência: a81f...

**Logger**

    {
      "traceId": "a81f...",
      "user": { "id": "..." },
      "http": {
        "method": "POST",
        "route": "/api/agents/...",
        "statusCode": 500,
        "latencyMs": 842
      },
      "error": {
        "type": "PrismaClientKnownRequestError",
        "code": "P2002",
        "message": "...",
        "stack": "..."
      }
    }

O usuário não precisa conhecer Prisma, stack trace ou detalhes de banco para conseguir agir.

## Preserve o trabalho do usuário

Um erro não deve causar uma segunda perda.

Ao falhar:
- preserve valores digitados;
- preserve seleção;
- preserve arquivos já escolhidos quando possível;
- preserve contexto de navegação;
- preserve estado local;
- não resete o formulário sem motivo;
- não obrigue o usuário a refazer tudo sem necessidade.

Isso é especialmente importante em formulários longos, uploads e fluxos de alta intenção.

## Quando o erro acontece durante uma ação

Não basta trocar a mensagem. Verifique o estado do botão.

### Durante envio

O usuário deve conseguir perceber:
- que a operação foi iniciada;
- se está processando;
- se falhou;
- se pode tentar novamente.

### Após falha

Nunca deixe:
- botão permanentemente desabilitado;
- spinner infinito;
- estado visual indistinguível de sucesso;
- formulário aparentemente concluído quando o backend recusou a operação.

### Retry

Só ofereça retry automático/manual quando:
- a operação puder ser repetida com segurança;
- o sistema não criar duplicidade;
- o estado da operação for conhecido ou idempotente.

Não transforme um timeout desconhecido em "tente de novo" quando um segundo clique puder criar duas cobranças ou duas entidades.

## Acessibilidade do erro

Erro visual não pode depender somente de cor.

WCAG 2.2 exige texto para identificação de erros de entrada e exige que status messages possam ser determinados programaticamente para tecnologias assistivas sem necessariamente mover foco.

Verifique:
- texto do erro;
- associação com o campo correto;
- contraste;
- foco quando necessário;
- leitura por screen reader;
- aria-invalid quando apropriado;
- aria-describedby quando apropriado;
- role="alert" ou live region somente quando o comportamento exigir;
- role="status" para status não críticos que não devem roubar foco.

Não transforme todo erro em alert modal: isso gera interrupção excessiva.

## Segurança

**Nunca exiba automaticamente o erro bruto vindo do backend.**

Antes de renderizar uma mensagem, pergunte:

- contém stack trace?
- contém path interno?
- contém SQL?
- contém nome de tabela/coluna?
- contém hostname/IP interno?
- contém token?
- contém chave?
- contém dados pessoais?
- contém detalhes de infraestrutura?
- contém informação que permite enumerar recursos ou contas?

OWASP documenta que mensagens de erro detalhadas podem revelar caminhos internos, bibliotecas, versões, bancos, tabelas e outras informações úteis para ataques.

A UI deve receber uma representação segura para usuário, não o objeto Error bruto.

## Estados que precisam ser validados

Para cada operação relevante, considere pelo menos:

    idle
    → submitting
    → success
    → validation-error
    → business-error
    → unauthorized
    → conflict
    → network-error
    → timeout
    → server-error
    → unknown-error

Para operações assíncronas:

    queued
    → processing
    → success
    → failed
    → uncertain
    → cancelled

Se um desses estados é possível no backend mas não existe no frontend, existe um gap entre sistema e experiência do usuário.

## Anti-padrões críticos

Sinalize imediatamente:

- UI mostra sucesso quando a operação falhou;
- UI mostra erro definitivo quando o resultado ainda é incerto;
- toda exceção vira "Algo deu errado";
- frontend renderiza error.message bruto;
- stack trace aparece na interface;
- SQL ou detalhes do banco aparecem na interface;
- erro aparece apenas por cor;
- erro aparece apenas em toast e desaparece antes de ser percebido;
- usuário precisa refazer todo formulário após erro recuperável;
- botão fica travado após falha;
- retry pode duplicar uma operação;
- timeout é tratado automaticamente como "não aconteceu";
- mensagem diz uma causa que o sistema não comprovou;
- código técnico substitui explicação;
- mensagem culpa o usuário;
- a mesma mensagem é usada para causas diferentes que o sistema consegue distinguir;
- erro crítico não tem ação de recuperação;
- erro de campo aparece distante do campo;
- status assíncrono desaparece quando o usuário navega.

## Critério de fidelidade

Antes de aprovar um feedback de erro, responda:

### Verdade
A mensagem representa exatamente o que sabemos que aconteceu?

### Causa
Estamos afirmando somente causas comprovadas?

### Contexto
O usuário consegue entender qual ação foi afetada?

### Ação
Existe um próximo passo claro?

### Estado
A UI representa corretamente se a operação falhou, está processando, foi concluída ou está incerta?

### Recuperação
O usuário consegue corrigir ou tentar novamente sem perder trabalho?

### Diagnóstico
QA, engenharia e suporte conseguem chegar ao erro técnico original a partir do traceId/código?

### Segurança
Nenhuma informação técnica ou sensível desnecessária está sendo exposta?

### Acessibilidade
Uma pessoa que não percebe cor, animação ou toast também recebe o erro de forma programaticamente detectável?

## Fluxo de investigação integrado

Quando um erro visual for encontrado, siga esta sequência:

### 1. Reproduzir — hm-qa

Confirme:
- ação realizada;
- estado inicial;
- resultado observado;
- viewport/dispositivo;
- frequência;
- se ocorre sempre ou intermitentemente.

### 2. Encontrar a causa — hm-engineer

Identifique:
- origem real;
- tipo de erro;
- causa conhecida;
- comportamento esperado;
- se a operação é retryable/idempotente;
- estados que o frontend precisa conhecer.

### 3. Rastrear — hm-logger

Garanta:
- traceId;
- usuário/contexto;
- HTTP;
- erro serializado;
- código;
- dados suficientes para reproduzir/investigar;
- ausência de secrets/PII indevida.

### 4. Projetar o feedback — hm-error-feedback

Defina:
- copy;
- severidade;
- componente visual;
- posição;
- persistência;
- ação;
- recuperação;
- comportamento durante retry;
- acessibilidade.

### 5. Validar novamente — hm-qa

Teste:
- happy path;
- causa original;
- cada causa conhecida;
- timeout;
- rede;
- retry;
- refresh;
- mobile;
- teclado/screen reader quando aplicável;
- ausência de vazamento técnico.

## Formato de saída

Use:

### Erro real
O que o sistema efetivamente detectou?

### Causa conhecida
O que foi comprovado? O que permanece incerto?

### Estado da operação
Falhou / processando / sucesso / resultado incerto.

### Feedback atual
O que o usuário vê hoje?

### Problema do feedback
Onde ele é falso, genérico, invisível, inacessível ou pouco acionável?

### Feedback recomendado
Título, descrição, ação e componente visual.

### Recuperação
Como o usuário corrige, tenta novamente ou acompanha o estado?

### Diagnóstico
Qual traceId, código ou vínculo com logger permite investigação?

### Segurança
Existe informação técnica ou sensível sendo exposta?

### Validação
Como QA deve reproduzir e confirmar o novo estado?

## Princípios baseados em evidências

### Nielsen Norman Group

A heurística de "Help Users Recognize, Diagnose, and Recover from Errors" orienta mensagens em linguagem simples, indicação precisa do problema, sugestão construtiva de solução e tratamento visual que facilite perceber o erro. NN/G também recomenda evitar jargão técnico e mensagens genéricas.

**Aplicação:** o feedback precisa ajudar a pessoa a reconhecer, diagnosticar no nível necessário e recuperar-se do problema.

### W3C / WCAG 2.2

SC 3.3.1 exige identificação textual do erro detectado. SC 3.3.3 exige sugestão de correção quando uma sugestão conhecida puder ser fornecida. SC 4.1.3 trata da comunicação programática de status messages sem exigir mudança de foco.

**Aplicação:** texto do erro, associação ao elemento afetado e comportamento acessível fazem parte da implementação, não são detalhes opcionais de polish.

### GOV.UK Design System

O padrão de error summary combina resumo da falha com mensagens junto aos campos e move o foco para o resumo em erros de validação, criando um caminho de navegação direto até os problemas.

**Aplicação:** formulários com múltiplas falhas devem oferecer orientação global e local.

### Microsoft

As diretrizes de mensagens de erro recomendam comunicar **problema + causa + solução**, com linguagem relevante, acionável, centrada no usuário, breve, clara e específica. A documentação também afirma que bons erros dependem do design do tratamento de erros no software, não apenas do texto da interface.

**Aplicação:** uma mensagem precisa ser suportada por um modelo de erro capaz de distinguir as causas relevantes.

### Apple

A Apple orienta usar alerts com parcimônia, incluindo apenas informação essencial e ações úteis. Para escrever erros, recomenda mensagens diretas, específicas, próximas do problema e sem culpar o usuário.

**Aplicação:** escolha a apresentação visual pela importância e necessidade de ação, não por preferência estética.

### RFC 9457

O padrão para Problem Details separa type, title, detail e instance, permitindo que APIs carreguem uma descrição legível e um identificador da ocorrência. O RFC afirma que detail deve ajudar o cliente a corrigir o problema e alerta para o risco de expor detalhes de implementação.

**Aplicação:** o contrato técnico pode ser estruturado e rastreável sem obrigar o usuário a receber detalhes internos.

### OWASP

OWASP alerta que mensagens de erro detalhadas podem vazar caminhos, versões, bibliotecas, bancos, tabelas e outras informações úteis para ataques. Ao mesmo tempo, a organização recomenda que logs mantenham informação suficiente para suporte e investigação.

**Aplicação:** separar rigorosamente o canal de usuário do canal de diagnóstico.

## Fontes

- Nielsen Norman Group — Error-Message Guidelines: https://www.nngroup.com/articles/error-message-guidelines/
- Nielsen Norman Group — 10 Usability Heuristics, #9: https://www.nngroup.com/articles/ten-usability-heuristics/
- W3C — WCAG 2.2, SC 3.3.1 Error Identification: https://www.w3.org/WAI/WCAG22/Understanding/error-identification
- W3C — WCAG 2.2, SC 3.3.3 Error Suggestion: https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion
- W3C — WCAG 2.2, SC 4.1.3 Status Messages: https://www.w3.org/WAI/WCAG21/Understanding/status-messages
- GOV.UK Design System — Error Summary: https://design-system.service.gov.uk/components/error-summary/
- GOV.UK Design System — Error Message: https://design-system.service.gov.uk/components/error-message/
- Microsoft Learn — Error Messages in Windows: https://learn.microsoft.com/en-us/windows/win32/uxguide/mess-error
- Apple Human Interface Guidelines — Alerts: https://developer.apple.com/design/human-interface-guidelines/alerts
- Apple Human Interface Guidelines — Feedback: https://developer.apple.com/design/human-interface-guidelines/feedback
- RFC 9457 — Problem Details for HTTP APIs: https://www.rfc-editor.org/rfc/rfc9457.html
- OWASP — Improper Error Handling: https://community.owasp.org/Improper_Error_Handling
- OWASP Web Security Testing Guide — Improper Error Handling: https://wstg.owasp.org/v4.2/4-Web_Application_Security_Testing/08-Testing_for_Error_Handling/01-Testing_For_Improper_Error_Handling/

## Regra final

**Não tente fazer o erro parecer menor do que ele é. Não tente fazer o erro parecer maior do que ele é. Represente exatamente o que o produto sabe, no nível de detalhe que o usuário precisa, com um próximo passo claro e um caminho de diagnóstico preservado para o time.**
