import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// هيكل تحميل ناعم متحرك (shimmer) بدل الدوران التقليدي.
class Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const Shimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: AlignmentDirectional(_c.value * 2 - 1, 0),
              end: AlignmentDirectional(_c.value * 2 + 1, 0),
              colors: const [
                Color(0xFF1C1927),
                Color(0xFF2A2540),
                Color(0xFF1C1927),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// بطاقة منتج وهمية أثناء التحميل.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: Shimmer(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Shimmer(width: double.infinity, height: 12),
                SizedBox(height: 8),
                Shimmer(width: 120, height: 12),
                SizedBox(height: 12),
                Shimmer(width: 80, height: 16),
                SizedBox(height: 8),
                Shimmer(width: 60, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
