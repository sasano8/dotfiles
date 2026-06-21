# 組織の品質方針（quality-policy）

> [[memory-bank]] の **参照系 `reference/`** の 1 エントリ。本組織（この supervisor 配下）で
> **品質チェックをどう行うか**を定める。一般的な検証方法・チェックシートは [[quality]] スキルが正本で、
> 本ファイルはそれを**この組織にどう適用するか**だけを書く（関心の分離）。[[memory-bank]] の
> 「切りのいいところ」での品質チェックは本方針に従う。品質以外の要件は `reference/` に別エントリで足す。

## 適用

- **Python リポジトリ**: 検証は [[quality]] の規約（R1〜R10）を満たし、各 repo は **`make check`**（Makefile）に
  materialize する。エージェントは生コマンド（`uvx ruff …` 等）をベタ書きせず、必ず `make` ターゲット経由で叩く
  （ツール版は Makefile で固定＝再現性）。詳細ルール・あるべき姿は [[quality]] を参照（ここには再掲しない）。
- **スキル / ドキュメントの更新も品質対象**: SKILL.md やドキュメントを更新するときも [[quality]] の該当チェック
  （構成・一貫性・参照の妥当性）を参照する。コードだけが品質対象ではない。

## 運用（誰がいつ確認するか）

- **判断の正本は [[quality]]**（あるべき姿＝R10 ほか）。本ファイルは「この組織での適用」を宣言するだけ。
- **取り込みの drift 監視は [[supervisor]] が定期実行**: 配下各 worker（と自身）の `techContext.md` が本方針を
  materialize し続けているか（`make check` 等・ベタ書き不在）を状態把握スイープで軽く確認し、ズレたら worker の
  interrupt に是正指示。重い是正は worker 側で [[quality]] を起動して直す。

## 参照チェーン

```
memory-bank（「品質チェックを行う」だけ）
  └─▶ reference/quality-policy.md（本ファイル：この組織での適用）
        └─▶ quality スキル（一般的な検証方法・チェックシートの正本）
worker techContext（本方針を make check に materialize）
```
