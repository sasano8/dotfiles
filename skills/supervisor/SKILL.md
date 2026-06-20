---
name: supervisor
description: 複数のワーカープロジェクトを束ねて俯瞰計画し、各ワーカーの interrupt 受信箱へ指示を配信し、ワーカーからのエスカレーションを取り込む。supervisor として動くのは CLAUDE.md に `workers_dir` を宣言したプロジェクトのみ（無ければ何もしない＝暴発しない）。優先度は要求側の要望を踏まえつつ supervisor が確定する。ユーザーが「supervisor」「workers をまとめる」「配下に指示」「俯瞰計画」「エスカレーションを捌く」等を求めたときに使う。プロジェクト非依存。
---

# supervisor — ワーカー群の俯瞰オーケストレーション

複数のワーカープロジェクトを束ね、**俯瞰計画 → 各ワーカーへ指示配信 → ワーカーからのエスカレ取り込み**を回す
スキル。各ワーカーの中身は [[memory-bank]] が継続を担い、supervisor は**横断の判断と配信**だけを行う。

> ロール（supervisor/worker）はアイデンティティではなく**構造と権限**で決まる。CLAUDE.md で `workers_dir` を
> 宣言したプロジェクトだけが supervisor として振る舞える（＝capability の昇格）。ワーカーは普通のプロジェクトで、
> 自分が誰の配下かを基本は知らない。

## 0. 起動時チェック（supervisor か判定）

このプロジェクトの **CLAUDE.md の supervisor 宣言**を見る（`workers_dir` が宣言されているか）。CLAUDE.md は
コンテキストに読み込まれているので、その値を使う。**スキルは配下の場所を持たない**（正本は宣言側）。

- **宣言が無い** → **supervisor 文脈ではない。何もしない**（ワーカーとして [[memory-bank]] を使う）。
- **`workers_dir` がある** → その**ディレクトリ配下の各エントリ**（symlink または実サブプロジェクト）を配下と
  する。各ワーカーの `.work/skills/memory-bank/`（`activeContext.md` / `progress.md`）を読んで状態を把握する。

### 宣言（CLAUDE.md が正本）

supervisor か否か・配下の場所は **プロジェクトの CLAUDE.md** で宣言する。

````markdown
## supervisor 宣言
- workers_dir: <配下ワーカーを束ねるディレクトリ>
````

配下は `workers_dir` の中に各ワーカープロジェクトを置く。**置き方は問わない** —— `git clone` / git submodule /
symlink（エイリアス）/ 実ディレクトリ のいずれでもよい。supervisor は `workers_dir` のエントリを列挙するだけ。

```
<workers_dir>/<name>      # clone / submodule / symlink / 実ディレクトリ のいずれか
```

- ワーカーは**別リポジトリ**であることが多いので、`workers_dir` は supervisor リポジトリでは **gitignore する**
  のが基本（中身を親に取り込まない）。submodule で管理する場合のみ例外。
- **宣言しないと動かない**＝CLAUDE.md に `workers_dir` を与えたプロジェクトだけが supervisor（暴発しない）。
- ワーカーを `<workers_dir>/<name>` 経由（cwd が `…/<workers_dir>/<name>`）で起動すると、その worker は構造から
  「自分は配下」と気づける（[[memory-bank]] の上りエスカレ）。実パスで直接起動した worker は親を知らない＝standalone。

## コアワークフロー

```
Start → workers_dir 宣言の判定 → 自分の interrupt を取り込み（ワーカーからのエスカレ）
     → 各ワーカーの状態を把握 → 俯瞰計画 → 優先度を確定 → 指示を配信 → 記録
```

1. **エスカレ受信** — 自分の `.work/skills/memory-bank/interrupt/` を [[memory-bank]] の規約で取り込む。
   `from`/`role: worker` のものはワーカーからの上り。
2. **状態把握** — 配下各ワーカーの memory-bank を読む（何が進行中か／詰まっているか）。
3. **俯瞰計画** — 配下横断で何を進めるか決める。**優先度は supervisor が確定**（下記）。
4. **配信（下り）** — 指示は対象ワーカーの **`<worker>/.work/skills/memory-bank/interrupt/`** にメッセージを
   1 ファイル投函（非同期。ワーカーは次回起動時に取り込む）。即時に動かしたいときだけ、worker dir を指定して
   サブエージェントを起動する（同期）。
5. **境界** — 触れてよいのは **`workers_dir` 配下のワーカーのみ**。それ以外の外部プロジェクトには手を出さない。

## 優先度の判断（supervisor の役割）

要求側（ワーカー／人間）は priority を**要望**できるが、**実効優先度を決めるのは supervisor**。目安:

- **高**: すぐ実装でき・悪影響が小さく・効果が高いもの。／**ワーカーへの指示**（ワーカーの手を前に進める）。
- **低**: 要件が不十分で輪郭がぼやけているもの（まず明確化が必要。寝かせる）。
- **頻度を絞る**: **supervisor 自身のスキル／config の更新ばかりに偏らない**。最優先は**ワーカーの作業前進**で、
  メタ作業（自分の足回り磨き）でワーカーを止めない。メタ改善は溜めて間引いて入れる。

> 原則: supervisor は「自分を磨く」より「配下を進める」。横断判断と配信に徹し、実装はワーカーに委ねる。

## 配信メッセージ書式（下り：supervisor → worker）

ワーカーの interrupt に置くファイル。ファイル名は**推奨**で `YYYYMMDDHHMMSS-<slug>.md`（[[memory-bank]] の
取り込み順＝辞書順に乗る）。中身:

````markdown
---
from: <supervisor-repo 名>
role: supervisor
type: instruction        # instruction(指示) | info(共有)
priority: high           # high | normal | low（supervisor が確定した実効優先度）
date: <yyyy-mm-dd>
---

## 指示
<やってほしいこと。1 件 1 ファイル>

## 背景 / 受け入れ条件
<なぜ / 完了の判定>
````

## 注意

- CLAUDE.md に `workers_dir` 宣言が無ければ**何もしない**（ワーカー単体で誤って supervisor 化しない）。
- 配下以外には触れない。指示は原則 interrupt 投函（非同期・疎結合）。同期実行は明示時のみ。
- ワーカーの中身の作り込みは [[memory-bank]] に従ってワーカー側で行う。supervisor は俯瞰と配信に集中。
