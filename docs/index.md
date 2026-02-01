# 矽聯科技．產品文件中心

歡迎來到 **矽聯科技．產品文件中心（Systemlead Product Documentation Hub）**。
本文件庫彙整矽聯科技股份有限公司所開發與提供之各項產品與服務，並作為 **對內營運、對外說明，以及 AI 系統（GPTs / AI 客服）** 的**唯一可信文件來源**。

本文件中心所有內容，皆依據 `docs/governance/` 所定義之治理規範維護，確保 **一致性、可追溯性、可稽核性與長期可維運性**。

---

## 🔷 文件中心提供什麼？

本文件中心包含但不限於以下內容：

- API 說明文件與 OpenAPI 規格（SSOT）
- 系統操作手冊（Manual）
- 常見營運情境與流程 SOP
- 產品知識庫（KB）與常見問題
- 新功能、改版與系統公告（Release）

👉 同時也是 **AI 客服與 GPTs 的主要知識來源**，AI 回答行為受治理文件明確約束，
**不自由推測、不補定規則、不混用文件角色**。

---

## 🔷 產品模組總覽

請依你使用的產品，選擇對應模組進入文件專區：

### 1️⃣ e首發票（EINV）

**電子發票加值服務中心**，適用於電商、POS、ERP、第三方平台與 API 串接情境。

- 👉 [進入 e首發票 文件專區](./modules/einv/index.md)
- 常見內容：
  - 電子發票 API 串接（OpenAPI / API Guide）
  - **操作手冊（Manual）**：發票開立、作廢、折讓、下載；**EC 整合**（蝦皮 API 授權、EasyStore 串接／自動開立／手動開立／作廢／再次開立）；營業人與字軌設定
  - **情境 SOP**：開立方式選擇、作廢 vs 折讓、字軌匯入判斷
  - **知識庫（KB）**：補開限制、作廢與折讓原因、字軌與不上傳說明

---

### 2️⃣ 維修雲回報（MRC / MCR）

**設備維修與派工回報系統**，支援製造、工程與維運現場之數位化管理。

- 👉 [進入 維修雲回報 文件專區](./modules/mrc/index.md)
- 常見內容：

  - 維修派工與回報 API
  - 現場操作與完工回報手冊
  - 製造 / 維修流程 SOP

> 若尚未正式啟用之模組，其文件將依治理流程逐步補齊。

---

## 🔷 共用與治理文件（所有產品適用）

以下文件為跨產品模組之共用規範，並構成 **單一真相來源（SSOT）與 AI 治理基礎**：

- 📘 [文件治理與 Metadata Routing 規範（治理入口）](./governance/index.md)
- 🧭 [Metadata Routing 規格（AI / GPTs 使用）](./governance/metadata-routing.md)
- 🤖 [AI 使用與回答治理原則](./governance/ai-usage.md)
- 🧠 [AI 文件檢索架構（可稽核 / 可控 / 永遠讀最新）](./governance/ai-document-retrieval-architecture.md)
- 🔌 [AI 知識庫與應用程式串接指南](./governance/ai-knowledge-base-application-integration.md)（如何把文件與定價串接到你的 App）
- 📜 [e首發票規則：發票開立與取號（SSOT）](./rules/einv/invoice-issuance-and-numbering.md)
- 🔌 [OpenAPI 規格總覽（SSOT）](./openapi/index.md)

👉 **僅 OpenAPI / Rules 可定義事實與系統行為**，其餘文件僅為說明與輔助。

---

## 🔷 我該從哪裡開始？

- **營業人 / 一般使用者**：
  - e首發票：[操作手冊總覽](./modules/einv/manual/index.md)（含 EC 整合：蝦皮、EasyStore）→ 依需求選「發票開立／折讓／作廢／下載」或「蝦皮授權／EasyStore 串接」
  - 不確定用哪個功能時：[情境 SOP 總覽](./modules/einv/sop/index.md)

- **工程師 / 開發者**：
  - [OpenAPI 規格總覽](./openapi/index.md) 與 [e首發票 API 說明](./modules/einv/api/index.md)

- **客服 / 顧問 / AI 訓練**：
  - [情境 SOP](./modules/einv/sop/index.md)、[知識庫（KB）](./modules/einv/kb/index.md)，並以 SSOT 文件作為最終判斷依據

---

## 🔷 文件與 AI 治理說明（重要）

- 本文件庫採 **模組化管理（modules）**，避免不同產品文件混用
- 規則（Rules）、錯誤碼（Errors）與 OpenAPI 為跨模組共用之 **單一真相來源（SSOT）**
- AI（GPTs / 客服機器人）僅能透過治理定義之文件檢索架構存取內容
- 所有文件皆可由 AI 協助產製，但 **必須經人工審核後** 才能發布或成為 AI 可引用內容

---

> 本文件中心為矽聯科技產品與服務的正式文件入口。
> 所有內容將持續依治理流程更新，並保留完整版本與演進紀錄，以支援產品長期營運與 AI 應用發展。
