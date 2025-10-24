class User {
  final String id;
  final String username;
  final String email;
  final String role; // "student" or "mentor"
  final String? profilePicture;
  final ProgressSummary? progressSummary;
  final List<Badge>? badges;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profilePicture,
    this.progressSummary,
    this.badges,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? json['name'] ?? '',  // Handle both 'username' and 'name'
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      profilePicture: json['profilePicture'],
      progressSummary: json['progressSummary'] != null 
          ? ProgressSummary.fromJson(json['progressSummary'])
          : null,
      badges: json['badges'] != null
          ? (json['badges'] as List).map((b) => Badge.fromJson(b)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profilePicture': profilePicture,
      'progressSummary': progressSummary?.toJson(),
      'badges': badges?.map((b) => b.toJson()).toList(),
    };
  }
}

class ProgressSummary {
  final int totalModules;
  final int completedModules;
  final int badgesEarned;
  final int assessmentsPassed;
  final int currentStreak;

  ProgressSummary({
    this.totalModules = 0,
    this.completedModules = 0,
    this.badgesEarned = 0,
    this.assessmentsPassed = 0,
    this.currentStreak = 0,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      totalModules: json['totalModules'] ?? 0,
      completedModules: json['completedModules'] ?? 0,
      badgesEarned: json['badgesEarned'] ?? 0,
      assessmentsPassed: json['assessmentsPassed'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalModules': totalModules,
      'completedModules': completedModules,
      'badgesEarned': badgesEarned,
      'assessmentsPassed': assessmentsPassed,
      'currentStreak': currentStreak,
    };
  }
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['_id'] ?? json['badgeId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}
