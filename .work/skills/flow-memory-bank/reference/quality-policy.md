# 組織の品質方針（quality-policy）— インスタンス上書き

> [[flow]] の **参照系 `reference/`** の品質エントリ。スキル同梱デフォルト
> （`<flow スキル>/reference/quality-policy.md`＝既定の品質 unit は [[unit-quality]]）を**この組織（この
> supervisor 配下）にどう適用するか**で上書きする（あれば本ファイルが優先）。一般的な検証方法・チェックシート・
> 規約の正本は [[unit-quality]]。本ファイルはそれを**この組織にどう適用するか**だけを書く（関心の分離）。
> [[flow]] の「切りのいいところ」での品質チェックは本方針に従う。品質以外の要件は `reference/` に別エントリで足す。

## 既定の品質 unit

**この組織でも既定どおり [[unit-quality]] を使う**（付け替えなし）。別 unit に変えるならこの行を書き換える。

## 適用

- **Python リポジトリ**: 検証は [[unit-quality]] の規約（R1〜R10）を満たし、各 repo は **`make check`**（Makefile）に
  materialize する。エージェントは生コマンド（`uvx ruff …` 等）をベタ書きせず、必ず `make` ターゲット経由で叩く
  （ツール版は Makefile で固定＝再現性）。詳細ルール・あるべき姿は [[unit-quality]] を参照（ここには再掲しない）。
- **スキル / ドキュメントの更新も品質対象**: SKILL.md やドキュメントを更新するときも [[unit-quality]] の該当チェック
  （構成・一貫性・参照の妥当性）を参照する。コードだけが品質対象ではない。

## 運用（誰がいつ確認するか）

- **判断の正本は [[unit-quality]]**（あるべき姿＝R10 ほか）。本ファイルは「この組織での適用」を宣言するだけ。
- **取り込みの drift 監視は [[role]] が定期実行**: 配下各 worker（と自身）の `techContext.md` が本方針を
  materialize し続けているか（`make check` 等・ベタ書き不在）を状態把握スイープで軽く確認し、ズレたら worker の
  interrupt に是正指示。重い是正は worker 側で [[unit-quality]] を起動して直す。

## 参照チェーン

```
flow（「切りのいい単位に達したか品質に訊く」だけ。具体名を持たない）
  └─▶ reference/quality-policy.md（本ファイル：この組織での適用＝同梱デフォルトを上書き）
        └─▶ [[unit-quality]]（一般的な検証方法・チェックシートの正本）
worker techContext（本方針を make check に materialize）
```
