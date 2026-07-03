/// Blockzy — app entry point.
///
/// Bootstraps services, loads player data + candy art, wires Provider, and
/// launches the animated home screen. Also manages app-lifecycle so music
/// pauses in the background and in-progress state is saved.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/save_repository.dart';
import 'presentation/player_controller.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'services/asset_loader.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Services (single instances shared app-wide).
  final audio = AudioService();
  final haptics = HapticService();
  final assets = CandyAssetLoader();
  await assets.load();

  final player = PlayerController(
    repository: SaveRepository(),
    audio: audio,
    haptics: haptics,
  );
  await player.init();

  runApp(
    BlockzyApp(
      player: player,
      audio: audio,
      assets: assets,
    ),
  );
}

class BlockzyApp extends StatelessWidget {
  const BlockzyApp({
    super.key,
    required this.player,
    required this.audio,
    required this.assets,
  });

  final PlayerController player;
  final AudioService audio;
  final CandyAssetLoader assets;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: player),
        Provider.value(value: audio),
        Provider.value(value: assets),
      ],
      child: _LifecycleHost(
        audio: audio,
        child: Consumer<PlayerController>(
          builder: (context, p, _) => MaterialApp(
            title: 'Blockzy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            // Battery-saver / accessibility can prefer the lighter surface.
            themeMode: p.settings.batterySaver ? ThemeMode.light : ThemeMode.dark,
            home: const HomeScreen(),
          ),
        ),
      ),
    );
  }
}

/// Pauses/resumes ambient music with the app lifecycle.
class _LifecycleHost extends StatefulWidget {
  const _LifecycleHost({required this.child, required this.audio});
  final Widget child;
  final AudioService audio;

  @override
  State<_LifecycleHost> createState() => _LifecycleHostState();
}

class _LifecycleHostState extends State<_LifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.audio.startMusic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        widget.audio.pauseMusic();
      case AppLifecycleState.resumed:
        widget.audio.resumeMusic();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
