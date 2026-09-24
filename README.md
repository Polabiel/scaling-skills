# scaling-skills

Minhas skills baseadas na Filosofia Higher Mind e nas minhas experiências com código como dev.

Coleção de **15 skills** para agentes de IA (padrão [Agent Skills](https://agentskills.io) — uma pasta com `SKILL.md`):

| Skill | O que faz |
|---|---|
| [`hm-align`](hm-align/SKILL.md) | Valida se o que está sendo construído é a coisa certa (visão, timing, valor real) |
| [`hm-cli`](hm-cli/SKILL.md) | Construção de CLI no padrão Higher Mind (terminal como produto cinematográfico) |
| [`hm-data-integrity`](hm-data-integrity/SKILL.md) | Dados sagrados — backup, migrations, operações destrutivas, DR, compliance |
| [`hm-deploy`](hm-deploy/SKILL.md) | Validação de deploy e infraestrutura |
| [`hm-designer`](hm-designer/SKILL.md) | Validação visual de interface (sofisticação, pixel-perfect, dark-first) |
| [`hm-engineer`](hm-engineer/SKILL.md) | Validação de código senior-level pré-ship (baseline, OWASP, custo, resiliência) |
| [`hm-init`](hm-init/SKILL.md) | Início de projeto novo (stack, infra Docker-first, segurança day-1) |
| [`hm-llm-guardrails`](hm-llm-guardrails/SKILL.md) | 14 patterns obrigatórios para apps que integram LLM em produção |
| [`hm-logger`](hm-logger/SKILL.md) | Logging estruturado com traceId, usuário e contexto HTTP |
| [`hm-performance`](hm-performance/SKILL.md) | Profiling com metas concretas e fix por gargalo (8 domínios) |
| [`hm-qa`](hm-qa/SKILL.md) | Quality assurance que declara baseline-ready (Dev Team) |
| [`hm-security`](hm-security/SKILL.md) | Auditoria de segurança profunda (L1/L2/L3, 14 domínios) |
| [`hm-sequoia`](hm-sequoia/SKILL.md) | Valida se a direção estratégica está alinhada com o futuro |
| [`hm-ux-flow`](hm-ux-flow/SKILL.md) | Validação de fluxo cognitivo end-to-end (3 tipos de friction) |
| [`hm-validate-all`](hm-validate-all/SKILL.md) | Orquestrador pré-ship que dispara as 12 skills de validação em ondas |

---

## Instalação (1 comando)

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills && cd ~/.claude/skills/scaling-skills && chmod +x setup && ./setup
```

O `setup` detecta quais ferramentas você tem instaladas e instala as skills em cada uma automaticamente.

### Onde cada ferramenta recebe as skills

| Ferramenta | Diretório | Modo |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | symlink |
| **VS Code** | `~/.claude/skills/` | symlink |
| **Kiro** | `~/.kiro/skills/` | cópia |
| **Opencode** | `~/.config/opencode/skills/` | symlink |

> **Por que o Kiro usa cópia?** O Kiro IDE não segue symlinks em `~/.kiro/skills/` (issue [kirodotdev/Kiro#6401](https://github.com/kirodotdev/Kiro/issues/6401)). Por isso o setup copia as pastas para o Kiro — se você atualizar o repositório, rode o `setup` de novo para sincronizar.
>
> **VS Code** lê skills pessoais de `~/.claude/skills/` (além de `~/.agents/skills/` e `~/.copilot/skills/`), então a instalação do Claude Code já cobre o VS Code.

---

## Instalação manual (sem o setup)

### Claude Code

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills
for d in ~/.claude/skills/scaling-skills/hm-*/; do
  ln -s "$d" ~/.claude/skills/"$(basename "$d")"
done
```

### Kiro

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.kiro/skills/scaling-skills
cp -R ~/.kiro/skills/scaling-skills/hm-* ~/.kiro/skills/
```

### VS Code

Igual ao Claude Code (o VS Code lê `~/.claude/skills/`):

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.claude/skills/scaling-skills
for d in ~/.claude/skills/scaling-skills/hm-*/; do
  ln -s "$d" ~/.claude/skills/"$(basename "$d")"
done
```

### Opencode

```bash
git clone https://github.com/Polabiel/scaling-skills ~/.config/opencode/skills/scaling-skills
for d in ~/.config/opencode/skills/scaling-skills/hm-*/; do
  ln -s "$d" ~/.config/opencode/skills/"$(basename "$d")"
done
```

---

## Uso do setup

```bash
./setup                  # instala em todas as ferramentas detectadas
./setup --all            # idem (explícito)
./setup --claude         # instala só no Claude Code
./setup --kiro           # instala só no Kiro
./setup --vscode         # instala só no VS Code
./setup --opencode       # instala só no Opencode
./setup --copy           # força cópia em vez de symlink em todos os destinos
./setup --list           # lista as skills disponíveis
./setup --uninstall      # remove as skills instaladas
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