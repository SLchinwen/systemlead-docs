# Metadata Routing 規範
（Metadata-driven Document Routing Specification）

> 本文件定義 systemlead-docs 中所有文件所需之 **Metadata（Front-matter）規範**，
> 用於協助 **人員、Reviewer 與 AI 系統** 正確判斷文件角色、可信層級與存放路徑，
> 並作為 **AI 文件檢索（RAG）與治理自動化** 的前置依據。

---

## 一、為什麼需要 Metadata Routing

在 systemlead-docs 中：

- 文件數量會持續成長
- 文件同時會被：
  - 人類（工程師 / 客服 / 營業人）
  - AI（GPTs / 客服機器人 / Copilot）
  使用

**若缺乏結構化 Metadata，將導致以下風險：**

- 文件被誤放、誤用
- 非 SSOT 文件被誤當規則
- AI 無法判斷可信層級而產生錯誤回答
- 無法進行自動化檢查與稽核

👉 因此，本專案採用 **Metadata Routing** 作為文件治理的核心機制。

---

## 二、Metadata 的實作方式（標準）

### 2.1 實作形式

Metadata **必須** 以 YAML front-matter 的形式，
放置於 Markdown 文件最上方。

```yaml
---
docType: manual
product: einv
audience: merchant
status: reviewed
---
