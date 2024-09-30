import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_evm_addresses_page.dart'; 
import '../main.dart'; // Importer le fichier contenant MyApp
import '../generated/l10n.dart'; // Importer le fichier généré pour les traductions

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsPage({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;
  String _selectedLanguage = 'en'; 
  final List<String> _languages = ['en', 'fr']; 

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'en'; 
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    MyApp.of(context)?.changeLanguage(language); // Mise à jour de la langue dans l'app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(S.of(context).settingsTitle)), // Utilisation de la traduction
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(S.of(context).darkTheme), // Utilisation de la traduction pour "Dark Theme"
              trailing: Switch(
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                  widget.onThemeChanged(value);
                  _saveTheme(value); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).themeUpdated(value ? S.of(context).dark : S.of(context).light))),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).language), // Utilisation de la traduction pour "Language"
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: _languages.map((String languageCode) {
                  return DropdownMenuItem<String>(
                    value: languageCode,
                    child: Text(languageCode == 'en' ? S.of(context).english : S.of(context).french), // Traductions des langues
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                    _saveLanguage(newValue); // Sauvegarder et changer la langue
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).languageUpdated(newValue == 'en' ? S.of(context).english : S.of(context).french))),
                    );
                  }
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).manageEvmAddresses), // Utilisation de la traduction pour "Manage EVM Addresses"
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageEvmAddressesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
