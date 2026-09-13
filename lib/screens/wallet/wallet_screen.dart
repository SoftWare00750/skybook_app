import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/payment_method_tile.dart';
import '../../models/wallet_transaction.dart';
import '../../models/payment_method.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../services/payment_method_service.dart';
import '../../services/api_client.dart';
import '../auth/welcome_screen.dart';
import 'payment_methods_screen.dart';
import 'topup_payment_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with RouteAware {
  final _authService = AuthService();
  final _walletService = WalletService();
  final _methodService = PaymentMethodService();

  bool _loading = true;
  bool _signedIn = false;
  String? _error;
  Wallet? _wallet;
  List<PaymentMethod> _methods = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Fires when a screen pushed on top of this one (adding a payment
  // method, or the multi-step "Add Money" flow) gets popped and this
  // wallet screen becomes visible again — so the balance, transactions,
  // and saved methods are always fresh without the person having to
  // pull to refresh themselves.
  @override
  void didPopNext() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final signedIn = await _authService.isSignedIn();
    if (!signedIn) {
      if (!mounted) return;
      setState(() {
        _signedIn = false;
        _loading = false;
      });
      return;
    }
    try {
      final wallet = await _walletService.getWallet();
      // Best-effort: a hiccup fetching saved payment methods shouldn't
      // block the wallet balance/transactions from showing.
      final methods = await _methodService.list().catchError((_) => <PaymentMethod>[]);
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _wallet = wallet;
        _methods = methods;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _error = "Couldn't load your wallet. Pull down to try again.";
        _loading = false;
      });
    }
  }

  Future<void> _addMoney() async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("You'll choose how to pay on the next step.", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Amount', prefixText: '\$ '),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
    if (amount == null || !mounted) return;

    // TopUpPaymentScreen handles the charge + wallet credit itself, then
    // pops straight back to this screen — didPopNext() above refreshes.
    Navigator.push(context, MaterialPageRoute(builder: (_) => TopUpPaymentScreen(amount: amount)));
  }

  Future<void> _openPaymentMethods() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: _body(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (!_signedIn) return _guestPrompt();
    if (_error != null) return _errorState(_error!);

    final wallet = _wallet ?? const Wallet(balance: 0, transactions: []);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wallet Balance', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        '\$${wallet.balance.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: AppColors.primary, minimumSize: const Size(0, 40)),
                  onPressed: _addMoney,
                  child: const Text('Add Money'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: _openPaymentMethods,
                child: Text(_methods.isEmpty ? 'Add' : 'Manage'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_methods.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: _openPaymentMethods,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_card_outlined, color: AppColors.textGrey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Add a card, bank account, or other provider', style: TextStyle(color: AppColors.textGrey)),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textGrey),
                  ],
                ),
              ),
            )
          else
            ..._methods.take(2).map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PaymentMethodTile(method: m),
                )),
          const SizedBox(height: 16),
          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (wallet.transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No transactions yet', style: TextStyle(color: AppColors.textGrey))),
            )
          else
            ...wallet.transactions.take(10).map((t) => _transactionRow(t)),
        ],
      ),
    );
  }

  Widget _transactionRow(WalletTransaction t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(t.isCredit ? Icons.add_circle_outline : Icons.flight_takeoff, color: AppColors.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(t.formattedDate, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${t.isCredit ? '+' : '-'}\$${t.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(color: t.isCredit ? AppColors.success : AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _guestPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.textGrey),
            const SizedBox(height: 12),
            const Text('Sign in to use your wallet', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              'Balance and transactions are saved to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.textGrey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
