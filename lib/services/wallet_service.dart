import '../models/wallet_transaction.dart';
import 'api_client.dart';

class WalletService {
  final _client = ApiClient();

  Future<Wallet> getWallet() async {
    final data = await _client.get('/api/wallet') as Map<String, dynamic>;
    return Wallet.fromJson(data);
  }

  Future<WalletTransaction> topUp({required double amount, String? label}) async {
    final data = await _client.post('/api/wallet/topup', {
      'amount': amount,
      'label': label ?? 'Money Added',
    }) as Map<String, dynamic>;
    return WalletTransaction.fromJson(data);
  }
}
