# GitHub 專用 AI 指令 Prompt 集

（AI Prompts for Documentation in systemlead-docs）

> 本文件提供在 GitHub（Copilot / Copilot Chat / Editor）中
> 使用 AI 生成或修正文件時的**標準指令 Prompt**。
>
> 目的：
> **確保 AI 產出符合本 Repo 的治理原則、SSOT 定義與文件風格。**

---

## 使用前必讀（很重要）

在使用以下任何 Prompt 前，請確認：

- 你正在編輯 `.md` 文件
- 本 Repo 的治理原則已建立：

  - `docs/governance/ai-usage.md`
  - `CONTRIBUTING.md`
  - `docs/templates/document-header.md`

👉 **AI 僅為輔助者，最終內容仍需人工 Review。**

---

## Prompt 0｜新文件起手式（強烈建議每次用）

> 🎯 用途：建立「一開始就合規」的文件

```text
請依照本 Repository 的文件治理原則產生內容：

1. 文件必須在最上方加入「文件標註（非 SSOT）」區塊
2. 文件性質為：非 SSOT（說明文件）
3. 文件中若提及規則或行為，請標註需回溯至 OpenAPI / Rules / Errors
4. 請避免使用可能被誤解為正式規則的語氣
```

---

## Prompt 1｜補齊或改寫說明文件（最常用）

> 🎯 用途：補說明、不改規則

```text
請在「不改變任何規則語意」的前提下，
將下列內容改寫為清楚的說明文件語氣：

- 本文件為非 SSOT
- 僅作為輔助理解
- 所有行為仍以對應的 OpenAPI / Rules / Errors 為準
```

---

## Prompt 2｜將規則轉為白話說明（安全版本）

> 🎯 用途：客服、教學文件

```text
請將下列規則內容轉換為白話說明，
但請遵守以下限制：

- 不新增任何條件
- 不推論未明確定義的行為
- 不使用「系統一定會」「正式規定」等語句
- 明確標註此段為非 SSOT 說明
```

---

## Prompt 3｜檢查文件是否有「被誤當 SSOT」的風險（Reviewer 用）

> 🎯 用途：審核 AI / 人寫的文件

```text
請檢查此文件是否存在以下風險：

1. 語氣可能被誤解為正式規則（SSOT）
2. 使用絕對性或法律效果語句
3. 未明確標註為非 SSOT
4. 規則描述未指向 OpenAPI / Rules / Errors

請指出具體段落並給出修正建議。
```

---

## Prompt 4｜PR 審核用（搭配 Copilot Chat）

> 🎯 用途：Pull Request Review

```text
請以 Reviewer 角度檢查本 PR：

- 是否清楚區分 SSOT 與非 SSOT
- 是否存在 AI 推論或語意偏移
- 是否符合 docs/governance/ai-usage.md
- 是否適合合併至 main

請列出風險與建議。
```

---

## Prompt 5｜重構文件結構（不動內容）

> 🎯 用途：整理老文件

```text
請在不改變任何內容語意的前提下，
協助重構此文件的結構，包括：

- 標題層級
- 段落順序
- 條列清晰度

請勿新增或刪除規則性描述。
```

---

## 建議使用方式（實務）

- ✍ 編輯文件時：用 Prompt 0 + Prompt 1
- 🧑‍💻 客服 / 教學文件：Prompt 2
- 👀 Review / 審核：Prompt 3、Prompt 4
- 🧹 技術債整理：Prompt 5

---

## 最後提醒（治理核心）

> **AI 產出的是草稿，
> Repo 中存在的內容，才是責任。**
