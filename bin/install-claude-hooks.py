#!/usr/bin/env python3
"""Claude Code の settings.json に SessionStart フックをマージ注入する。

- 標準ライブラリのみ。
- 既定はドライラン: 対象ファイルと差分(unified diff)を表示し、書き込まない。
- --apply で実際に書き込む(冪等。既に同じ command があれば変更なし)。
- settings.json が symlink の場合は実体(dotfiles 側)へ書き込む(symlink は保持)。

使い方:
    install-claude-hooks.py                # ドライラン(差分表示のみ)
    install-claude-hooks.py --apply        # 書き込み
    install-claude-hooks.py --settings ~/.claude/settings.json --apply
"""

from __future__ import annotations

import argparse
import copy
import difflib
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path


def default_hook_command() -> str:
    """同梱の memory-bank-sessionstart を $HOME 相対(可能なら)で表す。"""
    hook = Path(__file__).resolve().parent / "memory-bank-sessionstart"
    home = Path.home()
    try:
        return f"$HOME/{hook.relative_to(home).as_posix()}"
    except ValueError:
        return str(hook)


def build_hook_entry(command: str) -> dict:
    return {
        "type": "command",
        "command": command,
        "timeout": 10,
        "statusMessage": "Memory Bank を確認中...",
    }


def session_start_has_command(settings: dict, command: str) -> bool:
    for group in settings.get("hooks", {}).get("SessionStart", []):
        for h in group.get("hooks", []):
            if h.get("type") == "command" and h.get("command") == command:
                return True
    return False


def merge_hook(settings: dict, command: str) -> dict:
    """SessionStart に command を追加した新しい dict を返す(元は変更しない)。"""
    out = copy.deepcopy(settings)
    hooks = out.setdefault("hooks", {})
    session_start = hooks.setdefault("SessionStart", [])
    session_start.append({"hooks": [build_hook_entry(command)]})
    return out


def dumps(obj: dict) -> str:
    return json.dumps(obj, indent=2, ensure_ascii=False) + "\n"


def load_settings(path: Path) -> dict:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        return {}
    try:
        data = json.loads(text)
    except json.JSONDecodeError as e:
        sys.exit(f"error: {path} は不正な JSON です: {e}")
    if not isinstance(data, dict):
        sys.exit(f"error: {path} のトップレベルがオブジェクトではありません")
    return data


def main() -> int:
    ap = argparse.ArgumentParser(description="Claude Code に SessionStart フックを注入する")
    ap.add_argument(
        "--settings",
        type=Path,
        default=Path.home() / ".claude" / "settings.json",
        help="対象 settings.json (既定: ~/.claude/settings.json)",
    )
    ap.add_argument("--command", default=default_hook_command(), help="フックの command 文字列")
    ap.add_argument("--apply", action="store_true", help="実際に書き込む(既定はドライラン)")
    ap.add_argument("--no-backup", action="store_true", help="--apply 時に .bak を作らない")
    args = ap.parse_args()

    path: Path = args.settings.expanduser()
    print(f"対象ファイル: {path}" + (" (symlink)" if path.is_symlink() else ""))
    if path.is_symlink():
        print(f"  -> 実体: {path.resolve()}")

    before = load_settings(path)

    if session_start_has_command(before, args.command):
        print(f"既に注入済み(command が一致): {args.command}")
        print("変更なし。")
        return 0

    after = merge_hook(before, args.command)

    diff = difflib.unified_diff(
        dumps(before).splitlines(keepends=True),
        dumps(after).splitlines(keepends=True),
        fromfile=f"{path} (現在)",
        tofile=f"{path} (適用後)",
    )
    diff_text = "".join(diff)
    print("\n--- 差分 ---")
    print(diff_text if diff_text else "(差分なし)")

    if not args.apply:
        print("\n[ドライラン] 書き込みません。適用するには --apply を付けてください。")
        return 0

    if path.exists() and not args.no_backup:
        bak = path.with_name(path.name + f".bak.{datetime.now():%Y%m%d%H%M%S}")
        shutil.copy2(path, bak)  # symlink の場合は実体の内容をコピー
        print(f"\nバックアップ: {bak}")

    path.parent.mkdir(parents=True, exist_ok=True)
    # symlink の場合、'w' は実体へ書き込み symlink は保持される
    path.write_text(dumps(after), encoding="utf-8")
    print(f"書き込みました: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
