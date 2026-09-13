import '../models/booking.dart';
import '../models/flight.dart';
import 'api_client.dart';

class BookingService {
  final _client = ApiClient();

  Future<List<Booking>> listBookings() async {
    final data = await _client.get('/api/bookings') as List;
    return data.whereType<Map<String, dynamic>>().map(Booking.fromJson).toList();
  }

  /// Creates a booking on the backend once payment succeeds, and returns
  /// it (with a real, server-generated booking reference). [paymentMethod]
  /// should be the result of a prior [PaymentService.simulate] call —
  /// only "wallet" debits the wallet ledger here, since card / bank
  /// transfer / other were already charged directly by that call.
  Future<Booking> createBooking({
    required Flight flight,
    required String seatNumber,
    required String cabinClass,
    required int passengers,
    required double totalPrice,
    String? paymentMethod,
    String? paymentMethodLabel,
    String? paymentReference,
  }) async {
    final departDate = _toIsoDate(flight.date) ?? DateTime.now().toIso8601String().split('T').first;
    final response = await _client.post('/api/bookings', {
      'airline': flight.airline,
      'flightCode': flight.flightCode,
      'departCode': flight.departCode,
      'arriveCode': flight.arriveCode,
      'departTime': flight.departTime,
      'arriveTime': flight.arriveTime,
      'departDate': departDate,
      'duration': flight.duration,
      'stops': flight.stops,
      'seatNumber': seatNumber,
      'cabinClass': cabinClass,
      'passengers': passengers,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentMethodLabel': paymentMethodLabel,
      'paymentReference': paymentReference,
    }) as Map<String, dynamic>;
    return Booking.fromJson(response);
  }

  /// Flight.date looks like "15 Jun, 2023" — converts it to "yyyy-MM-dd"
  /// for the backend's DateOnly field. Falls back to null if unparseable.
  String? _toIsoDate(String display) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final match = RegExp(r'^(\d{1,2})\s+(\w{3}),?\s*(\d{4})$').firstMatch(display.trim());
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = months[match.group(2)];
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
