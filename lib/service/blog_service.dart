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

  Future<void> addComment(String postId, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/blog/reviews/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 'current_user_id', // Replace with actual user ID
          'rating': 0,
          'comment': comment,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blog/review/all/$postId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to load comments');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> submitComment(String postId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blog/reviews/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': 'current_user_id', // Replace with actual user ID
        'rating': 0,
        'comment': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit comment');
    }
  }

  Future<int> getCommentsCount(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blog/review/all/$postId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Error getting comments count: $e');
      return 0;
    }
  }
} 