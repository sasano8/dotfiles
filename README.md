# dotfiles

個人の Claude Code / エージェント設定とスキルを git 管理し、symlink で各マシンへ展開する。
**詳しい知識は各 `skills/<name>/SKILL.md` にある。この README は入口。**

## セットアップ

```bash
git clone <repo> ~/projects/dotfiles
~/projects/dotfiles/install.sh   # 冪等・非破壊（既存設定は壊さない。上書きは FORCE=1）
```

symlink される主なもの:

- `skills/<name>/` → `~/.claude/skills/` と `~/.agents/skills/`
  （`SKILL.md` は Claude Code / Codex / Gemini 共通形式）
- `claude/settings.json` → `~/.claude/settings.json`
- `editorconfig` → `~/.editorconfig`（Makefile のタブだけ規定。他はフォーマッタに委ねる）

## Memory Bank — `skills/memory-bank`

セッションを跨いでプロジェクトを継続するための永続ドキュメント（Cline 準拠）。
使い方・構成は [skills/memory-bank/SKILL.md](skills/memory-bank/SKILL.md)。

セッション開始時に「Memory Bank があれば読む」よう自動案内する **SessionStart フック**:

- 本体: `bin/memory-bank-sessionstart`（無いプロジェクトでは no-op）
- グローバル設定は `claude/settings.json`（= `~/.claude/settings.json`）に同梱済み。
- settings.json が実体のマシンへ入れるとき:

  ```bash
  bin/install-claude-hooks.py            # ドライラン（対象ファイルと差分を表示）
  bin/install-claude-hooks.py --apply    # 書き込み（.bak 作成・冪等）
  ```

## ドキュメント解析 — `skills/docs-summary`

`.cache/docs/` に置いたドキュメント（議事録など）を解析し、トピック別・決定事項・未完了 ToDo・
時系列に**再整理した要約**を `.cache/docs/summary/SUMMARY.md` に生成する。
使い方は [skills/docs-summary/SKILL.md](skills/docs-summary/SKILL.md)。

議事録の新規作成:

```bash
bin/new-meeting [タイトル]   # .cache/docs/meetings/yyyymmddhhmm.md（15分丸め・既存ならエラー）
```

> `.cache/` はローカル限定（git 追跡しない）。議事録・要約は手元のみ。
