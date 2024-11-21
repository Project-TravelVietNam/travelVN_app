import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelvn/screens/auth/sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Dio _dio = Dio(); // Sử dụng Dio cho API
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _avatarFile;
  int selectedTabIndex = 0; // Tab hiện tại
  bool isLoading = true;

  Map<String, dynamic> userData = {}; // Dữ liệu người dùng
  List<dynamic> destinations = []; // Danh sách điểm đến

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Hàm định dạng ngày tháng từ ISO sang dd/MM/yyyy
  String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return isoDate; // Trả về nguyên bản nếu lỗi
    }
  }

  // Hàm ngược lại để gửi ngày tháng lên server từ dd/MM/yyyy về ISO
  String formatDateToISO(String formattedDate) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      return parsedDate.toIso8601String().split('T').first; // Chỉ lấy phần ngày
    } catch (e) {
      return formattedDate; // Trả về nguyên bản nếu lỗi
    }
  }

  // Gọi API để lấy dữ liệu người dùng
  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token is missing');

      var response = await _dio.get(
        'http://192.168.0.149:8800/v1/user/me',
        options: Options(headers: {
          'Cookie': 'access_token=$token',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
          _usernameController.text = userData['username'] ?? '';
          _fullNameController.text = userData['fullname'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _birthdayController.text =
              userData['birthday'] != null ? formatDate(userData['birthday']) : '';
          _genderController.text = userData['gender'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token is missing');

      Map<String, dynamic> data = {
        'username': _usernameController.text,
        'fullname': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'birthday': formatDateToISO(_birthdayController.text),
        'gender': _genderController.text,
        'bio': _bioController.text,
      };

      // Upload avatar if exists
      if (_avatarFile != null) {
        String fileName = _avatarFile!.path.split('/').last;

        FormData formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_avatarFile!.path, filename: fileName),
        });

        var uploadResponse = await _dio.post(
          'http://192.168.0.149:8800/v1/img/upload',
          data: formData,
          options: Options(headers: {
            'Cookie': 'access_token=$token',
            'Content-Type': 'multipart/form-data',
          }),
        );

        if (uploadResponse.statusCode == 200) {
          data['avatar'] = uploadResponse.data['_id'];
        }
      }

      // Update user profile
      var response = await _dio.put(
        'http://192.168.0.149:8800/v1/user/${userData['_id']}',
        data: json.encode(data),
        options: Options(headers: {
          'Cookie': 'access_token=$token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        fetchUserData(); // Refresh user data
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

// DatePicker để chọn ngày tháng
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cài đặt",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Icon(Icons.edit_calendar, color: Colors.black),
                          title: Text('Lập kế hoạch'),
                          onTap: () {
                            Navigator.pop(context); // Đóng BottomSheet
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.black),
                          title: Text('Đăng xuất'),
                          onTap: () async {
                            // Xóa thông tin đăng nhập (ví dụ: xóa token, userData, ...)
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear(); // Ví dụ nếu bạn lưu token người dùng
                            // await prefs.remove('userData');  // Nếu lưu dữ liệu người dùng
                            // Chuyển người dùng về màn hình đăng nhập
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => SignIn()),
                            ); 
                          }
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Check if username is available
                        Text(
                          userData['username'] ?? 'Tên người dùng', // Fallback to default text if null
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(width: 16,),
                    // Profile Image and Stats Row
                    Row(
                      children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (userData['avatar'] != null
                                ? NetworkImage('http://192.168.0.149:8800/v1/img/${userData['avatar']}')
                                : AssetImage('assets/img/default_avatar.jpg')) as ImageProvider,
                      ),
                    ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(child: buildStatColumn('34', 'Điểm đến')),
                                  Expanded(child: buildStatColumn('140', 'Người theo dõi')),
                                  Expanded(child: buildStatColumn('456', 'Đang theo dõi')),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Blogger',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Yêu du lịch, tích trải nghiệm',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 0; // Dòng thời gian
                              });
                            },
                            child: Text(
                              'Dòng thời gian',
                              style: TextStyle(
                                color: selectedTabIndex == 0 ? Colors.blue : Colors.black,
                                fontWeight: selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 1; // Giới thiệu
                              });
                            },
                            child: Text(
                              'Giới thiệu',
                              style: TextStyle(
                                color: selectedTabIndex == 1 ? Colors.blue : Colors.black,
                                fontWeight: selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 2; // Album
                              });
                            },
                            child: Text(
                              'Album',
                              style: TextStyle(
                                color: selectedTabIndex == 2 ? Colors.blue : Colors.black,
                                fontWeight: selectedTabIndex == 2 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 3; // Đang theo dõi
                              });
                            },
                            child: Text(
                              'Đang theo dõi',
                              style: TextStyle(
                                color: selectedTabIndex == 3 ? Colors.blue : Colors.black,
                                fontWeight: selectedTabIndex == 3 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 4; // Viết bài
                              });
                            },
                            child: Text(
                              'Viết bài',
                              style: TextStyle(
                                color: selectedTabIndex == 4 ? Colors.blue : Colors.black,
                                fontWeight: selectedTabIndex == 4 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              // Nội dung hiển thị dựa vào selectedTabIndex
              if (selectedTabIndex == 0)
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: Center(child: Text('Dòng thời gian')),
                )
              else if (selectedTabIndex == 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'THÔNG TIN CÁ NHÂN',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'User Name'),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'Họ và tên'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: 'Số điện thoại'),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _birthdayController,
                            decoration: InputDecoration(labelText: 'Ngày tháng năm sinh'),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _genderController,
                        decoration: InputDecoration(labelText: 'Giới tính'),
                      ),
                      TextField(
                        controller: _bioController,
                        decoration: InputDecoration(labelText: 'Tiểu sử'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue, disabledForegroundColor: Colors.blueGrey.withOpacity(0.38), disabledBackgroundColor: Colors.blueGrey.withOpacity(0.12), 
                          elevation: 5, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Update Profile'),
                          ],
                        ),
                      ),
                        SizedBox(height: 20),
                        buildPersonalInfoRow('User Name', userData['username'] ?? '...'),
                        buildPersonalInfoRow('Họ và tên', userData['fullname'] ?? '...'),
                        buildPersonalInfoRow('Email', userData['email'] ?? '...'),
                        buildPersonalInfoRow('Số điện thoại', userData['phone'] ?? '...'),
                        buildPersonalInfoRow(
                          'Ngày sinh tháng năm sinh',
                          userData['birthday'] != null ? formatDate(userData['birthday']) : '...',
                        ),
                        buildPersonalInfoRow('Giới tính', userData['gender'] ?? '...'),
                        buildPersonalInfoRow('Tiểu sử', userData['bio'] ?? '...'),
                      ],
                    ),
                  )
              else if (selectedTabIndex == 2)
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: Center(child: Text('Album')),
                )
              else if (selectedTabIndex == 3)
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: Center(child: Text('Đang theo dõi')),
                )
              else if (selectedTabIndex == 4)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viết bài',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Tên bài viết',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Ghi chú',
                          border: OutlineInputBorder(),
                          hintText: 'Bạn cần note gì ?',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Nội dung',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Chủ đề *', style: TextStyle(color: Colors.red)),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text('#Miền Nam')),
                          Chip(label: Text('#Du lịch')),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Upload Images',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                            Text(
                              'Upload a file or drag and drop\nPNG, JPG, GIF up to 10MB',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Save button action
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue, disabledForegroundColor: Colors.blueGrey.withOpacity(0.38), disabledBackgroundColor: Colors.blueGrey.withOpacity(0.12), 
                          elevation: 5, 
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: 
                          Text('Save'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 4),
    );
  }

  // Helper function to build statistic column
  Column buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  // Helper function to build personal info row
  Widget buildPersonalInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black54),
          ),
          Text(value),
        ],
      ),
    );
  }

}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}
