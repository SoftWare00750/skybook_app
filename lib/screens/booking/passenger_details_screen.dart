import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'seat_selection_screen.dart';

class PassengerDetailsScreen extends StatelessWidget {
  final Flight flight;
  final double total;
  final String cabinClass;
  final int passengers;
  const PassengerDetailsScreen({
    super.key,
    required this.flight,
    required this.total,
    this.cabinClass = 'Economy',
    this.passengers = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Passenger Details', style: TextStyle(fontSize: 18)),
            Text('$passengers ${passengers == 1 ? 'Adult' : 'Adults'}',
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Passenger 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Mr.',
                    items: ['Mr.', 'Ms.', 'Mrs.']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (_) {},
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: CustomTextField(hint: 'John Doe', icon: Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 16),
            _labeledField('Full Name', 'John Doe', Icons.badge_outlined),
            const SizedBox(height: 16),
            _labeledField('Date of Birth', '12 May 1990', Icons.cake_outlined),
            const SizedBox(height: 16),
            _labeledField('Nationality', 'United States', Icons.public),
            const SizedBox(height: 16),
            _labeledField('Passport Number', 'AB1234567', Icons.badge_outlined),
            const SizedBox(height: 16),
            _labeledField('Passport Expiry', '12 May 2030', Icons.event_outlined),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SeatSelectionScreen(
                    flight: flight,
                    total: total,
                    cabinClass: cabinClass,
                    passengers: passengers,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        const SizedBox(height: 6),
        CustomTextField(hint: value, icon: icon),
      ],
    );
  }
}
