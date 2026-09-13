import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../services/payment_method_service.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../services/api_client.dart';
import '../../widgets/custom_button.dart';

/// Generic "pay with another provider" step (PayPal, Apple Pay, Google
/// Pay, or anything else) — reused by both flight checkout and wallet
/// top-ups. Simulates the charge via POST /api/payments/simulate,
/// optionally saves the provider for next time, then hands the resulting
/// [PaymentReceipt] to [onPaid].
class OtherEntryScreen extends StatefulWidget {
  final double amount;
  final String purpose; // 'flight_booking' | 'wallet_topup'
  final String title;
  final Future<void> Function(BuildContext context, PaymentReceipt receipt) onPaid;

  const OtherEntryScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.onPaid,
    this.title = 'Other Payment Method',
  });

  @override
  State<OtherEntryScreen> createState() => _OtherEntryScreenState();
}

class _OtherEntryScreenState extends State<OtherEntryScreen> {
  final _paymentService = PaymentService();
  final _methodService = PaymentMethodService();
  final _authService = AuthService();
  final _providerCtrl = TextEditingController();

  static const _providers = [
    {'label': 'PayPal', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Apple Pay', 'icon': Icons.apple},
    {'label': 'Google Pay', 'icon': Icons.g_mobiledata},
    {'label': 'Klarna', 'icon': Icons.schedule},
  ];

  bool _saveProvider = true;
  bool _paying = false;

  @override
  void dispose() {
    _providerCtrl.dispose();
    super.dispose();
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
    final provider = _providerCtrl.text.trim();
    if (provider.isEmpty) {
      _showError('Choose or enter a payment provider.');
      return;
    }

    setState(() => _paying = true);
    try {
      final signedIn = await _authService.isSignedIn();
      late final PaymentReceipt receipt;

      if (signedIn) {
        receipt = await _paymentService.simulate(
          amount: widget.amount,
          method: 'other',
          purpose: widget.purpose,
          otherProvider: provider,
        );

        if (_saveProvider) {
          try {
            await _methodService.addOther(provider: provider);
          } catch (_) {
            // The charge itself succeeded — don't fail checkout just
            // because saving the provider for next time didn't.
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        receipt = PaymentReceipt(
          id: 'local',
          reference: _localReference(),
          method: 'other',
          methodLabel: provider,
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
            const Text('Choose a Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _providers.map((p) {
                final selected = _providerCtrl.text == p['label'];
                return ChoiceChip(
                  avatar: Icon(p['icon'] as IconData, size: 18, color: selected ? Colors.white : AppColors.textDark),
                  label: Text(p['label'] as String),
                  selected: selected,
                  onSelected: (_) => setState(() => _providerCtrl.text = p['label'] as String),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Or Enter a Provider', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _providerCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'e.g. Venmo', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Save as a payment method')),
                Switch(
                  value: _saveProvider,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _saveProvider = v),
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
