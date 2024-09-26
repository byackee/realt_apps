import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'api_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Future<List<dynamic>>? _walletTokens;
  Future<List<dynamic>>? _rmmTokens; // Ajout des tokens RMM
  Future<List<dynamic>>? _realTokens;

  // Create a PopupController to manage the popups
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _walletTokens = ApiService.fetchTokens(); // Charger les tokens du Wallet
    _rmmTokens = ApiService.fetchRMMTokens(); // Charger les tokens du RMM
    _realTokens = ApiService.fetchRealTokens(); // Charger les RealTokens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_walletTokens!, _rmmTokens!, _realTokens!]), // Attendre les trois requêtes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading map data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tokens found in the wallet or RMM'));
          }

          final walletTokens = snapshot.data![0][0]['balances']; // Accès aux balances des tokens du wallet
          final rmmTokens = snapshot.data![1]; // Accès aux balances des tokens du RMM
          final realTokens = snapshot.data![2]; // Infos des RealTokens

          final List<Marker> markers = [];

          // Ajouter les tokens du Wallet sur la carte
          for (var walletToken in walletTokens) {
            final tokenAddress = walletToken['token']['address'].toLowerCase();

            // Recherche du RealToken correspondant via uuid
            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null && matchingRealToken['coordinate'] != null) {
              final lat = double.tryParse(matchingRealToken['coordinate']['lat']);
              final lng = double.tryParse(matchingRealToken['coordinate']['lng']);

              if (lat != null && lng != null) {
                markers.add(
                  Marker(
                    point: LatLng(lat, lng),
                    width: 80.0,
                    height: 80.0,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green, // Couleur pour les tokens du Wallet
                      size: 40.0,
                    ),
                  ),
                );
              }
            }
          }

          // Ajouter les tokens du RMM sur la carte
          for (var rmmToken in rmmTokens) {
            final tokenAddress = rmmToken['token']['id'].toLowerCase();

            // Recherche du RealToken correspondant via uuid
            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null && matchingRealToken['coordinate'] != null) {
              final lat = double.tryParse(matchingRealToken['coordinate']['lat']);
              final lng = double.tryParse(matchingRealToken['coordinate']['lng']);

              if (lat != null && lng != null) {
                markers.add(
                  Marker(
                    point: LatLng(lat, lng),
                    width: 80.0,
                    height: 80.0,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue, // Couleur pour les tokens du RMM
                      size: 40.0,
                    ),
                  ),
                );
              }
            }
          }

          if (markers.isEmpty) {
            return const Center(child: Text('No matching tokens found on the map'));
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(42.367476, -83.130921), // Point de départ par défaut
              initialZoom: 13.0,
              onTap: (_, __) => _popupController.hideAllPopups(), // Cacher tous les popups en cas de tap sur la carte
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: markers,
                  popupController: _popupController,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      // Trouver le RealToken correspondant à la position du marqueur
                      final matchingRealToken = realTokens.firstWhere(
                        (realToken) =>
                            double.parse(realToken['coordinate']['lat']) == marker.point.latitude &&
                            double.parse(realToken['coordinate']['lng']) == marker.point.longitude,
                        orElse: () => null,
                      );

                      if (matchingRealToken != null) {
                        return Card(
                          child: Container(
                            width: 200, // Contrainte de largeur
                            constraints: const BoxConstraints(
                              maxHeight: 200, // Contrainte de hauteur maximale
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  matchingRealToken['imageLink'][0],
                                  width: 200,
                                  height: 100,
                                  fit: BoxFit.cover, // Assurez-vous que l'image ne dépasse pas
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    matchingRealToken['shortName'],
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Text('No data available for this marker');
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
