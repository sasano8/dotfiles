#!/usr/bin/env bash
# dotfiles のシンボリックリンクを張る（冪等）。
# 別マシンでは: git clone <this repo> ~/projects/dotfiles && ~/projects/dotfiles/install.sh
# 置き場所は任意（スクリプト自身の位置から $DOT を解決する）。
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

link_skill() {
  # link_skill <name>: SKILL.md 正本（skills/<name>）を各エージェントツールへ張る。
  # SKILL.md（frontmatter name+description）は Agent Skills 標準（agentskills.io）で共通。
  local name="$1"
  link "skills/$name" "$HOME/.claude/skills/$name"   # Claude Code（独自パス）
  link "skills/$name" "$HOME/.agents/skills/$name"    # 共有標準 .agents/skills: Codex / Gemini CLI 等が読む
}

# 共有スキル（Claude Code + Codex）
link_skill memory-bank
link_skill docs-summary
# Claude Code 設定（秘密は含めない。マシン固有は settings.local.json へ＝非同期）
link "claude/settings.json" "$HOME/.claude/settings.json"
# グローバル EditorConfig
link "editorconfig" "$HOME/.editorconfig"

echo "done."
