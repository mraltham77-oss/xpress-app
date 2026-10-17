import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/wallet_tx.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: const Color(0xFF1B2A4A),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              AppStrings.myWallet,
              style: TextStyle(color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.walletGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.availableBalance,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        Money.format(wallet.available),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_clock_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${AppStrings.heldAmount}: ${Money.format(wallet.held)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openAmountSheet(context, ref, isDeposit: true),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(AppStrings.deposit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openAmountSheet(context, ref, isDeposit: false),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 20),
                      label: const Text(AppStrings.withdraw),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.escrowDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'يتم الإفراج عن مبلغ البائع بعد تأكيدك استلام الطلب',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: AppStrings.recentTransactions,
              leadingIcon: Icons.receipt_long_rounded,
            ),
          ),
          SliverList.separated(
            itemCount: wallet.transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 60),
            itemBuilder: (context, i) => _TxTile(tx: wallet.transactions[i]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final WalletTransaction tx;

  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _icon(tx.type);
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppDate.relative(tx.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${tx.isCredit ? '+' : ''}${Money.raw(tx.amount)} ${AppStrings.currency}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: tx.isCredit ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _icon(WalletTxType t) {
    switch (t) {
      case WalletTxType.hold:
        return (Icons.lock_clock_rounded, AppColors.warning);
      case WalletTxType.release:
        return (Icons.lock_open_rounded, AppColors.info);
      case WalletTxType.topup:
        return (Icons.add_circle_outline_rounded, AppColors.success);
      case WalletTxType.withdraw:
        return (Icons.arrow_downward_rounded, AppColors.textSecondary);
      case WalletTxType.refund:
        return (Icons.replay_rounded, AppColors.success);
      case WalletTxType.fee:
        return (Icons.percent_rounded, AppColors.primary);
    }
  }
}

void _openAmountSheet(
  BuildContext context,
  WidgetRef ref, {
  required bool isDeposit,
}) {
  final amount = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            Text(
              isDeposit ? 'إيداع في المحفظة' : 'سحب من المحفظة',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              isDeposit
                  ? 'أضف رصيدًا لاستخدامه في مشترياتك'
                  : 'سيتم تحويل المبلغ إلى حسابك البنكي',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                hintText: '0.00',
                suffixText: 'ر.س',
                suffixStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [50, 100, 250, 500]
                  .map(
                    (v) => ActionChip(
                      label: Text('$v'),
                      onPressed: () => amount.text = '$v',
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(amount.text) ?? 0;
                if (value <= 0) return;
                if (isDeposit) {
                  ref.read(walletProvider.notifier).deposit(value);
                } else {
                  final available = ref.read(walletProvider).available;
                  if (value > available) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الرصيد غير كافٍ للسحب'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }
                  ref.read(walletProvider.notifier).withdraw(value);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isDeposit
                          ? 'تم إيداع ${value.toInt()} ر.س بنجاح ✅'
                          : 'تم طلب سحب ${value.toInt()} ر.س',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(isDeposit ? 'تأكيد الإيداع' : 'تأكيد السحب'),
            ),
          ],
        ),
      ),
    ),
  );
}
