---
product: shared
docType: openapi
module: core
audience: [dev, integrator, ai]
version: v1.0
effectiveDate: 2026-01-14
sourceOfTruth: []
tags: [openapi, ssot, systemlead]
menuPath: ["OpenAPI"]
---

# OpenAPI 規格中心｜矽聯科技（Systemlead）

本區提供 **矽聯科技（Systemlead）** 旗下產品與服務的 **OpenAPI 規格入口**，
作為所有 API 文件、工程實作、AI 文件產製的 **單一真相來源（SSOT）**。

> 重要說明
> - 所有 API 行為、欄位定義、型別與限制 **一律以 OpenAPI 為準**
> - API 說明文件、SOP、KB 僅能「引用」OpenAPI，不得自行定義或修改規格

---

## 適用對象

- 工程師（後端 / 前端）
- 系統整合商
- API 文件撰寫者
- GPTs / AI 客服（高權重知識來源）

---

## 目前提供的 OpenAPI 規格

### 1) e首發票（EINV）

- 規格檔：`docs/openapi/openapi.yaml`
- 相關入口：
  - [e首發票 API 說明入口](../modules/einv/api/index.md)
  - [e首發票規則：發票開立與取號（SSOT）](../rules/einv/invoice-issuance-and-numbering.md)

---

## OpenAPI 使用建議

### 1) 作為開發與驗證依據

- 開發時以 OpenAPI 定義：
  - Request / Response Schema
  - 必填欄位與格式
  - Enum / Pattern 限制
- 實作完成後，可搭配：
  - Swagger UI
  - Postman
  - 其他 OpenAPI 工具

---

### 2) 作為文件與 AI 的真相來源

- API 文件（Markdown）負責「怎麼用」，不重複定義 Schema
- GPTs / AI 以 OpenAPI 為 schema 基準，並搭配 rules / errors 進行回應

---

## 檔案管理與版本原則（建議）

- `openapi.yaml` 為主檔
- 若未來需要版本化，可採用：

```text
openapi/
├─ v1/
│  └─ openapi.yaml
├─ v2/
│  └─ openapi.yaml
└─ index.md
```

- 重大異動需同步：
  - 更新 API 說明文件
  - 發布 Release Note

---

## 與文件治理的關係

| 文件類型 | 是否可定義 API |
| --- | --- |
| OpenAPI | 可以（SSOT） |
| API 說明（Markdown） | 不可（僅說明） |
| SOP / Manual / KB | 不可（僅引用） |
| AI 回答 | 不可（需回溯 OpenAPI） |

---

> 若 OpenAPI 與其他文件內容衝突，**一律以 OpenAPI 為準**。

