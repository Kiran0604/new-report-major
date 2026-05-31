# PowerShell script to clean and compile the LaTeX project using MiKTeX
# This script handles cleaning invalid environment variables from PATH that crash MiKTeX.

# 1. Clean environment path of any direct file references (which crash MiKTeX)
$paths = $env:PATH -split ';'
$cleanPaths = @()
foreach ($p in $paths) {
    if ($p -and (Test-Path -Path $p -PathType Container)) {
        $cleanPaths += $p
    }
}
$env:PATH = "C:\Users\Kiran\AppData\Local\Programs\MiKTeX\miktex\bin\x64;" + ($cleanPaths -join ';')

Write-Host "Step 1/4: Cleaning auxiliary files..." -ForegroundColor Cyan
Remove-Item -Path *.aux, *.bbl, *.blg, *.lof, *.log, *.lot, *.out, *.toc, *.run.xml, *.bcf -ErrorAction SilentlyContinue

Write-Host "Step 2/4: Running pdflatex (First pass)..." -ForegroundColor Cyan
pdflatex -interaction=nonstopmode MajorProjectReport.tex | Out-Null

Write-Host "Running makeglossaries-lite..." -ForegroundColor Cyan
makeglossaries-lite MajorProjectReport | Out-Null

Write-Host "Step 3/4: Running BibTeX..." -ForegroundColor Cyan
bibtex MajorProjectReport | Out-Null

Write-Host "Step 4/4: Finalizing pdflatex compilation..." -ForegroundColor Cyan
pdflatex -interaction=nonstopmode MajorProjectReport.tex | Out-Null
pdflatex -interaction=nonstopmode MajorProjectReport.tex | Out-Null

if (Test-Path -Path "MajorProjectReport.pdf") {
    Write-Host "`nSuccess! PDF compiled successfully: MajorProjectReport.pdf" -ForegroundColor Green
} else {
    Write-Host "`nError: Compilation failed. Check MajorProjectReport.log for details." -ForegroundColor Red
}
