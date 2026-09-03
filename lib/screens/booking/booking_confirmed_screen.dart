import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flight_card.dart';
import '../bookings/my_bookings_screen.dart';
import '../home/home_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final Flight flight;
  final double total;
  const BookingConfirmedScreen({super.key, required this.flight, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Booking Confirmed!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Your flight has been booked successfully.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 28),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Text('Booking Reference', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          SizedBox(height: 4),
                          Text('ABC12345', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: FlightCard(flight: flight)),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'View My Booking',
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                        (route) => false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Download Itinerary',
                      icon: Icons.download_outlined,
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
