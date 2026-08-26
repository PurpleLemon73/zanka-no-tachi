import 'dart:async';

import 'package:http/http.dart' as http;

class ProviderResponse {
  const ProviderResponse({
    required this.statusCode,
    required this.body,
    required this.finalUri,
  });

  final int statusCode;
  final String body;
  final Uri finalUri;
}

abstract interface class ProviderTransport {
  Future<ProviderResponse> get(Uri uri);
  void close();
}

class HttpProviderTransport implements ProviderTransport {
  HttpProviderTransport({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
    this.maxTransientRetries = 1,
    this.userAgent = 'ZankaNoTachi/0.2 (+public metadata validation)',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final int maxTransientRetries;
  final String userAgent;

  @override
  Future<ProviderResponse> get(Uri uri) async {
    Object? lastError;
    for (var attempt = 0; attempt <= maxTransientRetries; attempt++) {
      try {
        final response = await _client
            .get(uri, headers: {'User-Agent': userAgent})
            .timeout(timeout);
        if (_isTransient(response.statusCode) &&
            attempt < maxTransientRetries) {
          continue;
        }
        return ProviderResponse(
          statusCode: response.statusCode,
          body: response.body,
          finalUri: response.request?.url ?? uri,
        );
      } on Object catch (error) {
        lastError = error;
        if (attempt == maxTransientRetries) rethrow;
      }
    }
    throw StateError('Transport retry loop exhausted: $lastError');
  }

  bool _isTransient(int status) =>
      status == 408 || status == 429 || status >= 500;

  @override
  void close() => _client.close();
}
