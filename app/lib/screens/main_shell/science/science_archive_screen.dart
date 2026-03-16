import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';

/// 往期科普列表；点击跳转到该日科普详情（只读，不可发评论）。
class ScienceArchiveScreen extends ConsumerStatefulWidget {
  const ScienceArchiveScreen({super.key});

  @override
  ConsumerState<ScienceArchiveScreen> createState() => _ScienceArchiveScreenState();
}

class _ScienceArchiveScreenState extends ConsumerState<ScienceArchiveScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final list = await api.getScienceArchive();
      if (mounted) setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('往期科普'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _items.isEmpty
                ? const Center(child: Text('暂无往期', style: TextStyle(color: AppColors.textHint)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final dateStr = item['date'] as String? ?? '';
                      final title = item['title'] as String? ?? '';
                      return GestureDetector(
                        onTap: () => context.push('/science/$dateStr'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 8,
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
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textHint),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms);
                    },
                  ),
      ),
    );
  }
}
