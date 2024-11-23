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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng đăng nhập để xem danh sách yêu thích')),
        );
      }
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
        if (mounted) {
          setState(() {
            favoritePlaces = List<Map<String, dynamic>>.from(data['locals'] ?? []);
            favoriteHistories = List<Map<String, dynamic>>.from(data['histories'] ?? []);
            favoriteCulturals = List<Map<String, dynamic>>.from(data['culturals'] ?? []);
          });
        }
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi khi tải danh sách yêu thích')),
        );
      }
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
      body: hasNoFavorites
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.red.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa yêu thích địa điểm nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy khám phá và lưu lại những địa điểm yêu thích!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (favoritePlaces.isNotEmpty) ...[
                        _buildSectionTitle('Địa điểm yêu thích'),
                        const SizedBox(height: 12),
                        _buildGrid(favoritePlaces, 'local'),
                        const SizedBox(height: 24),
                      ],
                      if (favoriteHistories.isNotEmpty) ...[
                        _buildSectionTitle('Di tích lịch sử yêu thích'),
                        const SizedBox(height: 12),
                        _buildGrid(favoriteHistories, 'history'),
                        const SizedBox(height: 24),
                      ],
                      if (favoriteCulturals.isNotEmpty) ...[
                        _buildSectionTitle('Văn hóa ẩm thực yêu thích'),
                        const SizedBox(height: 12),
                        _buildGrid(favoriteCulturals, 'cultural'),
                        const SizedBox(height: 16),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items, String type) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final place = items[index];
        final imageUrl = _getImageUrl(place);
        
        return GestureDetector(
          onTap: () => _navigateToDetail(context, place, type),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        place['title'] ?? 'Tên địa điểm không xác định',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getImageUrl(Map<String, dynamic> place) {
    if (place['imgLocal']?.isNotEmpty == true) {
      return 'http://192.168.0.149:8800/v1/img/${place['imgLocal'][0]}';
    } else if (place['imgHistory']?.isNotEmpty == true) {
      return 'http://192.168.0.149:8800/v1/img/${place['imgHistory'][0]}';
    } else if (place['imgculural']?.isNotEmpty == true) {
      return 'http://192.168.0.149:8800/v1/img/${place['imgculural'][0]}';
    }
    return 'https://via.placeholder.com/600';
  }

  Future<void> _navigateToDetail(BuildContext context, Map<String, dynamic> place, String type) async {
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
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
    
    if (needsRefresh == true) {
      await _loadFavorites();
    }
  }
}