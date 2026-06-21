# Active Context

## 現在のフォーカス
- **`memory clean` の実装を完成（2026-06-21、worker=manystore 経由のユーザー依頼）。** 前セッションで
  `memory clean` の配線（description キーワード＋起動時チェック L23 の前方参照「下記『メモリークリーン』」）
  だけ入れて**本体の節を書かずに中断・未コミット**だった。この壊れた前方参照を解消すべく、SKILL.md に
  **「メモリークリーン（memory clean ＝ 畳み込み / GC）」節**を追記（トリガ／肥大の兆候／操作=昇格・畳み込み・
  GC・dedup／非破壊原則／1 コミットで終える）。やりかけの description/L23 もそのまま活かして 1 コミットに。

## 直近の変更
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
1. WIP（SKILL.md / sessionstart）と Memory Bank 初期化を「切りのいい区切り」として `agent` ブランチへコミット。
2. supervisor として配下 `workers/manystore` の状態（`.work/skills/memory-bank/`）を確認するか、
   ユーザーの次の指示を受けて作業対象を選定する。

## 進行中の決定・考慮事項
- コミット方針は config 未配置のため既定 `agent-branch`（現在ブランチが既に `agent` なのでそのまま積む）。
- WIP は本人の編集なので、内容を確認の上まとめてコミットしてよいか（独立コミットにすべきか）は要判断。

## 重要なパターン・好み / 学び
- 正本はつねに宣言側（CLAUDE.md / config）に置き、スキルへハードコードしない。
- `.work/` は commit する（gitignore しない）＝リセット後の唯一の引き継ぎ手段。
- エージェントは `agent` ブランチに単線でコミットし、`main` 統合は人間に委ねる（競合を背負わない）。
