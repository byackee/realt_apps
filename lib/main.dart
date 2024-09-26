import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realt_apps/statistics_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Utilisation d'un ValueNotifier pour gérer le thème sombre/clair
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
          title: 'Flutter Demo',
          theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          home: MyHomePage(
            onThemeChanged: (value) {
              _isDarkTheme.value = value;
              _saveTheme(value); // Sauvegarder le thème choisi
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MyHomePage({required this.onThemeChanged, super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = <String>[
    'Dashboard',
    'Statistiques',
    'Maps',
    'Portfolio',
  ];

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    StatisticsPage(),
    MapsPage(),
    PortfolioPage(), // Ici la page Portfolio sans AppBar
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
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
                    'assets/logo.png', // Chemin de votre image
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10), // Espacement entre l'image et le texte
                  const Text(
                    'RealT App',
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
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistiques'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
