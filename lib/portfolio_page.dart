// portfolio_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import de SharedPreferences
import 'data_manager.dart'; // Import du DataManager
import 'portfolio_display_1.dart';
import 'portfolio_display_2.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _isDisplay1 = true; // Indicateur pour basculer entre les affichages
  String _searchQuery = ''; // Pour filtrer par nom de token
  String _sortOption = 'Name'; // Option de tri (Nom, Valeur, APY)
  bool _isAscending = true; // Indicateur de tri croissant/décroissant

  @override
  void initState() {
    super.initState();
    final dataManager = Provider.of<DataManager>(context, listen: false);
    dataManager.fetchAndCalculateData(); // Charger les données du portefeuille
    _loadDisplayPreference(); // Charger la préférence d'affichage
  }

  // Charger la préférence d'affichage depuis SharedPreferences
  Future<void> _loadDisplayPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDisplay1 = prefs.getBool('isDisplay1') ?? true; // Valeur par défaut: Display 1
    });
  }

  // Sauvegarder la préférence d'affichage dans SharedPreferences
  Future<void> _saveDisplayPreference(bool isDisplay1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDisplay1', isDisplay1);
  }

  // Basculer entre Display 1 et Display 2 et sauvegarder la préférence
  void _toggleDisplay() {
    setState(() {
      _isDisplay1 = !_isDisplay1;
    });
    _saveDisplayPreference(_isDisplay1); // Sauvegarder la préférence lors du basculement
  }

  // Filtrage et tri des tokens
  List<Map<String, dynamic>> _filterAndSortPortfolio(List<Map<String, dynamic>> portfolio) {
    List<Map<String, dynamic>> filteredPortfolio = portfolio
        .where((token) => token['shortName'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Tri en fonction de l'option sélectionnée
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

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<DataManager>(
      builder: (context, dataManager, child) {
        if (dataManager.portfolio.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Appliquer le filtre et le tri
        final sortedFilteredPortfolio = _filterAndSortPortfolio(dataManager.portfolio);

        return Padding( // Ajouter un padding ici
          padding: const EdgeInsets.only(top: kToolbarHeight +40), // Ajuste la valeur du padding selon ton besoin
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
