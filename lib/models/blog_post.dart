class BlogPost {
  final String id;
  final String title;
  final String content;
  final String image;
  final List<String> categories;
  final String postedBy;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.categories,
    required this.postedBy,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      postedBy: json['postedBy']?['username'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: json['likes']?.length ?? 0,
      comments: json['comments']?.length ?? 0,
      isLiked: false, // You can update this based on user's like status
      isSaved: false, // You can update this based on user's save status
    );
  }
} 