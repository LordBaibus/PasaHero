/// Client-side validation for the route form.
///
/// Mirrors the rules enforced by routes_create.php and routes_update.php so
/// obvious mistakes never leave the phone. The backend still re-checks
/// everything; this only saves the user a round trip.
class RouteValidator {
  const RouteValidator._();

  /// Parses a fare typed by the user. Returns `null` when it is not a number.
  static double? parseFare(String text) {
    final cleaned = text.trim().replaceAll(',', '');

    if (cleaned.isEmpty) {
      return null;
    }

    return double.tryParse(cleaned);
  }

  /// Returns `null` when every field is acceptable, otherwise the first
  /// problem found, phrased so it can be shown directly to the user.
  static String? validate({
    required String routeName,
    required String origin,
    required String destination,
    required String regularFareText,
    required String discountedFareText,
  }) {
    if (routeName.trim().isEmpty) {
      return 'Route name is required.';
    }

    if (routeName.trim().length > 120) {
      return 'Route name must not exceed 120 characters.';
    }

    if (origin.trim().isEmpty) {
      return 'Origin is required.';
    }

    if (destination.trim().isEmpty) {
      return 'Destination is required.';
    }

    if (origin.trim().toLowerCase() == destination.trim().toLowerCase()) {
      return 'Origin and destination must be different.';
    }

    final double? regular = parseFare(regularFareText);

    if (regular == null) {
      return 'Regular fare must be a valid number, for example 15.00';
    }

    if (regular < 0) {
      return 'Regular fare cannot be negative.';
    }

    if (regular > 99999.99) {
      return 'Regular fare is out of range.';
    }

    final double? discounted = parseFare(discountedFareText);

    if (discounted == null) {
      return 'Discounted fare must be a valid number, for example 12.00';
    }

    if (discounted < 0) {
      return 'Discounted fare cannot be negative.';
    }

    if (discounted > regular) {
      return 'Discounted fare cannot be higher than the regular fare.';
    }

    return null;
  }
}
