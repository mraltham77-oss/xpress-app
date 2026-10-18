import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

/// حماية عامة: أي استثناء أثناء بناء أي واجهة يُعرض كشاشة واضحة
/// بدل تجميد التطبيق أو ظهور شاشة رمادية/سوداء بلا سبب.
void installErrorGuard() {
  ErrorWidget.builder = (FlutterErrorDetails details) => _ErrorPanel(details);
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[XPRESS ERROR] ${details.exceptionAsString()}');
  };
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel(this.details);

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A0A12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Color(0xFFFF2E93)),
                  SizedBox(width: 8),
                  Text(
                    'حدثت مشكلة في هذه الشاشة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'التطبيق يعمل. هذه تفاصيل الخطأ لتسهيل الإصلاح:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                details.exceptionAsString(),
                style: const TextStyle(
                  color: Color(0xFFFFB4D2),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              if (details.context != null) ...[
                const SizedBox(height: 10),
                SelectableText(
                  'السياق: ${details.context}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
