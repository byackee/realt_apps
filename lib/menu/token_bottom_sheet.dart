import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import '../generated/l10n.dart'; // Import pour les traductions

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
                Center(
                  child: Text(
                    token['fullName'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 5), // Réduit l'espacement

                // TabBar pour les différents onglets
                TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: S.of(context).properties), // Utilisation de la traduction
                    Tab(text: S.of(context).finances), // Utilisation de la traduction
                    Tab(text: S.of(context).others), // Utilisation de la traduction
                    Tab(text: S.of(context).insights), // Utilisation de la traduction
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
                            Text(
                              S.of(context).characteristics, // Utilisation de la traduction
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(S.of(context).constructionYear, token['constructionYear']?.toString() ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).propertyStories, token['propertyStories']?.toString() ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).totalUnits, token['totalUnits']?.toString() ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).lotSize, '${token['lotSize']?.toStringAsFixed(2) ?? S.of(context).notSpecified} sqft'),
                            _buildDetailRow(S.of(context).squareFeet, '${token['squareFeet']?.toStringAsFixed(2) ?? S.of(context).notSpecified} sqft'),
                            const SizedBox(height: 20),
                            Text(
                              S.of(context).offering, // Utilisation de la traduction
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(S.of(context).initialLaunchDate, token['initialLaunchDate'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).rentalType, token['rentalType'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).rentStartDate, token['rentStartDate'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).rentedUnits, '${token['rentedUnits'] ?? S.of(context).notSpecified} / ${token['totalUnits'] ?? S.of(context).notSpecified}'),
                          ],
                        ),
                      ),
                      
                      // Onglet Finances
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDetailRow(S.of(context).totalInvestment, formatCurrency(token['totalInvestment'] ?? 0)),
                            _buildDetailRow(S.of(context).underlyingAssetPrice, formatCurrency(token['underlyingAssetPrice'] ?? 0)),
                            _buildDetailRow(S.of(context).initialMaintenanceReserve, formatCurrency(token['initialMaintenanceReserve'] ?? 0)),
                            _buildDetailRow(S.of(context).grossRentMonth, formatCurrency(token['grossRentMonth'] ?? 0)),
                            _buildDetailRow(S.of(context).netRentMonth, formatCurrency(token['netRentMonth'] ?? 0)),
                            _buildDetailRow(S.of(context).annualPercentageYield, '${token['annualPercentageYield']?.toStringAsFixed(2) ?? S.of(context).notSpecified}%'),
                          ],
                        ),
                      ),
                      
                      // Onglet Autres avec section Blockchain uniquement
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).blockchain, // Utilisation de la traduction
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(S.of(context).tokenAddress, token['ethereumContract'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).network, token['blockchainAddresses']?['ethereum']?['chainName'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).tokenSymbol, token['tokenSymbol'] ?? S.of(context).notSpecified),
                            _buildDetailRow(S.of(context).contractType, token['contractType'] ?? S.of(context).notSpecified),
                          ],
                        ),
                      ),
                      
                      // Onglet Insights (Graphique de l'évolution du yield et du prix avec pastille de statut de location)
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Pastille de couleur en fonction du statut de location
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getRentalStatusColor(
                                      token['rentedUnits'] ?? 0, // Nombre de logements loués
                                      token['totalUnits'] ?? 1,  // Nombre total de logements
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  S.of(context).rentalStatus, // Utilisation de la traduction
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            // Ajout du texte pour indiquer le pourcentage des logements loués
                            Text(
                              '${S.of(context).rentedUnits} : ${token['rentedUnits'] ?? S.of(context).notSpecified} / ${token['totalUnits'] ?? S.of(context).notSpecified}',
                              style: const TextStyle(fontSize: 13),
                            ),

                            const SizedBox(height: 10),

                            // Graphique du rendement (Yield)
                            Text(
                              S.of(context).yieldEvolution, // Utilisation de la traduction
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildYieldChartOrMessage(context, token['historic']?['yields'] ?? [], token['historic']?['init_yield']),
                            
                            const SizedBox(height: 20),

                            // Graphique des prix
                            Text(
                              S.of(context).priceEvolution, // Utilisation de la traduction
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            _buildPriceChartOrMessage(context, token['historic']?['prices'] ?? [], token['historic']?['init_price']),
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
                    height: 36,
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _launchURL(token['marketplaceLink']),
                      child: Text(S.of(context).viewOnRealT), // Utilisation de la traduction
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
Widget _buildYieldChartOrMessage(BuildContext context, List<dynamic> yields, double? initYield) {
  if (yields.length <= 1) {
    // Afficher le message si une seule donnée est disponible
    return Text(
      "${S.of(context).noYieldEvolution} ${yields.isNotEmpty ? yields.first['yield'].toStringAsFixed(2) : S.of(context).notSpecified}",
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
          "${S.of(context).yieldEvolutionPercentage} ${percentageChange.toStringAsFixed(2)}%",
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}


// Méthode pour afficher soit le graphique des prix, soit un message, avec % évolution
Widget _buildPriceChartOrMessage(BuildContext context, List<dynamic> prices, double? initPrice) {
  if (prices.length <= 1) {
    // Afficher le message si une seule donnée est disponible
    return Text(
      "${S.of(context).noPriceEvolution} ${prices.isNotEmpty ? prices.first['price'].toStringAsFixed(2) : S.of(context).notSpecified}",
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
          "${S.of(context).priceEvolutionPercentage} ${percentageChange.toStringAsFixed(2)}%",
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
    // Vérifier que 'timsync' est une chaîne de caractères valide pour créer la date
    if (yields[i]['timsync'] != null && yields[i]['timsync'] is String) {
      DateTime date = DateTime.parse(yields[i]['timsync']);
      double x = i.toDouble(); // Utiliser un indice pour l'axe X

      // Vérification que le yield est bien un nombre et est converti correctement
      double y = yields[i]['yield'] != null
          ? double.tryParse(yields[i]['yield'].toString()) ?? 0
          : 0;

      // Limiter la valeur de `y` à 2 décimales
      y = double.parse(y.toStringAsFixed(2));

      spots.add(FlSpot(x, y));
      dateLabels.add(DateFormat('MM/yyyy').format(date)); // Ajouter la date formatée en mois/année
    }
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
                // Limiter les valeurs à 2 décimales pour l'axe des Y
                return Text(
                  value.toStringAsFixed(2), // Limite à 2 décimales
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
                  value.toStringAsFixed(2), // Limiter les décimales à 2 chiffres
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

// Méthode pour déterminer la couleur de la pastille en fonction du taux de location
Color getRentalStatusColor(int rentedUnits, int totalUnits) {
  if (rentedUnits == 0) {
    return Colors.red; // Aucun logement loué
  } else if (rentedUnits == totalUnits) {
    return Colors.green; // Tous les logements sont loués
  } else {
    return Colors.orange; // Partiellement loué
  }
}


// Méthode pour ouvrir une URL dans le navigateur externe
Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Impossible d\'ouvrir l\'URL: $url';
  }
}
