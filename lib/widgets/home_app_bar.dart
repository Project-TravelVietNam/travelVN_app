import 'package:flutter/material.dart';
import 'package:travelvn/widgets/search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _currentAddress = "Đang xác định...";
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _currentAddress = "Vui lòng bật vị trí");
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _currentAddress = "Quyền truy cập bị từ chối");
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted && placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = "${place.locality ?? place.subAdministrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = "Không thể xác định vị trí");
      }
    }
  }

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
      onTap: _getCurrentLocation,  // Refresh location khi tap
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.blueAccent,
          ),
          Text(
            _currentAddress,
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
