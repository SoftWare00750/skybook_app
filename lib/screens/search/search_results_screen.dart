import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/flight_card.dart';
import '../../services/aviationstack_service.dart';
import '../home/passenger_picker_sheet.dart';
import 'flight_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String departureIata;
  final String arrivalIata;
  final String? departureLabel;
  final String? arrivalLabel;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final PassengerSelection? passengers;

  const SearchResultsScreen({
    super.key,
    this.departureIata = 'JFK',
    this.arrivalIata = 'LHR',
    this.departureLabel,
    this.arrivalLabel,
    this.departureDate,
    this.returnDate,
    this.passengers,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _service = AviationstackService();
  late Future<FlightSearchResult> _future;

  static const _sortOptions = ['Price: Low to High', 'Price: High to Low', 'Duration', 'Departure time'];
  String _sortBy = _sortOptions.first;

  @override
  void initState() {
    super.initState();
    _future = _service.searchFlights(
      departureIata: widget.departureIata,
      arrivalIata: widget.arrivalIata,
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String get _tripSummary {
    final parts = <String>[];
    if (widget.departureDate != null) {
      parts.add(widget.returnDate != null
          ? '${_formatDate(widget.departureDate!)} - ${_formatDate(widget.returnDate!)}'
          : _formatDate(widget.departureDate!));
    }
    parts.add(widget.passengers?.summary ?? '1 Adult, Economy');
    return parts.join(' · ');
  }

  List<Flight> _sorted(List<Flight> flights) {
    final list = [...flights];
    switch (_sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Duration':
        list.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'Departure time':
        list.sort((a, b) => a.departTime.compareTo(b.departTime));
        break;
    }
    return list;
  }

  Future<void> _openSort() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sort by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            for (final option in _sortOptions)
              RadioListTile<String>(
                value: option,
                groupValue: _sortBy,
                activeColor: AppColors.primary,
                title: Text(option),
                onChanged: (v) => Navigator.pop(context, v),
              ),
          ],
        ),
      ),
    );
    if (choice != null) setState(() => _sortBy = choice);
  }

  @override
  Widget build(BuildContext context) {
    final departureLabel = widget.departureLabel ?? widget.departureIata;
    final arrivalLabel = widget.arrivalLabel ?? widget.arrivalIata;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search Results', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              '${widget.departureIata}  →  ${widget.arrivalIata}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Modify search',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _tripSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _pillButton(Icons.filter_list, 'Filters', onTap: () {}),
                const SizedBox(width: 12),
                _pillButton(Icons.swap_vert, 'Sort', onTap: _openSort),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<FlightSearchResult>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Searching flights…', style: TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                  );
                }

                final result = snapshot.data ?? FlightSearchResult(flights: sampleFlights, usedLiveData: false);
                final flights = _sorted(result.flights);

                if (flights.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flight_land, size: 40, color: AppColors.textGrey),
                          const SizedBox(height: 12),
                          Text(
                            'No flights found for $departureLabel → $arrivalLabel.\nTry different dates or airports.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (result.notice != null)
                      _noticeBanner(result.notice!, icon: Icons.info_outline, color: AppColors.warning)
                    else
                      _noticeBanner('Live flight data via aviationstack', icon: Icons.bolt, color: AppColors.success),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          // Keeps cards a comfortable reading width on
                          // tablets/wide screens while staying fully fluid
                          // on phones of any size.
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: flights.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, i) => FlightCard(
                              flight: flights[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlightDetailsScreen(
                                    flight: flights[i],
                                    cabinClass: widget.passengers?.cabinClass ?? 'Economy',
                                    passengers: widget.passengers?.total ?? 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeBanner(String text, {required IconData icon, required Color color}) {
    return Container(
      width: double.infinity,
      color: color.withOpacity(0.10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }

  Widget _pillButton(IconData icon, String label, {required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.textDark),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
