import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';

/// مصادقة حقيقية عبر Supabase Auth (بريد إلكتروني + كلمة مرور).
class AuthRepository {
  const AuthRepository();

  GoTrueClient get _auth => SupabaseService.client.auth;

  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _map(u, null);
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
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    final user = res.user;
    if (user == null) throw const AuthException('تعذّر إنشاء الحساب');
    if (res.session != null) {
      await _upsertProfile(
        id: user.id,
        name: name,
        phone: phone ?? '',
        city: 'القاهرة',
      );
    }
    return _map(user, {'name': name, 'phone': phone, 'city': 'القاهرة'});
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
  }) async {
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': id,
        'name': name,
        'phone': phone,
        'city': city,
        'role': 'customer',
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
