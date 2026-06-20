# CLAUDE.md — dotfiles

このリポジトリでは [memory-bank] と [supervisor] スキルを使う。

## supervisor 宣言

このプロジェクトは **supervisor**。配下ワーカーは下記ディレクトリの各エントリ（symlink）。

- workers_dir: workers

> `workers_dir` が宣言されていなければ supervisor として動かない（no-op）。
> 配下は `workers/` に各ワーカーへの symlink を張って宣言する（実体は移動しない）。
