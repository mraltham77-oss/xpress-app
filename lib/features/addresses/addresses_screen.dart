import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/address.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('عناوين التوصيل'),
      ),
      body: addresses.isEmpty
          ? const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'لا توجد عناوين محفوظة',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Gap.md),
              itemCount: addresses.length,
              itemBuilder: (context, i) => _AddressCard(address: addresses[i]),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddressSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة عنوان جديد'),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final Address address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addressesProvider.notifier);
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 1.4)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                address.label == 'العمل'
                    ? Icons.work_outline_rounded
                    : Icons.home_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                address.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'الافتراضي',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          const SizedBox(height: 3),
          Text(
            address.summary,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          if (address.details.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address.details,
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Gap.md),
          const Divider(),
          const SizedBox(height: Gap.sm),
          Row(
            children: [
              if (!address.isDefault)
                TextButton(
                  onPressed: () => notifier.setDefault(address.id),
                  child: const Text('تعيين كافتراضي'),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => notifier.remove(address.id),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddressSheet(BuildContext context, WidgetRef ref) {
  final label = TextEditingController(text: 'المنزل');
  final name = TextEditingController();
  final phone = TextEditingController(text: '+966 5');
  final city = TextEditingController(text: 'القاهرة');
  final district = TextEditingController();
  final street = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: Gap.lg),
              const Text(
                'إضافة عنوان جديد',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: Gap.lg),
              _field(label, 'التسمية (المنزل/العمل)'),
              _field(name, 'الاسم بالكامل'),
              _field(phone, 'رقم الجوال', keyboard: TextInputType.phone),
              _field(city, 'المدينة'),
              _field(district, 'الحي'),
              _field(street, 'الشارع'),
              const SizedBox(height: Gap.lg),
              ElevatedButton(
                onPressed: () {
                  if (name.text.isEmpty || street.text.isEmpty) return;
                  ref
                      .read(addressesProvider.notifier)
                      .add(
                        Address(
                          id: 'a${DateTime.now().millisecondsSinceEpoch}',
                          label: label.text.isEmpty ? 'عنوان' : label.text,
                          fullName: name.text,
                          phone: phone.text,
                          city: city.text,
                          district: district.text,
                          street: street.text,
                        ),
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ العنوان'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _field(TextEditingController c, String hint, {TextInputType? keyboard}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: Gap.md),
    child: TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(hintText: hint),
    ),
  );
}
