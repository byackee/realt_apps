import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../api/data_manager.dart';
import '../generated/l10n.dart'; // Import pour les traductions

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'Semaine'; // Peut être traduit

  // Carte des abréviations d'États des États-Unis à leurs noms complets
  final Map<String, String> _usStateAbbreviations = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming'
  };

  @override
  void initState() {
    super.initState();
    final dataManager = Provider.of<DataManager>(context, listen: false);
    dataManager.fetchRentData();
    dataManager.fetchPropertyData();
  }

  List<Map<String, dynamic>> _groupRentDataByPeriod(DataManager dataManager) {
    if (_selectedPeriod == S.of(context).week) {
      return _groupByWeek(dataManager.rentData);
    } else if (_selectedPeriod == S.of(context).month) {
      return _groupByMonth(dataManager.rentData);
    } else {
      return _groupByYear(dataManager.rentData);
    }
  }

  List<Map<String, dynamic>> _groupByWeek(List<Map<String, dynamic>> data) {
    Map<String, double> groupedData = {};
    for (var entry in data) {
      DateTime date = DateTime.parse(entry['date']);
      String weekKey = "${date.year}-S ${_weekNumber(date)}";
      groupedData[weekKey] = (groupedData[weekKey] ?? 0) + entry['rent'];
    }
    return groupedData.entries
        .map((entry) => {'date': entry.key, 'rent': entry.value})
        .toList();
  }

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

  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }

  List<FlSpot> _buildChartData(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      double rentValue = data[i]['rent']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), rentValue));
    }
    return spots;
  }

  List<String> _buildDateLabels(List<Map<String, dynamic>> data) {
    return data.map((entry) => entry['date'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    List<Map<String, dynamic>> groupedData = _groupRentDataByPeriod(dataManager);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 40.0, bottom: 80.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).rentGraph, // Traduction pour "Graphique des loyers perçus"
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildPeriodSelector(),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (groupedData.isNotEmpty
                                            ? (groupedData.length / 5).round()
                                            : 1)
                                        .toDouble(),
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(0),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (groupedData.isNotEmpty
                                            ? (groupedData.length / 6).round()
                                            : 1)
                                        .toDouble(),
                                    getTitlesWidget: (value, meta) {
                                      List<String> labels = _buildDateLabels(groupedData);
                                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: Text(
                                            labels[value.toInt()],
                                            style: const TextStyle(fontSize: 8),
                                          ),
                                        );
                                      } else {
                                        return const Text('');
                                      }
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
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
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).tokenDistribution, // Traduction pour "Répartition des Tokens par Type de Propriété"
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _buildDonutChartData(dataManager),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildLegend(dataManager),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
               // Donut Chart for token distribution by country
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).tokenDistributionByCountry, // "Répartition des Tokens par Pays"
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _buildDonutChartDataByCountry(dataManager),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                       const SizedBox(height: 10),
                      _buildLegendByCountry(dataManager),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Donut Chart for token distribution by region
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).tokenDistributionByRegion, // "Répartition des Tokens par Région"
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _buildDonutChartDataByRegion(dataManager),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      _buildLegendByRegion(dataManager),
                      ],
                    ),
                  ),
                ),
              ),             
              const SizedBox(height: 20),
              // Donut Chart for token distribution by city
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).tokenDistributionByCity, // "Répartition des Tokens par Ville"
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _buildDonutChartDataByCity(dataManager),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      _buildLegendByCity(dataManager),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton(S.of(context).week, isFirst: true), // Traduction pour "Semaine"
        _buildPeriodButton(S.of(context).month), // Traduction pour "Mois"
        _buildPeriodButton(S.of(context).year, isLast: true), // Traduction pour "Année"
      ],
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 6),
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

  List<PieChartSectionData> _buildDonutChartData(DataManager dataManager) {
    return dataManager.propertyData.map((data) {
      final double percentage = (data['count'] / dataManager.propertyData.fold(0.0, (double sum, item) => sum + item['count'])) * 100;
      return PieChartSectionData(
        value: data['count'].toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getPropertyColor(data['propertyType']),
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildDonutChartDataByCity(DataManager dataManager) {
    Map<String, int> cityCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String city = parts.length >= 2 ? parts[1].trim() : S.of(context).unknownCity;

      cityCount[city] = (cityCount[city] ?? 0) + 1;
    }

    return cityCount.entries.map((entry) {
      final double percentage = (entry.value / cityCount.values.fold(0, (sum, value) => sum + value)) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[cityCount.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildDonutChartDataByRegion(DataManager dataManager) {
    Map<String, int> regionCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String region = '';

      // Si la région contient des chiffres (par exemple, MI 48224), on extrait seulement les lettres
      if (parts.length >= 3 && RegExp(r'^[A-Z]{2}\s\d{5}$').hasMatch(parts[2].trim())) {
        region = parts[2].trim().substring(0, 2);
      } else if (parts.length >= 3) {
        region = parts[2].trim();
      }

      // Utiliser le nom complet de la région si applicable
      if (_usStateAbbreviations.containsKey(region)) {
        region = _usStateAbbreviations[region]!;
      }

      regionCount[region] = (regionCount[region] ?? 0) + 1;
    }

    return regionCount.entries.map((entry) {
      final double percentage = (entry.value / regionCount.values.fold(0, (sum, value) => sum + value)) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.accents[regionCount.keys.toList().indexOf(entry.key) % Colors.accents.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildDonutChartDataByCountry(DataManager dataManager) {
    Map<String, int> countryCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String country = '';

      // Si le pays est spécifié dans le dernier bloc, sinon États-Unis par défaut
      if (parts.length == 4) {
        country = parts[3].trim();
      } else {
        country = 'United States';
      }

      countryCount[country] = (countryCount[country] ?? 0) + 1;
    }

    return countryCount.entries.map((entry) {
      final double percentage = (entry.value / countryCount.values.fold(0, (sum, value) => sum + value)) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.cyan[100 * (countryCount.keys.toList().indexOf(entry.key) % 9)] ?? Colors.cyan,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegend(DataManager dataManager) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: dataManager.propertyData.map((data) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getPropertyColor(data['propertyType']),
            ),
            const SizedBox(width: 4),
            Text(getPropertyTypeName(data['propertyType'])),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegendByCountry(DataManager dataManager) {
    Map<String, int> countryCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String country = '';

      if (parts.length == 4) {
        country = parts[3].trim();
      } else {
        country = 'United States';
      }

      countryCount[country] = (countryCount[country] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: countryCount.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.cyan[100 * (countryCount.keys.toList().indexOf(entry.key) % 9)] ?? Colors.cyan,
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegendByRegion(DataManager dataManager) {
    Map<String, int> regionCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String regionCode = parts.length >= 3 ? parts[2].trim().substring(0, 2) : S.of(context).unknown;

      String regionName = _usStateAbbreviations[regionCode] ?? regionCode;

      regionCount[regionName] = (regionCount[regionName] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: regionCount.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.accents[regionCount.keys.toList().indexOf(entry.key) % Colors.accents.length],
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

Widget _buildLegendByCity(DataManager dataManager) {
    Map<String, int> cityCount = {};

    for (var token in dataManager.portfolio) {
      String fullName = token['fullName'];
      List<String> parts = fullName.split(',');
      String city = parts.length >= 2 ? parts[1].trim() : S.of(context).unknownCity;

      cityCount[city] = (cityCount[city] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: cityCount.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.primaries[cityCount.keys.toList().indexOf(entry.key) % Colors.primaries.length],
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getPropertyColor(int propertyType) {
    switch (propertyType) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.yellow;
      case 7:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String getPropertyTypeName(int propertyType) {
    switch (propertyType) {
      case 1:
        return S.of(context).singleFamily; // Traduction pour "Single Family"
      case 2:
        return S.of(context).multiFamily; // Traduction pour "Multi Family"
      case 3:
        return S.of(context).duplex; // Traduction pour "Duplex"
      case 4:
        return S.of(context).condominium; // Traduction pour "Condominium"
      case 6:
        return S.of(context).mixedUse; // Traduction pour "Mixed-Use"
      case 8:
        return S.of(context).multiFamily; // Traduction pour "Multi Family"
      case 9:
        return S.of(context).commercial; // Traduction pour "Commercial"
      case 10:
        return S.of(context).sfrPortfolio; // Traduction pour "SFR Portfolio"
      case 11:
        return S.of(context).mfrPortfolio; // Traduction pour "MFR Portfolio"
      case 12:
        return S.of(context).resortBungalow; // Traduction pour "Resort Bungalow"
      default:
        return S.of(context).unknown; // Traduction pour "Unknown"
    }
  }
}
