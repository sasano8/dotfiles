#!/usr/bin/env bash
# dotfiles のシンボリックリンクを張る（冪等）。
# 別マシンでは: git clone <this repo> ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  # link <target(実体, DOT 相対)> <link(設置先, 絶対)>
  local target="$DOT/$1" linkpath="$2"
  mkdir -p "$(dirname "$linkpath")"
  if [ -L "$linkpath" ]; then
    rm "$linkpath"
  elif [ -e "$linkpath" ]; then
    echo "skip: $linkpath は既存の実体（symlink でない）。手動で確認してください。" >&2
    return
  fi
  ln -s "$target" "$linkpath"
  echo "linked: $linkpath -> $target"
}

# Claude Code ユーザースキル
link "claude/skills/memory-bank" "$HOME/.claude/skills/memory-bank"

echo "done."
