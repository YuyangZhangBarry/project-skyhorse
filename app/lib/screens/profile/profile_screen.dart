import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

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
    if (user.id == 'demo') {
      if (mounted) {
        setState(() {
          _totalAnswers = 3;
          _avgScore = 72.5;
          _recentAnswers = [
            {'answer_content': '人类会减少对农业的依赖…', 'ai_score': 78.0, 'answer_type': 'short_answer'},
            {'answer_content': '思考是意识存在的证明…', 'ai_score': 68.0, 'answer_type': 'short_answer'},
            {'answer_content': '番茄炒蛋——简单却温暖', 'ai_score': 72.0, 'answer_type': 'short_answer'},
          ];
          _isLoading = false;
        });
      }
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
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: user == null
              ? const Center(child: Text('请先登录'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildAvatar(user),
                      const SizedBox(height: 24),
                      if (user.tier != UserTier.premium) _buildUpgradeCard(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          const Text(
            '个人主页',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: user.tier == UserTier.premium
                ? AppColors.warning.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                user.tier == UserTier.premium
                    ? Icons.workspace_premium
                    : Icons.person,
                size: 16,
                color: user.tier == UserTier.premium
                    ? const Color(0xFFD4A017)
                    : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                user.tier == UserTier.premium ? '高级会员' : '免费用户',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: user.tier == UserTier.premium
                      ? const Color(0xFFD4A017)
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Future<void> _upgradeToPremium() async {
    try {
      final api = ref.read(apiServiceProvider);
      final updatedUser = await api.upgradeToPremium();
      ref.read(authProvider.notifier).updateUser(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('恭喜，你已成为高级会员！'), backgroundColor: AppColors.success),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('升级失败，请稍后重试')),
        );
      }
    }
  }

  Widget _buildUpgradeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GestureDetector(
        onTap: _upgradeToPremium,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('升级为高级会员', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('解锁投稿问题 + 论坛分享功能', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildActionButtons(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionTile(
              icon: Icons.forum_outlined,
              label: '讨论广场',
              onTap: () => context.push('/forum'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionTile(
              icon: Icons.add_circle_outline,
              label: '投稿问题',
              locked: user.tier != UserTier.premium,
              onTap: () {
                if (user.tier != UserTier.premium) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('需要升级为高级会员才能投稿问题')),
                  );
                  return;
                }
                context.push('/submit-question');
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 380.ms, duration: 400.ms);
  }

  Widget _buildActionTile({required IconData icon, required String label, bool locked = false, required VoidCallback onTap}) {
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
            Stack(
              children: [
                Icon(icon, size: 28, color: locked ? AppColors.textHint : AppColors.primary),
                if (locked)
                  Positioned(
                    right: -2, bottom: -2,
                    child: Icon(Icons.lock, size: 14, color: AppColors.textHint),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: locked ? AppColors.textHint : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('答题总数', _isLoading ? '-' : '$_totalAnswers', Icons.quiz_outlined),
      ('平均分', _isLoading ? '-' : (_avgScore?.toStringAsFixed(1) ?? '--'), Icons.analytics_outlined),
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
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                '最近回答',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            Center(
              child: Text('还没有答题记录', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
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
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              '最近回答',
              style: TextStyle(
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
                          answerType == 'choice' ? '选择题' : '简答题',
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
          child: const Text(
            '退出登录',
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
