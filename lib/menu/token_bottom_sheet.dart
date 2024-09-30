import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

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
      return DefaultTabController(
        length: 4, // Quatre onglets
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du token
                CachedNetworkImage(
                  imageUrl: token['imageLink'] ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                
                // Titre du token
                // Titre du token
Center(
  child: Text(
    token['fullName'],
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  ),
),

// Ajuste ou supprime cette SizedBox pour réduire l'espacement
const SizedBox(height: 5), // Réduit l'espacement ou retire cette ligne

// TabBar pour les différents onglets
TabBar(
  labelColor: Theme.of(context).primaryColor,
  unselectedLabelColor: Colors.grey,
  tabs: const [
    Tab(text: 'Propriétés'),
    Tab(text: 'Finances'),
    Tab(text: 'Autres'),
    Tab(text: 'Insights'),
  ],
),

                
                const SizedBox(height: 10),
                
                // TabBarView pour le contenu de chaque onglet
                SizedBox(
                  height: 300, // Ajuster selon la hauteur du contenu
                  child: TabBarView(
                    children: [
                      // Onglet Propriétés avec deux sections (Propriétés et Offering)
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Caractéristiques',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow('Année de construction', token['constructionYear']?.toString() ?? 'Non spécifié'),
                            _buildDetailRow('Nombre d\'étages', token['propertyStories']?.toString() ?? 'Non spécifié'),
                            _buildDetailRow('Nombre de logements', token['totalUnits']?.toString() ?? 'Non spécifié'),
                            _buildDetailRow('Taille du terrain', '${token['lotSize']?.toStringAsFixed(2) ?? 'Non spécifié'} sqft'),
                            _buildDetailRow('Taille intérieure', '${token['squareFeet']?.toStringAsFixed(2) ?? 'Non spécifié'} sqft'),
                            const SizedBox(height: 20),
                            const Text(
                              'Offering',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow('Mise en vente', token['initialLaunchDate'] ?? 'Non spécifié'),
                            _buildDetailRow('Type de location', token['rentalType'] ?? 'Non spécifié'),
                            _buildDetailRow('Premier loyer', token['rentStartDate'] ?? 'Non spécifié'),
                            _buildDetailRow('Logements loués', '${token['rentedUnits'] ?? 'Non spécifié'} / ${token['totalUnits'] ?? 'Non spécifié'}'),
                          ],
                        ),
                      ),
                      
                      // Onglet Finances
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDetailRow('Valeur de l\'investissement', formatCurrency(token['totalInvestment'] ?? 0)),
                            _buildDetailRow('Valeur du bien', formatCurrency(token['underlyingAssetPrice'] ?? 0)),
                            _buildDetailRow('Réserve de maintenance', formatCurrency(token['initialMaintenanceReserve'] ?? 0)),
                            _buildDetailRow('Loyer brut mensuel', formatCurrency(token['grossRentMonth'] ?? 0)),
                            _buildDetailRow('Loyer net mensuel', formatCurrency(token['netRentMonth'] ?? 0)),
                            _buildDetailRow('Rendement annuel', '${token['annualPercentageYield']?.toStringAsFixed(2) ?? 'Non spécifié'}%'),
                          ],
                        ),
                      ),
                      
                      // Onglet Autres avec section Blockchain uniquement
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Blockchain',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow('Token address', token['ethereumContract'] ?? 'Non spécifié'),
                            _buildDetailRow('Network', token['blockchainAddresses']?['ethereum']?['chainName'] ?? 'Non spécifié'),
                            _buildDetailRow('Token Symbol', token['tokenSymbol'] ?? 'Non spécifié'),
                            _buildDetailRow('Contract Type', token['contractType'] ?? 'Non spécifié'),
                          ],
                        ),
                      ),
                      
                      // Onglet Insights (Graphique de l'évolution du yield et du prix)
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Évolution du rendement (Yield)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildYieldChartOrMessage(token['historic']?['yields'] ?? [], token['historic']?['init_yield']),
                            
                            const SizedBox(height: 20),

                            const Text(
                              'Évolution des prix',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildPriceChartOrMessage(token['historic']?['prices'] ?? [], token['historic']?['init_price']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Bouton pour voir sur RealT
                Center(
                  child: SizedBox(
                    height: 36, // Hauteur réduite du bouton
                    width: 150, // Optionnel : ajuster la largeur pour un bouton plus petit
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Ajuster les marges internes
                        textStyle: const TextStyle(fontSize: 12), // Taille du texte réduite
                      ),
                      onPressed: () => _launchURL(token['marketplaceLink']),
                      child: const Text('Voir sur RealT'),
                    ),
                  ),
                ),
              ],
            ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}

// Méthode pour afficher soit le graphique du yield, soit un message, avec % évolution
Widget _buildYieldChartOrMessage(List<dynamic> yields, double? initYield) {
  if (yields.length <= 1) {
    // Afficher le message si une seule donnée est disponible
    return Text(
      "Pas d'évolution du rendement (yield). La dernière valeur est : ${yields.isNotEmpty ? yields.first['yield'].toStringAsFixed(2) : 'Non spécifié'}",
      style: const TextStyle(fontSize: 13),
    );
  } else {
    // Calculer l'évolution en pourcentage
    double lastYield = yields.last['yield']?.toDouble() ?? 0;
    double percentageChange = ((lastYield - (initYield ?? lastYield)) / (initYield ?? lastYield)) * 100;

    // Afficher le graphique et le % d'évolution
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYieldChart(yields),
        const SizedBox(height: 10),
        Text(
          "Évolution du rendement : ${percentageChange.toStringAsFixed(2)}%",
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

// Méthode pour afficher soit le graphique des prix, soit un message, avec % évolution
Widget _buildPriceChartOrMessage(List<dynamic> prices, double? initPrice) {
  if (prices.length <= 1) {
    // Afficher le message si une seule donnée est disponible
    return Text(
      "Pas d'évolution des prix. Le dernier prix est : ${prices.isNotEmpty ? prices.first['price'].toStringAsFixed(2) : 'Non spécifié'}",
      style: const TextStyle(fontSize: 13),
    );
  } else {
    // Calculer l'évolution en pourcentage
    double lastPrice = prices.last['price']?.toDouble() ?? 0;
    double percentageChange = ((lastPrice - (initPrice ?? lastPrice)) / (initPrice ?? lastPrice)) * 100;

    // Afficher le graphique et le % d'évolution
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceChart(prices),
        const SizedBox(height: 10),
        Text(
          "Évolution des prix : ${percentageChange.toStringAsFixed(2)}%",
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

// Méthode pour construire le graphique du yield
Widget _buildYieldChart(List<dynamic> yields) {
  List<FlSpot> spots = [];
  List<String> dateLabels = [];

  for (int i = 0; i < yields.length; i++) {
    DateTime date = DateTime.parse(yields[i]['timsync']);
    double x = i.toDouble(); // Utiliser un indice pour l'axe X
    double y = yields[i]['yield']?.toDouble() ?? 0;

    spots.add(FlSpot(x, y));
    dateLabels.add(DateFormat('MM/yyyy').format(date)); // Ajouter la date formatée en mois/année
  }

  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Désactiver l'axe du haut
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dateLabels.length) {
                  return Text(dateLabels[value.toInt()],
                      style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
              interval: 1, // Afficher une date à chaque intervalle
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Ajouter un espace réservé pour afficher correctement les valeurs
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1), // Limiter les décimales à 1 chiffre
                  style: const TextStyle(fontSize: 10), // Réduire la taille du texte
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Désactiver l'axe de droite
          ),
        ),
        minX: spots.isNotEmpty ? spots.first.x : 0,
        maxX: spots.isNotEmpty ? spots.last.x : 0,
        minY: spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b)
            : 0,
        maxY: spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
            : 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    ),
  );
}

// Méthode pour construire le graphique des prix
Widget _buildPriceChart(List<dynamic> prices) {
  List<FlSpot> spots = [];
  List<String> dateLabels = [];

  for (int i = 0; i < prices.length; i++) {
    DateTime date = DateTime.parse(prices[i]['timsync']);
    double x = i.toDouble(); // Utiliser un indice pour l'axe X
    double y = prices[i]['price']?.toDouble() ?? 0;

    spots.add(FlSpot(x, y));
    dateLabels.add(DateFormat('MM/yyyy').format(date)); // Ajouter la date formatée en mois/année
  }

  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Désactiver l'axe du haut
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dateLabels.length) {
                  return Text(dateLabels[value.toInt()],
                      style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
              interval: 1, // Afficher une date à chaque intervalle
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Ajouter un espace réservé pour afficher correctement les valeurs
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1), // Limiter les décimales à 1 chiffre
                  style: const TextStyle(fontSize: 10), // Réduire la taille du texte
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Désactiver l'axe de droite
          ),
        ),
        minX: spots.isNotEmpty ? spots.first.x : 0,
        maxX: spots.isNotEmpty ? spots.last.x : 0,
        minY: spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b)
            : 0,
        maxY: spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
            : 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
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
