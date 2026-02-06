# 研發投資抵減：使用 Pandoc 將完整版文件轉成 Word (.docx)
# 使用前請先安裝 Pandoc (https://pandoc.org/)（不需 LaTeX）
# 在 PowerShell 於「systemlead-docs」專案根目錄執行： .\docs\rd-tax-credit\輸出DOCX.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$outDir = Join-Path $root "docs\rd-tax-credit\docx-output"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# 政府格式範本（字體、標題項次）。優先使用專案 templates，其次 OneDrive 路徑。
$refDoc = Join-Path $root "docs\rd-tax-credit\templates\附件1-研發計畫重點摘要書(中小企業).docx"
if (-not (Test-Path $refDoc)) { $refDoc = "c:\Users\sl-ch\OneDrive - SystemLead Tech CO\文件\附件1-研發計畫重點摘要書(中小企業)(1).docx" }

$docs = @(
    @{
        In   = "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md"
        Out  = "2025_研發投資抵減_完整計畫書.docx"
        Ref  = $refDoc
    },
    @{
        In   = "docs\rd-tax-credit\plans\2025\2025_完整附件與報告.md"
        Out  = "2025_研發投資抵減_完整附件與報告.docx"
        Ref  = $null
    },
    @{
        In   = "docs\rd-tax-credit\execution\work-reports\2025_研發工作報告_完整版.md"
        Out  = "2025_研發工作報告_完整版.docx"
        Ref  = $null
    },
    @{
        In   = "docs\rd-tax-credit\execution\training\2025_教育訓練計畫與參訓名冊_完整版.md"
        Out  = "2025_教育訓練計畫與參訓名冊_完整版.docx"
        Ref  = $null
    },
    @{
        In   = "docs\rd-tax-credit\execution\work-reports\2025_monthly\2025_月工作報告彙總.md"
        Out  = "2025_月工作報告彙總.docx"
        Ref  = $null
    }
)

Push-Location $root
try {
    foreach ($d in $docs) {
        $inPath = Join-Path $root $d.In
        $outPath = Join-Path $outDir $d.Out
        if (-not (Test-Path $inPath)) { Write-Warning "找不到: $inPath"; continue }
        Write-Host "轉換: $($d.Out)"
        if ($d.Ref -and (Test-Path $d.Ref)) {
            & pandoc $inPath -o $outPath --reference-doc=$d.Ref
        } else {
            if ($d.Ref) { Write-Warning "未找到格式範本，以預設樣式輸出: $($d.Out)" }
            & pandoc $inPath -o $outPath
        }
    }
    Write-Host "完成。DOCX 輸出於: $outDir"
} finally {
    Pop-Location
}
