---
from: manystore
role: worker
type: info
priority: normal
date: 2026-06-21
---

## 気づき（メタ層・横断ルール）

**quality スキルが「発揮されない」構造的ギャップ**。再現性ある検証（Makefile 経由・ruff 版固定）は
quality スキルにすでに正本がある（`skills/quality/SKILL.md` の **R5 Makefile** / **R8 検証緑＝`make check`**）。
にもかかわらず、ワーカーの普段の作業では発揮されなかった。

### 根本原因

- quality は **ユーザー起動のオンデマンド監査スキル**（trigger: 「品質」「quality」「規約チェック」等）。
  常時回る [[memory-bank]] の作業ループからは**参照されていない**。
- memory-bank の「検証」「切りのいいところ」ステップは `techContext.md の検証コマンド` を見るだけで、
  quality の R5/R8 を参照しない。結果、repo の techContext がベタ書き `uvx ruff …` だと、ワーカーは
  毎回それを手打ちし、ruff 版や対象がブレる（＝今セッションで実際に発生。manystore で `uvx ruff check`
  を手打ち → ユーザー指摘）。
- 出典: `skills/quality/SKILL.md:36`（R5）/`:39`（R8）、`skills/memory-bank/SKILL.md:156`（検証緑の定義）。
  manystore 側の元凶 `manystore/.work/skills/memory-bank/techContext.md` の「検証コマンド」がベタ書きだった
  （worker 権限で `make` 参照に修正済み。commit は manystore agent ブランチ）。

### 提案（反映先は supervisor が判断）

1. **memory-bank → quality を構造リンク**（最有力）。memory-bank の「検証」「切りのいいところ」ステップに
   「検証は repo のタスクランナー（`make check` 等）で行う＝[[quality]] の R5/R8 に従う。ベタ書き禁止」を
   1〜2 行で追記し `[[quality]]` で links する。これで**常時ループから quality 正本が参照される**＝発揮される。
2. **techContext 雛形の「検証コマンド」例を `make check` 系に変更**（生コマンド例 `uvx ruff check` をやめる）。
   `skills/memory-bank/SKILL.md:283` の雛形。ワーカーが新規 repo を作るたびベタ書きに誘導されるのを断つ。
3. 補強案: quality 監査が repo を是正する際、techContext.md の「検証コマンド」も `make` 参照に揃える項目を
   R に含める（materialize 漏れの防止）。

> 本件は「自分（worker）の足回り」ではなく**横断ルール／メタ層**なので、worker 側で親スキルを直接編集せず
> エスカレ（ユーザー方針）。実効優先度・反映先は supervisor が確定してください。
