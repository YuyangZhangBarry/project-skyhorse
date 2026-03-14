import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/question.dart';
import '../../providers/answer_provider.dart';
import '../../providers/questions_provider.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final int questionId;

  const QuestionScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  int? _selectedOptionId;
  String? _selectedOptionContent;
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Question? get _question {
    final state = ref.read(questionsProvider);
    try {
      return state.questions.firstWhere((q) => q.id == widget.questionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    final question = _question;
    if (question == null) return;

    if (question.type == QuestionType.choice && _selectedOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择一个选项')),
      );
      return;
    }

    if (question.type == QuestionType.shortAnswer &&
        _textController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少写10个字哦')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final content = question.type == QuestionType.choice
        ? _selectedOptionContent!
        : _textController.text.trim();

    final answer = await ref.read(answerProvider.notifier).submitAnswer(
      questionId: question.id,
      answerType: question.type,
      content: content,
    );

    if (mounted && answer != null) {
      context.push('/result/${answer.id}');
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;

    if (question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('题目加载中...')),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionInfo(question),
                      const SizedBox(height: 28),
                      if (question.type == QuestionType.choice)
                        _buildChoiceOptions(question)
                      else
                        _buildTextInput(),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '第 ${widget.questionId} 题',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTag(question.category, AppColors.primary),
            const SizedBox(width: 8),
            _buildTag(
              question.type == QuestionType.choice ? '选择题' : '简答题',
              AppColors.secondary,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.05, duration: 400.ms),
        const SizedBox(height: 20),
        Text(
          question.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            question.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.05, delay: 200.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChoiceOptions(Question question) {
    final options = question.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请选择你的答案',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedOptionId == option.id;
          final letter = String.fromCharCode(65 + index);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedOptionId = option.id;
              _selectedOptionContent = option.content;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE8E8E8),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 300 + index * 80),
                duration: 400.ms,
              )
              .slideX(
                begin: 0.05,
                delay: Duration(milliseconds: 300 + index * 80),
                duration: 400.ms,
              );
        }),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '写下你的回答',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 8,
            minLines: 5,
            decoration: const InputDecoration(
              hintText: '请大胆发挥你的想象力，写下你的思考...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              fillColor: Colors.transparent,
              filled: true,
            ),
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.05, delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, value, _) {
              return Text(
                '${value.text.length} 字',
                style: TextStyle(
                  fontSize: 13,
                  color: value.text.length < 10
                      ? AppColors.textHint
                      : AppColors.success,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  '提交回答',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 0.2, delay: 500.ms, duration: 400.ms);
  }
}
