---
name: memory-bank
description: Cline の Memory Bank パターンに準拠した永続ドキュメント群を読み書きし、セッションを跨いでプロジェクトを継続する。作業フォルダ `.work/skills/memory-bank/` 配下の 6 コアファイル（projectbrief / productContext / activeContext / systemPatterns / techContext / progress）を、毎タスク開始時に必ず全て読む。初回利用（ファイルが無い）は「initialize memory bank」として雛形を初期化する。ユーザーが「memory bank」「initialize memory bank」「update memory bank」「作業を進める」「次のサイクル」等を求めたときに使う。プロジェクト非依存。
---

# Memory Bank（Cline 準拠）

> 本スキルは [Cline の Memory Bank](https://docs.cline.bot/prompting/cline-memory-bank) の構成・運用に準拠する。
> Memory Bank の実体は **作業フォルダ `.work/skills/memory-bank/`** 配下に置く（`.work/skills/<スキル名>/` 規約。
> リポジトリ直下を汚さない）。`.work/` は **gitignore しない**＝引き継ぎのため commit する状態の正本。

私（このエージェント）はセッションを跨ぐと記憶が完全にリセットされる、という前提で動く。リセット後は
**Memory Bank だけ**を頼りにプロジェクトを理解し作業を継続する。したがって **毎タスクの開始時に Memory Bank の
全ファイルを必ず読む（任意ではない）**。

## 0. 起動時チェック（必須・最初に）

`.work/skills/memory-bank/` の有無と 6 コアファイルの存在を確認する。

- **揃っている** → 全ファイルを読んでから「コアワークフロー」へ。
- **無い／不完全** → **「initialize memory bank」をユーザーに提案・実行する**（下記「初期化」）。

旧レイアウト（リポジトリ直下や `AGENT_LOOP.md` / `PROJECT.md` の 2 ファイル構成）が見つかった場合は、
Cline 6 ファイル構成へ移行することを提案する（内容を 6 ファイルへ振り分け、旧ファイルは削除）。

## Memory Bank の構造（コアファイル）

すべて Markdown。ファイルは階層を成し、上位が下位を規定する。

```
projectbrief.md ─┬─> productContext.md ─┐
                 ├─> systemPatterns.md ─┼─> activeContext.md ─> progress.md
                 └─> techContext.md ────┘
```

### コアファイル（必須・6 つ）

1. **projectbrief.md** — 全ての土台。プロジェクト開始時に作成。**コア要件・ゴール・スコープの正本**。
2. **productContext.md** — なぜ存在するか／解決する課題／どう動くべきか／UX ゴール。
3. **activeContext.md** — **現在の作業フォーカス**／直近の変更／次のステップ／進行中の決定・考慮事項／
   重要なパターンと好み／学び・知見。（最も頻繁に更新する）
4. **systemPatterns.md** — システム構成／主要な技術判断／採用する設計パターン／コンポーネント関係／
   重要な実装経路。
5. **techContext.md** — 使用技術／開発セットアップ／技術的制約／依存／ツールの使い方。
6. **progress.md** — 動くもの／残作業／現状ステータス／既知の問題／意思決定の変遷。

### 追加コンテキスト（任意）

整理に役立つなら `memory-bank/` 配下にファイル/フォルダを足してよい（複雑な機能の仕様、統合仕様、
API ドキュメント、テスト戦略、デプロイ手順 など）。

## コアワークフロー

### Plan Mode（計画）

```
Start → Memory Bank を読む → ファイルは揃っているか?
  ├─ No  → 計画を立てる → チャットに計画を文書化
  └─ Yes → コンテキストを検証 → 戦略を立てる → 進め方を提示
```

### Act Mode（実行）

```
Start → Memory Bank を確認 → ドキュメントを更新 → タスクを実行 → 変更を文書化
      → 切りがよければ commit（下記「コミットをフローに組み込む」）
```

「変更を文書化」したら、**切りのいいところでコミットする**ところまでが 1 サイクル。コミットせずに
次のタスクへ進まない（コミットは引き継ぎの単位＝リセット後の唯一の手がかりを確定させる行為）。

## ドキュメント更新（Documentation Updates）

Memory Bank の更新は次のときに行う：
1. 新しいプロジェクトのパターンを発見したとき。
2. 重要な変更を実装したあと。
3. ユーザーが **「update memory bank」** を要求したとき（**全ファイルを必ずレビューする**）。
4. コンテキストの明確化が必要なとき。

更新プロセス: **全ファイルをレビュー → 現状を文書化 → 次のステップを明確化 → 知見・パターンを記録**。
特に **activeContext.md** と **progress.md**（現状を追う 2 ファイル）を重点的に見る。

## コミットをフローに組み込む（必須）

Memory Bank は引き継ぎの正本なので、**「切りのいいところ」で必ずコミットする**ところまでがワークフロー
（Act Mode の終端）。コミットしていない作業はリセットで失われる前提で扱う。

**前提：git リポジトリのときだけ。** リポジトリが git 初期化されていない場合（`git rev-parse` が失敗等）は
コミット手順を**まるごとスキップする**（`git init` を促したりコミットの是非を問うたりしない）。Memory Bank
ファイルの更新だけ行えばよい。

### 「切りのいいところ」の定義

次を満たしたら 1 つの区切り＝コミット単位とする：
1. 意味のあるまとまり（1 タスク / 1 機能 / 1 修正）が一段落した。
2. 検証が緑（lint + test。techContext.md の検証コマンド）。緑にできない場合は WIP である旨を
   activeContext.md に明記してからコミットする。
3. Memory Bank（特に **activeContext.md** と **progress.md**）を現状に合わせて更新済み。

### コミットのやり方

- **コード変更と Memory Bank の更新を 1 コミットにまとめる**（「何を変えたか＋現状＋次の計画」が
  1 コミットで揃う）。
- 既定では **`main` に直コミットしない**。作業前に branch を切る（既に作業ブランチ上ならそのまま）。
- メッセージは Conventional Commits（`feat:` / `fix:` / `refactor:` / `docs:` / `test:` 等）＋日本語要約で可。
- **push はユーザーが求めたときだけ**行う（コミットはこまめに、push は明示時）。
- コミット前に `git status` / `git diff` で意図しない混入（生成物・秘密情報）が無いか確認する。

> 自動化したい場合：判断（「切りがいいか」）を伴うため Stop フック等での無条件 auto-commit は避ける。
> どうしてもハードに強制したいなら、コミット漏れを*通知*するだけの非ブロッキングなフックに留める。

## 初期化（initialize memory bank）

ファイルが無いプロジェクトで初めて使うときの手順：

1. `mkdir -p .work/skills/memory-bank`。
2. `.gitignore` が `.work/` を無視していないか確認（無視していれば `!.work/skills/` 等で除外、または
   ユーザーに方針確認）。状態の正本なので **commit される**こと。
3. リポジトリを実際に調べ（README / pyproject / ソース / git log 等）、6 コアファイルを作成する。
   各ファイルの内容は上記「コアファイル」の役割に従い、**projectbrief.md（土台）→ 派生ファイル → 
   activeContext / progress** の順に埋める。下記「雛形」を出発点にしてよい。
4. 初期化内容をユーザーに要約提示し、必要なら commit する。

## 注意

- **毎タスク開始時に全コアファイルを読む**（リセット後の唯一の手がかり）。これを省略しない。
- 大物タスクや破壊的・外向きの判断は着手前にユーザーへ確認する。
- リセット後は完全にゼロから始まる。Memory Bank だけが過去の作業との唯一の接続点であり、その正確さに
  作業効率が完全に依存する。**精確さと明瞭さをもって維持すること。**

---

## コアファイル雛形

### projectbrief.md
````markdown
# Project Brief: <プロジェクト名>

## 概要 / スコープ
（何を作るか。スコープの正本＝この範囲を超える要求は別途合意）

## コア要件
- （要件 1）

## ゴール
- （ゴール 1）
````

### productContext.md
````markdown
# Product Context

## なぜ存在するか / 解決する課題
## どう動くべきか
## UX / 利用者ゴール
````

### activeContext.md
````markdown
# Active Context

## 現在のフォーカス
（いま/次に取り組むこと。空なら「未着手＝次サイクルで選定」）

## 直近の変更
## 次のステップ
## 進行中の決定・考慮事項
## 重要なパターン・好み / 学び
````

### systemPatterns.md
````markdown
# System Patterns

## システム構成
## 主要な技術判断
## 設計パターン / 原則
## コンポーネント関係 / 重要な実装経路
````

### techContext.md
````markdown
# Tech Context

## 使用技術 / スタック
## 開発セットアップ
## 検証コマンド（lint + test。例 `uvx ruff check` / `uv run pytest`）
## 技術的制約 / 依存
````

### progress.md
````markdown
# Progress

## 動くもの（What works）
## 残作業（What's left）
## 現状ステータス
## 既知の問題
## 意思決定の変遷
````
