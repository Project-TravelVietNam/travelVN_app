import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelvn/widgets/home_bottom_bar.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isExpanded = false; // Biến để lưu trạng thái xem thêm
  Local? localData; // Biến nullable lưu trữ dữ liệu lấy từ API

  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm fetchData khi khởi tạo widget
  }

  // Hàm lấy dữ liệu từ API
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.0.149:8800/v1/local"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          localData = Local.fromJson(data[0]); // Lấy dữ liệu đầu tiên từ API
        });
      } else {
        throw Exception('Không thể tải dữ liệu');
      }
    } catch (error) {
      print('Lỗi khi tải dữ liệu: $error');
    }
  }

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
      body: localData == null
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa lấy được dữ liệu
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        // Kiểm tra nếu imgLocal không phải là null và có ít nhất một ảnh
                        localData!.imgLocal.isNotEmpty
                            ? 'http://192.168.0.149:8800/images/${localData!.imgLocal[0]}'
                            : 'https://via.placeholder.com/150', // Sử dụng hình ảnh mặc định nếu không có ảnh
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
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
                          return Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            print('Đã nhấn yêu thích');
                          },
                          child: Icon(
                            Icons.favorite_border,
                            color: const Color.fromARGB(255, 252, 252, 252),
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      localData!.title.isNotEmpty ? localData!.title : 'Chưa có tiêu đề', // Kiểm tra tiêu đề
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          localData!.region.isNotEmpty ? localData!.region : 'Chưa có khu vực', // Kiểm tra khu vực
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GIỚI THIỆU CHI TIẾT',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Địa điểm',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          localData!.content.isNotEmpty ? localData!.content : 'Chưa có mô tả', // Kiểm tra mô tả
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 8),
                          Text(
                            'Địa chỉ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            localData!.address.isNotEmpty ? localData!.address : 'Chưa có địa chỉ', // Kiểm tra và hiển thị địa chỉ
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(isExpanded ? 'Thu gọn' : '...Xem thêm'),
                        ),
                      ],
                    ),
                  ),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
        onPressed: () {},
        label: Text('Thêm kế hoạch'),
        icon: Icon(Icons.add),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3), // Sử dụng HomeBottomBar ở đây
    );
  }

  // Hàm tạo đánh giá
  Widget buildRatingRow(int starCount, double percentage) {
    return Row(
      children: [
        Text('$starCount sao', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm tạo phần nhận xét
  Widget buildCommentSection(String userName, String timeAgo, String imageUrl, int rating, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(imageUrl), radius: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(timeAgo, style: TextStyle(color: Colors.black54, fontSize: 12)),
              Row(
                children: List.generate(rating, (index) => Icon(Icons.star, color: Colors.blue)),
              ),
              SizedBox(height: 4),
              Text(comment, style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

// Model dữ liệu
class Local {
  final String id;
  final String content;
  final String title;
  final String region;
  final List<String> imgLocal;
  final String address;

  Local({
    required this.id,
    required this.content,
    required this.title,
    required this.region,
    required this.imgLocal,
    required this.address,
  });

  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      id: json['_id'] ?? '', // Kiểm tra null, nếu null thì gán giá trị mặc định
      content: json['content'] ?? '', // Kiểm tra null
      title: json['title'] ?? '', // Kiểm tra null
      region: json['region']?['name'] ?? '', // Kiểm tra nếu 'region' hoặc 'name' là null
      imgLocal: json['imgLocal'] != null ? List<String>.from(json['imgLocal']) : [], // Kiểm tra null cho imgLocal
      address: json['address'] ?? '', // Kiểm tra null
    );
  }
}
