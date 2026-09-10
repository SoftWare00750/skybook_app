/// A minimal airport record used to drive the "From" / "To" pickers on the
/// home screen's search form. Kept in the app (rather than fetched) since
/// aviationstack's own airport list requires a paid plan.
///
/// This is a curated set of the world's major international airports —
/// covering every populated continent and the great majority of countries
/// people actually search flights for — rather than the full ~40,000-entry
/// global airport registry, which would be impractical to hand-maintain and
/// isn't something aviationstack's free tier exposes either. If a specific
/// smaller airport is missing, it's straightforward to add another
/// [Airport] entry below.
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
  // --- North America ---------------------------------------------------
  Airport(iata: 'JFK', city: 'New York', country: 'United States'),
  Airport(iata: 'LGA', city: 'New York', country: 'United States'),
  Airport(iata: 'EWR', city: 'Newark', country: 'United States'),
  Airport(iata: 'LAX', city: 'Los Angeles', country: 'United States'),
  Airport(iata: 'SFO', city: 'San Francisco', country: 'United States'),
  Airport(iata: 'ORD', city: 'Chicago', country: 'United States'),
  Airport(iata: 'MIA', city: 'Miami', country: 'United States'),
  Airport(iata: 'ATL', city: 'Atlanta', country: 'United States'),
  Airport(iata: 'DFW', city: 'Dallas', country: 'United States'),
  Airport(iata: 'DEN', city: 'Denver', country: 'United States'),
  Airport(iata: 'SEA', city: 'Seattle', country: 'United States'),
  Airport(iata: 'BOS', city: 'Boston', country: 'United States'),
  Airport(iata: 'IAD', city: 'Washington D.C.', country: 'United States'),
  Airport(iata: 'LAS', city: 'Las Vegas', country: 'United States'),
  Airport(iata: 'PHX', city: 'Phoenix', country: 'United States'),
  Airport(iata: 'IAH', city: 'Houston', country: 'United States'),
  Airport(iata: 'HNL', city: 'Honolulu', country: 'United States'),
  Airport(iata: 'YYZ', city: 'Toronto', country: 'Canada'),
  Airport(iata: 'YVR', city: 'Vancouver', country: 'Canada'),
  Airport(iata: 'YUL', city: 'Montreal', country: 'Canada'),
  Airport(iata: 'YYC', city: 'Calgary', country: 'Canada'),
  Airport(iata: 'MEX', city: 'Mexico City', country: 'Mexico'),
  Airport(iata: 'CUN', city: 'Cancun', country: 'Mexico'),
  Airport(iata: 'GDL', city: 'Guadalajara', country: 'Mexico'),
  Airport(iata: 'SJU', city: 'San Juan', country: 'Puerto Rico'),
  Airport(iata: 'HAV', city: 'Havana', country: 'Cuba'),
  Airport(iata: 'PTY', city: 'Panama City', country: 'Panama'),
  Airport(iata: 'SJO', city: 'San José', country: 'Costa Rica'),

  // --- South America -----------------------------------------------------
  Airport(iata: 'GRU', city: 'São Paulo', country: 'Brazil'),
  Airport(iata: 'GIG', city: 'Rio de Janeiro', country: 'Brazil'),
  Airport(iata: 'BSB', city: 'Brasília', country: 'Brazil'),
  Airport(iata: 'EZE', city: 'Buenos Aires', country: 'Argentina'),
  Airport(iata: 'SCL', city: 'Santiago', country: 'Chile'),
  Airport(iata: 'BOG', city: 'Bogotá', country: 'Colombia'),
  Airport(iata: 'MDE', city: 'Medellín', country: 'Colombia'),
  Airport(iata: 'LIM', city: 'Lima', country: 'Peru'),
  Airport(iata: 'UIO', city: 'Quito', country: 'Ecuador'),
  Airport(iata: 'CCS', city: 'Caracas', country: 'Venezuela'),
  Airport(iata: 'MVD', city: 'Montevideo', country: 'Uruguay'),
  Airport(iata: 'ASU', city: 'Asunción', country: 'Paraguay'),
  Airport(iata: 'LPB', city: 'La Paz', country: 'Bolivia'),

  // --- Europe --------------------------------------------------------------
  Airport(iata: 'LHR', city: 'London', country: 'United Kingdom'),
  Airport(iata: 'LGW', city: 'London', country: 'United Kingdom'),
  Airport(iata: 'STN', city: 'London', country: 'United Kingdom'),
  Airport(iata: 'MAN', city: 'Manchester', country: 'United Kingdom'),
  Airport(iata: 'EDI', city: 'Edinburgh', country: 'United Kingdom'),
  Airport(iata: 'CDG', city: 'Paris', country: 'France'),
  Airport(iata: 'ORY', city: 'Paris', country: 'France'),
  Airport(iata: 'NCE', city: 'Nice', country: 'France'),
  Airport(iata: 'LYS', city: 'Lyon', country: 'France'),
  Airport(iata: 'FCO', city: 'Rome', country: 'Italy'),
  Airport(iata: 'MXP', city: 'Milan', country: 'Italy'),
  Airport(iata: 'VCE', city: 'Venice', country: 'Italy'),
  Airport(iata: 'NAP', city: 'Naples', country: 'Italy'),
  Airport(iata: 'BCN', city: 'Barcelona', country: 'Spain'),
  Airport(iata: 'MAD', city: 'Madrid', country: 'Spain'),
  Airport(iata: 'AGP', city: 'Málaga', country: 'Spain'),
  Airport(iata: 'PMI', city: 'Palma de Mallorca', country: 'Spain'),
  Airport(iata: 'LIS', city: 'Lisbon', country: 'Portugal'),
  Airport(iata: 'OPO', city: 'Porto', country: 'Portugal'),
  Airport(iata: 'AMS', city: 'Amsterdam', country: 'Netherlands'),
  Airport(iata: 'FRA', city: 'Frankfurt', country: 'Germany'),
  Airport(iata: 'MUC', city: 'Munich', country: 'Germany'),
  Airport(iata: 'BER', city: 'Berlin', country: 'Germany'),
  Airport(iata: 'HAM', city: 'Hamburg', country: 'Germany'),
  Airport(iata: 'ZRH', city: 'Zurich', country: 'Switzerland'),
  Airport(iata: 'GVA', city: 'Geneva', country: 'Switzerland'),
  Airport(iata: 'VIE', city: 'Vienna', country: 'Austria'),
  Airport(iata: 'BRU', city: 'Brussels', country: 'Belgium'),
  Airport(iata: 'DUB', city: 'Dublin', country: 'Ireland'),
  Airport(iata: 'CPH', city: 'Copenhagen', country: 'Denmark'),
  Airport(iata: 'ARN', city: 'Stockholm', country: 'Sweden'),
  Airport(iata: 'OSL', city: 'Oslo', country: 'Norway'),
  Airport(iata: 'HEL', city: 'Helsinki', country: 'Finland'),
  Airport(iata: 'KEF', city: 'Reykjavík', country: 'Iceland'),
  Airport(iata: 'WAW', city: 'Warsaw', country: 'Poland'),
  Airport(iata: 'PRG', city: 'Prague', country: 'Czech Republic'),
  Airport(iata: 'BUD', city: 'Budapest', country: 'Hungary'),
  Airport(iata: 'ATH', city: 'Athens', country: 'Greece'),
  Airport(iata: 'IST', city: 'Istanbul', country: 'Turkey'),
  Airport(iata: 'SAW', city: 'Istanbul', country: 'Turkey'),
  Airport(iata: 'SVO', city: 'Moscow', country: 'Russia'),
  Airport(iata: 'LED', city: 'Saint Petersburg', country: 'Russia'),
  Airport(iata: 'KBP', city: 'Kyiv', country: 'Ukraine'),
  Airport(iata: 'OTP', city: 'Bucharest', country: 'Romania'),
  Airport(iata: 'SOF', city: 'Sofia', country: 'Bulgaria'),
  Airport(iata: 'ZAG', city: 'Zagreb', country: 'Croatia'),
  Airport(iata: 'BEG', city: 'Belgrade', country: 'Serbia'),

  // --- Middle East -----------------------------------------------------
  Airport(iata: 'DXB', city: 'Dubai', country: 'United Arab Emirates'),
  Airport(iata: 'AUH', city: 'Abu Dhabi', country: 'United Arab Emirates'),
  Airport(iata: 'DOH', city: 'Doha', country: 'Qatar'),
  Airport(iata: 'JED', city: 'Jeddah', country: 'Saudi Arabia'),
  Airport(iata: 'RUH', city: 'Riyadh', country: 'Saudi Arabia'),
  Airport(iata: 'KWI', city: 'Kuwait City', country: 'Kuwait'),
  Airport(iata: 'BAH', city: 'Manama', country: 'Bahrain'),
  Airport(iata: 'MCT', city: 'Muscat', country: 'Oman'),
  Airport(iata: 'TLV', city: 'Tel Aviv', country: 'Israel'),
  Airport(iata: 'AMM', city: 'Amman', country: 'Jordan'),
  Airport(iata: 'BEY', city: 'Beirut', country: 'Lebanon'),

  // --- Africa --------------------------------------------------------------
  Airport(iata: 'CAI', city: 'Cairo', country: 'Egypt'),
  Airport(iata: 'HRG', city: 'Hurghada', country: 'Egypt'),
  Airport(iata: 'JNB', city: 'Johannesburg', country: 'South Africa'),
  Airport(iata: 'CPT', city: 'Cape Town', country: 'South Africa'),
  Airport(iata: 'NBO', city: 'Nairobi', country: 'Kenya'),
  Airport(iata: 'LOS', city: 'Lagos', country: 'Nigeria'),
  Airport(iata: 'ABV', city: 'Abuja', country: 'Nigeria'),
  Airport(iata: 'ACC', city: 'Accra', country: 'Ghana'),
  Airport(iata: 'ADD', city: 'Addis Ababa', country: 'Ethiopia'),
  Airport(iata: 'CMN', city: 'Casablanca', country: 'Morocco'),
  Airport(iata: 'RAK', city: 'Marrakesh', country: 'Morocco'),
  Airport(iata: 'TUN', city: 'Tunis', country: 'Tunisia'),
  Airport(iata: 'ALG', city: 'Algiers', country: 'Algeria'),
  Airport(iata: 'DAR', city: 'Dar es Salaam', country: 'Tanzania'),
  Airport(iata: 'ZNZ', city: 'Zanzibar', country: 'Tanzania'),
  Airport(iata: 'EBB', city: 'Entebbe', country: 'Uganda'),
  Airport(iata: 'MRU', city: 'Port Louis', country: 'Mauritius'),
  Airport(iata: 'SEZ', city: 'Mahé', country: 'Seychelles'),
  Airport(iata: 'DKR', city: 'Dakar', country: 'Senegal'),

  // --- Asia ----------------------------------------------------------------
  Airport(iata: 'SIN', city: 'Singapore', country: 'Singapore'),
  Airport(iata: 'HKG', city: 'Hong Kong', country: 'Hong Kong'),
  Airport(iata: 'BKK', city: 'Bangkok', country: 'Thailand'),
  Airport(iata: 'DMK', city: 'Bangkok', country: 'Thailand'),
  Airport(iata: 'HKT', city: 'Phuket', country: 'Thailand'),
  Airport(iata: 'NRT', city: 'Tokyo', country: 'Japan'),
  Airport(iata: 'HND', city: 'Tokyo', country: 'Japan'),
  Airport(iata: 'KIX', city: 'Osaka', country: 'Japan'),
  Airport(iata: 'ICN', city: 'Seoul', country: 'South Korea'),
  Airport(iata: 'GMP', city: 'Seoul', country: 'South Korea'),
  Airport(iata: 'PVG', city: 'Shanghai', country: 'China'),
  Airport(iata: 'SHA', city: 'Shanghai', country: 'China'),
  Airport(iata: 'PEK', city: 'Beijing', country: 'China'),
  Airport(iata: 'PKX', city: 'Beijing', country: 'China'),
  Airport(iata: 'CAN', city: 'Guangzhou', country: 'China'),
  Airport(iata: 'SZX', city: 'Shenzhen', country: 'China'),
  Airport(iata: 'CTU', city: 'Chengdu', country: 'China'),
  Airport(iata: 'TPE', city: 'Taipei', country: 'Taiwan'),
  Airport(iata: 'KUL', city: 'Kuala Lumpur', country: 'Malaysia'),
  Airport(iata: 'CGK', city: 'Jakarta', country: 'Indonesia'),
  Airport(iata: 'DPS', city: 'Denpasar (Bali)', country: 'Indonesia'),
  Airport(iata: 'MNL', city: 'Manila', country: 'Philippines'),
  Airport(iata: 'CEB', city: 'Cebu', country: 'Philippines'),
  Airport(iata: 'SGN', city: 'Ho Chi Minh City', country: 'Vietnam'),
  Airport(iata: 'HAN', city: 'Hanoi', country: 'Vietnam'),
  Airport(iata: 'PNH', city: 'Phnom Penh', country: 'Cambodia'),
  Airport(iata: 'RGN', city: 'Yangon', country: 'Myanmar'),
  Airport(iata: 'VTE', city: 'Vientiane', country: 'Laos'),
  Airport(iata: 'DEL', city: 'New Delhi', country: 'India'),
  Airport(iata: 'BOM', city: 'Mumbai', country: 'India'),
  Airport(iata: 'BLR', city: 'Bengaluru', country: 'India'),
  Airport(iata: 'MAA', city: 'Chennai', country: 'India'),
  Airport(iata: 'HYD', city: 'Hyderabad', country: 'India'),
  Airport(iata: 'CCU', city: 'Kolkata', country: 'India'),
  Airport(iata: 'GOI', city: 'Goa', country: 'India'),
  Airport(iata: 'KTM', city: 'Kathmandu', country: 'Nepal'),
  Airport(iata: 'DAC', city: 'Dhaka', country: 'Bangladesh'),
  Airport(iata: 'CMB', city: 'Colombo', country: 'Sri Lanka'),
  Airport(iata: 'MLE', city: 'Malé', country: 'Maldives'),
  Airport(iata: 'KHI', city: 'Karachi', country: 'Pakistan'),
  Airport(iata: 'LHE', city: 'Lahore', country: 'Pakistan'),
  Airport(iata: 'ISB', city: 'Islamabad', country: 'Pakistan'),
  Airport(iata: 'TAS', city: 'Tashkent', country: 'Uzbekistan'),
  Airport(iata: 'ALA', city: 'Almaty', country: 'Kazakhstan'),
  Airport(iata: 'UBN', city: 'Ulaanbaatar', country: 'Mongolia'),

  // --- Oceania -------------------------------------------------------------
  Airport(iata: 'SYD', city: 'Sydney', country: 'Australia'),
  Airport(iata: 'MEL', city: 'Melbourne', country: 'Australia'),
  Airport(iata: 'BNE', city: 'Brisbane', country: 'Australia'),
  Airport(iata: 'PER', city: 'Perth', country: 'Australia'),
  Airport(iata: 'ADL', city: 'Adelaide', country: 'Australia'),
  Airport(iata: 'AKL', city: 'Auckland', country: 'New Zealand'),
  Airport(iata: 'WLG', city: 'Wellington', country: 'New Zealand'),
  Airport(iata: 'NAN', city: 'Nadi', country: 'Fiji'),
  Airport(iata: 'POM', city: 'Port Moresby', country: 'Papua New Guinea'),
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
