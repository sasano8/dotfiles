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
    データ slot を `flow-memory-bank` へ移行。移行互換（旧名 symlink・hook 旧名検出・settings 旧 glob）は全 worker
    （manystore）移行完了につき **2026-06-22 撤去済み**。install.sh は dangling 旧リンクを prune。
  - **Stage2 完了（2026-06-22）**: 内容再配置をファイル単位 5 コミットで実施。
    - flow: 開発内ループ（開発→自己点検→反復→commit→記録→次）を明文化。上りエスカレを **pull 型 outbox `outbox/`** へ
      （worker は親を知らず自分の outbox に積む。supervisor が回収）。向き/境界ポリシーは role 参照に。
    - unit-quality: **両建て廃止**＝常に flow→unit の自己点検 1 本。R10/注意を再フレーム。
    - role: 新節「役割の権限（非対称: 下り許可・上り禁止）」。エスカレ受信を worker outbox の pull 回収に。
      quality を下り dispatch（横断監査しない）に。配信 dispatch は flow 内ループの起点だが driver しない旨を明記。
    - guard: docstring/deny メッセージを「上り禁止・下り許可」「outbox に積んで pull 回収」へ（判定ロジックは不変）。
    - sessionstart: **role 判定 1 行**を中央注入（supervisor/worker/standalone を構造判定。3 ケース実挙動検証済み）。
  - 残: なし。manystore 移行完了・移行互換撤去済み（他マシン無し）。命名プレフィックス由来の参照更新も追従済み。
- M005: **スキルドキュメントに OKF（Open Knowledge Format）メタデータを義務化**（ユーザー要望 2026-06-22）。
  OKF= Google Cloud の markdown+YAML 知識フォーマット（詳細はメモリ `okf-open-knowledge-format`）。必須 frontmatter は
  `type` のみ／推奨 `title`/`description`/`resource`/`tags`/`timestamp`。本リポ適用の論点（**未決**）:
  - フィールド: `type` に**種別（role/flow/unit/func）**を入れる案（R11 の「種別は frontmatter で宣言」を実体化）。
    `name`/`description` は loader 既定で維持。`timestamp`/`tags` は任意とするか。
  - 置き場所: unit-quality の **新 R12（推奨・構造チェック系）** か R11 拡張か。← ユーザー「一旦中断」で保留。
  - スコープ: まず SKILL.md 4 本だけか、Memory Bank コア 6 ファイル（現状 frontmatter 皆無）の OKF 化まで広げるか。
  - 推奨（再開時）: SKILL.md に `type: role|flow|unit|func` 必須を新 R12 で規定。MB コアの OKF 化は別タスクに分離。
- M006: **unit-quality に「deep think」フェーズを導入**（ユーザー要望 2026-06-22）。作業範囲が品質ガイドラインに
  沿っているかを**俯瞰的に深く考える**フェーズ。flow 内ループを 2 つの deep think ゲートで挟み、最終で問題が
  あれば計画へ戻すループにする:
  ```
  計画整理（deep think・俯瞰）→ （開発 → 自己点検・局所/スピード重視）×N → 最終点検（deep think・俯瞰）
    → 品質に問題あり: 計画整理（deep think）へ戻る ／ 問題なし: commit
  ```
  - **二層の点検の役割分担**:
    - **deep think（俯瞰）** = 作業スコープ全体が品質ガイドラインに沿うかを深く考えるゲート。①着手前の計画整理、
      ②コミット前の最終点検 の 2 か所。最終で NG なら**計画整理へ巻き戻す**（commit へ進まない）。
    - **per-iteration 自己点検（局所）** = 各開発ステップ内の局所チェック。**スピード重視**（deep think しても
      よいが軽く）。既存の flow 内ループの「開発→自己点検」をそのまま担う。
  - **置き場所**: deep think の**考え方アルゴリズム自体は [[unit-quality]] が正本**として定める（品質正本に同居）。
    flow は内ループにこの構造を組み込み「deep think せよ／自己点検せよ」と呼ぶだけ（flow→品質参照の indirection を踏襲）。
  - 論点（**未決**）: (a) deep think アルゴリズムの具体（俯瞰観点の列挙か・自問テンプレか・反証ステップ有無か）。
    (b) standalone/worker で重さが過剰にならないよう発火条件（大物のみ等）を設けるか＝局所点検との軽重の線引き。
    (c) 「最終点検 NG → 計画整理へ戻る」の無限ループ防止（戻り回数の上限 or WIP コミットでの退避）。

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
