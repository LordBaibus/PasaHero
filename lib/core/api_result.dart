/// Dart representation of the JSON envelope every PasaHero endpoint returns.
///
/// The PHP side always answers with exactly this shape:
///
/// ```json
/// { "success": true, "message": "2 route(s) retrieved.", "data": [ ... ] }
/// ```
library;

/// A decoded response from the PHP API.
class ApiResult {
  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });

  /// Mirrors the `success` boolean from PHP.
  final bool success;

  /// Human-readable message written by the backend. Safe to show to the user.
  final String message;

  /// Payload. A `List` for reads, a `Map` for single records, `null` otherwise.
  final dynamic data;

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'],
    );
  }

  /// Convenience accessor for endpoints that return a single record.
  Map<String, dynamic>? get dataAsMap {
    final value = data;
    return value is Map<String, dynamic> ? value : null;
  }

  /// Convenience accessor for endpoints that return a list of records.
  List<dynamic>? get dataAsList {
    final value = data;
    return value is List ? value : null;
  }

  @override
  String toString() => 'ApiResult(success: $success, message: $message)';
}

/// Thrown whenever a request cannot produce a usable [ApiResult].
///
/// [isNetworkIssue] separates "the server is unreachable" from "the server
/// answered but refused the request". The connect screen and the heartbeat
/// only care about the first kind.
class ApiException implements Exception {
  ApiException(
      this.message, {
        this.isNetworkIssue = false,
        this.statusCode,
      });

  /// Message intended to be displayed directly inside a glass dialog.
  final String message;

  /// True when the failure was a timeout, a socket error, or a bad host.
  final bool isNetworkIssue;

  /// HTTP status code, when one was actually received.
  final int? statusCode;

  @override
  String toString() => message;
}