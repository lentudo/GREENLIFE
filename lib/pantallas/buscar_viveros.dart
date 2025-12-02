import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class BuscarViverosScreen extends StatefulWidget {
  const BuscarViverosScreen({super.key});

  @override
  State<BuscarViverosScreen> createState() => _BuscarViverosScreenState();
}

class _BuscarViverosScreenState extends State<BuscarViverosScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  // ¡IMPORTANTE! Reemplaza esto con tu API Key real
  final String _googleApiKey = 'https://serpapi.com/search?engine=google_maps';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });

    _searchNearbyViveros(position);
  }

  Future<void> _searchNearbyViveros(Position position) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&keyword=vivero&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          _markers.clear();
          for (var result in results) {
            final lat = result['geometry']['location']['lat'];
            final lng = result['geometry']['location']['lng'];
            final name = result['name'];
            final vicinity = result['vicinity'];

            _markers.add(
              Marker(
                markerId: MarkerId(result['place_id']),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: name,
                  snippet: vicinity,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error buscando viveros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Viveros 🏪'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('No se pudo obtener la ubicación'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                ),
    );
  }
}
