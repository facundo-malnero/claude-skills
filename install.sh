#!/bin/bash
set -euo pipefail

REPO="facundo-malnero/claude-skills"
BRANCH="main"
API_BASE="https://api.github.com/repos/$REPO/contents"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
TARGET="$HOME/.claude/skills"
MARKER=".lightit-managed"

# ─── helpers ────────────────────────────────────────────────────────────────

has_cmd() { command -v "$1" &>/dev/null; }

skill_status() {
  local skill="$1" dir="$TARGET/$skill"
  if [ -d "$dir" ] && [ ! -f "$dir/$MARKER" ]; then
    echo "personal"
  elif [ -f "$dir/$MARKER" ]; then
    echo "managed"
  else
    echo "new"
  fi
}

install_skill() {
  local skill="$1" target_dir="$TARGET/$skill"
  local files
  files=$(curl -fsSL "$API_BASE/skills/$skill?ref=$BRANCH" \
    | grep '"path"' | sed 's/.*"path": "\(.*\)".*/\1/')

  for file_path in $files; do
    local local_path="$target_dir/${file_path#skills/$skill/}"
    mkdir -p "$(dirname "$local_path")"
    curl -fsSL "$RAW_BASE/$file_path" -o "$local_path"
  done

  touch "$target_dir/$MARKER"
}

# ─── fetch available skills ──────────────────────────────────────────────────

mkdir -p "$TARGET"
all_skills=$(curl -fsSL "$RAW_BASE/manifest.txt" | grep -v '^#' | grep -v '^$')

# Separate personal overrides from installable candidates
installable=()
personal=()
for skill in $all_skills; do
  status=$(skill_status "$skill")
  if [ "$status" = "personal" ]; then
    personal+=("$skill")
  else
    installable+=("$skill")
  fi
done

if [ ${#installable[@]} -eq 0 ]; then
  echo "Nothing to install — all skills are either up to date or have personal overrides."
  [ ${#personal[@]} -gt 0 ] && printf "  ⚠  personal override (skipped): %s\n" "${personal[@]}"
  exit 0
fi

# ─── skill selection TUI ─────────────────────────────────────────────────────

# Build display labels: show [update] for already-managed skills
labels=()
for skill in "${installable[@]}"; do
  status=$(skill_status "$skill")
  if [ "$status" = "managed" ]; then
    labels+=("$skill  [update]")
  else
    labels+=("$skill")
  fi
done

selected_skills=()

if has_cmd gum; then
  # gum multi-select — pre-select all by default
  result=$(printf '%s\n' "${labels[@]}" | \
    gum choose --no-limit \
      --header "Light-it Claude Skills — seleccioná qué instalar:" \
      --selected="$(printf '%s,' "${labels[@]}")" \
    ) || { echo "Cancelled."; exit 0; }
  while IFS= read -r line; do
    [ -n "$line" ] && selected_skills+=("${line%  \[update\]}")
  done <<< "$result"

elif has_cmd fzf; then
  result=$(printf '%s\n' "${labels[@]}" | \
    fzf --multi --prompt="Light-it Claude Skills > " \
        --header="[tab] seleccionar  [enter] confirmar  [esc] cancelar" \
        --bind=tab:toggle+down \
        --bind=ctrl-a:select-all \
    ) || { echo "Cancelled."; exit 0; }
  while IFS= read -r line; do
    [ -n "$line" ] && selected_skills+=("${line%  \[update\]}")
  done <<< "$result"

else
  # No TUI available — install all with confirmation
  echo "Skills a instalar:"
  printf '  • %s\n' "${labels[@]}"
  echo ""
  read -rp "¿Instalar todas? [Y/n] " confirm
  case "$confirm" in
    [nN]*) echo "Cancelled."; exit 0 ;;
    *) selected_skills=("${installable[@]}") ;;
  esac
fi

if [ ${#selected_skills[@]} -eq 0 ]; then
  echo "Nada seleccionado."
  exit 0
fi

# ─── install ─────────────────────────────────────────────────────────────────

echo ""
for skill in "${selected_skills[@]}"; do
  printf "Installing %s... " "$skill"
  install_skill "$skill"
  echo "✓"
done

# Warn about personal overrides
if [ ${#personal[@]} -gt 0 ]; then
  echo ""
  printf "  ⚠  skipped (personal override): %s\n" "${personal[@]}"
  echo "  To use the managed version, remove ~/.claude/skills/<skill> and re-run."
fi

# ─── update alias ────────────────────────────────────────────────────────────

ALIAS_LINE="alias claude-skills-update='curl -fsSL $RAW_BASE/install.sh | bash'"
SHELL_RC="$HOME/.zshrc"
if ! grep -q "claude-skills-update" "$SHELL_RC" 2>/dev/null; then
  { echo ""; echo "# Light-it Claude skills updater"; echo "$ALIAS_LINE"; } >> "$SHELL_RC"
  echo ""
  echo "✓  alias 'claude-skills-update' added — run 'source ~/.zshrc' to activate"
fi

echo ""
echo "Done."
