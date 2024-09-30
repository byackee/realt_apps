import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Import de la bibliothèque intl
import 'package:url_launcher/url_launcher.dart'; // Import de la bibliothèque url_launcher
import 'package:RealToken/menu/token_bottom_sheet.dart';

// Fonction de formatage des valeurs monétaires avec des espaces pour les milliers
String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR',  // Utilisez 'fr_FR' pour les espaces entre milliers
    symbol: '\$',     // Symbole de la devise
    decimalDigits: 2, // Nombre de chiffres après la virgule
  );
  return formatter.format(value);
}

class PortfolioDisplay1 extends StatelessWidget {
  final List<Map<String, dynamic>> portfolio;

  const PortfolioDisplay1({Key? key, required this.portfolio}) : super(key: key);


  // Méthode pour ouvrir une URL dans le navigateur externe
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // Ouvrir le lien dans le navigateur
    } else {
      throw 'Impossible d\'ouvrir l\'URL: $url'; // Gérer l'erreur si l'URL ne peut pas être ouverte
    }
  }

  // Méthode pour construire les lignes de détails
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Taille réduite de 14 à 13
          ),
          Text(value, style: const TextStyle(fontSize: 13)), // Taille réduite de 14 à 13
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        itemCount: portfolio.length,
        itemBuilder: (context, index) {
          final token = portfolio[index];
          final isWallet = token['source'] == 'Wallet'; // Vérification de la source Wallet
          final isRMM = token['source'] == 'RMM'; // Vérification de la source RMM

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => showTokenDetails(context, token), // Utilisation de la modal réutilisable
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image ajustée à la même hauteur que la carte, arrondie seulement à gauche
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: token['imageLink'] ?? '',
                            width: 150,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(), // Placeholder pendant le chargement
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error), // En cas d'erreur
                          ),
                        ),
                        Expanded(
                          // Carte à droite de l'image, arrondie seulement à droite
                          child: Card(
                            elevation: 0, // Enlever l'ombre
                            margin: EdgeInsets.zero, // Enlever l'espace entre l'image et la carte
                            color: Theme.of(context).cardColor, // Applique la couleur du thème pour la carte
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        token['shortName'] ?? 'Nom indisponible',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // Pastille pour source avec texte "Wallet", "RMM", ou "Other"
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0, vertical: 3.0),
                                        decoration: BoxDecoration(
                                          color: isWallet
                                              ? Colors.green
                                              : isRMM
                                                  ? Colors.blue
                                                  : Colors.grey, // Couleur selon la source
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          isWallet
                                              ? 'Wallet'
                                              : isRMM
                                                  ? 'RMM'
                                                  : 'Other', // Texte selon la source
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Affichage de Amount et Total Tokens
                                  Text(
                                    'Total Value: ${formatCurrency(token['totalValue'])}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    'Amount: ${token['amount']} / ${token['totalTokens']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  // Affichage de l'APY arrondi à 2 chiffres après la virgule
                                  Text(
                                    'APY: ${token['annualPercentageYield']?.toStringAsFixed(2)}%',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Revenue:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Day',
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['dailyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Text('Month',
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['monthlyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Text('Year',
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['yearlyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
