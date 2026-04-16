import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class ChoiceResultScreen extends ConsumerStatefulWidget {
  const ChoiceResultScreen({
    super.key,
    required this.questionId,
    required this.answerId,
    required this.questionTitle,
    required this.selectedOptionContent,
  });

  final int questionId;
  final String answerId;
  final String questionTitle;
  final String selectedOptionContent;

  @override
  ConsumerState<ChoiceResultScreen> createState() => _ChoiceResultScreenState();
}

class _ChoiceResultScreenState extends ConsumerState<ChoiceResultScreen> {
  List<Map<String, dynamic>> _stats = [];
  List<Map<String, dynamic>> _posts = [];
  bool _statsLoading = true;
  bool _postsLoading = true;
  final _reasonController = TextEditingController();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadPosts();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final items = await api.getChoiceStats(widget.questionId);
      if (mounted) setState(() {
        _stats = items;
        _statsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getForumPosts(
        questionId: widget.questionId,
        sort: 'time',
      );
      final items = (data['items'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      if (mounted) setState(() {
        _posts = items;
        _postsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _postsLoading = false);
    }
  }

  Future<void> _publishReason() async {
    final content = _reasonController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入原因')),
      );
      return;
    }
    setState(() => _isPublishing = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.createForumPost(
        answerId: widget.answerId,
        content: content,
      );
      if (mounted) {
        _reasonController.clear();
        _loadPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发表成功')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发表失败，请重试')),
        );
      }
    }
    if (mounted) setState(() => _isPublishing = false);
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildYourChoice(),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildReasonSection(),
                      const SizedBox(height: 24),
                      _buildCommentsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.questionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.home_outlined,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildYourChoice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          Text(
            '你选择了：${widget.selectedOptionContent}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildStatsSection() {
    if (_statsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投票分布',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_stats.length, (i) {
          final item = _stats[i];
          final content = item['content'] as String? ?? '';
          final count = item['count'] as int? ?? 0;
          final percentage = (item['percentage'] as num?)?.toDouble() ?? 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionBar(
              label: content,
              count: count,
              percentage: percentage,
              isSelected: content == widget.selectedOptionContent,
            ),
          ).animate().fadeIn(delay: (50 * i).ms, duration: 300.ms);
        }),
      ],
    );
  }

  Widget _buildReasonSection() {
    final isRegisteredUser = ref.watch(authProvider).isRegisteredUser;
    final isPremium = ref.watch(authProvider).user?.tier == UserTier.premium;
    final canPublish = isRegisteredUser && isPremium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '是否要发表选择该选项的原因？',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (!isRegisteredUser)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '请注册并登录后可发表选择原因',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          )
        else if (!isPremium)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '仅会员可发表选择原因',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          )
        else ...[
          TextField(
            controller: _reasonController,
            maxLines: 3,
            enabled: canPublish && !_isPublishing,
            decoration: const InputDecoration(
              hintText: '写下你选择该选项的原因...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (canPublish && !_isPublishing) ? _publishReason : null,
              child: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('发表到论坛'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '用户评论',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_postsLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_posts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '暂无评论',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          )
        else
          ...List.generate(_posts.length, (i) {
            final post = _posts[i];
            final canLike = ref.watch(authProvider).isRegisteredUser;
            return _CommentCard(
              userNickname: post['user_nickname'] as String? ?? '',
              content: post['content'] as String? ?? '',
              selectedOption: post['selected_option'] as String?,
              likeCount: post['like_count'] as int? ?? 0,
              likedByMe: post['liked_by_me'] as bool? ?? false,
              canLike: canLike,
              onLike: () => _toggleLike(i),
            ).animate().fadeIn(delay: (40 * i).ms, duration: 300.ms);
          }),
      ],
    );
  }

  Future<void> _toggleLike(int index) async {
    if (!ref.read(authProvider).isRegisteredUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请注册并登录后点赞')),
      );
      return;
    }
    final post = _posts[index];
    try {
      final api = ref.read(apiServiceProvider);
      final newCount = await api.toggleLike(post['id'] as String);
      setState(() {
        _posts[index] = {
          ...post,
          'like_count': newCount,
          'liked_by_me': !(post['liked_by_me'] as bool? ?? false),
        };
      });
    } catch (_) {}
  }
}

class _OptionBar extends StatelessWidget {
  final String label;
  final int count;
  final double percentage;
  final bool isSelected;

  const _OptionBar({
    required this.label,
    required this.count,
    required this.percentage,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              '$count 人 · ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 28,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  color: AppColors.surface,
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.gradientPrimary
                          : LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.5),
                                AppColors.primaryLight.withValues(alpha: 0.5),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Widget child;

  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth * widthFactor).clamp(0.0, double.infinity);
        return SizedBox(width: w, child: child);
      },
    );
  }
}

class _CommentCard extends StatelessWidget {
  final String userNickname;
  final String content;
  final String? selectedOption;
  final int likeCount;
  final bool likedByMe;
  final bool canLike;
  final VoidCallback onLike;

  const _CommentCard({
    required this.userNickname,
    required this.content,
    this.selectedOption,
    required this.likeCount,
    required this.likedByMe,
    required this.canLike,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    userNickname.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userNickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (selectedOption != null && selectedOption!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '选择了：$selectedOption',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  likedByMe ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: canLike
                      ? (likedByMe ? AppColors.secondary : AppColors.textHint)
                      : AppColors.textHint.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount',
                  style: TextStyle(
                    fontSize: 13,
                    color: likedByMe ? AppColors.secondary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
