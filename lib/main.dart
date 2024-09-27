import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';  // Import du Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'data_manager.dart';
import 'dashboard_page.dart';
import 'statistics_page.dart';
import 'real_tokens_page.dart';
import 'portfolio_page.dart';
import 'maps_page.dart';
import 'settings_page.dart';

void main() async {
  // Initialiser Hive
  await Hive.initFlutter();

  // Ouvrir les boxes Hive
  await Hive.openBox('dashboardTokens');
  await Hive.openBox('realTokens');
  await Hive.openBox('rentData');


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataManager()..fetchAndCalculateData()), // Initialiser le DataManager
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
          theme: ThemeData(
            primarySwatch: Colors.blue, 
            scaffoldBackgroundColor: Colors.grey[100],
            cardColor: Colors.white,
            textTheme: const TextTheme(
                      bodyLarge: TextStyle(
                        color: Colors.black, // Définir la couleur du texte
                      ),
                    ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0, 
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent, 
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
            drawerTheme: DrawerThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey[900],
            textTheme: const TextTheme(
                      bodyLarge: TextStyle(
                        color: Colors.white, // Définir la couleur du texte
                      ),
                    ),            
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              elevation: 0, 
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
            ),
            drawerTheme: DrawerThemeData(
              backgroundColor: Colors.grey[900],
            ),
          ),
          themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: MyHomePage(
            onThemeChanged: (value) {
              _isDarkTheme.value = value;
              _saveTheme(value); 
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MyHomePage({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = <String>[
    'Dashboard',
    'Portfolio',
    'Statistiques',
    'Maps',
  ];

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    PortfolioPage(),
    StatisticsPage(),
    MapsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilisation de Stack pour créer l'effet de flou
      body: Stack(
        children: [
          Positioned.fill(
            child: _pages.elementAt(_selectedIndex), 
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + 40,
                  color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.black.withOpacity(0.3) 
                        : Colors.white.withOpacity(0.3),
                         child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                   
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 91, 
                color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black.withOpacity(0.3) 
                      : Colors.white.withOpacity(0.3),
                         child: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                      BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
                      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistiques'),
                      BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
                    ],
                    currentIndex: _selectedIndex,
                    elevation: 0,
                    selectedItemColor: Colors.blue,
                    unselectedItemColor: Colors.grey,
                    backgroundColor: Colors.transparent, 
                    type: BottomNavigationBarType.fixed, 
                    onTap: _onItemTapped,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'RealToken',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('RealTokens list'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealTokensPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(onThemeChanged: widget.onThemeChanged),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Historique des changements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealTokensPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealTokensPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
