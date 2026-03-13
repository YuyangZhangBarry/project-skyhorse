import 'question.dart';

class UserAnswer {
  final String id;
  final String userId;
  final int questionId;
  final QuestionType answerType;
  final String answerContent;
  final double? aiScore;
  final String? aiFeedback;
  final DateTime answeredAt;
  final double? imagination;
  final double? logic;
  final double? knowledge;
  final double? creativity;

  const UserAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.answerType,
    required this.answerContent,
    this.aiScore,
    this.aiFeedback,
    required this.answeredAt,
    this.imagination,
    this.logic,
    this.knowledge,
    this.creativity,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questionId: json['question_id'] as int,
      answerType: QuestionType.fromJson(json['answer_type'] as String),
      answerContent: json['answer_content'] as String,
      aiScore: (json['ai_score'] as num?)?.toDouble(),
      aiFeedback: json['ai_feedback'] as String?,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      imagination: (json['imagination'] as num?)?.toDouble(),
      logic: (json['logic'] as num?)?.toDouble(),
      knowledge: (json['knowledge'] as num?)?.toDouble(),
      creativity: (json['creativity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'answer_type': answerType.toJson(),
      'answer_content': answerContent,
      'ai_score': aiScore,
      'ai_feedback': aiFeedback,
      'answered_at': answeredAt.toIso8601String(),
      'imagination': imagination,
      'logic': logic,
      'knowledge': knowledge,
      'creativity': creativity,
    };
  }
}
