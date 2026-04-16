import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/question.dart';
import '../../models/user_answer.dart';
import '../../providers/answer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/score_circle.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String answerId;

  const ResultScreen({super.key, required this.answerId});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnimation;
  bool _isPublishingToForum = false;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOutCubic),
    );

    Future.microtask(() {
      final state = ref.read(answerProvider);
      if (state.answer == null || state.answer!.id != widget.answerId) {
        ref.read(answerProvider.notifier).loadResult(widget.answerId);
      }
      _pollForResult();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _scoreAnimController.forward();
    });
  }

  void _pollForResult() async {
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final answer = ref.read(answerProvider).answer;
      if (answer == null) return;
      if (answer.isCompleted) {
        _scoreAnimController.reset();
        _scoreAnimController.forward();
        return;
      }
      await ref.read(answerProvider.notifier).loadResult(widget.answerId);
    }
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answerState = ref.watch(answerProvider);
    final answer = answerState.answer;

    if (answer == null) {
      return Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.gradientBackground),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    final isShortAnswer = answer.answerType == QuestionType.shortAnswer;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildScoreHeader(answer.aiScore ?? 0),
                const SizedBox(height: 32),
                if (isShortAnswer) ...[
                  _buildDimensionScores(answer),
                  const SizedBox(height: 28),
                ],
                _buildFeedbackCard(answer.aiFeedback, isShortAnswer),
                if (isShortAnswer) ...[
                  const SizedBox(height: 24),
                  _buildPublishToForumButton(answer),
                ],
                const SizedBox(height: 32),
                _buildActions(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(double score) {
    return Column(
      children: [
        const Text(
          'AI 评分',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            final animatedScore = score * _scoreAnimation.value;
            return Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primaryLight.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animatedScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 12),
        Text(
          _getScoreLabel(score),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 500.ms),
      ],
    );
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return '🌟 非凡的思考者！';
    if (score >= 80) return '✨ 令人印象深刻！';
    if (score >= 70) return '💡 很有想法！';
    if (score >= 60) return '🎯 不错的开始！';
    return '🌱 继续探索吧！';
  }

  Widget _buildDimensionScores(UserAnswer answer) {
    final dimensions = [
      ('想象力', answer.imagination ?? 0.0, const Color(0xFFE17055)),
      ('逻辑性', answer.logic ?? 0.0, const Color(0xFF0984E3)),
      ('知识面', answer.knowledge ?? 0.0, const Color(0xFF00B894)),
      ('趣味性', answer.creativity ?? 0.0, const Color(0xFFFDCB6E)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '四维评估',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dimensions
                .asMap()
                .entries
                .map((entry) => ScoreCircle(
                      label: entry.value.$1,
                      score: entry.value.$2,
                      color: entry.value.$3,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 600 + entry.key * 150),
                          duration: 500.ms,
                        ))
                .toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.1, delay: 400.ms, duration: 500.ms);
  }

  Widget _buildFeedbackCard(String? feedback, bool isShortAnswer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI 点评',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            feedback ?? '暂无点评',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: isShortAnswer ? 1000 : 400),
          duration: 500.ms,
        )
        .slideY(
          begin: 0.1,
          delay: Duration(milliseconds: isShortAnswer ? 1000 : 400),
          duration: 500.ms,
        );
  }

  Widget _buildPublishToForumButton(UserAnswer answer) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isPublishingToForum
            ? null
            : () => _publishShortAnswerToForum(answer),
        icon: _isPublishingToForum
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.forum_outlined, size: 20),
        label: const Text('发表到论坛'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1100.ms, duration: 400.ms)
        .slideY(begin: 0.1, delay: 1100.ms, duration: 400.ms);
  }

  Future<void> _publishShortAnswerToForum(UserAnswer answer) async {
    setState(() => _isPublishingToForum = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.createForumPost(
        answerId: answer.id,
        content: answer.answerContent,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已发表到论坛')),
        );
      }
    } catch (e) {
      if (mounted) {
        const msg = '发表失败，请重试';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    if (mounted) setState(() => _isPublishingToForum = false);
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primaryLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '返回首页',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ref.read(answerProvider.notifier).clear();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '下一题',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1200.ms, duration: 500.ms)
        .slideY(begin: 0.2, delay: 1200.ms, duration: 500.ms);
  }
}
