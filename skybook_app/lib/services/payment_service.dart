import '../models/payment.dart';
import 'api_client.dart';

/// Simulates charging a payment method. There's no real payment gateway
/// behind this — the backend always succeeds (after a short simulated
/// processing delay) except a wallet charge that would overdraw the
/// balance. Used for both flight checkout and wallet top-ups; the caller
/// passes the resulting [PaymentReceipt.reference] into whichever comes
/// next (POST /api/bookings or POST /api/wallet/topup).
class PaymentService {
  final _client = ApiClient();

  Future<PaymentReceipt> simulate({
    required double amount,
    required String method, // 'card' | 'bank_transfer' | 'wallet' | 'other'
    required String purpose, // 'flight_booking' | 'wallet_topup'
    String? paymentMethodId,
    String? cardNumber,
    String? cardholderName,
    String? expiryMonth,
    String? expiryYear,
    String? bankName,
    String? accountNumber,
    String? otherProvider,
  }) async {
    final data = await _client.post('/api/payments/simulate', {
      'amount': amount,
      'method': method,
      'purpose': purpose,
      if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      if (cardNumber != null) 'cardNumber': cardNumber,
      if (cardholderName != null) 'cardholderName': cardholderName,
      if (expiryMonth != null) 'expiryMonth': expiryMonth,
      if (expiryYear != null) 'expiryYear': expiryYear,
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (otherProvider != null) 'otherProvider': otherProvider,
    }) as Map<String, dynamic>;
    return PaymentReceipt.fromJson(data);
  }

  Future<List<PaymentReceipt>> history() async {
    final data = await _client.get('/api/payments') as List;
    return data.whereType<Map<String, dynamic>>().map(PaymentReceipt.fromJson).toList();
  }
}
