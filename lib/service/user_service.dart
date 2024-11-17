// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class UserService {
//   static const String apiUrl = 'http://localhost:8800/v1/user/'; // URL API của bạn

//   // Hàm để lấy dữ liệu người dùng từ API
//   Future<Map<String, dynamic>> fetchUserData(String token) async {
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Lỗi khi tải dữ liệu người dùng');
//     }
//   }
// }
