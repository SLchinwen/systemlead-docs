# 開立發票 API－取號治理模式說明

> ⚠️ 本章節不定義欄位、不取代 OpenAPI，所有正式規則請以 SSOT 為準。

---

product: einv
docType: api
module: invoice
audience: [dev, integrator]
version: v1.1
effectiveDate: 2026-01-14
sourceOfTruth: [openapi/openapi, rules/einv/invoice-issuance-and-numbering]
tags: [invoice, create, api, einv]
menuPath: ["EINV", "API", "Invoice", "Create"]
----------------------------------------------

# 開立發票 API（Create Invoice）｜e首發票（EINV）

本文件說明 **e首發票（EINV）－開立發票 API** 的最小成功使用方式，
適用於工程師快速完成串接、測試與正式上線。

> 📌 **重要原則（文件治理）**
>
> - 欄位定義、型別、必填與 enum **一律以 OpenAPI（SSOT）為準**
> - 取號責任、混合使用與切本配號 **一律以 Rules（SSOT）為準**
> - 本文件僅說明「如何呼叫 API 與如何選擇使用情境」

---

## 🔷 使用時機（When to use）

- B2C / B2B 訂單完成後，需即時或排程開立電子發票
- 電商平台、ERP、POS 系統串接
- 批次或背景排程開立發票

> ⚠️ 實際採用「發票版 / 訂單版 / 機台模式」，請務必先確認取號責任歸屬。

---

## 🔷 Endpoint（摘要）

> 實際路徑、方法與驗證方式請以 OpenAPI 為準

- **Method**：`POST`
- **Path**：`/api/invoice/create`
- **Auth**：API Key / 簽章（依系統設定）

---

## 🔷 最小成功請求（Minimal Success Request）

> 範例僅示意最小可成功欄位，實際欄位請依 OpenAPI

```json
{
  "InvoiceNo": "AA12345678",
  "InvoiceDate": "2026-01-14",
  "BuyerIdentifier": "",
  "BuyerName": "王小明",
  "SalesAmount": 1000,
  "TaxType": 1,
  "TaxAmount": 50,
  "TotalAmount": 1050,
  "Items": [
    {
      "ItemName": "測試商品",
      "ItemCount": 1,
      "ItemPrice": 1000,
      "ItemAmount": 1000
    }
  ]
}
```

### 說明

- `BuyerIdentifier` 空白 → 視為 **B2C**
- B2B / B2C 金額與稅額計算方式不同，請依 OpenAPI 與 Rule 說明
- `Items` 至少 1 筆

---

## 🔷 最小成功回應（Minimal Success Response）

```json
{
  "Status": "SUCCESS",
  "InvoiceNumber": "AA12345678",
  "InvoiceDate": "2026-01-14",
  "Message": "Invoice created successfully"
}
```

---

## 🔷 常見錯誤與處理方式

| 錯誤碼       | 說明      | 建議處理               |
| --------- | ------- | ------------------ |
| E-INV-001 | 參數缺漏    | 檢查必填欄位             |
| E-INV-010 | 買受人統編錯誤 | 確認 BuyerIdentifier |
| E-INV-020 | 重複開立    | 檢查冪等鍵 / InvoiceNo  |

> 完整錯誤定義請參考：
>
> - 錯誤碼請依 OpenAPI 與實際 API 回應為準

---

## 🔷 工程實務建議

### 1) 冪等鍵（Idempotency）

- 建議使用訂單編號或交易編號
- 重送請求不應造成重複開立

### 2) 排程與補單

- 排程開立時，請保存原始訂單資料
- 失敗可重送，並比對回傳狀態

### 3) 與 SOP 搭配

- 涉及逾期、補開、重開，請搭配對應 SOP 文件

---

## 🔷 發票開立與取號治理模式（重要）

本 API 依 **取號責任歸屬**，支援下列使用模式：

- **發票版（Invoice-based）**：

  - 發票號碼由 ERP / POS 等呼叫端系統自行管理並傳入

- **訂單版（Order-based）**：

  - 發票號碼由 e首發票系統協助取號後開立

- **機台／設備簡化模式（Device-based）**：

  - 以機台號作為追蹤主體，由 e首發票協助取號

> ⚠️ API 介面相同，差異在於 **責任歸屬與治理方式**，非技術功能差異。

### 正式規則（SSOT）

- `docs/rules/einv/invoice-issuance-and-numbering.md`
- `docs/modules/einv/api/scenarios.md`

---

## 🔷 相關文件

- [API 說明入口](../index.md)
- [OpenAPI 規格（SSOT）](../../../openapi/index.md)
- [e首發票規則：發票開立與取號](../../../rules/einv/invoice-issuance-and-numbering.md)
- [情境 SOP（補開 / 例外）](../../sop/index.md)

---

> 本文件為工程師導向文件，若內容與 OpenAPI 或 Rules 衝突，**一律以 SSOT 為準**。

