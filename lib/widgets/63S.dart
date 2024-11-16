import 'package:flutter/material.dart';
import 'package:travelvn/screens/local.dart';
import 'package:travelvn/themes/63VN.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class Local63Page extends StatefulWidget {
  const Local63Page({Key? key}) : super(key: key);

  @override
  _Local63PageState createState() => _Local63PageState();
}

class _Local63PageState extends State<Local63Page> {
  bool isExpanded = false; // Trạng thái xem thêm/thu gọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Travel",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "VietNam",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề chính
                Text(
                  "Khám phá 63 tỉnh thành Việt Nam",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                // Mô tả du lịch Việt Nam với tính năng Xem thêm/Thu gọn
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AnimatedCrossFade(
                        duration: Duration(milliseconds: 300),
                        firstChild: Text(
                          'Việt Nam, đất nước nằm ở Đông Nam Á, nổi bật với lịch sử lâu dài và nền văn hóa đa dạng. Từ những di tích cổ xưa như phố cổ Hội An, cố đô Huế, đến những danh lam thắng cảnh thiên nhiên tuyệt đẹp như vịnh Hạ Long và Phong Nha – Kẻ Bàng.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        secondChild: Text(
                          'Việt Nam, đất nước nằm ở Đông Nam Á, nổi bật với lịch sử lâu dài và nền văn hóa đa dạng. Từ những di tích cổ xưa như phố cổ Hội An, cố đô Huế, đến những danh lam thắng cảnh thiên nhiên tuyệt đẹp như vịnh Hạ Long và Phong Nha – Kẻ Bàng. Văn hóa Việt Nam đậm đà bản sắc với các lễ hội truyền thống, nghệ thuật múa rối nước, và những giá trị đạo đức sâu sắc. Ẩm thực Việt Nam cũng là một phần không thể thiếu khi nhắc đến du lịch, với những món ăn đặc sắc như phở, bún chả, nem cuốn và cà phê sữa đá.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
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
                            Text(
                              isExpanded ? 'Thu gọn' : 'Xem thêm',
                              style: TextStyle(color: Colors.blue),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Lưới hiển thị các tỉnh thành
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: locationData.length, // Sử dụng dữ liệu từ locationData
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocalPage(), // Mở trang LocalPage
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.asset(
                                  locationData[index].img, // Đường dẫn ảnh
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    locationData[index].title, // Tên tỉnh thành
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LocalPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      "Khám phá",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 2),
    );
  }
}
