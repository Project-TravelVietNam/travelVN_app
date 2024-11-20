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
          .where((place) => favoriteIds.contains(place['_id'].toString()))
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa yêu thích địa điểm nào.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: favoritePlaces.length,
                itemBuilder: (context, index) {
                  final place = favoritePlaces[index];
                  final imageUrl = (place['imgLocal'] != null && place['imgLocal'].isNotEmpty)
                    ? 'http://192.168.0.149:8800/v1/img/${place['imgLocal'][0]}'
                    : 'https://via.placeholder.com/600';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detail(location: place),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                place['title'] ?? 'Tên địa điểm không xác định',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}