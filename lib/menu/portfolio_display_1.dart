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

// Fonction pour extraire le nom de la ville à partir du fullName
String extractCity(String fullName) {
  List<String> parts = fullName.split(',');
  return parts.length >= 2 ? parts[1].trim() : 'Ville inconnue';
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(value, style: const TextStyle(fontSize: 13)),
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
          final isWallet = token['source'] == 'Wallet'; 
          final isRMM = token['source'] == 'RMM'; 
          final city = extractCity(token['fullName'] ?? '');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => showTokenDetails(context, token),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Conteneur avec image et superposition du texte de la ville
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Image de l'avatar avec hauteur fixe
                              Container(
                                width: 150,
                                height: double.infinity,  // Hauteur ajustée à l'élément adjacent
                                child: CachedNetworkImage(
                                  imageUrl: token['imageLink'] ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              // Superposition du texte de la ville en bas de l'image
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  color: Colors.black54, 
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // Carte à droite de l'image
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: Theme.of(context).cardColor,
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
                                                  : Colors.grey,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          isWallet
                                              ? 'Wallet'
                                              : isRMM
                                                  ? 'RMM'
                                                  : 'Other',
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
