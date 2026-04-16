import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

String? _validateEmail(String value, AppLocalizations l10n) {
  if (value.isEmpty) return l10n.validationEmailRequired;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return l10n.validationEmailRequired;
  final pattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!pattern.hasMatch(trimmed)) return l10n.validationEmailInvalid;
  if (trimmed.length > 254) return l10n.validationEmailTooLong;
  return null;
}

String? _validatePassword(String value, AppLocalizations l10n) {
  if (value.isEmpty) return l10n.validationPasswordRequired;
  if (value.length < 6) return l10n.validationPasswordMinLength;
  if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return l10n.validationPasswordNeedsLetter;
  if (!RegExp(r'[0-9]').hasMatch(value)) return l10n.validationPasswordNeedsDigit;
  if (!RegExp(r'^[a-zA-Z0-9_!.@#$%^&*\-+=]+$').hasMatch(value)) {
    return l10n.validationPasswordAllowedChars;
  }
  return null;
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nicknameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerFillAll)),
      );
      return;
    }

    final email = _emailController.text.trim();
    final emailError = _validateEmail(email, l10n);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }
    setState(() => _emailError = null);

    final pwdError = _validatePassword(_passwordController.text, l10n);
    if (pwdError != null) {
      setState(() => _passwordError = pwdError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pwdError)),
      );
      return;
    }
    setState(() => _passwordError = null);

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).register(
      _emailController.text.trim(),
      _passwordController.text,
      _nicknameController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildForm(authState),
                      const SizedBox(height: 28),
                      _buildRegisterButton(),
                      const SizedBox(height: 24),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 12,
                right: 16,
                child: LanguageToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 36,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 20),
        Text(
          l10n.registerTitle,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 8),
        Text(
          l10n.registerSubtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: l10n.fieldNickname,
            prefixIcon: const Icon(Icons.face_outlined, color: AppColors.textHint),
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: l10n.fieldEmail,
            errorText: _emailError,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
          ),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 400.ms, duration: 400.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: l10n.fieldPassword,
            helperText: l10n.registerPasswordHelper,
            helperMaxLines: 2,
            errorText: _passwordError,
            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textHint),
          ),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          onSubmitted: (_) => _register(),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 500.ms, duration: 400.ms),
        if (authState.error != null) ...[
          const SizedBox(height: 12),
          Text(
            localizedAuthError(authState.error!, l10n),
            style: const TextStyle(color: AppColors.secondary, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                l10n.actionRegister,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.1, delay: 600.ms, duration: 400.ms);
  }

  Widget _buildLoginLink() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.pop(),
      child: RichText(
        text: TextSpan(
          text: l10n.registerHasAccount,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          children: [
            TextSpan(
              text: l10n.actionLogin,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms);
  }
}
