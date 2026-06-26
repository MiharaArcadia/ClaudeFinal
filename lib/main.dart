import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:clocky/providers/entry_provider.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/providers/settings_provider.dart';
import 'package:clocky/providers/timer_provider.dart';
import 'package:clocky/screens/entries_screen.dart';
import 'package:clocky/screens/export_screen.dart';
import 'package:clocky/screens/projects_screen.dart';
import 'package:clocky/screens/settings_screen.dart';
import 'package:clocky/screens/timer_screen.dart';
import 'package:clocky/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClockyApp());
}

class ClockyApp extends StatelessWidget {
  const ClockyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()..loadProjects()),
        ChangeNotifierProvider(create: (_) => EntryProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Clocky',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de', 'DE'),
              Locale('en', 'US'),
            ],
            locale: const Locale('de', 'DE'),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _widgetChannel = MethodChannel('clocky/widget');

  @override
  void initState() {
    super.initState();
    _widgetChannel.setMethodCallHandler(_handleWidgetAction);
  }

  @override
  void dispose() {
    _widgetChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleWidgetAction(MethodCall call) async {
    final timer = context.read<TimerProvider>();
    final entries = context.read<EntryProvider>();
    switch (call.method) {
      case 'start':
        if (timer.state == TimerState.stopped || timer.state == TimerState.paused) {
          timer.start(timer.currentProjectId);
        }
        break;
      case 'pause':
        if (timer.state == TimerState.running) {
          timer.pause();
        } else if (timer.state == TimerState.paused) {
          timer.resume();
        }
        break;
      case 'stop':
        if (timer.state != TimerState.stopped) {
          await timer.stop(entries);
        }
        break;
    }
  }

  static const _screens = [
    TimerScreen(),
    EntriesScreen(),
    ProjectsScreen(),
    ExportScreen(),
    SettingsScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.timer_outlined),
      activeIcon: Icon(Icons.timer_rounded),
      label: 'Timer',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_outlined),
      activeIcon: Icon(Icons.list_alt_rounded),
      label: 'Einträge',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open_outlined),
      activeIcon: Icon(Icons.folder_open_rounded),
      label: 'Projekte',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.download_outlined),
      activeIcon: Icon(Icons.download_rounded),
      label: 'Export',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Einstellungen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
      ),
    );
  }
}
