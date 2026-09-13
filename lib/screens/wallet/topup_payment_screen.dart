import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/wallet_service.dart';
import '../payment/payment_method_picker_screen.dart';

/// Wallet -> Add Money's payment step — the same "pay with a saved method,
/// or card / bank transfer / other" screen used at flight checkout, just
/// pointed at [WalletService.topUp] instead of creating a booking. Pops
/// straight back to the wallet tab on success; WalletScreen notices via
/// RouteAware and refreshes its balance/transactions automatically.
class TopUpPaymentScreen extends StatelessWidget {
  final double amount;

  const TopUpPaymentScreen({super.key, required this.amount});

  Future<void> _finishTopUp(BuildContext context, PaymentReceipt receipt) async {
    await WalletService().topUp(
      amount: amount,
      method: receipt.method,
      methodLabel: receipt.methodLabel,
      reference: receipt.reference,
    );
    if (!context.mounted) return;
    // Jump straight back to the wallet tab, however many screens deep this
    // is (picking a saved method is 1 level; entering a new card/bank/
    // other is 2). WalletScreen picks the refresh up itself via
    // RouteAware.didPopNext, so nothing further needs to happen here.
    Navigator.of(context).popUntil(ModalRoute.withName('wallet'));
  }

  @override
  Widget build(BuildContext context) {
    return PaymentMethodPickerScreen(
      amount: amount,
      purpose: 'wallet_topup',
      title: 'Add Money',
      amountLabel: "You're Adding",
      onPaid: _finishTopUp,
    );
  }
}
