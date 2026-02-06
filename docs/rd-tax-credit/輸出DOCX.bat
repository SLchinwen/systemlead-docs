@echo off
chcp 65001 >nul
REM 研發投資抵減：使用 Pandoc 將完整版文件轉成 Word (.docx)
REM 使用前請先安裝 Pandoc (https://pandoc.org/)。在「systemlead-docs」專案根目錄執行此 bat。

cd /d "%~dp0"
cd ..\..
set OUTDIR=docs\rd-tax-credit\docx-output
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo 轉換: 2025_研發投資抵減_完整計畫書.docx
pandoc "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md" -o "%OUTDIR%\2025_研發投資抵減_完整計畫書.docx"
if errorlevel 1 goto err

echo 轉換: 2025_研發投資抵減_完整附件與報告.docx
pandoc "docs\rd-tax-credit\plans\2025\2025_完整附件與報告.md" -o "%OUTDIR%\2025_研發投資抵減_完整附件與報告.docx"
if errorlevel 1 goto err

echo 轉換: 2025_研發工作報告_完整版.docx
pandoc "docs\rd-tax-credit\execution\work-reports\2025_研發工作報告_完整版.md" -o "%OUTDIR%\2025_研發工作報告_完整版.docx"
if errorlevel 1 goto err

echo 轉換: 2025_教育訓練計畫與參訓名冊_完整版.docx
pandoc "docs\rd-tax-credit\execution\training\2025_教育訓練計畫與參訓名冊_完整版.md" -o "%OUTDIR%\2025_教育訓練計畫與參訓名冊_完整版.docx"
if errorlevel 1 goto err

echo 轉換: 2025_月工作報告彙總.docx（備查）
pandoc "docs\rd-tax-credit\execution\work-reports\2025_monthly\2025_月工作報告彙總.md" -o "%OUTDIR%\2025_月工作報告彙總.docx"
if errorlevel 1 goto err

echo.
echo 完成。DOCX 輸出於: %OUTDIR%
exit /b 0

:err
echo.
echo 轉換失敗。請確認已安裝 Pandoc，且於 systemlead-docs 專案根目錄執行此 bat。
exit /b 1
