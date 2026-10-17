/// إعدادات الاتصال بسيرفر Supabase (مجاني).
///
/// لا تُحفظ المفاتيح في الكود إطلاقًا. تُمرَّر وقت البناء/التشغيل عبر
/// `--dart-define`:
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
/// ```
///
/// إذا لم تُمرَّر، يعمل التطبيق في الوضع المحلي (بيانات تجريبية) تلقائيًا.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
