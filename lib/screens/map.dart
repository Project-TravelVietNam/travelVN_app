import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/map_markers.dart';
import '../widgets/search_bar_map.dart';
import '../widgets/directions_sheet.dart';

class MapScreen extends StatefulWidget {
  final String? searchAddress;
  
  const MapScreen({
    super.key, 
    this.searchAddress,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(16.4637, 107.5909);
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startSearchController = TextEditingController();
  final TextEditingController _endSearchController = TextEditingController();
  LatLng? _startLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];
  bool _showRoute = false;
  List<Map<String, dynamic>> _routeSteps = [];
  double _totalDistance = 0;
  String _totalDuration = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    
    // Nếu có địa chỉ được truyền vào, tự động điền vào ô tìm kiếm và tìm kiếm
    if (widget.searchAddress != null && widget.searchAddress != 'Chưa có địa chỉ') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _endSearchController.text = widget.searchAddress!;
        _searchEndLocation(widget.searchAddress!);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Vui lòng bật dịch vụ vị trí';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Quyền truy cập vị trí bị từ chối';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_currentLocation, 15.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _searchEndLocation(String address) async {
    try {
      setState(() => _isLoading = true);
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        setState(() {
          _destinationLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _showRoute = false;
          _routePoints.clear();
        });
        _mapController.move(_destinationLocation!, 15.0);
        if (_startLocation != null) {
          await _getRoute();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa điểm')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchStartLocation(String address) async {
    print('Searching start location: $address');
    try {
      setState(() => _isLoading = true);
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        setState(() {
          _startLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _showRoute = false;
          _routePoints.clear();
        });
        _mapController.move(_startLocation!, 15.0);
        if (_destinationLocation != null) {
          await _getRoute();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa điểm')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getRoute() async {
    if (_startLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập cả điểm bắt đầu và điểm đến')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${_startLocation!.longitude},${_startLocation!.latitude};'
        '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
        '?overview=full&geometries=geojson&steps=true'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final List<dynamic> coordinates = route['geometry']['coordinates'];
        final List<dynamic> steps = route['legs'][0]['steps'];
        
        final distance = route['distance'] / 1000;
        final duration = route['duration'] / 60;

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          _showRoute = true;
          _totalDistance = distance;
          _totalDuration = '${duration.round()} phút';
          
          _routeSteps = steps.map<Map<String, dynamic>>((step) {
            return {
              'instruction': step['maneuver']['type'],
              'distance': (step['distance'] / 1000).toStringAsFixed(1),
              'duration': (step['duration'] / 60).round(),
            };
          }).toList();
        });

        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50.0),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tìm đường đi: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareLocation() async {
    try {
      final String googleMapsUrl = 
        'https://www.google.com/maps/search/?api=1&query=${_currentLocation.latitude},${_currentLocation.longitude}';
      await Share.shareUri(Uri.parse(googleMapsUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chia sẻ vị trí: ${e.toString()}')),
      );
    }
  }

  void _showDirectionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DirectionsSheet(
        totalDistance: _totalDistance,
        totalDuration: _totalDuration,
        routeSteps: _routeSteps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareLocation,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBars(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(10.7769, 106.7009),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.travelVN_app',
          tileProvider: NetworkTileProvider(),
          maxZoom: 18,
          minZoom: 4,
          additionalOptions: {
            'useCache': 'true',
            'secure': 'true',
          },
        ),
        if (_showRoute && _routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 3.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            LocationMarker(
              point: _currentLocation,
              label: 'Vị trí của bạn',
              markerColor: Colors.red,
              icon: Icons.location_pin,
            ),
            if (_startLocation != null)
              LocationMarker(
                point: _startLocation!,
                label: 'Điểm bắt đầu',
                markerColor: Colors.red,
                icon: Icons.location_pin,
              ),
            if (_destinationLocation != null)
              LocationMarker(
                point: _destinationLocation!,
                label: 'Điểm đến',
                markerColor: Colors.blue,
                icon: Icons.place,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBars() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          CustomSearchBarMap(
            controller: _startSearchController,
            hintText: 'Điểm bắt đầu...',
            icon: Icons.my_location,
            onSubmitted: _searchStartLocation,
            onClear: () {
              _startSearchController.clear();
              setState(() {
                _startLocation = null;
                _showRoute = false;
                _routePoints.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          CustomSearchBarMap(
            controller: _endSearchController,
            hintText: 'Điểm đến...',
            icon: Icons.place,
            onSubmitted: _searchEndLocation,
            onClear: () {
              _endSearchController.clear();
              setState(() {
                _destinationLocation = null;
                _showRoute = false;
                _routePoints.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: (_startLocation == null || _destinationLocation == null) 
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập cả điểm bắt đầu và điểm đến')),
                );
              }
            : _getRoute,
          label: const Text('Tìm đường'),
          icon: const Icon(Icons.directions),
          heroTag: 'findRoute',
        ),
        if (_showRoute)
          ...[
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _showDirectionsSheet,
              child: const Icon(Icons.list),
              heroTag: 'showDirections',
            ),
          ],
      ],
    );
  }
}
