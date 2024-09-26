import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _url = 'https://gateway-arbitrum.network.thegraph.com/api/c57eb2612e998502f4418378a4cb9f35/subgraphs/id/FPPoFB7S2dcCNrRyjM5QbaMwKqRZPdbTg8ysBrwXd4SP';
  static const String rmmUrl = 'https://gateway-arbitrum.network.thegraph.com/api/c57eb2612e998502f4418378a4cb9f35/subgraphs/id/2dMMk7DbQYPX6Gi5siJm6EZ2gDQBF8nJcgKtpiPnPBsK';
  static const String realTokensUrl = 'https://pitswap-api.herokuapp.com/api/realTokens';
  static const String rentTrackerUrl = 'https://ehpst.duckdns.org/realt_rent_tracker/api/rent_holder/';
  static const Duration cacheDuration = Duration(hours: 1);

  // Récupérer les tokens depuis The Graph
  static Future<List<dynamic>> fetchTokens() async {
    var box = Hive.box('dashboardTokens');
    final lastFetchTime = box.get('lastFetchTime');
    final DateTime now = DateTime.now();

    if (lastFetchTime != null) {
      final DateTime lastFetch = DateTime.parse(lastFetchTime);
      if (now.difference(lastFetch) < cacheDuration) {
        final cachedData = box.get('cachedTokenData');
        if (cachedData != null) {
          return List<dynamic>.from(json.decode(cachedData));
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    List<String>? ethAddresses = prefs.getStringList('ethAddresses') ?? [];
    if (ethAddresses.isEmpty) {
      ethAddresses = ['']; // Si aucune adresse n'est stockée, utiliser une adresse par défaut
    }

    const query = '''
      query RealtokenQuery(\$addressList: [String]!) {
        accounts(where: { address_in: \$addressList }) {
          address
          balances(where: { amount_gt: "0" }, first: 1000, orderBy: amount, orderDirection: desc) {
            token {
              address
            }
            amount
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "query": query,
        "variables": {"addressList": ethAddresses}
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['accounts'];
      box.put('cachedTokenData', json.encode(data));
      box.put('lastFetchTime', now.toIso8601String());
      return data;
    } else {
      throw Exception('Failed to fetch tokens');
    }
  }

  // Récupérer les tokens sur le RealToken Marketplace (RMM)
  static Future<List<dynamic>> fetchRMMTokens() async {
    var box = Hive.box('dashboardTokens');
    final lastFetchTime = box.get('lastRMMFetchTime');
    final DateTime now = DateTime.now();

    if (lastFetchTime != null) {
      final DateTime lastFetch = DateTime.parse(lastFetchTime);
      if (now.difference(lastFetch) < cacheDuration) {
        final cachedData = box.get('cachedRMMData');
        if (cachedData != null) {
          return List<dynamic>.from(json.decode(cachedData));
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    List<String>? ethAddresses = prefs.getStringList('ethAddresses') ?? [];
    if (ethAddresses.isEmpty) {
      throw Exception('No Ethereum addresses found in SharedPreferences.');
    }

    // Construire la requête GraphQL avec la variable
    const query = '''
      query RmmQuery(\$addressList: String!) {
        users(where: { id: \$addressList }) {
          balances(
            where: { amount_gt: 0 },
            first: 100,
            orderBy: amount,
            orderDirection: desc,
            skip: 0
          ) {
            amount
            token {
              decimals
              id
              __typename
            }
            __typename
          }
          __typename
        }
      }
    ''';

    // Faire une requête pour chaque adresse dans ethAddresses
    List<dynamic> allBalances = [];
    for (var address in ethAddresses) {
      final response = await http.post(
        Uri.parse(rmmUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "query": query,
          "variables": {
            "addressList": address,  // Injecter l'adresse actuelle dans la requête
          }
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['data'] != null && decodedResponse['data']['users'] != null) {
          final data = decodedResponse['data']['users'][0]['balances'];
          allBalances.addAll(data);  // Ajouter les résultats de cette adresse à la liste globale
        }
      } else {
        throw Exception('Failed to fetch RMM tokens for address: $address');
      }
    }

    // Stocker les nouvelles données dans Hive
    box.put('cachedRMMData', json.encode(allBalances));
    box.put('lastRMMFetchTime', now.toIso8601String());

    return allBalances;
  }

  // Récupérer la liste complète des RealTokens depuis l'API pitswap
  static Future<List<dynamic>> fetchRealTokens() async {
    var box = Hive.box('realTokens');
    final lastFetchTime = box.get('lastFetchTime');
    final DateTime now = DateTime.now();

    if (lastFetchTime != null) {
      final DateTime lastFetch = DateTime.parse(lastFetchTime);
      if (now.difference(lastFetch) < cacheDuration) {
        final cachedData = box.get('cachedRealTokens');
        if (cachedData != null) {
          return List<dynamic>.from(json.decode(cachedData));
        }
      }
    }

    final response = await http.get(Uri.parse(realTokensUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      box.put('cachedRealTokens', json.encode(data));
      box.put('lastFetchTime', now.toIso8601String());
      return data;
    } else {
      throw Exception('Failed to fetch RealTokens');
    }
  }

  // Récupérer les données de loyer pour chaque wallet et les fusionner
  static Future<List<Map<String, dynamic>>> fetchRentData(List<String> wallets) async {
  List<Map<String, dynamic>> mergedRentData = [];

  for (String wallet in wallets) {
    final url = '$rentTrackerUrl$wallet';
    print('Fetching rent data for wallet: $wallet');  // Log wallet being fetched

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> rentData = List<Map<String, dynamic>>.from(json.decode(response.body));
      print('Rent data fetched for $wallet: $rentData');  // Log the fetched rent data

      for (var rentEntry in rentData) {
        final existingEntry = mergedRentData.firstWhere(
  (entry) => entry['date'] == rentEntry['date'],
  orElse: () => <String, dynamic>{}, // Retourner un objet vide si aucune correspondance n'est trouvée
);

if (existingEntry.isNotEmpty) {
  // Fusionner les valeurs si une entrée existe déjà
  existingEntry['rent'] = (existingEntry['rent'] ?? 0) + (rentEntry['rent'] ?? 0);
} else {
  // Ajouter une nouvelle entrée si elle n'existe pas
  mergedRentData.add({
    'date': rentEntry['date'],
    'rent': rentEntry['rent'] ?? 0,
  });
}


        print('Merging rent for date ${rentEntry['date']}: ${existingEntry['rent']} + ${rentEntry['rent']}');
        existingEntry['rent'] = (existingEntry['rent'] ?? 0) + (rentEntry['rent'] ?? 0);
            }
    } else {
      print('Failed to load rent data for wallet: $wallet');
      throw Exception('Failed to load rent data for wallet: $wallet');
    }
  }

  mergedRentData.sort((a, b) => a['date'].compareTo(b['date']));
  return mergedRentData;
}

}
