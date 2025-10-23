class Career {
  final String id;
  final String title;
  final String description;
  final String salaryRange;

  Career({
    required this.id,
    required this.title,
    required this.description,
    required this.salaryRange,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'salaryRange': salaryRange,
    };
  }
}
