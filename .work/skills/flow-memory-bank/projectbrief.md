# Project Brief: dotfiles

## 概要 / スコープ
個人の Claude Code / エージェント（Codex / Gemini 等）設定とスキルを **git 管理**し、
`install.sh` の **symlink で各マシンへ冪等・非破壊に展開**するためのリポジトリ。
「設定とスキルの正本を 1 箇所に集約し、複数マシン・複数エージェントで共有する」ことがスコープ。

加えて、このリポジトリ自身が **supervisor**（配下ワーカーを束ねる）として宣言されている（`workers_dir: workers`）。

スコープ外: アプリ実装・業務ロジック。ここはあくまでエージェント基盤（設定・スキル・運用ルール）の置き場。

## コア要件
- スキルは `skills/<name>/SKILL.md`（Claude Code / Codex / Gemini 共通形式）として書き、
  `~/.claude/skills/` と `~/.agents/skills/` の両方へ symlink する。
- `install.sh` は **冪等・非破壊**（既存の組織管理設定を勝手に上書きしない。上書きは `FORCE=1`）。
- 秘密情報は `.gitignore` で構造的に排除（誤コミット防止）。
- supervisor 配下のワーカー（`workers/`）は別リポジトリ扱いで親には取り込まない（gitignore 済み）。

## ゴール
- 新しいマシンで `git clone` → `install.sh` だけで一貫したエージェント環境が再現できる。
- Memory Bank / supervisor / docs-summary / quality 等のスキルで、セッション・プロジェクトを跨いだ
  継続作業と俯瞰オーケストレーションを成立させる。
