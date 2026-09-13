import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment_method.dart';
import '../../services/payment_method_service.dart';
import '../../services/api_client.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/payment_method_tile.dart';

/// Saves a new payment method to the wallet (Wallet -> Payment Methods ->
/// Add) so it can be picked at flight checkout or when topping up the
/// wallet without re-entering details. Only ever sends the raw
/// card/account number to the backend to derive a brand + last 4 digits
/// — never stores or re-displays the full number itself.
class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _service = PaymentMethodService();
  String _type = 'card';
  bool _saving = false;
  bool _setDefault = false;

  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryMonthCtrl = TextEditingController();
  final _expiryYearCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _otherProviderCtrl = TextEditingController();

  static const _otherProviders = ['PayPal', 'Apple Pay', 'Google Pay', 'Klarna'];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryMonthCtrl.dispose();
    _expiryYearCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _otherProviderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    String? error;
    if (_type == 'card') {
      final digits = _cardNumberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length < 12) error = 'Enter a valid card number.';
      else if (_expiryMonthCtrl.text.trim().isEmpty || _expiryYearCtrl.text.trim().isEmpty) {
        error = 'Enter the card\'s expiry date.';
      }
    } else if (_type == 'bank_transfer') {
      if (_bankNameCtrl.text.trim().isEmpty) {
        error = 'Enter the bank name.';
      } else if (_accountNumberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').length < 4) {
        error = 'Enter a valid account number.';
      }
    } else {
      if (_otherProviderCtrl.text.trim().isEmpty) error = 'Choose or enter a provider.';
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _saving = true);
    try {
      late final PaymentMethod method;
      switch (_type) {
        case 'card':
          method = await _service.addCard(
            cardNumber: _cardNumberCtrl.text.trim(),
            cardholderName: _cardNameCtrl.text.trim().isEmpty ? 'Card Holder' : _cardNameCtrl.text.trim(),
            expiryMonth: _expiryMonthCtrl.text.trim(),
            expiryYear: _expiryYearCtrl.text.trim(),
            setDefault: _setDefault,
          );
          break;
        case 'bank_transfer':
          method = await _service.addBankTransfer(
            bankName: _bankNameCtrl.text.trim(),
            accountNumber: _accountNumberCtrl.text.trim(),
            setDefault: _setDefault,
          );
          break;
        default:
          method = await _service.addOther(
            provider: _otherProviderCtrl.text.trim(),
            setDefault: _setDefault,
          );
      }
      if (!mounted) return;
      Navigator.pop(context, method);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment Method')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  _typeTab('card', 'Card'),
                  _typeTab('bank_transfer', 'Bank Transfer'),
                  _typeTab('other', 'Other'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._fieldsForType(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Set as default payment method')),
                Switch(
                  value: _setDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _setDefault = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Save Payment Method', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(String type, String label) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(paymentTypeIcon(type), size: 16, color: selected ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fieldsForType() {
    switch (_type) {
      case 'card':
        return [
          const Text('Card Number', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNumberCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '4242 4242 4242 4242', prefixIcon: Icon(Icons.credit_card)),
          ),
          const SizedBox(height: 16),
          const Text('Cardholder Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNameCtrl,
            decoration: const InputDecoration(hintText: 'John Doe', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expiry Month', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _expiryMonthCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'MM'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expiry Year', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _expiryYearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'YY'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ];
      case 'bank_transfer':
        return [
          const Text('Bank Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _bankNameCtrl,
            decoration: const InputDecoration(hintText: 'Chase Bank', prefixIcon: Icon(Icons.account_balance_outlined)),
          ),
          const SizedBox(height: 16),
          const Text('Account Number', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _accountNumberCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '000123456789', prefixIcon: Icon(Icons.numbers)),
          ),
          const SizedBox(height: 8),
        ];
      default:
        return [
          const Text('Provider', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _otherProviderCtrl,
            decoration: const InputDecoration(hintText: 'PayPal', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _otherProviders
                .map((p) => ChoiceChip(
                      label: Text(p),
                      selected: _otherProviderCtrl.text == p,
                      onSelected: (_) => setState(() => _otherProviderCtrl.text = p),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: _otherProviderCtrl.text == p ? AppColors.primary : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
        ];
    }
  }
}
