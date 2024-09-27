import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import de la bibliothèque url_launcher
import 'api_service.dart';

String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

class RealTokensPage extends StatefulWidget {
  const RealTokensPage({super.key});

  @override
  _RealTokensPageState createState() => _RealTokensPageState();
}

class _RealTokensPageState extends State<RealTokensPage> {
  Future<List<dynamic>>? _realTokens;

  @override
  void initState() {
    super.initState();
    _realTokens = ApiService.fetchRealTokens(); // Charger les tokens RealTokens
  }

  // Méthode pour afficher les détails dans le BottomModalSheet
  void _showTokenDetails(BuildContext context, Map<String, dynamic> token) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (token['imageLink'] is List && token['imageLink'].isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: token['imageLink'][0],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else
                  const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                const SizedBox(height: 10),
                 Center(
                  child: Text(
                    token['fullName'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildDetailRow('Mise en vente', token['initialLaunchDate']['date'] ?? 'Non spécifié'),
                _buildDetailRow('Valeur de l\'investissement', formatCurrency(token['totalInvestment'] ?? 0)),
                _buildDetailRow('Valeur du bien', formatCurrency(token['underlyingAssetPrice'] ?? 0)),
                _buildDetailRow('Type de location', token['rentalType'] ?? 'Non spécifié'),
                _buildDetailRow('Premier loyer', token['rentStartDate']['date'] ?? 'Non spécifié'),
                _buildDetailRow('Logements loués', '${token['rentedUnits'] ?? 'Non spécifié'} / ${token['totalUnits'] ?? 'Non spécifié'}'),
                _buildDetailRow('Loyer brut mensuel', formatCurrency(token['grossRentMonth'] ?? 0)),
                _buildDetailRow('Loyer net mensuel', formatCurrency(token['netRentMonth'] ?? 0)),
                _buildDetailRow('Rendement annuel', '${token['annualPercentageYield']?.toStringAsFixed(2) ?? 'Non spécifié'}%'),
                _buildDetailRow('Année de construction', token['constructionYear']?.toString() ?? 'Non spécifié'),
                _buildDetailRow('Nombre d\'étages', token['propertyStories']?.toString() ?? 'Non spécifié'),
                _buildDetailRow('Nombre de logements', token['totalUnits']?.toString() ?? 'Non spécifié'),
                _buildDetailRow('Taille du terrain', '${token['lotSize']?.toStringAsFixed(2) ?? 'Non spécifié'} sqft'),
                _buildDetailRow('Taille intérieure', '${token['squareFeet']?.toStringAsFixed(2) ?? 'Non spécifié'} sqft'),
                const SizedBox(height: 20),
                // Bouton centré pour ouvrir le lien
                Center(
                  child: ElevatedButton(
                    onPressed: () => _launchURL(token['marketplaceLink']),
                    child: const Text('Voir sur RealT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Méthode pour ouvrir une URL dans le navigateur externe
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
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
      appBar: AppBar(
        title: const Text('RealTokens'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _realTokens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching RealTokens'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No RealTokens found'));
          }

          final realTokens = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: realTokens.length,
            itemBuilder: (context, index) {
              final token = realTokens[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showTokenDetails(context, token),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: token['imageLink'][0] ?? '',
                                width: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                            Expanded(
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
                                                fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Asset price: ${formatCurrency(token['totalInvestment'] ?? 0)}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      Text(
                                        'Token price: ${token['tokenPrice']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Expected Yield: ${token['annualPercentageYield']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
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
          );
        },
      ),
    );
  }
}
