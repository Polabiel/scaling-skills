#!/usr/bin/env bash
#
# scaling-skills — instalador das skills Higher Mind
#
# Destinos:
#   Claude Code     -> ~/.claude/skills/
#   VS Code/Copilot -> ~/.copilot/skills/
#   Kiro            -> ~/.kiro/skills/ (cópia)
#   Opencode        -> ~/.config/opencode/skills/
#   Codex           -> ${CODEX_HOME:-~/.codex}/skills/
#
# O GSD Core não é uma skill deste repositório.
# O setup chama o instalador oficial @opengsd/gsd-core via npx
# com o runtime correto para cada ambiente detectado.
#
# Uso:
#   ./setup [--all] [--claude] [--vscode] [--kiro] [--opencode] [--codex]
#   ./setup --doctor
#   ./setup --copy
#   ./setup --uninstall
#   ./setup --list
#   ./setup --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="link"
ACTION="install"
TARGETS=""
OS_NAME="unknown"

skill_files() {
  find "$SCRIPT_DIR" -mindepth 2 -maxdepth 2 -type f -name "SKILL.md" | sort
}

skill_count() {
  skill_files | wc -l | tr -d " "
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  local kernel
  kernel="$(uname -s 2>/dev/null || printf "unknown")"
  case "$kernel" in
    Darwin*) OS_NAME="macOS" ;;
    Linux*)
      if [ -r /proc/version ] && grep -qi microsoft /proc/version; then
        OS_NAME="WSL"
      else
        OS_NAME="Linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*) OS_NAME="Windows" ;;
    *) OS_NAME="$kernel" ;;
  esac
}

is_claude_detected() {
  has_cmd claude || [ -d "$HOME/.claude" ]
}

is_vscode_detected() {
  has_cmd code ||
  has_cmd code.cmd ||
  [ -d "$HOME/.config/Code" ] ||
  [ -d "$HOME/Library/Application Support/Code" ] ||
  { [ -n "${APPDATA:-}" ] && [ -d "$APPDATA/Code" ]; }
}

is_kiro_detected() {
  has_cmd kiro || [ -d "$HOME/.kiro" ]
}

is_opencode_detected() {
  has_cmd opencode || [ -d "$HOME/.config/opencode" ]
}

is_codex_detected() {
  has_cmd codex || [ -d "${CODEX_HOME:-$HOME/.codex}" ]
}

validate_skill() {
  local file="$1"
  local dir name declared description

  dir="$(dirname "$file")"
  name="$(basename "$dir")"

  [ "$(sed -n "1p" "$file")" = "---" ] || return 1

  declared="$(sed -n "2p" "$file" | sed "s/^name: *//")"
  [ "$declared" = "$name" ] || return 1

  description="$(sed -n "3p" "$file")"
  [[ "$description" == description:* ]] || return 1

  [ "$(sed -n "4p" "$file")" = "---" ] || return 1
}

validate_skills() {
  local failed=0 file name

  while IFS= read -r file; do
    name="$(basename "$(dirname "$file")")"
    if validate_skill "$file"; then
      printf "  %-24s OK\n" "$name"
    else
      printf "  %-24s INVALID\n" "$name"
      failed=1
    fi
  done < <(skill_files)

  if [ "$failed" -ne 0 ]; then
    printf "%s\n" "ERROR: existe skill com frontmatter inválido."
    return 1
  fi

  printf "%s skills válidas.\n" "$(skill_count)"
}

install_skill() {
  local file="$1" target_dir="$2" mode="$3"
  local src_dir name dst

  src_dir="$(dirname "$file")"
  name="$(basename "$src_dir")"
  dst="$target_dir/$name"

  mkdir -p "$target_dir"

  if [ -L "$dst" ] || [ -e "$dst" ]; then
    rm -rf "$dst"
  fi

  if [ "$mode" = "copy" ]; then
    cp -R "$src_dir" "$dst"
  else
    ln -s "$src_dir" "$dst"
  fi
}

count_existing_skills() {
  local target_dir="$1"
  local file name dst count=0

  while IFS= read -r file; do
    name="$(basename "$(dirname "$file")")"
    dst="$target_dir/$name"
    if [ -L "$dst" ] || [ -e "$dst" ]; then
      count=$((count + 1))
    fi
  done < <(skill_files)

  printf "%s" "$count"
}

confirm_update_existing() {
  local label="$1" target_dir="$2"
  local existing answer

  existing="$(count_existing_skills "$target_dir")"

  if [ "$existing" -eq 0 ]; then
    return 0
  fi

  printf "\n%s\n" "Já existem $existing skill(s) instaladas em $label."
  printf "%s\n" "As skills existentes NÃO serão sobrescritas sem confirmação."
  printf "%s" "Atualizar/substituir essas skills agora? [y/N] "

  if ! read -r answer </dev/tty; then
    answer=""
  fi

  case "$answer" in
    y|Y)
      printf "%s\n" "Atualização autorizada."
      return 0
      ;;
    *)
      printf "%s\n" "Atualização recusada. Skills existentes serão preservadas."
      return 1
      ;;
  esac
}

verify_install() {
  local target_dir="$1" mode="$2"
  local file src_dir name dst

  while IFS= read -r file; do
    src_dir="$(dirname "$file")"
    name="$(basename "$src_dir")"
    dst="$target_dir/$name"

    if [ "$mode" = "copy" ]; then
      [ -f "$dst/SKILL.md" ] || return 1
    else
      [ -L "$dst" ] || return 1
      [ "$(readlink "$dst")" = "$src_dir" ] || return 1
    fi
  done < <(skill_files)

  return 0
}

install_to() {
  local label="$1" target_dir="$2" mode="$3"
  local file src_dir name dst update_existing installed=0 skipped=0

  printf "\n[%s] %s\n" "$label" "$target_dir"

  update_existing=0
  if confirm_update_existing "$label" "$target_dir"; then
    update_existing=1
  fi

  while IFS= read -r file; do
    src_dir="$(dirname "$file")"
    name="$(basename "$src_dir")"
    dst="$target_dir/$name"

    if [ -L "$dst" ] || [ -e "$dst" ]; then
      if [ "$update_existing" -eq 1 ]; then
        install_skill "$file" "$target_dir" "$mode"
        installed=$((installed + 1))
        printf "  atualizado: %s\n" "$name"
      else
        skipped=$((skipped + 1))
        printf "  preservado: %s\n" "$name"
      fi
    else
      install_skill "$file" "$target_dir" "$mode"
      installed=$((installed + 1))
      printf "  instalado:  %s\n" "$name"
    fi
  done < <(skill_files)

  if [ "$skipped" -gt 0 ]; then
    printf "%s\n" "$skipped skill(s) existente(s) preservada(s)."
  fi

  if [ "$installed" -gt 0 ] && [ "$skipped" -eq 0 ]; then
    printf "%s skills instaladas/atualizadas e verificadas.\n" "$installed"
  elif [ "$installed" -gt 0 ]; then
    printf "%s skills novas/atualizadas.\n" "$installed"
  else
    printf "%s\n" "Nenhuma skill existente foi alterada."
  fi

  if ! verify_install "$target_dir" "$mode" 2>/dev/null; then
    if [ "$skipped" -eq 0 ]; then
      printf "ERRO: instalação incompleta em %s\n" "$target_dir"
      return 1
    fi
  fi
}

uninstall_from() {
  local target_dir="$1"
  local file name dst

  while IFS= read -r file; do
    name="$(basename "$(dirname "$file")")"
    dst="$target_dir/$name"
    if [ -L "$dst" ] || [ -e "$dst" ]; then
      rm -rf "$dst"
    fi
  done < <(skill_files)
}

node_major_version() {
  node -p 'process.versions.node.split(".")[0]' 2>/dev/null || printf "0"
}

npm_major_version() {
  npm --version 2>/dev/null | cut -d. -f1 || printf "0"
}

install_gsd() {
  local runtime="$1" label="$2"
  local major npm_major

  if ! has_cmd npx; then
    printf "GSD Core pendente para %s: npx não encontrado (OS: %s).\n" "$label" "$OS_NAME"
    return 1
  fi

  major="$(node_major_version)"
  npm_major="$(npm_major_version)"
  if [ "$major" -lt 22 ] || [ "$npm_major" -lt 10 ]; then
    printf "GSD Core pendente para %s: requer Node.js >= 22 e npm >= 10; encontrados Node.js %s e npm %s.\n" "$label" "$major" "$npm_major"
    return 1
  fi

  printf "\nGSD Core oficial -> %s (--%s --global)\n" "$label" "$runtime"
  npx --yes @opengsd/gsd-core@latest "--$runtime" --global
}

uninstall_gsd() {
  local runtime="$1" label="$2"
  local major npm_major

  has_cmd npx || return 1
  major="$(node_major_version)"
  npm_major="$(npm_major_version)"
  [ "$major" -ge 22 ] && [ "$npm_major" -ge 10 ] || return 1

  printf "\nGSD Core uninstall -> %s\n" "$label"
  npx --yes @opengsd/gsd-core@latest "--$runtime" --global --uninstall
}

run_install_target() {
  local target="$1"

  case "$target" in
    claude)
      install_to "Claude Code" "$HOME/.claude/skills" "$MODE"
      install_gsd "claude" "Claude Code" || true
      ;;
    vscode)
      install_to "VS Code/Copilot" "$HOME/.copilot/skills" "$MODE"
      install_gsd "copilot" "VS Code/Copilot" || true
      ;;
    kiro)
      install_to "Kiro" "$HOME/.kiro/skills" "copy"
      printf "%s\n" "GSD Core não possui runtime Kiro suportado."
      ;;
    opencode)
      install_to "Opencode" "$HOME/.config/opencode/skills" "$MODE"
      install_gsd "opencode" "Opencode" || true
      ;;
    codex)
      install_to "Codex" "${CODEX_HOME:-$HOME/.codex}/skills" "$MODE"
      install_gsd "codex" "Codex" || true
      ;;
    *)
      printf "runtime desconhecido: %s\n" "$target"
      return 1
      ;;
  esac
}

detect_and_install() {
  local found=0

  if is_claude_detected; then
    printf "%s\n" "Claude Code detectado"
    run_install_target "claude"
    found=1
  fi

  if is_vscode_detected; then
    printf "%s\n" "VS Code/Copilot detectado"
    run_install_target "vscode"
    found=1
  fi

  if is_kiro_detected; then
    printf "%s\n" "Kiro detectado"
    run_install_target "kiro"
    found=1
  fi

  if is_opencode_detected; then
    printf "%s\n" "Opencode detectado"
    run_install_target "opencode"
    found=1
  fi

  if is_codex_detected; then
    printf "%s\n" "Codex detectado"
    run_install_target "codex"
    found=1
  fi

  if [ "$found" -eq 0 ]; then
    printf "%s\n" "Nenhum runtime detectado. Use --claude, --vscode, --kiro ou --opencode."
    return 1
  fi
}

doctor() {
  detect_os

  printf "%s\n" "scaling-skills — doctor"
  printf "OS: %s\n\n" "$OS_NAME"

  printf "%s\n" "Skills:"
  validate_skills

  printf "\n%s\n" "Runtimes:"
  is_claude_detected && printf "%s\n" "Claude Code: detectado" || printf "%s\n" "Claude Code: não detectado"
  is_vscode_detected && printf "%s\n" "VS Code/Copilot: detectado" || printf "%s\n" "VS Code/Copilot: não detectado"
  is_kiro_detected && printf "%s\n" "Kiro: detectado" || printf "%s\n" "Kiro: não detectado"
  is_opencode_detected && printf "%s\n" "Opencode: detectado" || printf "%s\n" "Opencode: não detectado"
  is_codex_detected && printf "%s\n" "Codex: detectado" || printf "%s\n" "Codex: não detectado"

  printf "\n%s\n" "GSD Core:"
  if has_cmd npx; then
    printf "npx: disponível\n"
    printf "Node.js: %s\n" "$(node --version 2>/dev/null || printf "ausente")"
    printf "npm: %s\n" "$(npm --version 2>/dev/null || printf "ausente")"
    local major npm_major
    major="$(node_major_version)"
    npm_major="$(npm_major_version)"
    if [ "$major" -ge 22 ] && [ "$npm_major" -ge 10 ]; then
      printf "%s\n" "Node.js >= 22 e npm >= 10 atendem ao requisito do GSD Core"
    else
      printf "Requisito do GSD Core NÃO atendido: Node.js %s / npm %s (necessário >=22 / >=10)\n" "$major" "$npm_major"
    fi
  else
    printf "%s\n" "npx: não encontrado"
  fi

  printf "\n%s\n" "Destinos nativos:"
  printf "%s\n" "~/.claude/skills/          -> Claude Code"
  printf "%s\n" "~/.copilot/skills/         -> VS Code/Copilot"
  printf "%s\n" "~/.kiro/skills/            -> Kiro"
  printf "%s\n" "~/.config/opencode/skills/ -> Opencode"
  printf "%s\n" "${CODEX_HOME:-$HOME/.codex}/skills/ -> Codex"
}

usage() {
  sed -n "2,27p" "$0" | sed "s/^# *//"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)       ACTION="install" ;;
    --claude)    ACTION="install"; TARGETS="$TARGETS claude" ;;
    --vscode)    ACTION="install"; TARGETS="$TARGETS vscode" ;;
    --kiro)      ACTION="install"; TARGETS="$TARGETS kiro" ;;
    --opencode)  ACTION="install"; TARGETS="$TARGETS opencode" ;;
    --codex)     ACTION="install"; TARGETS="$TARGETS codex" ;;
    --copy)      MODE="copy" ;;
    --doctor)    ACTION="doctor" ;;
    --uninstall) ACTION="uninstall" ;;
    --list)
      skill_files
      exit 0
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf "argumento desconhecido: %s\n" "$1"
      usage
      exit 1
      ;;
  esac
  shift
done

case "$ACTION" in
  doctor)
    doctor
    exit 0
    ;;
  uninstall)
    detect_os
    is_claude_detected && { uninstall_from "$HOME/.claude/skills"; uninstall_gsd "claude" "Claude Code" || true; }
    is_vscode_detected && { uninstall_from "$HOME/.copilot/skills"; uninstall_gsd "copilot" "VS Code/Copilot" || true; }
    is_kiro_detected && uninstall_from "$HOME/.kiro/skills"
    is_opencode_detected && { uninstall_from "$HOME/.config/opencode/skills"; uninstall_gsd "opencode" "Opencode" || true; }
    exit 0
    ;;
esac

detect_os
printf "%s\n" "scaling-skills — Higher Mind"
printf "OS: %s\n" "$OS_NAME"
validate_skills

if [ -z "$TARGETS" ]; then
  detect_and_install
else
  for target in $TARGETS; do
    run_install_target "$target"
  done
fi

printf "\n%s\n" "Pronto! Reinicie o agente/IDE."
printf "%s\n" "Validação sem instalar: ./setup --doctor"
