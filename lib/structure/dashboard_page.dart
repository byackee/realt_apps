import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/data_manager.dart';
import 'package:intl/intl.dart';
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final dataManager = Provider.of<DataManager>(context, listen: false);
  dataManager.fetchAndCalculateData(); // Charger les données du portefeuille
  dataManager.fetchRentData(); // Charger les données de loyer
  dataManager.fetchPropertyData(); // Charger les données de propriété
}

  // Récupère la dernière valeur de loyer
  String _getLastRentReceived(DataManager dataManager) {
    final rentData = dataManager.rentData;

    if (rentData.isEmpty) {
      return S.of(context).noRentReceived; // Utilisation de la traduction
    }

    // Trier les loyers par date pour trouver la plus récente
    rentData.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    
    // Récupérer le dernier loyer
    final lastRent = rentData.first['rent'];
    return formatCurrency(lastRent);
  }

  // Groupement mensuel sur les 12 derniers mois glissants pour la carte Rendement
  List<double> _getLast12MonthsRent(DataManager dataManager) {
    final currentDate = DateTime.now();
    final rentData = dataManager.rentData;

    Map<String, double> monthlyRent = {};

    for (var rentEntry in rentData) {
      DateTime date = DateTime.parse(rentEntry['date']);
      if (date.isAfter(currentDate.subtract(const Duration(days: 365)))) {
        String monthKey = DateFormat('yyyy-MM').format(date);
        monthlyRent[monthKey] = (monthlyRent[monthKey] ?? 0) + rentEntry['rent'];
      }
    }

    // Assurer que nous avons les 12 derniers mois dans l'ordre
    List<String> sortedMonths = List.generate(12, (index) {
      DateTime date = DateTime(currentDate.year, currentDate.month - index, 1);
      return DateFormat('yyyy-MM').format(date);
    }).reversed.toList();

    return sortedMonths.map((month) => monthlyRent[month] ?? 0).toList();
  }

  // Méthode pour créer un mini graphique pour la carte Rendement
  Widget _buildMiniGraphForRendement(List<double> data, BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 60,
        width: 120,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: data.length.toDouble() - 1,
            minY: data.reduce((a, b) => a < b ? a : b),
            maxY: data.reduce((a, b) => a > b ? a : b),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 2,
                    color: Colors.blue,
                    strokeWidth: 0,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construction des cartes du Dashboard
  Widget _buildCard(String title, IconData icon, Widget firstChild, List<Widget> otherChildren, DataManager dataManager, BuildContext context, {bool hasGraph = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: Theme.of(context).cardColor, // Utilisation de la couleur du thème
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: title == S.of(context).rents ? Colors.green :
                             title == S.of(context).tokens ? Colors.orange :
                             title == S.of(context).properties ? Colors.blue :
                             title == S.of(context).portfolio ? Colors.black : Colors.blue, // Couleurs spécifiques
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19, // Légèrement augmenté
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                firstChild, // Première ligne stylisée
                const SizedBox(height: 3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: otherChildren, // Autres lignes inchangées
                ),
              ],
            ),
            const Spacer(),
            if (hasGraph)
              _buildMiniGraphForRendement(_getLast12MonthsRent(dataManager), context), // Graphique pour la carte Rendement uniquement
          ],
        ),
      ),
    );
  }

  // Construction d'une ligne pour afficher la valeur avant le texte
  Widget _buildValueBeforeText(String value, String text) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16, // Augmenter la taille de la police pour la valeur
            fontWeight: FontWeight.bold, // Mettre la valeur en gras
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    
    // Récupérer la couleur de texte à partir du thème actuel
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    // Récupérer la dernière valeur du loyer
    final lastRentReceived = _getLastRentReceived(dataManager);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Applique le background du thème
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 110.0, left: 12.0, right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligner tout à gauche
            children: [
              Text(
                S.of(context).hello, // Utilisation de la traduction
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left, // Alignement à gauche
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: S.of(context).lastRentReceived, // Utilisation de la traduction
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor, // Applique la couleur du thème
                      ),
                    ),
                    TextSpan(
                      text: lastRentReceived,
                      style: TextStyle(
                        fontSize: 18, // Augmenter la taille de la police
                        fontWeight: FontWeight.bold, // Texte en gras
                        color: textColor, // Applique la couleur du thème
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildCard(
                S.of(context).portfolio, // Utilisation de la traduction
                Icons.dashboard,
                _buildValueBeforeText(formatCurrency(dataManager.totalValue), S.of(context).totalPortfolio), // Première ligne
                [
                  Text('${S.of(context).wallet}: ${formatCurrency(dataManager.walletValue)}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).rmm}: ${formatCurrency(dataManager.rmmValue)}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).rwaHoldings}: ${formatCurrency(dataManager.rwaHoldingsValue)}',
                      style: const TextStyle(fontSize: 13)),
                ],
                dataManager,
                context,
              ),
              const SizedBox(height: 15),
              _buildCard(
                S.of(context).properties, // Utilisation de la traduction
                Icons.home,
                _buildValueBeforeText(
                    '${(dataManager.rentedUnits / dataManager.totalUnits * 100).toStringAsFixed(2)}%', S.of(context).rented),
                [
                  Text('${S.of(context).properties}: ${(dataManager.walletTokenCount +dataManager.rmmTokenCount)}',
                      style: const TextStyle(fontSize: 13)),
                   Text('${S.of(context).wallet}: ${dataManager.walletTokenCount}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).rmm}: ${dataManager.rmmTokenCount.toInt()}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).rentedUnits}: ${dataManager.rentedUnits} / ${dataManager.totalUnits}',
                      style: const TextStyle(fontSize: 13)),
                ],
                dataManager,
                context,
              ),
              const SizedBox(height: 15),
              _buildCard(
                S.of(context).tokens, // Utilisation de la traduction
                Icons.account_balance_wallet,
                _buildValueBeforeText('${dataManager.totalTokens}', S.of(context).totalTokens),
                [
                  Text('${S.of(context).wallet}: ${dataManager.walletTokensSums.toInt()}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).rmm}: ${dataManager.rmmTokensSums.toInt()}',
                      style: const TextStyle(fontSize: 13)),
                ],
                dataManager,
                context,
              ),
              const SizedBox(height: 15),
              _buildCard(
                S.of(context).rents, // Utilisation de la traduction
                Icons.attach_money,
                _buildValueBeforeText(
                    '${dataManager.averageAnnualYield.toStringAsFixed(2)}%', S.of(context).annualYield),
                [
                  Text('${S.of(context).daily}: ${formatCurrency(dataManager.dailyRent)}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).weekly}: ${formatCurrency(dataManager.weeklyRent)}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).monthly}: ${formatCurrency(dataManager.monthlyRent)}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${S.of(context).annually}: ${formatCurrency(dataManager.yearlyRent)}',
                      style: const TextStyle(fontSize: 13)),
                ],
                dataManager,
                context,
                hasGraph: true, // Seule la carte "Rendement" aura un graphique
              ),
              const SizedBox(height: 80), // Ajout d'un padding en bas pour laisser de l'espace pour la BottomBar
            ],
          ),
        ),
      ),
    );
  }
}
