# 設計アイデア: スキル/プロジェクト分類の直交ファセット体系（未確定・探索）

> M008 の俯瞰展開。**確定設計ではなくアイデア集**。開発現場の慣習（`env: prod/stg/dev`、`team: app/infra`、
> `role: …`）に倣い、分類を**単一の prefix に押し込まず複数の直交ファセット**として体系化する。
> 結論を急がず、軸の抽出と carrier（載せ場所）の判断基準を残すのが目的。

## 出発点（なぜ）
現 `role-` が「調整位置（sup/worker）」と「機能領域（app/infra）」を混在（M008）。開発体系では分類は
**複数の直交した軸（ファセット）**で表すのが普通＝env・team・role… が別々の名前空間。これに倣う。

## 中核原則（3 つ）
1. **1 次元 1 軸**（混ぜない）。違和感の正体は軸の混在。
2. **各軸を正しい carrier に載せる**。carrier は 3 種:
   - **prefix**（スキル名の階層）… スキル依存グラフの**骨格**＝抽象度・依存方向だけ。
   - **metadata**（OKF frontmatter の `type`/`tags`/専用キー）… **主題・属性**（多値・横断）。
   - **declaration / config**（CLAUDE.md・`workers_dir` 等）… **構造・文脈で決まり本人が選ばない**もの。
3. **prefix は安売りしない**。prefix が増えるほど名前が汚れリネーム耐性も落ちる。骨格（抽象度）以外は
   metadata か declaration へ逃がす（M005 の OKF 基盤がちょうど受け皿）。

## 抽出した直交ファセット（俯瞰）

| ファセット | 例 | 性質 | 推奨 carrier | メモ |
|---|---|---|---|---|
| **抽象度/依存 (level)** | role / flow / unit / func | 体系の骨格・上→下依存 | **prefix** | 既存。ただし最上位名 "role" が調整軸と紛らわしい→改名検討 |
| **調整/権限 (coordination)** | supervisor / worker | 垂直・org 関係・権限の向き | **declaration**（`workers_dir` で構造決定済み） | "役割"の一種だが**選ぶものでなく構造で決まる**＝config が正解 |
| **機能/領域 (team/domain)** | app / infra / data / ML / security / QA / platform | 水平・主題 | **metadata (tags)** | 開発現場の team 概念。1 つが複数持てる（app かつ security） |
| **環境/段階 (env)** | prod / stg / dev / local / CI / sandbox | 実行文脈・リスク水準 | **declaration / context** | スキル属性でなく**適用文脈**。リスク操作のガード条件に使える |
| **ライフサイクル (phase)** | plan / design / build / test / release / operate | 時間・工程 | **flow 内で表現** | 一部内在済み（deep think=plan/最終点検、開発内ループ） |
| **成熟度 (maturity)** | experimental / stable / deprecated | 状態 | **metadata (tag/status)** | スキルの信頼度・撤去判断 |
| **適用範囲 (scope)** | global / project / personal | 可視性・所在 | **declaration / 設置場所** | install.sh の symlink 先で部分表現済み |

## carrier 判定基準（なぜそこに載るか）
- **prefix** ← 「依存グラフの骨格」だけ。多軸を入れない。→ 抽象度軸のみ。
- **metadata** ← 「多値・横断・主題」。1 スキルが複数値を持てる。OKF は未知キー許容＝拡張自由（M005）。
- **declaration/config** ← 「構造・文脈で決まり本人が選ばない」もの（sup/worker は `workers_dir`、env はデプロイ文脈）。

## 命名の衝突整理
- 最上位抽象レベル "role" と調整軸 "role" が紛らわしい → **どちらかを改名**（抽象最上位を別名に／調整軸を
  `org-`・`coord-` に）。波及の小さい方を選ぶ。
- team 軸: "team"（集団）より `domain`/`discipline` が精確。**タグなら値は自由**なので `team: app` でも可。
- "function" 系は `func-`（既存）と衝突＝回避。

## 具体イメージ（1 スキルの多軸分類）
```yaml
# 名前 = prefix で抽象度だけを表す: flow-memory-bank
type: flow                      # OKF 必須＝抽象度（骨格）。M005 で導入済み
tags: [orchestration, stable]   # 機能領域 / 成熟度（横断・多値）
# 調整位置(sup/worker)・env は スキル自身が持たない
#   → 調整は CLAUDE.md の workers_dir、env は実行文脈/別 config が決める
```

## 段階導入（YAGNI）
1. **今すぐ低コスト**: 機能領域・成熟度を **OKF tags** で表すだけ（M005 の基盤に載るだけ・新 prefix 不要）。
2. **必要になったら**: env をリスクガード（境界 guard 系）と結びつけたくなった時点で declaration 化。
3. **合意後に一括**: prefix 改名（role 衝突解消）は破壊的＝最後に一度だけ。

## 未決の問い
- (a) prefix を「抽象度のみ」に純化し、他は全部 tags/config へ寄せる**最小 prefix 主義**を採るか。
- (b) 抽象度最上位の改名 vs 調整軸の改名、どちらが波及小か。
- (c) tag のキー設計: 単一 `tags:` 自由リスト vs `domain:`/`env:`/`status:` 専用キー（OKF 的に専用キー追加は自由）。
- (d) env を「スキル分類」に入れるべきか、そもそも runtime 文脈として分離すべきか（本ノートは後者寄り）。
