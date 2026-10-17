import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).set(v),
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
      body: query.isEmpty
          ? _Suggestions(
              onTap: (v) {
                _controller.text = v;
                ref.read(searchQueryProvider.notifier).set(v);
              },
            )
          : results.isEmpty
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: AppStrings.noResults,
              subtitle: 'جرّب كلمات مفتاحية أخرى',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemCount: results.length,
              itemBuilder: (context, i) => ProductCard(
                product: results[i],
                onTap: () => context.push('/product/${results[i].id}'),
              ),
            ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _Suggestions({required this.onTap});

  static const _recent = ['هاتف ذكي', 'سماعات', 'حقيبة جلد', 'ساعة ذكية'];
  static const _trending = ['عروض فلاش', 'أزياء نسائية', 'إلكترونيات', 'عطور'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Head('عمليات البحث الأخيرة'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recent
              .map(
                (e) => _Pill(
                  text: e,
                  icon: Icons.history_rounded,
                  onTap: () => onTap(e),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 26),
        const _Head('الأكثر بحثًا'),
        const SizedBox(height: 10),
        ..._trending.asMap().entries.map(
          (e) => InkWell(
            onTap: () => onTap(e.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: e.key < 3
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: e.key < 3
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(e.value, style: const TextStyle(fontSize: 14)),
                  const Spacer(),
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  final String text;

  const _Head(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _Pill({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textHint),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
