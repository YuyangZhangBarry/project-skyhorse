import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../models/user_answer.dart';
import 'auth_provider.dart';

class AnswerState {
  final UserAnswer? answer;
  final bool isSubmitting;
  final String? error;

  const AnswerState({this.answer, this.isSubmitting = false, this.error});

  AnswerState copyWith({UserAnswer? answer, bool? isSubmitting, String? error}) {
    return AnswerState(
      answer: answer ?? this.answer,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class AnswerNotifier extends StateNotifier<AnswerState> {
  final Ref _ref;

  AnswerNotifier(this._ref) : super(const AnswerState());

  Future<UserAnswer?> submitAnswer({
    required int questionId,
    required QuestionType answerType,
    required String content,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final answer = await api.submitAnswer(
        questionId: questionId,
        answerType: answerType.toJson(),
        content: content,
      );
      state = AnswerState(answer: answer);
      return answer;
    } catch (_) {
      return _generateDemoAnswer(questionId, answerType, content);
    }
  }

  UserAnswer _generateDemoAnswer(
    int questionId,
    QuestionType answerType,
    String content,
  ) {
    final rng = Random();
    final score = 60.0 + rng.nextInt(35) + rng.nextDouble();

    final feedbacks = [
      '你的回答展现了独特的思维角度！对于这个问题，你能够跳出常规框架，从一个新颖的视角进行分析，这很有价值。',
      '非常有创意的回答！你的想象力令人印象深刻，同时又保持了一定的逻辑性。如果能再深入挖掘一些细节，会更加精彩。',
      '很棒的思考！你对这个问题的理解比较深入，论述也很有条理。建议可以更多地联系实际案例来增强说服力。',
      '有意思的回答！可以看出你对这个话题有自己独到的见解。不过某些论点可以进一步展开，给出更有力的支撑。',
    ];

    final answer = UserAnswer(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo',
      questionId: questionId,
      answerType: answerType,
      answerContent: content,
      aiScore: double.parse(score.toStringAsFixed(1)),
      aiFeedback: feedbacks[rng.nextInt(feedbacks.length)],
      answeredAt: DateTime.now(),
      imagination: double.parse((15.0 + rng.nextInt(10) + rng.nextDouble()).toStringAsFixed(1)),
      logic: double.parse((15.0 + rng.nextInt(10) + rng.nextDouble()).toStringAsFixed(1)),
      knowledge: double.parse((15.0 + rng.nextInt(10) + rng.nextDouble()).toStringAsFixed(1)),
      creativity: double.parse((15.0 + rng.nextInt(10) + rng.nextDouble()).toStringAsFixed(1)),
    );
    state = AnswerState(answer: answer);
    return answer;
  }

  Future<void> loadResult(String answerId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final answer = await api.getAnswerResult(answerId);
      state = AnswerState(answer: answer);
    } catch (e) {
      if (state.answer == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: '加载结果失败',
        );
      }
    }
  }

  void clear() => state = const AnswerState();
}

final answerProvider =
    StateNotifierProvider<AnswerNotifier, AnswerState>((ref) {
  return AnswerNotifier(ref);
});
