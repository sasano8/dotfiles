---
name: quality
description: プロジェクトの品質規約（uv 強制 / pyproject / ruff・pytest / Makefile の format・test / src レイアウト）を正本として持ち、対象リポジトリを監査して規約違反・不足を問題点として列挙し、是正をエージェントのタスクとして登録・処理する。新規・既存どちらにも使える（新規＝全項目が「不在」として挙がる）。現状サポートは Python。ユーザーが「品質」「quality」「規約チェック」「足回りを整える」「format と test を整備」「プロジェクトを規約に合わせて」等を求めたときに使う。
---

# quality — プロジェクト品質規約の適用（規約 → 監査 → タスク化）

このスキルは **品質規約（ルール）を正本として持ち**、対象リポジトリをそれに照らして監査し、
**問題点を列挙**して、**是正をエージェントのタスクとして処理**させる。スキャフォルダではなく
「あるべき姿との差分を埋める」運用。新規リポジトリは全項目が「不在」として挙がるだけで同じ流れに乗る。

**いまは Python のみ対応**（他言語は将来このスキルに節を足して拡張する）。

## 進め方（3 ステップ）

1. **規約提示** — 下記「品質規約（ルール）」を対象に適用することを宣言。プロジェクト固有の例外があれば
   ここで確認して上書き（例: `requires-python`、ソースレイアウト）。
2. **監査 → 問題点の列挙** — 各ルールを判定（**OK / 違反 / 不在**）し、違反・不在を一覧化する。
   各項目に `ルールID / 現状 / あるべき姿 / 重大度 / 是正方針` を書く（下記「監査レポート様式」）。
3. **タスク化 → 処理** — 是正を **`TaskCreate` でタスク登録**し、エージェントが順に処理する
   （着手で `in_progress`、完了で `completed`）。最後に `make check`（整形確認＋test）が緑で完了。

> このスキルは**勝手に commit しない**。是正後の commit 可否はユーザーに委ねる
> （commit をフローに組み込む運用は [[memory-bank]] 側に従う）。

## 品質規約（ルール）

各ルールは「あるべき姿 / 判定方法」を持つ。あるべき姿の具体形は末尾「リファレンス雛形」を正本とする。

| ID | ルール | 判定方法（違反/不在の見つけ方） |
|----|--------|-------------------------------|
| **R1 uv 強制** | 依存管理は uv（`uv sync`/`uv add`/`uv run`、使い捨ては `uvx <tool>@<版>`）。`pip`/素の venv 手順は不可 | `uv.lock` の有無。README/CI/Makefile に `pip install` が無いか。`uv --version` が通るか |
| **R2 pyproject** | `pyproject.toml` が存在し hatchling ビルド。`[project]`（name/version/requires-python/dependencies）が揃う | ファイル有無と必須キー |
| **R3 ruff 設定** | `[tool.ruff] line-length=100`・`target-version="py314"`、`[tool.ruff.lint] select=["E","F","I","UP","B","SIM"]` | 当該節の有無・値 |
| **R4 pytest 設定** | `[tool.pytest.ini_options] testpaths=["tests"] addopts="-ra"`、dev 依存に `pytest>=8.0` | 当該節と dev group |
| **R5 Makefile** | `format`/`format-check`/`lint`/`test`/`check` を提供。**format は `uvx ruff@<固定版>`**（`RUFF_VERSION` で 1 点管理。**py314 対応版**＝0.15+ 目安） | ターゲット有無、ruff がピン留めか（`ruff@x.y.z`） |
| **R6 src レイアウト** | ソースは `src/<package>/`、wheel packages は `["src/<package>"]`、`tests/` 分離 | ディレクトリ構成、`[tool.hatch.build.targets.wheel]` |
| **R7 .gitignore** | `.venv/` `__pycache__/` `.pytest_cache/` `.ruff_cache/` `dist/`/`*.egg-info/` を無視 | 当該エントリ |
| **R8 検証緑** | `make check`（`format-check` + `test`）が緑 | 実行結果。落ちる箇所が是正対象 |
| **R9 Python 3.14+** | `requires-python=">=3.14"`。3.14 は注釈遅延評価（PEP 649）が既定＝**`from __future__ import annotations` を書かない**（自クラス等への前方参照はそのまま valid）。ruff は py314 対応版＋`target-version="py314"` | `requires-python` の値、`from __future__ import annotations` の混入、ruff 版/`target-version` |

> ルールはプロジェクト都合で**安易に緩めない**。例外が要るなら 2.の規約提示で合意してから外す。

## 監査レポート様式（問題点の列挙）

```markdown
## 品質監査: <project>（規約: quality / Python）

| # | ルール | 現状 | あるべき姿 | 重大度 | 是正方針 |
|---|--------|------|-----------|--------|---------|
| 1 | R5 Makefile | format が素の `ruff`（未ピン） | `uvx ruff@<版>` に固定 | 中 | RUFF_VERSION 導入 |
| 2 | R6 src    | パッケージが直下 | `src/<pkg>/` へ移動 | 高 | 移動＋wheel packages 更新 |

→ 上記をタスク化して処理する。
```

是正は **粒度を 1 ルール（または 1 ファイル）単位**でタスクに割る。依存関係（例: R6 移動 → R4 testpaths）が
あれば順序を明示する。

---

## リファレンス雛形（あるべき姿の正本）

`<name>` / `<package>` は対象に合わせて置換。設計の正本は既存リポジトリ `manystore` の構成に揃えてある。

### pyproject.toml

````toml
[project]
name = "<name>"
version = "0.0.1"
description = ""
requires-python = ">=3.14"
dependencies = []

[dependency-groups]
dev = [
    "pytest>=8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/<package>"]

[tool.ruff]
line-length = 100
target-version = "py314"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra"
````

> `uv sync` がプロジェクトを editable で入れるため、`src` レイアウトでも `tests` から
> `import <package>` できる（`pythonpath` 設定は不要）。

### Makefile

`format` は **`uvx ruff@<固定版>`**。バージョンは先頭の `RUFF_VERSION` だけ変えれば全体に反映。

````makefile
# <project> — 開発タスク
# format は uvx で ruff のバージョンを固定して実行する（環境差を排除）。

# ruff のピン留めバージョン（更新時はここだけ変える。py314 対応版＝0.15+ 目安）
RUFF_VERSION := 0.15.18

# lint/format/test の対象
SRC := src tests

.PHONY: format format-check lint test check

# コード整形（自動修正）
format:
	uvx ruff@$(RUFF_VERSION) format $(SRC)
	uvx ruff@$(RUFF_VERSION) check --fix $(SRC)

# 整形確認のみ（CI 向け・書き換えない）
format-check:
	uvx ruff@$(RUFF_VERSION) format --check $(SRC)
	uvx ruff@$(RUFF_VERSION) check $(SRC)

# lint のみ
lint:
	uvx ruff@$(RUFF_VERSION) check $(SRC)

# テスト
test:
	uv run pytest

# 一括検証（format 確認 + test）
check: format-check test
````

### .gitignore

````gitignore
# Python
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/

# venv / uv
.venv/

# build
dist/
build/
*.egg-info/
````

### 最小レイアウト（新規時）

```
<project>/
├── pyproject.toml
├── Makefile
├── README.md
├── .gitignore
├── src/<package>/__init__.py    # __version__ = "0.0.1"
└── tests/test_smoke.py          # import <package>; assert <package>.__version__
```

## 注意

- **uv 必須。** 是正案に `pip` / 素の `python -m venv` を出さない。
- 既存ファイルは上書きせず、監査で差分提示 → タスクとして合意の上で直す。
- ruff のピン版は「最新安定版を 1 つ選んで固定」。存在しないバージョンを書くと R8（`make check`）で落ちる。
- **Python 3.14+ 前提（R9）**: `from __future__ import annotations` は書かない（3.14 は注釈遅延評価が既定で前方参照は
  valid）。ruff は `target-version="py314"` が通る版（0.15+ 目安）を選ぶ。0.9 系は py314 未対応で設定パース時に落ちる。
  なお「不要な future import」を自動で消す lint ルールは無い＝R9 は config（`target-version`/`requires-python`）と
  本ルールの規約で担保する（監査時に grep で混入を確認）。
- 他言語対応が要るときは、本スキルに言語別のルール表＋雛形を足して拡張する（スキルは分割しない）。
