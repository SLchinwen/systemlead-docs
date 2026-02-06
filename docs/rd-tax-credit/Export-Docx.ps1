# RD tax credit: export plan/reports to DOCX via Pandoc.
# Called by 輸出DOCX.bat (ASCII name avoids cmd encoding issues). Install Pandoc first.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outDir = Join-Path $root "docs\rd-tax-credit\docx-output"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$refDoc = Join-Path $root "docs\rd-tax-credit\templates\ref.docx"

$docs = @(
    @{ In = "docs\rd-tax-credit\plans\2025\2025_年度研發投資抵減_完整計畫書.md"; Out = "2025_研發投資抵減_完整計畫書.docx"; Ref = $refDoc },
    @{ In = "docs\rd-tax-credit\plans\2025\2025_完整附件與報告.md"; Out = "2025_研發投資抵減_完整附件與報告.docx"; Ref = $null },
    @{ In = "docs\rd-tax-credit\execution\work-reports\2025_研發工作報告_完整版.md"; Out = "2025_研發工作報告_完整版.docx"; Ref = $null },
    @{ In = "docs\rd-tax-credit\execution\training\2025_教育訓練計畫與參訓名冊_完整版.md"; Out = "2025_教育訓練計畫與參訓名冊_完整版.docx"; Ref = $null },
    @{ In = "docs\rd-tax-credit\execution\work-reports\2025_monthly\2025_月工作報告彙總.md"; Out = "2025_月工作報告彙總.docx"; Ref = $null }
)

Push-Location $root
try {
    foreach ($d in $docs) {
        $inPath = Join-Path $root $d.In
        $outPath = Join-Path $outDir $d.Out
        if (-not (Test-Path $inPath)) { Write-Warning "Missing: $inPath"; continue }
        Write-Host "Converting: $($d.Out)"
        if ($d.Ref -and (Test-Path $d.Ref)) {
            & pandoc $inPath -o $outPath --reference-doc=$d.Ref
        } else {
            & pandoc $inPath -o $outPath
        }
        if ($LASTEXITCODE -ne 0) { throw "Pandoc failed for $($d.Out)" }
    }
    Write-Host "Done. Output: $outDir"
} finally {
    Pop-Location
}
