import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.149:8800/v1';
  
  // Lưu thông tin user
  Future<void> saveUserInfo(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(userData));
  }

  // Lấy thông tin user
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: {
          'Cookie': 'access_token=$token'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Lấy user ID
  Future<String?> getUserId() async {
    final userData = await getUserInfo();
    return userData?['_id'];
  }
} 