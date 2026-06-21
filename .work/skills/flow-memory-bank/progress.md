# Progress

## 動くもの（What works）
- `install.sh` による冪等・非破壊な symlink 展開（スキル共有、settings.json、editorconfig）。
- スキル群（4 レベル taxonomy・prefix 改名済み）: `func-docs-summary` / `flow-memory-bank` / `unit-quality` /
  `role-supervisor_or_worker`。クロス参照は層エイリアス（`[[flow]]`/`[[role]]`）でリネーム耐性。
  - flow-memory-bank に **`memory clean`（畳み込み/GC）節**＋**開発内ループ**を実装済み。**上りエスカレは pull 型 outbox**。
  - role は **権限が非対称（下り許可・上り禁止）**。quality は **flow→unit の自己点検 1 本**（両建てなし）。
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
- M004: スキルを **role / flow / unit / func の 4 レベル**に再編（**Stage1・Stage2 完了**。詳細は systemPatterns）。
  - **Stage1 完了**: 4 スキルを prefix 改名（`role-supervisor_or_worker` / `flow-memory-bank` / `unit-quality` /
    `func-docs-summary`）。クロス参照を層エイリアスへ抽象化（`[[flow]]`/`[[role]]`＝singleton、葉はフル名）。
    データ slot を `flow-memory-bank` へ移し旧名は互換 symlink（全 worker 移行後に削除）。hook 両名検出・settings 両 glob・
    install.sh に dangling prune。
  - **Stage2 完了（2026-06-22）**: 内容再配置をファイル単位 5 コミットで実施。
    - flow: 開発内ループ（開発→自己点検→反復→commit→記録→次）を明文化。上りエスカレを **pull 型 outbox `outbox/`** へ
      （worker は親を知らず自分の outbox に積む。supervisor が回収）。向き/境界ポリシーは role 参照に。
    - unit-quality: **両建て廃止**＝常に flow→unit の自己点検 1 本。R10/注意を再フレーム。
    - role: 新節「役割の権限（非対称: 下り許可・上り禁止）」。エスカレ受信を worker outbox の pull 回収に。
      quality を下り dispatch（横断監査しない）に。配信 dispatch は flow 内ループの起点だが driver しない旨を明記。
    - guard: docstring/deny メッセージを「上り禁止・下り許可」「outbox に積んで pull 回収」へ（判定ロジックは不変）。
    - sessionstart: **role 判定 1 行**を中央注入（supervisor/worker/standalone を構造判定。3 ケース実挙動検証済み）。
  - 残: **要 各マシンで `install.sh` 再実行**（dotfiles では Stage1 で活性化済み・他マシンは未）。旧名互換 symlink は
    全 worker 移行後に削除。命名プレフィックス導入で CLAUDE.md 参照名の更新が要る箇所があれば追従。

## 現状ステータス
- 2026-06-22: **M004 Stage2 完了**（内容再配置をファイル単位 5 コミットで実施）。作業ツリーは Memory Bank 更新分のみ。
- 2026-06-21: Memory Bank 初期化完了。

## 既知の問題
- このリポジトリには専用テストスイートが無く、検証は構文チェック・ドライラン・目視 diff が中心。

## 意思決定の変遷
- コミットのブランチ方針を config 駆動化 → `agent` 専用ブランチでの単線運用に確定（main 統合は人間）。
- supervisor 宣言を CLAUDE.md（`workers_dir`）へ移し、スキルから literal を排除。
- Memory Bank の「無い／不完全」時の挙動を、通知のみ→**ブロッキング（承諾後に作り切る）**へ強化（WIP）。
- `memory clean` は当初 description/起動時チェックに参照だけ入れて節が無い「壊れた前方参照」状態だった →
  **本体の節を書いて解消**（要望はまず記録してから実装＝ worker 側の record-request-before-work の親側適用）。
- 役割の権限を **非対称（下り許可・上り禁止）** に確定（当初の「worker 不可侵＝互いに触れない」は言い過ぎ）。
  上りは pull 型 outbox で worker が親を知らずに済ませ、guard は上りだけを止める。
- quality を **両建て廃止＝flow→unit の自己点検 1 本**に確定（supervisor は横断監査せず下り dispatch のみ）。
  これで role→flow→unit の依存が一貫した。
