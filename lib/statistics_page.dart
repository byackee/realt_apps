import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> _rentData = [];
  List<Map<String, dynamic>> _propertyData = []; // Pour le graphique en donut
  bool _isLoading = true;
  String _selectedPeriod = 'Semaine'; // Période par défaut

  @override
  void initState() {
    super.initState();
    _fetchRentData();
    _fetchPropertyData(); // Récupérer les données de la propriété pour le donut chart
  }

  // Récupérer les données du loyer via l'API
  Future<void> _fetchRentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> wallets = prefs.getStringList('ethAddresses') ?? [];
      List<Map<String, dynamic>> rentData = await ApiService.fetchRentData(wallets);
      setState(() {
        _rentData = rentData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching rent data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Récupérer les données de la propriété pour le donut chart
  Future<void> _fetchPropertyData() async {
    try {
      // Récupérer les tokens depuis l'API
      final walletTokens = await ApiService.fetchTokens();
      final rmmTokens = await ApiService.fetchRMMTokens();
      final realTokens = await ApiService.fetchRealTokens();

      // Fusionner les tokens du portefeuille et du RMM
      List<dynamic> allTokens = [...walletTokens[0]['balances'], ...rmmTokens];
      List<Map<String, dynamic>> propertyData = [];

      // Parcourir chaque token du portefeuille et du RMM
      for (var token in allTokens) {
        if (token != null && token['token'] != null && token['token']['address'] != null) {
          final tokenAddress = token['token']['address'].toLowerCase();

          // Correspondre avec les RealTokens
          final matchingRealToken = realTokens.firstWhere(
            (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
            orElse: () => null,
          );

          if (matchingRealToken != null && matchingRealToken['propertyType'] != null) {
            final propertyType = matchingRealToken['propertyType'];

            // Vérifiez si le type de propriété existe déjà dans propertyData
            final existingPropertyType = propertyData.firstWhere(
              (data) => data['propertyType'] == propertyType,
              orElse: () => <String, dynamic>{}, // Renvoie un map vide si aucune correspondance n'est trouvée
            );

            if (existingPropertyType.isNotEmpty) {
              // Incrémenter le compte si la propriété existe déjà
              existingPropertyType['count'] += 1;
            } else {
              // Ajouter une nouvelle entrée si la propriété n'existe pas encore
              propertyData.add({'propertyType': propertyType, 'count': 1});
            }
          }
        } else {
          print('Invalid token or missing address for token: $token');
        }
      }

      setState(() {
        _propertyData = propertyData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching property data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mapper les types de propriété aux titres correspondants
  String getPropertyTypeName(int propertyType) {
    switch (propertyType) {
      case 1:
        return 'Single Family';
      case 2:
        return 'Multi Family';
      case 3:
        return 'Commercial';
      default:
        return 'Unknown';
    }
  }

  // Calculer les données pour le graphique en donut
  List<PieChartSectionData> _buildDonutChartData() {
    return _propertyData.map((data) {
      final double percentage = (data['count'] / _propertyData.fold(0.0, (double sum, item) => sum + item['count'])) * 100;
      return PieChartSectionData(
        value: data['count'].toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',  // Afficher le pourcentage
        color: _getPropertyColor(data['propertyType']),
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // Assigner des couleurs selon les types de propriété
  Color _getPropertyColor(int propertyType) {
    switch (propertyType) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Construire la légende sous le donut chart
  Widget _buildLegend() {
    return Column(
      children: _propertyData.map((data) {
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getPropertyColor(data['propertyType']),
            ),
            const SizedBox(width: 8),
            Text(getPropertyTypeName(data['propertyType'])),
          ],
        );
      }).toList(),
    );
  }

  // Regrouper les données en fonction de la période sélectionnée
  List<Map<String, dynamic>> _groupRentDataByPeriod() {
    if (_selectedPeriod == 'Semaine') {
      return _groupByWeek(_rentData);
    } else if (_selectedPeriod == 'Mois') {
      return _groupByMonth(_rentData);
    } else {
      return _groupByYear(_rentData);
    }
  }

  // Fonction pour regrouper par semaine
  List<Map<String, dynamic>> _groupByWeek(List<Map<String, dynamic>> data) {
    Map<String, double> groupedData = {};
    for (var entry in data) {
      DateTime date = DateTime.parse(entry['date']);
      String weekKey = "${date.year}-Semaine ${_weekNumber(date)}";
      groupedData[weekKey] = (groupedData[weekKey] ?? 0) + entry['rent'];
    }
    return groupedData.entries
        .map((entry) => {'date': entry.key, 'rent': entry.value})
        .toList();
  }

  // Fonction pour regrouper par mois
  List<Map<String, dynamic>> _groupByMonth(List<Map<String, dynamic>> data) {
    Map<String, double> groupedData = {};
    for (var entry in data) {
      DateTime date = DateTime.parse(entry['date']);
      String monthKey = DateFormat('yyyy-MM').format(date);
      groupedData[monthKey] = (groupedData[monthKey] ?? 0) + entry['rent'];
    }
    return groupedData.entries
        .map((entry) => {'date': entry.key, 'rent': entry.value})
        .toList();
  }

  // Fonction pour regrouper par année
  List<Map<String, dynamic>> _groupByYear(List<Map<String, dynamic>> data) {
    Map<String, double> groupedData = {};
    for (var entry in data) {
      DateTime date = DateTime.parse(entry['date']);
      String yearKey = date.year.toString();
      groupedData[yearKey] = (groupedData[yearKey] ?? 0) + entry['rent'];
    }
    return groupedData.entries
        .map((entry) => {'date': entry.key, 'rent': entry.value})
        .toList();
  }

  // Calculer le numéro de semaine d'une date
  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }

  // Construire les points pour le graphique des loyers
  List<FlSpot> _buildChartData(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      double rentValue = data[i]['rent']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), rentValue));
    }
    return spots;
  }

  // Construire les labels d'axe X avec les dates
  List<String> _buildDateLabels(List<Map<String, dynamic>> data) {
    return data.map((entry) => entry['date'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> groupedData = _groupRentDataByPeriod();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Graphique des loyers perçus',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildPeriodSelector(),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          List<String> labels = _buildDateLabels(groupedData);
                                          return Text(labels[value.toInt()]);
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  minX: 0,
                                  maxX: (groupedData.length - 1).toDouble(),
                                  minY: 0,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _buildChartData(groupedData),
                                      isCurved: true,
                                      barWidth: 3,
                                      color: Colors.blue,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Répartition des Tokens par Type de Propriété',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildDonutChartData(),
                                  centerSpaceRadius: 50,
                                  sectionsSpace: 2,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLegend(), // Ajouter la légende sous le graphique
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Créer la barre de sélection de période
  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton('Semaine', isFirst: true),
        _buildPeriodButton('Mois'),
        _buildPeriodButton('Année', isLast: true),
      ],
    );
  }

  // Créer chaque bouton de sélection de période
  Widget _buildPeriodButton(String period, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(20) : Radius.zero,
              right: isLast ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            period,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
