# ═══════════════════════════════════════════════════
# Carby — Version-Bump für Day-One-Patch / Store-Update
# Erhöht in pubspec.yaml den versionCode (+N) und optional den versionName,
# baut danach das Release-AAB. Jedes Play-Upload braucht einen höheren N.
#
# Beispiele:
#   .\bump_version.ps1                 # nur versionCode +1 (z.B. 1.0.0+1 -> 1.0.0+2)
#   .\bump_version.ps1 -Name 1.0.1     # versionName auf 1.0.1, versionCode +1
#   .\bump_version.ps1 -Name 1.0.1 -NoBuild   # nur pubspec ändern, nicht bauen
# ═══════════════════════════════════════════════════

param(
    [string]$Name,      # neuer versionName (z.B. "1.0.1"); leer = unverändert
    [switch]$NoBuild    # nur pubspec anpassen, keinen Build starten
)

$ErrorActionPreference = "Stop"

$pubspec = "pubspec.yaml"
if (-not (Test-Path $pubspec)) {
    Write-Host "✗ pubspec.yaml nicht gefunden. Bitte im Projekt-Root ausführen." -ForegroundColor Red
    exit 1
}

$content = Get-Content $pubspec -Raw
# Zeile: version: X.Y.Z+N
$match = [regex]::Match($content, "(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$")
if (-not $match.Success) {
    Write-Host "✗ Konnte 'version: X.Y.Z+N' in pubspec.yaml nicht finden." -ForegroundColor Red
    exit 1
}

$oldName = $match.Groups[1].Value
$oldCode = [int]$match.Groups[2].Value
$newName = if ($Name) { $Name } else { $oldName }
$newCode = $oldCode + 1

$newContent = $content -replace "(?m)^version:\s*.+$", "version: $newName+$newCode"
Set-Content -Path $pubspec -Value $newContent -NoNewline

Write-Host ""
Write-Host "  Version: $oldName+$oldCode  ->  $newName+$newCode" -ForegroundColor Green
Write-Host "  (versionName=$newName, versionCode=$newCode)" -ForegroundColor White
Write-Host ""

if ($NoBuild) {
    Write-Host "  -NoBuild gesetzt: kein Build. pubspec.yaml aktualisiert." -ForegroundColor Yellow
    exit 0
}

Write-Host "→ Starte Release-Build..." -ForegroundColor Yellow
& "$PSScriptRoot\build_android.ps1"
