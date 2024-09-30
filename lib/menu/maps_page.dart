import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Future<List<dynamic>>? _walletTokens;
  Future<List<dynamic>>? _rmmTokens;
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
        future: Future.wait([_walletTokens!, _rmmTokens!, _realTokens!]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading map data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tokens found in the wallet or RMM'));
          }

          final walletTokens = snapshot.data![0][0]['balances'];
          final rmmTokens = snapshot.data![1];
          final realTokens = snapshot.data![2];

          final List<Marker> markers = [];

          // Ajouter les tokens du Wallet sur la carte
          for (var walletToken in walletTokens) {
            final tokenAddress = walletToken['token']['address'].toLowerCase();

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
                      color: Colors.green,
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
                      color: Colors.blue,
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
              initialCenter: LatLng(42.367476, -83.130921),
              initialZoom: 13.0,
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Utilisation directe de l'URL sans sous-domaines
              ),
              PopupScope(
                child: MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 120,
                    disableClusteringAtZoom: 14, // Désactiver le clustering au-dessus du zoom 16
                    size: const Size(40, 40),
                    markers: markers,
                    builder: (context, markers) {
                      return CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(markers.length.toString()),
                      );
                    },
                    popupOptions: PopupOptions(
                      popupController: _popupController,
                      popupBuilder: (BuildContext context, Marker marker) {
                        final matchingRealToken = realTokens.firstWhere(
                          (realToken) =>
                              double.parse(realToken['coordinate']['lat']) ==
                                  marker.point.latitude &&
                              double.parse(realToken['coordinate']['lng']) ==
                                  marker.point.longitude,
                          orElse: () => null,
                        );

                        if (matchingRealToken != null) {
                          return Card(
                            child: Container(
                              width: 200,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    matchingRealToken['imageLink'][0],
                                    width: 200,
                                    height: 100,
                                    fit: BoxFit.cover,
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
              ),
            ],
          );
        },
      ),
    );
  }
}
