class Career {
  final String id;
  final String title;
  final String description;
  final String salaryRange;
  final List<String> skillsRequired;
  final List<Map<String, dynamic>>? roadmap;

  Career({
    required this.id,
    required this.title,
    required this.description,
    required this.salaryRange,
    this.skillsRequired = const [],
    this.roadmap,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    // Parse skillsRequired - handle various formats
    List<String> skills = [];
    if (json['skillsRequired'] != null) {
      if (json['skillsRequired'] is List) {
        skills = (json['skillsRequired'] as List)
            .map((s) => s.toString())
            .toList();
      }
    }

    // Parse roadmap
    List<Map<String, dynamic>>? roadmapData;
    if (json['roadmap'] != null && json['roadmap'] is List) {
      roadmapData = (json['roadmap'] as List)
          .map((r) => r as Map<String, dynamic>)
          .toList();
    }

    return Career(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salaryRange: json['salaryRange'] ?? 'Salary not specified',
      skillsRequired: skills,
      roadmap: roadmapData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'salaryRange': salaryRange,
      'skillsRequired': skillsRequired,
      'roadmap': roadmap,
    };
  }

  /// Get skill count for preview display
  int get skillCount => skillsRequired.length;

  /// Check if career has skills defined
  bool get hasSkills => skillsRequired.isNotEmpty;
}
