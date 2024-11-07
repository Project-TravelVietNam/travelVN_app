import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;             // Tên người đăng bài
  final String time;                 // Thời gian đăng bài
  final String content;              // Nội dung của bài đăng
  final List<String> hashtags;       // Danh sách hashtag liên quan đến bài đăng
  final String imageUrl;             // URL hình ảnh chính của bài đăng
  final String profileImageUrl;      // URL ảnh đại diện của người đăng bài

  PostCard({super.key, 
    required this.username,
    required this.time,
    required this.content,
    required this.hashtags,
    required this.imageUrl,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tiêu đề (chứa ảnh đại diện, tên người dùng, thời gian và menu)
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert), // Biểu tượng menu
              ],
            ),
            SizedBox(height: 10),
            
            // Nội dung bài đăng
            Text(content),
            
            // Các hashtag
            Wrap(
              spacing: 5,
              children: hashtags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            
            SizedBox(height: 10),
            
            // Hình ảnh của bài đăng từ assets
            Image.asset('assets/images/city1.png'), // Sử dụng hình ảnh từ assets

            // Hàng chứa các biểu tượng hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {}, // Thao tác yêu thích
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () {}, // Thao tác bình luận
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {}, // Thao tác chia sẻ
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () {}, // Thao tác lưu bài
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
