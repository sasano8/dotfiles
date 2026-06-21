# System Patterns

## システム構成
```
dotfiles/
├── CLAUDE.md            # プロジェクト指示（memory-bank/supervisor を使う宣言・workers_dir 宣言）
├── README.md            # 入口（詳細は各 SKILL.md）
├── install.sh           # 冪等・非破壊な symlink 展開
├── claude/settings.json # ~/.claude/settings.json の正本（SessionStart フック同梱）
├── editorconfig         # ~/.editorconfig（Makefile のタブだけ規定）
├── bin/                 # 補助スクリプト（hooks 注入 / sessionstart / new-meeting）
├── skills/              # docs-summary / memory-bank / quality / supervisor
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

## 目標アーキテクチャ: スキルを role / flow / unit の 3 レベルに分ける（backlog・未実装）

スキルを役割・手順・観点の 3 レベルに整理し、名前にプレフィックスを付ける（合意済み・実装は M004 で）。
依存は常に上→下のみ（下位は上位を参照し返さない＝[[skill-no-hard-refs-to-project-impl]] と一致）。

```
role-*  … 各ロール間のやり取り方法（向き・境界）＋「1 つの共通 flow」への参照を持つ
flow-*  … 作業の進め方/記憶。エージェント間通信（interrupt 機構）を規定。複数 unit への参照を持つ
unit-*  … 単一観点の点検指標（葉）
```

- **role-supervisor_or_worker**（現 `supervisor` を改名・統合）: 既定 worker、`workers_dir` 宣言で supervisor へ昇格。
  - 行動指針＝「自分の repo 外（親/配下）の中身は直接編集しない」。**唯一の例外＝ interrupt 経由のやり取りだけ許可**。
    - supervisor は全体俯瞰の知識を持つ → 全体を加味した**下り** interrupt を配下へ。
    - worker は自分の要望を**上り** interrupt（worker からの要望）として supervisor へ。
  - 境界の機械強制は `bin/worker-boundary-guard`（dotfiles 実装＝個別層。スキルは原則だけ持つ）。
  - 現 memory-bank にある「上りエスカレ（向き・境界のポリシー）」はここへ移す。
- **flow-memory-bank**（現 `memory-bank`）: 6 コア＋サイクル。**interrupt の機構（受信箱・取り込み・書式）を規定**＝
  役割間通信が起きる“場所”。役割に非依存（role を参照し返さない）。複数 unit を参照。
- **unit-quality**（現 `quality`）ほか: 単一観点。
  - quality は 2 つの顔: ①自分の品質を自分のサイクルで点検＝flow から参照する unit／
    ②supervisor が配下の quality drift を横断監視＝role 側に残す。両建て。
