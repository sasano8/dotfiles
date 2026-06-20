# dotfiles

個人環境の設定を git 管理し、各マシンで symlink を張って同期する。

## セットアップ（新しいマシン）

```bash
git clone <this repo> ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` は冪等。既存の symlink は張り直し、symlink でない実体があればスキップして警告する。

## 中身

| パス | symlink 先 | 用途 |
|------|-----------|------|
| `claude/skills/memory-bank/` | `~/.claude/skills/memory-bank` | Claude Code ユーザースキル（Cline 準拠 Memory Bank） |

## スキルを編集するとき

実体は `~/dotfiles/claude/skills/...` にある（`~/.claude/skills/` は symlink）。
普段どおり編集 → `cd ~/dotfiles && git commit` で履歴を残し、他マシンは `git pull` で反映される
（symlink なので張り直し不要）。
