import 'package:http/http.dart' as http;
import 'dart:convert';

class LocalService {
  static const String baseUrl = 'http://192.168.0.149:8800/v1';

  Future<void> addReview(String localId, String userId, int rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/local/reviews/$localId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReviews(String localId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/local/review/all/$localId'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      throw Exception('Failed to load reviews');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 