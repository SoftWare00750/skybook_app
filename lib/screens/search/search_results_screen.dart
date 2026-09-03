import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/flight.dart';
import '../../widgets/flight_card.dart';
import 'flight_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Results', style: TextStyle(fontSize: 18)),
            SizedBox(height: 2),
            Text('JFK  →  LHR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sampleFlights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final flight = sampleFlights[i];
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
