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
  final MapController _mapController = MapController(); //khởi tạo bản đồ
  //Tọa độ hiện tại được đặt mặc định là Thành phố Hồ Chí Minh
  LatLng _currentLocation = const LatLng(10.7769, 106.7009);
  bool _isLoading = true;
  //Điều khiển dữ liệu nhập trong ô tìm kiếm chính
  final TextEditingController _searchController = TextEditingController();
  // Dùng cho ô tìm kiếm điểm bắt đầu
  final TextEditingController _startSearchController = TextEditingController();
  //Dùng cho ô tìm kiếm điểm kết thúc
  final TextEditingController _endSearchController = TextEditingController();
  //Vị trí được chọn hoặc nhập làm điểm bắt đầu
  LatLng? _startLocation;
  //Vị trí điểm đến được chọn hoặc nhập
  LatLng? _destinationLocation;
  //Lưu trữ danh sách các tọa độ tạo thành tuyến đường giữa điểm bắt đầu và điểm đến
  List<LatLng> _routePoints = [];
  //Hiển thị hoặc ẩn tuyến đường
  bool _showRoute = false;
  //hướng dẫn lộ trình
  List<Map<String, dynamic>> _routeSteps = [];
  //Tổng quãng đường và thời gian di chuyển
  double _totalDistance = 0;
  String _totalDuration = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    
    // Nếu có địa chỉ được truyền vào, tự động điền vào ô tìm kiếm và tìm kiếm
    if (widget.searchAddress != null && widget.searchAddress != 'Chưa có địa chỉ') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //Gán địa chỉ tìm kiếm
        _endSearchController.text = widget.searchAddress!;
        //Thực hiện tìm kiếm vị trí dựa trên địa chỉ được gán
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
      //Lấy vị trí hiện tại
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (mounted) {
        setState(() {
          //Cập nhật tọa độ hiện tại với vị trí vừa lấy được
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        //Di chuyển bản đồ đến vị trí mới
        _mapController.move(_currentLocation, 15.0);
      }
      //xử lý lỗi nếu xảy ra
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

//tìm kiếm tọa với một địa chỉ cụ thể, cập nhật vị trí đích trên bản đồ và vẽ tuyến đường nếu có điểm bắt đầu.
  Future<void> _searchEndLocation(String address) async {
    try {
      setState(() => _isLoading = true);
      //Tìm kiếm vị trí từ địa chỉ
      List<Location> locations = await locationFromAddress(address);
      //Kiểm tra kết quả tìm kiếm
      if (locations.isNotEmpty && mounted) {
        //Cập nhật vị trí đích
        setState(() {
          _destinationLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _showRoute = false;
          _routePoints.clear();
        });
        _mapController.move(_destinationLocation!, 15.0); //Di chuyển bản đồ
        //Vẽ tuyến đường (nếu có điểm bắt đầu)
        if (_startLocation != null) {
          await _getRoute();
        }
      }
      //xử lý ngoại lệ
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa điểm')),
        );
      }
      //Hoàn tất xử lý
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchStartLocation(String address) async {
    print('Searching start location: $address');
    try {
      setState(() => _isLoading = true);
      List<Location> locations = await locationFromAddress(address);
      //Kiểm tra và cập nhật vị trí bắt đầu
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
          await _getRoute(); //để tính toán và hiển thị tuyến đường từ vị trí bắt đầu đến đích.
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

//Tìm và hiển thị tuyến đường
  Future<void> _getRoute() async {
    //Kiểm tra đầu vào
    if (_startLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập cả điểm bắt đầu và điểm đến')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
//Gửi yêu cầu HTTP đến OSRM, lấy dữ liệu tuyến đường từ API OSRM
      final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/' //Chỉ định chế độ lái xe.
        '${_startLocation!.longitude},${_startLocation!.latitude};' //Tọa độ điểm bắt đầu
        '${_destinationLocation!.longitude},${_destinationLocation!.latitude}' // '' đến
        '?overview=full&geometries=geojson&steps=true' //Bao gồm toàn bộ tuyến đường, ạng GeoJSON, các bước chỉ dẫn chi tiết
      ));

//Xử lý phản hồi thành công
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        //Danh sách các tọa độ của tuyến đường.
        final List<dynamic> coordinates = route['geometry']['coordinates'];
        //Danh sách các bước hướng dẫn trong lộ trình
        final List<dynamic> steps = route['legs'][0]['steps'];
        //Tổng quãng đường (đơn vị: km)
        final distance = route['distance'] / 1000;
        // Thời gian di chuyển (đơn vị: phút).
        final duration = route['duration'] / 60;

//Cập nhật thông tin và bản đồ
        setState(() { //Gọi setState để làm mới giao diện người dùng
          //sử dụng để vẽ đường đi trên bản đồ
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          //Hiển thị tuyến đường trên bản đồ
          _showRoute = true;
          //Cập nhật khoảng cách và thời gian
          _totalDistance = distance;
          _totalDuration = '${duration.round()} phút';
          
          //Chỉ dẫn chi tiết
          _routeSteps = steps.map<Map<String, dynamic>>((step) {
            return {
              'instruction': step['maneuver']['type'],
              'distance': (step['distance'] / 1000).toStringAsFixed(1),
              'duration': (step['duration'] / 60).round(),
            };
          }).toList();
        });

//Điều chỉnh phạm vi bản đồ
        final bounds = LatLngBounds.fromPoints(_routePoints); //Tạo giới hạn bản đồ từ tuyến đường
        //Điều chỉnh camera của bản đồ để phù hợp với một vùng cụ thể
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
      await Share.shareUri(Uri.parse(googleMapsUrl)); //Chia sẻ URL dưới dạng một liên kết
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
        //Hiển thị khoảng cách và thời gian tổng cộng
        totalDistance: _totalDistance,
        totalDuration: _totalDuration,
        //Hiển thị các bước hướng dẫn lộ trình
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
    //Tạo bản đồ bằng FlutterMap
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(10.7769, 106.7009),
        initialZoom: 13.0,
      ),
      children: [
        //Lớp bản đồ nền
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.travelVN_app',
          //Cung cấp các ô bản đồ qua mạng
          tileProvider: NetworkTileProvider(),
          maxZoom: 18,
          minZoom: 4,
          additionalOptions: {
            'useCache': 'true',
            'secure': 'true',
          },
        ),
        //Lớp vẽ tuyến đường
        if (_showRoute && _routePoints.isNotEmpty)
        //Vẽ một đường kết nối các điểm
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 3.0,
              ),
            ],
          ),
        //Lớp đánh dấu vị trí
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
            : _getRoute, //tính toán và hiển thị tuyến đường
          label: const Text('Tìm đường'),
          icon: const Icon(Icons.directions),
          heroTag: 'findRoute',
        ),
        //Hiển thị hướng dẫn
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
