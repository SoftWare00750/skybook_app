/// Destination header photos, sourced from Unsplash (hotlinked directly —
/// no API key required for plain image URLs like these).
///
/// Keyed by IATA airport code so it can be looked up straight from a
/// [Flight]'s arrival code, whether that flight came from local sample
/// data or a live aviationstack response.
class DestinationImages {
  static const Map<String, String> _byIata = {
    'LHR': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad', // London
    'LGW': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad',
    'CDG': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34', // Paris
    'ORY': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
    'JFK': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9', // New York
    'LGA': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9',
    'EWR': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9',
    'BKK': 'https://images.unsplash.com/photo-1508009603885-50cf7c579365', // Bangkok
    'DMK': 'https://images.unsplash.com/photo-1508009603885-50cf7c579365',
    'NRT': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf', // Tokyo
    'HND': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
    'DXB': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c', // Dubai
    'FCO': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5', // Rome
    'SYD': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9', // Sydney
    'SIN': 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd', // Singapore
    'HKG': 'https://images.unsplash.com/photo-1536599424071-0b215a388ba7', // Hong Kong
    'BCN': 'https://images.unsplash.com/photo-1583422409516-2895a77efded', // Barcelona
    'AMS': 'https://images.unsplash.com/photo-1534351590666-13e3e96b5017', // Amsterdam
    'IST': 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200', // Istanbul
    'LAX': 'https://images.unsplash.com/photo-1444723121867-7a241cacace9', // Los Angeles
    'CPT': 'https://images.unsplash.com/photo-1580060839134-75a50c1d8323', // Cape Town (Table Mountain)
    'LOS': 'https://images.unsplash.com/photo-1618828665347-7384e39da5e5', // Lagos
    'ABV': 'https://images.unsplash.com/photo-1618828665347-7384e39da5e5', // Abuja (shares Lagos photo)
    'KUL': 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07', // Kuala Lumpur (Petronas Towers)
    'DPS': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4', // Bali
  };

  static const String _fallback =
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05'; // generic airplane wing / sky

  /// Returns a photo URL for the given arrival IATA code, or a generic
  /// travel photo if the code isn't in the curated map yet.
  static String forIata(String iataCode) {
    final url = _byIata[iataCode.toUpperCase()];
    return _sized(url ?? _fallback);
  }

  static String _sized(String baseUrl) =>
      '$baseUrl?auto=format&fit=crop&w=900&q=70';
}
