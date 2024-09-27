import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'data_manager.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'Semaine';

  @override
  void initState() {
    super.initState();
    final dataManager = Provider.of<DataManager>(context, listen: false);
    dataManager.fetchRentData();
    dataManager.fetchPropertyData();
  }

  List<Map<String, dynamic>> _groupRentDataByPeriod(DataManager dataManager) {
    if (_selectedPeriod == 'Semaine') {
      return _groupByWeek(dataManager.rentData);
    } else if (_selectedPeriod == 'Mois') {
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
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 80.0), // Ajout du padding en haut et en bas
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Graphique des loyers perçus',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              rightTitles: AxisTitles(
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
                            borderData: FlBorderData(
                              show: false,
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
                elevation: 0,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Répartition des Tokens par Type de Propriété',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10), // Réduire l'espace ici
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
                      const SizedBox(height: 10), // Ajuster cet espace également
                      _buildLegend(dataManager),
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

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton('Semaine', isFirst: true),
        _buildPeriodButton('Mois'),
        _buildPeriodButton('Année', isLast: true),
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

  Color _getPropertyColor(int propertyType) {
    switch (propertyType) {
      case 1:
      return Colors.blue;      // Couleur pour le type de propriété 1
    case 2:
      return Colors.green;     // Couleur pour le type de propriété 2
    case 3:
      return Colors.orange;    // Couleur pour le type de propriété 3
    case 4:
      return Colors.red;       // Couleur pour le type de propriété 4
    case 5:
      return Colors.purple;    // Couleur pour le type de propriété 5
    case 6:
      return Colors.yellow;    // Couleur pour le type de propriété 6
    case 7:
      return Colors.teal;      // Couleur pour le type de propriété 7
    default:
      return Colors.grey;      // Couleur par défaut pour les types non spécifiés

    }
  }

  String getPropertyTypeName(int propertyType) {
    switch (propertyType) {
      case 1:
        return 'Single Family';
      case 2:
        return 'Multi Family';
      case 3:
        return 'Duplex';
      case 4:
        return 'Condominium';
      case 6:
        return 'Mixed-Use';
      case 8:
        return 'Multi Family';
      case 9:
        return 'Commercial';
      case 10:
        return 'SFR Portfolio';
      case 11:
        return 'MFR Portfolio';
      case 12:
        return 'Resort Bungalow';
      default:
        return 'Unknown';
    }
  }
}
