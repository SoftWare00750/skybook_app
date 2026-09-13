import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/flight.dart';
import '../../models/payment.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../payment/payment_method_picker_screen.dart';
import 'booking_confirmed_screen.dart';

/// Flight checkout — a thin wrapper around the shared
/// [PaymentMethodPickerScreen] that only takes card / bank transfer /
/// other (no "pay from wallet" here, by design: a flight is an outside
/// expense, not something to fund from money already in the wallet).
/// Once a [PaymentReceipt] comes back, this finishes the booking and
/// hands off to the confirmation screen.
class PaymentScreen extends StatelessWidget {
  final Flight flight;
  final double total;
  final String seatNumber;
  final String cabinClass;
  final int passengers;

  const PaymentScreen({
    super.key,
    required this.flight,
    required this.total,
    this.seatNumber = '',
    this.cabinClass = 'Economy',
    this.passengers = 1,
  });

  Future<void> _finishBooking(BuildContext context, PaymentReceipt receipt) async {
    final authService = AuthService();
    final signedIn = await authService.isSignedIn();

    Booking? booking;
    if (signedIn) {
      booking = await BookingService().createBooking(
        flight: flight,
        seatNumber: seatNumber,
        cabinClass: cabinClass,
        passengers: passengers,
        totalPrice: total,
        paymentMethod: receipt.method,
        paymentMethodLabel: receipt.methodLabel,
        paymentReference: receipt.reference,
      );
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmedScreen(
          flight: flight,
          total: total,
          seatNumber: seatNumber,
          cabinClass: cabinClass,
          passengers: passengers,
          booking: booking,
          paymentMethodLabel: receipt.methodLabel,
          paymentReference: receipt.reference,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaymentMethodPickerScreen(
      amount: total,
      purpose: 'flight_booking',
      title: 'Payment',
      amountLabel: 'Total Amount',
      onPaid: _finishBooking,
    );
  }
}
