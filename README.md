# dotfiles

個人環境の設定を git 管理し、各マシンで symlink を張って同期する。
置き場所は任意（このリポジトリは `~/projects/dotfiles` にある）。

## セットアップ（新しいマシン）

```bash
git clone <this repo> ~/projects/dotfiles
~/projects/dotfiles/install.sh
```

`install.sh` は冪等かつ**非破壊**。自分が張ったリンク以外は上書きしない：

- 既に正しい先を指す symlink … 何もしない（ok）
- **別の場所を指す symlink（組織管理など）… 保持してスキップ**（`FORCE=1 ./install.sh` で上書き可）
- symlink でない実体（実ファイル/ディレクトリ）… 常に保持（FORCE でも消さない）
- 何も無い … 新規作成

組織が `~/.agents/skills` 等を管理している環境で clone+install しても、既存設定を勝手に壊さない。

## 中身

| パス | symlink 先 | 用途 |
|------|-----------|------|
| `skills/<name>/SKILL.md` | `~/.claude/skills/<name>` ＋ `~/.agents/skills/<name>` | エージェントスキル正本。Claude Code と Codex の両方へ張る |
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code 設定（model / theme / tui ＋ SessionStart フック）。秘密は含めない |
| `bin/memory-bank-sessionstart` | （直接参照） | SessionStart フック本体。後述 |
| `editorconfig` | `~/.editorconfig` | グローバル EditorConfig（ホーム配下のフォールバック） |

現在のスキル: `memory-bank`（Cline 準拠 Memory Bank）, `docs-summary`（`.cache/docs/` を解析して要約生成）。

### SessionStart フック（Memory Bank 自動案内・グローバル）

`claude/settings.json`（= `~/.claude/settings.json`）の `hooks.SessionStart` で、全プロジェクトのセッション
開始時に `bin/memory-bank-sessionstart` を実行する。プロジェクトに Memory Bank
（`.work/skills/memory-bank/` または `memory-bank/`）があれば「タスク前に memory-bank スキルで読む」よう
**文脈注入**し、無ければ **no-op**（何もしない・ログも残さない）。

- コマンドは `$HOME/projects/dotfiles/bin/...` と `$HOME` 相対（dotfiles を別の場所へ置くマシンでは要調整）。
- 検出時のみ `~/.claude/memory-bank-hook.log` に記録。切り分け時は `MB_HOOK_DEBUG=1` で no-op も記録。
- 確認: memory bank のあるプロジェクトで新規セッション → 上記ログに行が増える。

dotfiles の symlink を使わず settings.json が実体のマシンなどには、`bin/install-claude-hooks.py` で
フックをマージ注入できる（標準ライブラリのみ）。既定はドライランで**対象ファイルと差分**を表示し、
`--apply` で書き込む（冪等。既存キーは保持）:

```bash
bin/install-claude-hooks.py                       # ドライラン（差分のみ）
bin/install-claude-hooks.py --apply               # 書き込み（.bak を作成）
bin/install-claude-hooks.py --settings <path> --apply
```

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
