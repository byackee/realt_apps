import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DataManager extends ChangeNotifier {
  // Variables partagées pour le Dashboard et Portfolio
  double totalValue = 0;
  double walletValue = 0;
  double rmmValue = 0;
  double rwaHoldingsValue = 0;
  int rentedUnits = 0;
  int totalUnits = 0;
  int totalTokens = 0;
  double walletTokensSums = 0;
  double rmmTokensSums = 0;
  double averageAnnualYield = 0;
  double dailyRent = 0;
  double weeklyRent = 0;
  double monthlyRent = 0;
  double yearlyRent = 0;

  // Variables pour stocker les données de loyers et de propriétés
  List<Map<String, dynamic>> rentData = [];
  List<Map<String, dynamic>> propertyData = [];

  // Ajout des variables pour compter les tokens dans le wallet et RMM
  int walletTokenCount = 0;
  int rmmTokenCount = 0;

  bool isLoading = true;

  // Portfolio data for PortfolioPage
  List<Map<String, dynamic>> _portfolio = [];

  List<Map<String, dynamic>> get portfolio => _portfolio;

  // Ajout des données pour les mises à jour récentes
  List<Map<String, dynamic>> _recentUpdates = [];

  List<Map<String, dynamic>> get recentUpdates => _recentUpdates;

  final String rwaTokenAddress = '0x0675e8f4a52ea6c845cb6427af03616a2af42170';

  // Méthode pour récupérer et calculer les données pour le Dashboard et Portfolio
  Future<void> fetchAndCalculateData() async {
    final walletTokens = await ApiService.fetchTokens();
    final rmmTokens = await ApiService.fetchRMMTokens();
    final realTokens = await ApiService.fetchRealTokens(); // Garder realTokens en List<dynamic>

    // Variables temporaires
    double walletValueSum = 0;
    double rmmValueSum = 0;
    double rwaValue = 0;
    double walletTokensSum = 0;
    double rmmTokensSum = 0;
    int rentedUnitsSum = 0;
    int totalUnitsSum = 0;
    double annualYieldSum = 0;
    double dailyRentSum = 0;
    double monthlyRentSum = 0;
    double yearlyRentSum = 0;
    int yieldCount = 0;
    List<Map<String, dynamic>> newPortfolio = [];

    // Réinitialisation des compteurs de tokens
    walletTokenCount = 0;
    rmmTokenCount = 0;

    if (walletTokens.isNotEmpty && rmmTokens.isNotEmpty && realTokens.isNotEmpty) {
      final walletBalances = walletTokens[0]['balances'];
      final rmmBalances = rmmTokens;

      // Process wallet tokens (pour Dashboard et Portfolio)
      for (var walletToken in walletBalances) {
        final tokenAddress = walletToken['token']['address'].toLowerCase();
        final matchingRealToken = realTokens.cast<Map<String, dynamic>>().firstWhere(
          (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
          orElse: () => <String, dynamic>{},
        );

        if (matchingRealToken.isNotEmpty) {
          final double tokenPrice = matchingRealToken['tokenPrice'];
          final double tokenValue = double.parse(walletToken['amount']) * tokenPrice;

          rentedUnitsSum += (matchingRealToken['rentedUnits'] ?? 0) as int;
          totalUnitsSum += (matchingRealToken['totalUnits'] ?? 0) as int;

          if (tokenAddress == rwaTokenAddress.toLowerCase()) {
            rwaValue += tokenValue;
          } else {
            walletValueSum += tokenValue;
            walletTokensSum += double.parse(walletToken['amount']);
            walletTokenCount++; // Incrémenter le compteur de tokens du wallet

            annualYieldSum += matchingRealToken['annualPercentageYield'];
            yieldCount++;
            dailyRentSum += matchingRealToken['netRentDayPerToken'] * double.parse(walletToken['amount']);
            monthlyRentSum += matchingRealToken['netRentMonthPerToken'] * double.parse(walletToken['amount']);
            yearlyRentSum += matchingRealToken['netRentYearPerToken'] * double.parse(walletToken['amount']);
          }

          // Ajout au Portfolio
          newPortfolio.add({
            'shortName': matchingRealToken['shortName'],
            'fullName': matchingRealToken['fullName'],
            'imageLink': matchingRealToken['imageLink'][0],
            'amount': walletToken['amount'],
            'totalTokens': matchingRealToken['totalTokens'],
            'source': 'Wallet',
            'tokenPrice': tokenPrice,
            'totalValue': tokenValue,
            'annualPercentageYield': matchingRealToken['annualPercentageYield'],
            'dailyIncome': matchingRealToken['netRentDayPerToken'] * double.parse(walletToken['amount']),
            'monthlyIncome': matchingRealToken['netRentMonthPerToken'] * double.parse(walletToken['amount']),
            'yearlyIncome': matchingRealToken['netRentYearPerToken'] * double.parse(walletToken['amount']),
            'initialLaunchDate': matchingRealToken['initialLaunchDate']?['date'],
            'totalInvestment': matchingRealToken['totalInvestment'],
            'underlyingAssetPrice': matchingRealToken['underlyingAssetPrice'],
            'initialMaintenanceReserve': matchingRealToken['initialMaintenanceReserve'],
            'rentalType': matchingRealToken['rentalType'],
            'rentStartDate': matchingRealToken['rentStartDate']?['date'],
            'rentedUnits': matchingRealToken['rentedUnits'],
            'totalUnits': matchingRealToken['totalUnits'],
            'grossRentMonth': matchingRealToken['grossRentMonth'],
            'netRentMonth': matchingRealToken['netRentMonth'],
            'constructionYear': matchingRealToken['constructionYear'],
            'propertyStories': matchingRealToken['propertyStories'],
            'lotSize': matchingRealToken['lotSize'],
            'squareFeet': matchingRealToken['squareFeet'],
            'marketplaceLink': matchingRealToken['marketplaceLink'],
            'propertyType': matchingRealToken['propertyType'],
            'historic': matchingRealToken['historic'],
          });
        }
      }

      // Process RMM tokens (pour Dashboard et Portfolio)
      for (var rmmToken in rmmBalances) {
        final tokenAddress = rmmToken['token']['id'].toLowerCase();
        final matchingRealToken = realTokens.cast<Map<String, dynamic>>().firstWhere(
          (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
          orElse: () => <String, dynamic>{},
        );

        if (matchingRealToken.isNotEmpty) {
          final BigInt rawAmount = BigInt.parse(rmmToken['amount']);
          final int decimals = matchingRealToken['decimals'] ?? 18;
          final double amount = rawAmount / BigInt.from(10).pow(decimals);
          final double tokenPrice = matchingRealToken['tokenPrice'];
          rmmValueSum += amount * tokenPrice;
          rmmTokensSum += amount;
          rmmTokenCount++; // Incrémenter le compteur de tokens du RMM

          rentedUnitsSum += (matchingRealToken['rentedUnits'] ?? 0) as int;
          totalUnitsSum += (matchingRealToken['totalUnits'] ?? 0) as int;

          annualYieldSum += matchingRealToken['annualPercentageYield'];
          yieldCount++;
          dailyRentSum += matchingRealToken['netRentDayPerToken'] * amount;
          monthlyRentSum += matchingRealToken['netRentMonthPerToken'] * amount;
          yearlyRentSum += matchingRealToken['netRentYearPerToken'] * amount;

          // Ajout au Portfolio
          newPortfolio.add({
            'shortName': matchingRealToken['shortName'],
            'fullName': matchingRealToken['fullName'],
            'imageLink': matchingRealToken['imageLink'][0],
            'amount': amount.toString(),
            'totalTokens': matchingRealToken['totalTokens'],
            'walletTokensSum': matchingRealToken['walletTokensSum'],
            'source': 'RMM',
            'tokenPrice': tokenPrice,
            'totalValue': amount * tokenPrice,
            'annualPercentageYield': matchingRealToken['annualPercentageYield'],
            'dailyIncome': matchingRealToken['netRentDayPerToken'] * amount,
            'monthlyIncome': matchingRealToken['netRentMonthPerToken'] * amount,
            'yearlyIncome': matchingRealToken['netRentYearPerToken'] * amount,
            'initialLaunchDate': matchingRealToken['initialLaunchDate']?['date'],
            'totalInvestment': matchingRealToken['totalInvestment'],
            'underlyingAssetPrice': matchingRealToken['underlyingAssetPrice'],
            'initialMaintenanceReserve': matchingRealToken['initialMaintenanceReserve'],
            'rentalType': matchingRealToken['rentalType'],
            'rentStartDate': matchingRealToken['rentStartDate']?['date'],
            'rentedUnits': matchingRealToken['rentedUnits'],
            'totalUnits': matchingRealToken['totalUnits'],
            'grossRentMonth': matchingRealToken['grossRentMonth'],
            'netRentMonth': matchingRealToken['netRentMonth'],
            'constructionYear': matchingRealToken['constructionYear'],
            'propertyStories': matchingRealToken['propertyStories'],
            'lotSize': matchingRealToken['lotSize'],
            'squareFeet': matchingRealToken['squareFeet'],
            'marketplaceLink': matchingRealToken['marketplaceLink'],
            'propertyType': matchingRealToken['propertyType'],
            'historic': matchingRealToken['historic'],
          });
        }
      }

      // Extraire les mises à jour récentes (update30)
      _recentUpdates = _extractRecentUpdates(realTokens);
    }

    // Mise à jour des variables pour le Dashboard
    totalValue = walletValueSum + rmmValueSum + rwaValue;
    walletValue = walletValueSum;
    rmmValue = rmmValueSum;
    rwaHoldingsValue = rwaValue;
    walletTokensSums = walletTokensSum;
    rmmTokensSums = rmmTokensSum;
    totalTokens = (walletTokensSum + rmmTokensSum).toInt();
    rentedUnits = rentedUnitsSum;
    totalUnits = totalUnitsSum;
    averageAnnualYield = yieldCount > 0 ? annualYieldSum / yieldCount : 0;
    dailyRent = dailyRentSum;
    weeklyRent = dailyRentSum * 7;
    monthlyRent = monthlyRentSum;
    yearlyRent = yearlyRentSum;

    // Mise à jour des données pour le Portfolio
    _portfolio = newPortfolio;

    // Notify listeners that data has changed
    notifyListeners();
  }

  // Méthode pour extraire les mises à jour récentes sur les 30 derniers jours
  List<Map<String, dynamic>> _extractRecentUpdates(List<dynamic> realTokensRaw) {
  final List<Map<String, dynamic>> realTokens = realTokensRaw.cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> recentUpdates = [];

  for (var token in realTokens) {
    if (token.containsKey('update30')) {
      final String shortName = token['shortName'] ?? 'Nom inconnu';
      final String imageLink = token['imageLink'] != null && token['imageLink'].isNotEmpty 
          ? token['imageLink'][0] // Prendre la première image si disponible
          : 'Lien d\'image non disponible';

      List<Map<String, dynamic>> updatesWithDetails = List<Map<String, dynamic>>.from(token['update30']).where((update) {
        return update['key'] == 'netRentYearPerToken' || update['key'] == 'annualPercentageYield';
      }).map((update) {
        // Initialiser les variables avec des valeurs par défaut
        String formattedKey = 'Donnée inconnue';
        String formattedOldValue = 'Valeur inconnue';
        String formattedNewValue = 'Valeur inconnue';

        if (update['key'] == 'netRentYearPerToken') {
          // Arrondir la valeur à deux chiffres après la virgule
          double newValue = double.tryParse(update['new_value']) ?? 0.0;
          double oldValue = double.tryParse(update['old_value']) ?? 0.0;
          formattedKey = 'Net Rent Per Token (Annuel)';
          formattedOldValue = "${oldValue.toStringAsFixed(2)} USD";
          formattedNewValue = "${newValue.toStringAsFixed(2)} USD";
        } else if (update['key'] == 'annualPercentageYield') {
          // Arrondir la valeur à deux chiffres après la virgule
          double newValue = double.tryParse(update['new_value']) ?? 0.0;
          double oldValue = double.tryParse(update['old_value']) ?? 0.0;
          formattedKey = 'Rendement Annuel (%)';
          formattedOldValue = "${oldValue.toStringAsFixed(2)}%";
          formattedNewValue = "${newValue.toStringAsFixed(2)}%";
        }

        return {
          'shortName': shortName,
          'formattedKey': formattedKey,
          'formattedOldValue': formattedOldValue,
          'formattedNewValue': formattedNewValue,
          'timsync': update['timsync'],
          'imageLink': imageLink, // Ajout de l'image du token
        };
      }).toList();

      recentUpdates.addAll(updatesWithDetails);
    }
  }

  // Trier les mises à jour par date
  recentUpdates.sort((a, b) => DateTime.parse(b['timsync']).compareTo(DateTime.parse(a['timsync'])));

  return recentUpdates;
}



  // Méthode pour récupérer les données des loyers
  Future<void> fetchRentData() async {
    try {
      List<Map<String, dynamic>> rentData = await ApiService.fetchRentData();
      this.rentData = rentData;
    } catch (e) {
      print("Error fetching rent data: $e");
    }
    notifyListeners();
  }

  // Méthode pour récupérer les données des propriétés
  Future<void> fetchPropertyData() async {
    try {
      // Récupérer les tokens depuis l'API
      final walletTokens = await ApiService.fetchTokens();
      final rmmTokens = await ApiService.fetchRMMTokens();
      final realTokens = await ApiService.fetchRealTokens();

      final List<Map<String, dynamic>> realTokensCasted = realTokens.cast<Map<String, dynamic>>();

      // Fusionner les tokens du portefeuille et du RMM
      List<dynamic> allTokens = [...walletTokens[0]['balances'], ...rmmTokens];
      List<Map<String, dynamic>> propertyData = [];

      // Parcourir chaque token du portefeuille et du RMM
      for (var token in allTokens) {
        if (token != null && token['token'] != null && token['token']['address'] != null) {
          final tokenAddress = token['token']['address'].toLowerCase();

          // Correspondre avec les RealTokens
          final matchingRealToken = realTokens.cast<Map<String, dynamic>>().firstWhere(
            (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
            orElse: () => <String, dynamic>{},
          );

          if (matchingRealToken.isNotEmpty && matchingRealToken['propertyType'] != null) {
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

      this.propertyData = propertyData;
    } catch (e) {
      print("Error fetching property data: $e");
    }
    notifyListeners();
  }
}
