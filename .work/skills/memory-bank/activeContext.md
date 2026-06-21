# Active Context

## 現在のフォーカス
- **`memory clean` の実装を完成（2026-06-21、worker=manystore 経由のユーザー依頼）。** 前セッションで
  `memory clean` の配線（description キーワード＋起動時チェック L23 の前方参照「下記『メモリークリーン』」）
  だけ入れて**本体の節を書かずに中断・未コミット**だった。この壊れた前方参照を解消すべく、SKILL.md に
  **「メモリークリーン（memory clean ＝ 畳み込み / GC）」節**を追記（トリガ／肥大の兆候／操作=昇格・畳み込み・
  GC・dedup／非破壊原則／1 コミットで終える）。やりかけの description/L23 もそのまま活かして 1 コミットに。

## 直近の変更
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
