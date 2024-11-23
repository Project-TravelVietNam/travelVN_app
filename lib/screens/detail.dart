import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelvn/screens/map.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import 'package:http/http.dart' as http;

class Detail extends StatefulWidget {
  final Map<String, dynamic> location;

  const Detail({super.key, required this.location});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isExpanded = false;
  bool isFavorite = false;
  List<dynamic> suggestedLocations = [];
  LatLng? _locationCoordinates;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _fetchSuggestedLocations();
    _loadLocationCoordinates();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _loadFavoriteStatus() async {
    final token = await getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/favorite'),
        headers: {
          'Cookie': 'access_token=$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final locals = List<Map<String, dynamic>>.from(data['locals'] ?? []);
        final currentId = widget.location['_id'].toString();
        
        setState(() {
          isFavorite = locals.any((item) => item['_id'].toString() == currentId);
        });
      }
    } catch (e) {
      print('Error loading favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final token = await getToken();
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để sử dụng tính năng này')),
      );
      return;
    }

    final id = widget.location['_id'].toString();
    
    try {
      if (isFavorite) {
        // Xóa yêu thích
        final response = await http.delete(
          Uri.parse('http://192.168.0.149:8800/v1/favorite/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'access_token=$token',
          },
        );
        
        if (response.statusCode == 200) {
          setState(() {
            isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa khỏi yêu thích!')),
          );
          // Di chuyển Navigator.pop() vào một Future.delayed
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
        } else {
          print('Error response: ${response.body}');
          throw Exception('Failed to remove from favorites');
        }
      } else {
        // Thêm yêu thích
        final response = await http.post(
          Uri.parse('http://192.168.0.149:8800/v1/favorite'),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'access_token=$token',
          },
          body: json.encode({
            'type': 'local',
            'itemId': id,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm vào yêu thích!')),
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi thay đổi trạng thái yêu thích')),
      );
    }
  }

  Future<void> _fetchSuggestedLocations() async {
    try {
      // Lấy region name của địa điểm hiện tại
      final currentRegionName = widget.location['region']['name'];
      
      // Gọi API lấy tất cả địa điểm
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/local'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Lọc địa điểm cùng region name và loại bỏ địa điểm hiện tại
          suggestedLocations = (data as List)
              .where((location) => 
                location['region']['name'] == currentRegionName && 
                location['_id'] != widget.location['_id'])
              .take(5)
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching suggested locations: $e');
    }
  }

  Future<void> _loadLocationCoordinates() async {
    if (widget.location['address'] != null) {
      final coordinates = await _getCoordinatesFromAddress(widget.location['address']);
      if (coordinates != null) {
        setState(() {
          _locationCoordinates = coordinates;
        });
      }
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var localData = widget.location;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: "Travel",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: "VietNam",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Hiển thị ảnh chi tiết khi nhấn
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent, // Cho nền trong suốt
                      child: Stack(
                        children: [
                          // Ảnh hiển thị toàn màn hình
                          PhotoView(
                            imageProvider: NetworkImage(
                              localData['imgLocal'] != null && localData['imgLocal'].isNotEmpty
                                  ? 'http://192.168.0.149:8800/v1/img/${localData['imgLocal'][0]}'
                                  : 'https://via.placeholder.com/600',
                            ),
                          ),
                          // Nút X để đóng ảnh
                          Positioned(
                            top: 20,
                            left: 20,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: () {
                                Navigator.of(context).pop(); // Đóng Dialog
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    child: Image.network(
                      localData['imgLocal'] != null && localData['imgLocal'].isNotEmpty
                          ? 'http://192.168.0.149:8800/v1/img/${localData['imgLocal'][0]}'
                          : 'https://via.placeholder.com/600',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20, 
                    child: Text(
                      localData['title'] ?? 'Chưa có tiêu đề',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3, 
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2)),
                        ],
                      ),
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: GestureDetector(
                      onTap: () async {
                        await _loadFavoriteStatus();
                        await _toggleFavorite(); // Gọi phương thức _toggleFavorite để thay đổi trạng thái yêu thích
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border, // Hiển thị icon yêu thích hoặc không yêu thích
                          color: isFavorite ? Colors.red : Colors.grey, // Màu đỏ nếu yêu thích, màu xám nếu chưa yêu thích
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      // Kiểm tra nếu localData['region'] là null hoặc không hợp lệ
                      localData['region'] != null && localData['region'] is Map
                          ? localData['region']['name'] ?? 'Chưa có khu vực'
                          : 'Chưa có khu vực',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giới thiệu chi tiết',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    firstChild: Text(
                      localData['content'] ?? 'Chưa có mô tả',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    secondChild: Text(
                      localData['content'] ?? 'Chưa có mô tả',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    crossFadeState:
                        isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isExpanded ? 'Thu gọn' : 'Xem thêm',
                            style: TextStyle(color: Colors.blue)),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Địa chỉ:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  searchAddress: localData['address'] ?? 'Chưa có địa chỉ',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            localData['address'] ?? 'Chưa có địa chỉ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue, // Thêm màu để chỉ ra có thể nhấn
                              decoration: TextDecoration.underline, // Thêm gạch chân
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4,7',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(Icons.star, color: Colors.blue);
                        }),
                      ),
                      SizedBox(height: 4),
                      Text('Đánh giá nhận xét'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  buildRatingRow(5, 0.85),
                  buildRatingRow(4, 0.10),
                  buildRatingRow(3, 0.05),
                  buildRatingRow(2, 0.0),
                  buildRatingRow(1, 0.0),
                ],
              ),
            ),
            buildSuggestedLocations(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nhận xét (33)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            buildCommentSection('Khoai Lang Thang', '3 giờ 15 phút trước', 'assets/images/user1.png', 4, 'Ở đây có rất nhiều địa điểm để khám phá du lịch.'),
            buildCommentSection('Kang Ho', '4 ngày trước', 'assets/images/user2.png', 5, 'I was very happy to be exposed to the culture here.'),
            _buildMapPreview(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalendarPage()), // Điều hướng đến trang table_calendar.dart
          );
        },
        label: Text('Thêm kế hoạch'),
        icon: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 171, 201, 226), // Đặt màu xanh cho nt
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
  
  Widget buildRatingRow(int starCount, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$starCount'),
          SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentSection(String name, String time, String avatarPath, int rating, String comment) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              avatarPath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: List.generate(rating, (index) {
                    return Icon(Icons.star, color: Colors.blue);
                  })..addAll(List.generate(5 - rating, (index) {
                    return Icon(Icons.star_border, color: Colors.blue);
                  })),
                ),
                SizedBox(height: 4),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageTile(String imagePath, String title) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            imagePath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
      
    );
    
  }

  Widget buildSuggestedLocations() {
    if (suggestedLocations.isEmpty) {
      return SizedBox.shrink(); // Không hiển thị gì nếu không có đề xuất
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa điểm khác tại ${widget.location['region']['name']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestedLocations.length,
              itemBuilder: (context, index) {
                final location = suggestedLocations[index];
                final imageUrl = location['imgLocal'] != null && location['imgLocal'].isNotEmpty
                    ? 'http://192.168.0.149:8800/v1/img/${location['imgLocal'][0]}'
                    : 'https://via.placeholder.com/160x120';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Detail(location: location),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location['title'] ?? 'Chưa có tiêu đề',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location['region']['name'] ?? 'Chưa có khu vực',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí trên bản đồ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: _locationCoordinates ?? LatLng(16.4637, 107.5909),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (_locationCoordinates != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _locationCoordinates!,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        widget.location['address'] ?? 'Chưa có địa chỉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              searchAddress: widget.location['address'] ?? 'Chưa có địa chỉ',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.open_in_full,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}