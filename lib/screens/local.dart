import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelvn/screens/detail.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

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

  void navigateToDetail(Map<String, dynamic> location, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detail(),
      ),
    );
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
                color: Colors.blueAccent,
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Thiết lập để cuộn ngang
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
            )

          ),
          SizedBox(height: 15),
          Expanded(
            child: locations.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
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
                        onTap: () => navigateToDetail(location, context),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80.0,
                                        height: 80.0,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 40.0,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location['title'] ?? 'Tên địa điểm',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      location['region']?['name'] ?? 'Tên Tỉnh',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blueAccent,
                                      size: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 20.0,
                              ),
                            ],
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