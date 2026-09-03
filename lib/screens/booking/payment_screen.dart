import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import 'add_card_screen.dart';
import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Flight flight;
  final double total;
  const PaymentScreen({super.key, required this.flight, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selected = 0;
  final _methods = const [
    {'label': 'Credit / Debit Card', 'icon': Icons.credit_card, 'sub': 'VISA / Mastercard'},
    {'label': 'PayPal', 'icon': Icons.account_balance_wallet_outlined, 'sub': null},
    {'label': 'Apple Pay', 'icon': Icons.apple, 'sub': null},
    {'label': 'Google Pay', 'icon': Icons.g_mobiledata, 'sub': null},
    {'label': 'Book Now, Pay Later', 'icon': Icons.schedule, 'sub': 'Klarna'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 4),
                  Text('\$${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...List.generate(_methods.length, (i) {
                    final m = _methods[i];
                    final selected = _selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => setState(() => _selected = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: i,
                                groupValue: _selected,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => _selected = v!),
                              ),
                              Icon(m['icon'] as IconData, color: AppColors.textDark),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(m['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              if (m['sub'] != null)
                                Text(m['sub'] as String, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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
                  label: 'Pay \$${widget.total.toStringAsFixed(2)}',
                  onPressed: () {
                    if (_selected == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddCardScreen(flight: widget.flight, total: widget.total),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmedScreen(flight: widget.flight, total: widget.total),
                        ),
                      );
                    }
                  },
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
}
