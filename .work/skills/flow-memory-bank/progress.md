# Progress

## 動くもの（What works）
- `install.sh` による冪等・非破壊な symlink 展開（スキル共有、settings.json、editorconfig）。
- スキル群（4 レベル taxonomy・prefix 改名済み）: `func-docs-summary` / `flow-memory-bank` / `unit-quality` /
  `role-supervisor_or_worker`。クロス参照は層エイリアス（`[[flow]]`/`[[role]]`）でリネーム耐性。
  - flow-memory-bank に **`memory clean`（畳み込み/GC）節**＋**開発内ループ**を実装済み。**上りエスカレは pull 型 outbox**。
    開発内ループは **deep think 2 ゲート（着手前/コミット前）で挟む**（算法は unit-quality・配置は flow＝M006）。
  - unit-quality に **「deep think（俯瞰品質ゲートの算法）」節**（俯瞰観点＋反証ステップ）を実装済み。
  - unit-quality に **R12（OKF ドキュメントメタデータ）**。4 スキル SKILL.md に必須 `type`（role/flow/unit/func）付与済み
    （値の正本は CLAUDE.md＝M005）。
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
- M005: **スキルドキュメントに OKF メタデータを義務化＝実装完了（2026-06-22）**。確定:
  - **新 R12（unit-quality）**: SKILL.md は OKF 準拠 frontmatter を持つ。**必須 `type`**（値はプロジェクトの taxonomy が
    定める＝OKF は producer 裁量。汎用スキルは literal を持たず「taxonomy が定める値」とだけ言う）。`name`/`description` は
    loader 必須として維持、`tags`/`timestamp` 任意。R11 の `kind` 例示を `type`（R12）へ統一＝drift 解消。
  - **具体の taxonomy 値（role/flow/unit/func）は CLAUDE.md が正本**（汎用スキルへの固有値ハード参照を回避＝R11 自己遵守。
    最終 deep think で反証ヒット→修正した点）。SKILL.md 4 本に `type:` を付与（role/flow/unit/func）。
  - スコープは SKILL.md 4 本に限定。MB コア 6 ファイルの OKF 化は M007 へ分離（YAGNI）。
  - 残リスク: skill loader が未知キー `type` を拒否しないこと（OKF/Agent Skills は拡張許容が原則＝低リスク。reload 後の
    スキル一覧表示で要確認）。
- M007: **Memory Bank コア 6 ファイルの OKF 化**（M005 から分離）。現状 frontmatter 皆無。`type`（例: `memory-core` や
  ファイル別種別）を付すか、index.md/log.md 概念を入れるか含め**未着手・要設計**。優先度 low（コア 6 は固定役割で flow が
  読む＝loader 非経由のため義務度は SKILL.md より低い）。
- M008: **`role` プレフィックスの再考＝直交2軸の分離**（ユーザー指摘 2026-06-22・要設計・未決）。現 `role-` は
  **軸1=調整/権限の位置**（supervisor↔worker・垂直・`workers_dir` で構造決定）と **軸2=機能/専門領域**（app開発・
  インフラ運用・QA…・水平・主題）を混在させている。1 プロジェクトは「app開発×worker」のように両方を同時に持つ＝直交。
  現 4 階層（role/flow/unit/func）は「抽象度＋依存方向」の単一軸で、軸2（主題）はその階層ではない点が肝。
  - **方向A（エージェント推奨）**: 軸2を**階層でなく直交メタデータ（tags / OKF frontmatter）**で表す（M005 の OKF と
    整合・新 prefix 不要・抽象度軸を綺麗に保つ）。
  - **方向B**: 軸2を新上位 prefix に。`team-` は「集団」で機能でない＝`domain-`/`discipline-` が精確。`func-` と衝突する
    "function" 系は避ける。派生案: supervisor/worker を `org-`/`coord-` へ改名し "role" を軸2へ明け渡す（改名コスト大）。
  - **段階導入案**: まず方向A（tags）。合成可能なスキル実体が要ると判明した時点で衝突しない名で方向Bへ昇格。
  - 未決: (a) A/B どちらを採るか（まず A で十分か）。(b) B なら軸名（domain/discipline/team）と sup/worker の改名要否。
    (c) tags のキー設計（`tags:` 自由値か `domain:` 専用フィールドか）。
  - **俯瞰展開（2026-06-22）**: 開発体系（env: prod/stg/dev、team: app/infra）に倣い、分類を**直交ファセット**として
    体系化するアイデアを `design/taxonomy-faceted.md` に抽出。要点: 軸を 3 種の carrier に振り分ける（**prefix**=抽象度の
    骨格だけ／**metadata(OKF tags)**=主題・属性／**declaration/config**=構造・文脈で決まるもの＝sup/worker は workers_dir・
    env は実行文脈）。抽出ファセット: level / coordination / team(domain) / env / lifecycle / maturity / scope。
    段階導入は「まず tags で機能領域・成熟度（最小コスト）→ 必要なら env を declaration 化 → 合意後に prefix 改名」。
- M009: **エージェント間通信のスケール化＝排他＋ローカル外対応**（ユーザー要望 2026-06-23・要設計・未決）。現状の
  supervisor↔worker 通信は flow-memory-bank の **ローカルファイルの置き場所を決めているだけ**（interrupt/ への投函・
  outbox/ の pull、辞書順取り込み）。要望: (a) **排他処理**で同時書き込み/取り込みでも壊れない、(b) **ローカル外にも
  スケール**できる通信路（複数ホスト/リモート間でも届く）。優先度 **low**（メタ作業＝supervisor 自身の足回り。
  「配下を進める」を優先しメタに偏らない原則に従い寝かせる。輪郭が不十分＝まず明確化）。設計論点/未決:
  - 排他の粒度と方式: 1 件 1 ファイル＋アトミック rename（local は `os.replace`）で足りるか、ロック/リース/
    CAS が要るか。取り込み後の archive/受領印の競合をどう防ぐか。
  - ローカル外の transport: 共有 FS / オブジェクトストレージ / メッセージング のどれを置き場にするか。
    → **manystore とのシナジー**: manystore は local/nats/s3 を共通 IF で抽象する。通信の置き場を manystore backend に
      載せれば「ローカル外スケール」が backend 差し替えで済む可能性（flow の置き場を manystore で抽象する案）。要検討。
  - 配送セマンティクス: at-least-once / 重複排除 / 順序（現状の辞書順ファイル名に代わるもの）。冪等な取り込み。
  - スコープ: flow（記憶/通信実体）と role（権限・向き）のどちらが正本を持つか。最小から（YAGNI）。
- M010: **オープンテスト・プラットフォーム（リモート適合性テストの実行基盤）**（ユーザー要望 2026-06-23・新規・要設計・
  未決）。**ストレージテストのオープン化（manystore 側 = テストの“中身”）とは別タスク**＝こちらは“プラットフォーム”
  （配送・トンネル・エージェント・オーケストレーション）。想定アーキテクチャ（ユーザー提示）:
  - **受験側（テストを受けたい側）**: 接続先＋クレデンシャルを送り、**テストエージェントを起動**する。
  - **トンネル**: WebSocket 等で受験側エージェント ↔ プラットフォーム間にトンネルを掘る。
  - **実行**: プラットフォーム側がトンネル経由で**テストリクエスト**を送り、**受験側エージェント経由でテストを実行**、
    結果を返す。テスト本体（契約スイート）は manystore の conformance suite（別タスク）を載せて配る想定。
  - 優先度 **low**（新規・大きい・輪郭が粗い＝まず明確化。メタ/新規基盤に偏らず配下前進を優先）。設計論点/未決:
    - **クレデンシャルの扱い**（最重要）: 受験側は「クレデンシャルを送る」とあるが、実行は受験側エージェント上。
      → 資格情報をプラットフォームに渡すのか、ローカルに留めてエージェントだけが使うのか（送るのは“接続先メタ”だけ？）。
      セキュリティ境界（クレデンシャル非送出が望ましい）と利便のトレードオフを決める。
    - **トンネル/transport**: WebSocket 前提か、回線断・再接続・認証（誰が誰のエージェントか）をどう担保するか。
    - **テスト配送**: 契約スイート（manystore conformance）をどう受験側へ届け実行させるか（コード配布 vs 既知バージョン参照）。
    - **隣接タスクとの関係**: M009（エージェント間通信のスケール/排他）とトンネル基盤が重なる可能性＝共通化を要検討。
      テスト対象に manystore S3 ゲートウェイ（manystore 側 dispatch 済）も含まれ得る。
    - **正本/置き場**: 新規 worker プロジェクトとして切るか、既存配下に載せるか（supervisor が後で判断）。
- M006: **unit-quality に「deep think」フェーズを導入**（ユーザー要望 2026-06-22）**＝実装完了（2026-06-22）**。
  flow 内ループを 2 つの deep think ゲート（着手前=計画整理／コミット前=最終点検）で挟み、最終 NG なら計画へ戻す:
  ```
  計画整理（deep think・俯瞰）→ （開発 → 自己点検・局所/速）×N → 最終点検（deep think・俯瞰）
    → NG: 計画整理へ戻る（1 往復まで。なお NG は WIP コミット退避）／ OK: commit
  ```
  - **二層の点検**: deep think（俯瞰・コミット単位の 2 ゲート）と per-iteration 自己点検（局所/速）の役割分担。
  - **関心の分離（実装の肝）**: deep think の**算法（俯瞰観点＋反証ステップ）は [[unit-quality]] が正本**（新節
    「deep think（俯瞰品質ゲートの算法）」）。**配置・タイミング・戻し回数・WIP 退避＝フローは [[flow]]** が持つ
    （単体スキルにフローを混ぜない原則を遵守）。flow は内ループに構造を組み込み「deep think せよ」と呼ぶだけ。
  - **確定した 3 論点**（2026-06-22 ユーザー承認）: (a) 算法の形＝**俯瞰観点＋反証ステップ**（固定テンプレにせず
    観点と姿勢だけ規定）。(b) 発火＝**コミット単位・範囲比例**（軽微は着手前ゲートを省き最終に畳む。局所点検は速のまま）。
    (c) ループ防止＝**上限 1 往復→WIP 退避**（なお NG なら緑にできない WIP として commit し activeContext に明記）。

## 現状ステータス
- 2026-06-22: **M005 完了**（OKF メタデータ義務化＝R12 新設・4 スキルに `type` 付与・値正本を CLAUDE.md へ）。MB コア
  OKF 化は M007 へ繰り越し。
- 2026-06-22: **M006 完了**（deep think 2 ゲートを flow 内ループへ／算法を unit-quality に新設）。M001 は作業ツリー
  clean で実質完了、M002 は manystore clean・outbox なし・既投函 dispatch 未取り込み（待ちは想定どおり）。
- 2026-06-22: **M004 Stage2 完了**（内容再配置をファイル単位 5 コミットで実施）。
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
- **deep think（俯瞰品質ゲート）を導入**（M006）。算法（俯瞰観点＋反証）は unit-quality・配置/戻し回数/WIP 退避は
  flow に分離（単体スキルにフロー混ぜない原則）。発火はコミット単位・範囲比例、ループ防止は上限 1 往復→WIP 退避。
- **OKF メタデータを義務化**（M005）。R12 で SKILL.md に必須 `type`。**値の正本は宣言側（CLAUDE.md）**・汎用スキル
  （unit-quality）は literal を持たず「taxonomy が定める値」と言うだけ＝R11 自己遵守（deep think 反証で発見・修正）。
