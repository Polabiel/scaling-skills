#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$*"
}

mapfile -t SKILLS < <(
  find "$ROOT" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' -print |
    sed "s#^$ROOT/##" |
    sed 's#/SKILL.md$##' |
    grep -v '^gsd$' |
    sort
)

[ "${#SKILLS[@]}" -gt 0 ] || fail "nenhuma skill encontrada"

for skill in "${SKILLS[@]}"; do
  file="$ROOT/$skill/SKILL.md"
  IFS=$'\n' read -r l1 l2 l3 l4 < "$file"

  [ "$l1" = "---" ] || fail "$skill: frontmatter não começa na primeira linha"
  [ "$l2" = "name: $skill" ] || fail "$skill: name não corresponde ao diretório"
  [[ "$l3" =~ ^description:[[:space:]] ]] || fail "$skill: description ausente"

  desc="${l3#description:}"
  desc="${desc# }"
  desc="${desc#\"}"
  desc="${desc%\"}"

  [ "${#desc}" -le 1024 ] || fail "$skill: description excede 1024 caracteres"

  [[ "$skill" =~ ^[a-z0-9-]+$ ]] || fail "$skill: nome incompatível com Agent Skills"
  [ "${#skill}" -le 64 ] || fail "$skill: nome excede 64 caracteres"

  [ "$l4" = "---" ] || fail "$skill: frontmatter não termina na quarta linha"
done

# Claude Code user-skill discovery contract.
# Claude Code documents user skills under ~/.claude/skills/<name>/SKILL.md.
CLAUDE_ROOT="$TMP_ROOT/.claude/skills"
mkdir -p "$CLAUDE_ROOT"

for skill in "${SKILLS[@]}"; do
  ln -s "$ROOT/$skill" "$CLAUDE_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$CLAUDE_ROOT/$skill/SKILL.md" ] || fail "Claude discovery: $skill não está acessível"
done

claude_count="$(find "$CLAUDE_ROOT" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
[ "$claude_count" -eq "${#SKILLS[@]}" ] || fail "Claude discovery: esperado ${#SKILLS[@]}, encontrado $claude_count"
pass "Claude Code discovery contract: $claude_count skills"

# VS Code/Copilot personal-skill discovery contract.
# VS Code documents user skills under ~/.copilot/skills/<name>/SKILL.md.
COPILOT_ROOT="$TMP_ROOT/.copilot/skills"
mkdir -p "$COPILOT_ROOT"

for skill in "${SKILLS[@]}"; do
  ln -s "$ROOT/$skill" "$COPILOT_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$COPILOT_ROOT/$skill/SKILL.md" ] || fail "VS Code/Copilot discovery: $skill não está acessível"
done

copilot_count="$(find "$COPILOT_ROOT" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
[ "$copilot_count" -eq "${#SKILLS[@]}" ] || fail "VS Code/Copilot discovery: esperado ${#SKILLS[@]}, encontrado $copilot_count"
pass "VS Code/Copilot discovery contract: $copilot_count skills"

pass "Agent Skills contract válido para ${#SKILLS[@]} skills"
