# Tech Context

## 使用技術 / スタック
- Bash スクリプト（`install.sh`, `bin/memory-bank-sessionstart`, `bin/new-meeting`）。
- Python スクリプト（`bin/install-claude-hooks.py` — settings.json へのフック注入、jq 非依存）。
- Markdown（スキル定義 `SKILL.md` / Memory Bank コアファイル）。
- JSON（`claude/settings.json`、Memory Bank の `config.json`）。
- 対象エージェント: Claude Code / Codex / Gemini（Agent Skills 標準の SKILL.md を共有）。

## 開発セットアップ
```bash
git clone <repo> ~/projects/dotfiles
~/projects/dotfiles/install.sh          # 冪等・非破壊（上書きは FORCE=1）
bin/install-claude-hooks.py             # フック注入のドライラン
bin/install-claude-hooks.py --apply     # 書き込み（.bak 作成・冪等）
```

## 検証コマンド（lint + test）
- このリポジトリは設定・スキル（Markdown / shell / Python スクリプト）が中心で、
  専用のテストスイートは未整備。
- shell: `bash -n <script>`（構文チェック）。`install.sh` は冪等なので再実行で確認可。
- Python: `bin/install-claude-hooks.py` はドライラン（引数なし）で安全に挙動確認できる。
- 変更後は最低限 `git diff` で意図しない混入（生成物・秘密情報）が無いか確認する。
- quality スキル（Python 3.14+ ベースライン等）あり: 本格的な品質基準は `skills/quality/SKILL.md` 参照。

## 技術的制約 / 依存
- `jq` には依存しない方針（sessionstart は最小限の JSON エスケープを自前で行う）。
- `.cache/` はローカル限定（git 追跡しない）。議事録・要約は手元のみ。
- `workers/` は別リポジトリ（clone/submodule/symlink）で gitignore 済み。親には取り込まない。
- `.work/` は **gitignore しない**（Memory Bank の正本として commit する）。
- ブランチ方針は `agent-branch`（既定ブランチ名 `agent`）。push は明示時のみ。
