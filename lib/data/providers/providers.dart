import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/admin_repository.dart';
import '../models/address.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/review.dart';
import '../models/vendor.dart';
import '../models/wallet_tx.dart';
import '../remote/auth_repository.dart';
import '../remote/catalog_repository.dart';
import '../remote/seller_repository.dart';
import '../remote/supabase_service.dart';
import '../remote/user_data_repository.dart';
import '../storage/local_store.dart';

const _catalogRepo = CatalogRepository();
const _authRepo = AuthRepository();
const _userRepo = UserDataRepository();
const _sellerRepo = SellerRepository();

/// معرّف المستخدم على السيرفر (null في الوضع المحلي أو قبل تسجيل الدخول).
String? _remoteUserId(Ref ref) => SupabaseService.isReady
    ? SupabaseService.client.auth.currentUser?.id
    : null;

// ─────────────────────────── Catalog ───────────────────────────
class CategoriesNotifier extends Notifier<List<ProductCategory>> {
  @override
  List<ProductCategory> build() {
    _hydrate();
    // نبدأ من صفر: كل الأقسام تُدار من السيرفر (لوحة الأدمن).
    return const [];
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    try {
      final list = await _catalogRepo.fetchCategories();
      if (list.isNotEmpty) state = list;
    } catch (_) {
      // تعذّر الاتصال — نُبقي البيانات المحلية.
    }
  }

  void add(ProductCategory c) => state = [...state, c];
  void rename(String id, String name) => state = [
    for (final c in state)
      if (c.id == id) c.copyWith(name: name) else c,
  ];
  void remove(String id) => state = state.where((c) => c.id != id).toList();
}

final categoriesProvider =
    NotifierProvider<CategoriesNotifier, List<ProductCategory>>(
      CategoriesNotifier.new,
    );

class CatalogNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    _hydrate();
    // نبدأ من صفر: كل المنتجات حقيقية من السيرفر.
    return const [];
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    try {
      final list = await _catalogRepo.fetchProducts();
      if (list.isNotEmpty) state = list;
    } catch (_) {
      // تعذّر الاتصال — نُبقي البيانات المحلية.
    }
  }

  void add(Product p) => state = [p, ...state];
  void update(Product p) => state = [
    for (final x in state)
      if (x.id == p.id) p else x,
  ];
  void remove(String id) => state = state.where((x) => x.id != id).toList();
  void setStock(String id, int stock) => state = [
    for (final x in state)
      if (x.id == id) x.copyWith(stock: stock < 0 ? 0 : stock) else x,
  ];
  void adjustStock(String id, int delta) {
    final p = productById(id);
    if (p != null) setStock(id, p.stock + delta);
  }

  Product? productById(String id) {
    for (final p in state) {
      if (p.id == id) return p;
    }
    return null;
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, List<Product>>(
  CatalogNotifier.new,
);

final flashDealsProvider = Provider<List<Product>>(
  (ref) =>
      ref.watch(catalogProvider).where((p) => p.discountPercent >= 30).toList(),
);

final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final list = ref.watch(catalogProvider);
  for (final p in list) {
    if (p.id == id) return p;
  }
  return null;
});

final productsByCategoryProvider = Provider.family<List<Product>, String>((
  ref,
  catId,
) {
  return ref
      .watch(catalogProvider)
      .where((p) => p.categoryId == catId)
      .toList();
});

final vendorByIdProvider = Provider.family<Vendor?, String>((ref, id) {
  final stores = ref.watch(storesProvider).asData?.value ?? const <Vendor>[];
  for (final v in stores) {
    if (v.id == id) return v;
  }
  return null;
});

final productsByVendorProvider = Provider.family<List<Product>, String>((
  ref,
  id,
) {
  return ref.watch(catalogProvider).where((p) => p.vendor.id == id).toList();
});

// ─────────────────────────── Search ───────────────────────────
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// ─────────────────────────── Shell tab ───────────────────────────
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void select(int index) => state = index;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(
  ShellTabNotifier.new,
);

final searchResultsProvider = Provider<List<Product>>((ref) {
  final q = ref.watch(searchQueryProvider).trim();
  if (q.isEmpty) return const [];
  return ref
      .watch(catalogProvider)
      .where((p) => p.title.contains(q) || p.vendor.name.contains(q))
      .toList();
});

// ─────────────────────────── Auth ───────────────────────────
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    if (!SupabaseService.isReady) {
      // الوضع المحلي: لا بيانات تجريبية — يعمل كزائر.
      return null;
    }
    // مزامنة تلقائية مع تغيّرات جلسة Supabase (Google OAuth / OTP / خروج).
    try {
      final sub = SupabaseService.client.auth.onAuthStateChange.listen((ev) {
        final hasSession = ev.session != null;
        if (hasSession) {
          refreshProfile();
        } else {
          state = null;
        }
      });
      ref.onDispose(sub.cancel);
    } catch (_) {
      // تجاهل: الجلسة تُدار محليًا.
    }
    return _authRepo.currentUser;
  }

  bool get serverMode => SupabaseService.isReady;

  /// تسجيل دخول حقيقي بالبريد الإلكتروني عبر Supabase.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = await _authRepo.signIn(email: email, password: password);
    _reloadUserData();
  }

  /// إنشاء حساب حقيقي عبر Supabase.
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    UserRole role = UserRole.customer,
  }) async {
    state = await _authRepo.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role.name,
    );
    _reloadUserData();
  }

  /// يعيد قراءة الملف الشخصي من السيرفر (مثلًا بعد فتح متجر).
  Future<void> refreshProfile() async {
    if (!SupabaseService.isReady) return;
    state = await _authRepo.currentUserFresh();
    _reloadUserData();
  }

  /// تسجيل الدخول بحساب Google.
  Future<void> signInWithGoogle() async {
    await _authRepo.signInWithGoogle();
  }

  /// إعادة تحميل الجلسة بعد رجوع المستخدم من متصفح Google.
  Future<void> syncFromGoogle() async {
    await refreshProfile();
  }

  Future<void> sendPhoneOtp(String phone) => _authRepo.sendPhoneOtp(phone);

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
    String name = '',
  }) async {
    state = await _authRepo.verifyPhoneOtp(
      phone: phone,
      token: token,
      name: name,
    );
    _reloadUserData();
  }

  /// تفعيل حساب الأدمن بالكود السري (أول أدمن فقط).
  Future<bool> claimAdmin(String code) async {
    if (!SupabaseService.isReady) return false;
    final ok = await _authRepo.claimAdmin(code);
    if (ok) await refreshProfile();
    return ok;
  }

  /// الوضع المحلي (بدون سيرفر): دخول تجريبي.
  void login(String phone) {
    if (SupabaseService.isReady) return;
    state = AppUser(id: 'u2', name: 'عضو جديد', phone: phone, city: 'القاهرة');
  }

  void register({required String name, required String phone, String? email}) {
    if (SupabaseService.isReady) return;
    state = AppUser(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      city: 'القاهرة',
    );
  }

  void resetPassword(String newPassword) {
    // mock: no persistence layer — password reset is a no-op placeholder
  }

  void updateProfile({String? name, String? city}) {
    if (state == null) return;
    state = state!.copyWith(name: name, city: city);
  }

  Future<void> logout() async {
    if (SupabaseService.isReady) await _authRepo.signOut();
    state = null;
    _reloadUserData();
  }

  void _reloadUserData() {
    ref.invalidate(addressesProvider);
    ref.invalidate(cartProvider);
    ref.invalidate(ordersProvider);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

// ─────────────────────────── Wishlist ───────────────────────────
class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final saved = LocalStore.isReady
        ? LocalStore.instance.getStringList(LocalStore.kWishlist)
        : null;
    if (saved != null) return saved.toSet();
    return <String>{};
  }

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    _persist();
  }

  void _persist() {
    if (!LocalStore.isReady) return;
    LocalStore.instance.setStringList(LocalStore.kWishlist, state.toList());
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

final wishlistProductsProvider = Provider<List<Product>>((ref) {
  final ids = ref.watch(wishlistProvider);
  return ref.watch(catalogProvider).where((p) => ids.contains(p.id)).toList();
});

// ─────────────────────────── Cart ───────────────────────────
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    _hydrate();
    if (!LocalStore.isReady) return [];
    final rows = LocalStore.instance.getJsonList(LocalStore.kCart);
    if (rows == null) return [];
    final byId = {for (final p in ref.read(catalogProvider)) p.id: p};
    final restored = <CartItem>[];
    for (final row in rows) {
      final product = byId[row['productId']] ?? _snapshot(row['product']);
      if (product == null) continue; // منتج لم يعد متاحًا — نتجاهل السطر.
      restored.add(
        CartItem(
          product: product,
          quantity: (row['quantity'] as num?)?.toInt() ?? 1,
          color: row['color'] as String?,
          size: row['size'] as String?,
          selected: row['selected'] as bool? ?? true,
        ),
      );
    }
    return restored;
  }

  Future<void> _hydrate() async {
    final uid = _remoteUserId(ref);
    if (uid == null) return;
    try {
      final rows = await _userRepo.fetchCart(uid);
      final byId = {for (final p in ref.read(catalogProvider)) p.id: p};
      final restored = <CartItem>[];
      for (final row in rows) {
        final product = byId[row['product_id']];
        if (product == null) continue;
        restored.add(
          CartItem(
            product: product,
            quantity: (row['quantity'] as num?)?.toInt() ?? 1,
            color: row['color'] as String?,
            size: row['size'] as String?,
            selected: row['selected'] as bool? ?? true,
          ),
        );
      }
      state = restored;
    } catch (_) {
      // تعذّر الاتصال — نُبقي السلة المحلية.
    }
  }

  void _persist() {
    final rows = [
      for (final i in state)
        {
          'productId': i.product.id,
          'product': i.product.toJson(),
          'quantity': i.quantity,
          'color': i.color,
          'size': i.size,
          'selected': i.selected,
        },
    ];
    if (LocalStore.isReady) {
      LocalStore.instance.setJsonList(LocalStore.kCart, rows);
    }
    final uid = _remoteUserId(ref);
    if (uid != null) {
      _userRepo.replaceCart(uid, rows).catchError((_) {});
    }
  }

  bool _sameLine(CartItem a, Product p, String? color, String? size) =>
      a.product.id == p.id && a.color == color && a.size == size;

  Product? _snapshot(Object? raw) {
    if (raw is Map) return Product.fromJson(raw.cast<String, dynamic>());
    return null;
  }

  void add(Product p, {int qty = 1, String? color, String? size}) {
    final index = state.indexWhere((i) => _sameLine(i, p, color, size));
    if (index >= 0) {
      final updated = [...state];
      updated[index].quantity += qty;
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(product: p, quantity: qty, color: color, size: size),
      ];
    }
    _persist();
  }

  void remove(CartItem item) {
    state = state.where((i) => !identical(i, item)).toList();
    _persist();
  }

  void increment(CartItem item) {
    item.quantity++;
    state = [...state];
    _persist();
  }

  void decrement(CartItem item) {
    if (item.quantity <= 1) return remove(item);
    item.quantity--;
    state = [...state];
    _persist();
  }

  void toggleSelect(CartItem item) {
    item.selected = !item.selected;
    state = [...state];
    _persist();
  }

  void toggleAll(bool value) {
    for (final i in state) {
      i.selected = value;
    }
    state = [...state];
    _persist();
  }

  void clearSelected() {
    state = state.where((i) => !i.selected).toList();
    _persist();
  }

  int get itemCount => state.fold(0, (s, i) => s + i.quantity);
  int get selectedCount => state.where((i) => i.selected).length;
  List<CartItem> get selectedItems => state.where((i) => i.selected).toList();

  List<CartGroup> get groups {
    final map = <String, List<CartItem>>{};
    for (final item in state) {
      map.putIfAbsent(item.vendor.id, () => []).add(item);
    }
    return map.entries
        .map((e) => CartGroup(vendor: e.value.first.vendor, items: e.value))
        .toList();
  }

  List<CartGroup> get selectedGroups {
    final map = <String, List<CartItem>>{};
    for (final item in selectedItems) {
      map.putIfAbsent(item.vendor.id, () => []).add(item);
    }
    return map.entries
        .map((e) => CartGroup(vendor: e.value.first.vendor, items: e.value))
        .toList();
  }

  double get selectedSubtotal =>
      selectedItems.fold(0.0, (s, i) => s + i.lineTotal);
  double get selectedQty => selectedItems.fold(0.0, (s, i) => s + i.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

// ─────────────────────────── Addresses ───────────────────────────
class AddressesNotifier extends Notifier<List<Address>> {
  @override
  List<Address> build() {
    _hydrate();
    if (!LocalStore.isReady) return const [];
    final rows = LocalStore.instance.getJsonList(LocalStore.kAddresses);
    if (rows == null) return const [];
    return rows.map(Address.fromJson).toList();
  }

  Future<void> _hydrate() async {
    final uid = _remoteUserId(ref);
    if (uid == null) return;
    try {
      state = await _userRepo.fetchAddresses(uid);
    } catch (_) {
      // تعذّر الاتصال — نُبقي البيانات المحلية.
    }
  }

  void _fire(Future<void> Function() action) {
    action().catchError((_) {});
  }

  void _persist() {
    if (!LocalStore.isReady) return;
    LocalStore.instance.setJsonList(LocalStore.kAddresses, [
      for (final a in state) a.toJson(),
    ]);
  }

  void add(Address a) {
    final list = [...state];
    final isFirst = list.isEmpty;
    if (a.isDefault || isFirst) {
      for (var i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(isDefault: false);
      }
    }
    list.add(a.isDefault || isFirst ? a.copyWith(isDefault: true) : a);
    state = list;
    _persist();
    final uid = _remoteUserId(ref);
    if (uid != null) _fire(() => _userRepo.saveAddress(uid, list.last));
  }

  void setDefault(String id) {
    state = [for (final a in state) a.copyWith(isDefault: a.id == id)];
    _persist();
    final uid = _remoteUserId(ref);
    if (uid != null) _fire(() => _userRepo.setDefaultAddress(uid, id));
  }

  void remove(String id) {
    final wasDefault = state.any((a) => a.id == id && a.isDefault);
    var list = state.where((a) => a.id != id).toList();
    if (wasDefault && list.isNotEmpty) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    state = list;
    _persist();
    final uid = _remoteUserId(ref);
    if (uid != null) _fire(() => _userRepo.deleteAddress(id));
  }

  Address? get defaultAddress {
    for (final a in state) {
      if (a.isDefault) return a;
    }
    return state.isEmpty ? null : state.first;
  }
}

final addressesProvider = NotifierProvider<AddressesNotifier, List<Address>>(
  AddressesNotifier.new,
);

final defaultAddressProvider = Provider<Address?>(
  (ref) => ref.watch(addressesProvider.notifier).defaultAddress,
);

// ─────────────────────────── Payment methods ───────────────────────────
// حاليًا: الدفع عند الاستلام فقط (حقيقي). الدفع الإلكتروني يحتاج بوابة دفع.
final paymentMethodsProvider = Provider<List<PaymentMethod>>(
  (ref) => const [
    PaymentMethod(
      id: 'cod',
      type: PaymentType.cod,
      label: 'الدفع عند الاستلام',
      isDefault: true,
    ),
  ],
);

// ─────────────────────────── Coupons ───────────────────────────
class CouponsNotifier extends Notifier<List<Coupon>> {
  @override
  List<Coupon> build() => const [];

  Coupon? findByCode(String code) {
    final c = code.trim().toUpperCase();
    for (final coupon in state) {
      if (coupon.code == c) return coupon;
    }
    return null;
  }

  void add(Coupon coupon) => state = [coupon, ...state];
  void remove(String code) =>
      state = state.where((c) => c.code != code).toList();
}

final couponsProvider = NotifierProvider<CouponsNotifier, List<Coupon>>(
  CouponsNotifier.new,
);

// ─────────────────────────── Reviews ───────────────────────────
class ReviewsNotifier extends Notifier<Map<String, List<Review>>> {
  @override
  Map<String, List<Review>> build() {
    // المراجعات تُبنى من السيرفر لاحقًا؛ نبدأ من صفر.
    return const <String, List<Review>>{};
  }

  void add(Review review) {
    final next = {...state};
    next[review.productId] = [review, ...(next[review.productId] ?? [])];
    state = next;
  }

  List<Review> forProduct(String id) => state[id] ?? const [];

  double? averageFor(String id) {
    final list = state[id];
    if (list == null || list.isEmpty) return null;
    return list.fold<int>(0, (s, r) => s + r.rating) / list.length;
  }
}

final reviewsProvider =
    NotifierProvider<ReviewsNotifier, Map<String, List<Review>>>(
      ReviewsNotifier.new,
    );

// ─────────────────────────── Notifications ───────────────────────────
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => const [];

  int get unread => state.where((n) => !n.read).length;

  void markAllRead() => state = [for (final n in state) n.copyWith(read: true)];

  void markRead(String id) =>
      state = [for (final n in state) n.id == id ? n.copyWith(read: true) : n];
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

// ─────────────────────────── Orders ───────────────────────────
class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    _hydrate();
    if (!LocalStore.isReady) return const [];
    final rows = LocalStore.instance.getJsonList(LocalStore.kOrders);
    if (rows == null) return const [];
    return rows.map(Order.fromJson).toList();
  }

  Future<void> _hydrate() async {
    final uid = _remoteUserId(ref);
    if (uid == null) return;
    try {
      final list = await _userRepo.fetchOrders(uid);
      if (list.isNotEmpty) state = list;
    } catch (_) {
      // تعذّر الاتصال — نُبقي الطلبات المحلية.
    }
  }

  void _persist() {
    if (!LocalStore.isReady) return;
    LocalStore.instance.setJsonList(LocalStore.kOrders, [
      for (final o in state) o.toJson(),
    ]);
  }

  Order? byId(String id) {
    for (final o in state) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// ينشئ طلبًا حقيقيًا من عناصر السلة المختارة (مقسّم حسب المتجر).
  Order place({
    required List<CartItem> items,
    required double shipping,
    required double discount,
    required String addressSummary,
    required String paymentLabel,
  }) {
    final subtotal = items.fold(0.0, (s, i) => s + i.lineTotal);
    final byVendor = <String, List<CartItem>>{};
    for (final i in items) {
      byVendor.putIfAbsent(i.vendor.id, () => []).add(i);
    }

    final shipments = byVendor.values.map((lines) {
      final amount = lines.fold(0.0, (s, i) => s + i.lineTotal);
      return OrderShipment(
        vendorId: lines.first.vendor.id,
        vendorName: lines.first.vendor.name,
        vendorAvatar: lines.first.vendor.avatarUrl,
        status: OrderStatus.processing,
        itemTitles: lines.map((e) => e.product.title).toList(),
        productIds: lines.map((e) => e.product.id).toList(),
        itemCount: lines.fold(0, (s, i) => s + i.quantity),
        amount: amount,
        trackingNo: 'SP${DateTime.now().millisecondsSinceEpoch % 100000000}',
      );
    }).toList();

    final order = Order(
      id: 'XP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      date: DateTime.now(),
      shipments: shipments,
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      total: subtotal + shipping - discount,
      addressSummary: addressSummary,
      paymentLabel: paymentLabel,
      escrowHeld: true,
    );

    state = [order, ...state];
    _persist();
    final uid = _remoteUserId(ref);
    if (uid != null) {
      final customerName = ref.read(authProvider)?.name ?? '';
      _userRepo
          .insertOrder(uid, order, customerName: customerName)
          .catchError((_) {});
    }
    return order;
  }

  void confirmReceipt(Order order) {
    final index = state.indexWhere((o) => o.id == order.id);
    if (index < 0) return;
    final updated = [...state];
    updated[index].escrowHeld = false;
    state = updated;
    _persist();
    if (SupabaseService.isReady) {
      _userRepo.updateOrder(updated[index]).catchError((_) {});
    }
  }

  void markReviewed(Order order) {
    final index = state.indexWhere((o) => o.id == order.id);
    if (index < 0) return;
    final updated = [...state];
    updated[index].reviewed = true;
    state = updated;
    _persist();
    if (SupabaseService.isReady) {
      _userRepo.updateOrder(updated[index]).catchError((_) {});
    }
  }

  /// إجراء خاص بلوحة التحكم: تحديث حالة شحنة معينة داخل الطلب.
  void setShipmentStatus(
    String orderId,
    int shipmentIndex,
    OrderStatus status,
  ) {
    final index = state.indexWhere((o) => o.id == orderId);
    if (index < 0) return;
    final order = state[index];
    if (shipmentIndex < 0 || shipmentIndex >= order.shipments.length) return;
    final shipments = [...order.shipments];
    shipments[shipmentIndex] = shipments[shipmentIndex].copyWith(
      status: status,
    );
    final updated = [...state];
    updated[index] = Order(
      id: order.id,
      date: order.date,
      shipments: shipments,
      total: order.total,
      subtotal: order.subtotal,
      shipping: order.shipping,
      discount: order.discount,
      addressSummary: order.addressSummary,
      paymentLabel: order.paymentLabel,
      escrowHeld: order.escrowHeld,
      reviewed: order.reviewed,
    );
    state = updated;
    _persist();
    if (SupabaseService.isReady) {
      _userRepo.updateOrder(updated[index]).catchError((_) {});
    }
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

final orderByIdProvider = Provider.family<Order?, String>((ref, id) {
  final orders = ref.watch(ordersProvider);
  for (final o in orders) {
    if (o.id == id) return o;
  }
  return null;
});

// ─────────────────────────── Wallet ───────────────────────────
class WalletState {
  final double available;
  final double held;
  final List<WalletTransaction> transactions;

  const WalletState({
    required this.available,
    required this.held,
    required this.transactions,
  });
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() =>
      const WalletState(available: 0, held: 0, transactions: []);

  void deposit(double amount) {
    state = WalletState(
      available: state.available + amount,
      held: state.held,
      transactions: [
        WalletTransaction(
          id: 'w${DateTime.now().millisecondsSinceEpoch}',
          type: WalletTxType.topup,
          title: 'إيداع في المحفظة',
          amount: amount,
          date: DateTime.now(),
        ),
        ...state.transactions,
      ],
    );
  }

  void withdraw(double amount) {
    if (amount > state.available) return;
    state = WalletState(
      available: state.available - amount,
      held: state.held,
      transactions: [
        WalletTransaction(
          id: 'w${DateTime.now().millisecondsSinceEpoch}',
          type: WalletTxType.withdraw,
          title: 'سحب من المحفظة',
          amount: -amount,
          date: DateTime.now(),
        ),
        ...state.transactions,
      ],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);

// ─────────────────────────── Seller (لوحة البائع) ───────────────────────────
final sellerRepositoryProvider = Provider<SellerRepository>(
  (ref) => _sellerRepo,
);

/// المتجر الخاص بالمستخدم الحالي (null إن لم يكن بائعًا بعد).
class MyStoreNotifier extends AsyncNotifier<Vendor?> {
  @override
  Future<Vendor?> build() async {
    final uid = _remoteUserId(ref);
    if (uid == null) return null;
    return _sellerRepo.myStore(uid);
  }

  Future<Vendor?> createStore({
    required String name,
    String category = '',
    String description = '',
    String phone = '',
  }) async {
    final uid = _remoteUserId(ref);
    if (uid == null) throw Exception('سجّل الدخول أولًا');
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => _sellerRepo.createStore(
        userId: uid,
        name: name,
        category: category,
        description: description,
        phone: phone,
      ),
    );
    state = result;
    await ref.read(authProvider.notifier).refreshProfile();
    return result.asData?.value;
  }
}

final myStoreProvider = AsyncNotifierProvider<MyStoreNotifier, Vendor?>(
  MyStoreNotifier.new,
);

/// منتجات متجر المستخدم الحالي.
final myProductsProvider = FutureProvider<List<Product>>((ref) async {
  final store = await ref.watch(myStoreProvider.future);
  if (store == null) return const [];
  return _sellerRepo.myProducts(store.id);
});

/// الطلبات الواردة لمتجر المستخدم الحالي.
final incomingOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final store = await ref.watch(myStoreProvider.future);
  if (store == null) return const [];
  return _sellerRepo.incomingOrders(store.id);
});

// ─────────────────────────── Storefronts (المتاجر المعتمدة) ───────────────────────────
/// قائمة المتاجر المرئية للجميع (المعتمدة فقط تظهر للزوار حسب RLS).
class StoresNotifier extends AsyncNotifier<List<Vendor>> {
  @override
  Future<List<Vendor>> build() async {
    if (!SupabaseService.isReady) return const [];
    try {
      final rows = await _catalogRepo.fetchStores();
      return rows;
    } catch (_) {
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!SupabaseService.isReady) return const <Vendor>[];
      return _catalogRepo.fetchStores();
    });
  }
}

final storesProvider = AsyncNotifierProvider<StoresNotifier, List<Vendor>>(
  StoresNotifier.new,
);

/// المتاجر المعتمدة فقط (يُستخدم في واجهة العملاء).
final approvedStoresProvider = Provider<List<Vendor>>((ref) {
  final stores = ref.watch(storesProvider).asData?.value ?? const <Vendor>[];
  return stores.where((s) => s.isApproved).toList();
});

// ─────────────────────────── Admin (لوحة الأدمن) ───────────────────────────
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => const AdminRepository(),
);

/// هل المستخدم الحالي أدمن؟
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(authProvider)?.isAdmin ?? false,
);

/// طلبات المتاجر بانتظار موافقة الأدمن.
final pendingStoresProvider = FutureProvider<List<Vendor>>((ref) async {
  if (!SupabaseService.isReady) return const [];
  if (!(ref.watch(authProvider)?.isAdmin ?? false)) return const [];
  return ref.watch(adminRepositoryProvider).pendingStores();
});

/// كل المتاجر (للأدمن).
final allStoresProvider = FutureProvider<List<Vendor>>((ref) async {
  if (!SupabaseService.isReady) return const [];
  if (!(ref.watch(authProvider)?.isAdmin ?? false)) return const [];
  return ref.watch(adminRepositoryProvider).allStores();
});

/// كل المنتجات (للأدمن).
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  if (!SupabaseService.isReady) return const [];
  if (!(ref.watch(authProvider)?.isAdmin ?? false)) return const [];
  return ref.watch(adminRepositoryProvider).allProducts();
});

/// كل المستخدمين (للأدمن).
final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  if (!SupabaseService.isReady) return const [];
  if (!(ref.watch(authProvider)?.isAdmin ?? false)) return const [];
  return ref.watch(adminRepositoryProvider).allUsers();
});

/// إحصاءات لوحة الأدمن.
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  if (!SupabaseService.isReady) return const {};
  if (!(ref.watch(authProvider)?.isAdmin ?? false)) return const {};
  return ref.watch(adminRepositoryProvider).stats();
});
