/// Single source of truth for the PasaHero PHP API contract.
///
/// If the folder inside htdocs is ever renamed, only [kApiFolderName] changes
/// and the whole application follows.
library;

/// Name of the folder placed inside C:\xampp\htdocs\
const String kApiFolderName = 'pasahero_api';

/// Path appended to whatever IP address the user types on the connect screen.
///
/// Typing `192.168.1.14` produces `http://192.168.1.14/pasahero_api/api`.
const String kApiBasePath = '/$kApiFolderName/api';

/// Value returned by ping.php in the `api` field.
///
/// The client checks this so that a random web server answering on port 80
/// is not mistaken for the PasaHero backend.
const String kApiIdentifier = 'pasahero-api';

/// Filenames of the PHP endpoints.
class ApiEndpoints {
  const ApiEndpoints._();

  /// Health check. Used for IP validation and for disconnection detection.
  static const String ping = 'ping.php';

  /// READ — list routes, filter them, or fetch one by id.
  static const String readRoutes = 'routes_read.php';

  /// CREATE — insert a new route.
  static const String createRoute = 'routes_create.php';

  /// UPDATE — modify an existing route.
  static const String updateRoute = 'routes_update.php';

  /// DELETE — remove an existing route.
  static const String deleteRoute = 'routes_delete.php';
}

/// Network timeouts used across the application.
class ApiTimeouts {
  const ApiTimeouts._();

  /// First handshake when the user taps Connect. Generous on purpose —
  /// campus Wi-Fi can be slow on the first request.
  static const Duration connect = Duration(seconds: 8);

  /// Normal CRUD requests.
  static const Duration request = Duration(seconds: 10);

  /// Background heartbeat. Kept short so a dead server is noticed quickly.
  static const Duration heartbeat = Duration(seconds: 4);
}

/// Vehicle types accepted by the `vehicle_type` ENUM column.
class VehicleTypes {
  const VehicleTypes._();

  static const String jeepney = 'jeepney';
  static const String tricycle = 'tricycle';
  static const String bus = 'bus';
  static const String uvExpress = 'uv_express';

  static const List<String> all = <String>[
    jeepney,
    tricycle,
    bus,
    uvExpress,
  ];
}


