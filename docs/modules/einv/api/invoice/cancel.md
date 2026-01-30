---
product: einv
docType: api
module: invoice
audience: [dev, integrator]
version: v1.0
effectiveDate: 2026-01-14
sourceOfTruth: [openapi/openapi, rules/einv/invoice-issuance-and-numbering]
tags: [invoice, cancel, api, einv]
menuPath: ["EINV", "API", "Invoice", "Cancel"]
---

# 作廢發票 API（Cancel Invoice）｜e首發票（EINV）

本文件說明 **e首發票（EINV）－作廢發票 API** 的使用方式，
適用於已成功開立、但需依法規與業務情境進行作廢處理的發票。

> 📌 **重要原則**  
> - 發票一經作廢即不可還原，請確認業務流程後再呼叫  
> - 欄位定義與檢核規則一律以 **OpenAPI / Rule Catalog（SSOT）** 為準

---

## 🔷 使用時機（When to use）

- 開立錯誤（金額、品項、買受人）且尚未完成申報
- 系統異常導致需作廢重開
- 客戶取消交易（依法需作廢）

> ⚠️ 若已超過可作廢時限，請改用「折讓」或補開流程，並參考對應 SOP。

---

## 🔷 Endpoint（摘要）

> 實際路徑與方法請以 OpenAPI 為準

- **Method**：`POST`
- **Path**：`/api/invoice/cancel`
- **Auth**：API Key / 簽章（依系統設定）

---

## 🔷 最小成功請求（Minimal Success Request）

```json
{
  "InvoiceNumber": "AA12345678",
  "CancelDate": "2026-01-14",
  "CancelReason": "開立金額錯誤"
}
```

### 說明
- `InvoiceNumber`：欲作廢之發票號碼
- `CancelReason`：依法規需提供作廢原因

---

## 🔷 最小成功回應（Minimal Success Response）

```json
{
  "Status": "SUCCESS",
  "InvoiceNumber": "AA12345678",
  "Message": "Invoice cancelled successfully"
}
```

---

## 🔷 常見錯誤與處理方式

| 錯誤碼 | 說明 | 建議處理 |
| --- | --- | --- |
| E-INV-030 | 發票不存在 | 確認 InvoiceNumber |
| E-INV-031 | 發票不可作廢 | 檢查狀態與時限 |
| E-INV-032 | 重複作廢 | 避免重送請求 |

> 完整錯誤定義請參考：
> - 錯誤碼請依 OpenAPI 與實際 API 回應為準

---

## 🔷 工程實務建議

### 1) 作廢前檢核
- 建議先透過「發票查詢 API」確認狀態
- 確認未進入申報或不可作廢狀態

### 2) 作廢後處理
- 作廢完成後，若需重開請使用新號碼
- 不可沿用原發票號

### 3) 排程與補償機制
- 排程作廢時，請記錄原始請求與回應
- 作廢失敗需有人工或自動補償流程

---

## 🔷 相關文件

- [API 說明入口](../index.md)
- [開立發票 API](./create.md)
- [OpenAPI 規格（SSOT）](../../../openapi/index.md)
- [e首發票規則：發票開立與取號](../../../rules/einv/invoice-issuance-and-numbering.md)
- [情境 SOP（作廢 / 重開）](../../sop/index.md)

---

> 本文件為工程師導向文件，若內容與 OpenAPI 衝突，**一律以 OpenAPI 為準**。

