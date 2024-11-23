import 'package:flutter/material.dart';
import 'package:travelvn/screens/blog_detail_screen.dart';
import 'package:travelvn/screens/post_card.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import '../models/blog_post.dart';
import '../service/blog_service.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final BlogService _blogService = BlogService();
  List<BlogPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _blogService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }

  // void _handleLike(String postId) async {
  //   try {
  //     await _blogService.likePost(postId);
  //     await _loadPosts(); // Reload posts to update like status
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error liking post: $e')),
  //     );
  //   }
  // }

  // void _handleSave(String postId) async {
  //   try {
  //     await _blogService.savePost(postId);
  //     await _loadPosts(); // Reload posts to update save status
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving post: $e')),
  //     );
  //   }
  // }

  void _handleShare(BlogPost post) {
    // Implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return Column(
                      children: [
                        if (index == 0) const SizedBox(height: 20),
                        PostCard(
                          username: post.postedBy,
                          time: _getTimeAgo(post.createdAt),
                          title: post.title,
                          content: post.content,
                          hashtags: post.categories.map((category) => '#$category').toList(),
                          imageUrl: 'http://192.168.0.149:8800/v1/img/${post.image}',
                          profileImageUrl: 'http://192.168.0.149:8800/v1/img/default-avatar.jpg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlogDetailScreen(
                                  blogId: post.id,
                                ),
                              ),
                            );
                          },
                          onShare: () => _handleShare(post),
                          isLiked: post.isLiked,
                          isSaved: post.isSaved,
                          likesCount: post.likes,
                          commentsCount: post.comments,
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 0),
    );
  }
}
