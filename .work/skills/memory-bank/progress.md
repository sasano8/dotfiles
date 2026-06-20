# Progress

## 動くもの（What works）
- `install.sh` による冪等・非破壊な symlink 展開（スキル共有、settings.json、editorconfig）。
- スキル群: `docs-summary` / `memory-bank` / `quality` / `supervisor`。
- SessionStart フック（`bin/memory-bank-sessionstart` + `bin/install-claude-hooks.py` での注入）。
- supervisor 宣言（`workers_dir: workers`、配下 `manystore` を symlink で配置）。
- 議事録ツール `bin/new-meeting` と docs-summary（`.cache/docs/`）。

## 残作業（What's left）
- M001: 未コミット WIP（SKILL.md ブロッキング化 / sessionstart のコア充足チェック）を確定コミット。
- M002: supervisor として `workers/manystore` の状態確認と必要なら指示配信。
- M003: 検証コマンドの整備（shell/Python の最低限のチェック手順の明文化 or スクリプト化）。

## 現状ステータス
- 2026-06-21: Memory Bank 初期化完了。WIP 2 件のコミットがこのサイクルの主作業。

## 既知の問題
- このリポジトリには専用テストスイートが無く、検証は構文チェック・ドライラン・目視 diff が中心。

## 意思決定の変遷
- コミットのブランチ方針を config 駆動化 → `agent` 専用ブランチでの単線運用に確定（main 統合は人間）。
- supervisor 宣言を CLAUDE.md（`workers_dir`）へ移し、スキルから literal を排除。
- Memory Bank の「無い／不完全」時の挙動を、通知のみ→**ブロッキング（承諾後に作り切る）**へ強化（WIP）。
