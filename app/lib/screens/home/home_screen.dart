import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/questions_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/question_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categories = ['全部', '科学', '哲学', '脑洞', '生活', '宇宙'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(questionsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, authState),
              _buildCategoryFilter(ref, questionsState.selectedCategory),
              Expanded(
                child: questionsState.isLoading && questionsState.questions.isEmpty
                    ? const LoadingShimmer()
                    : _buildQuestionsList(context, ref, questionsState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthState authState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '天马行空',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.1, duration: 500.ms),
              const SizedBox(height: 2),
              Text(
                '每一个回答，都是一次思维冒险',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  authState.user?.nickname.characters.first ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                delay: 300.ms,
                duration: 400.ms,
              ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, String selectedCategory) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CategoryChip(
              label: category,
              isSelected: selectedCategory == category,
              onTap: () =>
                  ref.read(questionsProvider.notifier).setCategory(category),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: -0.2, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildQuestionsList(
    BuildContext context,
    WidgetRef ref,
    QuestionsState state,
  ) {
    if (state.questions.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              '暂无题目',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(questionsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: state.questions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.questions.length) {
            if (state.hasMore && !state.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(questionsProvider.notifier).loadQuestions();
              });
            }
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final question = state.questions[index];
          return QuestionCard(
            question: question,
            index: index,
            onTap: () => context.push('/question/${question.id}'),
          );
        },
      ),
    );
  }
}
