---
product: company
docType: reference
module: pricing
title: 年度張數級距公式與維護說明
slug: pricing-tier-formula
version: v1.0
effectiveDate: 2026-02-01
audience:
  - product
  - finance
  - dev
  - sales
tags:
  - 級距
  - 公式
  - 定價
  - 千張
---

## 年度張數級距公式與維護說明

> **文件性質：參考文件（與 pricing-tiers.yaml 同為級距單一來源）**  
> 輸入：張數（以**千張**為單位）；輸出：年費（元）。**非**單價×數量，採分段線性內插以呈現體積折扣。

---

## 1. 公式邏輯

### 1.1 輸入與輸出

| 項目 | 說明 |
|------|------|
| **輸入** | 年度張數，以**千張**為單位（例：1 = 1,000 張、240 = 240,000 張） |
| **輸出** | 年費（新臺幣，元） |
| **資料來源** | [pricing-tiers.yaml](./pricing-tiers.yaml) 內各方案之 `tierAnchors` 錨點 |

### 1.2 計算方式（分段線性內插）

1. 令 `x = 張數 / 1000`（千張）。
2. 取該方案之錨點表，依 `sheets_k` 由小到大排序。
3. 若 `x ≤ 第一錨點之 sheets_k`：**fee = 第一錨點之 fee**。
4. 若 `x ≥ 最後錨點之 sheets_k`：**fee = 最後錨點之 fee**。
5. 否則，找到相鄰兩錨點 `(a.sheets_k, a.fee)` 與 `(b.sheets_k, b.fee)` 使得 `a.sheets_k ≤ x < b.sheets_k`，計算：
   - **fee = a.fee + (b.fee − a.fee) × (x − a.sheets_k) / (b.sheets_k − a.sheets_k)**

### 1.3 範例（訂單版，錨點見 pricing-tiers.yaml）

| 張數 | 千張 (x) | 計算說明 | 年費（元） |
|------|----------|----------|------------|
| 300 | 0.3 | 等於第一錨點 | 2,000 |
| 500 | 0.5 | 0.3～1 間內插 | 2,000 + (3,000−2,000)×(0.5−0.3)/(1−0.3) = 2,000 + 286 ≈ 2,286 |
| 1,000 | 1 | 等於錨點 | 3,000 |
| 6,000 | 6 | 等於錨點 | 4,500 |
| 240,000 | 240 | 等於錨點 | 20,000 |
| 300,000 | 300 | 大於最後錨點 240，取最後錨點 | 20,000 |

---

## 2. 維護作業（標準化流程）

### 2.1 單一維護來源

- **級距錨點**：僅在 [pricing-tiers.yaml](./pricing-tiers.yaml) 新增／修改／刪除 `tierAnchors` 下之錨點。
- **產品代碼與顯示名稱**：僅在 `pricing-tiers.yaml` 之 `products` 區塊維護，報價表單、文件、系統共用同一組 id／name。

### 2.2 新增或調整錨點

1. 開啟 `pricing-tiers.yaml`，找到對應方案（如 `plan_order`）。
2. 在 `anchors` 中依 **sheets_k 由小到大** 新增或修改一筆，格式：
   - `sheets_k`: 千張數（可小數，例 0.3、1、240）
   - `fee`: 該千張數對應之年費（整數，元）
3. 存檔後，系統與試算表依同一公式邏輯重算即可，無需改程式內寫死的數字。

### 2.3 產品重新命名

1. 在 `pricing-tiers.yaml` 的 `products` 下修改對應之 `name`（顯示用）或 `id`（系統／表單代碼）。
2. 若變更 `id`，需同步更新引用該 id 之表單、文件與後端（建議用搜尋「plan_order」「plan_invoice」等）。

### 2.4 定價檢討時

- 年度定價檢討時，僅需更新 YAML 錨點與必要時之產品名稱。
- 公式邏輯（分段線性內插）不變，無需改本說明文件除非要改計價方式。

---

## 3. 與其他文件的關係

| 文件 | 角色 |
|------|------|
| [pricing-tiers.yaml](./pricing-tiers.yaml) | 級距錨點與產品代碼／名稱之**唯一資料來源** |
| 本文件 (pricing-tier-formula.md) | 公式定義與維護流程說明 |
| [定價治理辦法](./pricing-governance.md) | 定價原則、對外說法、續約；**引用**級距公式與產品代碼 |
| [線上報價產品引導](./online-quoting-product-guide.md) | 客服／客戶用；方案名稱與級距**對應** YAML 之 products／tierAnchors |

---

## 4. 相關連結

- [定價治理辦法](./pricing-governance.md)
- [定價與報價總覽](./index.md)
- [pricing-tiers.yaml（級距與產品資料）](./pricing-tiers.yaml)
