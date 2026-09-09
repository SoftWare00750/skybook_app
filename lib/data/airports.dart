/// A minimal airport record used to drive the "From" / "To" pickers on the
/// home screen's search form. Kept in the app (rather than fetched) since
/// aviationstack's own airport list requires a paid plan; this list also
/// intentionally matches the cities covered by [DestinationImages] so
/// picked destinations always have a header photo downstream.
class Airport {
  final String iata;
  final String city;
  final String country;

  const Airport({required this.iata, required this.city, required this.country});

  /// e.g. "New York (JFK)" — matches the label style used across the
  /// mockups' "From" / "To" fields.
  String get label => '$city ($iata)';

  @override
  bool operator ==(Object other) => other is Airport && other.iata == iata;

  @override
  int get hashCode => iata.hashCode;
}

const List<Airport> airports = [
  Airport(iata: 'JFK', city: 'New York', country: 'United States'),
  Airport(iata: 'LGA', city: 'New York', country: 'United States'),
  Airport(iata: 'EWR', city: 'Newark', country: 'United States'),
  Airport(iata: 'LAX', city: 'Los Angeles', country: 'United States'),
  Airport(iata: 'LHR', city: 'London', country: 'United Kingdom'),
  Airport(iata: 'LGW', city: 'London', country: 'United Kingdom'),
  Airport(iata: 'CDG', city: 'Paris', country: 'France'),
  Airport(iata: 'ORY', city: 'Paris', country: 'France'),
  Airport(iata: 'FCO', city: 'Rome', country: 'Italy'),
  Airport(iata: 'BCN', city: 'Barcelona', country: 'Spain'),
  Airport(iata: 'AMS', city: 'Amsterdam', country: 'Netherlands'),
  Airport(iata: 'IST', city: 'Istanbul', country: 'Turkey'),
  Airport(iata: 'DXB', city: 'Dubai', country: 'United Arab Emirates'),
  Airport(iata: 'SIN', city: 'Singapore', country: 'Singapore'),
  Airport(iata: 'HKG', city: 'Hong Kong', country: 'Hong Kong'),
  Airport(iata: 'BKK', city: 'Bangkok', country: 'Thailand'),
  Airport(iata: 'DMK', city: 'Bangkok', country: 'Thailand'),
  Airport(iata: 'NRT', city: 'Tokyo', country: 'Japan'),
  Airport(iata: 'HND', city: 'Tokyo', country: 'Japan'),
  Airport(iata: 'SYD', city: 'Sydney', country: 'Australia'),
];

/// Case-insensitive search across city, country, and IATA code.
List<Airport> searchAirports(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return airports;
  return airports.where((a) {
    return a.city.toLowerCase().contains(q) ||
        a.country.toLowerCase().contains(q) ||
        a.iata.toLowerCase().contains(q);
  }).toList();
}
