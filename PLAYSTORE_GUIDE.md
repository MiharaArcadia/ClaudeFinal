# Clocky – Play Store Veröffentlichung

## 1. Keystore erstellen (einmalig – SICHER AUFBEWAHREN!)

```bash
keytool -genkey -v -keystore clocky-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias clocky
```

Dann `clocky-release.jks` in den Ordner `android/` kopieren.

## 2. key.properties erstellen

Datei `android/key.properties` anlegen (NICHT ins Git pushen!):

```
storeFile=../clocky-release.jks
storePassword=DEIN_STORE_PASSWORT
keyAlias=clocky
keyPassword=DEIN_KEY_PASSWORT
```

Die Datei ist bereits in `.gitignore` ausgeschlossen.

## 3. Release Build erstellen

```bash
flutter build appbundle --release
```

Die fertige Datei liegt dann unter:
`build/app/outputs/bundle/release/app-release.aab`

---

## 4. Play Console – App anlegen

1. https://play.google.com/console aufrufen
2. "App erstellen" → Sprache: Deutsch, Typ: App, Kostenlos
3. Alle Pflichtfelder ausfüllen

---

## 5. Store-Eintrag (Texte)

### App-Name (max 30 Zeichen)
```
Clocky – Zeiterfassung
```

### Kurzbeschreibung (max 80 Zeichen)
```
Stunden tracken, Berichte exportieren – kostenlos, werbefrei, offline.
```

### Vollständige Beschreibung (max 4000 Zeichen)
```
Clocky ist die einfachste Zeiterfassungs-App für Freelancer und Selbstständige – kostenlos, werbefrei und komplett offline.

⏱ TIMER MIT EINEM KLICK
Starte und stoppe deinen Timer direkt vom Startbildschirm oder dem Home-Screen-Widget. Clocky läuft im Hintergrund weiter, auch wenn du die App schließt.

📁 PROJEKTE VERWALTEN
Lege beliebig viele Projekte an, vergib Stundenssätze und weise Einträge automatisch dem richtigen Kunden zu. Behalte den Überblick über alle laufenden Aufträge.

📋 VERLAUF & STATISTIKEN
Sieh auf einen Blick, wie viele Stunden du heute, diese Woche und diesen Monat gearbeitet hast. Filtere nach Projekt oder Zeitraum.

📄 PROFESSIONELLER EXPORT
Erstelle mit einem Tipper einen fertigen PDF-Stundenzettel – komplett mit deinen Kundendaten, Stundenssatz und Unterschriftsfeld. Oder exportiere als CSV für Excel und Steuerberater. Alles direkt per E-Mail versendbar.

📱 HOME-SCREEN WIDGET
Starte, pausiere und stoppe deinen Timer direkt vom Homescreen aus – ohne die App zu öffnen. Verfügbar als 2×2 und 4×1 Widget.

🌙 DARK MODE & LIGHT MODE
Clocky passt sich automatisch an dein System-Theme an. Dunkler Modus für abends, helles Design für tagsüber.

🔒 DEINE DATEN GEHÖREN DIR
Clocky speichert alles lokal auf deinem Gerät. Keine Cloud, keine Anmeldung, keine Server. Deine Stunden sind deine Sache.

IDEAL FÜR:
• Freelancer & Selbstständige
• Grafikdesigner, Entwickler, Berater
• Handwerker & Dienstleister
• Alle, die ihre Zeit im Blick behalten wollen

Clocky ist und bleibt kostenlos – ohne Werbung, ohne Abo, ohne versteckte Kosten.
```

---

## 6. Store Assets

Alle Dateien liegen in `store_assets/`:

| Datei                    | Verwendung                    | Größe       |
|--------------------------|-------------------------------|-------------|
| `icon_512.png`           | High-Res Icon                 | 512×512 px  |
| `feature_graphic.png`    | Feature Graphic               | 1024×500 px |
| `screenshot_01_timer.png`     | Screenshot 1: Timer      | 1080×1920 px|
| `screenshot_02_projekte.png`  | Screenshot 2: Projekte   | 1080×1920 px|
| `screenshot_03_verlauf.png`   | Screenshot 3: Verlauf    | 1080×1920 px|
| `screenshot_04_export.png`    | Screenshot 4: Export     | 1080×1920 px|

---

## 7. Content-Rating

Fragebogen ausfüllen:
- Gewalt: Nein
- Sexueller Inhalt: Nein
- Sprache: Nein
- Glücksspiel: Nein
→ **Freigegeben ab 0 Jahren (Everyone)**

---

## 8. Datensicherheit (Data Safety)

| Frage                                    | Antwort |
|------------------------------------------|---------|
| Werden Daten erhoben?                    | Nein    |
| Werden Daten mit Dritten geteilt?        | Nein    |
| Werden Daten verschlüsselt übertragen?   | N/A     |
| Können Benutzer Daten löschen?           | Ja (App deinstallieren) |

---

## 9. Kategorie & Tags

- **Kategorie:** Business
- **Tags:** Zeiterfassung, Freelancer, Stunden, Timer, Rechnungsvorbereitung

---

## 10. Preise & Distribution

- **Kostenlos:** Ja
- **Länder:** Alle verfügbaren Länder (oder nur DE/AT/CH für den Anfang)
- **Enthält Werbung:** Nein
- **Enthält In-App-Käufe:** Nein

---

## 11. Checkliste vor dem Einreichen

- [ ] Keystore erstellt und sicher gespeichert
- [ ] `key.properties` angelegt
- [ ] `flutter build appbundle --release` erfolgreich
- [ ] AAB-Datei hochgeladen
- [ ] Store-Eintrag ausgefüllt (Name, Beschreibung, Screenshots, Feature Graphic)
- [ ] Content Rating ausgefüllt
- [ ] Datensicherheit ausgefüllt
- [ ] Preise gesetzt (kostenlos)
- [ ] Prüfung abgeschickt

**Typische Review-Dauer:** 1–3 Werktage (manchmal länger bei ersten Apps)
