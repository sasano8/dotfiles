# dotfiles

個人環境の設定を git 管理し、各マシンで symlink を張って同期する。
置き場所は任意（このリポジトリは `~/projects/dotfiles` にある）。

## セットアップ（新しいマシン）

```bash
git clone <this repo> ~/projects/dotfiles
~/projects/dotfiles/install.sh
```

`install.sh` は冪等。既存の symlink は張り直し、symlink でない実体があればスキップして警告する。

## 中身

| パス | symlink 先 | 用途 |
|------|-----------|------|
| `claude/skills/memory-bank/` | `~/.claude/skills/memory-bank` | Claude Code ユーザースキル（Cline 準拠 Memory Bank） |
| `claude/skills/docs-summary/` | `~/.claude/skills/docs-summary` | `.cache/docs/` を解析し再整理した要約を `.cache/docs/summary/` に生成 |
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code 設定（model / theme / tui）。秘密は含めない |
| `editorconfig` | `~/.editorconfig` | グローバル EditorConfig（ホーム配下のフォールバック） |

> 秘密・認証情報は `.gitignore` で構造的に排除している。マシン固有の設定は
> `~/.claude/settings.local.json` 等（`*.local` パターンで非同期）に置く。

## docs（個人ナレッジベース・ローカル限定）

`.cache/docs/` がベース。**`.cache/` は `.gitignore` 済み＝コミット・同期しない**（手元のローカル資料）。

| パス / コマンド | 用途 |
|------|------|
| `bin/new-meeting [タイトル]` | 議事録 `.cache/docs/meetings/yyyymmddhhmm.md` を生成（時刻は 15 分単位に丸め・既存ならエラー） |
| `.cache/docs/meetings/` | 議事録 |
| `.cache/docs/summary/` | `docs-summary` スキルが生成する再整理済みの要約（`SUMMARY.md`） |

## 設定を編集するとき

実体は `~/projects/dotfiles/...` にある（`~/.claude/...` 等は symlink）。
普段どおり編集 → `cd ~/projects/dotfiles && git commit` で履歴を残し、他マシンは `git pull` で反映される
（symlink なので張り直し不要）。
