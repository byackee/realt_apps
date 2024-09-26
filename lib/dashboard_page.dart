import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pour le formatage des nombres
import 'api_service.dart';

// Fonction de formatage des valeurs monétaires avec des espaces pour les milliers
String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR',  // Utilisez 'fr_FR' pour les espaces entre milliers
    symbol: '\$',     // Symbole de la devise
    decimalDigits: 2, // Nombre de chiffres après la virgule
  );
  return formatter.format(value);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<dynamic>>? _walletTokens;
  Future<List<dynamic>>? _rmmTokens;
  Future<List<dynamic>>? _realTokens;

  double totalValue = 0;
  double walletValue = 0;
  double rmmValue = 0;
  double rwaHoldingsValue = 0; // Valeur du token RWA Holdings SA
  int rentedUnits = 0;
  int totalUnits = 0;
  int totalTokens = 0;
  double walletTokensSum = 0;
  double rmmTokensSum = 0;
  double averageAnnualYield = 0;
  double dailyRent = 0;
  double weeklyRent = 0;
  double monthlyRent = 0;
  double yearlyRent = 0;

  final String rwaTokenAddress = '0x0675e8f4a52ea6c845cb6427af03616a2af42170'; // Adresse du token RWA Holdings SA

  @override
  void initState() {
    super.initState();
    _walletTokens = ApiService.fetchTokens(); // Récupérer les tokens du portefeuille
    _rmmTokens = ApiService.fetchRMMTokens(); // Récupérer les tokens du RMM
    _realTokens = ApiService.fetchRealTokens(); // Récupérer les RealTokens

    _calculatePortfolioValues(); // Calculer les valeurs au chargement
  }

  Future<void> _calculatePortfolioValues() async {
    final walletData = await _walletTokens;
    final rmmData = await _rmmTokens;
    final realTokensData = await _realTokens;

    double walletValueSum = 0;
    double rmmValueSum = 0;
    double rwaValue = 0;
    double walletTokens = 0;
    double rmmTokens = 0;
    int rentedUnitsSum = 0;
    int totalUnitsSum = 0;
    double annualYieldSum = 0;
    double dailyRentSum = 0;
    double weeklyRentSum = 0;
    double monthlyRentSum = 0;
    double yearlyRentSum = 0;
    int yieldCount = 0;

    if (walletData != null && rmmData != null && realTokensData != null) {
      final walletBalances = walletData[0]['balances'];
      final rmmBalances = rmmData;

      // Calcul des valeurs pour les tokens dans le wallet
      for (var walletToken in walletBalances) {
        final tokenAddress = walletToken['token']['address'].toLowerCase();
        final matchingRealToken = realTokensData.firstWhere(
          (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
          orElse: () => null,
        );

        if (matchingRealToken != null) {
          final double tokenPrice = matchingRealToken['tokenPrice'];
          final double tokenValue = double.parse(walletToken['amount']) * tokenPrice;

          // Addition des unités louées et des unités totales pour le wallet
          rentedUnitsSum += (matchingRealToken['rentedUnits'] ?? 0) as int;
          totalUnitsSum += (matchingRealToken['totalUnits'] ?? 0) as int;

          if (tokenAddress == rwaTokenAddress.toLowerCase()) {
            rwaValue += tokenValue; // Ajouter à la somme de RWA Holdings SA
          } else {
            walletValueSum += tokenValue; // Ajouter au wallet (en excluant RWA Holdings SA)
            walletTokens += double.parse(walletToken['amount']); // Additionner le nombre de tokens

            // Calcul des rendements et des loyers
            annualYieldSum += matchingRealToken['annualPercentageYield'];
            yieldCount++; // Incrémenter le compteur de rendements
            dailyRentSum += matchingRealToken['netRentDayPerToken'] * double.parse(walletToken['amount']);
            monthlyRentSum += matchingRealToken['netRentMonthPerToken'] * double.parse(walletToken['amount']);
            yearlyRentSum += matchingRealToken['netRentYearPerToken'] * double.parse(walletToken['amount']);
          }
        }
      }

      // Calcul des valeurs pour les tokens dans le RMM
      for (var rmmToken in rmmBalances) {
        final tokenAddress = rmmToken['token']['id'].toLowerCase();
        final matchingRealToken = realTokensData.firstWhere(
          (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
          orElse: () => null,
        );

        if (matchingRealToken != null) {
          final BigInt rawAmount = BigInt.parse(rmmToken['amount']);
          final int decimals = matchingRealToken['decimals'] ?? 18;
          final double amount = rawAmount / BigInt.from(10).pow(decimals);
          final double tokenPrice = matchingRealToken['tokenPrice'];
          rmmValueSum += amount * tokenPrice;
          rmmTokens += amount; // Additionner le nombre de tokens

          // Addition des unités louées et des unités totales pour le RMM
          rentedUnitsSum += (matchingRealToken['rentedUnits'] ?? 0) as int;
          totalUnitsSum += (matchingRealToken['totalUnits'] ?? 0) as int;

          // Calcul des rendements et des loyers pour le RMM
          annualYieldSum += matchingRealToken['annualPercentageYield'];
          yieldCount++; // Incrémenter le compteur de rendements
          dailyRentSum += matchingRealToken['netRentDayPerToken'] * amount;
          monthlyRentSum += matchingRealToken['netRentMonthPerToken'] * amount;
          yearlyRentSum += matchingRealToken['netRentYearPerToken'] * amount;
        }
      }
    }

    setState(() {
      walletValue = walletValueSum;
      rmmValue = rmmValueSum;
      rwaHoldingsValue = rwaValue; // Mettre à jour la valeur de RWA Holdings SA
      totalValue = walletValueSum + rmmValueSum + rwaValue;
      walletTokensSum = walletTokens;
      rmmTokensSum = rmmTokens;
      totalTokens = (walletTokens + rmmTokens).toInt();
      rentedUnits = rentedUnitsSum; // Somme des unités louées pour wallet et RMM
      totalUnits = totalUnitsSum; // Somme des unités totales pour wallet et RMM
      averageAnnualYield = yieldCount > 0 ? annualYieldSum / yieldCount : 0; // Calcul de la moyenne
      dailyRent = dailyRentSum;
      weeklyRent = dailyRentSum * 7;
      monthlyRent = monthlyRentSum;
      yearlyRent = yearlyRentSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcul du pourcentage de logements loués
    final double rentedPercentage =
        totalUnits > 0 ? (rentedUnits / totalUnits) * 100 : 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Carte "Overview"
              SizedBox(
                width: screenWidth,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0), // Taille intermédiaire
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold), // Taille intermédiaire
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Total Portfolio Value: ${formatCurrency(totalValue)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Taille intermédiaire
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Wallet Value: ${formatCurrency(walletValue)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RMM Value: ${formatCurrency(rmmValue)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RWA Holdings SA Value: ${formatCurrency(rwaHoldingsValue)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25), // Espacement intermédiaire
              // Carte "Propriétés"
              SizedBox(
                width: screenWidth,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0), // Taille intermédiaire
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Propriétés',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold), // Taille intermédiaire
                        ),
                        const SizedBox(height: 15),
                        Text(
                            'Percentage Rented: ${rentedPercentage.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            'Rented Units: $rentedUnits / Total Units: $totalUnits',
                            style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Carte "Tokens"
              SizedBox(
                width: screenWidth,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0), // Taille intermédiaire
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tokens',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold), // Taille intermédiaire
                        ),
                        const SizedBox(height: 15),
                        Text('Total Tokens: $totalTokens', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Tokens in Wallet: ${formatCurrency(walletTokensSum)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Tokens in RMM: ${formatCurrency(rmmTokensSum)}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Carte "Rendement"
              SizedBox(
                width: screenWidth,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0), // Taille intermédiaire
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rendement',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold), // Taille intermédiaire
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Rendement Annuel (Moyenne): ${averageAnnualYield.toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('Journaliers: ${formatCurrency(dailyRent)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Hebdomadaires: ${formatCurrency(weeklyRent)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Mensuels: ${formatCurrency(monthlyRent)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Annuels: ${formatCurrency(yearlyRent)}',
                            style: const TextStyle(fontSize: 16)),
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
}
