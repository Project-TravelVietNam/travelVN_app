import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelvn/screens/detailCulural.dart';
import 'package:travelvn/screens/detailHistory.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'detail.dart';

class LocalPage extends StatefulWidget {
  @override
  _LocalPageState createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  final List<String> category = ['Tất cả địa điểm', 'Lịch sử', 'Văn hóa Ẩm thực'];
  String selectedCategory = 'Tất cả địa điểm';
  List<dynamic> locations = [];
  Set<int> favoriteLocations = {}; // Lưu các địa điểm được yêu thích

  Future<List<dynamic>> fetchLocations(String category) async {
    String apiUrl;

    switch (category) {
      case 'Lịch sử':
        apiUrl = 'http://192.168.0.149:8800/v1/history';
        break;
      case 'Văn hóa Ẩm thực':
        apiUrl = 'http://192.168.0.149:8800/v1/cultural';
        break;
      default:
        apiUrl = 'http://192.168.0.149:8800/v1/local';
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocations(selectedCategory).then((data) {
      setState(() {
        locations = data;
      });
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (favoriteLocations.contains(index)) {
        favoriteLocations.remove(index);
      } else {
        favoriteLocations.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: HomeAppBar(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Danh mục địa điểm",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: category.map((cat) => Container(
                  margin: EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: selectedCategory == cat ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: selectedCategory == cat,
                    selectedColor: Colors.blueAccent,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = cat;
                        fetchLocations(selectedCategory).then((data) {
                          setState(() {
                            locations = data;
                          });
                        });
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: locations.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];

                      String imageUrl = '';
                      if (selectedCategory == 'Lịch sử' && location['imgHistory'] != null) {
                        var imgHistory = location['imgHistory'] is List ? location['imgHistory'][0] : location['imgHistory'];
                        imageUrl = 'http://192.168.0.149:8800/v1/img/$imgHistory';
                      } else if (selectedCategory == 'Văn hóa Ẩm thực' && location['imgculural'] != null) {
                        var imgculural = location['imgculural'] is List ? location['imgculural'][0] : location['imgculural'];
                        imageUrl = 'http://192.168.0.149:8800/v1/img/$imgculural';
                      } else if (selectedCategory == 'Tất cả địa điểm' && location['imgLocal'] != null) {
                        var imageId = location['imgLocal'] is List ? location['imgLocal'][0] : location['imgLocal'];
                        imageUrl = 'http://192.168.0.149:8800/v1/img/$imageId';
                      }

                      if (imageUrl.isEmpty) {
                        imageUrl = 'https://example.com/default-image.png';
                      }

                      return GestureDetector(
                        onTap: () {
                          if (selectedCategory == 'Lịch sử') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailHistory(location: location),
                              ),
                            );
                          } else if (selectedCategory == 'Văn hóa Ẩm thực') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailCulural(location: location),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Detail(location: location),
                              ),
                            );
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
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    location['title'] ?? 'Tên địa điểm',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleFavorite(index),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    favoriteLocations.contains(index)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    size: 24,
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
        ],
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
}
