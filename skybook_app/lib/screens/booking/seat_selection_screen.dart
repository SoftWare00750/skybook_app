import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../services/currency_service.dart';
import '../../widgets/custom_button.dart';
import 'payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Flight flight;
  final double total;
  final String cabinClass;
  final int passengers;
  const SeatSelectionScreen({
    super.key,
    required this.flight,
    required this.total,
    this.cabinClass = 'Economy',
    this.passengers = 1,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

enum SeatState { available, selected, occupied }

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> cols = ['A', 'B', 'C', '', 'D', 'E', 'F', '', 'H', 'J', 'K'];
  late Map<String, SeatState> seatMap;
  String? selectedSeat;

  static const occupiedSeats = {'2C', '3D', '3E', '3F', '4H', '4J', '4K', '2K'};

  @override
  void initState() {
    super.initState();
    seatMap = {};
    for (int row = 1; row <= 6; row++) {
      for (final c in cols) {
        if (c.isEmpty) continue;
        final id = '$row$c';
        seatMap[id] = occupiedSeats.contains(id) ? SeatState.occupied : SeatState.available;
      }
    }
    seatMap['3B'] = SeatState.selected;
    selectedSeat = '3B';
  }

  double get seatPrice => selectedSeat == '3B' ? 20.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Seats', style: TextStyle(fontSize: 18)),
            Text(
              '${widget.flight.departCode} → ${widget.flight.arriveCode} · ${widget.flight.date}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: cols
                  .map((c) => Expanded(
                        child: Center(
                          child: Text(c, style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 6,
              itemBuilder: (context, rowIdx) {
                final row = rowIdx + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: cols.map((c) {
                      if (c.isEmpty) return const Expanded(child: SizedBox());
                      final id = '$row$c';
                      final state = seatMap[id] ?? SeatState.available;
                      return Expanded(child: Center(child: _seat(id, state)));
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legend(AppColors.inputFill, 'Available', border: true),
                _legend(AppColors.primary, 'Selected'),
                _legend(Colors.transparent, 'Occupied', icon: Icons.close),
              ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CurrencyService.instance.format(seatPrice),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text(selectedSeat != null ? 'Seat $selectedSeat' : 'No seat selected',
                        style: const TextStyle(color: AppColors.textGrey)),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        flight: widget.flight,
                        total: widget.total + seatPrice,
                        seatNumber: selectedSeat ?? '',
                        cabinClass: widget.cabinClass,
                        passengers: widget.passengers,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seat(String id, SeatState state) {
    Color bg;
    Widget? child;
    switch (state) {
      case SeatState.available:
        bg = AppColors.inputFill;
        break;
      case SeatState.selected:
        bg = AppColors.primary;
        break;
      case SeatState.occupied:
        bg = Colors.transparent;
        child = const Icon(Icons.close, size: 14, color: AppColors.textGrey);
        break;
    }
    return GestureDetector(
      onTap: state == SeatState.occupied
          ? null
          : () => setState(() {
                if (selectedSeat != null) seatMap[selectedSeat!] = SeatState.available;
                seatMap[id] = SeatState.selected;
                selectedSeat = id;
              }),
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: state == SeatState.occupied ? Border.all(color: AppColors.divider) : null,
        ),
        child: child,
      ),
    );
  }

  Widget _legend(Color color, String label, {bool border = false, IconData? icon}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: AppColors.divider) : null,
          ),
          child: icon != null ? Icon(icon, size: 10, color: AppColors.textGrey) : null,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}
