# ═══════════════════════════════════════════════════
# Carby — Android Release Build Script
# Ausführen: .\build_android.ps1
# ═══════════════════════════════════════════════════

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Carby Android Release Build" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Flutter check
Write-Host "→ Prüfe Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter"
    Write-Host "  ✓ $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Flutter nicht gefunden!" -ForegroundColor Red
    Write-Host "  Installiere mit: winget install Flutter.Flutter" -ForegroundColor Red
    exit 1
}

# 2. key.properties check
Write-Host "→ Prüfe key.properties..." -ForegroundColor Yellow
if (-not (Test-Path "android\key.properties")) {
    Write-Host "  ✗ android\key.properties fehlt!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  1. Erstelle Keystore:" -ForegroundColor White
    Write-Host "     keytool -genkey -v -keystore `$env:USERPROFILE\carby-release.jks -alias carby -keyalg RSA -keysize 2048 -validity 10000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Kopiere android\key.properties.template → android\key.properties" -ForegroundColor White
    Write-Host "  3. Fülle die Werte aus" -ForegroundColor White
    exit 1
}
Write-Host "  ✓ key.properties vorhanden" -ForegroundColor Green

# 3. google-services.json check
Write-Host "→ Prüfe google-services.json..." -ForegroundColor Yellow
$gsJson = Get-Content "android\app\google-services.json" -Raw
if ($gsJson -match "ERSETZEN_MIT") {
    Write-Host "  ✗ google-services.json enthält noch Platzhalter!" -ForegroundColor Red
    Write-Host "  Lade die echte Datei von Firebase Console herunter:" -ForegroundColor White
    Write-Host "  console.firebase.google.com → Projekt → Einstellungen → Android App" -ForegroundColor Cyan
    exit 1
}
Write-Host "  ✓ google-services.json konfiguriert" -ForegroundColor Green

# 4. flutter pub get
Write-Host "→ flutter pub get..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Host "  ✗ pub get fehlgeschlagen" -ForegroundColor Red; exit 1 }
Write-Host "  ✓ Dependencies aktuell" -ForegroundColor Green

# 5. flutter analyze
Write-Host "→ flutter analyze..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠ Analyse-Warnings (Build wird trotzdem fortgesetzt)" -ForegroundColor Yellow
}

# 6. Build AAB
Write-Host ""
Write-Host "→ Baue Release AAB (dauert 2-5 Minuten)..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ✗ Build fehlgeschlagen!" -ForegroundColor Red
    exit 1
}

$aabPath = "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $aabPath) {
    $size = [math]::Round((Get-Item $aabPath).length / 1MB, 1)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✓ BUILD ERFOLGREICH!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Datei: $aabPath" -ForegroundColor White
    Write-Host "  Größe: $size MB" -ForegroundColor White
    Write-Host ""
    Write-Host "  Nächster Schritt:" -ForegroundColor Yellow
    Write-Host "  → play.google.com/console → App auswählen → Release → AAB hochladen" -ForegroundColor Cyan
    Write-Host ""

    # Öffne Ordner im Explorer
    $folder = Split-Path $aabPath -Parent
    explorer $folder
}
