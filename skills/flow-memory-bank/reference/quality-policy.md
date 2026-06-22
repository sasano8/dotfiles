# 品質方針（quality-policy）— スキル同梱デフォルト

> [[flow]] の **参照系 `reference/`** の既定エントリ（スキル同梱）。flow は「切りのいい自己完結した
> 単位に達したか」を**品質に訊く**だけで、規約も具体の品質 unit 名も持たない。**どの品質 unit を既定に
> 使うかを指定するのが本ファイル**＝付け替え点。組織で特化・上書きしたいときはインスタンス側
> `.work/skills/flow-memory-bank/reference/quality-policy.md` に同名で置く（あればそちらが優先）。

## 既定の品質 unit

**既定: [[unit-quality]]**（一般的な検証方法・チェックシート・規約の正本）。flow の自己点検と
「切りのいいところ」での品質チェックはこの unit に従う。別の品質 unit へ付け替えるなら**本行を書き換える**
（または下記インスタンス側で上書きする）。

## 解決順（どの方針を使うか）

1. **インスタンス**: `.work/skills/flow-memory-bank/reference/quality-policy.md`（あれば最優先＝組織固有の適用）。
2. **スキル同梱デフォルト**: 本ファイル（既定の品質 unit = [[unit-quality]]）。

> commit 設定（`config.json` → `config.default.json` → ハードコード）と同じ解決思想。SKILL 本体は
> 具体の品質 unit 名を持たず**本参照を見るだけ**＝付け替えは参照 1 か所で済む。

## 参照チェーン

```
flow（「切りのいい単位に達したか品質に訊く」だけ。具体名を持たない）
  └─▶ reference/quality-policy.md（本ファイル：既定の品質 unit を指定）
        └─▶ [[unit-quality]]（一般的な検証方法・チェックシートの正本）
worker techContext（指定された品質 unit を make check 等に materialize）
```
