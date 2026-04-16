import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

String localizedAuthError(String error, AppLocalizations l10n) {
  switch (error) {
    case 'login_failed':
      return l10n.loginFailed;
    case 'register_failed':
      return l10n.registerFailed;
    default:
      return error;
  }
}

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider).languageCode;
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          langCode == 'zh' ? 'EN' : '中',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
