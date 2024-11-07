// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_app_top.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/widgets/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> category = [
    'Địa điểm nổi bật',
    'Di tích',
    'Biển',
    'Đảo',
    'Núi',
    '...',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0; // index hiện tại

  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(21.0285, 105.8542);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // thay đổi page
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round(); // index hiện tại
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: HomeAppTop(),
      appBar: const PreferredSize(preferredSize: Size.fromHeight(90.0), child: HomeAppBar()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 6,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              // thêm vô đây để chuyển trang đến các địa điểm
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
                                      "City Name", //nữa mấy cái dữ liệu để vô đây
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
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: index == _currentPage ? Colors.blueAccent : Colors.grey, // Đổi màu dựa trên chỉ số
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      for (int i = 0; i < 6; i++)
                        Container(
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
                          child: Text(
                            category[i],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15.0),
                      alignment: Alignment.topLeft,
                      child: Text(
                      "Lịch của tháng",
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

              // hiển thị lịch thu nhỏ

              // Khung ngoài cho lịch
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 247, 255), // Màu lam cho khung ngoài
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
                        builder: (context) => CalendarPage(),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 340, // Giới hạn chiều cao cho lịch
                    width: 330, // Giới hạn chiều rộng cho lịch
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
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 2),
    );
  }
}