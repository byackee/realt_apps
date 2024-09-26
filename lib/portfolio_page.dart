import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import de SharedPreferences
import 'api_service.dart';
import 'portfolio_display_1.dart';
import 'portfolio_display_2.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Future<List<dynamic>>? _walletTokens;
  Future<List<dynamic>>? _rmmTokens;
  Future<List<dynamic>>? _realTokens;
  bool _isDisplay1 = true; // Indicateur pour basculer entre les affichages
  String _searchQuery = ''; // Pour filtrer par nom de token
  String _sortOption = 'Name'; // Option de tri (Nom, Valeur, APY)
  bool _isAscending = true; // Indicateur de tri croissant/décroissant

  @override
  void initState() {
    super.initState();
    _walletTokens = ApiService.fetchTokens();
    _rmmTokens = ApiService.fetchRMMTokens();
    _realTokens = ApiService.fetchRealTokens();
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

  // Filtrage des tokens par nom
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
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_walletTokens!, _rmmTokens!, _realTokens!]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading portfolio'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tokens found in portfolio'));
          }

          final walletTokens = snapshot.data![0][0]['balances'];
          final rmmTokens = snapshot.data![1];
          final realTokens = snapshot.data![2];

          final List<Map<String, dynamic>> portfolio = [];

          for (var walletToken in walletTokens) {
            final tokenAddress = walletToken['token']['address'].toLowerCase();
            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null) {
              final double tokenPrice = matchingRealToken['tokenPrice'];
              final totalValue = double.parse(walletToken['amount']) * tokenPrice;
              final dailyIncome = double.parse(walletToken['amount']) * matchingRealToken['netRentDayPerToken'];
              final monthlyIncome = double.parse(walletToken['amount']) * matchingRealToken['netRentMonthPerToken'];
              final yearlyIncome = double.parse(walletToken['amount']) * matchingRealToken['netRentYearPerToken'];

              portfolio.add({
                'shortName': matchingRealToken['shortName'],
                'imageLink': matchingRealToken['imageLink'][0],
                'amount': walletToken['amount'],
                'totalTokens': matchingRealToken['totalTokens'],
                'source': 'Wallet',
                'tokenPrice': tokenPrice,
                'totalValue': totalValue,
                'annualPercentageYield': matchingRealToken['annualPercentageYield'],
                'dailyIncome': dailyIncome,
                'monthlyIncome': monthlyIncome,
                'yearlyIncome': yearlyIncome,
                'initialLaunchDate': matchingRealToken['initialLaunchDate']?['date'],  // Date de lancement
                'totalInvestment': matchingRealToken['totalInvestment'],  // Valeur de l'investissement
                'underlyingAssetPrice': matchingRealToken['underlyingAssetPrice'],  // Valeur du bien
                'initialMaintenanceReserve': matchingRealToken['initialMaintenanceReserve'],  // Réserve de maintenance
                'rentalType': matchingRealToken['rentalType'],  // Type de location
                'rentStartDate': matchingRealToken['rentStartDate']?['date'],  // Premier loyer
                'rentedUnits': matchingRealToken['rentedUnits'],  // Logements loués
                'totalUnits': matchingRealToken['totalUnits'],  // Nombre total de logements
                'grossRentMonth': matchingRealToken['grossRentMonth'],  // Loyer brut mensuel
                'netRentMonth': matchingRealToken['netRentMonth'],  // Loyer net mensuel
                'constructionYear': matchingRealToken['constructionYear'],  // Année de construction
                'propertyStories': matchingRealToken['propertyStories'],  // Nombre d'étages
                'lotSize': matchingRealToken['lotSize'],  // Taille du terrain
                'squareFeet': matchingRealToken['squareFeet'],  // Taille intérieure
                'marketplaceLink': matchingRealToken['marketplaceLink'],  // Taille intérieure
                'propertyType': matchingRealToken['propertyType'], 
              });
            }
          }

          for (var rmmToken in rmmTokens) {
            final tokenAddress = rmmToken['token']['id'].toLowerCase();
            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null) {
              final BigInt rawAmount = BigInt.parse(rmmToken['amount']);
              final int decimals = matchingRealToken['decimals'] ?? 18;
              final double amount = rawAmount / BigInt.from(10).pow(decimals);
              final double tokenPrice = matchingRealToken['tokenPrice'];
              final totalValue = amount * tokenPrice;
              final dailyIncome = amount * matchingRealToken['netRentDayPerToken'];
              final monthlyIncome = amount * matchingRealToken['netRentMonthPerToken'];
              final yearlyIncome = amount * matchingRealToken['netRentYearPerToken'];

              portfolio.add({
                'shortName': matchingRealToken['shortName'],
                'imageLink': matchingRealToken['imageLink'][0],
                'amount': amount.toString(),
                'totalTokens': matchingRealToken['totalTokens'],
                'source': 'RMM',
                'tokenPrice': tokenPrice,
                'totalValue': totalValue,
                'annualPercentageYield': matchingRealToken['annualPercentageYield'],
                'dailyIncome': dailyIncome,
                'monthlyIncome': monthlyIncome,
                'yearlyIncome': yearlyIncome,
                'initialLaunchDate': matchingRealToken['initialLaunchDate']?['date'],  // Date de lancement
                'totalInvestment': matchingRealToken['totalInvestment'],  // Valeur de l'investissement
                'underlyingAssetPrice': matchingRealToken['underlyingAssetPrice'],  // Valeur du bien
                'initialMaintenanceReserve': matchingRealToken['initialMaintenanceReserve'],  // Réserve de maintenance
                'rentalType': matchingRealToken['rentalType'],  // Type de location
                'rentStartDate': matchingRealToken['rentStartDate']?['date'],  // Premier loyer
                'rentedUnits': matchingRealToken['rentedUnits'],  // Logements loués
                'totalUnits': matchingRealToken['totalUnits'],  // Nombre total de logements
                'grossRentMonth': matchingRealToken['grossRentMonth'],  // Loyer brut mensuel
                'netRentMonth': matchingRealToken['netRentMonth'],  // Loyer net mensuel
                'constructionYear': matchingRealToken['constructionYear'],  // Année de construction
                'propertyStories': matchingRealToken['propertyStories'],  // Nombre d'étages
                'lotSize': matchingRealToken['lotSize'],  // Taille du terrain
                'squareFeet': matchingRealToken['squareFeet'],  // Taille intérieure
                'marketplaceLink': matchingRealToken['marketplaceLink'],  // Taille intérieure
                'propertyType': matchingRealToken['propertyType'], 
                });
            }
          }

          if (portfolio.isEmpty) {
            return const Center(child: Text('No matching tokens found'));
          }

          // Appliquer filtre et tri
          final sortedFilteredPortfolio = _filterAndSortPortfolio(portfolio);

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: Row(
                    children: [
                      // Champ de recherche directement dans la AppBar
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
                            isDense: false, // Réduire la hauteur du champ de texte
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: false,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Compacter la taille
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Icône pour basculer entre les vues
                      IconButton(
                        icon: Icon(_isDisplay1 ? Icons.view_module : Icons.view_list),
                        onPressed: _toggleDisplay,
                      ),
                      const SizedBox(width: 8.0),
                      // Menu pour trier
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
          );
        },
      ),
    );
  }
}
