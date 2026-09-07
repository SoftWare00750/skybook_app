import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flight_card.dart';
import '../booking/passenger_details_screen.dart';

class FlightDetailsScreen extends StatelessWidget {
  final Flight flight;
  const FlightDetailsScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    const taxes = 120.0;
    final total = flight.price + taxes;
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DestinationImageBanner(
              imageUrl: flight.destinationImage,
              cityLabel: '${flight.departCode} → ${flight.arriveCode}',
              height: 160,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AirlineLogo(color: flight.airlineColor),
                      const SizedBox(width: 10),
                      Text(flight.airline, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(flight.flightCode, style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flight.departTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(flight.departCode, style: const TextStyle(color: AppColors.textGrey)),
                          Text(flight.date, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(flight.duration, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                            const Icon(Icons.flight, color: AppColors.textGrey, size: 18),
                            Text(flight.stops, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(flight.arriveTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(flight.arriveCode, style: const TextStyle(color: AppColors.textGrey)),
                          Text(flight.date, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Flight Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _infoRow('Aircraft', 'Boeing 777-300ER'),
            _infoRow('Duration', flight.duration),
            _infoRow('Baggage', '23 kg checked'),
            _infoRow('Cabin', 'Economy'),
            const SizedBox(height: 24),
            const Text('Fare Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _infoRow('1 Adult', '\$${flight.price.toStringAsFixed(2)}'),
            _infoRow('Taxes & fees', '\$${taxes.toStringAsFixed(2)}'),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PassengerDetailsScreen(flight: flight, total: total)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
