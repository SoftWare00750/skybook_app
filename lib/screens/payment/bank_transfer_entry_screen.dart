import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../services/payment_method_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../widgets/custom_button.dart';

/// Generic "pay by bank transfer" step, reused by both flight checkout
/// and wallet top-ups. Simulates the transfer via
/// POST /api/payments/simulate, optionally saves the account for next
/// time, then hands the resulting [PaymentReceipt] to [onPaid].
class BankTransferEntryScreen extends StatefulWidget {
  final double amount;
  final String purpose; // 'flight_booking' | 'wallet_topup'
  final String title;
  final Future<void> Function(BuildContext context, PaymentReceipt receipt) onPaid;

  const BankTransferEntryScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.onPaid,
    this.title = 'Pay by Bank Transfer',
  });

  @override
  State<BankTransferEntryScreen> createState() => _BankTransferEntryScreenState();
}

class _BankTransferEntryScreenState extends State<BankTransferEntryScreen> {
  final _paymentService = PaymentService();
  final _methodService = PaymentMethodService();
  final _authService = AuthService();

  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();

  bool _saveAccount = true;
  bool _paying = false;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  String get _digits => _accountNumberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
  String get _last4 => _digits.length >= 4 ? _digits.substring(_digits.length - 4) : _digits.padLeft(4, '0');

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _localReference() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return 'PAY-${List.generate(8, (i) => chars[(rand + i * 7) % chars.length]).join()}';
  }

  Future<void> _pay() async {
    if (_bankNameCtrl.text.trim().isEmpty) {
      _showError('Enter the bank name.');
      return;
    }
    if (_digits.length < 4) {
      _showError('Enter a valid account number.');
      return;
    }

    setState(() => _paying = true);
    try {
      final signedIn = await _authService.isSignedIn();
      late final PaymentReceipt receipt;

      if (signedIn) {
        receipt = await _paymentService.simulate(
          amount: widget.amount,
          method: 'bank_transfer',
          purpose: widget.purpose,
          bankName: _bankNameCtrl.text.trim(),
          accountNumber: _accountNumberCtrl.text.trim(),
        );

        if (_saveAccount) {
          try {
            await _methodService.addBankTransfer(
              bankName: _bankNameCtrl.text.trim(),
              accountNumber: _accountNumberCtrl.text.trim(),
            );
          } catch (_) {
            // The transfer itself succeeded — don't fail checkout just
            // because saving the account for next time didn't.
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        receipt = PaymentReceipt(
          id: 'local',
          reference: _localReference(),
          method: 'bank_transfer',
          methodLabel: '${_bankNameCtrl.text.trim()} •••• $_last4',
          amount: widget.amount,
          status: 'succeeded',
          purpose: widget.purpose,
          createdAt: DateTime.now(),
        );
      }

      if (!mounted) return;
      await widget.onPaid(context, receipt);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textGrey, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a simulated transfer — no real bank connection is made, and your account number is never stored in full.',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bank Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _bankNameCtrl,
              decoration: const InputDecoration(hintText: 'Chase Bank', prefixIcon: Icon(Icons.account_balance_outlined)),
            ),
            const SizedBox(height: 16),
            const Text('Account Holder Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _accountNameCtrl,
              decoration: const InputDecoration(hintText: 'John Doe', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            const Text('Account Number', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _accountNumberCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '000123456789', prefixIcon: Icon(Icons.numbers)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Save account for faster payments')),
                Switch(
                  value: _saveAccount,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _saveAccount = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Pay \$${widget.amount.toStringAsFixed(2)}', loading: _paying, onPressed: _pay),
          ],
        ),
      ),
    );
  }
}
