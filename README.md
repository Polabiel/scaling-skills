# scaling-skills

Minhas skills baseadas na Filosofia Higher Mind e nas minhas experiências com código como dev.

Coleção de **31 skills** para agentes de IA (padrão [Agent Skills](https://agentskills.io) — uma pasta com `SKILL.md`):

| Skill | O que faz |
|---|---|
| [`hm-accessibility`](hm-accessibility/SKILL.md) | Auditoria de acessibilidade baseada em WCAG 2.2 e WAI-ARIA |
| [`hm-align`](hm-align/SKILL.md) | Valida se o que está sendo construído é a coisa certa (visão, timing, valor real) |
| [`hm-analytics`](hm-analytics/SKILL.md) | Product analytics, funis, ativação, retenção, cohorts e experimentos |
| [`hm-api-contract`](hm-api-contract/SKILL.md) | Valida contratos de API, schemas, erros, compatibilidade e idempotência |
| [`hm-cli`](hm-cli/SKILL.md) | Construção de CLI no padrão Higher Mind (terminal como produto cinematográfico) |
| [`hm-conversion`](hm-conversion/SKILL.md) | Design de conversão baseado em evidências, fricção, intenção e validação |
| [`hm-copy`](hm-copy/SKILL.md) | UX writing e microcopy orientados a clareza, ação e consistência |
| [`hm-data-integrity`](hm-data-integrity/SKILL.md) | Dados sagrados — backup, migrations, operações destrutivas, DR, compliance |
| [`hm-deploy`](hm-deploy/SKILL.md) | Validação de deploy e infraestrutura |
| [`hm-designer`](hm-designer/SKILL.md) | Validação visual de interface (sofisticação, pixel-perfect, dark-first) |
| [`hm-engineer`](hm-engineer/SKILL.md) | Validação de código senior-level pré-ship (baseline, OWASP, custo, resiliência) |
| [`hm-error-feedback`](hm-error-feedback/SKILL.md) | Converte erros reais em feedback visual fiel, claro, acionável e seguro |
| [`hm-incident`](hm-incident/SKILL.md) | Incident response, contenção, timeline, recuperação e postmortem |
| [`hm-init`](hm-init/SKILL.md) | Início de projeto novo (stack, infra Docker-first, segurança day-1) |
| [`hm-llm-guardrails`](hm-llm-guardrails/SKILL.md) | 14 patterns obrigatórios para apps que integram LLM em produção |
| [`hm-logger`](hm-logger/SKILL.md) | Logging estruturado, Grafana/Loki, correlação e observabilidade |
| [`hm-performance`](hm-performance/SKILL.md) | Profiling com metas concretas e fix por gargalo (8 domínios) |
| [`hm-product`](hm-product/SKILL.md) | Valida problemas, necessidades, hipóteses e valor real de produto |
| [`hm-qa`](hm-qa/SKILL.md) | Quality assurance que declara baseline-ready (Dev Team) |
| [`hm-security`](hm-security/SKILL.md) | Auditoria de segurança profunda (L1/L2/L3, 14 domínios) |
| [`hm-sequoia`](hm-sequoia/SKILL.md) | Valida se a direção estratégica está alinhada com o futuro |
| [`hm-design-system`](hm-design-system/SKILL.md) | Governança de tokens, componentes, padrões, acessibilidade e evolução do design system |
| [`pm-data`](pm-data/SKILL.md) | Gestão de produto orientada por dados, métricas, tracking e governança |
| [`pm-growth`](pm-growth/SKILL.md) | Growth de produto: aquisição, ativação, retenção, monetização e experimentação |
| [`pm-ops`](pm-ops/SKILL.md) | Product Operations: processos, feedback, handoffs, launch e operação |
| [`pm-strategy`](pm-strategy/SKILL.md) | Estratégia de produto, outcomes, apostas, prioridades e roadmap |
| [`pm-technical`](pm-technical/SKILL.md) | Gestão técnica de produto, viabilidade, dívida, arquitetura e NFRs |
| [`hm-state-machine`](hm-state-machine/SKILL.md) | Modela estados, eventos, transições e fluxos assíncronos |
| [`hm-ux-flow`](hm-ux-flow/SKILL.md) | Validação de fluxo cognitivo end-to-end (3 tipos de friction) |
| [`hm-validate-all`](hm-validate-all/SKILL.md) | Orquestrador pré-ship que dispara as skills de validação em ondas |
| [`gsd`](gsd/SKILL.md) | Referência de aplicação do GSD (Goal-Driven Development) — loop de fases Discuss → Plan → Execute → Verify → Ship |

---

## GSD (Goal-Driven Development)

O [`gsd`](gsd/SKILL.md) é uma **skill de referência**: ela não substitui o framework, mas ensina o agente a aplicar a metodologia GSD e instalar o GSD Core no runtime atual.

- **O que é:** framework de context-engineering e spec-driven development que conduz agentes de IA por um loop disciplinado de fases (**Discuss → Plan → Execute → Verify → Ship**), combatendo o *context rot* com subagentes de contexto fresco e verificação real.
- **Site:** https://opengsd.net/ · **Repositório:** https://github.com/open-gsd/gsd-core
- **Instalação do GSD Core:** o `setup` instala o GSD Core **do repositório oficial via npx** (nunca da pasta `gsd/` local, que é só referência):

```bash
npx @opengsd/gsd-core@latest --claude --global     # Claude Code / VS Code
npx @opengsd/gsd-core@latest --opencode --global   # Opencode
```

O instalador oficial aplica as transformações corretas por runtime (skills, agents, hooks, commands). O GSD Core **não suporta Kiro** (sem flag `--kiro`). Depois de instalado: `/gsd-new-project` (projeto novo) ou `/gsd-onboard` (codebase existente).

> **Como se relacionam:** o **GSD** estrutura *como* o trabalho é conduzido (fases, contexto, verificação); as skills **hm-\*** validam a qualidade do que é construído (segurança, performance, QA, design, dados). Use os dois juntos — ex.: `/hm-validate-all` como gate antes do Ship.

## Instalação (1 comando)

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills && cd ~/.claude/skills/scaling-skills && chmod +x setup && ./setup
```

O `setup` detecta quais ferramentas você tem instaladas e instala as skills em cada uma automaticamente.

### Onde cada ferramenta recebe as skills

| Ferramenta | Diretório | Modo | GSD Core |
|---|---|---|---|
| **Claude Code** | `~/.claude/skills/` | symlink | via npx (`--claude`) |
| **VS Code** | `~/.claude/skills/` | symlink | via npx (`--claude`) |
| **Kiro** | `~/.kiro/skills/` | cópia | não suportado |
| **Opencode** | `~/.config/opencode/skills/` | symlink | via npx (`--opencode`) |

> **Por que o Kiro usa cópia?** O Kiro IDE não segue symlinks em `~/.kiro/skills/` (issue [kirodotdev/Kiro#6401](https://github.com/kirodotdev/Kiro/issues/6401)). Por isso o setup copia as pastas para o Kiro — se você atualizar o repositório, rode o `setup` de novo para sincronizar.
>
> **VS Code** lê skills pessoais de `~/.claude/skills/` (além de `~/.agents/skills/` e `~/.copilot/skills/`), então a instalação do Claude Code já cobre o VS Code.

---

## Instalação manual (sem o setup)

> As seções abaixo instalam apenas as skills **hm-\***. O **GSD Core** é sempre instalado do repositório oficial via npx (veja [GSD](#gsd-goal-driven-development)).

### Claude Code

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills
for d in ~/.claude/skills/scaling-skills/*/; do
  ln -s "$d" ~/.claude/skills/"$(basename "$d")"
done
```

### Kiro

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.kiro/skills/scaling-skills
cp -R ~/.kiro/skills/scaling-skills/*/ ~/.kiro/skills/
```

### VS Code

Igual ao Claude Code (o VS Code lê `~/.claude/skills/`):

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills
for d in ~/.claude/skills/scaling-skills/*/; do
  ln -s "$d" ~/.claude/skills/"$(basename "$d")"
done
```

### Opencode

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.config/opencode/skills/scaling-skills
for d in ~/.config/opencode/skills/scaling-skills/*/; do
  ln -s "$d" ~/.config/opencode/skills/"$(basename "$d")"
done
```

---

## Uso do setup

```bash
./setup                  # instala em todas as ferramentas detectadas (+ GSD Core via npx)
./setup --all            # idem (explícito)
./setup --claude         # instala só no Claude Code (+ GSD Core via npx)
./setup --kiro           # instala só no Kiro (GSD não suportado)
./setup --vscode         # instala só no VS Code (+ GSD Core via npx --claude)
./setup --opencode       # instala só no Opencode (+ GSD Core via npx)
./setup --copy           # força cópia em vez de symlink em todos os destinos
./setup --list           # lista as skills disponíveis
./setup --uninstall      # remove as skills instaladas (+ GSD Core via npx --uninstall)
./setup --help           # ajuda
```

> **Atualizar skills:** `cd ~/.claude/skills/scaling-skills && git pull && ./setup`

---

## Como usar as skills

As skills são ativadas automaticamente pelo agente quando a descrição corresponde ao contexto — ou invocadas como slash command:

- **Claude Code / VS Code / Opencode:** `/hm-security`, `/hm-qa`, `/hm-validate-all`, etc.
- **Kiro:** digite o nome da skill no chat ou importe via painel *Agent Steering & Skills*.

A skill `hm-validate-all` orquestra as demais: rode-a antes de qualquer ship para produção.

---

## Licença

[MIT](LICENSE)