# Active Context

## 現在のフォーカス（2026-06-22・最新）
- **M005「OKF メタデータ義務化」実装完了**。unit-quality に R12（OKF 準拠 frontmatter・必須 `type`）を新設、4 スキルの
  SKILL.md に `type`（role/flow/unit/func）を付与。**具体の taxonomy 値は CLAUDE.md が正本**（汎用スキルへの固有値
  ハード参照を回避＝R11 自己遵守。これは着手前 deep think で計画し、最終 deep think の反証でハード参照ミスを捕捉→修正した）。
  R11 の `kind` 例示を `type`（R12）へ統一し drift 解消。MB コア 6 ファイルの OKF 化は M007 へ分離（YAGNI）。
  残リスク: skill loader が未知キー `type` を拒否しないこと（低リスク。reload 後のスキル一覧で要確認）。
- **M006「deep think（俯瞰品質ゲート）」実装完了**（前サイクル）。flow 内ループを 2 ゲートで挟み、算法は [[unit-quality]]・
  配置/戻し回数/WIP 退避は [[flow]] に分離。今サイクルの M005 はこの deep think を実地で回した（着手前計画＋最終反証）。
- supervisor roll-up: manystore は clean・outbox なし・既投函 dispatch 未取り込み（待ちは想定どおり）。
- **2026-06-23 interrupt 取り込み → 振り分け**（ユーザー対話で 3 件投入）:
  - タスク1+2「S3 ゲートウェイ＋ backend=s3 パススルー」= manystore の機能 → **下り dispatch 済**
    （`workers/manystore` の `interrupt/20260623-s3-gateway-and-passthrough.md`・priority normal・要設計先行）。
  - タスク3「エージェント間通信のスケール化（排他＋ローカル外）」= flow/role の通信基盤＝自分のメタ作業 →
    **M009 として backlog 化**（progress.md・priority low・要設計）。manystore（local/nats/s3 抽象）とのシナジー要検討。
- **2026-06-23 interrupt 取り込み（2 巡目）→ 振り分け**（ユーザーが「ストレージテストのオープン化」と「オープンテスト
  *プラットフォーム*」を明確に別タスクと指定）:
  - タスクA「ストレージ適合性テスト（共通 IF の契約スイート／再利用可能形）」= テストの中身 → **manystore へ下り dispatch 済**
    （`interrupt/20260623-storage-conformance-test-suite.md`・normal・設計先行）。
  - タスクB「オープンテスト・プラットフォーム（受験側がクレデンシャル送付→テストエージェント起動→WebSocket トンネル
    →プラットフォームからテストリクエスト→受験側エージェントで実行）」= 配送/トンネル基盤 → **M010 として backlog 化**
    （low・要設計）。M009（agent 通信）とトンネル基盤が重なる可能性／対象に manystore S3 GW も含み得る。
- 次サイクル候補: M007（MB コア OKF 化・low）、M003（検証コマンド整備）、M009（agent 通信・low/要設計）、
  M010（オープンテスト基盤・low/要設計・新規）。

## 旧フォーカス（2026-06-22・M004 系）
- **worker 越境の機械強制（guard）＋スキル taxonomy の合意**。manystore（worker）セッションでスキル更新を命じた
  結果、symlink 越しに親（dotfiles）の正本が書き換わり親に WIP が残った事象を起点に、(1) `bin/worker-boundary-guard`
  （PreToolUse・worker からの親正本書き込みを deny、4 ケース検証済み）を実装し settings.json に配線、(2) supervisor
  SKILL を**プロジェクト非依存**に直す（`bin/...`/`dotfiles` 直書きを排除＝[[skill-no-hard-refs-to-project-impl]]）。
  さらにスキルを **role/flow/unit/func の 4 レベル**に再編する設計に合意。guard は確定済み（`605b8da`/`ffc2fff`）。
- **M004 Stage1 完了（このサイクル）**: 4 スキルを prefix 改名（role-supervisor_or_worker / flow-memory-bank /
  unit-quality / func-docs-summary）、クロス参照を層エイリアス（`[[flow]]`/`[[role]]`）へ抽象化＝リネーム耐性。
  データ slot は flow-memory-bank へ移行＋旧名互換 symlink、hook 両名検出、settings 両 glob、install.sh に dangling prune。
- **Stage1 活性化済み**: `install.sh` 実行で旧リンク 8 本 prune・新名 4 本リンク（`~/.claude/skills` & `~/.agents/skills`）。
  新スキル名（role-supervisor_or_worker 等）が有効。
- **M004 Stage2 完了（このサイクル・2026-06-22）**: 内容再配置をファイル単位 5 コミットで実施。
  - flow: 開発内ループ明文化＋上りエスカレを pull 型 outbox（`outbox/`）へ。向き/境界ポリシーは role 参照に。
  - unit-quality: 両建て廃止＝flow→unit の自己点検 1 本（R10/注意を再フレーム）。
  - role: 非対称権限（下り許可・上り禁止）節を新設／エスカレ受信を worker outbox の pull 回収へ／quality を下り dispatch に。
  - guard: docstring/deny 文言を「上り禁止・下り許可」「outbox pull」へ（判定ロジック不変）。
  - sessionstart: role 判定 1 行を中央注入（supervisor/worker/standalone を構造判定。3 ケース検証済み）。

## 旧フォーカス（完了）
- **`memory clean` の実装を完成（2026-06-21、worker=manystore 経由のユーザー依頼）。** 前セッションで
  `memory clean` の配線（description キーワード＋起動時チェック L23 の前方参照「下記『メモリークリーン』」）
  だけ入れて**本体の節を書かずに中断・未コミット**だった。この壊れた前方参照を解消すべく、SKILL.md に
  **「メモリークリーン（memory clean ＝ 畳み込み / GC）」節**を追記（トリガ／肥大の兆候／操作=昇格・畳み込み・
  GC・dedup／非破壊原則／1 コミットで終える）。やりかけの description/L23 もそのまま活かして 1 コミットに。

## 直近の変更
- 2026-06-22: **M008 俯瞰展開＝直交ファセット体系アイデアを抽出**。開発体系（env/team/role）に倣い `design/taxonomy-faceted.md`
  を新規作成。軸を 3 carrier（prefix=抽象度骨格／metadata=主題 tags／declaration=構造文脈）へ振り分ける体系と、抽出
  ファセット（level/coordination/team/env/lifecycle/maturity/scope）・段階導入・命名衝突整理・未決の問いを記録。M008 から参照。
- 2026-06-22: **interrupt 取り込み → M008 backlog 化**。対話要望「`role` プレフィックスが直交2軸（調整位置＝
  sup/worker ／ 機能領域＝app開発/インフラ）を混在」を funnel 経由で記録、私の分析（方向A=tags/OKF 推奨・方向B=
  `domain-`/`discipline-` 新 prefix・段階導入）を折り込んで progress M008 へ。`archive/2026-06-22-role-prefix-two-axes.md` に退避。
- 2026-06-22: **M005 OKF メタデータ義務化**。unit-quality に R12 新設（OKF 準拠 frontmatter・必須 `type`）、R11 の `kind`
  を `type` へ統一。4 スキルに `type` 付与、具体 taxonomy 値の正本を CLAUDE.md へ。deep think を実地運用（着手前計画→
  最終反証で「汎用スキルに固有値直書き」のハード参照ミスを捕捉し CLAUDE.md へ逃がす修正）。lint-doc-refs 緑・frontmatter YAML 妥当。
- 2026-06-22: **M006 deep think 実装**。flow SKILL「開発内ループ」を 2 ゲート構造へ改修（着手前/コミット前の俯瞰
  ゲート＋per-iteration 自己点検の二層／範囲比例の発火／上限 1 往復→WIP 退避）。unit-quality に「deep think（俯瞰
  品質ゲートの算法）」節を新設（俯瞰観点＋反証ステップ。配置・タイミングは flow の領分と明記＝関心の分離を維持）。
  自己点検は deep think（俯瞰＋反証）で実施＝関心の分離違反なし・R11 ハード参照混入なし・lint-doc-refs 緑。
- 2026-06-22: **品質参照の indirection 化（`4b0d3ed` でコミット済み）**。flow SKILL.md 本体から `[[unit-quality]]` の直書きを
  全除去し、品質 unit の指定を `reference/quality-policy.md` へ一元化。スキル同梱デフォルト
  `skills/flow-memory-bank/reference/quality-policy.md`（既定 [[unit-quality]]）→ インスタンス
  `.work/.../reference/quality-policy.md`（組織上書き）の解決順（commit config と同思想）。付け替えは参照 1 か所。
  インスタンス側の旧参照名（`[[quality]]`/`[[memory-bank]]`/`[[supervisor]]`）も現行 taxonomy へ修正。
- 2026-06-22: **interrupt 取り込み → M006 をバックログへ**。対話要望「unit-quality の deep think フェーズ」を
  funnel 経由で記録し progress.md M006 へトリアージ、`interrupt/archive/2026-06-22-deep-think-phase.md` に退避。
  設計合意: `計画整理(deep think・俯瞰) → (開発→自己点検・局所/速)×N → 最終点検(deep think) → 問題あれば計画整理へ戻る → commit`。
  deep think=俯瞰ゲート（着手前/コミット前の 2 か所、NG なら巻き戻し）、per-iteration 自己点検=局所・速。算法は unit-quality に定義。
- 2026-06-22: **manystore の slot 移行＋移行互換の全撤去**。supervisor 下りで manystore の
  `.work/skills/memory-bank/` → `flow-memory-bank/` を `git mv`（履歴保持）し UI config の featured パスも更新、
  manystore の agent ブランチへコミット。全 worker 移行完了につき dotfiles 側の移行互換（`.work/skills/memory-bank`
  symlink・settings 旧 glob・hook 旧名検出）を撤去。dispatch ファイルも「移行は supervisor が完了」に更新。
- 2026-06-22: **R11 にハード参照禁止チェックを追加**（汎用スキルへの固有実装名/パス/literal 混入を grep 検出）。
  Stage2 で role SKILL に再発させた違反（guard 名指し）を契機に quality 監査の穴を塞いだ。
- 2026-06-22: **supervisor 配信（下り dispatch）を manystore へ実施**。outbox 回収＝上申なし／状態 clean を確認。
  manystore の interrupt に info+low-pri instruction を投函: ①過去エスカレ「quality がループから発揮されない」は
  Stage2 で解決済みと共有、②規約追従（旧 slot `memory-bank/`→`flow-memory-bank/` 移行・上りエスカレ pull 型化・
  層エイリアス統一）を**急がず**依頼。manystore は UI 開発（M019/M020）進行中で前進優先＝待ち（次回起動で取り込む）。
- 2026-06-21: **セッション境界を「1 repo = 1 セッション」に確定＋supervisor 起動時 worker roll-up を追加**
  （ユーザー指摘: SessionStart はプロセス単位で、supervisor 起動→プロセス内で worker に切替えると worker には
  再発火せず効かない）。SessionStart フックは絶対パスのグローバル登録なので worker-rooted セッションには効く
  （この経路が正）。プロセス内コンテキストスイッチは原理的に非対応＝worker 作業は worker を cwd にした別セッション
  で起動する運用に確定。代替として **C: supervisor 起動時に `workers_dir` 配下を走査し各 worker の WIP/MB 充足を
  roll-up 表示**（フックに追加・実測: dotfiles 起動で `manystore: 未コミット N 件 / MB:ok`）。supervisor スキルに
  「セッション境界」節を明記。
- 2026-06-21: **funnel すり抜けの自動バックストップを 2 つ追加**（「もっと抜けないように」のユーザー要望）。
  funnel は記憶依存で忘れれば素通りする（今回の `memory clean` 取りこぼしが実例）→ SessionStart フック
  （`bin/memory-bank-sessionstart`）に **A: 未コミット WIP の表面化**（`git status` dirty を毎起動で通知）と
  **B: 宙吊り前方参照 lint**（新規 `bin/lint-doc-refs`＝`下記「…」`が指す節の未実装を検出、skills/ 持ち repo のみ）
  を配線。いずれも非ブロッキング通知。フック JSON は改行エスケープ対応・両 repo で実挙動検証済み。SKILL.md の
  funnel 節に「自動バックストップ」注記も追加。
- 2026-06-21: `memory clean` 節を SKILL.md に実装し、半端だった前方参照を解消（上記フォーカス）。
- 2026-06-21: Memory Bank 6 コア + interrupt/ 受信箱を新規作成（initialize memory bank）。
- リポジトリ調査（README / git log / skills / .gitignore / 未コミット diff）を実施し、各コアへ反映。

## 次のステップ
1. supervisor として配下 `workers/manystore` を pull 回収（outbox）＋状態確認し、必要なら下り dispatch。
   あわせて manystore の flow が **pull 型 outbox に追従しているか**（旧 push 型エスカレの名残が無いか）軽く確認。
2. ユーザーの次の指示を受けて作業対象を選定する。

> 他マシンへの `install.sh` 反映は不要（他マシンなし＝2026-06-22 ユーザー確認）。manystore 移行完了につき
> 旧名互換（symlink・hook 旧名検出・settings 旧 glob）は 2026-06-22 撤去済み。

## 進行中の決定・考慮事項
- コミット方針は config 未配置のため既定 `agent-branch`（現在ブランチが既に `agent` なのでそのまま積む）。
- WIP は本人の編集なので、内容を確認の上まとめてコミットしてよいか（独立コミットにすべきか）は要判断。

## 重要なパターン・好み / 学び
- 正本はつねに宣言側（CLAUDE.md / config）に置き、スキルへハードコードしない。
- `.work/` は commit する（gitignore しない）＝リセット後の唯一の引き継ぎ手段。
- エージェントは `agent` ブランチに単線でコミットし、`main` 統合は人間に委ねる（競合を背負わない）。
