import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class LiveMediaResponse {
  const LiveMediaResponse({
    required this.statusCode,
    required this.bytes,
    required this.finalUri,
    this.headers = const {},
  });

  final int statusCode;
  final Uint8List bytes;
  final Uri finalUri;
  final Map<String, String> headers;
  String get body => utf8.decode(bytes, allowMalformed: true);
}

abstract interface class LiveMediaTransport {
  Future<LiveMediaResponse> get(Uri uri, {Map<String, String> headers});
  void close();
}

class HttpLiveMediaTransport implements LiveMediaTransport {
  HttpLiveMediaTransport({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final Map<String, String> _cookies = {};

  static const userAgent =
      'Mozilla/5.0 (Android; Mobile) AppleWebKit/537.36 Chrome/140 Safari/537.36';

  @override
  Future<LiveMediaResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final origin =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    final cookie = _cookies[origin];
    final response = await _client
        .get(
          uri,
          headers: {
            'User-Agent': userAgent,
            'Accept': '*/*',
            if (cookie != null) 'Cookie': cookie,
            ...headers,
          },
        )
        .timeout(timeout);
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final pairs = RegExp(
        r'(?:^|,\s*)([^;,=\s]+=[^;,]*)',
      ).allMatches(setCookie).map((match) => match.group(1)!).toList();
      if (pairs.isNotEmpty) _cookies[origin] = pairs.join('; ');
    }
    return LiveMediaResponse(
      statusCode: response.statusCode,
      bytes: response.bodyBytes,
      finalUri: response.request?.url ?? uri,
      headers: response.headers,
    );
  }

  @override
  void close() => _client.close();
}
