import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({super.key});

  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

//Đây là thanh ở dưới cùng của app
class _HomeBottomBarState extends State<HomeBottomBar> {
  int _currentIndex = 2; // Chỉ số biểu tượng mặc định

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      index: _currentIndex,
      items: [
        Icon(Icons.edit, size: 30, color: _currentIndex == 0 ? Colors.blueAccent : Colors.black), //index 0
        Icon(Icons.favorite_outline, size: 30, color: _currentIndex == 1 ? Colors.blueAccent : Colors.black), //index 1
        Icon(Icons.home, size: 30, color: _currentIndex == 2 ? Colors.blueAccent : Colors.black), //index 2 
        Icon(Icons.location_on_outlined, size: 30, color: _currentIndex == 3 ? Colors.blueAccent : Colors.black), //index 3
        Icon(Icons.person_outlined, size: 30, color: _currentIndex == 4 ? Colors.blueAccent : Colors.black), //index 4
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Cập nhật chỉ số khi nhấn
        });
        
      },
    );
  }
}
