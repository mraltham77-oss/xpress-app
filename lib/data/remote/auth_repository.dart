import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';

/// يرمى عند إنشاء حساب يحتاج تأكيد البريد الإلكتروني قبل تسجيل الدخول.
class EmailConfirmationRequired implements Exception {
  const EmailConfirmationRequired();

  @override
  String toString() =>
      'تم إنشاء حسابك. افتح بريدك الإلكتروني وأكّد الرسالة ثم سجّل الدخول.';
}

/// مصادقة حقيقية عبر Supabase Auth (بريد إلكتروني + كلمة مرور).
class AuthRepository {
  const AuthRepository();

  GoTrueClient get _auth => SupabaseService.client.auth;

  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _map(u, null);
  }

  /// يقرأ ملف المستخدم الحالي من قاعدة البيانات (يشمل الدور/الاسم المحدّث).
  Future<AppUser?> currentUserFresh() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final profile = await _fetchProfile(u.id);
    return _map(u, profile);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw const AuthException('تعذّر تسجيل الدخول');
    final profile = await _fetchProfile(user.id);
    return _map(user, profile);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'customer',
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone, 'role': role},
    );
    final user = res.user;
    if (user == null) throw const AuthException('تعذّر إنشاء الحساب');
    if (res.session == null) {
      // الحساب اتّعمل، لكن Supabase بيطلب تأكيد البريد قبل الدخول.
      throw const EmailConfirmationRequired();
    }
    await _upsertProfile(
      id: user.id,
      name: name,
      phone: phone ?? '',
      city: 'القاهرة',
      role: role,
    );
    return _map(user, {
      'name': name,
      'phone': phone,
      'city': 'القاهرة',
      'role': role,
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<Map<String, dynamic>?> _fetchProfile(String id) async {
    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      return row;
    } catch (_) {
      return null;
    }
  }

  Future<void> _upsertProfile({
    required String id,
    required String name,
    required String phone,
    required String city,
    String role = 'customer',
  }) async {
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': id,
        'name': name,
        'phone': phone,
        'city': city,
        'role': role,
      });
    } catch (_) {
      // الجدول قد يُدار عبر Trigger — نتجاهل الفشل غير الحرج.
    }
  }

  AppUser _map(User u, Map<String, dynamic>? profile) {
    final meta = u.userMetadata ?? const <String, dynamic>{};
    final email = u.email;
    final name =
        (profile?['name'] ??
                meta['name'] ??
                email?.split('@').first ??
                'مستخدم')
            .toString();
    final phone = (profile?['phone'] ?? meta['phone'] ?? '').toString();
    final city = (profile?['city'] ?? 'القاهرة').toString();
    final roleStr = (profile?['role'] ?? 'customer').toString();
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.customer,
    );
    return AppUser(
      id: u.id,
      name: name,
      phone: phone,
      email: email,
      city: city,
      role: role,
    );
  }
}
