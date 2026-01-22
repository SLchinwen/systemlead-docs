# 歷史發票資料拆分治理 PRD（Archive Invoice PRD）

---

## 1. 文件基本資訊

- **文件名稱**：歷史發票資料拆分治理 PRD
- **產品模組**：e首發票（EINV）
- **文件類型**：PRD（Product Requirements Document）
- **版本**：v1.0
- **適用範圍**：一年以上電子發票歷史資料
- **目標對象**：產品負責人、後端工程師、資料庫管理者、維運人員
- **生效日**：2026-01

---

## 2. 背景與問題定義

隨著電子發票資料量逐年累積，主系統資料庫面臨以下問題：

1. 查詢效能下降（單頭＋單身＋折讓多表 Join）
2. 個資保存年限與治理風險提高
3. 主系統承載過多歷史查詢與證明下載需求
4. 維運與索引重建成本持續上升

因此需導入「**歷史發票資料拆分治理（Archive）**」機制，將**超過一年之發票資料進行彙總、去個資識別化，並移轉至獨立歷史資料庫**，同時確保：

- 可查找
- 可對帳
- 可稽核
- 可下載證明

---

## 3. 目標與非目標

### 3.1 目標（Goals）

- 將一年以上發票資料自主系統拆分
- 彙總為「**單檔發票單頭資料**」
- 移除或去識別化個資欄位
- 保留稅務、狀態、金額、查詢與證明能力
- 降低主系統資料量與查詢壓力

### 3.2 非目標（Non-Goals）

- 不支援歷史資料修改（唯讀）
- 不回寫主系統狀態
- 不保留發票單身（Item）明細

---

## 4. 整體架構與資料流

### 4.1 架構概念

- **主系統（Hot DB）**：保留 1 年內完整資料（單頭＋單身＋折讓）
- **歷史系統（Archive DB）**：保留 1 年以上彙總後單檔資料
- **Object Storage**：保存歷史發票證明（PDF / HTML）

### 4.2 ETL 資料流

1. 排程掃描符合條件之發票（InvoiceDate < Today - 365）
2. 彙總單頭、單身、折讓資料
3. 進行金額與稅別一致性檢核
4. 個資去識別化
5. 寫入 Archive DB
6. 產生或搬移證明檔至 Object Storage
7. 紀錄批次處理結果

---

## 5. 資料模型設計

### 5.1 資料表：InvoiceArchiveHeader

#### A. 識別與主鍵

- SellerBan（賣方統編）
- InvoiceNo（發票號碼）
- InvoiceYear（年度 / 發票期別）
- InvoiceKey（SellerBan + InvoiceNo，Unique）
- DataVersion（資料規格版本）

#### B. 日期欄位

- InvoiceDateTime（開立日期時間）
- VoidDateTime（作廢時間）
- AllowanceDateTime（最後折讓時間）
- UploadDateTime（完成上傳/存證時間）
- ArchiveBatchId（彙總批次編號）

#### C. 金額與稅務

- TaxType（1 應稅 / 2 零稅 / 3 免稅 / 9 混稅）
- SalesAmount（應稅銷售額）
- ZeroTaxSalesAmount（零稅銷售額）
- FreeTaxSalesAmount（免稅銷售額）
- TaxAmount（稅額）
- TotalAmount（發票總額）
- AllowanceTotalAmount（累計折讓額）
- NetTotalAmount（淨額）

#### D. 關聯欄位

- OrderNo（訂單號，僅留原值或遮罩）
- OrderNoHash（HMAC-SHA256）
- BuyerBan（買方統編）
- AllowanceNo（最後一筆折讓單號）

#### E. 狀態欄位

- InvoiceStatus（Issued / Voided）
- AllowanceStatus（None / Partial / Full）
- DocType（Invoice / Allowance）
- IsUploaded（Y / N）

#### F. 證明與來源

- ProofKey（證明檔識別碼）
- ProofUri（Object Storage 相對路徑）
- SourceSystem（API / Excel / FTP / ThirdParty）
- SourceRef（來源系統識別碼）

---

## 6. 索引與效能設計

### 6.1 必備索引

- UX_InvoiceKey（SellerBan, InvoiceNo） Unique
- IX_InvoiceDateTime（InvoiceDateTime）
- IX_OrderNoHash（OrderNoHash）
- IX_BuyerBan（BuyerBan）
- IX_Status（InvoiceStatus, AllowanceStatus, TaxType）

### 6.2 Partition 策略

- 依 InvoiceDateTime 或 InvoiceYear 進行分割
- 建議月分或雙月期別

---

## 7. ETL 與程式設計規劃

### 7.1 彙總邏輯

- 發票為最小粒度
- 單身資料僅用於金額加總，不保存
- 折讓資料累計為 AllowanceTotalAmount

### 7.2 去識別化規則

- 移除：姓名、Email、電話、地址、載具號
- 保留：BuyerBan、OrderNo（遮罩）
- Hash：OrderNoHash = HMACSHA256(secret, OrderNo)

### 7.3 一致性檢核（必須通過）

- TotalAmount = Sales + ZeroTax + FreeTax + TaxAmount
- 彙總前後張數與總額需一致

---

## 8. 查詢與使用情境

### 8.1 查詢方式

1. 精準查詢：SellerBan + InvoiceNo
2. 客服查詢：OrderNoHash + 日期區間
3. 稽核查詢：日期 + 狀態 + 稅別 + 金額

### 8.2 證明下載

- 依 InvoiceKey 取得 ProofKey
- 從 Object Storage 下載 PDF / HTML

---

## 9. 權限與治理原則

- 歷史資料唯讀
- 查詢與下載需符合原系統權限控管
- ETL 批次需完整紀錄與可追溯

---

## 10. 驗收條件（Acceptance Criteria）

1. 一年以上資料可成功移轉至 Archive DB
2. 查詢速度不受主系統資料量影響
3. 任一發票可查詢並下載證明
4. 個資欄位不可於 Archive DB 中還原
5. 金額、稅務、張數對帳正確

---

## 11. 風險與注意事項

- 折讓多筆僅保留彙總資訊
- 規格異動需調整 DataVersion
- Object Storage 權限與連結有效期限需控管

---

**本文件為 e首發票歷史資料拆分治理之標準 PRD，後續如有 ERP、API、查詢介面擴充，需以此為基準延伸。**

