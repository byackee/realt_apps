import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importer url_launcher pour ouvrir des liens externes
import '../settings/settings_page.dart';  // Importer la page des paramètres
import '../real_tokens_page.dart';  // Importer la page des RealTokens
import '../about.dart';  // Importer la page About

class CustomDrawer extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const CustomDrawer({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Agrandissement de l'icône pour qu'elle corresponde à la hauteur des deux textes
                Image.asset(
                  'assets/logo.png',
                  width: 60,  // Ajuster la largeur de l'icône
                  height: 60, // Ajuster la hauteur de l'icône
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'RealToken',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'mobile app for Community',
                      style: TextStyle(
                        color: Colors.white70,  // Couleur légèrement plus claire
                        fontSize: 16,  // Taille légèrement plus petite
                      ),
                    ),
                  ],
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
                  builder: (context) => SettingsPage(onThemeChanged: onThemeChanged),
                ),
              );
            },
          ),
          const Spacer(),  // Utilisé pour pousser les éléments vers le bas
          const Divider(),  // Séparation visuelle
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              _launchFeedbackURL();
            },
          ),
          const SizedBox(height: 20),  // Ajout d'un espace vide pour remonter les éléments
        ],
      ),
    );
  }

  // Fonction pour ouvrir le lien Feedback dans le navigateur
  void _launchFeedbackURL() async {
    const url = 'https://github.com/RealToken-Community/realtoken-apps/issues';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir le lien $url';
    }
  }
}
