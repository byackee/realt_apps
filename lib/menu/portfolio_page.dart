import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../api/data_manager.dart'; 
import 'portfolio_display_1.dart';
import 'portfolio_display_2.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _isDisplay1 = true; 
  String _searchQuery = ''; 
  String _sortOption = 'Name'; 
  bool _isAscending = true;
  String? _selectedCity; // Ville sélectionnée pour le filtrage

  @override
  void initState() {
    super.initState();
    final dataManager = Provider.of<DataManager>(context, listen: false);
    dataManager.fetchAndCalculateData(); 
    _loadDisplayPreference(); 
  }

  Future<void> _loadDisplayPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDisplay1 = prefs.getBool('isDisplay1') ?? true; 
    });
  }

  Future<void> _saveDisplayPreference(bool isDisplay1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDisplay1', isDisplay1);
  }

  void _toggleDisplay() {
    setState(() {
      _isDisplay1 = !_isDisplay1;
    });
    _saveDisplayPreference(_isDisplay1); 
  }

  List<Map<String, dynamic>> _filterAndSortPortfolio(List<Map<String, dynamic>> portfolio) {
    List<Map<String, dynamic>> filteredPortfolio = portfolio
        .where((token) =>
            token['fullName'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
            (_selectedCity == null || token['fullName'].contains(_selectedCity!)))
        .toList();

    if (_sortOption == 'Name') {
      filteredPortfolio.sort((a, b) =>
          _isAscending ? a['shortName'].compareTo(b['shortName']) : b['shortName'].compareTo(a['shortName']));
    } else if (_sortOption == 'Value') {
      filteredPortfolio.sort((a, b) => _isAscending
          ? a['totalValue'].compareTo(b['totalValue'])
          : b['totalValue'].compareTo(a['totalValue']));
    } else if (_sortOption == 'APY') {
      filteredPortfolio.sort((a, b) => _isAscending
          ? a['annualPercentageYield'].compareTo(b['annualPercentageYield'])
          : b['annualPercentageYield'].compareTo(a['annualPercentageYield']));
    }

    return filteredPortfolio;
  }

  // Méthode pour obtenir la liste unique des villes à partir des noms complets (fullName)
  List<String> _getUniqueCities(List<Map<String, dynamic>> portfolio) {
    final cities = portfolio.map((token) {
      List<String> parts = token['fullName'].split(',');
      return parts.length >= 2 ? parts[1].trim() : 'Ville inconnue';
    }).toSet().toList();
    cities.sort(); 
    return cities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataManager>(
        builder: (context, dataManager, child) {
         

          final sortedFilteredPortfolio = _filterAndSortPortfolio(dataManager.portfolio);
          final uniqueCities = _getUniqueCities(dataManager.portfolio); 

          return Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40),
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    primary: false,
                    floating: true,
                    snap: true,
                    title: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(_isDisplay1 ? Icons.view_module : Icons.view_list),
                          onPressed: _toggleDisplay,
                        ),
                        const SizedBox(width: 8.0),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.location_city),
                          onSelected: (String value) {
                            setState(() {
                              _selectedCity = value == 'All' ? null : value;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(
                                value: 'All',
                                child: Text('All Cities'),
                              ),
                              ...uniqueCities.map((city) => PopupMenuItem(
                                    value: city,
                                    child: Text(city),
                                  )),
                            ];
                          },
                        ),
                        const SizedBox(width: 8.0),

                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              if (value == 'asc' || value == 'desc') {
                                _isAscending = (value == 'asc');
                              } else {
                                _sortOption = value;
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(
                                value: 'Name',
                                child: Text('Sort by Name'),
                              ),
                              const PopupMenuItem(
                                value: 'Value',
                                child: Text('Sort by Value'),
                              ),
                              const PopupMenuItem(
                                value: 'APY',
                                child: Text('Sort by APY'),
                              ),
                              const PopupMenuDivider(),
                              CheckedPopupMenuItem(
                                value: 'asc',
                                checked: _isAscending,
                                child: const Text('Ascending'),
                              ),
                              CheckedPopupMenuItem(
                                value: 'desc',
                                checked: !_isAscending,
                                child: const Text('Descending'),
                              ),
                            ];
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ];
              },
              body: _isDisplay1
                  ? PortfolioDisplay1(portfolio: sortedFilteredPortfolio)
                  : PortfolioDisplay2(portfolio: sortedFilteredPortfolio),
            ),
          );
        },
      ),
    );
  }
}
