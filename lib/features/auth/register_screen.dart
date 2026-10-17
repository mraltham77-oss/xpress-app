import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/app_user.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/premium.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _obscure = true;
  bool _loading = false;
  UserRole _role = UserRole.customer;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || !_agree) {
      if (!_agree) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.termsAgree),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }
    final notifier = ref.read(authProvider.notifier);
    final phone = '+20 ${_phone.text.replaceAll(RegExp(r'\D'), '')}';

    if (notifier.serverMode) {
      setState(() => _loading = true);
      try {
        await notifier.registerWithEmail(
          email: _email.text.trim(),
          password: _password.text,
          name: _name.text.trim(),
          phone: phone,
          role: _role,
        );
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء حسابك بنجاح 🎉')),
        );
        context.go('/home');
      } catch (e) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر إنشاء الحساب: ${_msg(e)}')),
        );
      }
      return;
    }

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    notifier.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: phone,
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إنشاء حسابك بنجاح 🎉')));
    context.go('/home');
  }

  String _msg(Object e) {
    final s = e.toString();
    final i = s.indexOf('message:');
    if (i >= 0) return s.substring(i + 8).replaceAll(RegExp(r'[)\s]+$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.signUp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlowIconBadge(
                  icon: Icons.person_add_alt_1_rounded,
                  size: 64,
                ),
                const SizedBox(height: Gap.xl),
                const Text(
                  'أنشئ حسابك في XPRESS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Gap.sm),
                const Text(
                  'دقيقة واحدة وتصلك عروض لا تُفوّت',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: Gap.xxl),
                Row(
                  children: [
                    Expanded(
                      child: _roleChip(
                        label: 'عميل',
                        icon: Icons.shopping_bag_rounded,
                        value: UserRole.customer,
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: _roleChip(
                        label: 'تاجر',
                        icon: Icons.storefront_rounded,
                        value: UserRole.seller,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                _field(
                  controller: _name,
                  label: AppStrings.fullName,
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: Gap.lg),
                _field(
                  controller: _email,
                  label: AppStrings.email,
                  icon: Icons.alternate_email_rounded,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    final ok =
                        v != null &&
                        RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(v.trim());
                    return ok ? null : AppStrings.invalidEmail;
                  },
                ),
                const SizedBox(height: Gap.lg),
                _field(
                  controller: _phone,
                  label: AppStrings.phone,
                  icon: Icons.phone_rounded,
                  keyboard: TextInputType.phone,
                  digitsOnly: true,
                  validator: (v) =>
                      (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                      ? AppStrings.invalidPhone
                      : null,
                ),
                const SizedBox(height: Gap.lg),
                _field(
                  controller: _password,
                  label: AppStrings.password,
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v == null || v.length < 8)
                      ? AppStrings.weakPassword
                      : null,
                ),
                const SizedBox(height: Gap.lg),
                _field(
                  controller: _confirm,
                  label: AppStrings.confirmPassword,
                  icon: Icons.lock_reset_rounded,
                  obscure: true,
                  validator: (v) =>
                      v != _password.text ? AppStrings.passwordsMismatch : null,
                ),
                const SizedBox(height: Gap.lg),
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        AppStrings.termsAgree,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                NeonButton(
                  label: AppStrings.signUp,
                  icon: Icons.check_rounded,
                  onPressed: _loading ? null : _submit,
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: Gap.md),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  ),
                const SizedBox(height: Gap.lg),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.haveAccount,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(AppStrings.signIn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip({
    required String label,
    required IconData icon,
    required UserRole value,
  }) {
    final sel = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: sel ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: sel ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    bool digitsOnly = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: Gap.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          validator: validator,
          inputFormatters: digitsOnly
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
