# Carby → Google Play Store Release Guide

## Voraussetzungen (einmalig)

### 1. Flutter SDK installieren
```powershell
winget install Flutter.Flutter
winget install Google.AndroidStudio
```
Dann: `flutter doctor` ausführen → alle Punkte müssen ✓ sein.

### 2. Android Emulator einrichten (für Tests)
1. Android Studio öffnen
2. Virtual Device Manager → Create Device
3. Pixel 7 → API 34 (Android 14) → Download → Finish
4. Emulator mit ▶ starten
5. Im Projektordner: `flutter run` → App startet im Emulator

---

## Firebase einrichten

1. **console.firebase.google.com** → Neues Projekt: `Carby`
2. **Android App hinzufügen** → Package: `io.arcadiaapps.carby`
3. **google-services.json** herunterladen → nach `android/app/` kopieren (alte Datei ersetzen)
4. **Authentication** → Anonymous aktivieren
5. **Firestore Database** → Create → Start in test mode → `europe-west3`

---

## Keystore erstellen (einmalig — Passwort NICHT vergessen!)

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\carby-release.jks -alias carby -keyalg RSA -keysize 2048 -validity 10000
```

Dann `android/key.properties` erstellen (aus Template kopieren):
```powershell
Copy-Item android\key.properties.template android\key.properties
notepad android\key.properties
```
Werte eintragen:
```
storePassword=DEIN_PASSWORT
keyPassword=DEIN_PASSWORT
keyAlias=carby
storeFile=C:\Users\DEIN_NAME\carby-release.jks
```

⚠️ **WICHTIG:** `key.properties` und `carby-release.jks` niemals ins Git pushen!

---

## App bauen

```powershell
.\build_android.ps1
```

Oder manuell:
```powershell
flutter pub get
flutter build appbundle --release
```

AAB-Datei: `build\app\outputs\bundle\release\app-release.aab`

---

## Google Play Console

1. **play.google.com/console** → Account erstellen ($25 einmalig)
2. **App erstellen** → Name: Carby, Sprache: Deutsch, App, Kostenlos
3. **Production** → Create new release → AAB hochladen
4. **Store listing** ausfüllen:
   - **Kurzbeschreibung:** Kostenloser Ernährungs-Tracker mit KI-Spracheingabe
   - **Beschreibung:** (siehe unten)
   - **Screenshots:** 4 Stück (Emulator: Strg+S)
   - **Icon:** 512×512px (`assets/images/Arcadia_Krake.png`)
   - **Privacy Policy:** `https://miharaarcadia.github.io/claudefinal/privacy-policy.html`
5. **Content Rating** → Fragebogen ausfüllen (kein Gewalt/Adult-Content)
6. **Pricing** → Free
7. **Submit for review**

### Store-Beschreibung (DE):

Carby ist dein kostenloser, werbefreier Ernährungs-Tracker mit KI-Spracheingabe.

**Features:**
• 🎙️ KI-Spracheingabe — sag einfach "Hähnchenbrust 150g"
• 📊 Makro-Tracking — Protein, Kohlenhydrate, Fett in Echtzeit
• 💧 Wasser-Tracker — Tagesziel im Blick
• 🔍 3+ Millionen Lebensmittel via OpenFoodFacts
• 🧮 BMI & TDEE-Rechner mit Aktivitätslevel
• 🎯 Persönliche Ziele: Abnehmen, Halten oder Zunehmen
• 🔒 Privacy First — keine Werbung, kein Tracking

Carby ist komplett kostenlos und bleibt es. Keine Premium-Mauer, kein Abo.

---

## Review-Zeiten
- Neue Apps: **1–3 Tage**
- Updates: **Wenige Stunden**

Nach Genehmigung ist Carby live im Play Store 🎉

---

## Day-One-Patch (Update nach dem Launch)

Ein „Day One Patch" ist bei Android ein **ganz normales Store-Update** mit höherem
`versionCode`. Es gibt keinen separaten Patch-Mechanismus — jedes Update ist ein
neues AAB.

### Wie Versionen funktionieren
Einzige Quelle ist `pubspec.yaml`:
```
version: 1.0.0+1
         ^^^^^ ^
   versionName versionCode
```
- **versionName** (`1.0.0`) = was der Nutzer im Store sieht.
- **versionCode** (`+1`) = interne Nummer. **Muss bei JEDEM Upload streng größer sein.**

### Patch bauen (Schritt für Schritt)
1. Version erhöhen — entweder per Skript:
   ```powershell
   .\bump_version.ps1 -Name 1.0.1     # 1.0.0+1 -> 1.0.1+2, baut danach das AAB
   ```
   oder von Hand in `pubspec.yaml`: `version: 1.0.0+1` → `version: 1.0.1+2`, dann `.\build_android.ps1`.
   oder ohne pubspec-Edit direkt beim Build:
   ```powershell
   flutter build appbundle --release --build-name=1.0.1 --build-number=2
   ```
2. Neues AAB in Play Console → **Production → Create new release** → hochladen → freigeben.
3. Update-Review dauert meist nur **wenige Stunden**.

### ⚠️ Pflicht-Regeln für Updates
- **Gleicher Signing-Key** wie beim ersten Release (dasselbe `key.properties` / derselbe
  Keystore). Anderer Key = Play lehnt das Update ab. → Keystore sicher sichern!
- `versionCode` **immer** hochzählen (2, 3, 4 …).

### Damit der Patch am Launch-Tag sofort startklar ist
- **Stufenweise Einführung:** 1.0.0 z.B. zu 20 % ausrollen. Kommt ein Bug, lädst du 1.0.1
  hoch — das Update erreicht die Nutzer automatisch.
- **Vorab-Staging:** 1.0.1 schon vor dem Launch auf dem **Internal-Testing-Track**
  bereitlegen und am Day One in **Production promoten** (schneller, da schon geprüft).
- Pro Release einen **Git-Tag** setzen (`v1.0.0`, `v1.0.1`) für reproduzierbare Builds.
