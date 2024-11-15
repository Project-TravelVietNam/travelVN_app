import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class Search extends StatefulWidget {
  final dynamic item;

  const Search({super.key, required this.item});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<dynamic> relatedLocations = [];
  bool isLoading = false;

  // Hàm để tải các địa điểm liên quan
  Future<void> fetchRelatedLocations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.149:8800/v1/related/${widget.item['id']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          relatedLocations = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Lỗi khi tải địa điểm liên quan: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRelatedLocations(); // Gọi hàm tải dữ liệu khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: HomeAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chi tiết về item
            Text(
              widget.item['title'] ?? 'Không có tiêu đề',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item['region']?['name'] ?? 'Không có khu vực',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Địa điểm liên quan:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Hiển thị danh sách các địa điểm liên quan
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : relatedLocations.isNotEmpty
                      ? ListView.builder(
                          itemCount: relatedLocations.length,
                          itemBuilder: (context, index) {
                            final location = relatedLocations[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(location['title'] ?? 'Không có tiêu đề'),
                                subtitle: Text(
                                  location['region']?['name'] ?? 'Không có khu vực',
                                ),
                                onTap: () {
                                  // Mở chi tiết địa điểm khác nếu cần
                                },
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('Không tìm thấy địa điểm liên quan.'),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
}
