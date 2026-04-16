import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _totalAnswers = 0;
  double? _avgScore;
  List<Map<String, dynamic>> _recentAnswers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final api = ref.read(apiServiceProvider);
      final stats = await api.getUserStats();
      final history = await api.getAnswerHistory();
      if (mounted) {
        setState(() {
          _totalAnswers = stats['total_answers'] as int? ?? 0;
          _avgScore = (stats['average_score'] as num?)?.toDouble();
          _recentAnswers = history.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: user == null
              ? Center(child: Text(l10n.profileLogin))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildAvatar(user),
                      const SizedBox(height: 24),
                      _buildActionButtons(user),
                      const SizedBox(height: 16),
                      _buildStats(),
                      const SizedBox(height: 24),
                      _buildRecentAnswers(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context, ref),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          Text(
            l10n.profileTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.nickname.characters.first,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.7, 0.7),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 16),
        Text(
          user.nickname,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildActionButtons(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionTile(
              icon: Icons.forum_outlined,
              label: l10n.forumTitle,
              onTap: () => context.push('/forum'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionTile(
              icon: Icons.add_circle_outline,
              label: l10n.profileSubmitQuestion,
              onTap: () => context.push('/submit-question'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 380.ms, duration: 400.ms);
  }

  Widget _buildActionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final l10n = AppLocalizations.of(context)!;
    final stats = [
      (l10n.profileTotalAnswers, _isLoading ? '-' : '$_totalAnswers', Icons.quiz_outlined),
      (l10n.profileAverageScore, _isLoading ? '-' : (_avgScore?.toStringAsFixed(1) ?? '--'), Icons.analytics_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: stats.asMap().entries.map((entry) {
            final stat = entry.value;
            return Column(
              children: [
                Icon(stat.$3, color: AppColors.primary, size: 24),
                const SizedBox(height: 10),
                Text(
                  stat.$2,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 400 + entry.key * 100),
                  duration: 400.ms,
                );
          }).toList(),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.1, delay: 300.ms, duration: 400.ms);
  }

  Widget _buildRecentAnswers() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_recentAnswers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                l10n.profileRecentAnswers,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            Center(
              child: Text(l10n.profileNoHistory, style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              l10n.profileRecentAnswers,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ..._recentAnswers.asMap().entries.map((entry) {
            final data = entry.value;
            final content = data['answer_content'] as String? ?? '';
            final score = (data['ai_score'] as num?)?.toDouble() ?? 0;
            final answerType = data['answer_type'] as String? ?? '';
            final displayText = content.length > 20 ? '${content.substring(0, 20)}...' : content;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          answerType == 'choice' ? l10n.questionTypeChoice : l10n.questionTypeShort,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _scoreColor(score).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      score > 0 ? score.toStringAsFixed(0) : '--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(score),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 600 + entry.key * 100),
                  duration: 400.ms,
                )
                .slideX(
                  begin: 0.05,
                  delay: Duration(milliseconds: 600 + entry.key * 100),
                  duration: 400.ms,
                );
          }),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.primary;
    return AppColors.secondary;
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            l10n.actionLogout,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms);
  }
}
