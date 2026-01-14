# Systemlead 產品服務文件庫
## 維護與治理標準（v1.0）

> 適用範圍：矽聯科技（Systemlead）旗下所有產品與服務（例如：e首發票 EINV、MRC 等）
>
> 目的：
> - 建立**單一、可長期遵循**的文件治理模式
> - 避免文件重複、衝突、版本混亂
> - 讓工程師、客服、AI、合作夥伴都能「用同一套文件」

---

## 一、核心治理原則（必讀）

### 1. Single Source of Truth（SSOT）

文件庫中，**只有三種內容可以成為事實來源**：

| 類型 | 目錄 | 說明 |
|---|---|---|
| API 規格 | `docs/openapi/` | 欄位、型別、必填、enum 的唯一來源 |
| 系統規則 | `docs/rules/` | 業務邏輯、法規、判斷條件 |
| 錯誤碼 | `docs/errors/` | 系統錯誤代碼與定義 |

👉 其他所有文件（API 說明、SOP、手冊、KB）**只能引用，不可重新定義**。

---

### 2. 文件分工原則（不混用）

| 文件類型 | 目的 | 不應包含 |
|---|---|---|
| API 說明 | 教工程師怎麼呼叫 | 規則推論、法規解釋 |
| 操作手冊 | 教使用者怎麼操作畫面 | API 欄位定義 |
| SOP | 說明情境與流程選擇 | 技術細節 |
| 知識庫（KB） | 回答「為什麼 / 怎麼辦」 | 新規則定義 |
| 公告 / Release | 說明改了什麼 | 操作細節全文 |

---

## 二、標準目錄結構（不得隨意更動）

```text
docs/
├─ index.md                # 對外唯一入口
├─ modules/                # 各產品模組
│  └─ einv/
│     ├─ index.md
│     ├─ api/
│     ├─ manual/
│     ├─ sop/
│     └─ kb/
├─ openapi/                # SSOT：API 規格
├─ rules/                  # SSOT：業務規則
├─ errors/                 # SSOT：錯誤碼
├─ release/                # 版本公告
└─ governance/             # 文件治理規範
```

👉 新產品模組一律新增於 `modules/` 下，不另開 Repo。

---

## 三、文件新增與改版流程（標準作業）

### 文件新增（所有人適用）

1. **先判斷文件類型**（API / Manual / SOP / KB / Release）
2. 確認是否需要引用：
   - OpenAPI
   - Rule Catalog
   - Error Catalog
3. 使用對應模板建立 Markdown
4. 放入正確目錄
5. Commit（一個 Commit 一種文件目的）

---
### 文件 Metadata（Front-matter）最低要求（MVP）

自 **2026-01-XX** 起，  
**所有新建立或被修改的 Markdown 文件，必須於文件最上方加入 YAML front-matter，  
以利文件治理、Metadata Routing 與 AI 正確判斷文件角色。**

最低必填欄位如下：

- `docType`：文件類型（openapi / rules / errors / api / manual / sop / kb / release / governance）
- `product`：所屬產品模組（einv / mrc / shared）
- `audience`：主要讀者（developer / merchant / cs / ops / public / internal）
- `status`：文件狀態（draft / reviewed / approved / deprecated）

#### 範例（最小可行 Front-matter）

```yaml
---
docType: manual
product: einv
audience: merchant
status: reviewed
---


### API 或欄位變更（強制順序）

1. **先更新 `openapi.yaml`**
2. 再更新 API 說明 Markdown
3. 如影響流程，補 SOP / KB
4. 最後新增 Release 說明

❗ 不可跳過第 1 步

---

## 四、版本與命名規範

### 檔名原則

- 小寫英文 + `-`
- 一檔一主題

範例：
- `create-invoice.md`
- `b2c-reissue-overdue.md`

---

### 版本說明原則

- 文件內容更新：不需版本號
- 行為或規格變更：
  - 更新 OpenAPI / Rules
  - 補 Release 文件

---

## 五、AI 與自動化使用準則

### AI 可以做的事

- 依既有規範產生新文件草稿
- 依 Metadata Routing 建議存放路徑
- 協助比對文件是否違反 SSOT

### AI 不可以做的事

- 自行新增系統規則
- 推測未定義的 API 行為
- 修改 SSOT 文件未經人工確認

---

## 六、文件品質檢核清單（Review 用）

在合併或發布前，請確認：

- [ ] 文件類型正確
- [ ] 未重複定義 OpenAPI 欄位
- [ ] 有引用對應 Rule / Error（如適用）
- [ ] 放在正確目錄
- [ ] 可被 AI 與人類理解

---

## 七、未來擴充指引

- 文件數量增加 → 啟用 GitHub Pages
- 多產品成長 → 模組化擴充
- AI 客服上線 → 以本 Repo 作為唯一知識來源

---

> 本文件為 Systemlead 產品文件治理的長期基準。
> 未來如需調整，請僅於 `docs/governance/` 下新增新版說明，不覆寫歷史規範。

