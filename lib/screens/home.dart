// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelvn/screens/blog.dart';
import 'package:travelvn/screens/local.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> recommendedLocations = [];
  final List<String> category = [
    'Lịch sử',
    'Văn hóa',
    'Ẩm thực',
    
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0; // index hiện tại

  GoogleMapController ? mapController;
  final LatLng _center = const LatLng(21.0285, 105.8542);
  
  // late GoogleMapController _mapController;
  // LatLng _currentPosition = LatLng(21.0285, 105.8542);

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _getCurrentLocation();
    // thay đổi page
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round(); // index hiện tại
      });
    });
    fetchLocations();
  }

  // Lấy dữ liệu từ Firestore và sử dụng học máy để đề xuất
  Future<void> fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('local').get();

    // Lấy tất cả địa điểm
    setState(() {
      locations = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });

    // Áp dụng mô hình học máy (ví dụ: sắp xếp theo độ phổ biến)
    _recommendLocations();
  }

  void navigateToDetail(Map<String, dynamic> location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(location: location),
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
  
  
  Future<void> _getCurrentLocation() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    // Yêu cầu quyền truy cập vị trí
    status = await Permission.location.request();
    if (!status.isGranted) {
      // Nếu người dùng từ chối, hiển thị thông báo lỗi hoặc xử lý logic tương ứng
      print('User denied permissions to access the device\'s location.');
      return;
    }
  }

  // Nếu quyền đã được cấp, tiếp tục lấy vị trí
  // Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high);
  // setState(() {
  //   _currentPosition = LatLng(position.latitude, position.longitude);
  // });
}

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
                                controller: _pageController, // Cập nhật controller
                                itemCount: recommendedLocations.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final location = recommendedLocations[index];
                                  return InkWell(
                                    onTap: () {
                                      // Thêm mã để chuyển trang hoặc làm gì đó khi click vào địa điểm
                                    },
                                    child: Container(
                                      width: 160,
                                      padding: EdgeInsets.all(20),
                                      margin: EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: AssetImage("assets/images/city${index + 1}.png"),
                                          fit: BoxFit.cover,
                                        ),
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
                                            child: Text(
                                              location['local_name'] ?? 'Tên địa điểm',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
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
                                // Thêm hành động khi nhấn vào nút, ví dụ:
                                print("Button category ${i + 1} pressed");
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
                SizedBox(height: 20),
                // Cuộn ngang các địa điểm gợi ý
                SizedBox(
                  height: 200, // Cài đặt chiều cao cho vùng cuộn
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: locations.map((location) {
                          return GestureDetector(
                            onTap: () => navigateToDetail(location),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(location['image_url'] ?? 'https://via.placeholder.com/120'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    location['local_name'] ?? 'Tên địa điểm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                
                // Google Map Widget
                // Widget Google Map
                // Container(
                //   height: 200,
                //   margin: const EdgeInsets.symmetric(horizontal: 15),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(15),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black26,
                //         blurRadius: 4,
                //         offset: Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(15),
                //     child: GestureDetector(
                //       onTap: () async {
                //         // Đảm bảo vị trí hiện tại có sẵn
                //         if (_currentPosition.latitude != 0 && _currentPosition.longitude != 0) {
                //           String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${_currentPosition.latitude},${_currentPosition.longitude}";
                //           if (await canLaunch(googleMapsUrl)) {
                //             await launch(googleMapsUrl);
                //           } else {
                //             print('Không thể mở Google Maps.');
                //           }
                //         } else {
                //           print('Vị trí hiện tại không có sẵn.');
                //         }
                //       },
                //       child: GoogleMap(
                //         initialCameraPosition: CameraPosition(
                //           target: _currentPosition,
                //           zoom: 16,
                //         ),
                //         onMapCreated: (controller) {
                //           _mapController = controller;
                //           print('Google Map đã được tạo thành công');
                //         },
                //         myLocationEnabled: true,
                //         markers: {
                //           Marker(
                //             markerId: MarkerId("current_location"),
                //             position: _currentPosition,
                //           ),
                //         },
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 12.0,
                    ),
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
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> location;

  DetailPage({required this.location});

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${location['local_id'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.0),
            Text(
              location['local_name'] ?? 'Tên địa điểm',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            // Thêm các chi tiết khác nếu cần
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
}