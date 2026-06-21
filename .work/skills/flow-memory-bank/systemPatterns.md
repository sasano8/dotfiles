# System Patterns

## システム構成
```
dotfiles/
├── CLAUDE.md            # プロジェクト指示（flow/role を使う宣言・taxonomy 参照規約・workers_dir 宣言）
├── README.md            # 入口（詳細は各 SKILL.md）
├── install.sh           # 冪等・非破壊な symlink 展開（旧 dangling リンクの prune も）
├── claude/settings.json # ~/.claude/settings.json の正本（SessionStart/PreToolUse フック同梱）
├── editorconfig         # ~/.editorconfig（Makefile のタブだけ規定）
├── bin/                 # 補助スクリプト（sessionstart / worker-boundary-guard / lint-doc-refs / new-meeting）
├── skills/              # role-supervisor_or_worker / flow-memory-bank / unit-quality / func-docs-summary
└── workers/             # supervisor 配下ワーカー（別リポジトリ・gitignore 済み。現状 manystore）
```

## 主要な技術判断
- **スキル共有**: `skills/<name>/SKILL.md` を `~/.claude/skills/` と `~/.agents/skills/` の両方へ symlink
  （Codex/Gemini 等が共通で読む Agent Skills 標準）。
- **非破壊リンク**: 既存の組織管理設定を勝手に上書きしない。上書きは `FORCE=1`。共有未対応ツールは検出して通知。
- **フック注入は Python 化**: `bin/install-claude-hooks.py`（ドライラン既定 / `--apply` で .bak 作成・冪等）。
- **秘密情報の構造的排除**: `.gitignore` で credentials / key / token 等を広くパターン除外。
- **ロールは構造で決まる**: supervisor か否かは CLAUDE.md の `workers_dir` 宣言（capability の昇格）。
  スキル本体は配下の場所を持たない（正本は宣言側）。

## 設計パターン / 原則
- **正本の一元化**: 設定もワーカー所在も「宣言側（CLAUDE.md / config）」が正本。スキルにハードコードしない。
- **Memory Bank（Cline 準拠）**: `.work/skills/<skill>/` 規約。`.work/` は gitignore せず commit する（引き継ぎの正本）。
- **agent ブランチ単線運用**: エージェントは `agent` ブランチに単線でコミット。`main` への統合は人間。
  エージェントは競合解決を背負わない。
- **interrupt 受信箱**: 非対話でユーザーが要望を投函 → 起動時に取り込み → archive へ退避。

## コンポーネント関係 / 重要な実装経路
- `install.sh` → symlink 群を張る。`bin/install-claude-hooks.py` → settings.json へ SessionStart フック注入。
- `bin/memory-bank-sessionstart` → プロジェクトに Memory Bank があれば「読め」と案内（コア充足も検証する方向で改修中）。
- supervisor フロー: `workers_dir` 列挙 → 各ワーカーの `.work/skills/memory-bank/`（activeContext/progress）を読む
  → interrupt へ指示配信 → エスカレ取り込み。

## アーキテクチャ: スキルを role / flow / unit / func の 4 レベルに分ける（Stage1・Stage2 実装済み）

スキルを役割・手順・観点・機能の 4 レベルに整理し、名前にプレフィックスを付ける（M004）。
依存は常に上→下のみ（下位は上位を参照し返さない＝[[skill-no-hard-refs-to-project-impl]] と一致）。

```
role-*  … 各ロール間のやり取り方法（向き・境界）＋「1 つの共通 flow」への参照を持つ
flow-*  … 作業の進め方/記憶。エージェント間通信（interrupt 機構）を規定。複数 unit への参照を持つ
unit-*  … 単一観点の点検指標（葉）
func-*  … 単機能ユーティリティ（葉。例: docs-summary）
```

- **Stage1（実装済み）**: 4 スキルを prefix 改名（`role-supervisor_or_worker` / `flow-memory-bank` /
  `unit-quality` / `func-docs-summary`）。クロス参照を層エイリアスへ抽象化（`[[flow]]`/`[[role]]` は singleton、
  `[[unit-*]]`/`[[func-*]]` は葉のフル名）＝具体名は frontmatter のみ residし以後のリネームに波及しない。
  データ slot は `.work/skills/flow-memory-bank/`（**全 worker＝manystore 移行完了。旧名 memory-bank への移行互換
  ＝symlink・settings 旧 glob・hook 旧名検出は 2026-06-22 に撤去済み**）。install.sh は dangling 旧リンクを prune。
- **Stage2（実装済み）**: 下記の内容再配置を完了（ポリシー移動・quality 両建て廃止・エスカレ pull outbox・
  開発内ループ明文化・フックへ role 判定 1 行）。コミット `2c…`〜（agent ブランチ、ファイル単位 5 コミット）。

- **role-supervisor_or_worker**（現 `supervisor` を改名・統合）: 既定 worker、`workers_dir` 宣言で supervisor へ昇格。
  - **権限は非対称（下り許可・上り禁止）**: supervisor→worker（下り）は許可＝dispatch・worker の interrupt 投函・
    worker の outbox 回収/受領印。worker→supervisor（上り）は禁止＝越権（親の正本/受信箱に直接書かない）。
    「worker 不可侵（互いに触れない）」ではなく、触れてよいのは下りだけ。
  - 境界の機械強制は `bin/worker-boundary-guard`（dotfiles 実装＝個別層。**止めるのは上りだけ**。スキルは原則のみ）。
  - 「上りエスカレの向き・境界ポリシー」は flow から**ここ role へ移動**（機構＝積み方は flow に残す）。
  - **quality は下り dispatch で**: 配下を横断監査せず、drift が気になれば worker へ「自己点検せよ」と下ろすだけ
    （実点検は worker の flow→unit。role→unit 直参照・横断スイープは持たない＝両建て廃止）。
  - 配信 dispatch は worker の flow 開発内ループの**起点**だが、supervisor は各反復を driver しない（疎結合）。
- **flow-memory-bank**（現 `memory-bank`）: 6 コア＋サイクル。**interrupt の機構（受信箱・取り込み・書式）を規定**＝
  役割間通信が起きる“場所”。役割に非依存（role を参照し返さない）。複数 unit を参照。
  - **開発内ループを明文化**: 開発→自己点検（flow→unit-quality）→コミット単位に達するまで反復→commit→記録→次。
    ループ本体は worker 側 flow が自走（起点 dispatch は role）。
  - **上りエスカレは pull 型**: worker は親を知らなくてよい。自分の **outbox `outbox/`**（flow の所定場所）に積むだけで、
    supervisor が `workers_dir` を走査して回収する（起動時 roll-up の拡張）。flow が「タスク/エスカレの積み方」を規定。
  - **worker は既定動作**: per-worker の CLAUDE.md 契約は作らない（正本の複製になる）。worker 既定は role 既定（`workers_dir`
    不在）＋グローバル hook（flow を促す＋role 判定 1 行）＋guard（境界）の中央で賄う。
- **unit-quality**（現 `quality`）ほか: 単一観点。
  - quality は**常に flow→unit の自己点検 1 本（両建てにしない）**: 各 repo が自分の flow 開発内ループから参照して走らせる。
    supervisor は横断監査せず worker へ下り dispatch するだけ＝role→flow→unit が一貫する。
