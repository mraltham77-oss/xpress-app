import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/premium.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _id = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid => _id.text.trim().isNotEmpty && _password.text.length >= 4;

  Future<void> _login() async {
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل بيانات صحيحة للمتابعة')),
      );
      return;
    }
    final notifier = ref.read(authProvider.notifier);
    final id = _id.text.trim();

    if (notifier.serverMode) {
      if (!id.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('على السيرفر، سجّل الدخول بالبريد الإلكتروني'),
          ),
        );
        return;
      }
      setState(() => _loading = true);
      try {
        await notifier.signInWithEmail(email: id, password: _password.text);
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الدخول بنجاح 🎉')),
        );
        _close();
      } catch (e) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل تسجيل الدخول: ${_msg(e)}')));
      }
      return;
    }

    // الوضع المحلي (بدون سيرفر): دخول تجريبي.
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    notifier.login(
      id.contains('@') ? id : '+20 ${id.replaceAll(RegExp(r'\D'), '')}',
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول بنجاح 🎉')));
    _close();
  }

  void _socialLogin(String provider) {
    if (ref.read(authProvider.notifier).serverMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تسجيل الدخول بـ $provider يتطلب إعداد مزوّد OAuth في Supabase',
          ),
        ),
      );
      return;
    }
    ref.read(authProvider.notifier).login('+20 100 000 0000');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم الدخول بحساب $provider')));
    _close();
  }

  String _msg(Object e) {
    final s = e.toString();
    final i = s.indexOf('message:');
    if (i >= 0) {
      return s.substring(i + 8).replaceAll(RegExp(r'[)\s]+$'), '');
    }
    return s;
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            onPressed: _close,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Gap.sm),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 46,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const XpressLogo(showWord: false, size: 78),
                ),
              ),
              const SizedBox(height: Gap.md),
              const Center(
                child: Text(
                  'XPRESS',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: Gap.xl),
              const Center(
                child: Text(
                  'مرحبًا بك مجددًا',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'سعدنا بعودتك 🌟',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: Gap.xl),
              _AuthField(
                controller: _id,
                hint: 'البريد الالكتروني أو رقم الهاتف',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: Gap.md),
              _AuthField(
                controller: _password,
                hint: 'كلمة المرور',
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
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  _RememberCheck(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'تذكرني',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              NeonButton(
                label: 'تسجيل الدخول',
                onPressed: _loading ? null : _login,
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: Gap.md),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                ),
              const SizedBox(height: Gap.lg),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'أو تسجيل الدخول باستخدام',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: Gap.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialCircle(
                    onTap: () => _socialLogin('Google'),
                    child: const _GoogleG(),
                  ),
                  const SizedBox(width: 18),
                  _SocialCircle(
                    onTap: () => _socialLogin('Apple'),
                    child: const Icon(
                      Icons.apple_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  _SocialCircle(
                    background: const Color(0xFF1877F2),
                    onTap: () => _socialLogin('Facebook'),
                    child: const Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ليس لديك حساب؟',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              const Text(
                'بالضغط على تسجيل الدخول، أنت توافق على شروط الاستخدام وسياسة الخصوصية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textHint,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حقل إدخال بخلفية بيضاء كما في تصميم شاشة تسجيل الدخول الرسمي.
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: AppColors.primary,
        style: const TextStyle(
          color: Color(0xFF14121F),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

/// مربّع "تذكرني" بنفسجي بتصميم مخصّص.
class _RememberCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RememberCheck({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Motion.fast,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

/// دائرة شبكات اجتماعية بتصميم XPRESS (Google / Apple / Facebook).
class _SocialCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color background;

  const _SocialCircle({
    required this.child,
    required this.onTap,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: Shadows.floating,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// حرف "G" لشعار Google بألوان العلامة.
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return const GradientText(
      'G',
      fontSize: 26,
      fontWeight: FontWeight.w900,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4285F4),
          Color(0xFFEA4335),
          Color(0xFFFBBC05),
          Color(0xFF34A853),
        ],
      ),
    );
  }
}
