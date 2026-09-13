/// The receipt returned by POST /api/payments/simulate — a simulated
/// charge against a card, bank transfer, wallet balance, or "other"
/// provider. There's no real payment gateway behind this; it always
/// succeeds unless a wallet charge would overdraw the balance.
class PaymentReceipt {
  final String id;
  final String reference; // e.g. "PAY-7F3K9QZL"
  final String method; // 'card' | 'bank_transfer' | 'wallet' | 'other'
  final String methodLabel; // e.g. "Visa •••• 4242"
  final double amount;
  final String status;
  final String purpose;
  final DateTime createdAt;

  const PaymentReceipt({
    required this.id,
    required this.reference,
    required this.method,
    required this.methodLabel,
    required this.amount,
    required this.status,
    required this.purpose,
    required this.createdAt,
  });

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    return PaymentReceipt(
      id: json['id'] as String,
      reference: json['reference'] as String? ?? '',
      method: json['method'] as String? ?? '',
      methodLabel: json['methodLabel'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'succeeded',
      purpose: json['purpose'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
