# Active Context

## 現在のフォーカス
- Memory Bank を初期化したばかり（このサイクルで `.work/skills/memory-bank/` を新規作成）。
- 直前から **未コミットの WIP** が 2 件ある（このリポジトリの作業者本人の編集）:
  - `skills/memory-bank/SKILL.md` — 「無い／不完全」時を**ブロッキング化**（通知だけで進まない／承諾後に作り切る）。
  - `bin/memory-bank-sessionstart` — dir があっても 6 コアが欠けていれば警告し initialize を促す充足チェックを追加。
  → これらは Memory Bank の自己改善で一貫しているので、この初期化と合わせてコミット候補。

## 直近の変更
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
