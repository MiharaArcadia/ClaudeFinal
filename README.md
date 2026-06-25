# Clocky

Ein kostenloser, werbefreier Zeittracker für Freelancer — Android-only, vollständig offline.

**Von ArcadiaApps** · Gleiche Markenfamilie wie [Carby](https://arcadiaapps.de)

---

## Features

- **Stoppuhr** — Start, Pause, Stop mit einem Tap, Projektzuweisung, optionale Notiz
- **Einträge** — Alle Zeiten nach Datum gruppiert, manuelle Einträge hinzufügen & bearbeiten
- **Projekte** — Kunden, Stundensätze und Projektfarben verwalten
- **Export** — PDF-Stundenzettel, CSV-Export, direkt per E-Mail versenden
- **Home-Widget** — Timer-Control direkt vom Homescreen (2×2 und 4×1)
- **Einstellungen** — Profil, Logo, Dark/Light/System-Mode

## Tech Stack

- **Flutter** (UI + Logic, Dart 3)
- **Kotlin** (Android Home Screen Widget)
- **SQLite** via `sqflite`
- **PDF** via `pdf` + `printing`
- **CSV** via `csv`
- **Share** via `share_plus`
- Kein Backend · Kein Account · Kein Tracking

## Design

- Primärfarbe: `#FF6B35` (Orange)
- Background: `#121212` (Dark) / `#FAFAFA` (Light)
- Fonts: **Bebas Neue** (Timer-Display), **DM Sans** (UI-Text)
- Material Design 3
- Dark/Light Mode (System-Default + manuell umschaltbar)

## Voraussetzungen

- Flutter 3.x (Dart 3)
- Android SDK (minSdk 26 / Android 8.0+)

## Starten

```bash
flutter pub get
flutter run
```

## Datenschutz

Alle Daten werden ausschließlich lokal auf dem Gerät gespeichert.  
Kein Server, kein Account, kein Tracking, keine Werbung. DSGVO-konform.

## Website

[clocky.arcadiaapps.de](https://clocky.arcadiaapps.de)

## Lizenz

Open Source · [ArcadiaApps](https://arcadiaapps.de)
