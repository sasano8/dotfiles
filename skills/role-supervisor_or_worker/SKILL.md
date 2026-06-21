---
name: role-supervisor_or_worker
description: 複数のワーカープロジェクトを束ねて俯瞰計画し、各ワーカーの interrupt 受信箱へ指示を配信し、ワーカーからのエスカレーションを取り込む。supervisor として動くのは CLAUDE.md に `workers_dir` を宣言したプロジェクトのみ（無ければ何もしない＝暴発しない）。優先度は要求側の要望を踏まえつつ supervisor が確定する。ユーザーが「supervisor」「workers をまとめる」「配下に指示」「俯瞰計画」「エスカレーションを捌く」等を求めたときに使う。プロジェクト非依存。
---

# supervisor — ワーカー群の俯瞰オーケストレーション

複数のワーカープロジェクトを束ね、**俯瞰計画 → 各ワーカーへ指示配信 → ワーカーからのエスカレ取り込み**を回す
スキル。各ワーカーの中身は [[flow]] が継続を担い、supervisor は**横断の判断と配信**だけを行う。

> ロール（supervisor/worker）はアイデンティティではなく**構造と権限**で決まる。CLAUDE.md で `workers_dir` を
> 宣言したプロジェクトだけが supervisor として振る舞える（＝capability の昇格）。ワーカーは普通のプロジェクトで、
> 自分が誰の配下かを基本は知らない。

## 0. 起動時チェック（supervisor か判定）

このプロジェクトの **CLAUDE.md の supervisor 宣言**を見る（`workers_dir` が宣言されているか）。CLAUDE.md は
コンテキストに読み込まれているので、その値を使う。**スキルは配下の場所を持たない**（正本は宣言側）。

- **宣言が無い** → **supervisor 文脈ではない。何もしない**（ワーカーとして [[flow]] を使う）。
- **`workers_dir` がある** → その**ディレクトリ配下の各エントリ**（symlink または実サブプロジェクト）を配下と
  する。各ワーカーの `.work/skills/flow-memory-bank/`（`activeContext.md` / `progress.md`）を読んで状態を把握する。

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
  「自分は配下」と気づける（[[flow]] の上りエスカレ）。実パスで直接起動した worker は親を知らない＝standalone。

### worker は既定動作（per-worker の宣言は不要）

worker は**既定の振る舞い**で動く。`workers_dir` を**宣言しない**ことがそのまま「supervisor スキルは no-op ＝
自動的に worker」を意味する（昇格は `workers_dir` 宣言という構造条件だけ）。したがって **各 worker に「自分は worker」と
書く CLAUDE.md 契約は不要**——書けば正本の複製になる。worker の既定挙動は次の 3 つを**中央**が賄う:

- **役割**: `workers_dir` の不在＝自動的に worker（宣言しないことが宣言）。
- **flow**: 起動時の文脈注入が「[[flow]] を読め（無ければ initialize）」を促す＝作業/記憶のワークフロー。
- **境界**: 下記「境界の強制」のガードが越境を構造的に止める。

> per-worker に契約を配るのは正本の一元化に反する。worker 既定を明示で強めたいなら、各 worker の CLAUDE.md ではなく
> **起動時の文脈注入（フック）側に role 判定の一行**を足す（1 箇所で全 worker に効く）。

### 境界の強制（記憶でなく構造で）

上の「親の正本を直接編集しない」は口約束では守られない（記憶依存ですり抜ける。実例: worker セッションが
共有スキルの symlink 越しに親のスキル正本を書き換え、親に WIP が残った）。これは **supervisor repo 側の編集ガード**
（起動セッション単位で効く PreToolUse 等のフック）で毎回・決定論的に止めるのが正しい。満たすべき要件:

- 編集系ツールの対象を **symlink 解決**し、実体が **supervisor repo 配下**かつ起動セッションの cwd が
  **supervisor repo 自身でない**なら **deny**（worker からの越境のみ。supervisor 自身の自己編集と
  worker 内の自分のファイル編集・親正本の Read は素通し）。
- deny は「interrupt で上りエスカレ／supervisor repo の別セッションで編集」へ誘導する＝役割モデルと地続き。
- **具体の実装（スクリプト名・配線）は supervisor repo 側の関心事**としてその repo に置く。スキルは原則だけ持つ
  （汎用スキルから特定プロジェクトの実装をハード参照しない）。

### セッション境界（1 repo = 1 セッション）

**worker 作業は worker を cwd にした別セッションで起動する**。supervisor セッションの中でプロセスを保ったまま
worker に「コンテキストスイッチ」して worker の実装を進めるのは避ける。理由は構造的:

- 起動時文脈注入（SessionStart フック＝Memory Bank の読み込み促し・未コミット WIP 表面化）は
  **プロセス単位の起動イベント**で、起動時の cwd（`CLAUDE_PROJECT_DIR`）にしか効かない。1 プロセス内で
  cd しても**再発火しない**＝切替先 worker の Memory Bank/WIP は自動表面化されない。
- repo ごとに Memory Bank も `agent` ブランチも独立。1 プロセスで混ぜると「どの repo の文脈/ブランチか」が曖昧化する。

supervisor セッションの役割は**俯瞰と配信**（interrupt 投函で dispatch）であって worker の実装ではない。
代わりに **supervisor 起動時に配下 worker の状態（未コミット WIP / Memory Bank 充足）を roll-up 表示**する
（SessionStart フックが `workers_dir` 配下を走査）＝どの worker を進めるべきか一目で判断できる。
即時に worker を動かしたいときは、worker dir を指定してサブエージェントを起動する（同期・上記「配信」5 参照）。

## コアワークフロー

```
Start → workers_dir 宣言の判定 → 自分の interrupt を取り込み（ワーカーからのエスカレ）
     → 各ワーカーの状態を把握 → 俯瞰計画 → 優先度を確定 → 指示を配信 → 記録
```

1. **エスカレ受信** — 自分の `.work/skills/flow-memory-bank/interrupt/` を [[flow]] の規約で取り込む。
   `from`/`role: worker` のものはワーカーからの上り。
2. **状態把握** — 配下各ワーカーの memory-bank を読む（何が進行中か／詰まっているか）。あわせて
   **quality 取り込みの drift を軽く確認**（下記「quality 取り込みの定期チェック」）。
3. **俯瞰計画** — 配下横断で何を進めるか決める。**優先度は supervisor が確定**（下記）。
4. **配信（下り）** — 指示は対象ワーカーの **`<worker>/.work/skills/flow-memory-bank/interrupt/`** にメッセージを
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

## quality 取り込みの定期チェック（drift 監視）

[[unit-quality]] スキルは判断（あるべき姿）の正本を持つが**オンデマンドで自走しない**。**組織の品質方針**
（supervisor の memory-bank `reference/quality-policy.md`）が配下に取り込まれ続けているかは **supervisor が定期的に確認**する
（状態把握スイープの一部）。具体的には [[unit-quality]] の **R10（検証規約の取り込み）** を基準に、各 worker（と自身）の
`techContext.md`「検証コマンド」が方針を **materialize しているか**（`make check` 等・ベタ書き不在・drift 無し）を見る。

- **判断は quality に任せる**（あるべき姿は R10/R5/R8 が正本）。supervisor は「ズレているか」を検知して動かすだけ。
- **頻度**: 配下の状態把握のたびに軽く確認（毎回フル監査はしない）。ズレを見つけたら worker の interrupt に
  是正指示を投函（下り）。重い是正は worker 側で [[unit-quality]] を起動して直す。
- メタ作業に偏らない原則（上記「優先度の判断」）に従い、drift が無ければ何もしない。

## 配信メッセージ書式（下り：supervisor → worker）

ワーカーの interrupt に置くファイル。ファイル名は**推奨**で `YYYYMMDDHHMMSS-<slug>.md`（[[flow]] の
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
- ワーカーの中身の作り込みは [[flow]] に従ってワーカー側で行う。supervisor は俯瞰と配信に集中。
