# systemlead-docs

Systemlead（矽聯科技）旗下產品與服務的官方文件中心。

---

## 使用 MkDocs 建站與預覽

本專案以 **MkDocs** 建置文件網站，導航結構與首頁引導目錄定義於 `mkdocs.yml`。

### 環境需求

- Python 3.8+
- MkDocs 與 Material 主題（建議使用 `requirements-docs.txt`）

### 安裝與啟動

```bash
# 在 systemlead-docs 目錄下
pip install mkdocs mkdocs-material
mkdocs serve
```

瀏覽 <http://127.0.0.1:8000/> 即可預覽文件站。

### 建置靜態站

```bash
mkdocs build
```

輸出目錄為 `site/`（可依部署需求設定）。

### 導航結構說明

- **首頁**：產品文件中心入口，引導至各模組與治理文件
- **e首發票（EINV）**：模組總覽、API、**操作手冊（含 EC 整合：蝦皮、EasyStore）**、情境 SOP、知識庫、版本說明
- **治理與規範**：文件治理、Metadata Routing、AI 使用與檢索架構
- **規則（Rules）**：e首發票發票開立與取號（SSOT）
- **OpenAPI**：規格總覽
- **貢獻與範本**：文件標頭、AI Prompts 範本
