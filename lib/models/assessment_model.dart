class Assessment {
  final String id;
  final String title;
  final String moduleId;
  final List<Question> questions;

  Assessment({
    required this.id,
    required this.title,
    required this.moduleId,
    required this.questions,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      moduleId: json['moduleId'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'moduleId': moduleId,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOption;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      // Backend might return 'question' OR 'questionText'
      questionText: json['questionText'] ?? json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [],
      // Backend might return 'correctOption' OR 'correctAnswer'
      correctOption: json['correctOption'] ?? json['correctAnswer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOption': correctOption,
    };
  }
}
