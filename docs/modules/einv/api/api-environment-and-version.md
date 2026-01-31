---
product: einv
docType: api
module: core
audience:
  - developer
  - integrator
version: v1.0
effectiveDate: 2026-01-31
sourceOfTruth: []
tags:
  - api
  - swagger
  - staging
  - 環境
---

# e首發票 API 環境與版本參考

> 本文件為 **技術規格與整合文件** 可引用之 API 環境與版本說明。  
> API 欄位與行為以 **OpenAPI（SSOT）** 為準；本文件僅說明環境、端點與引用方式。

---

## 一、API 環境一覽

| 環境 | 用途 | Swagger UI | 備註 |
| ---- | ---- | ---------- | ---- |
| **Staging** | 開發、整合測試、API 探索 | [Staging Swagger UI](https://jpe-sl-einvoice-erpapi-stage.azurewebsites.net/swagger/ui/index#/) | 非正式環境，供技術驗證 |

> 正式環境（Production）端點與 Swagger 依公司公告為準；技術規格撰寫時可引用本表並註明「以實際公告為準」。

---

## 二、文件治理對應關係

依 [doc-governance](../../../governance/doc-governance.md)：

| 來源 | 角色 | 技術規格應如何引用 |
| ---- | ---- | ------------------ |
| **OpenAPI（repo）** | SSOT：欄位、型別、必填、enum | 以 `docs/openapi/openapi.yaml` 為規格基準 |
| **Swagger UI（Staging）** | 線上探索與測試 | 引用 Staging URL 作為「可測試環境」 |
| **API 說明（Markdown）** | 說明文件，不定義規格 | 引用 OpenAPI 與 Rules，說明用法與情境 |

---

## 三、技術規格文件引用建議

撰寫技術規格、整合文件或 PRD 時，可依下列方式引用：

### 3.1 API 規格基準

```text
API 規格以 docs/openapi/openapi.yaml（OpenAPI 3.0）為準。
欄位定義、Request/Response Schema、錯誤碼請參考該檔。
```

### 3.2 測試環境

```text
Staging 環境 Swagger UI：
https://jpe-sl-einvoice-erpapi-stage.azurewebsites.net/swagger/ui/index#/

可於該頁面進行 API 探索與整合測試。
```

### 3.3 版本說明

- 本文件對應 **e首發票 API** 之 Staging 環境
- 若 Swagger 與 repo 內 OpenAPI 有差異，**以 OpenAPI 為準**；Swagger 為即時部署反映
- 重大版本異動需同步更新 OpenAPI、API 說明與 Release Note

---

## 四、相關文件

- [e首發票 API 說明總覽](./index.md)
- [OpenAPI 規格中心](../../../openapi/index.md)
- [文件治理](../../../governance/doc-governance.md)
