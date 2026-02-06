@echo off
REM RD tax credit: export to DOCX. Needs Pandoc. Uses PowerShell (Export-Docx.ps1). ASCII-only to avoid encoding errors.

cd /d "%~dp0"
where powershell >nul 2>&1
if not %errorlevel% equ 0 (
  echo PowerShell not found. Install it or run Export-Docx.ps1 from PowerShell at repo root.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Export-Docx.ps1"
if errorlevel 1 (
  echo.
  echo FAILED. Check: Pandoc installed? Run from repo root?
  powershell -NoProfile -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;[Windows.Forms.MessageBox]::Show('DOCX export failed. Install Pandoc and run from repo root.','DOCX Failed','OK','Error')"
  pause
  exit /b 1
)

echo.
echo Done. Output: %~dp0docx-output
powershell -NoProfile -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;[Windows.Forms.MessageBox]::Show('DOCX done. Output: ' + [Environment]::NewLine + '%~dp0docx-output','DOCX Done','OK','Information')"
pause
exit /b 0
