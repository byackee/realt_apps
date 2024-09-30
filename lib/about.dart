import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importer pour le copier dans le presse-papiers
import 'package:url_launcher/url_launcher.dart';  // Pour ouvrir les liens externes

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Section Nom et Version de l'application
            const SectionHeader(title: 'Application'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Nom de l\'application'),
              subtitle: Text('RealToken App'),
            ),
            const ListTile(
              leading: Icon(Icons.verified),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Auteur'),
              subtitle: Text('Byackee'),
            ),

            // Padding pour décaler les liens
            Padding(
              padding: const EdgeInsets.only(left: 32.0), // Décalage des ListTile pour LinkedIn et GitHub
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('LinkedIn'),
                    onTap: () => _launchURL('https://www.linkedin.com/in/vincent-fresnel/'),
                    visualDensity: const VisualDensity(vertical: -4), // Réduction de l'espace vertical
                  ),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('GitHub'),
                    onTap: () => _launchURL('https://github.com/byackee'),
                    visualDensity: const VisualDensity(vertical: -4), // Réduction de l'espace vertical
                  ),
                ],
              ),
            ),

            const Divider(),

            // Section Remerciements
            const SectionHeader(title: 'Remerciements'),
            const ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Merci à tous ceux qui ont contribué à ce projet.'),
              subtitle: Text(
                'Remerciements particuliers à @Sigri, @ehpst, et pitsbi pour leur soutien.',
              ),
            ),
            const Divider(),

            // Section Donation
            const SectionHeader(title: 'Faire un don'),
            const ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Soutenez le projet'),
              subtitle: Text(
                'Si vous aimez cette application et souhaitez soutenir son développement, vous pouvez faire un don.',
              ),
            ),

            // Boutons pour les donations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton PayPal
                ElevatedButton.icon(
                  onPressed: () {
                    _launchURL('https://paypal.me/byackee?country.x=FR&locale.x=fr_FR');
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('PayPal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                // Bouton Donation en Crypto
                ElevatedButton.icon(
                  onPressed: () {
                    _showCryptoAddressDialog(context);
                  },
                  icon: const Icon(Icons.currency_bitcoin),
                  label: const Text('Crypto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher une boîte de dialogue avec l'adresse crypto
  void _showCryptoAddressDialog(BuildContext context) {
    const cryptoAddress = '0x7f57f6ad25c501deb2fcaca863264f593efe31d8';  // Remplacez par votre adresse Ethereum

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adresse de Donation Crypto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Envoyez vos donations à l\'adresse suivante :'),
              const SizedBox(height: 10),
              SelectableText(
                cryptoAddress,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton pour copier l'adresse dans le presse-papiers
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: cryptoAddress)); // Copier l'adresse dans le presse-papiers
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adresse copiée dans le presse-papiers')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour ouvrir un portefeuille crypto
  void _openInWallet(String address) async {
    final walletUrl = 'ethereum:$address'; // URL pour ouvrir les wallets supportant ce format
    if (await canLaunch(walletUrl)) {
      await launch(walletUrl);
    } else {
      throw 'Impossible d\'ouvrir le wallet avec l\'adresse $address';
    }
  }

  // Fonction pour ouvrir une URL dans le navigateur
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir le lien $url';
    }
  }
}

// Widget pour afficher les en-têtes de section
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
