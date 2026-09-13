import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_result.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  String? _baseUrl;

  String get baseUrl => _baseUrl ?? '';

  bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  void setBaseUrl(String value) => _baseUrl = value;

  void clear() => _baseUrl = null;

  static const Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  Future<ApiResult> get(
      String endpoint, {
        Map<String, String>? query,
        String? overrideBaseUrl,
        Duration timeout = ApiTimeouts.request,
      }) {
    final base = _resolveBase(overrideBaseUrl);

    final uri = Uri.parse('$base/$endpoint').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );

    return _send(() => _client.get(uri, headers: _headers), timeout);
  }

  Future<ApiResult> post(
      String endpoint,
      Map<String, dynamic> body, {
        String? overrideBaseUrl,
        Duration timeout = ApiTimeouts.request,
      }) {
    final base = _resolveBase(overrideBaseUrl);
    final uri = Uri.parse('$base/$endpoint');

    return _send(
          () => _client.post(uri, headers: _headers, body: jsonEncode(body)),
      timeout,
    );
  }

  String _resolveBase(String? overrideBaseUrl) {
    final base = overrideBaseUrl ?? _baseUrl;

    if (base == null || base.isEmpty) {
      throw ApiException(
        'No server address has been configured yet.',
        isNetworkIssue: true,
      );
    }

    return base;
  }

  Future<ApiResult> _send(
      Future<http.Response> Function() request,
      Duration timeout,
      ) async {
    late final http.Response response;

    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw ApiException(
        'The server did not respond in time. Check that Apache is running in '
            'XAMPP and that this device is on the same Wi-Fi network.',
        isNetworkIssue: true,
      );
    } on SocketException {
      throw ApiException(
        'Cannot reach the server at this address. Verify the IP address and '
            'that the server is switched on.',
        isNetworkIssue: true,
      );
    } on HttpException {
      throw ApiException(
        'The server returned a malformed response.',
        isNetworkIssue: true,
      );
    } on FormatException {
      throw ApiException(
        'The server address could not be understood.',
        isNetworkIssue: true,
      );
    }

    if (response.statusCode == 404) {
      throw ApiException(
        'A server answered, but the API was not found at this address. '
            'Confirm that the $kApiFolderName folder exists inside htdocs.',
        isNetworkIssue: true,
        statusCode: 404,
      );
    }

    if (response.body.isEmpty) {
      throw ApiException(
        'The server returned an empty response.',
        isNetworkIssue: true,
        statusCode: response.statusCode,
      );
    }

    late final Map<String, dynamic> decoded;

    try {
      final raw = jsonDecode(response.body);

      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Unexpected payload shape');
      }

      decoded = raw;
    } catch (_) {
      throw ApiException(
        'The response was not valid JSON. This address may not be the '
            'PasaHero API.',
        isNetworkIssue: true,
        statusCode: response.statusCode,
      );
    }

    return ApiResult.fromJson(decoded);
  }
}
