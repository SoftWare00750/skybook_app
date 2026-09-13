import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/airports.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/bottom_nav.dart';
import '../search/airport_picker_screen.dart';
import '../search/search_results_screen.dart';
import 'passenger_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tripType = 1; // 0 one way, 1 round trip, 2 multi-city

  // Live clock, driven by the device's local time. Ticks every second so
  // both the greeting (morning/afternoon/evening) and the time-of-day
  // label stay accurate for as long as the home screen is open.
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Good Morning (before 12pm) / Good Afternoon (12pm–5pm) / Good Evening
  /// (after 5pm), based on the device's current local hour.
  String get _greeting {
    final hour = _now.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// e.g. "2:07 PM" — formatted manually so we don't need to pull in intl
  /// just for a clock label.
  String get _formattedTime {
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final minute = _now.minute.toString().padLeft(2, '0');
    final period = _now.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  Airport? _origin = airports.firstWhere((a) => a.iata == 'JFK');
  Airport? _destination = airports.firstWhere((a) => a.iata == 'LHR');

  DateTime _departureDate = DateTime.now().add(const Duration(days: 14));
  DateTime? _returnDate = DateTime.now().add(const Duration(days: 21));

  PassengerSelection _passengers = const PassengerSelection(adults: 1, children: 0, cabinClass: 'Economy');

  // Quick-pick destinations shown below the search card. Each maps to a
  // real Airport so tapping one actually fills in the "To" field.
  final _popularDestinations = const [
    (airport: Airport(iata: 'LHR', city: 'London', country: 'United Kingdom'), icon: Icons.location_city),
    (airport: Airport(iata: 'CDG', city: 'Paris', country: 'France'), icon: Icons.location_city),
    (airport: Airport(iata: 'BKK', city: 'Bangkok', country: 'Thailand'), icon: Icons.temple_buddhist),
  ];

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Future<void> _pickAirport({required bool isOrigin}) async {
    final picked = await Navigator.push<Airport>(
      context,
      MaterialPageRoute(
        builder: (_) => AirportPickerScreen(
          title: isOrigin ? 'Select departure city' : 'Select arrival city',
          excluding: isOrigin ? _destination : _origin,
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isOrigin) {
        _origin = picked;
      } else {
        _destination = picked;
      }
    });
  }

  void _swapAirports() {
    if (_origin == null || _destination == null) return;
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    if (!isDeparture && _tripType == 0) return; // no return date for one-way
    final initial = isDeparture ? _departureDate : (_returnDate ?? _departureDate.add(const Duration(days: 7)));
    final firstDate = isDeparture ? DateTime.now() : _departureDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(_departureDate)) {
          _returnDate = _departureDate.add(const Duration(days: 7));
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  Future<void> _pickPassengers() async {
    final result = await showPassengerPicker(context, _passengers);
    if (result != null) setState(() => _passengers = result);
  }

  void _selectPopularDestination(Airport airport) {
    setState(() => _destination = airport);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Destination set to ${airport.city}'), duration: const Duration(seconds: 1)),
    );
  }

  void _search() {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose both a departure and arrival city.')));
      return;
    }
    if (_origin == _destination) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Departure and arrival cities must be different.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          departureIata: _origin!.iata,
          arrivalIata: _destination!.iata,
          departureLabel: _origin!.label,
          arrivalLabel: _destination!.label,
          departureDate: _departureDate,
          returnDate: _tripType == 1 ? _returnDate : null,
          passengers: _passengers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Cap the reading width on very wide screens/tablets while
            // staying fluid on phones of any size.
            final maxWidth = constraints.maxWidth > 560 ? 560.0 : constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_greeting,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('Where would you like to go?',
                                    style: const TextStyle(color: AppColors.textGrey),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
                                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textGrey),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formattedTime,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration:
                            BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Row(
                          children: [
                            _tripTypeTab('One way', 0),
                            _tripTypeTab('Round trip', 1),
                            _tripTypeTab('Multi-city', 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 44),
                                      child: _fieldRow(
                                        'From',
                                        _origin?.label ?? 'Select departure city',
                                        onTap: () => _pickAirport(isOrigin: true),
                                        showChevron: false,
                                      ),
                                    ),
                                    const Divider(height: 28),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 44),
                                      child: _fieldRow(
                                        'To',
                                        _destination?.label ?? 'Select arrival city',
                                        onTap: () => _pickAirport(isOrigin: false),
                                        showChevron: false,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  child: Material(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: _swapAirports,
                                      child: const Padding(
                                        padding: EdgeInsets.all(9),
                                        child: Icon(Icons.swap_vert, color: AppColors.primary, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: _fieldRow(
                                    'Departure',
                                    _formatDate(_departureDate),
                                    onTap: () => _pickDate(isDeparture: true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Opacity(
                                    opacity: _tripType == 0 ? 0.4 : 1,
                                    child: _fieldRow(
                                      'Return',
                                      _tripType == 0 ? 'N/A' : (_returnDate != null ? _formatDate(_returnDate!) : 'Select date'),
                                      onTap: () => _pickDate(isDeparture: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            _fieldRow('Passengers', _passengers.summary, onTap: _pickPassengers),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(label: 'Search Flights', icon: Icons.search, onPressed: _search),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Popular Destinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(onPressed: () {}, child: const Text('See all')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularDestinations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final d = _popularDestinations[i];
                            final selected = _destination == d.airport;
                            return GestureDetector(
                              onTap: () => _selectPopularDestination(d.airport),
                              child: Column(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: selected ? 0.18 : 0.08),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: selected ? Border.all(color: AppColors.primary, width: 1.4) : null,
                                    ),
                                    child: Icon(d.icon, color: AppColors.primary, size: 32),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      d.airport.city,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _tripTypeTab(String label, int index) {
    final selected = _tripType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tripType = index;
          if (index == 0) _returnDate = null;
          if (index != 0 && _returnDate == null) _returnDate = _departureDate.add(const Duration(days: 7));
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textGrey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value, {VoidCallback? onTap, bool showChevron = true}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onTap != null && showChevron)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.textGrey),
              ),
          ],
        ),
      ),
    );
  }
}
