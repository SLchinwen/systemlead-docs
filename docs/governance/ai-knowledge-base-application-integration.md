---
product: company
docType: governance
module: governance
title: AI 知識庫與應用程式串接指南
slug: ai-knowledge-base-application-integration
version: v1.0
effectiveDate: 2026-02-01
audience:
  - developer
  - product
  - ops
tags:
  - AI
  - 知識庫
  - 串接
  - RAG
  - 應用程式
---

# AI 知識庫與應用程式串接指南

> **文件性質：治理／實作指引**  
> 治理建立後，如何將本 Repo 的**文件與結構化資料**串接至你的應用程式與 AI 知識庫（GPTs／客服機器人／內部系統）。  
> 檢索架構與稽核原則仍以 [AI 文件檢索架構](./ai-document-retrieval-architecture.md) 為準。

---

## 1. 串接方式總覽

| 方式 | 適用情境 | 資料來源 | 應用程式怎麼用 |
|------|----------|----------|----------------|
| **A. RAG／檢索 API** | 問答、客服、說明文查詢 | Markdown 文件（chunk + 向量／關鍵字） | 呼叫 `/search` 或 `/doc`，把結果當 context 給 LLM |
| **B. 結構化資料直接讀取** | 定價計算、產品代碼、API 規格 | YAML／OpenAPI／Rules 等 | 從 Repo 取得檔案或透過你提供的 API 讀取，程式內依規則計算／驗證 |
| **C. 混合** | 既有報價試算又有 Q&A | A + B | 定價用 B（pricing-tiers.yaml + 公式）；說明、FAQ、SOP 用 A |

以下分別說明 A、B，再給「定價治理」的具體串接範例（B + 公式）。

---

## 2. 方式 A：RAG／檢索 API 串接（AI 問答用）

### 2.1 架構位置

- 完整架構與 API 規格：見 [AI 文件檢索架構](./ai-document-retrieval-architecture.md)。
- 你的應用程式（或 Custom GPT）**不直接讀 Repo**，而是呼叫你部署的 **Retrieval API**，由 API 查詢索引後回傳文件片段。

### 2.2 應用程式要做的事

1. **部署檢索層**（若尚未有）  
   - Ingestion：GitHub Webhook 或定時同步 `docs/`（含 pricing、modules、rules、openapi 等）。  
   - Index：Markdown chunk 化 + 關鍵字（BM25）或再加上向量（embedding），寫入 Azure AI Search／Elasticsearch／pgvector。  
   - Retrieval API：提供 `POST /search`、`GET /doc`（規格見檢索架構文件）。

2. **應用程式呼叫方式**  
   - 使用者問「訂單版和發票版差在哪？」→ 應用程式帶 query 呼叫 `POST /search`（可加 `filters.module=einv`、`preferSsot=true`）。  
   - API 回傳 topK 個 chunk（含 `filePath`、`commitSha`、`content`）。  
   - 應用程式把 `content`（及可選的來源連結）當成 **context** 送給 LLM，由 LLM 生成回答；回答時可附「依據 docs/…」以符合治理。

3. **治理一致**  
   - 檢索時 SSOT 優先（openapi > rules > errors > modules）。  
   - 對外 GPT 僅查 `audience=public`、`status=approved`（若你有做 metadata 過濾）。

### 2.3 定價／治理文件是否要進 RAG？

- **要**：若你希望 AI 回答「為何用年度張數計費？」「訂單版和發票版報價差在哪？」等，應把 `docs/pricing/`、`docs/governance/` 一併納入 Ingestion，讓檢索能搜到這些段落。  
- **不要混用**：定價「計算結果」（例如輸入 240 千張 → 20,000 元）建議用**方式 B** 由程式依 YAML + 公式計算，不要只靠 RAG 背數字，以免錨點更新後回答過期。

---

## 3. 方式 B：結構化資料直接串接（定價、產品代碼、API 規格）

### 3.1 適用內容

- **定價級距與產品代碼**：`docs/pricing/pricing-tiers.yaml`（錨點、產品 id／name）。  
- **級距公式**：邏輯見 `docs/pricing/pricing-tier-formula.md`（分段線性內插）。  
- **OpenAPI**：`docs/openapi/openapi.yaml`。  
- **Rules**：`docs/rules/` 下各規則文件（若你要做規則引擎或驗證）。

### 3.2 應用程式如何取得資料

| 做法 | 說明 | 優點 | 注意 |
|------|------|------|------|
| **B1. 從 Repo 直接讀** | 建置／部署時 clone 或 fetch repo，或從 CI 產物複製 `docs/pricing/pricing-tiers.yaml` 等 | 簡單、無額外服務 | 需有更新流程（重建／重拉） |
| **B2. 從你提供的 API 讀** | 後端有一支 API（例如 `GET /config/pricing-tiers`）從 Repo 或從已同步的 DB/Blob 讀 YAML 並回傳 | 應用程式只依賴 API，可做快取、版控 | 需實作同步（Webhook/定時）與 API |
| **B3. 從 GitHub Raw / 發佈物讀** | 應用程式請求 `https://raw.githubusercontent.com/.../pricing-tiers.yaml` 或從 Release 附件讀 | 永遠讀指定 branch/tag | 需處理網路與權限；對外若私有 Repo 需 token |

### 3.3 定價計算串接（B 的具體範例）

1. **取得 YAML**  
   - 用 B1／B2／B3 之一取得 `pricing-tiers.yaml` 內容。

2. **解析產品與錨點**  
   - 使用你語言可用的 YAML 解析器（如 .NET `YamlDotNet`、Node `yaml`、Python `PyYAML`）。  
   - 讀取 `products`（產品 id、name、shortDesc）與 `tierAnchors[plan_order]`（或 plan_invoice 等）的 `anchors` 陣列。

3. **依公式算出年費**  
   - 輸入：`x = 張數 / 1000`（千張）。  
   - 將 `anchors` 依 `sheets_k` 排序，找到 x 所在區間 `[a.sheets_k, b.sheets_k]`。  
   - 若 `x ≤ 最小 sheets_k` → fee = 最小錨點之 fee；若 `x ≥ 最大 sheets_k` → fee = 最大錨點之 fee；否則：  
     `fee = a.fee + (b.fee - a.fee) * (x - a.sheets_k) / (b.sheets_k - a.sheets_k)`。  
   - 回傳 fee 給前端或報價單。

4. **產品名稱顯示**  
   - 報價表單／下拉選單的「方案」選項，用 `pricing-tiers.yaml` 的 `products.*.id` 與 `name` 一致顯示，避免與文件不同步。

5. **更新策略**  
   - Repo 更新 YAML 後，若用 B1：重新建置／部署或拉檔；若用 B2：Ingestion 同步到你的儲存體，API 回傳最新；若用 B3：下次請求即為最新（或加 short cache）。

---

## 4. 混合使用建議（定價 + AI 知識庫）

- **定價試算、報價單、產品代碼**：一律用 **方式 B**（讀 `pricing-tiers.yaml` + 級距公式），保證數字與 Repo 錨點一致、易維護。  
- **「為何這樣計費？」「續約怎麼操作？」「訂單版發票版差別？」**：用 **方式 A**（RAG／檢索 API）查 `docs/pricing/`、`docs/modules/einv/` 等，把檢索結果當 context 給 LLM。  
- **治理**：AI 回答時仍遵守 [AI 使用治理原則](./ai-usage.md)：不以說明文件取代 SSOT；定價數字以 YAML + 公式為準，不在 RAG 裡背具體金額。

---

## 5. 檢查清單（串接前後）

| 項目 | 說明 |
|------|------|
| Repo 已建立治理 | 文件有 SSOT、定價有 YAML + 公式說明 |
| 決定用 A / B / 混合 | 問答用 A、定價用 B、其他依情境 |
| 若用 A | 部署 Ingestion + Index + Retrieval API；應用程式呼叫 /search、/doc；SSOT 與 audience 過濾 |
| 若用 B（定價） | 取得 pricing-tiers.yaml；實作分段線性公式；產品 id/name 與表單一致 |
| 更新流程 | Repo 改 YAML 或文件後，檢索索引／API 或建置流程要能更新 |
| 稽核（若需要） | 依檢索架構記錄 query、chunk、commitSha，以便追溯 |

---

## 6. 相關文件

- [AI 文件檢索架構](./ai-document-retrieval-architecture.md)：檢索 API、Ingestion、索引、審計  
- [AI 使用治理原則](./ai-usage.md)：AI 回答與 SSOT 規範  
- [定價級距公式與維護](../pricing/pricing-tier-formula.md)：輸入千張算出年費  
- [級距與產品代碼資料 (pricing-tiers.yaml)](../pricing/pricing-tiers.yaml)：產品命名與錨點單一來源  
