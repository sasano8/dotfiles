# CLAUDE.md — dotfiles

このリポジトリでは [[flow]]（記憶/作業フロー）と [[role]]（supervisor_or_worker）スキルを使う。

## スキル taxonomy と参照規約

スキルは **role / flow / unit / func** の 4 レベルで、名前にプレフィックスを付ける
（`role-supervisor_or_worker` / `flow-memory-bank` / `unit-quality` / `func-docs-summary`）。
**この 4 値が本リポの taxonomy ＝ SKILL.md frontmatter の必須キー `type` の取りうる値**（OKF 準拠・unit-quality R12。
汎用スキルは literal を持たず「taxonomy が定める値」とだけ言う＝具体値はここが正本）。
ドキュメント内のクロス参照は**具体名でなく層を指す**＝リネーム耐性を持たせる:

- `[[role]]` / `[[flow]]` … singleton（各 1 個）。`role-*` / `flow-*` プレフィックスの唯一のスキルへ解決。
- `[[unit-<name>]]` / `[[func-<name>]]` … 葉（複数）。フル名で参照。
- 依存は上→下のみ（role → flow → unit/func）。下位から上位・個別実装をハード参照しない。
- データ置き場（Memory Bank 実体）は安定 slot `.work/skills/flow-memory-bank/`。旧名 `memory-bank` への
  移行互換（symlink・settings 旧 glob・hook 旧名検出）は全 worker 移行完了につき撤去済み（2026-06-22）。

## supervisor 宣言

このプロジェクトは **supervisor**。配下ワーカーは下記ディレクトリの各エントリ（symlink）。

- workers_dir: workers

> `workers_dir` が宣言されていなければ supervisor として動かない（no-op）。
> 配下は `workers/` に各ワーカープロジェクトを置く（clone / submodule / symlink いずれでも）。
> `workers/` は別リポジトリなので gitignore 済み（親には取り込まない）。
