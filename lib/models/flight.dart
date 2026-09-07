import 'package:flutter/material.dart';
import '../data/destination_images.dart';

class Flight {
  final String airline;
  final String flightCode;
  final Color airlineColor;
  final String departTime;
  final String departCode;
  final String arriveTime;
  final String arriveCode;
  final String duration;
  final String stops;
  final String date;
  final double price;

  const Flight({
    required this.airline,
    required this.flightCode,
    required this.airlineColor,
    required this.departTime,
    required this.departCode,
    required this.arriveTime,
    required this.arriveCode,
    required this.duration,
    required this.stops,
    required this.date,
    required this.price,
  });

  /// A destination photo for the arrival city, used as a header image on
  /// the search results and flight details screens.
  String get destinationImage => DestinationImages.forIata(arriveCode);

  /// Builds a [Flight] from a single `data[]` entry of an aviationstack
  /// `/v1/flights` response. aviationstack doesn't return a ticket price
  /// (it's a flight-status API, not a fares API), so [estimatedPrice] is
  /// used to keep the booking flow working end-to-end.
  factory Flight.fromAviationstack(Map<String, dynamic> json, {double estimatedPrice = 599.0}) {
    final airline = json['airline']?['name'] ?? 'Unknown Airline';
    final flightNumber = json['flight']?['iata'] ?? json['flight']?['icao'] ?? '—';
    final departure = json['departure'] ?? {};
    final arrival = json['arrival'] ?? {};

    String timeOf(String? iso) {
      if (iso == null) return '--:--';
      final dt = DateTime.tryParse(iso);
      if (dt == null) return '--:--';
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    String dateOf(String? iso) {
      if (iso == null) return '';
      final dt = DateTime.tryParse(iso);
      if (dt == null) return '';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    }

    String durationBetween(String? dep, String? arr) {
      final d = DateTime.tryParse(dep ?? '');
      final a = DateTime.tryParse(arr ?? '');
      if (d == null || a == null) return '—';
      final diff = a.difference(d);
      final h = diff.inHours.abs();
      final m = diff.inMinutes.abs() % 60;
      return '${h}h ${m}m';
    }

    return Flight(
      airline: airline,
      flightCode: flightNumber,
      airlineColor: const Color(0xFF1F3A93),
      departTime: timeOf(departure['scheduled']),
      departCode: departure['iata'] ?? '---',
      arriveTime: timeOf(arrival['scheduled']),
      arriveCode: arrival['iata'] ?? '---',
      duration: durationBetween(departure['scheduled'], arrival['scheduled']),
      stops: 'Non-stop',
      date: dateOf(departure['scheduled']),
      price: estimatedPrice,
    );
  }
}

// Sample data mirroring the mockups (JFK -> LHR search results).
final List<Flight> sampleFlights = [
  const Flight(
    airline: 'American Airlines',
    flightCode: 'AA 100',
    airlineColor: Color(0xFFB01F24),
    departTime: '08:30',
    departCode: 'JFK',
    arriveTime: '20:15',
    arriveCode: 'LHR',
    duration: '7h 45m',
    stops: 'Non-stop',
    date: '15 Jun, 2023',
    price: 740.00,
  ),
  const Flight(
    airline: 'British Airways',
    flightCode: 'BA 178',
    airlineColor: Color(0xFF1F3A93),
    departTime: '21:45',
    departCode: 'JFK',
    arriveTime: '09:40',
    arriveCode: 'LHR',
    duration: '7h 55m',
    stops: 'Non-stop +1',
    date: '15 Jun, 2023',
    price: 690.00,
  ),
  const Flight(
    airline: 'Delta Airlines',
    flightCode: 'DL 221',
    airlineColor: Color(0xFFB01F24),
    departTime: '10:20',
    departCode: 'JFK',
    arriveTime: '22:30',
    arriveCode: 'LHR',
    duration: '8h 10m',
    stops: 'Non-stop +1',
    date: '15 Jun, 2023',
    price: 715.00,
  ),
  const Flight(
    airline: 'United Airlines',
    flightCode: 'UA 902',
    airlineColor: Color(0xFF1F3A93),
    departTime: '17:50',
    departCode: 'JFK',
    arriveTime: '06:40',
    arriveCode: 'LHR',
    duration: '7h 50m',
    stops: 'Non-stop +1',
    date: '15 Jun, 2023',
    price: 665.00,
  ),
];
