#!/usr/bin/env bash
#
# scaling-skills — instalador das skills Higher Mind + GSD
#
# Instala as skills (hm-*) nos agentes/IDEs detectados e o GSD Core da fonte oficial:
#   - Claude Code  -> ~/.claude/skills/            (symlink) + GSD via npx --claude
#   - VS Code      -> ~/.claude/skills/            (symlink — VS Code lê esse diretório) + GSD via npx --claude
#   - Kiro         -> ~/.kiro/skills/              (CÓPIA — Kiro IDE não segue symlinks; GSD não suporta Kiro)
#   - Opencode     -> ~/.config/opencode/skills/   (symlink) + GSD via npx --opencode
#
# O GSD Core é instalado do repositório oficial via npx (@opengsd/gsd-core),
# nunca a partir da pasta gsd/ deste repositório (que é só referência).
#
# Uso:
#   ./setup [--all] [--claude] [--kiro] [--vscode] [--opencode]
#   ./setup --copy          # força cópia em todos os destinos (em vez de symlink)
#   ./setup --uninstall     # remove as skills instaladas
#   ./setup --list          # lista as skills disponíveis neste repositório
#   ./setup --help          # mostra esta ajuda
#
# Sem argumentos, instala em todos os destinos detectados (comportamento --all).

set -euo pipefail

# ---------------------------------------------------------------- helpers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# descobre skills dinamicamente: toda pasta com SKILL.md na raiz do repo,
# exceto gsd/ (que é só referência — o GSD Core vem do repositório oficial via npx)
SKILLS=()
for _d in "$SCRIPT_DIR"/*/; do
  _name="$(basename "$_d")"
  [ "$_name" = "gsd" ] && continue
  [ -f "$_d/SKILL.md" ] && SKILLS+=("$_name")
done

BOLD=$'\033[1m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'
[ -t 1 ] || { BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; RESET=""; }

info()  { printf '%s\n' "${GREEN}✔${RESET} $*"; }
warn()  { printf '%s\n' "${YELLOW}!${RESET} $*"; }
error() { printf '%s\n' "${RED}✘${RESET} $*"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- install

install_skill() {
  local name="$1" target_dir="$2" mode="$3"
  local src="$SCRIPT_DIR/$name"
  local dst="$target_dir/$name"

  mkdir -p "$target_dir"

  # remove instalação anterior (link quebrado, link ou cópia)
  if [ -L "$dst" ] || [ -e "$dst" ]; then
    rm -rf "$dst"
  fi

  if [ "$mode" = "copy" ]; then
    cp -R "$src" "$dst"
    printf '  %-16s %s %s\n' "$name" "→" "$dst  ${DIM}(cópia)${RESET}"
  else
    ln -s "$src" "$dst"
    printf '  %-16s %s %s  %s\n' "$name" "→" "$dst" "${DIM}(symlink)${RESET}"
  fi
}

install_to() {
  local label="$1" target_dir="$2" mode="$3"
  printf '\n%s[%s]%s  %s\n' "$BOLD" "$label" "$RESET" "$target_dir"
  for name in "${SKILLS[@]}"; do
    install_skill "$name" "$target_dir" "$mode"
  done
  info "$((${#SKILLS[@]})) skills instaladas em $target_dir"
}

uninstall_from() {
  local label="$1" target_dir="$2"
  printf '\n%s[%s]%s  %s\n' "$BOLD" "$label" "$RESET" "$target_dir"
  local removed=0
  for name in "${SKILLS[@]}"; do
    local dst="$target_dir/$name"
    if [ -L "$dst" ] || [ -e "$dst" ]; then
      rm -rf "$dst"
      printf '  %-16s %s\n' "$name" "removida"
      removed=$((removed + 1))
    fi
  done
  [ "$removed" -gt 0 ] && info "$removed skills removidas de $target_dir" || warn "nada para remover em $target_dir"
}

# ---------------------------------------------------------------- GSD Core (oficial)

# Instala o GSD Core do repositório oficial via npx. O GSD Core não suporta
# Kiro (sem flag --kiro); VS Code é coberto pelo --claude (lê ~/.claude/skills/).
install_gsd() {
  local runtime="$1" label="$2"
  if ! has_cmd npx; then
    warn "npx não encontrado — GSD Core não instalado para $label"
    warn "Instale Node.js 18+ ou veja a instalação manual: https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md"
    return 1
  fi
  printf '\n%s[%s]%s  GSD Core (oficial via npx)\n' "$BOLD" "$label" "$RESET"
  npx -y @opengsd/gsd-core@latest --"$runtime" --global
}

uninstall_gsd() {
  local runtime="$1" label="$2"
  if ! has_cmd npx; then
    warn "npx não encontrado — GSD Core não desinstalado de $label"
    return 1
  fi
  printf '\n%s[%s]%s  GSD Core (oficial via npx)\n' "$BOLD" "$label" "$RESET"
  npx -y @opengsd/gsd-core@latest --"$runtime" --global --uninstall
}

# ---------------------------------------------------------------- detecção

detect() {
  local claude=0 kiro=0 vscode=0 opencode=0
  has_cmd claude   && claude=1
  has_cmd kiro     && kiro=1
  has_cmd code     && vscode=1
  has_cmd opencode && opencode=1

  # Kiro IDE (sem CLI) também pode existir — checa diretório global
  [ -d "$HOME/.kiro" ] && kiro=1

  printf '%s\n' "${BOLD}Detecção de ferramentas:${RESET}"
  printf '  %-10s %s\n' "Claude Code" "$([ "$claude" -eq 1 ] && echo "${GREEN}detectado${RESET}" || echo "${DIM}não detectado${RESET}")"
  printf '  %-10s %s\n' "Kiro"        "$([ "$kiro" -eq 1 ] && echo "${GREEN}detectado${RESET}" || echo "${DIM}não detectado${RESET}")"
  printf '  %-10s %s\n' "VS Code"     "$([ "$vscode" -eq 1 ] && echo "${GREEN}detectado${RESET}" || echo "${DIM}não detectado${RESET}")"
  printf '  %-10s %s\n' "Opencode"    "$([ "$opencode" -eq 1 ] && echo "${GREEN}detectado${RESET}" || echo "${DIM}não detectado${RESET}")"

  if [ "$claude" -eq 1 ]; then install_to "Claude Code" "$HOME/.claude/skills" "$MODE"; fi
  if [ "$vscode" -eq 1 ]; then install_to "VS Code"     "$HOME/.claude/skills" "$MODE"; fi
  if [ "$kiro" -eq 1 ]; then install_to "Kiro"         "$HOME/.kiro/skills"    "copy"; fi
  if [ "$opencode" -eq 1 ]; then install_to "Opencode" "$HOME/.config/opencode/skills" "$MODE"; fi

  # GSD Core — do repositório oficial via npx (não da pasta gsd/ local)
  if [ "$claude" -eq 1 ] || [ "$vscode" -eq 1 ]; then
    install_gsd "claude" "Claude Code / VS Code"
  fi
  if [ "$opencode" -eq 1 ]; then
    install_gsd "opencode" "Opencode"
  fi
  if [ "$kiro" -eq 1 ]; then
    warn "GSD Core não suporta Kiro (sem flag --kiro) — GSD não instalado no Kiro"
  fi

  if [ "$claude" -eq 0 ] && [ "$kiro" -eq 0 ] && [ "$vscode" -eq 0 ] && [ "$opencode" -eq 0 ]; then
    warn "nenhuma ferramenta detectada. Use flags explícitas: --claude --kiro --vscode --opencode"
    return 1
  fi
}

uninstall_all() {
  if has_cmd claude || [ -d "$HOME/.claude" ]; then
    uninstall_from "Claude Code" "$HOME/.claude/skills"
    uninstall_gsd "claude" "Claude Code"
  fi
  if has_cmd kiro || [ -d "$HOME/.kiro" ]; then
    uninstall_from "Kiro" "$HOME/.kiro/skills"
  fi
  if has_cmd opencode || [ -d "$HOME/.config/opencode" ]; then
    uninstall_from "Opencode" "$HOME/.config/opencode/skills"
    uninstall_gsd "opencode" "Opencode"
  fi
}

list_skills() {
  printf '%s\n' "${BOLD}Skills deste repositório (${#SKILLS[@]}):${RESET}"
  for name in "${SKILLS[@]}"; do
    local desc
    desc="$(awk -F': *' '/^description:/{sub(/^description: *"?/, ""); sub(/"?$/, ""); print; exit}' "$SCRIPT_DIR/$name/SKILL.md")"
    printf '  %-20s %s\n' "$name" "${DIM}${desc:0:90}...${RESET}"
  done
  printf '%s\n' "${BOLD}GSD:${RESET}"
  printf '  %-20s %s\n' "gsd" "${DIM}GSD Core — instalado do repositório oficial via npx (não da pasta gsd/ local)${RESET}"
}

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------- main

MODE="link"
ACTION="install"
TARGETS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --all)          ACTION="install" ;;
    --claude)       ACTION="install"; TARGETS+=("claude") ;;
    --kiro)         ACTION="install"; TARGETS+=("kiro") ;;
    --vscode)       ACTION="install"; TARGETS+=("vscode") ;;
    --opencode)     ACTION="install"; TARGETS+=("opencode") ;;
    --copy)         MODE="copy" ;;
    --uninstall)    ACTION="uninstall" ;;
    --list)         ACTION="list" ;;
    --help|-h)      ACTION="help" ;;
    *)              error "argumento desconhecido: $1"; usage; exit 1 ;;
  esac
  shift
done

case "$ACTION" in
  help)      usage; exit 0 ;;
  list)      list_skills; exit 0 ;;
  uninstall) uninstall_all; exit 0 ;;
esac

printf '%s\n' "${BOLD}scaling-skills — Higher Mind${RESET}"
printf '%s\n' "${DIM}origem: $SCRIPT_DIR${RESET}"

if [ "${#TARGETS[@]}" -eq 0 ]; then
  detect
else
  for t in "${TARGETS[@]}"; do
    case "$t" in
      claude)   install_to "Claude Code" "$HOME/.claude/skills" "$MODE"; install_gsd "claude" "Claude Code" ;;
      vscode)   install_to "VS Code"     "$HOME/.claude/skills" "$MODE"; install_gsd "claude" "VS Code" ;;
      kiro)     install_to "Kiro"        "$HOME/.kiro/skills"    "copy"; warn "GSD Core não suporta Kiro (sem flag --kiro) — GSD não instalado no Kiro" ;;
      opencode) install_to "Opencode"    "$HOME/.config/opencode/skills" "$MODE"; install_gsd "opencode" "Opencode" ;;
    esac
  done
fi

printf '\n%s\n' "${GREEN}Pronto!${RESET} Reinicie o agente/IDE para carregar as skills (Claude Code detecta mudanças automaticamente)."
printf '%s\n' "${DIM}Para remover: ./setup --uninstall${RESET}"