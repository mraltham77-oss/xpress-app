import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _push = true;
  bool _promos = true;
  bool _orderUpdates = true;
  String _language = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          _group('الإشعارات', [
            SwitchListTile(
              value: _push,
              onChanged: (v) => setState(() => _push = v),
              title: const Text(
                'الإشعارات الفورية',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              value: _orderUpdates,
              onChanged: (v) => setState(() => _orderUpdates = v),
              title: const Text(
                'تحديثات الطلبات',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              value: _promos,
              onChanged: (v) => setState(() => _promos = v),
              title: const Text(
                'العروض والتخفيضات',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              activeThumbColor: AppColors.primary,
            ),
          ]),
          _group('عام', [
            ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'اللغة',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: Text(
                _language,
                style: const TextStyle(color: AppColors.textHint),
              ),
              onTap: _pickLanguage,
            ),
            ListTile(
              leading: const Icon(
                Icons.cleaning_services_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'مسح ذاكرة التخزين المؤقت',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح 24.5 ميجابايت')),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'الإصدار',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: const Text(
                '1.0.0',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          ]),
          const SizedBox(height: Gap.md),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/home');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج')));
            },
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('تسجيل الخروج'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, Gap.md, 4, Gap.sm),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Shadows.card,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(Gap.lg),
              child: Text(
                'اختر اللغة',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            for (final lang in ['العربية', 'English'])
              ListTile(
                title: Text(lang),
                trailing: _language == lang
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _language = lang);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم اختيار اللغة: $lang')),
                  );
                },
              ),
            const SizedBox(height: Gap.sm),
          ],
        ),
      ),
    );
  }
}
