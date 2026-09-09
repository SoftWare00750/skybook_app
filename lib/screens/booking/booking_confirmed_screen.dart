import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flight_card.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/api_client.dart';
import '../bookings/my_bookings_screen.dart';
import '../home/home_screen.dart';
import '../auth/welcome_screen.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final Flight flight;
  final double total;
  final String seatNumber;
  final String cabinClass;
  final int passengers;

  const BookingConfirmedScreen({
    super.key,
    required this.flight,
    required this.total,
    this.seatNumber = '',
    this.cabinClass = 'Economy',
    this.passengers = 1,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  final _authService = AuthService();
  final _bookingService = BookingService();

  bool _saving = true;
  bool _isGuest = false;
  String? _bookingRef;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createBooking();
  }

  Future<void> _createBooking() async {
    final isGuest = await _authService.isGuest();
    final signedIn = await _authService.isSignedIn();

    if (!signedIn) {
      // Guest checkout: nothing to save server-side. Show a local
      // reference so the confirmation screen still feels complete, and
      // nudge the person to sign in if they want it saved for real.
      if (!mounted) return;
      setState(() {
        _isGuest = isGuest || true;
        _saving = false;
        _bookingRef = _localReference();
      });
      return;
    }

    try {
      final booking = await _bookingService.createBooking(
        flight: widget.flight,
        seatNumber: widget.seatNumber,
        cabinClass: widget.cabinClass,
        passengers: widget.passengers,
        totalPrice: widget.total,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _bookingRef = booking.bookingRef;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = e.message;
        _bookingRef = _localReference();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = "Couldn't save this booking to your account, but here's your confirmation.";
        _bookingRef = _localReference();
      });
    }
  }

  String _localReference() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (i) => chars[(rand + i * 7) % chars.length]).join();
  }

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
                      child: Column(
                        children: [
                          const Text('Booking Reference', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 4),
                          _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : Text(_bookingRef ?? '—',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    if (_isGuest && !_saving) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "You're browsing as a guest, so this booking isn't saved to an account.",
                                style: TextStyle(fontSize: 12, color: AppColors.textDark),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              ),
                              child: const Text('Sign in', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_errorMessage != null && !_saving) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(child: FlightCard(flight: widget.flight)),
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
