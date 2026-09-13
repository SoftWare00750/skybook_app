import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../services/payment_method_service.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../services/api_client.dart';
import '../../widgets/custom_button.dart';

/// Generic "pay with a new card" step, reused by both flight checkout and
/// wallet top-ups. Simulates charging the card via
/// POST /api/payments/simulate, optionally saves it to the wallet for
/// next time, then hands the resulting [PaymentReceipt] to [onPaid] to
/// finish whatever comes next (create a booking, or credit the wallet) —
/// that part is the caller's job, so this screen stays purpose-agnostic.
///
/// No real card validation happens here (Luhn check, expiry-in-the-past,
/// etc.) — this is a simulated checkout, not a payment gateway.
class CardEntryScreen extends StatefulWidget {
  final double amount;
  final String purpose; // 'flight_booking' | 'wallet_topup'
  final String title;
  final Future<void> Function(BuildContext context, PaymentReceipt receipt) onPaid;

  const CardEntryScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.onPaid,
    this.title = 'Pay by Card',
  });

  @override
  State<CardEntryScreen> createState() => _CardEntryScreenState();
}

class _CardEntryScreenState extends State<CardEntryScreen> {
  final _paymentService = PaymentService();
  final _methodService = PaymentMethodService();
  final _authService = AuthService();

  final _numberCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _nameCtrl = TextEditingController(text: 'John Doe');
  final _monthCtrl = TextEditingController(text: '12');
  final _yearCtrl = TextEditingController(text: '27');
  final _cvvCtrl = TextEditingController(text: '123');

  bool _saveCard = true;
  bool _paying = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String get _digits => _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

  String get _last4 => _digits.length >= 4 ? _digits.substring(_digits.length - 4) : _digits.padLeft(4, '0');

  String get _brand {
    if (_digits.startsWith('4')) return 'Visa';
    if (_digits.startsWith('34') || _digits.startsWith('37')) return 'Amex';
    if (_digits.startsWith('6011') || _digits.startsWith('65')) return 'Discover';
    if (_digits.length >= 2) {
      final firstTwo = int.tryParse(_digits.substring(0, 2)) ?? 0;
      if (firstTwo >= 51 && firstTwo <= 55) return 'Mastercard';
    }
    return 'Card';
  }

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
    if (_digits.length < 12) {
      _showError('Enter a valid card number.');
      return;
    }
    if (_monthCtrl.text.trim().isEmpty || _yearCtrl.text.trim().isEmpty) {
      _showError("Enter the card's expiry date.");
      return;
    }
    if (_cvvCtrl.text.trim().length < 3) {
      _showError('Enter the CVV on the back of your card.');
      return;
    }

    setState(() => _paying = true);
    try {
      final signedIn = await _authService.isSignedIn();
      late final PaymentReceipt receipt;

      if (signedIn) {
        receipt = await _paymentService.simulate(
          amount: widget.amount,
          method: 'card',
          purpose: widget.purpose,
          cardNumber: _numberCtrl.text.trim(),
          cardholderName: _nameCtrl.text.trim(),
          expiryMonth: _monthCtrl.text.trim(),
          expiryYear: _yearCtrl.text.trim(),
        );

        if (_saveCard) {
          try {
            await _methodService.addCard(
              cardNumber: _numberCtrl.text.trim(),
              cardholderName: _nameCtrl.text.trim().isEmpty ? 'Card Holder' : _nameCtrl.text.trim(),
              expiryMonth: _monthCtrl.text.trim(),
              expiryYear: _yearCtrl.text.trim(),
            );
          } catch (_) {
            // The charge itself succeeded — don't fail checkout just
            // because saving the card for next time didn't.
          }
        }
      } else {
        // Guest checkout: no account to charge against or save a card
        // to, but the same simulated delay keeps the flow feeling
        // consistent, and the caller still gets a receipt to show.
        await Future.delayed(const Duration(milliseconds: 600));
        receipt = PaymentReceipt(
          id: 'local',
          reference: _localReference(),
          method: 'card',
          methodLabel: '$_brand •••• $_last4',
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
              height: 190,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.wifi, color: Colors.white70),
                      Text(_brand.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const Spacer(),
                  Text('•••• •••• •••• $_last4', style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (_nameCtrl.text.trim().isEmpty ? 'CARD HOLDER' : _nameCtrl.text.toUpperCase()),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text('${_monthCtrl.text} / ${_yearCtrl.text}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Card Number', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '4242 4242 4242 4242', prefixIcon: Icon(Icons.credit_card)),
            ),
            const SizedBox(height: 16),
            const Text('Cardholder Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'John Doe', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expiry Date', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _monthCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(hintText: 'MM'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(hintText: 'YY'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CVV', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _cvvCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '123'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Save card for faster payments')),
                Switch(
                  value: _saveCard,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _saveCard = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Pay ${CurrencyService.instance.format(widget.amount)}', loading: _paying, onPressed: _pay),
          ],
        ),
      ),
    );
  }
}
