class Booking {
  final String id;
  final String bookingRef;
  final String airline;
  final String flightCode;
  final String departCode;
  final String arriveCode;
  final String departTime;
  final String arriveTime;
  final DateTime departDate;
  final String duration;
  final String stops;
  final String seatNumber;
  final String cabinClass;
  final int passengers;
  final double totalPrice;
  final String status;
  final bool isUpcoming;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.bookingRef,
    required this.airline,
    required this.flightCode,
    required this.departCode,
    required this.arriveCode,
    required this.departTime,
    required this.arriveTime,
    required this.departDate,
    required this.duration,
    required this.stops,
    required this.seatNumber,
    required this.cabinClass,
    required this.passengers,
    required this.totalPrice,
    required this.status,
    required this.isUpcoming,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      bookingRef: json['bookingRef'] as String? ?? '',
      airline: json['airline'] as String? ?? '',
      flightCode: json['flightCode'] as String? ?? '',
      departCode: json['departCode'] as String? ?? '',
      arriveCode: json['arriveCode'] as String? ?? '',
      departTime: json['departTime'] as String? ?? '--:--',
      arriveTime: json['arriveTime'] as String? ?? '--:--',
      departDate: DateTime.tryParse(json['departDate'] as String? ?? '') ?? DateTime.now(),
      duration: json['duration'] as String? ?? '',
      stops: json['stops'] as String? ?? 'Non-stop',
      seatNumber: json['seatNumber'] as String? ?? '',
      cabinClass: json['cabinClass'] as String? ?? 'Economy',
      passengers: (json['passengers'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'Confirmed',
      isUpcoming: json['isUpcoming'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${departDate.day} ${months[departDate.month - 1]}, ${departDate.year}';
  }
}
