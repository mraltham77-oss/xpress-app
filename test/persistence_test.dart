import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:souqi/data/mock/mock_data.dart';
import 'package:souqi/data/models/cart_item.dart';
import 'package:souqi/data/models/order_model.dart';
import 'package:souqi/data/providers/providers.dart';
import 'package:souqi/data/storage/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.init();
  });

  test('cart persists and is restored in a new session', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final product = MockData.products.first;
    container.read(cartProvider.notifier).add(product, qty: 2);

    // التخزين الفعلي كُتب.
    expect(LocalStore.instance.getJsonList(LocalStore.kCart), isNotNull);

    // جلسة جديدة (حاوية جديدة) تُعيد بناء السلة من التخزين.
    final restored = ProviderContainer();
    addTearDown(restored.dispose);
    final items = restored.read(cartProvider);
    expect(items.length, 1);
    expect(items.first.product.id, product.id);
    expect(items.first.quantity, 2);
  });

  test('wishlist persists across sessions', () {
    final c1 = ProviderContainer();
    addTearDown(c1.dispose);
    c1.read(wishlistProvider.notifier).toggle('p1');

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    expect(c2.read(wishlistProvider), contains('p1'));
  });

  test('orders persist and restore with shipments', () {
    final c1 = ProviderContainer();
    addTearDown(c1.dispose);
    final product = MockData.products.first;
    final order = c1
        .read(ordersProvider.notifier)
        .place(
          items: [CartItem(product: product, quantity: 1)],
          shipping: 12,
          discount: 5,
          addressSummary: 'القاهرة — مدينة نصر',
          paymentLabel: 'الدفع عند الاستلام',
        );

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    final restored = c2
        .read(ordersProvider)
        .firstWhere((o) => o.id == order.id);
    expect(restored.id, order.id);
    expect(restored.paymentLabel, 'الدفع عند الاستلام');
    expect(restored.shipments, isNotEmpty);
    expect(restored.shipments.first.status, OrderStatus.processing);
  });
}
