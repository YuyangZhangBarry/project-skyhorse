import '../l10n/app_localizations.dart';

String categoryLabel(String key, AppLocalizations l10n, {String? fallback}) {
  switch (key) {
    case '科学': return l10n.categoryScience;
    case '哲学': return l10n.categoryPhilosophy;
    case '脑洞': return l10n.categoryBrainhole;
    case '生活': return l10n.categoryLife;
    case '宇宙': return l10n.categoryUniverse;
    default: return fallback ?? key;
  }
}
