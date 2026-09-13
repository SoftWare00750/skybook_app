import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../models/payment_method.dart';
import '../../services/currency_service.dart';
import '../../services/payment_service.dart';
import '../../services/payment_method_service.dart';
import '../../services/api_client.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/payment_method_tile.dart';
import 'card_entry_screen.dart';
import 'bank_transfer_entry_screen.dart';
import 'other_entry_screen.dart';

/// The shared "how do you want to pay?" screen — lists any saved payment
/// methods plus "Card / Bank Transfer / Other" to enter something new,
/// and hands whichever [PaymentReceipt] results to [onPaid]. Used for
/// both flight checkout (see `PaymentScreen`) and wallet top-ups (see
/// `TopUpPaymentScreen`), which differ only in [amount], [purpose], and
/// what [onPaid] does with the receipt afterwards.
class PaymentMethodPickerScreen extends StatefulWidget {
  final double amount;
  final String purpose; // 'flight_booking' | 'wallet_topup'
  final String title;
  final String amountLabel;
  final Future<void> Function(BuildContext context, PaymentReceipt receipt) onPaid;

  const PaymentMethodPickerScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.onPaid,
    this.title = 'Payment',
    this.amountLabel = 'Total Amount',
  });

  @override
  State<PaymentMethodPickerScreen> createState() => _PaymentMethodPickerScreenState();
}

class _PaymentMethodPickerScreenState extends State<PaymentMethodPickerScreen> {
  final _methodService = PaymentMethodService();
  final _paymentService = PaymentService();

  bool _loadingMethods = true;
  bool _paying = false;
  List<PaymentMethod> _methods = [];
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    try {
      final methods = await _methodService.list();
      if (!mounted) return;
      String? defaultId;
      for (final m in methods) {
        if (m.isDefault) {
          defaultId = m.id;
          break;
        }
      }
      setState(() {
        _methods = methods;
        _selectedId = defaultId;
        _loadingMethods = false;
      });
    } catch (_) {
      // Guest checkout, or a network hiccup fetching saved methods —
      // not fatal. The "pay with something new" tiles below still work
      // fully independently of this list.
      if (!mounted) return;
      setState(() => _loadingMethods = false);
    }
  }

  PaymentMethod? get _selectedMethod {
    for (final m in _methods) {
      if (m.id == _selectedId) return m;
    }
    return null;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _payWithSaved() async {
    final method = _selectedMethod;
    if (method == null) return;

    setState(() => _paying = true);
    try {
      final receipt = await _paymentService.simulate(
        amount: widget.amount,
        method: method.type,
        purpose: widget.purpose,
        paymentMethodId: method.id,
      );
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

  void _openNew(String type) {
    Widget screen;
    switch (type) {
      case 'card':
        screen = CardEntryScreen(amount: widget.amount, purpose: widget.purpose, onPaid: widget.onPaid);
        break;
      case 'bank_transfer':
        screen = BankTransferEntryScreen(amount: widget.amount, purpose: widget.purpose, onPaid: widget.onPaid);
        break;
      default:
        screen = OtherEntryScreen(amount: widget.amount, purpose: widget.purpose, onPaid: widget.onPaid);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.amountLabel, style: const TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 4),
                  Text(CurrencyService.instance.format(widget.amount), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (_loadingMethods)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else ...[
                    if (_methods.isNotEmpty) ...[
                      const Text('Saved Payment Methods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ..._methods.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PaymentMethodTile(
                              method: m,
                              selected: _selectedId == m.id,
                              onTap: () => setState(() => _selectedId = m.id),
                            ),
                          )),
                      const SizedBox(height: 8),
                      const Text('Or Pay With', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                    ] else ...[
                      const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                    ],
                    _newMethodTile(Icons.credit_card, 'Credit / Debit Card', 'Visa, Mastercard, Amex', () => _openNew('card')),
                    const SizedBox(height: 12),
                    _newMethodTile(Icons.account_balance_outlined, 'Bank Transfer', 'Pay directly from your bank', () => _openNew('bank_transfer')),
                    const SizedBox(height: 12),
                    _newMethodTile(Icons.account_balance_wallet_outlined, 'Other', 'PayPal, Apple Pay, Google Pay', () => _openNew('other')),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Pay ${CurrencyService.instance.format(widget.amount)}',
                  loading: _paying,
                  onPressed: _selectedMethod == null ? null : _payWithSaved,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: AppColors.textGrey),
                    SizedBox(width: 6),
                    Text('Secure payment', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _newMethodTile(IconData icon, String label, String sub, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(sub, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
