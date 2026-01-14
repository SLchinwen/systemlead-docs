# 文件治理與 Metadata Routing 規範

> 本文件為 **Systemlead（矽聯科技）產品文件庫的治理入口頁**，
> 用於統一說明「文件治理標準」與「Metadata Routing 規範」，
> 作為人員、工程師與 AI 共同遵循的依據。

---

## 一、文件治理標準（Document Governance）

### 1. 治理目標

文件治理的核心目標為：

- 建立 **單一可信文件來源（Single Source of Truth, SSOT）**
- 避免文件重複、衝突與版本混亂
- 確保文件可同時被「人類」與「AI 系統」正確理解與使用
- 支援產品長期演進、模組擴充與 AI 客服導入

---

### 2. 文件角色與責任分工

| 文件類型 | 主要目的 | 是否可定義規則 |
|---|---|---|
| OpenAPI 規格 | 定義 API 欄位、型別、必填、行為 | ✅ 是（SSOT） |
| 規則文件（Rules） | 定義業務邏輯與判斷條件 | ✅ 是（SSOT） |
| 錯誤碼文件（Errors） | 定義錯誤代碼與意義 | ✅ 是（SSOT） |
| API 說明文件 | 教工程師如何呼叫 | ❌ 否 |
| 操作手冊（Manual） | 教使用者如何操作系統 | ❌ 否 |
| 情境 SOP | 說明情境與流程選擇 | ❌ 否 |
| 知識庫（KB） | 回答常見問題與原因說明 | ❌ 否 |
| Release / 公告 | 說明變更與影響 | ❌ 否 |

👉 **只有 OpenAPI / Rules / Errors 可以成為事實來源。**

---

### 3. 標準目錄結構（摘要）

```text
docs/
├─ index.md
├─ modules/
│  └─ {product}/
├─ openapi/
├─ rules/
├─ errors/
├─ release/
└─ governance/
```

- 新產品一律新增於 `modules/` 下
- 不另行建立獨立文件 Repo

---

### 4. 文件新增與改版基本原則

- 一份文件只解決「一個明確目的」
- 不混用文件類型
- 一次 Commit 對應一種文件目的
- 規格變更 **一定先改 SSOT**，再補說明文件

---

## 二、Metadata Routing 規範

### 1. 為什麼需要 Metadata Routing

Metadata Routing 用於：

- 協助 AI 與人類判斷文件類型與存放位置
- 確保文件可被自動化工具正確分類
- 避免文件被放錯目錄或混用角色

---

### 2. 標準 Metadata 欄位

所有新文件（或由 AI 產生的文件）應具備以下 Metadata（概念性）：

| 欄位 | 說明 |
|---|---|
| docType | 文件類型（api / manual / sop / kb / release） |
| product | 產品模組（einv / mrc / 其他） |
| audience | 主要讀者（developer / merchant / cs / ops） |
| title | 文件標題 |
| filePath | 建議存放路徑 |
| relatedSSOT | 引用的 OpenAPI / Rule / Error |

---

### 3. docType 判斷原則（簡表）

| 內容特徵 | docType |
|---|---|
| endpoint / request / response | api |
| 操作畫面 / 點擊步驟 | manual |
| 情境 / 流程 / 選擇建議 | sop |
| 為什麼 / 怎麼辦 / FAQ | kb |
| 新功能 / 改版 / 停機 | release |

---

### 4. Routing 流程（標準順序）

1. 判斷文件主要用途（docType）
2. 判斷所屬產品模組（product）
3. 建議正確存放目錄（filePath）
4. 確認是否需引用 SSOT
5. 產生或更新文件內容

👉 **未完成 Routing 前，不應直接產生正文。**

---

## 三、AI 使用與治理原則（摘要）

### AI 可以：

- 依本規範建議文件類型與路徑
- 產生文件初稿
- 檢查文件是否違反 SSOT

### AI 不可以：

- 自行新增或修改規則
- 推測未定義的 API 行為
- 未經人工確認直接變更 SSOT 文件

---

## 四、延伸文件

- 《產品文件庫－維護與治理標準（v1.0）》
- OpenAPI 規格文件（`docs/openapi/`）
- 規則總表（`docs/rules/`）
- 錯誤碼總表（`docs/errors/`）

---

> 本文件為治理入口頁，若有調整，請於 `docs/governance/` 下新增新版說明，
> 不覆寫既有治理文件，以保留治理演進紀錄。

