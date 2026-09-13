import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/flight.dart';
import '../data/destination_images.dart';
import '../services/currency_service.dart';

class AirlineLogo extends StatelessWidget {
  final Color color;
  final double size;
  const AirlineLogo({super.key, required this.color, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Icon(Icons.flight, color: Colors.white, size: 16),
    );
  }
}

/// A destination photo banner with graceful loading and offline fallback
/// states, plus a soft gradient + city label overlay.
///
/// The photo itself is resolved from [iataCode] via
/// `DestinationImages.resolve` (see `data/destination_images.dart`): a
/// hand-curated Unsplash photo for major hubs, otherwise a live Wikipedia
/// lookup by city name, otherwise a generic fallback photo — so every
/// destination gets a real photo, not just the curated ones.
class DestinationImageBanner extends StatelessWidget {
  final String iataCode;
  final String cityLabel;
  final double height;

  const DestinationImageBanner({
    super.key,
    required this.iataCode,
    required this.cityLabel,
    this.height = 130,
  });

  Widget _placeholder({Widget? child}) => Container(
        color: AppColors.inputFill,
        child: Center(
          child: child ??
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FutureBuilder<String>(
          future: DestinationImages.resolve(iataCode),
          builder: (context, snapshot) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (!snapshot.hasData)
                  _placeholder()
                else
                  Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _placeholder();
                    },
                    errorBuilder: (context, error, stack) => _placeholder(
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textGrey),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(cityLabel,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback? onTap;

  const FlightCard({super.key, required this.flight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DestinationImageBanner(iataCode: flight.arriveCode, cityLabel: flight.arriveCode),
            const SizedBox(height: 14),
            Row(
              children: [
                AirlineLogo(color: flight.airlineColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    flight.airline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(flight.flightCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flight.departTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(flight.departCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(flight.duration, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Icon(Icons.flight, size: 14, color: AppColors.textGrey),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(flight.stops, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(flight.arriveTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(flight.arriveCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flight.date, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(
                  CurrencyService.instance.format(flight.price),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
