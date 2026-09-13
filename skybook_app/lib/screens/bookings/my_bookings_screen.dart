import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/api_client.dart';
import '../../widgets/empty_state.dart';
import '../auth/welcome_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _authService = AuthService();
  final _bookingService = BookingService();

  int _tab = 0;
  bool _loading = true;
  bool _signedIn = false;
  String? _error;
  List<Booking> _bookings = [];

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
      final bookings = await _bookingService.listBookings();
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _bookings = bookings;
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
        _error = "Couldn't load your bookings. Pull down to try again.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  _tabBtn('Upcoming', 0),
                  _tabBtn('Past', 1),
                ],
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _body() {
    if (!_signedIn && !_loading) return _guestPrompt();
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return _errorState(_error!);

    final filtered = _bookings.where((b) => _tab == 0 ? b.isUpcoming : !b.isUpcoming).toList();
    if (filtered.isEmpty) {
      // Empty list still supports pull-to-refresh so a booking made
      // elsewhere shows up without navigating away and back.
      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 480,
              child: EmptyState(
                illustrationAsset: 'assets/icons/empty_bookings.svg',
                title: 'No bookings yet',
                subtitle: _tab == 0
                    ? "You haven't booked any upcoming flights. Search for a flight to get started."
                    : "You don't have any past bookings to show yet.",
                action: _tab == 0
                    ? OutlinedButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        child: const Text('Search flights'),
                      )
                    : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) => _bookingCard(filtered[i]),
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
            const Icon(Icons.confirmation_number_outlined, size: 40, color: AppColors.textGrey),
            const SizedBox(height: 12),
            const Text('Sign in to see your bookings', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "You're browsing as a guest, so bookings made now aren't saved to an account.",
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

  Widget _tabBtn(String label, int i) {
    final selected = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    final statusColor = b.status == 'Cancelled' ? AppColors.textGrey : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Color(0xFFB01F24), shape: BoxShape.circle),
                child: const Icon(Icons.flight, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(b.airline,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text(b.flightCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  b.isUpcoming ? 'Upcoming' : 'Past',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.departTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(b.departCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  Text(b.formattedDate, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(b.duration, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    const Icon(Icons.flight, color: AppColors.textGrey, size: 16),
                    Text(b.stops, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(b.arriveTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(b.arriveCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  Text(b.formattedDate, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kv('Booking Ref', b.bookingRef),
              _kv('Seat', b.seatNumber.isEmpty ? '—' : b.seatNumber),
              _kv('Status', b.status, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color ?? AppColors.textDark)),
      ],
    );
  }
}
