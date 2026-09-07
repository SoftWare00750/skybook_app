import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/flight_card.dart';
import '../../services/aviationstack_service.dart';
import 'flight_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String departureIata;
  final String arrivalIata;

  const SearchResultsScreen({super.key, this.departureIata = 'JFK', this.arrivalIata = 'LHR'});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _service = AviationstackService();
  late Future<FlightSearchResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.searchFlights(
      departureIata: widget.departureIata,
      arrivalIata: widget.arrivalIata,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search Results', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text('${widget.departureIata}  →  ${widget.arrivalIata}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 12),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('15 Jun - 22 Jun · 1 Adult', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                _pillButton(Icons.filter_list, 'Filters'),
                const SizedBox(width: 12),
                _pillButton(Icons.swap_vert, 'Sort'),
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

                final result = snapshot.data ??
                    FlightSearchResult(flights: sampleFlights, usedLiveData: false);

                return Column(
                  children: [
                    if (result.notice != null)
                      Container(
                        width: double.infinity,
                        color: AppColors.warning.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(result.notice!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        color: AppColors.success.withOpacity(0.10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Row(
                          children: [
                            Icon(Icons.bolt, size: 16, color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Live flight data via aviationstack',
                                style: TextStyle(fontSize: 12, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: result.flights.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final flight = result.flights[i];
                          return FlightCard(
                            flight: flight,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FlightDetailsScreen(flight: flight)),
                            ),
                          );
                        },
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

  Widget _pillButton(IconData icon, String label) {
    return Expanded(
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
