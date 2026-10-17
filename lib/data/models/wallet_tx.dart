enum WalletTxType { hold, release, topup, withdraw, refund, fee }

class WalletTransaction {
  final String id;
  final WalletTxType type;
  final String title;
  final double amount;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });

  bool get isCredit => amount >= 0;
}
