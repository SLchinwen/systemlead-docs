# CONTRIBUTING

> 本文件說明本 Repository 的貢獻方式與協作原則。
> 其中 **AI 協作章節** 用於規範使用 AI 產生或修改文件、規格與說明時的行為準則。

---

## 一、貢獻基本原則

- 本 Repository 重視：
  - 正確性（Correctness）
  - 可追溯性（Traceability）
  - 可審核性（Reviewability）
- 所有貢獻內容皆需透過 Pull Request 進行
- 所有變更皆需可被 Reviewer 理解與驗證

---

## 二、AI 協作原則（重要）

### 2.1 AI 的角色定位

在本 Repository 中，AI 被定位為：

> **輔助起草與整理的工具（Drafting Assistant）**

AI 可以協助：
- 產生文件草稿
- 重述或白話化既有內容
- 整理文件結構與段落

AI **不是**：
- 事實來源（Single Source of Truth, SSOT）
- 規則制定者或決策者

最終內容正確性與責任，皆由人類貢獻者與 Reviewer 承擔。

---

## 三、事實來源（SSOT）說明

以下文件類型被定義為 **唯一事實來源（SSOT）**：

- OpenAPI 規格文件
- Rules（規則定義文件）
- Errors（錯誤碼與錯誤行為定義文件）

### 使用 SSOT 的基本要求

- 所有規則、時限、欄位行為描述，必須可回溯至 SSOT
- 若文件內容與 SSOT 不一致，**一律以 SSOT 為準**
- 禁止使用 AI 推論或補寫未存在於 SSOT 的規則

---

## 四、非 SSOT 文件（說明文件）規範

說明文件、教學文件、FAQ、流程文件皆屬於：

> **非 SSOT 文件**

貢獻者在修改或新增非 SSOT 文件時，必須：

- 明確標註「非 SSOT」
- 避免使用可能被誤解為正式規則的語句
- 引用對應的 SSOT 文件作為依據

---

## 五、使用 AI 時的具體要求

若在貢獻過程中使用 AI，請務必遵守以下要求：

- 必須於 Pull Request 中揭露有使用 AI
- 必須說明 AI 的使用範圍（草稿、重述、結構整理等）
- 不得直接合併未經人工審核的 AI 產出內容

相關檢核請參考：

- `.github/PULL_REQUEST_TEMPLATE.md`
- `docs/governance/ai-usage.md`

---

## 六、Reviewer 的審核重點

Reviewer 在審核 AI 相關 PR 時，將特別關注：

- 是否清楚區分 SSOT / 非 SSOT
- 是否存在 AI 推論或語意偏移
- 是否正確引用事實來源
- 是否符合 AI 使用治理原則

---

## 七、延伸與參考

- AI 使用治理原則：
  - `docs/governance/ai-usage.md`
- 專案治理總覽：
  - `docs/governance/index.md`

---

> **提醒：**
> 本 CONTRIBUTING 文件的目的，是讓每一位貢獻者在使用 AI 時，
> 都能在效率與治理之間取得平衡，確保專案能夠長期、穩定地演進。

