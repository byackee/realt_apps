import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/data_manager.dart';
import 'settings/theme.dart';
import 'splash_screen.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox('dashboardTokens');
  await Hive.openBox('realTokens');
  await Hive.openBox('rentData');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataManager()..fetchAndCalculateData()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> _isDarkTheme = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme.value = prefs.getBool('isDarkTheme') ?? false;
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkTheme,
      builder: (context, isDarkTheme, child) {
        return MaterialApp(
          title: 'RealT mobile app',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(
            onThemeChanged: (value) {
              _isDarkTheme.value = value;
              _saveTheme(value);
            },
          ), // Passe la fonction au SplashScreen
        );
      },
    );
  }
}
