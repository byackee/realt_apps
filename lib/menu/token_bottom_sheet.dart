// token_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Fonction de formatage des valeurs monétaires avec des espaces pour les milliers
String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

// Fonction réutilisable pour afficher la BottomModalSheet avec les détails du token
void showTokenDetails(BuildContext context, Map<String, dynamic> token) {
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
              CachedNetworkImage(
                imageUrl: token['imageLink'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  token['fullName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildDetailRow('Mise en vente', token['initialLaunchDate'] ?? 'Non spécifié'),
              _buildDetailRow('Valeur de l\'investissement', formatCurrency(token['totalInvestment'] ?? 0)),
              _buildDetailRow('Valeur du bien', formatCurrency(token['underlyingAssetPrice'] ?? 0)),
              _buildDetailRow('Réserve de maintenance', formatCurrency(token['initialMaintenanceReserve'] ?? 0)),
              _buildDetailRow('Type de location', token['rentalType'] ?? 'Non spécifié'),
              _buildDetailRow('Premier loyer', token['rentStartDate'] ?? 'Non spécifié'),
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

// Méthode pour ouvrir une URL dans le navigateur externe
Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Impossible d\'ouvrir l\'URL: $url';
  }
}
