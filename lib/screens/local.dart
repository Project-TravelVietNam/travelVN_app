import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class LocalPage extends StatefulWidget {
  @override
  _LocalPageState createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  List<Map<String, dynamic>> locations = [];
  final List<String> category = [
    'Lịch sử',
    'Văn hóa',
    'Ẩm thực',
  ];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('local').get();
    setState(() {
      locations = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  void navigateToDetail(Map<String, dynamic> location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(location: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      body: Column(
        children: [
          SizedBox(height: 10), 
          Text(
            "Danh mục địa điểm",
            style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // Phần thêm danh mục bên dưới AppBar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  for (int i = 0; i < (category.length < 3 ? category.length : 3); i++)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          print("Button category ${i + 1} pressed");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadowColor: Colors.black26,
                          elevation: 4,
                        ),
                        child: Text(
                          category[i],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10), // Khoảng cách giữa danh mục và danh sách địa điểm
          Expanded(
            child: locations.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return GestureDetector(
                        onTap: () => navigateToDetail(location),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.blueAccent,
                                  size: 30.0,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location['local_name'] ?? 'Tên địa điểm',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'ID: ${location['local_id'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 18.0,
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

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> location;

  DetailPage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: "Travel",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: "VietNam",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${location['local_id'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.0),
            Text(
              location['local_name'] ?? 'Tên địa điểm',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 3),
    );
  }
}
