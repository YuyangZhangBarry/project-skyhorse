import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';

/// 今日科普：当日科普内容 + 讨论区（盖楼）；游客可发评论（唯一可发处）。
class ScienceScreen extends ConsumerStatefulWidget {
  const ScienceScreen({super.key});

  @override
  ConsumerState<ScienceScreen> createState() => _ScienceScreenState();
}

class _ScienceScreenState extends ConsumerState<ScienceScreen> {
  Map<String, dynamic>? _today;
  List<dynamic> _comments = [];
  bool _loading = true;
  bool _loadError = false;
  final _commentController = TextEditingController();
  bool _posting = false;
  String? _guestId;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _effectiveGuestId {
    _guestId ??= '游客_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    return _guestId!;
  }

  Future<void> _loadToday() async {
    setState(() => _loading = true; _loadError = false);
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getScienceToday();
      final dateStr = data['date'] as String;
      final byDate = await api.getScienceByDate(dateStr);
      if (mounted) {
        setState(() {
          _today = byDate;
          _comments = (byDate['comments'] as List<dynamic>?) ?? [];
          _loading = false;
          _loadError = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false; _loadError = true);
    }
  }

  Future<void> _submitComment() async {
    if (_posting) return;
    final content = _commentController.text.trim();
    if (content.isEmpty || _today == null) return;
    final dateStr = _today!['date'] as String;
    final isToday = _today!['is_today'] as bool? ?? false;
    if (!isToday) return;

    setState(() => _posting = true);
    try {
      final api = ref.read(apiServiceProvider);
      // 仅注册用户（有 token）不传 guest_id；游客/体验模式须传 guest_id
      final isRegisteredUser = ref.read(authProvider).isRegisteredUser;
      await api.postScienceComment(
        dateStr,
        content,
        guestId: isRegisteredUser ? null : _effectiveGuestId,
      );
      if (mounted) {
        _commentController.clear();
        await _loadToday();
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
    if (mounted) setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _today == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text(
                              _loadError ? '加载失败，请检查网络后重试' : '暂无今日科普',
                              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            if (_loadError) ...[
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: _loadToday,
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text('重试'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadToday,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildContent(),
                            const SizedBox(height: 24),
                            _buildArchiveLink(),
                            const SizedBox(height: 24),
                            _buildDiscussionSection(),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          '今日科普',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const Spacer(),
        Icon(Icons.auto_stories_rounded, color: AppColors.primary.withValues(alpha: 0.8)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildContent() {
    final title = _today!['title'] as String? ?? '';
    final content = _today!['content'] as String? ?? '';
    final dateStr = _today!['date'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildArchiveLink() {
    return GestureDetector(
      onTap: () => context.push('/science/archive'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            const Text(
              '查看往期科普',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildDiscussionSection() {
    final isToday = _today!['is_today'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '讨论区',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (isToday) ...[
          TextField(
            controller: _commentController,
            maxLines: 3,
            enabled: !_posting,
            decoration: const InputDecoration(
              hintText: '写下你的想法…（登录用户与游客均可发言）',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _posting ? null : _submitComment,
              child: _posting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('发表'),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('暂无讨论', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
            ),
          )
        else
          ...List.generate(_comments.length, (i) {
            final c = _comments[i] as Map<String, dynamic>;
            return _CommentTile(
              author: c['author_label'] as String? ?? '?',
              content: c['content'] as String? ?? '',
              isGuest: c['is_guest'] as bool? ?? false,
            ).animate().fadeIn(delay: (50 * i).ms, duration: 300.ms);
          }),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.author, required this.content, required this.isGuest});

  final String author;
  final String content;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                author,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isGuest ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
              if (isGuest) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('游客', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
