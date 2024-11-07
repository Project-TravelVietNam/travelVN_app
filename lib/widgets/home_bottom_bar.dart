import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:travelvn/screens/blog.dart';
import 'package:travelvn/screens/home.dart';
import 'package:travelvn/screens/profile_page.dart';

class HomeBottomBar extends StatefulWidget {
  final int currentIndex; // Thêm thuộc tính currentIndex
  HomeBottomBar({this.currentIndex = 2}); // Khởi tạo giá trị mặc định cho currentIndex
  
  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  int _currentIndex = 2; // Chỉ số biểu tượng mặc định là Home (index 2)

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex; // Nhận giá trị chỉ số từ widget
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      index: _currentIndex,
      items: [
        Icon(Icons.edit, size: 30, color: _currentIndex == 0 ? Colors.blueAccent : Colors.black),
        Icon(Icons.favorite_outline, size: 30, color: _currentIndex == 1 ? Colors.blueAccent : Colors.black),
        Icon(Icons.home, size: 30, color: _currentIndex == 2 ? Colors.blueAccent : Colors.black),
        Icon(Icons.location_on_outlined, size: 30, color: _currentIndex == 3 ? Colors.blueAccent : Colors.black),
        Icon(Icons.person_outlined, size: 30, color: _currentIndex == 4 ? Colors.blueAccent : Colors.black),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Cập nhật chỉ số khi nhấn
        });

        // Điều hướng đến các trang tương ứng dựa vào index
        if (index == 2) { // Nhấn vào icon Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // Chuyển đến HomePage
          );
        } else if (index == 4) { // Nhấn vào icon Person (Profile)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()), // Chuyển đến ProfilePage
          );
        }
        else if (index == 0) { // Nhấn vào icon Person (Profile)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BlogPage()), // Chuyển đến ProfilePage
          );
        }
      },
    );
  }
}
