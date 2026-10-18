import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// نقطة الوصول الوحيدة لعميل Supabase.
///
/// [init] يُستدعى مرة واحدة في `main()`. إذا لم تُضبط الإعدادات
/// ([SupabaseService.isReady] == false) يتجاهل التطبيق السيرفر ويعمل محليًا.
class SupabaseService {
  SupabaseService._();

  static bool _ready = false;
  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      if (SupabaseConfig.anonKey.startsWith('eyJ')) {
        // مفتاح anon القديم (JWT).
        await Supabase.initialize(
          url: SupabaseConfig.url,
          // ignore: deprecated_member_use
          anonKey: SupabaseConfig.anonKey,
        );
      } else {
        // مفتاح publishable الجديد (sb_publishable_...).
        await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.anonKey,
        );
      }
      _ready = true;
    } catch (_) {
      // أي فشل (شبكة/إعدادات) لا يمنع فتح التطبيق: نكمل بالوضع المحلي.
      _ready = false;
    }
  }
}
