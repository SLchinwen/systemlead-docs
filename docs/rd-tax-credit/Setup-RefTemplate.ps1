# Copy government plan template to ref.docx for DOCX export.
# Run once from repo root, or from this script's folder. Edit $sourcePath if your file is elsewhere.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$targetDir = Join-Path $root "docs\rd-tax-credit\templates"
$targetPath = Join-Path $targetDir "ref.docx"

# Default: attachment from user's OneDrive (edit if your path is different)
$sourcePath = "C:\Users\sl-ch\OneDrive - SystemLead Tech CO\文件\附件1-研發計畫重點摘要書(中小企業)(1).docx"

if (-not (Test-Path $sourcePath)) {
    Write-Host "Source file not found: $sourcePath"
    Write-Host "Edit this script (Setup-RefTemplate.ps1) and set `$sourcePath to your 附件1 .docx path."
    exit 1
}

if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
Write-Host "Done. ref.docx is at: $targetPath"
Write-Host "Next: open ref.docx in Word, set table style to have borders (see templates/範本設定說明.md), then save."
