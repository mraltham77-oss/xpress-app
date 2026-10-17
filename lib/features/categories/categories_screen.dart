import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Expanded(child: Text(AppStrings.categories)),
            Text(
              '${categories.length} أقسام',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(Gap.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: Gap.md,
          crossAxisSpacing: Gap.md,
          childAspectRatio: 0.95,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final c = categories[i];
          return GestureDetector(
            onTap: () => context.push(
              '/category/${c.id}?name=${Uri.encodeComponent(c.name)}',
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    c.imageAsset,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topCenter,
                        end: AlignmentDirectional.bottomCenter,
                        colors: [Colors.transparent, Color(0xE607060C)],
                      ),
                    ),
                  ),
                  // شريحة الفئة
                  PositionedDirectional(top: 12, end: 12, child: _chip(c.name)),
                  // الأقسام الفرعية
                  PositionedDirectional(
                    bottom: 12,
                    start: 12,
                    end: 12,
                    child: _subs(context, c),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder, width: 0.7),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _subs(BuildContext context, dynamic c) {
    final subs = c.subcategories as List<String>;
    if (subs.isEmpty) return const SizedBox();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: subs.take(2).map((s) => _subChip(context, c, s)).toList(),
    );
  }

  Widget _subChip(BuildContext context, dynamic c, String s) {
    return GestureDetector(
      onTap: () => context.push(
        '/category/${c.id}?name=${Uri.encodeComponent(s)}&q=${Uri.encodeComponent(s)}',
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder, width: 0.7),
        ),
        child: Text(
          s,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
