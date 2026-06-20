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
| `skills/<name>/SKILL.md` | `~/.claude/skills/<name>` ＋ `~/.agents/skills/<name>` | エージェントスキル正本。Claude Code と Codex の両方へ張る |
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code 設定（model / theme / tui）。秘密は含めない |
| `editorconfig` | `~/.editorconfig` | グローバル EditorConfig（ホーム配下のフォールバック） |

現在のスキル: `memory-bank`（Cline 準拠 Memory Bank）, `docs-summary`（`.cache/docs/` を解析して要約生成）。

> 秘密・認証情報は `.gitignore` で構造的に排除している。マシン固有の設定は
> `~/.claude/settings.local.json` 等（`*.local` パターンで非同期）に置く。

### スキルをツール横断で共有する仕組み

`SKILL.md`（YAML frontmatter の `name` + `description`）は **Agent Skills オープン標準（agentskills.io）** で、
多くのエージェントツールが共通で読む。違いは置き場所だけ：

- Claude Code … `~/.claude/skills/<name>/`（独自パス）
- **共有標準** … `~/.agents/skills/<name>/` … **Codex / Gemini CLI** などが読む相互運用パス
  （Gemini は `~/.gemini/skills/` より `~/.agents/skills/` を優先）

正本を `skills/<name>/` に置き、`install.sh` の `link_skill` が両所へ symlink する。スキルを 1 つ追加したら
`link_skill <name>` を 1 行足すだけで全対応ツールに反映される。`.agents/skills` を読む新ツールは設定不要で拾う。

> Cline / Cursor / Continue / Copilot などは `.agents/skills` ではなく独自のルール/プロンプト形式
> （`.clinerules`、`.cursor/rules/*.mdc`、Continue の rules、Copilot instructions）を使う。これらへ広げるには
> SKILL.md を各形式へ変換する必要があり、symlink では共有できない（必要になったら個別に対応）。

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
