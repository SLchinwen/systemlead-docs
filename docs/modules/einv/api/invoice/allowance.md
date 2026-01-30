---
product: einv
docType: api
module: invoice
audience: [dev, integrator]
version: v1.0
effectiveDate: 2026-01-14
sourceOfTruth: [openapi/openapi, rules/einv/invoice-issuance-and-numbering]
tags: [invoice, allowance, api, einv]
menuPath: ["EINV", "API", "Invoice", "Allowance"]
---

# 發票折讓 API（Allowance）｜e首發票（EINV）

本文件說明 **e首發票（EINV）－發票折讓 API** 的使用方式，
適用於已完成開立之發票，因退貨、折扣或價格調整而需依法規進行折讓處理的情境。

> 📌 **重要原則**  
> - 折讓需依原發票資料開立，不可跨發票折讓  
> - 欄位定義與檢核規則一律以 **OpenAPI / Rule Catalog（SSOT）** 為準

---

## 🔷 使用時機（When to use）

- 商品退貨（部分或全部）
- 價格調整或事後折扣
- 原發票金額需減少，且不可再作廢

> ⚠️ 折讓與作廢不可混用，請依發票狀態與時限選擇正確流程。

---

## 🔷 Endpoint（摘要）

> 實際路徑與方法請以 OpenAPI 為準

- **Method**：`POST`
- **Path**：`/api/invoice/allowance`
- **Auth**：API Key / 簽章（依系統設定）

---

## 🔷 最小成功請求（Minimal Success Request）

```json
{
  "InvoiceNumber": "AA12345678",
  "AllowanceDate": "2026-01-14",
  "AllowanceAmount": 500,
  "AllowanceTax": 25,
  "AllowanceReason": "部分退貨"
}
```

### 說明
- `InvoiceNumber`：原始發票號碼
- `AllowanceAmount`：未稅折讓金額
- `AllowanceTax`：對應稅額
- 折讓金額不得超過原發票金額

---

## 🔷 最小成功回應（Minimal Success Response）

```json
{
  "Status": "SUCCESS",
  "AllowanceNumber": "AL12345678",
  "Message": "Allowance created successfully"
}
```

---

## 🔷 常見錯誤與處理方式

| 錯誤碼 | 說明 | 建議處理 |
| --- | --- | --- |
| E-INV-040 | 發票不存在 | 確認 InvoiceNumber |
| E-INV-041 | 折讓金額超過原發票 | 檢查金額計算 |
| E-INV-042 | 發票不可折讓 | 檢查狀態與時限 |

> 完整錯誤定義請參考：
> - 錯誤碼請依 OpenAPI 與實際 API 回應為準

---

## 🔷 工程實務建議

### 1) 折讓前檢核
- 建議先查詢原發票狀態與可折讓金額
- 確保折讓項目與金額正確

### 2) 多次折讓情境
- 同一張發票可多次折讓（依系統與法規）
- 請累計折讓金額，避免超額

### 3) 與申報的關聯
- 折讓資料需納入當期或次期申報
- 建議與財務 / 會計流程同步確認

---

## 🔷 相關文件

- [API 說明入口](../index.md)
- [開立發票 API](./create.md)
- [作廢發票 API](./cancel.md)
- [OpenAPI 規格（SSOT）](../../../openapi/index.md)
- [e首發票規則：發票開立與取號](../../../rules/einv/invoice-issuance-and-numbering.md)
- [情境 SOP（退貨 / 折讓）](../../sop/index.md)

---

> 本文件為工程師導向文件，若內容與 OpenAPI 衝突，**一律以 OpenAPI 為準**。

