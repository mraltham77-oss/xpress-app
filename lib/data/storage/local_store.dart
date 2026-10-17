import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// تخزين محلي بسيط فوق SharedPreferences لحفظ حالة المستخدم بين الجلسات.
///
/// الاستخدام الآمن: يُهيّأ مرة واحدة في `main()` عبر [init]. تتجاهل الطبقات
/// الأعلى الحفظ إذا لم يكن جاهزًا ([isReady]) — وهذا مهم في الاختبارات.
class LocalStore {
  LocalStore._(this._prefs);

  final SharedPreferences _prefs;

  static LocalStore? _instance;

  static LocalStore get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'LocalStore غير مُهيّأ. استدعِ LocalStore.init() في main().',
      );
    }
    return i;
  }

  static bool get isReady => _instance != null;

  static Future<LocalStore> init() async {
    final prefs = await SharedPreferences.getInstance();
    return _instance ??= LocalStore._(prefs);
  }

  // مفاتيح التخزين (مُصدّرة بإصدار لتسهيل الترقية لاحقًا).
  static const String kCart = 'xp_cart_v1';
  static const String kOrders = 'xp_orders_v1';
  static const String kWishlist = 'xp_wishlist_v1';
  static const String kAddresses = 'xp_addresses_v1';

  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    } catch (_) {
      // بيانات تالفة/قديمة — نتجاهلها ونبدأ من جديد.
    }
    return null;
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));
}
