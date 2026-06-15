# NutriVoice 🎙️🥗

Voice-powered nutrition tracking app for iOS & Android, built with Flutter.

## Features

- **Voice recognition** in German & English (on-device + cloud fallback)
- **Food search** via OpenFoodFacts API (2M+ products)
- **Calorie ring chart** — modern donut chart like fitness apps
- **Nutrition table** per 100g and per portion
- **Portion slider** — adjust grams, calories update live
- **Daily log** — track everything eaten, swipe to delete
- **Nutrient gap analysis** — see what's missing & get food recommendations
- **Firebase** backend (Auth + Firestore)
- **Dark mode** design with gradient ring

## Setup

### Prerequisites
- Flutter 3.16+ (`flutter --version`)
- Dart 3.0+
- Android Studio / Xcode

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Anonymous Authentication**
3. Enable **Cloud Firestore** (start in test mode)
4. **Android:** Download `google-services.json` → place in `android/app/`
5. **iOS:** Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Add Firebase to `android/app/build.gradle`:

```gradle
// android/build.gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. Run the app

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Release build
flutter build apk --release         # Android APK
flutter build appbundle --release   # Google Play
flutter build ios --release         # iOS App Store
```

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── theme/app_theme.dart      # Dark theme, colors
├── models/                   # Data models
│   ├── food_model.dart
│   ├── food_log_entry.dart
│   ├── user_profile.dart
│   └── nutrient_gap.dart
├── services/                 # API & platform services
│   ├── open_food_facts_service.dart
│   ├── speech_service.dart
│   └── firebase_service.dart
├── providers/                # State management (Provider)
│   ├── user_provider.dart
│   └── nutrition_provider.dart
├── screens/                  # App screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── voice_search_screen.dart
│   ├── food_detail_screen.dart
│   ├── food_log_screen.dart
│   └── profile_screen.dart
├── widgets/                  # Reusable widgets
│   ├── calorie_ring_chart.dart
│   ├── macro_card.dart
│   ├── nutrient_gap_row.dart
│   └── pulsing_mic_button.dart
└── l10n/strings.dart         # DE/EN translations
```

## App Store Requirements

### Apple App Store ($99/year)
- Apple Developer Account
- Xcode for signing + archiving
- App icons (1024x1024)

### Google Play Store ($25 one-time)
- Google Play Developer Account
- Signed APK / App Bundle
- `flutter build appbundle --release`

## API Used

- **OpenFoodFacts** — Free, open-source food database
  - No API key required
  - 2M+ products worldwide
  - Returns: name, brand, image, all nutrients per 100g
