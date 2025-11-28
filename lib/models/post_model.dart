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
  final List<String> likedBy; // List of user IDs who liked this post
  final List<Comment> commentsList; // List of comments

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
    this.likedBy = const [],
    this.commentsList = const [],
  });

  // Check if a user has liked this post
  bool isLikedBy(String userId) => likedBy.contains(userId);

  // Factory constructor to create Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    // Parse likedBy array
    List<String> likedByList = [];
    if (json['likedBy'] != null && json['likedBy'] is List) {
      likedByList = (json['likedBy'] as List).map((e) => e.toString()).toList();
    }

    // Parse comments array
    List<Comment> commentsParsed = [];
    if (json['commentsList'] != null && json['commentsList'] is List) {
      commentsParsed = (json['commentsList'] as List)
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList();
    } else if (json['comments'] != null && json['comments'] is List) {
      commentsParsed = (json['comments'] as List)
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId']?.toString() ?? json['author']?['_id']?.toString() ?? '',
      authorName: _extractAuthorName(json),
      authorRole: json['authorRole'] ?? json['author']?['role'],
      profilePicture: json['profilePicture'] ?? json['author']?['profilePicture'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likeCount'] ?? json['likes'] ?? likedByList.length,
      comments: json['commentCount'] ?? (json['comments'] is int ? json['comments'] : commentsParsed.length),
      likedBy: likedByList,
      commentsList: commentsParsed,
    );
  }

  /// Helper to extract author name from various response formats
  static String _extractAuthorName(Map<String, dynamic> json) {
    // Try direct authorName field
    if (json['authorName'] != null && json['authorName'].toString().isNotEmpty) {
      return json['authorName'].toString();
    }
    
    // Try nested author object
    if (json['author'] != null && json['author'] is Map) {
      final author = json['author'] as Map;
      // Try different name fields
      if (author['name'] != null && author['name'].toString().isNotEmpty) {
        return author['name'].toString();
      }
      if (author['username'] != null && author['username'].toString().isNotEmpty) {
        return author['username'].toString();
      }
      if (author['email'] != null && author['email'].toString().isNotEmpty) {
        // Use email prefix as fallback
        final email = author['email'].toString();
        return email.contains('@') ? email.split('@')[0] : email;
      }
    }
    
    return 'Anonymous';
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
      'likedBy': likedBy,
      'commentsList': commentsList.map((c) => c.toJson()).toList(),
    };
  }

  // Create a copy with updated fields
  Post copyWith({
    int? likes,
    List<String>? likedBy,
    int? comments,
    List<Comment>? commentsList,
  }) {
    return Post(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      profilePicture: profilePicture,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
      commentsList: commentsList ?? this.commentsList,
    );
  }
}

/// Comment model for forum posts
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userRole;
  final String? profilePicture;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userRole,
    this.profilePicture,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user']?['_id'] ?? '',
      userName: json['userName'] ?? json['user']?['name'] ?? json['user']?['username'] ?? 'Anonymous',
      userRole: json['userRole'] ?? json['user']?['role'],
      profilePicture: json['profilePicture'] ?? json['user']?['profilePicture'],
      text: json['text'] ?? json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'profilePicture': profilePicture,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
