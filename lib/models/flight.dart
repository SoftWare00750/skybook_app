import 'package:flutter/material.dart';

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
