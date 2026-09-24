---
name: gsd
description: "Goal-Driven Development (GSD) — Git. Ship. Done. Framework de context-engineering e spec-driven development para agentes de IA. Use como referência obrigatória para estruturar trabalho de codificação em loop de fases (Discuss → Plan → Execute → Verify → Ship), combater context rot, manter escopo/estado/verificação e instalar o GSD Core no runtime atual. Ative antes de iniciar projetos, milestones ou fases de desenvolvimento, ou quando o trabalho do agente estiver perdendo escopo, estado ou verificação."
---

# GSD — Goal-Driven Development (Referência)

**Git. Ship. Done.**

GSD é um framework de **context-engineering** e **spec-driven development** que conduz agentes de IA (Claude Code, OpenCode, Codex, Copilot, Cursor, Windsurf, Antigravity, Kimi CLI, Kilo e outros) por um loop disciplinado de fases. Ele resolve o **context rot** — a degradação de qualidade que acumula conforme o agente enche a janela de contexto — rodando pesquisa, planejamento e execução pesados em subagentes com contexto fresco, mantendo a sessão principal enxuta.

> Esta skill é uma **referência de aplicação**: ela não substitui o GSD Core. Use-a para saber quando e como aplicar GSD, e instale o framework oficial no seu runtime.

## O loop de fases

Cada milestone repete o mesmo loop, uma fase por vez:

1. **Discuss** — capturar decisões de implementação antes de planejar qualquer coisa
2. **Plan** — pesquisar, decompor e verificar se o plano cabe numa janela de contexto fresca
3. **Execute** — executar planos em ondas paralelas; cada executor começa com contexto limpo
4. **Verify** — percorrer o que foi construído; diagnosticar e corrigir antes de declarar pronto
5. **Ship** — criar o PR, arquivar a fase, repetir para a próxima

## Instalação do GSD Core

O GSD Core é instalado **do repositório oficial via npx** — nunca a partir da pasta `gsd/` deste repositório (que é só referência). O `./setup` deste repositório já instala automaticamente para os runtimes detectados; manualmente:

```bash
npx @opengsd/gsd-core@latest --claude --global     # Claude Code / VS Code
npx @opengsd/gsd-core@latest --opencode --global   # Opencode
```

O instalador aplica as transformações corretas por runtime (skills, agents, hooks, commands). **O instalador é obrigatório para compatibilidade entre runtimes** — não copie arquivos de `agents/` ou `commands/` manualmente. O GSD Core não suporta Kiro (sem flag `--kiro`).

Sem Node.js ou em outro runtime: veja [Install on your runtime](https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md).

## Como aplicar

Depois de instalar, comece um projeto novo ou integre um repositório existente:

- `/gsd-new-project` — projeto greenfield
- `/gsd-onboard` — codebase existente

Fluxo recomendado por milestone: **Discuss → Plan → Execute → Verify → Ship**, com artefatos estruturados (`STATE.md`, `CONTEXT.md`, `PLAN.md`) que sobrevivem entre sessões e verificação real antes de declarar a fase concluída.

## Referências

- Site: https://opengsd.net/
- Repositório: https://github.com/open-gsd/gsd-core
- Docs: https://docs.opengsd.net/
- Loop (GitHub automation): `npx @opengsd/gsd-loop@latest install`
- CLI standalone (autônomo): `npm install -g @opengsd/gsd-pi@latest`

## Como se relaciona com as skills hm-*

As skills **hm-\*** validam a qualidade do que é construído (segurança, performance, QA, design, dados). O **GSD** estrutura *como* o trabalho é conduzido (fases, contexto, verificação). Use os dois juntos:

1. **GSD** para estruturar o ciclo de desenvolvimento do projeto (Discuss → Plan → Execute → Verify → Ship)
2. **hm-\*** como gates de validação dentro das fases (ex.: `/hm-validate-all` antes do Ship, `/hm-security` em fases que tocam auth/dados, `/hm-data-integrity` em fases que persistem dados)