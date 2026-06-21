# Active Context

## 現在のフォーカス（2026-06-22）
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

> 他マシンへの `install.sh` 反映は不要（他マシンなし＝2026-06-22 ユーザー確認）。旧名互換 symlink は
> 全 worker 移行後に削除でよい。

## 進行中の決定・考慮事項
- コミット方針は config 未配置のため既定 `agent-branch`（現在ブランチが既に `agent` なのでそのまま積む）。
- WIP は本人の編集なので、内容を確認の上まとめてコミットしてよいか（独立コミットにすべきか）は要判断。

## 重要なパターン・好み / 学び
- 正本はつねに宣言側（CLAUDE.md / config）に置き、スキルへハードコードしない。
- `.work/` は commit する（gitignore しない）＝リセット後の唯一の引き継ぎ手段。
- エージェントは `agent` ブランチに単線でコミットし、`main` 統合は人間に委ねる（競合を背負わない）。
