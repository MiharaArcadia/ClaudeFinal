import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:nutri_voice/providers/nutrition_provider.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/screens/splash_screen.dart';
import 'package:nutri_voice/services/firebase_service.dart';
import 'package:nutri_voice/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
