import 'package:flutter/material.dart';
import 'package:travelvn/screens/post_card.dart';
import 'package:travelvn/widgets/home_app_top.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppTop(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), 
        child: ListView(
          children: [
            const SizedBox(height: 10), 
            SearchBar(),
            const SizedBox(height: 20), 
            PostCard(
              username: 'Thanh Vũ',
              time: '4h',
              content: 'Mùa hạ Đà Lạt cũng đến rồi qua...',
              hashtags: ['#ĐàNẵng', '#Cặpđôi', '#Love'],
              imageUrl: 'assets/images/dalat.jpg', 
              profileImageUrl: 'assets/images/profile_thanh_vu.jpg', 
            ),
            const SizedBox(height: 10), 
            PostCard(
              username: 'Khoai Lang Thang',
              time: '6h',
              content: 'Mùa hoa tam giác mạch tại Xin Mần, Hà Giang...',
              hashtags: ['#HàGiang', '#Xinmần', '#Tamgiácmach'],
              imageUrl: 'assets/images/ha_giang.jpg', 
              profileImageUrl: 'assets/images/profile_khoai_lang.jpg', 
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 0),
    );
  }
}
