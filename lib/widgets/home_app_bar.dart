import 'package:flutter/material.dart';
import 'package:travelvn/widgets/search_bar.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderText(),
          SizedBox(height: 8),
          _buildLocationAndSearch(context),
        ],
      ),
    );
  }

  // Tạo một widget riêng cho đoạn văn bản header
  Widget _buildHeaderText() {
    return Text.rich(
      TextSpan(
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
    );
  }

  // Tạo một widget cho phần location và search
  Widget _buildLocationAndSearch(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLocation(),
        _buildSearchButton(context),
      ],
    );
  }

  // Widget cho phần location
  Widget _buildLocation() {
    return GestureDetector(
      onTap: () {
        // Mở màn hình chọn địa điểm (Có thể sử dụng một trang mới hoặc một popup)
        print("User tapped on location");
      },
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.blueAccent,
          ),
          Text(
            "HCM, Việt Nam",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho nút search
  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search, size: 28, color: Colors.blueAccent),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()), // Điều hướng tới trang tìm kiếm
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
