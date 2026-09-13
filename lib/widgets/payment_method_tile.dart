import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../theme/app_theme.dart';

/// Icon shown for a payment method type across the wallet and checkout
/// screens — card / bank transfer / other (PayPal, Apple Pay, etc).
IconData paymentTypeIcon(String type) {
  switch (type) {
    case 'card':
      return Icons.credit_card_rounded;
    case 'bank_transfer':
      return Icons.account_balance_rounded;
    default:
      return Icons.more_horiz_rounded;
  }
}

String paymentTypeLabel(String type) {
  switch (type) {
    case 'card':
      return 'Card';
    case 'bank_transfer':
      return 'Bank Transfer';
    default:
      return 'Other';
  }
}

/// A single saved payment method row — used both in the wallet's "Payment
/// Methods" list and as a "pay with a saved method" option at checkout.
class PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const PaymentMethodTile({
    super.key,
    required this.method,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(paymentTypeIcon(method.type), color: AppColors.textDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(method.label,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Default', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(method.subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.textGrey, size: 20),
                onPressed: onDelete,
              ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
