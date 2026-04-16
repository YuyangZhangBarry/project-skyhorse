import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions({bool refresh = false}) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final list = await api.getForumQuestionSummaries();
      setState(() {
        _questions = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _questions.isEmpty
                        ? _buildEmpty()
                        : _buildQuestionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          const Text(
            '讨论广场',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Icon(Icons.forum_outlined, color: AppColors.primary.withValues(alpha: 0.6)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('还没有人分享回答', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('成为会员，第一个分享你的精彩回答吧！', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return RefreshIndicator(
      onRefresh: () => _loadQuestions(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final q = _questions[index];
          return _buildQuestionCard(
            questionId: q['question_id'] as int,
            questionTitle: q['question_title'] as String,
            postCount: q['post_count'] as int,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard({
    required int questionId,
    required String questionTitle,
    required int postCount,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => context.push(
        '/forum/question/$questionId?title=${Uri.encodeComponent(questionTitle)}',
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                questionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '$postCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideX(begin: 0.03, duration: 400.ms);
  }
}
