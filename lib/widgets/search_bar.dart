import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travelvn/screens/search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final String localApi = "http://192.168.0.149:8800/v1/local";
  final String culturalApi = "http://192.168.0.149:8800/v1/cultural";
  final String historyApi = "http://192.168.0.149:8800/v1/history";

  List<dynamic> searchResults = [];
  bool isLoading = false;
  String searchQuery = '';

  Future<void> fetchData(String query) async {
  setState(() {
    isLoading = true;
  });

  try {
    final responses = await Future.wait([
      http.get(Uri.parse(localApi)),
      http.get(Uri.parse(culturalApi)),
      http.get(Uri.parse(historyApi)),
    ]);

    List<dynamic> allData = [];
    for (var response in responses) {
      if (response.statusCode == 200) {
        allData.addAll(json.decode(response.body));
      }
    }

    final filteredData = allData
        .where((item) =>
            item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (item['region'] != null && item['region']['name'] != null && 
             item['region']['name'].toString().toLowerCase().contains(query.toLowerCase())))
        .toList();

    setState(() {
      searchResults = filteredData;
      isLoading = false;
    });
  } catch (error) {
    setState(() {
      isLoading = false;
    });
    print('Lỗi khi tải dữ liệu: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            children: [
              TextSpan(text: 'Travel'),
              TextSpan(
                text: ' VietNam',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          children: [
            // Thanh tìm kiếm
            TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
                fetchData(query);
              },
              textInputAction: TextInputAction.search, // Hiển thị nút "Search" trên bàn phím
              
              decoration: InputDecoration(
                hintText: 'Tìm kiếm điểm đến, trải nghiệm...',
                hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: 28),
                filled: true,
                fillColor: const Color.fromARGB(255, 220, 220, 220),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 5),
            // Hiển thị kết quả tìm kiếm dạng danh sách dọc
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : searchResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final item = searchResults[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Giảm kích thước bo góc
                              ),
                              elevation: 4, // Giảm độ dày của bóng
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Search(item: item), // Đảm bảo tên lớp đúng
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Giảm Padding
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tiêu đề
                                      Text(
                                        item['title'] ?? 'Không có kết quả',
                                        style: TextStyle(
                                          fontSize: 14, // Giảm kích thước font
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10), // Giảm khoảng cách
                                      // Mô tả
                                      Text(
                                        item['region']['name'] ?? 'kết quả',
                                        style: TextStyle(
                                          fontSize: 12, // Giảm kích thước font
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            searchQuery.isEmpty
                                ? 'Nhập từ khóa để tìm kiếm'
                                : 'Không tìm thấy kết quả',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 