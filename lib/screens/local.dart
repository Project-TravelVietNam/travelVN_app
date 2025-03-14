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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "Khám phá địa điểm",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: category.length,
              itemBuilder: (context, index) {
                final cat = category[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: selectedCategory == cat ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selectedCategory == cat,
                    selectedColor: Colors.blue[700],
                    backgroundColor: Colors.grey[100],
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: locations.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.85,
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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
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
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                                      location['title'] ?? 'Tên địa điểm',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
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
                  ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
}
