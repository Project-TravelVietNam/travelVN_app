import 'package:flutter/material.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class DetailsLocation extends StatelessWidget {
  const DetailsLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailPage(),
      bottomNavigationBar: HomeBottomBar(),  // Di chuyển bottomNavigationBar vào đây
    );
  }
}

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Image and description
          Stack(
            children: [
              Image.asset(
                'assets/images/detailL.png',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(200, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thác Mơ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Với tổng cộng 6 tầng, mỗi tầng mang đến một vẻ đẹp độc đáo riêng, tạo nên sự cuốn hút.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        child: Text('Xem thêm'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Section for famous places
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Địa điểm nổi tiếng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
            
          // Other recommendations section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Đề xuất khác',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRecommendationItem('Cần Thơ', 'assets/images/anh1.png'),
                _buildRecommendationItem('Đình Rạch Gióng', 'assets/images/anh1.png'),
                _buildRecommendationItem('Bến Xuân Thanh', 'assets/images/anh1.png'),
                _buildRecommendationItem('Đồi chè trái tim', 'assets/images/anh1.png'),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Phổ biến nhất Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Phổ biến nhất',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),

          // List of popular places
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildLocationCard(
                'Đình Rạch Gióng',
                'Huyện Cù Lao Dung',
                'Sóc Trăng',
                'assets/images/anh1.png', // Replace with your image path
                5,
              ),
              _buildLocationCard(
                'Bến Xuân Thanh',
                'Huyện Xuân Nghi',
                'Hà Tĩnh',
                'assets/images/anh2.png', // Replace with your image path
                4,
              ),
              _buildLocationCard(
                'Đồi chè trái tim',
                'Huyện Mộc Châu',
                'Sơn La',
                'assets/images/anh3.png', // Replace with your image path
                5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String imageUrl) {
    return Container(
      width: 291,  // điều chỉnh lại chiều rộng cho giống với ảnh
      height: 188,  // điều chỉnh lại chiều cao cho giống với ảnh
      margin: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // tạo góc bo tròn cho ảnh
        image: DecorationImage(
          image: AssetImage(imageUrl), // ảnh đại diện
          fit: BoxFit.cover, // cắt ảnh vừa khung
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build each location card
  Widget _buildLocationCard(String title, String location, String province, String imageUrl, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image on the left
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            // Title, location, and rating on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(location),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(province),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < rating ? Colors.blue : Colors.grey,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
