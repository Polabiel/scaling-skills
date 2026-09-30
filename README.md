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
| [`pm-innovation`](pm-innovation/SKILL.md) | Inovação técnica, evolução arquitetural, performance preventiva, experimentos e capacidade futura |
| [`pm-ops`](pm-ops/SKILL.md) | Product Operations: processos, feedback, handoffs, launch e operação |
| [`pm-strategy`](pm-strategy/SKILL.md) | Estratégia de produto, outcomes, apostas, prioridades e roadmap |
| [`pm-technical`](pm-technical/SKILL.md) | Gestão técnica de produto, viabilidade, dívida, arquitetura e NFRs |
| [`hm-state-machine`](hm-state-machine/SKILL.md) | Modela estados, eventos, transições e fluxos assíncronos |
| [`hm-ux-flow`](hm-ux-flow/SKILL.md) | Validação de fluxo cognitivo end-to-end (3 tipos de friction) |
| [`hm-validate-all`](hm-validate-all/SKILL.md) | Orquestrador pré-ship que dispara as skills de validação em ondas |
---
## Instalação (1 comando)

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills && cd ~/.claude/skills/scaling-skills && chmod +x setup && ./setup
```

O `setup` detecta o sistema operacional e os runtimes instalados e instala as skills nos diretórios nativos. Use `./setup --doctor` para validar a máquina sem instalar nada.

### Onde cada ferramenta recebe as skills

| Ferramenta | Diretório | Modo |
|---|---|---|---|
| **Claude Code** | `~/.claude/skills/` | cópia |
| **VS Code/Copilot** | `~/.copilot/skills/` | cópia |
| **Kiro** | `~/.kiro/skills/` | cópia |
| **Opencode** | `~/.config/opencode/skills/` | cópia |
| **Codex** | `$CODEX_HOME/skills/` (padrão `~/.codex/skills/`) | cópia |

> O setup copia as pastas das skills para os diretórios nativos. Isso deixa cada instalação com os arquivos reais do repositório, sem depender de symlinks.
>
> **Atualização:** rode o `setup` novamente para sincronizar uma instalação existente.

---

## Instalação manual (sem o setup)

> As seções abaixo instalam apenas as skills deste repositório.

### Claude Code

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.scaling-skills
mkdir -p ~/.claude/skills
for d in ~/.scaling-skills/*/; do
  [ -f "$d/SKILL.md" ] && cp -R "$d" ~/.claude/skills/"$(basename "$d")"
done
```

### Kiro

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.scaling-skills
mkdir -p ~/.kiro/skills
for d in ~/.scaling-skills/*/; do
  [ -f "$d/SKILL.md" ] && cp -R "$d" ~/.kiro/skills/"$(basename "$d")"
done
```

### VS Code/Copilot

O VS Code suporta skills pessoais em `~/.copilot/skills/`.

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.scaling-skills
mkdir -p ~/.copilot/skills
for d in ~/.scaling-skills/*/; do
  [ -f "$d/SKILL.md" ] && cp -R "$d" ~/.copilot/skills/"$(basename "$d")"
done
```

### Opencode

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.scaling-skills
mkdir -p ~/.config/opencode/skills
for d in ~/.scaling-skills/*/; do
  [ -f "$d/SKILL.md" ] && cp -R "$d" ~/.config/opencode/skills/"$(basename "$d")"
done
```

### Codex

O Codex pesquisa skills globais em `$CODEX_HOME/skills/`. Quando `CODEX_HOME` não está definido, o caminho padrão é `~/.codex/skills/`.

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.scaling-skills
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
for d in ~/.scaling-skills/*/; do
  [ -f "$d/SKILL.md" ] && cp -R "$d" "${CODEX_HOME:-$HOME/.codex}/skills/$(basename "$d")"
done
```

---

## Uso do setup

```bash
./setup
./setup --all
./setup --claude
./setup --vscode
./setup --kiro
./setup --opencode
./setup --codex
./setup --copy
./setup --doctor
./setup --list
./setup --uninstall
./setup --help
```

> Use `./setup --doctor` para validar frontmatter, runtimes e pré-requisitos sem instalar.
>
> **Atualização segura:** quando uma skill já existir no destino, o `./setup` pede confirmação. Responda `y`/ `Y` para atualizar/substituir as skills existentes; qualquer outra resposta (inclusive Enter) preserva as existentes. Skills novas são instaladas normalmente.

---

## Como usar as skills

As skills são ativadas automaticamente pelo agente quando a descrição corresponde ao contexto — ou invocadas como slash command:

- **Claude Code / VS Code / Opencode / Codex:** `/hm-security`, `/hm-qa`, `/hm-validate-all`, etc.
- **Kiro:** digite o nome da skill no chat ou importe via painel *Agent Steering & Skills*.

A skill `hm-validate-all` orquestra as demais: rode-a antes de qualquer ship para produção.

---

## Licença

[MIT](LICENSE)