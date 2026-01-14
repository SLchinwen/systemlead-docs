---
product: einv
docType: api
module: index
audience: [dev, integrator]
version: v1.0
effectiveDate: 2026-01-14
sourceOfTruth: [rules/rule-catalog, errors/error-catalog, openapi/openapi]
tags: [api, integration, einv, systemlead]
menuPath: ["EINV", "API"]
---

# API 說明（e首發票 EINV）｜矽聯科技（Systemlead）

本頁為 **e首發票（EINV）API 串接**入口，提供工程師與系統整合商快速定位所需文件、規格與測試方式。  
所有 API 行為與欄位定義以 **OpenAPI（SSOT）** 為準；規則與錯誤處理請以 **Rule / Error Catalog（SSOT）** 為準。

---

## 🔷 快速開始（建議閱讀順序）

1. **確認共通規範**
   - 驗證 / 授權方式（API Key / 簽章規範，若適用）
   - 時區與日期欄位格式
   - 冪等鍵（idempotency）與重試策略

2. **選擇你的整合情境**
   - 電商平台（Shopify / WooCommerce / 蝦皮等）
   - ERP / POS
   - 排程批次開立

3. **依功能呼叫 API**
   - 開立發票（Create）
   - 作廢發票（Cancel）
   - 折讓（Allowance）
   - 查詢（Query）

4. **用測試資料驗證**
   - Postman / Sandbox 測試資料（如有）
   - 針對錯誤碼與例外情境做回歸測試

---

## 🔷 核心文件（SSOT / 必讀）

- 🔌 **OpenAPI 規格（SSOT）**  
  - [OpenAPI 索引（跨模組）](../../../openapi/index.md)

- 📜 **系統規則（SSOT）**  
  - [Rule Catalog（跨模組）](../../../rules/rule-catalog.md)

- ⚠️ **錯誤碼與處理建議（SSOT）**  
  - [Error Catalog（跨模組）](../../../errors/error-catalog.md)

- 🧭 **文件治理與 routing 規格（AI/GPTs）**  
  - [Metadata Routing 規格](../../../governance/metadata-routing.md)

---

## 🔷 功能 API 文件（模組內）

> 以下為 e首發票常用功能 API 文件入口（請依你實際開放端點與命名補齊 / 調整）。

- [開立發票（Create Invoice）](./invoice/create.md)
- [作廢發票（Cancel Invoice）](./invoice/cancel.md)
- [發票折讓（Allowance）](./invoice/allowance.md)
- [發票查詢（Query）](./invoice/query.md)

---

## 🔷 整合建議（工程實務）

### 1) 冪等鍵與重試策略
- 對外系統需提供可追蹤的 **冪等鍵**（例如：訂單號 / 交易號）
- 以「重試可安全」為原則設計，避免重複開立或狀態不一致

### 2) 錯誤處理
- 先依 HTTP Status 判斷類型（4xx / 5xx）
- 再依 Error Catalog 的錯誤碼與建議處理
- 對「可重試」與「不可重試」錯誤做分流

### 3) 上傳時限與排程
- 若涉及上傳期限或跨系統排程，請在 SOP 文件中建立標準流程  
- 並於 API 文件中註明「時間相關欄位」與「例外處理」策略

---

## 🔷 測試與驗證（建議最低標準）

- ✅ 最小成功案例（Happy Path）可完成端到端流程
- ✅ 至少覆蓋 3 種例外情境（參數錯誤 / 重複送出 / 上游狀態不一致）
- ✅ 針對錯誤碼建立對照表與處理策略
- ✅ 重要路徑具備可追蹤的 requestId / correlationId（若系統支援）

---

## 🔷 我不確定該看哪一份文件？

- 我只想「快速把發票開出去」  
  → 先看 **開立發票 API** + **最小成功範例**

- 我需要「正式規格與欄位定義」  
  → 以 **OpenAPI（SSOT）** 為準

- 我遇到錯誤或開立失敗  
  → 先查 **Error Catalog**，再對照對應 **Rule Catalog**

