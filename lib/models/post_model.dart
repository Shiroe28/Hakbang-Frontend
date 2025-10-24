class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorRole;
  final String? profilePicture;
  final DateTime createdAt;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.profilePicture,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  // Factory constructor to create Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? json['author']?['_id'] ?? '',
      authorName: json['authorName'] ?? json['author']?['username'] ?? 'Anonymous',
      authorRole: json['authorRole'] ?? json['author']?['role'],
      profilePicture: json['profilePicture'] ?? json['author']?['profilePicture'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? json['commentCount'] ?? 0,
    );
  }

  // Convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}
