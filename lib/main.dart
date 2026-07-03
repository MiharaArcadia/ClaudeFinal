import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:carby/providers/favorites_provider.dart';
import 'package:carby/providers/nutrition_provider.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/splash_screen.dart';
import 'package:carby/services/firebase_service.dart';
import 'package:carby/theme/app_theme.dart';

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
      title: 'Carby',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('[Firebase] Init skipped: $e');
  }
  runApp(CarbyApp(firebaseReady: firebaseReady));
}

class CarbyApp extends StatelessWidget {
  final bool firebaseReady;
  const CarbyApp({super.key, this.firebaseReady = false});

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
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..init(),
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (_, userProvider, __) => MaterialApp(
          title: 'Carby',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: userProvider.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
