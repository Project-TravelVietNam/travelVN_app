import 'package:flutter/material.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailCulural extends StatefulWidget {
  final Map<String, dynamic> location;

  const DetailCulural({super.key, required this.location});

  @override
  _DetailCuluralState createState() => _DetailCuluralState();
}

class _DetailCuluralState extends State<DetailCulural> {
  bool isExpanded = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi thay đổi trạng thái yêu thích')),
      );
    }
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
                        child: Text(
                          localData['address'] ?? 'Chưa có địa chỉ',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/anh1.png', width: 80, height: 80, fit: BoxFit.cover),
                  Image.asset('assets/images/anh2.png', width: 80, height: 80, fit: BoxFit.cover),
                  Image.asset('assets/images/anh3.png', width: 80, height: 80, fit: BoxFit.cover),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nhận xét (33)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            buildCommentSection('Khoai Lang Thang', '3 giờ 15 phút trước', 'assets/images/user1.png', 4, 'Ở đây có rất nhiều địa điểm để khám phá du lịch.'),
            buildCommentSection('Kang Ho', '4 ngày trước', 'assets/images/user2.png', 5, 'I was very happy to be exposed to the culture here.'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bando.png'),
                    fit: BoxFit.cover,
                  ),
                ),
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
        backgroundColor: const Color.fromARGB(255, 171, 201, 226), // Đặt màu xanh cho n��t
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
}
