import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/payment_method.dart';
import '../../services/payment_method_service.dart';
import '../../services/api_client.dart';
import '../../widgets/payment_method_tile.dart';
import 'add_payment_method_screen.dart';

/// Wallet -> Payment Methods. Lists every card / bank account / other
/// method the user has saved, lets them add a new one, set a default, or
/// remove one — the same list checkout screens read from to offer
/// "pay with a saved method".
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _service = PaymentMethodService();
  bool _loading = true;
  String? _error;
  List<PaymentMethod> _methods = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final methods = await _service.list();
      if (!mounted) return;
      setState(() {
        _methods = methods;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't load your payment methods. Pull down to try again.";
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final added = await Navigator.push<PaymentMethod>(
      context,
      MaterialPageRoute(builder: (_) => const AddPaymentMethodScreen()),
    );
    if (added != null) _load();
  }

  Future<void> _setDefault(PaymentMethod method) async {
    if (method.isDefault) return;
    setState(() {
      _methods = [
        for (final m in _methods)
          PaymentMethod(
            id: m.id,
            type: m.type,
            label: m.label,
            brand: m.brand,
            last4: m.last4,
            expiryMonth: m.expiryMonth,
            expiryYear: m.expiryYear,
            bankName: m.bankName,
            accountLast4: m.accountLast4,
            otherProvider: m.otherProvider,
            isDefault: m.id == method.id,
            createdAt: m.createdAt,
          ),
      ];
    });
    try {
      await _service.setDefault(method.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't set that as default.")));
      _load();
    }
  }

  Future<void> _delete(PaymentMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove payment method?'),
        content: Text('This will remove ${method.label} from your wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final previous = _methods;
    setState(() => _methods = _methods.where((m) => m.id != method.id).toList());
    try {
      await _service.remove(method.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _methods = previous);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't remove that payment method.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: AppColors.textGrey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_methods.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 500,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.credit_card_off_outlined, size: 48, color: AppColors.textGrey),
                      const SizedBox(height: 16),
                      const Text('No payment methods yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text(
                        'Add a card, bank account, or another provider to pay faster at checkout.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(onPressed: _add, child: const Text('Add Payment Method')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = _methods[i];
          return Dismissible(
            key: ValueKey(m.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await _delete(m);
              return false; // _delete already updates state; avoid double-remove
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: const Icon(Icons.delete_outline, color: AppColors.primary),
            ),
            child: PaymentMethodTile(
              method: m,
              onTap: () => _setDefault(m),
              onDelete: () => _delete(m),
            ),
          );
        },
      ),
    );
  }
}
