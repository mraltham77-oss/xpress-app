import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';

class NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  const NetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback = Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1927), Color(0xFF12101C)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.textHint, size: 28),
      ),
    );

    final child = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 320),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
      ),
      errorWidget: (_, _, _) => fallback,
    );

    if (radius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }
    return child;
  }
}

/// سعر بشكل احترافي: الرقم كبير + رمز العملة + سعر قديم مشطوب + شارة خصم.
class PriceTag extends StatelessWidget {
  final double price;
  final double? oldPrice;
  final double fontSize;
  final Color color;

  const PriceTag({
    super.key,
    required this.price,
    this.oldPrice,
    this.fontSize = 15,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            Money.raw(price),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: fontSize + 3,
              height: 1,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            AppStrings.currency,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize - 3,
              height: 1,
            ),
          ),
          if (oldPrice != null) ...[
            const SizedBox(width: 6),
            Text(
              Money.raw(oldPrice!),
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: fontSize - 4,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;
  final int? reviews;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 13,
    this.showValue = true,
    this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.gold, size: size + 3),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        if (reviews != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviews)',
            style: TextStyle(fontSize: size - 1, color: AppColors.textHint),
          ),
        ],
      ],
    );
  }
}

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final double size;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, onDecrement),
          Container(
            constraints: BoxConstraints(minWidth: size * 1.7),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          _button(Icons.add_rounded, onIncrement),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: size - 4, color: AppColors.textPrimary),
      ),
    );
  }
}

/// عنوان قسم موحّد: أيقونة ملوّنة + عنوان + زر "عرض الكل".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final IconData? leadingIcon;
  final Color? accent;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.leadingIcon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.md),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(leadingIcon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, size: 18, color: color),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final IconData? icon;
  final double fontSize;

  const PillBadge({
    super.key,
    required this.text,
    this.color = AppColors.primary,
    this.background = AppColors.primarySoft,
    this.icon,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: Gap.xl),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Gap.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Gap.xl),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
