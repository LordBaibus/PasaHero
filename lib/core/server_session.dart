import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_config.dart';
import 'api_result.dart';
import 'ip_validator.dart';

class ServerSession {
  ServerSession._();

  static final ServerSession instance = ServerSession._();

  static const Duration heartbeatInterval = Duration(seconds: 5);

  static const int failureThreshold = 2;

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  final ValueNotifier<String> hostLabel = ValueNotifier<String>('');

  final ValueNotifier<String> serverVersion = ValueNotifier<String>('');

  Timer? _heartbeat;
  int _consecutiveFailures = 0;

  Future<String?> connect(String rawHost) async {
    // 1. Cheap format check first, so an obvious typo fails instantly.
    final formatError = IpValidator.validate(rawHost);

    if (formatError != null) {
      return formatError;
    }

    // 2. Build the candidate URL.
    final candidateBaseUrl = IpValidator.buildBaseUrl(rawHost);

    if (candidateBaseUrl.isEmpty) {
      return 'The server address could not be understood.';
    }

    // 3. Actually try to reach the API.
    try {
      final result = await ApiClient.instance.get(
        ApiEndpoints.ping,
        overrideBaseUrl: candidateBaseUrl,
        timeout: ApiTimeouts.connect,
      );

      if (!result.success) {
        return result.message.isEmpty
            ? 'The server rejected the connection request.'
            : result.message;
      }

      // 4. Confirm it is really our API and not some other web server.
      final data = result.dataAsMap;

      if (data == null || data['api'] != kApiIdentifier) {
        return 'A server answered at this address, but it is not the '
            'PasaHero API. Check the IP address and the folder name inside '
            'htdocs.';
      }

      ApiClient.instance.setBaseUrl(candidateBaseUrl);
      hostLabel.value = IpValidator.hostOnly(rawHost);
      serverVersion.value = (data['version'] ?? '').toString();
      _consecutiveFailures = 0;
      isConnected.value = true;

      startMonitoring();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred while connecting to the server.';
    }
  }

  void startMonitoring() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(heartbeatInterval, (_) => _pulse());
  }

  void stopMonitoring() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  Future<void> _pulse() async {
    if (!isConnected.value) {
      return;
    }

    try {
      final result = await ApiClient.instance.get(
        ApiEndpoints.ping,
        timeout: ApiTimeouts.heartbeat,
      );

      if (result.success) {
        _consecutiveFailures = 0;
        return;
      }

      _registerFailure();
    } catch (_) {
      // Any throw here means the server could not be reached.
      _registerFailure();
    }
  }

  void _registerFailure() {
    _consecutiveFailures += 1;

    if (_consecutiveFailures >= failureThreshold) {
      _markDisconnected();
    }
  }

  void _markDisconnected() {
    stopMonitoring();
    _consecutiveFailures = 0;
    // Flipping this notifier is what triggers the dialog in main.dart.
    isConnected.value = false;
  }

  void reset() {
    stopMonitoring();
    _consecutiveFailures = 0;
    ApiClient.instance.clear();
    hostLabel.value = '';
    serverVersion.value = '';
    isConnected.value = false;
  }
}
