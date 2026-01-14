# 文件治理與 Metadata Routing 規範

> 本文件為 **Systemlead（矽聯科技）產品文件庫的治理入口頁**，
> 用於統一說明「文件治理標準」、「Metadata Routing 規範」以及「AI 文件檢索與引用治理原則」，
> 作為 **人員、工程師與 AI 系統** 共同遵循的唯一依據。
> 本專案之 AI 使用，請參考 ai-usage.md

---

## 一、文件治理標準（Document Governance）

### 1. 治理目標

文件治理的核心目標為：

* 建立 **單一可信文件來源（Single Source of Truth, SSOT）**
* 避免文件重複、衝突與版本混亂
* 確保文件可同時被「人類」與「AI 系統」正確理解與使用
* 支援產品長期演進、模組擴充、API 文件一致化與 **AI 文件檢索（RAG）** 導入
* 確保 AI 回答具備 **可追溯性、可稽核性與可控性**

---

### 2. 文件角色與責任分工

| 文件類型          | 主要目的               | 是否可定義事實 / 規則 | 治理定位     |
| ------------- | ------------------ | ------------ | -------- |
| OpenAPI 規格    | 定義 API 欄位、型別、必填、行為 | ✅ 是          | **SSOT** |
| 規則文件（Rules）   | 定義業務邏輯與判斷條件        | ✅ 是          | **SSOT** |
| 錯誤碼文件（Errors） | 定義錯誤代碼與意義          | ✅ 是          | **SSOT** |
| API 說明文件      | 教工程師如何呼叫           | ❌ 否          | 說明文件     |
| 操作手冊（Manual）  | 教使用者如何操作系統         | ❌ 否          | 說明文件     |
| 情境 SOP        | 說明情境與流程選擇          | ❌ 否          | 輔助決策     |
| 知識庫（KB）       | FAQ、原因說明、問題排除      | ❌ 否          | 輔助說明     |
| Release / 公告  | 說明變更、影響與時程         | ❌ 否          | 資訊通知     |
| AI 治理 / 架構文件  | 定義 AI 檢索、引用與稽核規則   | ❌ 否          | **治理文件** |

👉 **只有 OpenAPI / Rules / Errors 可以成為「事實與規則來源（SSOT）」。**
👉 其他文件 **不得推翻、補定或推測 SSOT 行為**。

---

### 3. 標準目錄結構（正式）

```text
docs/
├─ index.md                  # 對外入口（人 / AI）
├─ modules/                  # 各產品模組文件
│  └─ {product}/
├─ openapi/                  # API 單一事實來源（SSOT）
├─ rules/                    # 業務規則（SSOT）
├─ errors/                   # 錯誤碼定義（SSOT）
├─ release/                  # 發佈與公告
└─ governance/               # 文件與 AI 治理
   ├─ index.md               # 治理入口（本文件）
   ├─ metadata-routing.md    # Metadata Routing 規範
   ├─ ai-usage.md            # AI 使用與回答原則
   └─ ai-document-retrieval-architecture.md
```

* 新產品一律新增於 `modules/{product}/`
* **不得** 為單一產品或專案另建獨立文件 Repo
* 治理、AI 架構與跨模組規範 **一律集中於 `governance/`**

---

### 4. 文件新增與改版基本原則

* 一份文件只解決「一個明確目的」
* 不混用文件角色（SSOT ≠ 說明文件）
* 一次 Commit 對應一種文件目的
* 規格或邏輯變更：**一定先修改 SSOT**（OpenAPI / Rules / Errors）
* 說明文件、Manual、KB **不得補定未在 SSOT 定義的行為**
* 本專案之 AI 使用，請參考 ai-usage.md

---

## 二、Metadata Routing 規範

### 1. 為什麼需要 Metadata Routing

Metadata Routing 用於：

* 協助人類與 AI 判斷文件角色與可信層級
* 支援自動化文件分類、檢索與治理檢查
* 作為 AI 文件檢索與 RAG 系統的 **前置判斷依據**
* 避免文件被誤放、誤用或錯誤引用

---

### 2. 標準 Metadata 欄位（概念模型）

| 欄位          | 說明                                                                              |
| ----------- | ------------------------------------------------------------------------------- |
| docType     | 文件類型（openapi / rules / errors / api / manual / sop / kb / release / governance） |
| product     | 所屬產品模組（einv / mcr / 其他）                                                         |
| audience    | 主要讀者（developer / merchant / cs / ops / public）                                  |
| status      | 文件狀態（draft / reviewed / approved / deprecated）                                  |
| title       | 文件標題                                                                            |
| filePath    | 建議存放路徑                                                                          |
| relatedSSOT | 引用的 OpenAPI / Rule / Error                                                      |

---

### 3. docType 判斷原則（簡表）

| 內容特徵                         | docType    |
| ---------------------------- | ---------- |
| endpoint / schema / response | openapi    |
| 條件 / 判斷 / 規則                 | rules      |
| errorCode / message          | errors     |
| 呼叫方式 / 範例                    | api        |
| 操作畫面 / 點擊步驟                  | manual     |
| 情境 / 流程 / 選擇建議               | sop        |
| 為什麼 / FAQ / 問題排除             | kb         |
| 新功能 / 改版 / 停機                | release    |
| 治理 / 架構 / AI 規範              | governance |

---

### 4. Routing 標準流程

1. 判斷文件主要用途（docType）
2. 判斷所屬產品模組（product）
3. 判斷治理層級（是否為 SSOT / governance）
4. 建議正確存放路徑（filePath）
5. 確認是否需引用 SSOT
6. **完成 Routing 後，才可產生或提交正文**

👉 **未完成 Routing，不得產生正式文件內容。**

---

## 三、AI 文件檢索與使用治理（摘要）

### 1. AI 可以：

* 依本治理規範判斷文件可信層級
* 僅以 SSOT 文件作為事實與規則來源
* 透過文件檢索架構查詢「最新且核准」的文件內容
* 回答時附帶來源路徑與版本依據

### 2. AI 不可以：

* 自行新增、修改或推測 SSOT 規則
* 在 SSOT 缺失時自行補定行為
* 混用說明文件作為事實依據
* 未經治理層允許直接讀取非公開文件

👉 AI 的檢索、引用與回答行為，**須遵循《ai-document-retrieval-architecture.md》定義之架構與稽核原則**。

---

## 四、延伸治理文件

* `governance/metadata-routing.md`
* `governance/ai-usage.md`
* `governance/ai-document-retrieval-architecture.md`
* OpenAPI 規格（`docs/openapi/`）
* 規則文件（`docs/rules/`）
* 錯誤碼文件（`docs/errors/`）



---

> 本文件為治理入口頁。
>
> 所有治理規範僅允許 **新增版本文件**，不得覆寫既有治理文件，
> 以確保文件治理、AI 行為與產品規格具備完整的演進與稽核紀錄。
