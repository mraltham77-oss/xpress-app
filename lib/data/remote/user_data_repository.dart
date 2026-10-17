import '../models/address.dart';
import '../models/order_model.dart';
import 'supabase_service.dart';

/// CRUD لبيانات المستخدم الخاصة على Supabase: العناوين، السلة، الطلبات.
class UserDataRepository {
  const UserDataRepository();

  // ─────────────────────────── Addresses ───────────────────────────
  Future<List<Address>> fetchAddresses(String userId) async {
    final rows = await SupabaseService.client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return rows
        .map<Address>((r) => _address((r as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveAddress(String userId, Address a) async {
    await SupabaseService.client.from('addresses').upsert({
      'id': a.id,
      'user_id': userId,
      'label': a.label,
      'full_name': a.fullName,
      'phone': a.phone,
      'city': a.city,
      'district': a.district,
      'street': a.street,
      'details': a.details,
      'is_default': a.isDefault,
    });
  }

  Future<void> deleteAddress(String id) =>
      SupabaseService.client.from('addresses').delete().eq('id', id);

  Future<void> setDefaultAddress(String userId, String id) async {
    final client = SupabaseService.client;
    await client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    await client.from('addresses').update({'is_default': true}).eq('id', id);
  }

  // ─────────────────────────── Cart ───────────────────────────
  Future<List<Map<String, dynamic>>> fetchCart(String userId) async {
    final rows = await SupabaseService.client
        .from('cart_items')
        .select()
        .eq('user_id', userId);
    return rows.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  Future<void> replaceCart(
    String userId,
    List<Map<String, dynamic>> lines,
  ) async {
    final client = SupabaseService.client;
    await client.from('cart_items').delete().eq('user_id', userId);
    if (lines.isEmpty) return;
    await client.from('cart_items').insert([
      for (final l in lines)
        {
          'user_id': userId,
          'product_id': l['productId'],
          'quantity': l['quantity'],
          'color': l['color'],
          'size': l['size'],
          'selected': l['selected'],
        },
    ]);
  }

  // ─────────────────────────── Orders ───────────────────────────
  Future<List<Order>> fetchOrders(String userId) async {
    final rows = await SupabaseService.client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return rows
        .map<Order>(
          (r) => orderFromRemoteRow((r as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<void> insertOrder(
    String userId,
    Order o, {
    String customerName = '',
  }) async {
    final storeIds = o.shipments
        .map((s) => s.vendorId)
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    await SupabaseService.client.from('orders').insert({
      'id': o.id,
      'user_id': userId,
      'date': o.date.toIso8601String(),
      'shipments': o.shipments.map((s) => s.toJson()).toList(),
      'total': o.total,
      'subtotal': o.subtotal,
      'shipping': o.shipping,
      'discount': o.discount,
      'address_summary': o.addressSummary,
      'payment_label': o.paymentLabel,
      'escrow_held': o.escrowHeld,
      'reviewed': o.reviewed,
      'store_ids': storeIds,
      'customer_name': customerName,
    });
  }

  Future<void> updateOrder(Order o) async {
    await SupabaseService.client
        .from('orders')
        .update({
          'shipments': o.shipments.map((s) => s.toJson()).toList(),
          'escrow_held': o.escrowHeld,
          'reviewed': o.reviewed,
        })
        .eq('id', o.id);
  }

  Address _address(Map<String, dynamic> r) => Address(
    id: r['id'] as String,
    label: r['label'] as String? ?? '',
    fullName: r['full_name'] as String? ?? '',
    phone: r['phone'] as String? ?? '',
    city: r['city'] as String? ?? '',
    district: r['district'] as String? ?? '',
    street: r['street'] as String? ?? '',
    details: r['details'] as String? ?? '',
    isDefault: r['is_default'] as bool? ?? false,
  );
}
