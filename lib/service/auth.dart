import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://192.168.0.149:8800'; // URL của server Node.js của bạn

  // Đăng ký người dùng
  Future<String> addUser({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    String res;
    try {
      if (username.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
        if (password == confirmPassword) {
          final response = await http.post(
            Uri.parse('$baseUrl/v1/user/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
              'confirmPassword': confirmPassword,
            }),
          );

          final responseData = json.decode(response.body);
          if (response.statusCode == 201) {
            res = "Đăng ký thành công!";
          } else {
            res = responseData['message'];
          }
        } else {
          res = "Mật khẩu không trùng khớp!";
        }
      } else {
        res = "Vui lòng điền đầy đủ thông tin!";
      }
    } catch (e) {
      res = 'Lỗi: $e';
    }
    return res;
  }

  // Đăng nhập người dùng
  Future<String> loginUser({required String username, required String password}) async {
    String res;
    try {
      if (username.isNotEmpty && password.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/v1/user/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': username,
            'password': password,
          }),
        );

        final responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          res = "Đăng nhập thành công!";
          // Bạn có thể lưu token JWT ở đây, ví dụ: SharedPreferences hoặc trong một state nào đó
        } else {
          res = responseData['message'];
        }
      } else {
        res = "Vui lòng điền đầy đủ thông tin!";
      }
    } catch (e) {
      res = 'Lỗi: $e';
    }
    return res;
  }
}