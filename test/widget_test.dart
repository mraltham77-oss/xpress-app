import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souqi/data/mock/mock_data.dart';
import 'package:souqi/data/providers/providers.dart';

void main() {
  group('CartNotifier', () {
    test('adds items and groups them by vendor', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);
      notifier.add(MockData.products[0], qty: 2);
      notifier.add(MockData.products[1]);

      expect(container.read(cartProvider).length, 2);
      expect(notifier.itemCount, 3);
      expect(notifier.groups.length, 2);
      expect(notifier.selectedSubtotal,
          MockData.products[0].price * 2 + MockData.products[1].price);
    });

    test('merges identical lines into one', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);
      notifier.add(MockData.products[0], color: 'أسود');
      notifier.add(MockData.products[0], color: 'أسود');

      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartProvider).first.quantity, 2);
    });

    test('decrement removes item when quantity reaches one', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);
      notifier.add(MockData.products[0]);
      final item = container.read(cartProvider).first;
      notifier.decrement(item);

      expect(container.read(cartProvider), isEmpty);
    });
  });
}
