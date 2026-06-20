#!/usr/bin/env bash
# dotfiles のシンボリックリンクを張る（冪等・非破壊）。
# 別マシンでは: git clone <this repo> ~/projects/dotfiles && ~/projects/dotfiles/install.sh
# 置き場所は任意（スクリプト自身の位置から $DOT を解決する）。
#
# 非破壊の原則: 自分が張ったリンク以外は上書きしない。
#   - 既に正しい先を指す symlink … 何もしない（ok）
#   - 別の場所を指す symlink（組織管理など） … スキップして警告（FORCE=1 で上書き可）
#   - symlink でない実体（実ファイル/ディレクトリ） … 常にスキップ（FORCE でも消さない）
#   - 何も無い … 新規作成
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE="${FORCE:-0}"

link() {
  # link <target(実体, DOT 相対)> <link(設置先, 絶対)>
  local target="$DOT/$1" linkpath="$2"
  if [ -L "$linkpath" ]; then
    local cur; cur="$(readlink "$linkpath")"
    if [ "$cur" = "$target" ]; then
      echo "ok: $linkpath（既に正しい）"
      return
    fi
    if [ "$FORCE" = "1" ]; then
      rm "$linkpath"
    else
      echo "skip: $linkpath は別リンクを指す（-> $cur）。組織管理かもしれないので保持。上書きは FORCE=1。" >&2
      return
    fi
  elif [ -e "$linkpath" ]; then
    echo "skip: $linkpath は既存の実体（symlink でない）。保持（FORCE でも消さない）。手動確認を。" >&2
    return
  fi
  mkdir -p "$(dirname "$linkpath")"
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
link_skill quality
# Claude Code 設定（秘密は含めない。マシン固有は settings.local.json へ＝非同期）
link "claude/settings.json" "$HOME/.claude/settings.json"
# グローバル EditorConfig
link "editorconfig" "$HOME/.editorconfig"

# スキル共有に未対応のツールを検出して通知（独自のルール/プロンプト形式＝.agents/skills を読まない）。
# symlink では共有できず、SKILL.md を各形式へ変換する必要がある。
unsupported=""
note_unsupported() {
  # note_unsupported <表示名> <存在判定パス...>
  local name="$1"; shift
  local p
  for p in "$@"; do
    [ -e "$p" ] && { unsupported="$unsupported $name"; return; }
  done
}
note_unsupported cline    "$HOME/.cline"
note_unsupported cursor   "$HOME/.cursor" "$HOME/.cursor-server"
note_unsupported continue "$HOME/.continue"
note_unsupported copilot  "$HOME/.copilot"

if [ -n "$unsupported" ]; then
  echo "note: スキル共有に未対応（独自形式・要変換）:${unsupported}" >&2
  echo "      これらは .agents/skills を読まないため symlink 共有不可。SKILL.md を各形式へ変換が必要。" >&2
fi

echo "done."
