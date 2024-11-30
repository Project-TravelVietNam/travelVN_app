import 'package:flutter/material.dart';
import 'package:travelvn/widgets/home_app_bar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';
import '../models/blog_post.dart';
import '../service/blog_service.dart';
import '../service/auth_service.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({
    Key? key,
    required this.blogId,
  }) : super(key: key);

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final BlogService _blogService = BlogService();
  final AuthService _authService = AuthService();
  BlogPost? _post;
  bool _isLoading = true;
  bool _isContentExpanded = false;
  static const int _maxLines = 5;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
    _loadComments();
  }

  Future<void> _loadPostDetail() async {
    try {
      final post = await _blogService.getPostDetail(widget.blogId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading post: $e')),
      );
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _blogService.getComments(widget.blogId);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: $e')),
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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    try {
      final user = await _authService.getUserInfo();
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để bình luận')),
        );
        return;
      }

      await _blogService.addComment(widget.blogId, _commentController.text);
      _commentController.clear();
      await _loadComments();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bình luận đã được thêm thành công')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi bình luận: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  if (_post!.image.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        'http://192.168.0.149:8800/v1/img/${_post!.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error_outline, size: 40),
                            ),
                          );
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                'http://192.168.0.149:8800/v1/img/default-avatar.jpg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _post!.postedBy,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _getTimeAgo(_post!.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _post!.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Content with expand/collapse
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _post!.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                              maxLines: _isContentExpanded ? null : _maxLines,
                              overflow: _isContentExpanded 
                                  ? TextOverflow.visible 
                                  : TextOverflow.ellipsis,
                            ),
                            if (_post!.content.length > 200)  // Chỉ hiện nút khi nội dung đủ dài
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isContentExpanded = !_isContentExpanded;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isContentExpanded ? 'Thu gọn' : 'Xem thêm',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _isContentExpanded 
                                            ? Icons.keyboard_arrow_up 
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Colors.blue[700],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  icon: _post!.isLiked ? Icons.favorite : Icons.favorite_border,
                                  label: '${_post!.likes}',
                                  color: _post!.isLiked ? Colors.red : null,
                                  onPressed: () {/* Handle like */},
                                ),
                                _buildActionButton(
                                  icon: Icons.comment_outlined,
                                  label: '${_comments.length}',
                                  onPressed: () {/* Handle comment */},
                                ),
                                _buildActionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Chia sẻ',
                                  onPressed: () {/* Handle share */},
                                ),
                                _buildActionButton(
                                  icon: _post!.isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  label: 'Lưu',
                                  color: _post!.isSaved ? Colors.blue : null,
                                  onPressed: () {/* Handle save */},
                                ),
                              ],
                            ),

                            // Divider trước phần comments
                            const Divider(height: 32),

                            // Comments section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Comment header
                                  Text(
                                    'Bình luận (${_comments.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Comment input
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentController,
                                            decoration: const InputDecoration(
                                              hintText: 'Viết bình luận...',
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(12),
                                            ),
                                            maxLines: null,
                                            enabled: !_isSubmittingComment,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.send),
                                          color: Colors.blue,
                                          onPressed: _isSubmittingComment ? null : _submitComment,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Comments list
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = _comments[index];
                                      return _buildCommentItem(comment);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Categories/Hashtags
                        if (_post!.categories.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _post!.categories.map((category) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$category',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 0),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'http://192.168.0.149:8800/v1/img/default-avatar.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['username'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(DateTime.parse(comment['createdAt'])),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['comment'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Text(
                        'Thích',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {},
                      child: const Text(
                        'Trả lời',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 