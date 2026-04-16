import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SubmitQuestionScreen extends ConsumerStatefulWidget {
  const SubmitQuestionScreen({super.key});

  @override
  ConsumerState<SubmitQuestionScreen> createState() => _SubmitQuestionScreenState();
}

class _SubmitQuestionScreenState extends ConsumerState<SubmitQuestionScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = '脑洞';
  bool _isSubmitting = false;
  bool _submitted = false;

  static const _categories = ['科学', '哲学', '脑洞', '生活', '宇宙'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题至少需要5个字')),
      );
      return;
    }
    if (desc.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('描述至少需要10个字')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.submitUserQuestion(title: title, description: desc, category: _category);
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交失败，请稍后重试')),
        );
      }
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
              _buildHeader(),
              Expanded(
                child: _submitted ? _buildSuccess() : _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          const Text(
            '投稿问题',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 48, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          const Text('提交成功！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('你的问题已进入审核队列', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const Text('审核通过后将出现在题库中', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('想一个天马行空的问题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('好的问题能引发思考、激发想象力', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: '问题标题',
              hintText: '例如：如果人类能光合作用，世界会变成什么样？',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '问题描述',
              hintText: '给出一些背景信息，帮助回答者理解这个问题...',
            ),
          ),
          const SizedBox(height: 16),
          const Text('分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final selected = _category == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('提交审核'),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
    );
  }
}
