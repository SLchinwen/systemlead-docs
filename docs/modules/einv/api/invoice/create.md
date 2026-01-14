---
product: einv
docType: api
module: invoice
audience: [dev, integrator]
version: v1.0
effectiveDate: 2026-01-14
sourceOfTruth: [openapi/openapi, rules/rule-catalog, errors/error-catalog]
tags: [invoice, create, api, einv]
menuPath: ["EINV", "API", "Invoice", "Create"]
---

# 開立發票 API（Create Invoice）｜e首發票（EINV）

本文件說明 **e首發票（EINV）－開立發票 API** 的最小成功使用方式，
適用於工程師快速完成串接與驗證。

> 📌 **重要原則**  
> - 欄位定義、型別、限制以 **OpenAPI（SSOT）** 為準  
> - 本文件僅提供「怎麼用」與「最小成功範例」

---

## 🔷 使用時機（When to use）

- B2C / B2B 訂單完成後，需即時或排程開立電子發票
- 電商平台、ERP、POS 系統串接
- 批次或背景排程開立發票

---

## 🔷 Endpoint（摘要）

> 實際路徑與方法請以 OpenAPI 為準

- **Method**：`POST`
- **Path**：`/api/invoice/create`
- **Auth**：API Key / 簽章（依系統設定）

---

## 🔷 最小成功請求（Minimal Success Request）

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
- `BuyerIdentifier` 空白 → 視為 B2C
- 金額欄位請依稅別計算
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

| 錯誤碼 | 說明 | 建議處理 |
|---|---|---|
| E-INV-001 | 參數缺漏 | 檢查必填欄位 |
| E-INV-010 | 買受人統編錯誤 | 確認 BuyerIdentifier |
| E-INV-020 | 重複開立 | 檢查冪等鍵 / InvoiceNo |

> 完整錯誤定義請參考：
> - [Error Catalog（SSOT）](../../../errors/error-catalog.md)

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

## 🔷 相關文件

- [API 說明入口](../index.md)
- [OpenAPI 規格（SSOT）](../../../openapi/index.md)
- [系統規則（Rule Catalog）](../../../rules/rule-catalog.md)
- [情境 SOP（補開 / 例外）](../../sop/index.md)

---

> 本文件為工程師導向文件，若內容與 OpenAPI 衝突，**一律以 OpenAPI 為準**。
