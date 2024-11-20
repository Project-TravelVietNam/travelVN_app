import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:travelvn/widgets/table_calendar.dart';

class Detail extends StatefulWidget {
  final Map<String, dynamic> location;

  const Detail({super.key, required this.location});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isExpanded = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }
  
 Future<void> _loadFavoriteStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesString = prefs.getString('favorite_places_ids');
  
  // Kiểm tra nếu có danh sách yêu thích trong SharedPreferences
  if (favoritesString != null) {
    final favoriteIds = List<String>.from(json.decode(favoritesString));
    
    // Kiểm tra xem id có trong danh sách yêu thích không
    setState(() {
      isFavorite = favoriteIds.contains(widget.location['id'].toString());
    });
  } else {
    // Nếu danh sách yêu thích không tồn tại, mặc định là false
    setState(() {
      isFavorite = false; // Mặc định không yêu thích
    });
  }
}


  // Thay đổi trạng thái yêu thích
 Future<void> _toggleFavorite() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Lấy danh sách các ID yêu thích đã lưu trong SharedPreferences
  final favoritesString = prefs.getString('favorite_places_ids');
  List<String> favoriteIds = [];

  // Nếu danh sách đã tồn tại, giải mã JSON thành danh sách ID
  if (favoritesString != null) {
    favoriteIds = List<String>.from(json.decode(favoritesString));
  }

  // Lấy ID của địa điểm hiện tại
  final id = widget.location['_id'].toString();

  // Kiểm tra xem ID địa điểm đã tồn tại trong danh sách yêu thích chưa
  bool isCurrentlyFavorite = favoriteIds.contains(id);

  // Nếu đã có trong danh sách, xóa khỏi danh sách, ngược lại thêm vào danh sách
  if (isCurrentlyFavorite) {
    favoriteIds.remove(id); // Xóa khỏi danh sách yêu thích
  } else {
    favoriteIds.add(id); // Thêm vào danh sách yêu thích
  }

  // Lưu lại danh sách ID vào SharedPreferences
  await prefs.setString('favorite_places_ids', json.encode(favoriteIds));

  // Lưu thông tin chi tiết các địa điểm yêu thích vào SharedPreferences
  final String favoritePlacesString = prefs.getString('favorite_places') ?? '[]';
  List<Map<String, dynamic>> allFavoritePlaces = List<Map<String, dynamic>>.from(json.decode(favoritePlacesString));

  // Kiểm tra nếu địa điểm chưa có trong danh sách yêu thích
  if (isCurrentlyFavorite && !favoriteIds.contains(id)) {
    allFavoritePlaces.removeWhere((place) => place['_id'].toString() == id); // Xóa khỏi danh sách chi tiết
  } else if (!isCurrentlyFavorite && !allFavoritePlaces.any((place) => place['_id'].toString() == id)) {
    allFavoritePlaces.add(widget.location); // Thêm địa điểm vào danh sách chi tiết yêu thích
  }

  // Lưu lại danh sách chi tiết các địa điểm yêu thích vào SharedPreferences
  await prefs.setString('favorite_places', json.encode(allFavoritePlaces));

  // Cập nhật giao diện để hiển thị trạng thái yêu thích mới
  setState(() {
    isFavorite = !isCurrentlyFavorite; // Cập nhật trạng thái yêu thích
  });

  // Hiển thị thông báo cho người dùng
  final snackBar = SnackBar(
    content: Text(isFavorite ? 'Đã thêm vào yêu thích!' : 'Đã xóa khỏi yêu thích!'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        backgroundColor: const Color.fromARGB(255, 171, 201, 226), // Đặt màu xanh cho nút
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