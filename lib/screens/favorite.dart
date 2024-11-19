import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelvn/screens/coppydetail.dart';
import 'package:travelvn/screens/details_Location.dart';
import 'dart:convert';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favoritePlaces = [];

  @override
  void initState() {
    super.initState();
   // _loadFavorites();
  }

  // Hàm tải danh sách yêu thích từ SharedPreferences
//   // Future<void> _loadFavorites() async {
//   final prefs = await SharedPreferences.getInstance();
//   final favoritesString = prefs.getString('favorite_places');
//   if (favoritesString != null) {
//     print("Dữ liệu lưu trữ trong SharedPreferences: $favoritesString");  // In ra để kiểm tra dữ liệu
//     setState(() {
//       favoritePlaces = List<Map<String, dynamic>>.from(json.decode(favoritesString));
//     });
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 1),
      body: favoritePlaces.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa yêu thích địa điểm nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoritePlaces.length,
              itemBuilder: (context, index) {
                final place = favoritePlaces[index];
                return ListTile(
                  leading: place['image'] != null
                      ? Image.network(place['image'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.location_on),
                  title: Text(
                    place['title'] ?? 'Tên địa điểm không xác định',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(place['location'] ?? 'Vị trí không xác định'),
                  onTap: () {
                    // Điều hướng đến trang chi tiết của địa điểm
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Detail(location: place),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
