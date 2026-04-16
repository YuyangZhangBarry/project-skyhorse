class ChoiceOption {
  final int id;
  final int questionId;
  final String content;
  final String? aiComment;

  const ChoiceOption({
    required this.id,
    required this.questionId,
    required this.content,
    this.aiComment,
  });

  factory ChoiceOption.fromJson(Map<String, dynamic> json) {
    return ChoiceOption(
      id: json['id'] as int,
      questionId: json['question_id'] as int? ?? 0,
      content: json['content'] as String,
      aiComment: json['ai_comment'] as String?,
    );
  }
}
