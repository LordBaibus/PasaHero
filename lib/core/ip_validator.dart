import 'api_config.dart';

class IpValidator {
  const IpValidator._();


  static const Set<String> _allowedHostnames = <String>{
    'localhost',
    '10.0.2.2',
  };

  static final RegExp _ipv4Pattern =
  RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');


  static String? validate(String rawInput) {
    final input = rawInput.trim();

    if (input.isEmpty) {
      return 'Please enter the server IP address.';
    }

    final withoutScheme =
    input.replaceFirst('http://', '').replaceFirst('https://', '');

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

    if (parsed.path.isNotEmpty && parsed.path != '/') {
      return input;
    }

    return '$input$kApiBasePath';
  }


  static String hostOnly(String rawInput) {
    final withoutScheme = rawInput
        .trim()
        .replaceFirst('http://', '')
        .replaceFirst('https://', '');

    return withoutScheme.split('/').first;
  }
}
