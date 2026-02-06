# 研發投資抵減：使用 Pandoc 將完整版文件轉成 Word (.docx)
# 使用前請先安裝 Pandoc (https://pandoc.org/)（不需 LaTeX）
# 在 PowerShell 於「systemlead-docs」專案根目錄執行： .\docs\rd-tax-credit\輸出DOCX.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$outDir = Join-Path $root "docs\rd-tax-credit\docx-output"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$docs = @(
    @{
        In  = "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md"
        Out = "2025_研發投資抵減_完整計畫書.docx"
    },
    @{
        In  = "docs\rd-tax-credit\plans\2025\2025_完整附件與報告.md"
        Out = "2025_研發投資抵減_完整附件與報告.docx"
    },
    @{
        In  = "docs\rd-tax-credit\execution\work-reports\2025_研發工作報告_完整版.md"
        Out = "2025_研發工作報告_完整版.docx"
    },
    @{
        In  = "docs\rd-tax-credit\execution\training\2025_教育訓練計畫與參訓名冊_完整版.md"
        Out = "2025_教育訓練計畫與參訓名冊_完整版.docx"
    },
    @{
        In  = "docs\rd-tax-credit\execution\work-reports\2025_monthly\2025_月工作報告彙總.md"
        Out = "2025_月工作報告彙總.docx"
    }
)

Push-Location $root
try {
    foreach ($d in $docs) {
        $inPath = Join-Path $root $d.In
        $outPath = Join-Path $outDir $d.Out
        if (-not (Test-Path $inPath)) { Write-Warning "找不到: $inPath"; continue }
        Write-Host "轉換: $($d.Out)"
        & pandoc $inPath -o $outPath
    }
    Write-Host "完成。DOCX 輸出於: $outDir"
} finally {
    Pop-Location
}
