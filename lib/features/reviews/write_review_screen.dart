import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/review.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String productId;
  final String orderId;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    this.orderId = '',
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  final _tags = <String>{};

  static const _quickTags = [
    'جودة ممتازة',
    'وصل بسرعة',
    'مطابق للوصف',
    'سعر مناسب',
    'تغليف جيد',
    'أنصح به',
  ];

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final user = ref.read(authProvider);
    ref
        .read(reviewsProvider.notifier)
        .add(
          Review(
            id: 'r${DateTime.now().millisecondsSinceEpoch}',
            productId: widget.productId,
            userName: user?.name ?? 'مستخدم XPRESS',
            rating: _rating,
            comment: _comment.text.trim().isEmpty
                ? (_tags.isEmpty ? 'تجربة ممتازة' : _tags.join('، '))
                : _comment.text.trim(),
            date: DateTime.now(),
          ),
        );

    final order = widget.orderId.isEmpty
        ? null
        : ref.read(ordersProvider.notifier).byId(widget.orderId);
    if (order != null) ref.read(ordersProvider.notifier).markReviewed(order);

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شكرًا! تم نشر تقييمك ⭐'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('تقييم المنتج'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.xl),
        children: [
          if (product != null)
            Row(
              children: [
                NetImage(
                  url: product.images.first,
                  width: 56,
                  height: 56,
                  radius: 12,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: Gap.xl),
          const Center(
            child: Text(
              'كيف تقيّم المنتج؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: Gap.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: AnimatedScale(
                  scale: filled ? 1.15 : 1,
                  duration: Motion.fast,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 44,
                      color: filled ? AppColors.gold : AppColors.textHint,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: Gap.sm),
          Center(
            child: Text(
              _rating == 0
                  ? 'اضغط للتقييم'
                  : ['سيء', 'مقبول', 'جيد', 'جيد جدًا', 'ممتاز'][_rating - 1],
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: Gap.xl),
          const Text(
            'ما الذي أعجبك؟',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: _quickTags.map((t) {
              final selected = _tags.contains(t);
              return GestureDetector(
                onTap: () =>
                    setState(() => selected ? _tags.remove(t) : _tags.add(t)),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primarySoft
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Gap.xl),
          const Text(
            'اكتب مراجعتك (اختياري)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: Gap.md),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'شاركنا رأيك بالتفصيل...',
            ),
          ),
          const SizedBox(height: Gap.lg),
          ElevatedButton(
            onPressed: _rating == 0 || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text('نشر التقييم'),
          ),
        ],
      ),
    );
  }
}
