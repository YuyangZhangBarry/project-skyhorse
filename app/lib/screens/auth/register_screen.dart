import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nicknameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有字段')),
      );
      return;
    }

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
          child: Center(
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
        const Text(
          '创建账号',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 8),
        const Text(
          '开启你的脑洞之旅',
          style: TextStyle(
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
    return Column(
      children: [
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            hintText: '昵称',
            prefixIcon: Icon(Icons.face_outlined, color: AppColors.textHint),
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: '邮箱',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 400.ms, duration: 400.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '密码',
            prefixIcon: Icon(Icons.lock_outlined, color: AppColors.textHint),
          ),
          onSubmitted: (_) => _register(),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideX(begin: -0.05, delay: 500.ms, duration: 400.ms),
        if (authState.error != null) ...[
          const SizedBox(height: 12),
          Text(
            authState.error!,
            style: const TextStyle(color: AppColors.secondary, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterButton() {
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
            : const Text(
                '注册',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.1, delay: 600.ms, duration: 400.ms);
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: RichText(
        text: const TextSpan(
          text: '已有账号？',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          children: [
            TextSpan(
              text: '登录',
              style: TextStyle(
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
