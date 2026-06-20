# System Patterns

## システム構成
```
dotfiles/
├── CLAUDE.md            # プロジェクト指示（memory-bank/supervisor を使う宣言・workers_dir 宣言）
├── README.md            # 入口（詳細は各 SKILL.md）
├── install.sh           # 冪等・非破壊な symlink 展開
├── claude/settings.json # ~/.claude/settings.json の正本（SessionStart フック同梱）
├── editorconfig         # ~/.editorconfig（Makefile のタブだけ規定）
├── bin/                 # 補助スクリプト（hooks 注入 / sessionstart / new-meeting）
├── skills/              # docs-summary / memory-bank / quality / supervisor
└── workers/             # supervisor 配下ワーカー（別リポジトリ・gitignore 済み。現状 manystore）
```

## 主要な技術判断
- **スキル共有**: `skills/<name>/SKILL.md` を `~/.claude/skills/` と `~/.agents/skills/` の両方へ symlink
  （Codex/Gemini 等が共通で読む Agent Skills 標準）。
- **非破壊リンク**: 既存の組織管理設定を勝手に上書きしない。上書きは `FORCE=1`。共有未対応ツールは検出して通知。
- **フック注入は Python 化**: `bin/install-claude-hooks.py`（ドライラン既定 / `--apply` で .bak 作成・冪等）。
- **秘密情報の構造的排除**: `.gitignore` で credentials / key / token 等を広くパターン除外。
- **ロールは構造で決まる**: supervisor か否かは CLAUDE.md の `workers_dir` 宣言（capability の昇格）。
  スキル本体は配下の場所を持たない（正本は宣言側）。

## 設計パターン / 原則
- **正本の一元化**: 設定もワーカー所在も「宣言側（CLAUDE.md / config）」が正本。スキルにハードコードしない。
- **Memory Bank（Cline 準拠）**: `.work/skills/<skill>/` 規約。`.work/` は gitignore せず commit する（引き継ぎの正本）。
- **agent ブランチ単線運用**: エージェントは `agent` ブランチに単線でコミット。`main` への統合は人間。
  エージェントは競合解決を背負わない。
- **interrupt 受信箱**: 非対話でユーザーが要望を投函 → 起動時に取り込み → archive へ退避。

## コンポーネント関係 / 重要な実装経路
- `install.sh` → symlink 群を張る。`bin/install-claude-hooks.py` → settings.json へ SessionStart フック注入。
- `bin/memory-bank-sessionstart` → プロジェクトに Memory Bank があれば「読め」と案内（コア充足も検証する方向で改修中）。
- supervisor フロー: `workers_dir` 列挙 → 各ワーカーの `.work/skills/memory-bank/`（activeContext/progress）を読む
  → interrupt へ指示配信 → エスカレ取り込み。
