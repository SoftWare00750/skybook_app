import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import 'booking_confirmed_screen.dart';

class AddCardScreen extends StatefulWidget {
  final Flight flight;
  final double total;
  const AddCardScreen({super.key, required this.flight, required this.total});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String number = '4242 4242 4242 4242';
  String name = 'John Doe';
  String expiry = '12 / 27';
  bool saveCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Card')),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.wifi, color: Colors.white70),
                      Text('VISA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const Spacer(),
                  const Text('•••• •••• •••• 4242', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(expiry, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Card Number', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: TextEditingController(text: number),
              decoration: const InputDecoration(hintText: '4242 4242 4242 4242', prefixIcon: Icon(Icons.credit_card)),
            ),
            const SizedBox(height: 16),
            const Text('Cardholder Name', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: TextEditingController(text: name),
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
                      TextField(
                        controller: TextEditingController(text: expiry),
                        decoration: const InputDecoration(hintText: '12 / 27'),
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
                        controller: TextEditingController(text: '123'),
                        obscureText: true,
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
                  value: saveCard,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => saveCard = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Save Card',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingConfirmedScreen(flight: widget.flight, total: widget.total),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
