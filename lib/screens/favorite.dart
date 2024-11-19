import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/screens/details_Location.dart';
import 'package:travelvn/screens/detail.dart';

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
    _loadFavorites();
  }

  // Hàm tải danh sách yêu thích từ SharedPreferences sử dụng List<Map<String, dynamic>>
 Future<void> _loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Lấy danh sách ID yêu thích
  final favoritesIdsString = prefs.getString('favorite_places_ids');
  List<String> favoriteIds = [];

  if (favoritesIdsString != null) {
    favoriteIds = List<String>.from(json.decode(favoritesIdsString));
  }

  // Lấy danh sách địa điểm yêu thích
  final favoritesString = prefs.getString('favorite_places');
  List<Map<String, dynamic>> loadedFavorites = [];

  if (favoritesString != null) {
    try {
      final List<dynamic> decodedList = json.decode(favoritesString);

      if (decodedList is List) {
        loadedFavorites = decodedList
            .map((item) => item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item))
            .toList();
      }

      // Lọc các địa điểm yêu thích dựa trên ID
      final filteredFavorites = loadedFavorites
          .where((place) => favoriteIds.contains(place['id'].toString()))
          .toList();

      setState(() {
        favoritePlaces = filteredFavorites;
      });
    } catch (e) {
      print("Lỗi khi giải mã JSON: $e");
    }
  }
}


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
                subtitle: Text(place['region']['name']  ?? 'Vị trí không xác định'),
                onTap: () {
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
