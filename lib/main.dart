import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nutri_voice/providers/nutrition_provider.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/screens/splash_screen.dart';
import 'package:nutri_voice/services/firebase_service.dart';
import 'package:nutri_voice/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows window setup
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      backgroundColor: Color(0xFF0D0D0D),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'NutriVoice',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await Firebase.initializeApp();
  runApp(const NutriVoiceApp());
}

class NutriVoiceApp extends StatelessWidget {
  const NutriVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionProvider(firebaseService),
        ),
      ],
      child: MaterialApp(
        title: 'NutriVoice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
