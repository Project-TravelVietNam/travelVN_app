import 'package:flutter/material.dart';
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
                      onTap: () {
                        print('Đã nhấn yêu thích');
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
                          Icons.favorite_border,
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
// List<Location> locationData = [
//     Location(img: 'assets/images/63S/angiang.png', title: "An Giang"),
//     Location(img: 'assets/images/63S/bacgiang.png', title: "Bắc Giang"),
//     Location(img: 'assets/images/63S/backan.png', title: "Bắc Kạn"),
//     Location(img: 'assets/images/63S/baclieu.png', title: "Bạc Liêu"),
//     Location(img: 'assets/images/63S/bacninh.png', title: "Bắc Ninh"),
//     Location(img: 'assets/images/63S/bentre.png', title: "Bến Tre"),
//     Location(img: 'assets/images/63S/binhduong.png', title: "Bình Dương"),
//     Location(img: 'assets/images/63S/binhdinh.png', title: "Bình Định"),
//     Location(img: 'assets/images/63S/binhphuoc.png', title: "Bình Phước"),
//     Location(img: 'assets/images/63S/binhthuan.png', title: "Bình Thuận"),
//     Location(img: 'assets/images/63S/camau.png', title: "Cà Mau"),
//     Location(img: 'assets/images/63S/cantho.png', title: "Cần Thơ"),
//     Location(img: 'assets/images/63S/caobang.png', title: "Cao Bằng"),
//     Location(img: 'assets/images/63S/daklak.png', title: "Đắk Lắk"),
//     Location(img: 'assets/images/63S/daknong.png', title: "Đắk Nông"),
//     Location(img: 'assets/images/63S/danang.png', title: "Đà Nẵng"),
//     Location(img: 'assets/images/63S/dienbien.png', title: "Điện Biên"),
//     Location(img: 'assets/images/63S/dongnai.png', title: "Đồng Nai"),
//     Location(img: 'assets/images/63S/dongthap.png', title: "Đồng Tháp"),
//     Location(img: 'assets/images/63S/gialai.png', title: "Gia Lai"),
//     Location(img: 'assets/images/63S/hagiang.png', title: "Hà Giang"),
//     Location(img: 'assets/images/63S/hanam.png', title: "Hà Nam"),
//     Location(img: 'assets/images/63S/hanoi.png', title: "Hà Nội"),
//     Location(img: 'assets/images/63S/hatinh.png', title: "Hà Tĩnh"),
//     Location(img: 'assets/images/63S/haiduong.png', title: "Hải Dương"),
//     Location(img: 'assets/images/63S/haiphong.png', title: "Hải Phòng"),
//     Location(img: 'assets/images/63S/haugiang.png', title: "Hậu Giang"),
//     Location(img: 'assets/images/63S/hoabinh.png', title: "Hòa Bình"),
//     Location(img: 'assets/images/63S/hue.png', title: "Huế"),
//     Location(img: 'assets/images/63S/hungyen.png', title: "Hưng Yên"),
//     Location(img: 'assets/images/63S/khanhhoa.png', title: "Khánh Hòa"),
//     Location(img: 'assets/images/63S/kiengiang.png', title: "Kiên Giang"),
//     Location(img: 'assets/images/63S/kontum.png', title: "Kon Tum"),
//     Location(img: 'assets/images/63S/laichau.png', title: "Lai Châu"),
//     Location(img: 'assets/images/63S/lamdong.png', title: "Lâm Đồng"),
//     Location(img: 'assets/images/63S/langson.png', title: "Lạng Sơn"),
//     Location(img: 'assets/images/63S/laocai.png', title: "Lào Cai"),
//     Location(img: 'assets/images/63S/longan.png', title: "Long An"),
//     Location(img: 'assets/images/63S/namdinh.png', title: "Nam Định"),
//     Location(img: 'assets/images/63S/nghean.png', title: "Nghệ An"),
//     Location(img: 'assets/images/63S/ninhbinh.png', title: "Ninh Bình"),
//     Location(img: 'assets/images/63S/ninhthuan.png', title: "Ninh Thuận"),
//     Location(img: 'assets/images/63S/phutho.png', title: "Phú Thọ"),
//     Location(img: 'assets/images/63S/phuyen.png', title: "Phú Yên"),
//     Location(img: 'assets/images/63S/quangbinh.png', title: "Quảng Bình"),
//     Location(img: 'assets/images/63S/quangnam.png', title: "Quảng Nam"),
//     Location(img: 'assets/images/63S/quangngai.png', title: "Quảng Ngãi"),
//     Location(img: 'assets/images/63S/quangninh.png', title: "Quảng Ninh"),
//     Location(img: 'assets/images/63S/quangtri.png', title: "Quảng Trị"),
//     Location(img: 'assets/images/63S/soctrang.png', title: "Sóc Trăng"),
//     Location(img: 'assets/images/63S/sonla.png', title: "Sơn La"),
//     Location(img: 'assets/images/63S/tayninh.png', title: "Tây Ninh"),
//     Location(img: 'assets/images/63S/thaibinh.png', title: "Thái Bình"),
//     Location(img: 'assets/images/63S/thainguyen.png', title: "Thái Nguyên"),
//     Location(img: 'assets/images/63S/thanhhoa.png', title: "Thanh Hóa"),
//     Location(img: 'assets/images/63S/tiengiang.png', title: "Tiền Giang"),
//     Location(img: 'assets/images/63S/hcm.png', title: "TP Hồ Chí Minh"),
//     Location(img: 'assets/images/63S/travinh.png', title: "Trà Vinh"),
//     Location(img: 'assets/images/63S/tuyenquang.png', title: "Tuyên Quang"),
//     Location(img: 'assets/images/63S/vinhlong.png', title: "Vĩnh Long"),
//     Location(img: 'assets/images/63S/vinhphuc.png', title: "Vĩnh Phúc"),
//     Location(img: 'assets/images/63S/yenbai.png', title: "Yên Bái"),
//   ];
