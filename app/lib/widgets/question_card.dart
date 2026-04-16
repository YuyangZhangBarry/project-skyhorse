import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../utils/category_label.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;
  final int index;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryBadge(context),
                  const SizedBox(width: 8),
                  _buildTypeBadge(context),
                  const Spacer(),
                  _buildDifficultyStars(),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                question.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 60 * index),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.1,
          delay: Duration(milliseconds: 60 * index),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryColors = {
      '科学': const Color(0xFF0984E3),
      '哲学': const Color(0xFF6C5CE7),
      '脑洞': const Color(0xFFE17055),
      '生活': const Color(0xFF00B894),
    };
    final color = categoryColors[question.category] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        categoryLabel(question.category, l10n),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChoice = question.type == QuestionType.choice;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isChoice ? AppColors.secondary : AppColors.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isChoice ? Icons.check_circle_outline : Icons.edit_outlined,
            size: 13,
            color: isChoice ? AppColors.secondary : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            isChoice ? l10n.questionBadgeChoice : l10n.questionBadgeShort,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isChoice ? AppColors.secondary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < question.difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: i < question.difficulty
              ? AppColors.warning
              : AppColors.textHint,
        );
      }),
    );
  }
}
