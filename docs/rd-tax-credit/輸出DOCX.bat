@echo off
REM RD tax credit: export plan/reports to DOCX. Need Pandoc. Run from repo root.
REM If you see garbled paths: run 輸出DOCX.ps1 in PowerShell instead, or save this file as ANSI/Big5.

chcp 65001 >nul
cd /d "%~dp0"
cd ..\..

REM Prefer PowerShell to avoid encoding issues with Chinese paths in cmd
where powershell >nul 2>&1
if %errorlevel% equ 0 (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Export-Docx.ps1"
  if errorlevel 1 goto err
  echo.
  echo Done. Output: %~dp0docx-output
  powershell -NoProfile -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;[Windows.Forms.MessageBox]::Show('DOCX 已完成。輸出: ' + [Environment]::NewLine + '%~dp0docx-output','DOCX Done','OK','Information')"
  echo.
  pause
  exit /b 0
)

set "OUTDIR=docs\rd-tax-credit\docx-output"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM Template: use docs\rd-tax-credit\templates\ref.docx (copy gov format doc there, rename to ref.docx)
set "REFDOC=docs\rd-tax-credit\templates\ref.docx"

echo [1/5] Plan book...
if exist "%REFDOC%" (
  pandoc "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md" -o "%OUTDIR%\2025_研發投資抵減_完整計畫書.docx" --reference-doc="%REFDOC%"
) else (
  echo       (no ref.docx, using default style)
  pandoc "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md" -o "%OUTDIR%\2025_研發投資抵減_完整計畫書.docx"
)
if errorlevel 1 goto err

echo [2/5] Attachments...
pandoc "docs\rd-tax-credit\plans\2025\2025_完整附件與報告.md" -o "%OUTDIR%\2025_研發投資抵減_完整附件與報告.docx"
if errorlevel 1 goto err

echo [3/5] Quarterly report...
pandoc "docs\rd-tax-credit\execution\work-reports\2025_研發工作報告_完整版.md" -o "%OUTDIR%\2025_研發工作報告_完整版.docx"
if errorlevel 1 goto err

echo [4/5] Training...
pandoc "docs\rd-tax-credit\execution\training\2025_教育訓練計畫與參訓名冊_完整版.md" -o "%OUTDIR%\2025_教育訓練計畫與參訓名冊_完整版.docx"
if errorlevel 1 goto err

echo [5/5] Monthly summary...
pandoc "docs\rd-tax-credit\execution\work-reports\2025_monthly\2025_月工作報告彙總.md" -o "%OUTDIR%\2025_月工作報告彙總.docx"
if errorlevel 1 goto err

echo.
set "FULLOUT=%CD%\%OUTDIR%"
echo Done. Output: %FULLOUT%
powershell -NoProfile -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;[Windows.Forms.MessageBox]::Show('Output: ' + [Environment]::NewLine + '%FULLOUT%','DOCX Done','OK','Information')"
echo.
pause
exit /b 0

:err
echo.
echo FAILED. Check: Pandoc installed? Run from repo root? See errors above.
powershell -NoProfile -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;[Windows.Forms.MessageBox]::Show('DOCX export failed. Install Pandoc and run from repo root.','DOCX Failed','OK','Error')"
echo.
pause
exit /b 1
