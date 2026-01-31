# AI 使用治理原則（AI Usage Governance）

> 本文件定義在本 Repository 中使用 AI（人工智慧）協助撰寫、修改與維護文件與規格時的治理原則。
>
> 本治理原則的目的在於：**提升文件產出效率，同時確保事實正確性、可追溯性與責任歸屬清楚**。

---

## 1. 適用範圍（Scope）

本治理原則適用於：

- 使用 AI 工具（包含但不限於 ChatGPT、GitHub Copilot、其他生成式 AI）
- 對本 Repository 中的任何內容進行：
  - 新增文件
  - 修改文件
  - 補充說明
  - 重構文字或結構

---

## 2. AI 的角色定位（Role of AI）

在本 Repository 中，AI 的角色被明確定位為：

> **文件與說明的「輔助起草者（Drafting Assistant）」**

AI：

- ✅ 可用於產生草稿、重述內容、補齊說明、整理結構
- ❌ 不得被視為事實來源（Single Source of Truth, SSOT）
- ❌ 不得自行推論、創造或改寫規則語意

最終內容的正確性與責任，**一律由人類維護者（Maintainer / Reviewer）承擔**。

---

## 3. 事實來源定義（Single Source of Truth, SSOT）

在本 Repository 中，以下文件類型被明確定義為 **唯一事實來源（SSOT）**：

- OpenAPI 規格文件
- Rules（規則定義文件）
- Errors（錯誤碼與錯誤行為定義文件）

### SSOT 原則

- 所有系統行為、時限、欄位規則，**必須可回溯至 SSOT 文件**
- AI 產出內容 **不得凌駕、取代或隱含修改 SSOT**
- 若 AI 產出與 SSOT 不一致，**以 SSOT 為準**

---

## 4. 非 SSOT 文件（說明文件）規範

除 SSOT 以外的文件（例如說明文件、教學文件、FAQ、流程說明）均屬於：

> **非 SSOT（Non-Authoritative Documentation）**

### 非 SSOT 文件必須遵守以下規範

- 必須清楚標註「非 SSOT」
- 不得使用模糊語言暗示其為正式規則
- 若描述規則或行為，必須引用對應的 SSOT 來源

---

## 5. AI 可執行的行為（Allowed Uses）

AI 在本 Repository 中 **可以被允許用於**：

- 將 SSOT 規則轉換為白話說明（不改變語意）
- 補齊文件結構（標題、章節、條列）
- 統一用語與說明風格
- 產生 FAQ、範例說明、流程描述草稿

---

## 6. AI 禁止的行為（Disallowed Uses）

AI **不得被用於**：

- 自行新增、刪除或修改規則條件
- 推論「合理做法」並視為正式行為
- 修改 OpenAPI / Rules / Errors 而未經人工審核
- 產生未標註來源的規則性描述

---

## 7. 責任與審核原則（Responsibility & Review）

- 所有 AI 產出內容：
  - 必須可被 Review
  - 必須可被拒絕（Reject）
- Maintainer / Reviewer 對以下事項負最終責任：
  - 內容是否符合 SSOT
  - 是否存在語意偏移
  - 是否清楚標註文件性質（SSOT / 非 SSOT）

AI 不承擔任何最終決策或責任。

---

## 8. 治理原則的演進（Governance Evolution）

本文件屬於治理性文件：

- 修改頻率應低
- 任何調整應經過討論與共識
- 目的在於長期穩定，而非短期效率

---

## 9. 總結（Summary）

> **AI 是工具，不是規則來源。**  
> **治理讓 AI 成為槓桿，而不是風險。**

本治理原則的存在，是為了讓 AI 能夠被安心、可控、可長期地使用於本 Repository 中。
