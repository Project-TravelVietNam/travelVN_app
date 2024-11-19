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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _avatarFile;
  int selectedTabIndex = 0;
  bool isLoading = true;
  Map<String, dynamic> userData = {};
  List<dynamic> destinations = [];
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return isoDate; 
    }
  }
  String formatDateToISO(String formattedDate) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      return parsedDate.toIso8601String().split('T').first; 
    } catch (e) {
      return formattedDate; 
    }
  }
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
        'phone': _phoneController.text,
        'birthday': formatDateToISO(_birthdayController.text),
        'gender': _genderController.text,
        'bio': _bioController.text,
      };
      if (_avatarFile != null) {
        String fileName = _avatarFile!.path.split('/').last;
        FormData formData = FormData.fromMap({
          ...data,
          'avatar': await MultipartFile.fromFile(_avatarFile!.path, filename: fileName),
        });
        var response = await _dio.post(
        'http://192.168.0.149:8800/v1/user/update',
        data: formData,
        options: Options(headers: {
          'Cookie': 'access_token=$token',
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        fetchUserData();
      }
    } else {
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
        fetchUserData();
      }
    }
  } catch (error) {
    print('Error updating profile: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile')),
    );
  }
}
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          userData['username'] ?? 'Tên người dùng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(width: 16,),
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
                      ],
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
}