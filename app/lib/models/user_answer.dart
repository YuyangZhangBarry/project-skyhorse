import 'question.dart';

class UserAnswer {
  final String id;
  final String? userId;
  final int questionId;
  final QuestionType answerType;
  final String answerContent;
  final double? aiScore;
  final String? aiFeedback;
  final String? scoringStatus;
  final DateTime answeredAt;
  final double? imagination;
  final double? logic;
  final double? knowledge;
  final double? creativity;

  const UserAnswer({
    required this.id,
    this.userId,
    required this.questionId,
    required this.answerType,
    required this.answerContent,
    this.aiScore,
    this.aiFeedback,
    this.scoringStatus,
    required this.answeredAt,
    this.imagination,
    this.logic,
    this.knowledge,
    this.creativity,
  });

  bool get isCompleted => scoringStatus == 'completed';

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      questionId: json['question_id'] as int,
      answerType: QuestionType.fromJson(json['answer_type'] as String),
      answerContent: json['answer_content'] as String,
      aiScore: (json['ai_score'] as num?)?.toDouble(),
      aiFeedback: json['ai_feedback'] as String?,
      scoringStatus: json['scoring_status'] as String?,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      imagination: (json['imagination_score'] as num?)?.toDouble(),
      logic: (json['logic_score'] as num?)?.toDouble(),
      knowledge: (json['knowledge_score'] as num?)?.toDouble(),
      creativity: (json['creativity_score'] as num?)?.toDouble(),
    );
  }

}
