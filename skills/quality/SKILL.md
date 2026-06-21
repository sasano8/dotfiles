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

## 関心の分離（どこに何を書くか）

本スキルは『**単体スキル**』＝ お作法（規約・チェックシート・書き方）の自己完結した正本。**フロー（手順・実行
タイミング・優先度・誰がいつ）は持たない**——それは『**俯瞰的スキル**』（[[supervisor]] / [[memory-bank]]）の領分。
スキルはこの 2 種に分け、混ぜない:

- **俯瞰的スキル**: フロー・段取り・横断計画を持ち、単体スキルを呼び出す/参照する。
- **単体スキル**: 自己完結したお作法・知識を持ち、俯瞰的スキルから参照される。**フローを混ぜない**。

その上で本スキルは**一般的な検証方法・チェックシートの正本**（再利用可能・プロジェクト/組織非依存）。
「この組織でどう適用するか」「どの repo を何でチェックするか」は**本スキルに書かず**、層を分ける:

| 層 | 持ち物 | 例 |
|----|--------|----|
| **quality（本スキル）** | 一般的な検証方法・チェックシート（R1〜R10・雛形） | 「Makefile に `check` を持て」「`make check` が緑」 |
| **組織の品質方針**（[[memory-bank]] の参照系 `reference/`） | 本スキルを組織にどう適用するか。quality を参照 | supervisor memory-bank の `reference/quality-policy.md` |
| **[[memory-bank]]** | 「品質チェックを行う」とだけ言う（規約は持たない） | 切りのいいところで品質チェック → 組織方針に従う |
| **各 repo の techContext** | 組織方針を materialize した呼び出し | `make check` |

- **判断（あるべき姿）は本スキルに集約**し、他層は本スキルを参照するだけ（具体規約を各層へコピペしない＝drift 源）。
- **スキル / ドキュメントの更新も品質対象**: SKILL.md やドキュメントを更新するときも本スキルの該当チェック
  （構成・一貫性・参照の妥当性）を参照する。コードだけが品質対象ではない。スキルを増改築するときは、
  この関心の分離を崩していないか（規約の二重持ち・層の越境が無いか）を本スキルで点検する。

## ドキュメントの書き方

SKILL.md・README・設計メモなど**文章**の品質規約。コードと同じく「読み手が最短で正しく理解できるか」で見る。

1. **自己完結を優先** — 知識はできるだけ**その文章の中で完結**させる。読み手が他所を何度も往復しないと
   理解できない書き方を避ける（リンク追跡＝知識の分断・読解コスト）。

2. **体系 → 詳細にブレークダウン** — 知識量が多いときは **体系的（俯瞰・原則）→ 詳細（具体・手順）** の順に
   段階を作る。冒頭で全体像と要点、深掘りは後段・小節へ。読み手は必要な深さで読み止められる。

3. **核から外れるものは参照に逃がす** — 本文にはその文章の**ドメインの核となる関心**だけを置き、それ以外
   （別ドメイン・別レイヤの詳細）は**参照**で逃がす（[[memory-bank]] の `reference/` や他スキルへのリンク）。
   「**核は完結・周辺は参照**」＝自己完結（1）と分量制御を両立させる（上記「関心の分離」の文章版）。

4. **構造が悪いときはスキルも疑う** — 文章が書きにくい・肥大する・重複する・どこに書くか迷うときは、
   **文章そのもの**だけでなく、それを規定する**スキルの構造**が悪い可能性を疑う（関心の分離の崩れ／レイヤ
   配置の誤り）。直すべきが個別文章ではなくスキル側のこともある。

> **読み方は書き方の鏡（最小限）** — 読み手は基本 **俯瞰→局所**（構造・要点 → 詳細＝上の体系→詳細の鏡）。
> 方向は目的で選ぶ: 全体像づくりは依存の**順流（上流→下流）**、原因追跡は**逆流（下流→上流）**。ただし
> 適応的な読み自体は LLM が得意なので**読み方のアルゴリズムは規定しない**——お作法として効くのは**書く側**:
> これらの読み経路が成立するよう構造化する（例: [[memory-bank]] のコアは projectbrief→…→progress＝上流→下流）。

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
| **R10 検証規約の取り込み** | [[memory-bank]] を使う repo は、その `techContext.md`「検証コマンド」が **本スキル（quality）を参照し materialize**（`make check` 等の Makefile 呼び出し）していること。生 `uvx ruff …` のベタ書きや、R5/R8 と drift した記述が無い | `techContext.md`「検証コマンド」節を確認（[[quality]] への言及・`make` 経由・ベタ書き不在）。**supervisor が配下 worker（と自身）に対し定期実行**（[[supervisor]]）。判断（あるべき姿）は本スキルが正本 |
| **R11 ドキュメント/スキルの書き方** | SKILL.md・README・設計文書が「ドキュメントの書き方」（自己完結／体系→詳細／核外は参照へ逃がす）に沿う。書きにくさ・重複・肥大は文章だけでなくスキル構造の歪みも疑う。**単体スキルにフロー（手順・タイミング・優先度）が混入していないか**（俯瞰的/単体 の分離）も見る | 当該文書を上記「ドキュメントの書き方」「関心の分離」節に照らして判定。判断系のため重大度は文脈依存。**対象は自リポ/統治下のスキル・文書のみ（外部スキルは統治外＝規約対象外）**。種別は名前のプレフィックスではなく宣言（frontmatter `kind: flow\|unit` 等）で持ち、ここでは*中身*の一貫性（フロー混入の有無）を見る |

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
- **R10（検証規約の取り込み）の判断は本スキルが正本だが、定期実行は [[supervisor]] が担う**（配下 worker の
  `techContext.md` が quality を materialize し続けているかの drift 監視）。quality はオンデマンド監査スキルなので
  自走しない＝supervisor のコアワークフロー（定期スイープ）から呼ばれて発揮される。単発で叩きたいときは本スキルを
  直接起動し、対象 repo の `techContext.md` を R10 で監査する。
