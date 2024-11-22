import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:travelvn/screens/details_Location.dart';
import 'package:travelvn/screens/detail.dart';
import 'package:travelvn/screens/detailHistory.dart';
import 'package:travelvn/screens/detailCulural.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favoritePlaces = [];
  List<Map<String, dynamic>> favoriteHistories = [];
  List<Map<String, dynamic>> favoriteCulturals = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _loadFavorites() async {
    final token = await getToken();
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để xem danh sách yêu thích')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/favorite'),
        headers: {
          'Cookie': 'access_token=$token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final data = responseData['data'];
        setState(() {
          favoritePlaces = List<Map<String, dynamic>>.from(data['locals'] ?? []);
          favoriteHistories = List<Map<String, dynamic>>.from(data['histories'] ?? []);
          favoriteCulturals = List<Map<String, dynamic>>.from(data['culturals'] ?? []);
        });
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi khi tải danh sách yêu thích')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNoFavorites = favoritePlaces.isEmpty && 
                               favoriteHistories.isEmpty && 
                               favoriteCulturals.isEmpty;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 1),
      body: hasNoFavorites
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (favoritePlaces.isNotEmpty) ...[
                      Text(
                        'Địa điểm yêu thích',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildGrid(favoritePlaces, 'local'),
                      SizedBox(height: 20),
                    ],
                    if (favoriteHistories.isNotEmpty) ...[
                      Text(
                        'Di tích lịch sử yêu thích',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildGrid(favoriteHistories, 'history'),
                      SizedBox(height: 20),
                    ],
                    if (favoriteCulturals.isNotEmpty) ...[
                      Text(
                        'Văn hóa ẩm thực yêu thích',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildGrid(favoriteCulturals, 'cultural'),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items, String type) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final place = items[index];
        final imageUrl = (place['imgLocal'] != null && place['imgLocal'].isNotEmpty)
          ? 'http://192.168.0.149:8800/v1/img/${place['imgLocal'][0]}'
          : (place['imgHistory'] != null && place['imgHistory'].isNotEmpty)
              ? 'http://192.168.0.149:8800/v1/img/${place['imgHistory'][0]}'
          : (place['imgculural'] != null && place['imgculural'].isNotEmpty)
              ? 'http://192.168.0.149:8800/v1/img/${place['imgculural'][0]}'
              : 'https://via.placeholder.com/600';
        
        return GestureDetector(
          onTap: () async {
            Widget destinationScreen;
            
            switch (type) {
              case 'local':
                destinationScreen = Detail(location: place);
                break;
              case 'history':
                destinationScreen = DetailHistory(location: place);
                break;
              case 'cultural':
                destinationScreen = DetailCulural(location: place);
                break;
              default:
                destinationScreen = Detail(location: place);
            }

            final needsRefresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => destinationScreen,
              ),
            );
            
            if (needsRefresh == true) {
              await _loadFavorites();
            }
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
    );
  }
}