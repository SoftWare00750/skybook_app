import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/flight.dart';

class FlightSearchResult {
  final List<Flight> flights;
  final bool usedLiveData;
  final String? notice;

  FlightSearchResult({required this.flights, required this.usedLiveData, this.notice});
}

/// Wraps aviationstack.com's `/v1/flights` endpoint — "Full Aviation Data,
/// Real-Time Flights" per their marketing — to power the search results
/// screen with real flight data instead of static samples.
///
/// Notes on aviationstack:
/// - Requires a free (or paid) API key from https://aviationstack.com/.
/// - The free plan only allows plain `http://`, not `https://`; HTTPS
///   requires a paid subscription. This service uses https automatically
///   once a key is configured — switch to http in [_buildUri] if you're
///   on the free plan and see connection errors.
/// - It returns flight status/schedule data, not fares, so ticket prices
///   here are estimated client-side (see [Flight.fromAviationstack]).
class AviationstackService {
  static const _host = 'api.aviationstack.com';

  Future<FlightSearchResult> searchFlights({
    required String departureIata,
    required String arrivalIata,
  }) async {
    if (!AppConfig.hasAviationstackKey) {
      return FlightSearchResult(
        flights: sampleFlights,
        usedLiveData: false,
        notice: 'Showing sample flights — add an aviationstack API key in AppConfig to see live data.',
      );
    }

    final uri = _buildUri(departureIata: departureIata, arrivalIata: arrivalIata);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        return FlightSearchResult(
          flights: sampleFlights,
          usedLiveData: false,
          notice: 'aviationstack returned an error (${response.statusCode}) — showing sample flights instead.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body.containsKey('error')) {
        final message = body['error']?['message'] ?? 'Unknown aviationstack error';
        return FlightSearchResult(
          flights: sampleFlights,
          usedLiveData: false,
          notice: 'aviationstack error: $message — showing sample flights instead.',
        );
      }

      final data = (body['data'] as List?) ?? [];
      if (data.isEmpty) {
        return FlightSearchResult(
          flights: sampleFlights,
          usedLiveData: false,
          notice: 'No live flights found for this route right now — showing sample flights instead.',
        );
      }

      final flights = data
          .whereType<Map<String, dynamic>>()
          .map((f) => Flight.fromAviationstack(f))
          .toList();

      return FlightSearchResult(flights: flights, usedLiveData: true);
    } catch (e) {
      return FlightSearchResult(
        flights: sampleFlights,
        usedLiveData: false,
        notice: "Couldn't reach aviationstack — showing sample flights instead.",
      );
    }
  }

  Uri _buildUri({required String departureIata, required String arrivalIata}) {
    return Uri.https(_host, '/v1/flights', {
      'access_key': AppConfig.aviationstackApiKey,
      'dep_iata': departureIata,
      'arr_iata': arrivalIata,
    });
  }
}
