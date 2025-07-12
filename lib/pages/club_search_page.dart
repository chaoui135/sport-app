import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ClubSearchPage extends StatefulWidget {
  const ClubSearchPage({Key? key}) : super(key: key);

  @override
  _ClubSearchPageState createState() => _ClubSearchPageState();
}

class _ClubSearchPageState extends State<ClubSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Bbox Marseille (south, west, north, east)
  static const _south = 43.30;
  static const _west  = 5.316;
  static const _north = 43.45;
  static const _east  = 5.466;

  List<Map<String, dynamic>> _places = [];
  List<Marker> _markers = [];

  Future<void> _searchPlaces() async {
    final raw = _searchController.text.trim();
    if (raw.isEmpty) return;

    final uri = Uri.parse('https://nominatim.openstreetmap.org/search')
        .replace(queryParameters: {
      'format': 'json',
      'q': raw,
      'limit': '20',
      'viewbox': '$_west,$_north,$_east,$_south',
      'bounded': '1',
    });

    final resp = await http.get(uri, headers: {'User-Agent': 'Flutter/fitvista'});
    if (resp.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ${resp.statusCode}')),
      );
      return;
    }

    final data = json.decode(resp.body) as List;
    final places = List<Map<String, dynamic>>.from(data);
    final markers = places.map<Marker>((place) {
      final lat = double.parse(place['lat']);
      final lon = double.parse(place['lon']);
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(lat, lon),
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(place['display_name'])),
          ),
          child: const Icon(Icons.location_pin, size: 36, color: Colors.redAccent),
        ),
      );
    }).toList();

    setState(() {
      _places = places;
      _markers = markers;
    });

    if (markers.isNotEmpty) {
      _mapController.move(markers.first.point, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // 1) Carte + barre de recherche flottante
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(43.2965, 5.3698),
                      zoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.fitvista',
                      ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  // barre de recherche
                  Positioned(
                    top: 16, left: 16, right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchPlaces(),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un club à Marseille…',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2) panneau des résultats
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _places.isEmpty ? 0 : 200,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0,-2)
                )],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: _places.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: _places.length,
                itemBuilder: (ctx, i) {
                  final place = _places[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.redAccent),
                        title: Text(
                          place['display_name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${place['class']}/${place['type']}'),
                        onTap: () {
                          final lat = double.parse(place['lat']);
                          final lon = double.parse(place['lon']);
                          _mapController.move(LatLng(lat, lon), 15);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
