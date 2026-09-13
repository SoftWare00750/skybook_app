import '../models/payment_method.dart';
import 'api_client.dart';

/// CRUD for the payment methods a user has saved to their wallet (Wallet ->
/// Payment Methods), so checkout can offer "pay with a saved card" instead
/// of re-entering details every time.
class PaymentMethodService {
  final _client = ApiClient();

  Future<List<PaymentMethod>> list() async {
    final data = await _client.get('/api/payment-methods') as List;
    return data.whereType<Map<String, dynamic>>().map(PaymentMethod.fromJson).toList();
  }

  Future<PaymentMethod> addCard({
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    bool setDefault = false,
  }) async {
    final data = await _client.post('/api/payment-methods', {
      'type': 'card',
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'setDefault': setDefault,
    }) as Map<String, dynamic>;
    return PaymentMethod.fromJson(data);
  }

  Future<PaymentMethod> addBankTransfer({
    required String bankName,
    required String accountNumber,
    bool setDefault = false,
  }) async {
    final data = await _client.post('/api/payment-methods', {
      'type': 'bank_transfer',
      'bankName': bankName,
      'accountNumber': accountNumber,
      'setDefault': setDefault,
    }) as Map<String, dynamic>;
    return PaymentMethod.fromJson(data);
  }

  Future<PaymentMethod> addOther({
    required String provider,
    bool setDefault = false,
  }) async {
    final data = await _client.post('/api/payment-methods', {
      'type': 'other',
      'otherProvider': provider,
      'setDefault': setDefault,
    }) as Map<String, dynamic>;
    return PaymentMethod.fromJson(data);
  }

  Future<PaymentMethod> setDefault(String id) async {
    final data = await _client.put('/api/payment-methods/$id/default', const {}) as Map<String, dynamic>;
    return PaymentMethod.fromJson(data);
  }

  Future<void> remove(String id) => _client.delete('/api/payment-methods/$id');
}
