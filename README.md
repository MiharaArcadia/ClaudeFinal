# Carby

A Flutter nutrition/calorie tracking app with voice input, built with Firebase and OpenFoodFacts.

## Requirements

- Flutter 3.x (Dart 3)
- Android SDK / Xcode (for iOS)
- Firebase project

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable **Anonymous Authentication** under Authentication > Sign-in methods
3. Create a **Firestore** database in production or test mode
4. Download `google-services.json` (Android) and place it in `android/app/`
5. Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`
6. Run `flutterfire configure` or manually add Firebase options

## Running the App

```bash
flutter pub get
flutter run
```

## Features

- **Voice input**: Say a food name to search (speech_to_text)
- **OpenFoodFacts**: Real nutrition data from the public API
- **Dashboard**: Calorie ring, macro cards, nutrient gap progress bars
- **Food log**: Swipe-to-delete daily food entries
- **Profile**: Edit name, age, weight, height, goal, language
- **Multilingual**: German (Deutsch) and English
- **Dark theme**: Beautiful dark UI with orange/teal accents

## Architecture

- State management: **Provider**
- Database: **Cloud Firestore** (anonymous auth)
- Nutrition API: **OpenFoodFacts** (free, no API key needed)
- Charts: **fl_chart**
- Fonts: **Google Fonts (Inter)**
