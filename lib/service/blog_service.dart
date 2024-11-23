import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/blog_post.dart';

class BlogService {
  static const String baseUrl = 'http://192.168.0.149:8800/v1';

  Future<List<BlogPost>> getAllPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blog/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['posts'] as List)
              .map((post) => BlogPost.fromJson(post))
              .toList();
        }
      }
      throw Exception('Failed to load posts');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<BlogPost> getPostDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blog/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BlogPost.fromJson(data['post']);
      }
      throw Exception('Failed to load post detail');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 