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

  line1="$(sed -n '1p' "$file")"
  line2="$(sed -n '2p' "$file")"
  line3="$(sed -n '3p' "$file")"
  line4="$(sed -n '4p' "$file")"

  [ "$line1" = "---" ] || fail "$skill: frontmatter não começa na primeira linha"
  [ "$line2" = "name: $skill" ] || fail "$skill: name não corresponde ao diretório"
  [[ "$line3" =~ ^description:[[:space:]] ]] || fail "$skill: description ausente"
  [ "$line4" = "---" ] || fail "$skill: frontmatter não termina na quarta linha"

  [[ "$skill" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "$skill: nome incompatível com Agent Skills"
  [ "${#skill}" -le 64 ] || fail "$skill: nome excede 64 caracteres"

  desc="${line3#description:}"
  desc="${desc# }"
  desc="${desc#\"}"
  desc="${desc%\"}"
  [ "${#desc}" -le 1024 ] || fail "$skill: description excede 1024 caracteres"

  ruby -rpsych -e '
    data = Psych.safe_load(ARGF.read, permitted_classes: [], aliases: false)
    abort("frontmatter não é YAML válido") unless data.is_a?(Hash)
    abort("campo name ausente") unless data["name"].is_a?(String)
    abort("campo description ausente") unless data["description"].is_a?(String)
  ' < <(sed -n '2,3p' "$file") || fail "$skill: YAML inválido"
done

CLAUDE_ROOT="$TMP_ROOT/.claude/skills"
mkdir -p "$CLAUDE_ROOT"

for skill in "${SKILLS[@]}"; do
  cp -R "$ROOT/$skill" "$CLAUDE_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$CLAUDE_ROOT/$skill/SKILL.md" ] || fail "Claude Code discovery: $skill não está acessível"
done

claude_count=0
for skill in "${SKILLS[@]}"; do
  [ -f "$CLAUDE_ROOT/$skill/SKILL.md" ] || fail "Claude Code discovery: $skill não está acessível"
  claude_count=$((claude_count + 1))
done

[ "$claude_count" -eq "${#SKILLS[@]}" ] || fail "Claude Code discovery: esperado ${#SKILLS[@]}, encontrado $claude_count"
pass "Claude Code discovery contract: $claude_count skills"

COPILOT_ROOT="$TMP_ROOT/.copilot/skills"
mkdir -p "$COPILOT_ROOT"

for skill in "${SKILLS[@]}"; do
  cp -R "$ROOT/$skill" "$COPILOT_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$COPILOT_ROOT/$skill/SKILL.md" ] || fail "VS Code/Copilot discovery: $skill não está acessível"
done

copilot_count=0
for skill in "${SKILLS[@]}"; do
  [ -f "$COPILOT_ROOT/$skill/SKILL.md" ] || fail "VS Code/Copilot discovery: $skill não está acessível"
  copilot_count=$((copilot_count + 1))
done

[ "$copilot_count" -eq "${#SKILLS[@]}" ] || fail "VS Code/Copilot discovery: esperado ${#SKILLS[@]}, encontrado $copilot_count"
pass "VS Code/Copilot discovery contract: $copilot_count skills"

OPENCODE_ROOT="$TMP_ROOT/.config/opencode/skills"
mkdir -p "$OPENCODE_ROOT"

for skill in "${SKILLS[@]}"; do
  cp -R "$ROOT/$skill" "$OPENCODE_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$OPENCODE_ROOT/$skill/SKILL.md" ] || fail "OpenCode discovery: $skill não está acessível"
done

opencode_count=0
for skill in "${SKILLS[@]}"; do
  [ -f "$OPENCODE_ROOT/$skill/SKILL.md" ] || fail "OpenCode discovery: $skill não está acessível"
  opencode_count=$((opencode_count + 1))
done

[ "$opencode_count" -eq "${#SKILLS[@]}" ] || fail "OpenCode discovery: esperado ${#SKILLS[@]}, encontrado $opencode_count"
pass "OpenCode discovery contract: $opencode_count skills"

CODEX_ROOT="$TMP_ROOT/.codex/skills"
mkdir -p "$CODEX_ROOT"

for skill in "${SKILLS[@]}"; do
  cp -R "$ROOT/$skill" "$CODEX_ROOT/$skill"
done

for skill in "${SKILLS[@]}"; do
  [ -f "$CODEX_ROOT/$skill/SKILL.md" ] || fail "Codex discovery: $skill não está acessível"
done

codex_count=0
for skill in "${SKILLS[@]}"; do
  [ -f "$CODEX_ROOT/$skill/SKILL.md" ] || fail "Codex discovery: $skill não está acessível"
  codex_count=$((codex_count + 1))
done

[ "$codex_count" -eq "${#SKILLS[@]}" ] || fail "Codex discovery: esperado ${#SKILLS[@]}, encontrado $codex_count"
pass "Codex discovery contract: $codex_count skills"

pass "Agent Skills discovery contract válido para Claude Code, VS Code/Copilot, OpenCode e Codex — ${#SKILLS[@]} skills"
