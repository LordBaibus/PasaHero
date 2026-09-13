import '../core/api_config.dart';

class JeepRoute {
  const JeepRoute({
    required this.id,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.vehicleType,
    required this.regularFare,
    required this.discountedFare,
    required this.operatingHours,
    required this.notes,
    required this.isActive,
  });

  final int id;
  final String routeName;
  final String origin;
  final String destination;


  final String vehicleType;

  final double regularFare;
  final double discountedFare;
  final String operatingHours;
  final String notes;
  final bool isActive;


  static String vehicleLabel(String type) {
    switch (type) {
      case VehicleTypes.tricycle:
        return 'Tricycle';
      case VehicleTypes.bus:
        return 'Bus';
      case VehicleTypes.uvExpress:
        return 'UV Express';
      case VehicleTypes.jeepney:
      default:
        return 'Jeepney';
    }
  }

  String get vehicleTypeLabel => vehicleLabel(vehicleType);


  String get corridor => '$origin  \u2192  $destination';

  String get regularFareLabel => '\u20B1${regularFare.toStringAsFixed(2)}';

  String get discountedFareLabel => '\u20B1${discountedFare.toStringAsFixed(2)}';


  factory JeepRoute.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic value) =>
        double.tryParse(value?.toString() ?? '') ?? 0.0;

    return JeepRoute(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      routeName: (json['route_name'] ?? '').toString(),
      origin: (json['origin'] ?? '').toString(),
      destination: (json['destination'] ?? '').toString(),
      vehicleType: (json['vehicle_type'] ?? VehicleTypes.jeepney).toString(),
      regularFare: parseAmount(json['regular_fare']),
      discountedFare: parseAmount(json['discounted_fare']),
      operatingHours: (json['operating_hours'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      isActive:
      json['is_active'] == true || json['is_active']?.toString() == '1',
    );
  }


  Map<String, dynamic> toPayload({bool includeId = false}) {
    return <String, dynamic>{
      if (includeId) 'id': id,
      'route_name': routeName,
      'origin': origin,
      'destination': destination,
      'vehicle_type': vehicleType,
      'regular_fare': regularFare,
      'discounted_fare': discountedFare,
      'operating_hours': operatingHours,
      'notes': notes,
      'is_active': isActive,
    };
  }

  JeepRoute copyWith({
    int? id,
    String? routeName,
    String? origin,
    String? destination,
    String? vehicleType,
    double? regularFare,
    double? discountedFare,
    String? operatingHours,
    String? notes,
    bool? isActive,
  }) {
    return JeepRoute(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      vehicleType: vehicleType ?? this.vehicleType,
      regularFare: regularFare ?? this.regularFare,
      discountedFare: discountedFare ?? this.discountedFare,
      operatingHours: operatingHours ?? this.operatingHours,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  static const JeepRoute blank = JeepRoute(
    id: 0,
    routeName: '',
    origin: '',
    destination: '',
    vehicleType: VehicleTypes.jeepney,
    regularFare: 0,
    discountedFare: 0,
    operatingHours: '',
    notes: '',
    isActive: true,
  );
}
