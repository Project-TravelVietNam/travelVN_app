import 'package:flutter/material.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:travelvn/screens/map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../service/local_service.dart';
import '../service/auth_service.dart';

class DetailCulural extends StatefulWidget {
  final Map<String, dynamic> location;

  const DetailCulural({super.key, required this.location});

  @override
  _DetailCuluralState createState() => _DetailCuluralState();
}

class _DetailCuluralState extends State<DetailCulural> {
  bool isExpanded = false;
  bool isFavorite = false;
  List<dynamic> suggestedLocations = [];
  LatLng? _locationCoordinates;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];
  double _userRating = 5.0;
  bool _isSubmittingReview = false;
  bool _isLoadingReviews = false;
  double _averageRating = 0.0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _fetchSuggestedLocations();
    _loadLocationCoordinates();
    _loadReviews().then((_) {
    _calculateAverageRating();
    });
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
        final culturals = List<Map<String, dynamic>>.from(data['culturals'] ?? []);
        final currentId = widget.location['_id'].toString();
        
        setState(() {
          isFavorite = culturals.any((item) => item['_id'].toString() == currentId);
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
          Uri.parse('http://192.168.0.149:8800/v1/favorite/${id}'),
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
            'type': 'cultural',
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
      final currentRegionName = widget.location['region']['name'];
      
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/cultural'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final filtered = (data as List).where((location) {
          // Kiểm tra null safety
          if (location == null || 
              location['region'] == null || 
              location['region']['name'] == null ||
              location['_id'] == null) {
            return false;
          }
          
          return location['region']['name'] == currentRegionName && 
                 location['_id'] != widget.location['_id'];
        }).take(5).toList();
        
        print("Filtered Locations: ${filtered.length} items");
        
        setState(() {
          suggestedLocations = filtered;
        });
      } else {
        print("API Error Status Code: ${response.statusCode}");
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
  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/cultural/review/all/${widget.location['_id']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reviewsData = json.decode(response.body);
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(reviewsData);
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) return;

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final user = await _authService.getUserInfo();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.0.149:8800/v1/cultural/reviews/${widget.location['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': user['_id'],
          'rating': _userRating.round(),
          'comment': _reviewController.text,
        }),
      );

      if (response.statusCode == 201) {
        _reviewController.clear();
        await _loadReviews();
        _calculateAverageRating();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đánh giá đã được thêm thành công')),
        );
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    double total = 0;
    for (var review in _reviews) {
      total += (review['rating'] ?? 0).toDouble();
    }
    setState(() {
      _averageRating = total / _reviews.length;
    });
  }

  Widget _buildRatingOverview() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < _averageRating
                    ? Icons.star
                    : index < _averageRating + 0.5
                        ? Icons.star_half
                        : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          SizedBox(height: 8),
          Text(
            '${_reviews.length} đánh giá',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: [5, 4, 3, 2, 1].map((star) {
              int count = _reviews.where((r) => (r['rating'] ?? 0) == star).length;
              double ratio = _reviews.isEmpty ? 0 : count / _reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${(ratio * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và số lượng đánh giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bình luận (${_reviews.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Rating stars
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userRating = index + 1.0;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      size: 32,
                      color: index < _userRating ? Colors.amber : Colors.grey[400],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12),
          
          // Text input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.blue,
                  width: 1.0,
                ),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: 'Viết đánh giá...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    maxLines: null,
                    enabled: !_isSubmittingReview,
                  ),
                ),
                if (!_isSubmittingReview)
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _submitReview,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
                          localData['imgculural'] != null && localData['imgculural'].isNotEmpty
                              ? 'http://192.168.0.149:8800/v1/img/${localData['imgculural'][0]}'
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
                      localData['imgculural'] != null && localData['imgculural'].isNotEmpty
                          ? 'http://192.168.0.149:8800/v1/img/${localData['imgculural'][0]}'
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
                      onTap: _toggleFavorite,
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
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
                      localData['region']?['name'] ?? 'Chưa có khu vực',
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
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            buildSuggestedLocations(),
            SizedBox(height: 10),
            if (!_isLoadingReviews) ...[
              _buildRatingOverview(),
              SizedBox(height: 10),
              _buildReviewForm(),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_reviews.isEmpty)
                      Center(
                        child: Text(
                          'Chưa có đánh giá nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return buildCommentSection(
                            review['username'] ?? 'Anonymous',
                            _getTimeAgo(DateTime.parse(review['createdAt'])),
                            review['rating'] ?? 5,
                            review['comment'] ?? '',
                          );
                        },
                      ),
                  ],
                ),
              ),
            ] else
              Center(
                child: CircularProgressIndicator(),
              ),
            
            Padding(
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
                              initialCenter: LatLng(16.4637, 107.5909), // Vị trí mặc định
                              initialZoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(16.4637, 107.5909), // Sẽ được cập nhật từ địa chỉ
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
            ),
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
          
        ],
      ),
    );
  }

  Widget buildCommentSection(String name, String time, int rating, String comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
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
      return SizedBox.shrink();
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
                final imageUrl = location['imgculural'] != null && location['imgculural'].isNotEmpty
                    ? 'http://192.168.0.149:8800/v1/img/${location['imgculural'][0]}'
                    : 'https://via.placeholder.com/160x120';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailCulural(location: location),
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
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}