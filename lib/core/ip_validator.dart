import 'api_config.dart';

/// Format checks and URL construction for the server address the user types
/// on the connect screen.
///
/// This class never touches the network. It answers one question only:
/// *could* this text possibly be a server address? Whether a server is
/// actually listening there is decided later by [ServerSession.connect].
class IpValidator {
  const IpValidator._();

  /// Hostnames accepted in addition to a numeric IPv4 address.
  ///
  /// `10.0.2.2` is how the Android emulator reaches the host machine, which
  /// is handy while developing before testing on a real phone.
  static const Set<String> _allowedHostnames = <String>{
    'localhost',
    '10.0.2.2',
  };

  static final RegExp _ipv4Pattern =
  RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

  /// Returns `null` when [rawInput] is acceptable, otherwise a message that is
  /// ready to be shown inside an error dialog.
  ///
  /// Accepted shapes:
  ///   192.168.1.14
  ///   192.168.1.14:8080
  ///   http://192.168.1.14
  ///   localhost
  static String? validate(String rawInput) {
    final input = rawInput.trim();

    if (input.isEmpty) {
      return 'Please enter the server IP address.';
    }

    // Strip the scheme so the same logic works with or without http://.
    final withoutScheme =
    input.replaceFirst('http://', '').replaceFirst('https://', '');

    // Keep only the authority part, dropping any path the user pasted.
    final authority = withoutScheme.split('/').first;

    if (authority.isEmpty) {
      return 'The server address is incomplete.';
    }

    final segments = authority.split(':');

    if (segments.length > 2) {
      return 'The server address contains too many colons.';
    }

    if (segments.length == 2) {
      final port = int.tryParse(segments[1]);
      if (port == null || port < 1 || port > 65535) {
        return 'The port number is invalid. Use a value between 1 and 65535.';
      }
    }

    final host = segments.first;

    if (_allowedHostnames.contains(host.toLowerCase())) {
      return null;
    }

    final match = _ipv4Pattern.firstMatch(host);

    if (match == null) {
      return 'Invalid format. Enter an IPv4 address such as 192.168.1.14.';
    }

    for (var group = 1; group <= 4; group++) {
      final octet = int.tryParse(match.group(group)!);
      if (octet == null || octet > 255) {
        return 'Each part of the IP address must be between 0 and 255.';
      }
    }

    return null;
  }

  /// Turns what the user typed into a fully-qualified API base URL.
  ///
  ///   `192.168.1.14`  ->  `http://192.168.1.14/pasahero_api/api`
  ///
  /// Returns an empty string when the input cannot be parsed at all.
  static String buildBaseUrl(String rawInput) {
    var input = rawInput.trim();

    if (input.isEmpty) {
      return '';
    }

    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'http://$input';
    }

    while (input.endsWith('/')) {
      input = input.substring(0, input.length - 1);
    }

    final parsed = Uri.tryParse(input);

    if (parsed == null || parsed.host.isEmpty) {
      return '';
    }

    // If the user already supplied a path, respect it instead of appending
    // our own. This lets an advanced user point at a renamed folder.
    if (parsed.path.isNotEmpty && parsed.path != '/') {
      return input;
    }

    return '$input$kApiBasePath';
  }

  /// The host portion on its own, used for display in dialogs and headers.
  static String hostOnly(String rawInput) {
    final withoutScheme = rawInput
        .trim()
        .replaceFirst('http://', '')
        .replaceFirst('https://', '');

    return withoutScheme.split('/').first;
  }
}
