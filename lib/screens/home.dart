import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelvn/screens/blog.dart';
import 'package:travelvn/screens/detail.dart';
import 'package:travelvn/screens/local.dart';
import 'package:travelvn/themes/63VN.dart';
import 'package:travelvn/widgets/63S.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'package:travelvn/screens/map.dart';

import 'package:http/http.dart' as http;
import '../service/blog_service.dart';
import '../models/blog_post.dart';
import 'blog_detail_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> recommendedLocations = [];
  final List<String> category = ['Tất cả địa điểm','Lịch sử', 'Văn hóa Ẩm thực'];
  final BlogService _blogService = BlogService();
  List<BlogPost> _recentPosts = [];

  final PageController _pageController = PageController();
  int _currentPage = 0; // index hiện tại

  // Thêm biến để lưu trữ số lượng comments
  Map<String, int> _commentsCount = {};

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _loadRecentPosts();
    // thay đổi page
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round(); // index hiện tại
      });
    });
    //fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.149:8800/v1/local'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          locations = data.map((item) => item as Map<String, dynamic>).toList();
        });

        _recommendLocations();
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (error) {
      print('Error fetching locations: $error');
    }
  }

  // Thêm hàm để load số lượng comments cho mỗi bài viết
  Future<void> _loadCommentsCount(String postId) async {
    try {
      final count = await _blogService.getCommentsCount(postId);
      setState(() {
        _commentsCount[postId] = count;
      });
    } catch (e) {
      print('Error loading comments count: $e');
    }
  }

  // Cập nhật hàm _loadRecentPosts để load comments count
  Future<void> _loadRecentPosts() async {
    try {
      final posts = await _blogService.getAllPosts();
      setState(() {
        _recentPosts = posts.take(5).toList();
      });
      // Load comments count cho mỗi bài viết
      for (var post in _recentPosts) {
        _loadCommentsCount(post.id);
      }
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  // Đề xuất địa điểm nổi bật dựa trên mức độ phổ biến (ví dụ: dựa vào 'popularity')
  void _recommendLocations() {
    // Giả sử 'popularity' là một giá trị số
    recommendedLocations = List.from(locations)
      ..sort((a, b) => (b['popularity'] ?? 0).compareTo(a['popularity'] ?? 0)); // Sắp xếp theo độ phổ biến

    // Chỉ lấy 5 địa điểm đầu tiên để hiển thị
    recommendedLocations = recommendedLocations.take(5).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Giảm chiều cao của AppBar
        child: HomeAppBar()
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding đồng nhất
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái các phần tử
              children: [
                // Section Header với style thống nhất
                _buildSectionHeader(
                  title: "Địa điểm nổi bật",
                  actionText: "Tất cả địa điểm",
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocalPage()),
                  ),
                ),

                const SizedBox(height: 16),
                
                // Carousel với indicator được cải thiện
                SizedBox(
                  height: 220, // Tăng chiều cao một chút
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: recommendedLocations.length,
                        itemBuilder: (BuildContext context, int index) {
                          final location = recommendedLocations[index];

                          String imageId = location['imgLocal'] != null && location['imgLocal'] is List
                            ? location['imgLocal'][0]  
                            : null;

                          String imageUrl = imageId != null
                            ? 'http://192.168.0.149:8800/v1/img/$imageId'
                            : 'https://example.com/default-image.png'; 

                          return InkWell(
                            onTap: () {
                              // Navigate to Detail screen with the location data
                              print(location);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Detail(location: location),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: EdgeInsets.all(20),
                              margin: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.favorite_outline,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      location['title'] ?? 'Tên địa điểm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.7),
                                            offset: Offset(2, 2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Indicator với animation
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            recommendedLocations.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 63 Tỉnh thành section với card được cải thiện
                _buildSectionHeader(
                  title: "63 Tỉnh Thành",
                  actionText: "Xem tất cả các tỉnh thành",
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Local63Page()),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: locationData.length > 63 ? 63 : locationData.length,
                    itemBuilder: (context, index) {
                      final location = locationData[index];
                      return Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  location.img,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LocalPage()),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        "Khám phá →",
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
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

                const SizedBox(height: 24),

                // Bài Review section
                _buildSectionHeader(
                  title: "Bài Review",
                  actionText: "Xem tất cả",
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BlogPage()),
                  ),
                ),
                
                SizedBox(height: 16),
                
                SizedBox(
                  height: 350, // Tăng chiều cao để hiển thị đầy đủ nội dung
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentPosts.length,
                    itemBuilder: (context, index) {
                      final post = _recentPosts[index];
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.75, // Giảm kích thước so với post_card
                        margin: EdgeInsets.only(right: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogDetailScreen(blogId: post.id),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header với avatar và thông tin người dùng
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16, // Nhỏ hơn post_card
                                        backgroundImage: NetworkImage('http://192.168.0.149:8800/v1/img/default-avatar.jpg'),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.postedBy,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14, // Nhỏ hơn post_card
                                              ),
                                            ),
                                            Text(
                                              _getTimeAgo(post.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12, // Nhỏ hơn post_card
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Title
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 16, // Nhỏ hơn post_card
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                    ),
                                    maxLines: 1, // Chỉ hiển thị 1 dòng
                                    overflow: TextOverflow.ellipsis, // Thêm dấu 3 chấm khi vượt quá 1 dòng
                                  ),
                                  const SizedBox(height: 8),
                                  // Content
                                  Text(
                                    post.content,
                                    style: TextStyle(
                                      fontSize: 12, // Nhỏ hơn post_card
                                      color: Colors.grey[800],
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://192.168.0.149:8800/v1/img/${post.image}',
                                      height: 150, // Nhỏ hơn post_card
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Categories as hashtags
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: post.categories.map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12, // Nhỏ hơn post_card
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 8),

                                  // Action buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.favorite_border,
                                        label: post.likes.toString(),
                                      ),
                                      _buildActionButton(
                                        icon: Icons.chat_bubble_outline,
                                        label: _commentsCount[post.id]?.toString() ?? '0',
                                      ),
                                      _buildActionButton(
                                        icon: Icons.share_outlined,
                                        label: '',
                                      ),
                                      _buildActionButton(
                                        icon: Icons.bookmark_border,
                                        label: '',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue, size: 24), // Thêm icon lịch
                  SizedBox(width: 10), // Khoảng cách giữa icon và tiêu đề
                  Expanded(
                    child: Text(
                      "Lịch của tháng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Khung ngoài cho lịch
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền trắng cho khung
                  borderRadius: BorderRadius.circular(20), // Bo góc mềm mại
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12, // Đổ bóng nhẹ nhàng
                      blurRadius: 8,
                      offset: Offset(0, 4), // Đổ bóng ở phía dưới
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12), // Khoảng cách bên trong khung
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarPage(),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 350, // Giới hạn chiều cao cho lịch
                    width: double.infinity, // Chiều rộng tự động phù hợp với màn hình
                    child: TableCalendar(
                      focusedDay: DateTime.now(),
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Colors.red, // Màu đỏ cho các ngày cuối tuần
                        ),
                        todayTextStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
                SizedBox(height: 20),
                Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15.0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Bản đồ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      },
                      child: const MapScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 2),
    );
  }

  // Helper widget để tạo header sections
  Widget _buildSectionHeader({
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}