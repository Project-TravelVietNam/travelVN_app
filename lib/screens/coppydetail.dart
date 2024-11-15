
import 'package:flutter/material.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isExpanded = false; // Biến để lưu trạng thái xem thêm

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/anhdau1.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
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
                'Huyện Cù Lao Dung',
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
                    'Sóc Trăng',
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
                    'Huyện Cù Lao Dung nằm ở phía đông tỉnh Sóc Trăng, nằm giữa tỉnh Sóc Trăng và tỉnh Trà Vinh, nhưng thực sự huyện là bao gồm 3 hòn cù lao nhỏ góp lại. Đây là một địa điểm đẹp và có nhiều cảnh quan thiên nhiên.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (isExpanded) ...[
                    SizedBox(height: 8),
                    Text(
                      'Lịch sử',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trước năm 2002, huyện Cù Lao Dung thuộc huyện Long Phú, tỉnh Sóc Trăng. Ngày 11 tháng 1 năm 2002, Chính phủ ban hành Nghị định thành lập huyện Cù Lao Dung...',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Văn Hóa ẩm thực',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Huyện Cù Lao Dung có nền văn hóa ẩm thực phong phú với nhiều món ăn đặc trưng của vùng đồng bằng sông Cửu Long.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Địa điểm nổi bật',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildImageTile('assets/images/anh1.png', 'Đền thờ Bác Hồ'),
                          SizedBox(width: 8),
                          buildImageTile('assets/images/anh2.png', 'Cầu Mỹ Thuận'),
                          SizedBox(width: 8),
                          buildImageTile('assets/images/anh3.png', 'Chợ nổi Cái Răng'),
                        ],
                      ),
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
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.article),
      //       label: 'Blogs',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite_border),
      //       label: 'Like',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
        floatingActionButton: FloatingActionButton.extended(
    onPressed: () {},
    label: Text('Thêm kế hoạch'),
    icon: Icon(Icons.add),
  ),
  bottomNavigationBar: HomeBottomBar(currentIndex: 3), // Sử dụng HomeBottomBar ở đây
)
    ;
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
