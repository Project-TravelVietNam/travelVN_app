import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelvn/screens/blog.dart';
import 'package:travelvn/screens/detail.dart';
import 'package:travelvn/screens/local.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> recommendedLocations = [];
  final List<String> category = ['Tất cả địa điểm','Lịch sử', 'Văn hóa Ẩm thực'];

  final PageController _pageController = PageController();
  int _currentPage = 0; // index hiện tại

  @override
  void initState() {
    super.initState();
    fetchLocations();
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

  void navigateToDetail(Map<String, dynamic> location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detail(),
      ),
    );
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
      appBar: const PreferredSize(preferredSize: Size.fromHeight(90.0), child: HomeAppBar()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 15.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Địa điểm nổi bật",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LocalPage()), 
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 15.0),
                        alignment: Alignment.topRight,
                        child: Text(
                          "Tất cả địa điểm",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue, 
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 200,
                        child: recommendedLocations.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : PageView.builder(
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
                      ),
                    ),
                  ],
                ),


              SizedBox(height: 20),
              // Chấm chỉ số trang
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(recommendedLocations.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index == _currentPage ? Colors.blueAccent : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                // Dòng các danh mục
                SizedBox(height: 20),
                Text(
                  "Danh mục địa điểm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        for (int i = 0; i < (category.length < 3 ? category.length : 3); i++)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LocalPage()), 
                                  );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                backgroundColor: Colors.white, // Màu nền cho nút
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.black26,
                                elevation: 4,
                              ),
                              child: Text(
                                category[i],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black, // Màu chữ
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Cuộn ngang các địa điểm gợi ý
                SizedBox(
                  height: 220, 
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8), 
                      child: Wrap( 
                        spacing: 12, 
                        runSpacing: 8, 
                        children: locations.map((location) {
                          String imageId = location['imgLocal'] != null && location['imgLocal'] is List
                              ? location['imgLocal'][0]  
                              : null;

                          String imageUrl = imageId != null
                              ? 'http://192.168.0.149:8800/v1/img/$imageId'
                              : 'https://example.com/default-image.png'; 

                          return GestureDetector(
                            onTap: () => navigateToDetail(location), 
                            child: Container(
                              width: 170, 
                              padding: EdgeInsets.all(12), 
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20), 
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1), 
                                    blurRadius: 12, 
                                    spreadRadius: 1, 
                                    offset: Offset(0, 4), 
                                  ),
                                ],
                                gradient: LinearGradient( 
                                  colors: [Colors.white, Colors.grey.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      alignment: Alignment.center, 
                                      height: 120,
                                      width: 120, 
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 40.0,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    location['title'] ?? 'Tên địa điểm',
                                    style: TextStyle(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center, 
                                  ),
                                  SizedBox(height: 4), 
                                  if (location['region'] != null)
                                    Text(
                                      location['region']['name'] ?? 'Tên Tỉnh',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                      "Bài Review",
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
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 234, 237, 241), // Màu lam cho khung ngoài
                  borderRadius: BorderRadius.circular(15), // Bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2), // Đổ bóng
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10), // Khoảng cách bên trong khung
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogPage(),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 340, 
                    width: 330, 
                    
                  ),
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
                  height: 300,
                  // child: GoogleMap(
                  //   onMapCreated: _onMapCreated,
                  //   initialCameraPosition: CameraPosition(
                  //     target: _center,
                  //     zoom: 12.0,
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 2),
    );
  }
}