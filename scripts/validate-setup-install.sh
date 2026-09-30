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

EXPECTED="${#SKILLS[@]}"
[ "$EXPECTED" -gt 0 ] || fail "nenhuma skill encontrada"

export HOME="$TMP_ROOT/home"
mkdir -p "$HOME/.claude/skills"

# Simula uma instalação quebrada antiga: diretório vazio e symlink.
mkdir -p "$HOME/.claude/skills/hm-engineer"
ln -s "$ROOT/hm-qa" "$HOME/.claude/skills/hm-qa"

# Evita instalar GSD no CI. O comportamento do setup referente às skills
# continua sendo exercitado normalmente.
FAKE_BIN="$TMP_ROOT/bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/npx" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$FAKE_BIN/npx"
export PATH="$FAKE_BIN:$PATH"

cd "$ROOT"
./setup --claude </dev/null

count=0
while IFS= read -r skill; do
  dst="$HOME/.claude/skills/$skill"
  [ -d "$dst" ] || fail "$skill: diretório não instalado"
  [ ! -L "$dst" ] || fail "$skill: instalação ainda é symlink"
  [ -f "$dst/SKILL.md" ] || fail "$skill: SKILL.md não encontrado"

  source_sha="$(sha256sum "$ROOT/$skill/SKILL.md" | cut -d' ' -f1)"
  target_sha="$(sha256sum "$dst/SKILL.md" | cut -d' ' -f1)"
  [ "$source_sha" = "$target_sha" ] || fail "$skill: SKILL.md copiado não corresponde ao repositório"

  count=$((count + 1))
done < <(printf '%s\n' "${SKILLS[@]}")

[ "$count" -eq "$EXPECTED" ] || fail "esperado $EXPECTED skills, encontrado $count"

# Os dois casos quebrados precisam ter sido reparados.
[ ! -L "$HOME/.claude/skills/hm-qa" ] || fail "hm-qa ainda é symlink"
[ -f "$HOME/.claude/skills/hm-engineer/SKILL.md" ] || fail "hm-engineer vazio não foi reparado"

pass "setup instalou $count skills como arquivos reais e reparou destinos antigos"
