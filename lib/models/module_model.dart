class Module {
  final String id;
  final String title;
  final String description;
  final String careerId;
  final String contentType;
  final String contentURL;
  final bool isCompleted;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.careerId,
    required this.contentType,
    required this.contentURL,
    this.isCompleted = false,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      careerId: json['careerId'] ?? '',
      contentType: json['contentType'] ?? '',
      contentURL: json['contentURL'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'careerId': careerId,
      'contentType': contentType,
      'contentURL': contentURL,
      'isCompleted': isCompleted,
    };
  }

  Module copyWith({bool? isCompleted}) {
    return Module(
      id: id,
      title: title,
      description: description,
      careerId: careerId,
      contentType: contentType,
      contentURL: contentURL,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
