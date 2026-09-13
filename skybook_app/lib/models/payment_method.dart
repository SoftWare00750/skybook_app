/// A payment method saved to the user's wallet (card, bank account, or an
/// "other" provider like PayPal), returned by GET/POST /api/payment-methods.
/// Mirrors the backend's PaymentMethodResponse exactly — only a brand +
/// last 4 digits are ever stored server-side, never a full card/account
/// number.
class PaymentMethod {
  final String id;
  final String type; // 'card' | 'bank_transfer' | 'other'
  final String label; // e.g. "Visa •••• 4242"
  final String? brand;
  final String? last4;
  final String? expiryMonth;
  final String? expiryYear;
  final String? bankName;
  final String? accountLast4;
  final String? otherProvider;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.brand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.bankName,
    this.accountLast4,
    this.otherProvider,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'other',
      label: json['label'] as String? ?? '',
      brand: json['brand'] as String?,
      last4: json['last4'] as String?,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      bankName: json['bankName'] as String?,
      accountLast4: json['accountLast4'] as String?,
      otherProvider: json['otherProvider'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get subtitle {
    switch (type) {
      case 'card':
        return (expiryMonth != null && expiryYear != null) ? 'Expires $expiryMonth/$expiryYear' : 'Card';
      case 'bank_transfer':
        return 'Bank transfer';
      default:
        return 'Other';
    }
  }
}
