import 'choice_option.dart';

enum QuestionType {
  choice,
  shortAnswer;

  factory QuestionType.fromJson(String value) {
    return switch (value) {
      'choice' => QuestionType.choice,
      'short_answer' || 'shortAnswer' => QuestionType.shortAnswer,
      _ => QuestionType.shortAnswer,
    };
  }

  String toJson() => switch (this) {
    QuestionType.choice => 'choice',
    QuestionType.shortAnswer => 'short_answer',
  };
}

class Question {
  final int id;
  final String title;
  final String description;
  final QuestionType type;
  final String category;
  final int difficulty;
  final bool isFree;
  final List<ChoiceOption>? options;

  const Question({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    this.isFree = true,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: QuestionType.fromJson(json['type'] as String),
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      isFree: json['is_free'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ChoiceOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toJson(),
      'category': category,
      'difficulty': difficulty,
      'is_free': isFree,
      'options': options?.map((e) => e.toJson()).toList(),
    };
  }
}
