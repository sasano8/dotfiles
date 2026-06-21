# Progress

## 動くもの（What works）
- `install.sh` による冪等・非破壊な symlink 展開（スキル共有、settings.json、editorconfig）。
- スキル群: `docs-summary` / `memory-bank` / `quality` / `supervisor`。
  - memory-bank に **`memory clean`（畳み込み/GC）節**を実装済み（肥大時の昇格・畳み込み・GC・dedup の保守ワークフロー）。
- SessionStart フック（`bin/memory-bank-sessionstart` + `bin/install-claude-hooks.py` での注入）。
  - **funnel すり抜けの自動バックストップ**を内蔵: A=未コミット WIP の表面化（`git status` dirty を通知）／
    B=宙吊り前方参照 lint（`bin/lint-doc-refs`、skills/ 持ち repo のみ）。記憶非依存で取りこぼしを毎起動検知。
  - C=supervisor 起動時の worker roll-up（`workers_dir` 配下の各 worker の WIP/MB 充足を一覧）。SessionStart は
    プロセス単位なので worker 作業は worker-rooted 別セッションで起動する（1 repo = 1 セッション）。
- supervisor 宣言（`workers_dir: workers`、配下 `manystore` を symlink で配置）。
- 議事録ツール `bin/new-meeting` と docs-summary（`.cache/docs/`）。

## 残作業（What's left）
- M001: 未コミット WIP（SKILL.md ブロッキング化 / sessionstart のコア充足チェック）を確定コミット。
- M002: supervisor として `workers/manystore` の状態確認と必要なら指示配信。
- M003: 検証コマンドの整備（shell/Python の最低限のチェック手順の明文化 or スクリプト化）。
  - 一部着手: `bin/lint-doc-refs`（宙吊り前方参照 lint）を追加。今後ここに他チェックも集約していく。
- M004: スキルを **role / flow / unit の 3 レベル**に再編（合意済み・大きめの refactor。詳細は systemPatterns）。
  - 改名: `supervisor`→`role-supervisor_or_worker`（両役割・行動指針・境界を統治、1 flow を参照）／
    `memory-bank`→`flow-memory-bank`（interrupt 機構を規定、複数 unit を参照）／`quality`→`unit-quality`。
  - 移動: memory-bank の「上りエスカレ（向き・境界ポリシー）」を role 層へ。interrupt 機構は flow に残す。
  - quality は両建て（自己点検＝flow 参照 unit／配下 drift 横断＝role 側）。
  - 依存は上→下のみ。下位から上位/個別実装をハード参照しない（[[skill-no-hard-refs-to-project-impl]]）。
  - 命名プレフィックス導入は影響範囲あり（install.sh は自動検出済みなので追従、CLAUDE.md 参照名の更新が要る）。
  - **worker は既定動作。per-worker の CLAUDE.md 契約は作らない**（中央＝role 既定＋グローバル hook＋guard で賄う）。
    supervisor SKILL の「worker 宣言」節は削除済み。明示で強めたいならフックに role 判定 1 行（1 箇所で全 worker）。
  - **上りエスカレは pull 型**（worker は親を知らなくてよい）: worker は自分の **エスカレ保留 outbox**（flow=memory-bank の
    所定場所）に積むだけ。supervisor が `workers_dir` を走査して回収（既存の起動時 roll-up を拡張）。親パスで起動した
    worker は構造から親を検出できる（補助経路）。flow に「タスク/エスカレの積み方」として明記する。

## 現状ステータス
- 2026-06-21: Memory Bank 初期化完了。WIP 2 件のコミットがこのサイクルの主作業。

## 既知の問題
- このリポジトリには専用テストスイートが無く、検証は構文チェック・ドライラン・目視 diff が中心。

## 意思決定の変遷
- コミットのブランチ方針を config 駆動化 → `agent` 専用ブランチでの単線運用に確定（main 統合は人間）。
- supervisor 宣言を CLAUDE.md（`workers_dir`）へ移し、スキルから literal を排除。
- Memory Bank の「無い／不完全」時の挙動を、通知のみ→**ブロッキング（承諾後に作り切る）**へ強化（WIP）。
- `memory clean` は当初 description/起動時チェックに参照だけ入れて節が無い「壊れた前方参照」状態だった →
  **本体の節を書いて解消**（要望はまず記録してから実装＝ worker 側の record-request-before-work の親側適用）。
