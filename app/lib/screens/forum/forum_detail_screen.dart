import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ForumDetailScreen extends ConsumerStatefulWidget {
  const ForumDetailScreen({super.key, required this.questionId, required this.questionTitle});

  final int questionId;
  final String questionTitle;

  @override
  ConsumerState<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends ConsumerState<ForumDetailScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;
  bool _sortByTime = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  String get _sortParam => _sortByTime ? 'time' : 'likes';

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    if (!_hasMore && !refresh) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getForumPosts(
        page: _page,
        questionId: widget.questionId,
        sort: _sortParam,
      );
      final items = (data['items'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      setState(() {
        _posts = refresh ? items : [..._posts, ...items];
        _hasMore = items.length >= 20;
        _page++;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSort() async {
    setState(() {
      _sortByTime = !_sortByTime;
      _posts = [];
      _page = 1;
      _hasMore = true;
    });
    await _loadPosts(refresh: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSortBar(),
              Expanded(
                child: _isLoading && _posts.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _posts.isEmpty
                        ? _buildEmpty()
                        : _buildPostList(),
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
            child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
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
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          const Text('排序：', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (!_sortByTime) _toggleSort();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _sortByTime ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '最新',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _sortByTime ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_sortByTime) _toggleSort();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _sortByTime ? AppColors.surface : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: _sortByTime ? AppColors.textSecondary : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '最热',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _sortByTime ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('暂无讨论', style: TextStyle(fontSize: 15, color: AppColors.textHint)),
    );
  }

  Widget _buildPostList() {
    return RefreshIndicator(
      onRefresh: () => _loadPosts(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _posts.length) {
            if (_hasMore && !_isLoading) _loadPosts();
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          return _buildPostCard(_posts[index], index);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final liked = post['liked_by_me'] as bool? ?? false;
    final likeCount = post['like_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      (post['user_nickname'] as String? ?? '?').characters.first,
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
                        post['user_nickname'] as String? ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (post['selected_option'] != null &&
                          (post['selected_option'] as String).isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '选择了：${post['selected_option']}',
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
              post['content'] as String? ?? '',
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _toggleLike(index),
              child: Row(
                children: [
                  Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: liked ? AppColors.secondary : AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$likeCount',
                    style: TextStyle(
                      fontSize: 13,
                      color: liked ? AppColors.secondary : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 350.ms).slideY(begin: 0.03, duration: 350.ms);
  }
}
