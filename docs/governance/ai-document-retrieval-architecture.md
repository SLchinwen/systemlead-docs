# systemlead-docs 文件檢索：產品級能力方案（可稽核 / 可控 / 永遠讀最新）

> 目標：讓自訂 GPT（或內部 AI 服務）**永遠以 GitHub Repo 的最新內容**為準，且具備**權限控管、審計追蹤、版本可追溯、治理可落地**。

---

## 1. 目標與非目標

### 1.1 目標
1. **永遠讀最新**：Repo 更新後，檢索層在可接受的延遲（例：1–5 分鐘）內可查到最新內容。
2. **可稽核**：每次 AI 檢索/讀取的文件片段都可回溯（Who/When/What Query/Which Chunk/Which Commit）。
3. **可控**：
   - SSOT 優先（OpenAPI / rules / errors）
   - 可限制資料範圍（特定模組、特定路徑、特定分支/Tag）
   - 可做內容安全與資料分級（對外 GPT 只看 Public/Approved）
4. **可擴充**：支援多 repo、多模組、多版本；支援 embeddings/keyword 混合檢索。
5. **可維運**：具備監控、告警、重建索引、回滾、容量規劃。

### 1.2 非目標
- 不在本階段做「內容自動改寫/自動發 PR」；本階段以**讀取與檢索**為主。

---

## 2. 高階架構（建議）

### 2.1 元件
1. **GitHub Repo**：`github.com/SLchinwen/systemlead-docs`
2. **Ingestion Service（同步/擷取）**
   - 來源：GitHub Webhook（push / PR merge / release） + 定時補償掃描（cron）
   - 功能：抓取變更檔案、解析、切分 chunk、寫入索引
3. **Index Store（檢索索引）**
   - 文字索引：Azure AI Search / Elasticsearch（BM25）
   - 向量索引：Azure AI Search Vector / pgvector（embedding）
4. **Retrieval API（文件檢索 API）**
   - 提供 `/search`、`/doc`、`/health`、`/admin/reindex`…
   - 寫入審計紀錄
5. **Policy & Governance（治理層）**
   - 路徑白名單/黑名單
   - SSOT 優先權重
   - 文件狀態（Draft/Reviewed/Approved/Deprecated）
6. **Custom GPT Actions**
   - 使用 OpenAPI schema 連接 Retrieval API

### 2.2 資料流
1. Repo 更新 → GitHub Webhook 觸發 → Ingestion 拉取變更檔
2. 解析 Markdown/OpenAPI/PDF（建議先排除 PDF 或只做 metadata）
3. Chunk 化 + 計算 embedding + 存索引
4. GPT 問答 → Actions 呼叫 `/search` → 回傳 topK chunks（含 commitSHA）
5. GPT 需要展開時呼叫 `/doc`（可限制最大字數/段落）
6. 全程寫入 audit log（可查詢與報表）

---

## 3. 治理重點（你要的「可控」核心）

### 3.1 SSOT 優先序（建議固定）
1. `docs/openapi/`（最高）
2. `docs/rules/`
3. `docs/errors/`
4. `docs/modules/`
5. 其他（blog / drafts / notes）

> 檢索排序：在同分情況下，SSOT 路徑加權；或採用兩階段：先 SSOT 搜尋，不足再擴展。

### 3.2 文件狀態（建議以 front-matter 或 metadata 檔維護）
- `status`: `draft | reviewed | approved | deprecated`
- `audience`: `internal | partner | public`
- `module`: `einv | mig | printing | ...`
- `version`: 例如 `v1.2.0`

> 對外 GPT：預設只允許 `audience=public` 且 `status=approved`。

### 3.3 版本可追溯（必做）
每個 chunk 回傳必帶：
- `repo`
- `branch/tag`
- `commitSha`
- `filePath`
- `heading`（h1/h2）
- `chunkId`（穩定 ID）

---

## 4. Retrieval API 規格（最小可行）

### 4.1 `POST /search`
**Request（建議）**
- `query`（必填）
- `topK`（預設 5–8）
- `filters`：
  - `module` / `docType` / `pathPrefix`
  - `audience` / `status`
  - `ref`（branch/tag/commit）
- `preferSsot`（預設 true）

**Response（建議）**
- `results[]`：
  - `score`
  - `content`（chunk text，建議 200–800 字）
  - `filePath`
  - `heading`
  - `commitSha`
  - `url`（對應 GitHub permalink）
  - `chunkId`

### 4.2 `GET /doc`
- 參數：`filePath`, `ref`（commitSha/branch/tag）
- 回傳：完整內容（或受控的最大長度）

### 4.3 `POST /audit/query`（可選）
- 提供稽核查詢：依人員、時間、query、filePath、commitSha 查詢

---

## 5. 審計（Audit）設計（可稽核的關鍵）

### 5.1 必記錄欄位
- `timestamp`
- `tenant/org`（若多租戶）
- `actor`（GPT/使用者/系統服務帳號）
- `requestId`（trace id）
- `endpoint`（/search /doc）
- `query`（必要時脫敏/截斷）
- `filters`
- `returnedChunks[]`（chunkId/filePath/commitSha）
- `latencyMs`、`statusCode`

### 5.2 建議能力
- 7/30/365 天保留策略（依合規要求）
- 異常偵測：短時間大量查詢、敏感路徑查詢
- 報表：Top 查詢、Top 文件、查不到（0 hit）占比

---

## 6. 安全與權限（可控的底座）

### 6.1 身份驗證
- 建議：Azure Entra ID（OAuth2 / client credentials）
- Custom GPT Actions：以 API Key 或 OAuth 方式存取（依部署環境選擇）

### 6.2 授權（Authorization）
- RBAC：`reader_public`, `reader_partner`, `reader_internal`, `admin`
- ABAC：依 `audience/status/module` 做更細的條件判斷

### 6.3 資料分級
- 路徑級別白名單：對外只允許 `docs/public/**` 或 `audience=public`
- 黑名單：`secrets/`, `.env`, `internal-notes/`

---

## 7. 同步策略（永遠讀最新的關鍵）

### 7.1 事件驅動（主）
GitHub Webhook：
- `push`（main）
- `pull_request`（merge）
- `release`（published）

Ingestion 收到事件後：
1. 取得變更檔清單
2. 針對變更檔重建 chunk & index
3. 更新「最新 commit」游標

### 7.2 定時補償（輔）
- 每 1–6 小時掃描一次 repo HEAD，避免 webhook 遺失

### 7.3 索引回滾
- 若 ingestion 失敗：保留上一版 index；以 `commitSha` 為版本切換

---

## 8. Chunk 策略（RAG 品質核心）

### 8.1 建議切分
- 以 Markdown 標題層級（H2/H3）切分，再依長度做二次切分
- chunk 長度：600–1,200 中文字（或約 1,000–2,000 tokens 的更小子集）
- 每 chunk 保留：`title/heading/breadcrumb` 作為 context

### 8.2 內容正規化
- 移除目錄噪音（TOC）
- 保留表格（可轉成 TSV/Markdown table 純文字）
- code block 原樣保留（但可限制長度）

---

## 9. 監控與維運

### 9.1 監控指標
- ingestion success/fail
- indexing latency
- search p95 latency
- 0-hit rate
- top paths queried

### 9.2 操作介面（建議）
- `/admin/reindex?ref=...`（需要 admin）
- `/admin/sync-status`（顯示最新 commit、最後同步時間）

---

## 10. 建議落地里程碑（兩週可上線版）

### Week 1
1. 建立 Retrieval API（/search /doc /health）
2. 建立 Index（先用 BM25 文字索引）
3. 建立 GitHub Webhook → Ingestion（只處理 Markdown）
4. 加入 SSOT 權重排序
5. 寫入基本 audit log（DB/Log Analytics）

### Week 2
1. 加入 embedding 向量檢索（hybrid）
2. 加入 audience/status 控制
3. 增加定時補償掃描
4. 建立 Actions OpenAPI schema 並接入 Custom GPT
5. 加上 dashboard 與告警

---

## 11. Actions OpenAPI Schema（你要我補齊的部分）

> 後續我可以依你 API 的實際 URL 與 auth 方式，生成可直接貼到 Custom GPT Actions 的 OpenAPI 3.1.0 檔。

---

## 12. 你現在 repo 建議新增兩個治理檔（強烈建議）
1. `docs/index.md`：對外入口（SSOT 優先序、文件導航、版本）
2. `docs/governance/ai-usage.md`：AI 檢索與引用規範（audience/status/SSOT）

---

## 13. 下一步我建議你立刻做的 5 件事
1. 在 repo 定義 `audience/status/module`（front-matter 或 metadata.json）
2. 定義 SSOT 路徑白名單
3. 決定部署環境（你們偏 .NET + Azure：建議 Azure App Service + Azure AI Search + Entra ID）
4. 決定對外 GPT 是否只看 `public+approved`
5. 我協助你輸出：
   - Retrieval API 的 OpenAPI
   - Actions 設定檔
   - 最小可行的 DB schema（audit/index metadata）

---

## 14. 應用程式串接（如何用到你的 App）

若你要把本 Repo 的**文件與定價資料**串接到自己的應用程式（報價試算、客服機器人、Custom GPT），請依：

- **[AI 知識庫與應用程式串接指南](./ai-knowledge-base-application-integration.md)**  
  區分 **RAG／檢索 API**（問答）、**結構化資料直接讀取**（如定價 YAML + 公式）、**混合**，並說明定價計算與產品代碼的具體串接步驟。