import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelvn/screens/blog_detail_screen.dart';
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

  // Thêm các controller mới cho phần viết bài
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _postImage; // Lưu ảnh cho bài viết
  List<String> selectedCategories = []; // Lưu danh sách category được chọn
  
  // Danh sách các category có sẵn
  final List<String> categories = [
    'Du lịch', 'Ẩm thực', 'Văn hóa', 'Phiêu lưu', 
    'Miền Bắc', 'Miền Trung', 'Miền Nam', 'Review'
  ];

  // Thêm biến để lưu danh sách bài viết
  List<dynamic> userPosts = [];

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    
    if (token == null) {
      // Sử dụng mounted để tránh lỗi khi widget đã bị dispose
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
      return;
    }
    
    // Nếu có token thì fetch user data
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
        // Fetch posts sau khi có userData
        await fetchUserPosts();
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

  // Thêm method để xử lý việc chọn ảnh cho bài viết
  Future<void> pickPostImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _postImage = File(pickedFile.path);
      });
    }
  }

  // Thêm method để tạo bài viết mới
  Future<void> createNewPost() async {
    try {
      if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token is missing');

      String? imageId;
      if (_postImage != null) {
        // Upload ảnh
        String fileName = _postImage!.path.split('/').last;
        FormData formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_postImage!.path, filename: fileName),
        });

        var imageResponse = await _dio.post(
          'http://192.168.0.149:8800/v1/img/upload',
          data: formData,
          options: Options(headers: {
            'Cookie': 'access_token=$token',
            'Content-Type': 'multipart/form-data',
          }),
        );
        imageId = imageResponse.data['_id'];
      }

      // Tạo bài viết mới
      final response = await _dio.post(
        'http://192.168.0.149:8800/v1/blog/create',
        data: {
          'title': _titleController.text,
          'content': _contentController.text,
          'categories': selectedCategories,
          if (imageId != null) 'image': imageId,
          'postedBy': userData['_id'],
        },
        options: Options(headers: {
          'Cookie': 'access_token=$token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reset form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _postImage = null;
          selectedCategories.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công!')),
        );
      }
    } catch (error) {
      print('Error creating post: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi đăng bài')),
      );
    }
  }

  // Thêm hàm để fetch bài viết của user
  Future<void> fetchUserPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token is missing');

      var response = await _dio.get(
        'http://192.168.0.149:8800/v1/blog/showByUser',
        queryParameters: {'userId': userData['_id']},
        options: Options(headers: {
          'Cookie': 'access_token=$token',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          userPosts = response.data['posts'] ?? [];
        });
      }
    } catch (error) {
      print('Error fetching user posts: $error');
    }
  }

  // Thêm hàm xóa bài viết
  Future<void> handleDeletePost(String postId, String? imageId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token is missing');

      // Xóa ảnh nếu có
      if (imageId != null) {
        await _dio.delete(
          'http://192.168.0.149:8800/v1/img/$imageId',
          options: Options(headers: {
            'Cookie': 'access_token=$token',
          }),
        );
      }

      // Xóa bài viết
      await _dio.delete(
        'http://192.168.0.149:8800/v1/blog/delete/$postId',
        options: Options(headers: {
          'Cookie': 'access_token=$token',
        }),
      );

      // Refresh danh sách bài viết
      await fetchUserPosts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bài viết thành công')),
      );
    } catch (error) {
      print('Error deleting post: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi xóa bài viết')),
      );
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bài viết của tôi',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = 4; // Chuyển sang tab viết bài
                              });
                            },
                            icon: Icon(Icons.add),
                            label: Text('Viết bài'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      userPosts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có bài viết nào.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: userPosts.length,
                              itemBuilder: (context, index) {
                                final post = userPosts[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 16),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header với avatar và thông tin người đăng
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: userData['avatar'] != null
                                              ? NetworkImage('http://192.168.0.149:8800/v1/img/${userData['avatar']}')
                                              : AssetImage('assets/img/default_avatar.jpg') as ImageProvider,
                                        ),
                                        title: Text(
                                          userData['username'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Blogger',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => handleDeletePost(post['_id'], post['image']),
                                        ),
                                      ),
                                      // Ảnh bài viết
                                      if (post['image'] != null)
                                        Container(
                                          height: 200,
                                          width: double.infinity,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              'http://192.168.0.149:8800/v1/img/${post['image']}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      // Nội dung bài viết
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post['title'] ?? '',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              post['content'] ?? '',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Footer với các nút tương tác
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BlogDetailScreen(
                                                      blogId: post['_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.remove_red_eye_outlined, color: Colors.black), 
                                              label: Text('Xem chi tiết', style: TextStyle(color: Colors.black)),
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                // Thêm chức năng like sau
                                              },
                                              icon: Icon(Icons.favorite_border, color: Colors.black), 
                                              label: Text('Thích', style: TextStyle(color: Colors.black)), 
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                // Thêm chức năng share sau
                                              },
                                              icon: Icon(Icons.share_outlined, color: Colors.black), 
                                              label: Text('Chia sẻ', style: TextStyle(color: Colors.black)), 
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề bài viết',
                          border: OutlineInputBorder(),
                          hintText: 'Nhập tiêu đề bài viết của bạn',
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: 'Nội dung',
                          border: OutlineInputBorder(),
                          hintText: 'Chia sẻ trải nghiệm của bạn...',
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: categories.map((category) {
                          final isSelected = selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategories.add(category);
                                } else {
                                  selectedCategories.remove(category);
                                }
                              });
                            },
                            selectedColor: Colors.blue.withOpacity(0.25),
                            checkmarkColor: Colors.blue,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: pickPostImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _postImage != null
                              ? Stack(
                                  children: [
                                    Image.file(
                                      _postImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: IconButton(
                                        icon: Icon(Icons.close, color: Colors.white),
                                        onPressed: () => setState(() => _postImage = null),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                    Text('Thêm ảnh cho bài viết'),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: createNewPost,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Đăng bài'),
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
