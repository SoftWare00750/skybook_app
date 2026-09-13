class WalletTransaction {
  final String id;
  final String label;
  final double amount;
  final String? method;
  final String? reference;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.label,
    required this.amount,
    this.method,
    this.reference,
    required this.createdAt,
  });

  bool get isCredit => amount > 0;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String?,
      reference: json['reference'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${createdAt.day} ${months[createdAt.month - 1]}, ${createdAt.year}';
  }
}

class Wallet {
  final double balance;
  final List<WalletTransaction> transactions;

  const Wallet({required this.balance, required this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transactions: (json['transactions'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WalletTransaction.fromJson)
          .toList(),
    );
  }
}
