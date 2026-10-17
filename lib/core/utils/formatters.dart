import 'package:intl/intl.dart';

import '../constants/strings_ar.dart';

class Money {
  Money._();

  static final NumberFormat _nf = NumberFormat.decimalPattern('en');

  /// 12,345 ج.م (formatting wrapped in AppStrings.currency)
  static String format(num amount) {
    final v = amount == amount.roundToDouble() ? amount.round() : amount;
    return '${_nf.format(v)} ${AppStrings.currency}';
  }

  static String raw(num amount) {
    final v = amount == amount.roundToDouble() ? amount.round() : amount;
    return _nf.format(v);
  }
}

class AppDate {
  AppDate._();

  static final DateFormat _d = DateFormat('d MMM yyyy', 'ar');

  static String short(DateTime date) => _d.format(date);

  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'قبل ${diff.inDays} يوم';
    return short(date);
  }
}
