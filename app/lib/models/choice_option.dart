class ChoiceOption {
  final int id;
  final int questionId;
  final String content;
  final bool isInteresting;
  final String? aiComment;

  const ChoiceOption({
    required this.id,
    required this.questionId,
    required this.content,
    this.isInteresting = false,
    this.aiComment,
  });

  factory ChoiceOption.fromJson(Map<String, dynamic> json) {
    return ChoiceOption(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      content: json['content'] as String,
      isInteresting: json['is_interesting'] as bool? ?? false,
      aiComment: json['ai_comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content': content,
      'is_interesting': isInteresting,
      'ai_comment': aiComment,
    };
  }
}
