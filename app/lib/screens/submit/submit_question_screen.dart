import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/category_label.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submitTitleMin)),
      );
      return;
    }
    if (desc.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submitDescMin)),
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
    } catch (_) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.submitFailed)),
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.submitTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSuccess() {
    final l10n = AppLocalizations.of(context)!;
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
          Text(l10n.submitSuccessTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(l10n.submitSuccessQueue, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          Text(l10n.submitSuccessAppear, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionBack),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.submitPrompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(l10n.submitPromptSub, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: l10n.submitFieldTitle,
              hintText: l10n.submitFieldTitleExample,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.submitFieldDescription,
              hintText: l10n.submitFieldDescriptionHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.labelCategory, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final selected = _category == cat;
              return ChoiceChip(
                label: Text(categoryLabel(cat, l10n)),
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
                  : Text(l10n.actionSubmitReview),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
    );
  }
}
