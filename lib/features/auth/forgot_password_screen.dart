import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/premium.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();

  int _step = 0; // 0 = email, 1 = otp, 2 = new password
  bool _loading = false;

  static const _demoOtp = '1234';

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  Future<void> _run(VoidCallback onDone) async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => _step == 0 ? context.pop() : setState(() => _step--),
        ),
        title: const Text(AppStrings.resetPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: AnimatedSwitcher(
            duration: Motion.base,
            child: switch (_step) {
              0 => _emailStep(),
              1 => _otpStep(),
              _ => _passwordStep(),
            },
          ),
        ),
      ),
    );
  }

  Widget _emailStep() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlowIconBadge(icon: Icons.lock_reset_rounded, size: 64),
        const SizedBox(height: Gap.xl),
        const Text(
          AppStrings.resetPassword,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: Gap.sm),
        const Text(
          AppStrings.resetPasswordHint,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: Gap.xxl),
        const Text(
          AppStrings.email,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: Gap.sm),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: Gap.xl),
        NeonButton(
          label: AppStrings.sendCode,
          icon: Icons.send_rounded,
          onPressed: (_emailValid && !_loading)
              ? () => _run(() => setState(() => _step = 1))
              : null,
        ),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlowIconBadge(icon: Icons.mark_email_read_outlined, size: 64),
        const SizedBox(height: Gap.xl),
        const Text(
          AppStrings.otpTitle,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          '${AppStrings.otpSubtitle} ${_email.text.trim()}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: Gap.sm),
        const Text(
          AppStrings.demoOtpHint,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Gap.xl),
        TextField(
          controller: _otp,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 16,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: '– – – –',
            counterText: '',
          ),
        ),
        const SizedBox(height: Gap.lg),
        NeonButton(
          label: AppStrings.verify,
          icon: Icons.verified_rounded,
          onPressed: (_otp.text.length == 4 && !_loading)
              ? () {
                  if (_otp.text != _demoOtp) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.invalidOtp),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }
                  setState(() => _step = 2);
                }
              : null,
        ),
        const SizedBox(height: Gap.md),
        Center(
          child: TextButton(
            onPressed: _loading ? null : () => setState(() {}),
            child: const Text(
              AppStrings.resendCode,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordStep() {
    final valid = _password.text.length >= 8;
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlowIconBadge(icon: Icons.password_rounded, size: 64),
        const SizedBox(height: Gap.xl),
        const Text(
          AppStrings.newPassword,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: Gap.sm),
        const Text(
          'اختر كلمة مرور قوية لا تقل عن 8 أحرف',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: Gap.xxl),
        TextField(
          controller: _password,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: Gap.sm),
        if (_password.text.isNotEmpty && !valid)
          const Text(
            AppStrings.weakPassword,
            style: TextStyle(color: AppColors.danger, fontSize: 12.5),
          ),
        const SizedBox(height: Gap.xl),
        NeonButton(
          label: AppStrings.changePassword,
          icon: Icons.check_rounded,
          onPressed: (valid && !_loading)
              ? () => _run(() {
                  ref.read(authProvider.notifier).resetPassword(_password.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.passwordUpdated),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/login');
                })
              : null,
        ),
      ],
    );
  }
}
