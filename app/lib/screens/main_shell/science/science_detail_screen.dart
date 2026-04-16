import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

/// 往期科普详情：仅展示内容与历史讨论，不可发评论。
class ScienceDetailScreen extends ConsumerStatefulWidget {
  const ScienceDetailScreen({super.key, required this.dateStr});

  final String dateStr;

  @override
  ConsumerState<ScienceDetailScreen> createState() => _ScienceDetailScreenState();
}

class _ScienceDetailScreenState extends ConsumerState<ScienceDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getScienceByDate(widget.dateStr);
      if (mounted) setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.scienceArchiveTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _data == null
                ? Center(child: Text(l10n.errorLoadFailed, style: const TextStyle(color: AppColors.textHint)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                              Text(
                                _data!['date'] as String? ?? '',
                                style: TextStyle(fontSize: 13, color: AppColors.textHint),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _data!['title'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _data!['content'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.sciencePastDiscussion,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildComments(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildComments() {
    final l10n = AppLocalizations.of(context)!;
    final comments = (_data!['comments'] as List<dynamic>?) ?? [];
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(l10n.forumNoDiscussion, style: const TextStyle(fontSize: 14, color: AppColors.textHint)),
        ),
      );
    }
    return Column(
      children: List.generate(
        comments.length,
        (i) {
          final c = comments[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 1)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['author_label'] as String? ?? '?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (c['is_guest'] as bool? ?? false)
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c['content'] as String? ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
