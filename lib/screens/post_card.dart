import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;             // Tên người đăng bài
  final String time;                 // Thời gian đăng bài
  final String title;                // Đổi tên từ content sang title
  final String content;              // Thêm trường content mới
  final List<String> hashtags;       // Danh sách hashtag liên quan đến bài đăng
  final String imageUrl;             // URL hình ảnh chính của bài đăng
  final String profileImageUrl;      // URL ảnh đại diện của người đăng bài
  final VoidCallback? onTap;         // Callback khi nhấn vào bài viết
  final bool isLiked;
  final bool isSaved;
  final int likesCount;
  final int commentsCount;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const PostCard({
    super.key, 
    required this.username,
    required this.time,
    required this.title,        // Đổi tên parameter
    required this.content,      // Thêm parameter mới
    required this.hashtags,
    required this.imageUrl,
    required this.profileImageUrl,
    this.onTap,
    this.isLiked = false,
    this.isSaved = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.onLike,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Username, Time
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                    onBackgroundImageError: (e, s) {
                      // Fallback khi load ảnh lỗi
                      const Icon(Icons.person);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show options menu
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Chia sẻ'),
                              onTap: () {
                                Navigator.pop(context);
                                // Handle share
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.report),
                              title: const Text('Báo cáo'),
                              onTap: () {
                                Navigator.pop(context);
                                // Handle report
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title - Được làm nổi bật
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Content
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Image
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error_outline),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              
              // Hashtags
              if (hashtags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hashtags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  )).toList(),
                ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like button
                  Expanded(
                    child: _buildActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      label: likesCount > 0 ? likesCount.toString() : 'Thích',
                      onPressed: onLike ?? () {},
                      color: isLiked ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  // Comment button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: commentsCount > 0 ? commentsCount.toString() : '',
                      onPressed: () {},
                    ),
                  ),
                  // Share button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_outlined,
                      label: '',
                      onPressed: onShare ?? () {},
                    ),
                  ),
                  // Save button
                  Expanded(
                    child: _buildActionButton(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                      label: '',
                      onPressed: onSave ?? () {},
                      color: isSaved ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: color ?? Colors.grey[700],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
