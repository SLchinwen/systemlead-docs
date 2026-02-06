# RD tax credit: export to DOCX via Pandoc. Reads paths from docx-file-list.txt (UTF-8). ASCII-only script.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outDir = Join-Path $root "docs\rd-tax-credit\docx-output"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$refDoc = Join-Path $root "docs\rd-tax-credit\templates\ref.docx"
$listPath = Join-Path $PSScriptRoot "docx-file-list.txt"
$listText = [System.IO.File]::ReadAllText($listPath, [System.Text.Encoding]::UTF8)
$lines = $listText -split "`r?`n" | Where-Object { $_.Trim() -ne "" }

Push-Location $root
try {
    foreach ($line in $lines) {
        $parts = $line -split "\|", 3
        if ($parts.Count -lt 2) { continue }
        $inRel = $parts[0].Trim()
        $outName = $parts[1].Trim()
        $useRef = ($parts.Count -ge 3) -and ($parts[2].Trim() -eq "ref")
        $inPath = Join-Path $root $inRel
        $outPath = Join-Path $outDir $outName
        if (-not (Test-Path $inPath)) { Write-Warning "Missing: $inRel"; continue }
        Write-Host "Converting: $outName"
        if ($useRef -and (Test-Path $refDoc)) {
            & pandoc $inPath -o $outPath --reference-doc=$refDoc
        } else {
            & pandoc $inPath -o $outPath
        }
        if ($LASTEXITCODE -ne 0) { throw "Pandoc failed for $outName" }
    }
    Write-Host "Done. Output: $outDir"
} finally {
    Pop-Location
}
