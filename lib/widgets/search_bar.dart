import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Đóng trang tìm kiếm khi bấm vào nút đóng
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          children: [
            // Thanh tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm điểm đến, trải nghiệm...',
                hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: 28),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic, color: Colors.blue, size: 26),
                  onPressed: () {
                    // Thêm chức năng tìm kiếm bằng giọng nói nếu cần
                  },
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 220, 220, 220),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[500]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Kết quả tìm kiếm (hiện tại là giả lập)
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Giả sử có 10 kết quả tìm kiếm
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blue),
                    title: Text(
                      'Điểm đến ${index + 1}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Mô tả ngắn về điểm đến'),
                    onTap: () {
                      // Hành động khi nhấn vào kết quả tìm kiếm (Chuyển trang chi tiết)
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
