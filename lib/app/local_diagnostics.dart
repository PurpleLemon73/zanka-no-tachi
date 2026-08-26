import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LocalLogLevel { debug, info, warning, error }

class DiagnosticRecord {
  const DiagnosticRecord({
    required this.timestamp,
    required this.level,
    required this.area,
    required this.message,
  });
  final DateTime timestamp;
  final LocalLogLevel level;
  final String area;
  final String message;

  Map<String, Object?> toJson() => {
    'timestamp': timestamp.toUtc().toIso8601String(),
    'level': level.name,
    'area': area,
    'message': message,
  };

  factory DiagnosticRecord.fromJson(Map<String, dynamic> value) =>
      DiagnosticRecord(
        timestamp: DateTime.parse(value['timestamp'] as String),
        level: LocalLogLevel.values.byName(value['level'] as String),
        area: value['area'] as String,
        message: value['message'] as String,
      );
}

class LocalDiagnostics {
  LocalDiagnostics({
    File? file,
    this.maximumRecords = 100,
    this.maximumBytes = 64 * 1024,
  }) : _injectedFile = file;

  final File? _injectedFile;
  final int maximumRecords;
  final int maximumBytes;
  final List<DiagnosticRecord> _records = [];
  bool _loaded = false;
  bool _writing = false;

  Future<File> _file() async =>
      _injectedFile ??
      File('${(await getApplicationSupportDirectory()).path}/diagnostics.json');

  Future<List<DiagnosticRecord>> records() async {
    await _load();
    return List.unmodifiable(_records);
  }

  Future<void> record(
    LocalLogLevel level,
    String area,
    String message, {
    Object? error,
  }) async {
    if (level == LocalLogLevel.debug && kReleaseMode) return;
    try {
      await _load();
      final combined = error == null
          ? message
          : '$message: ${error.runtimeType}';
      _records.add(
        DiagnosticRecord(
          timestamp: DateTime.now().toUtc(),
          level: level,
          area: _redact(area, maximumLength: 48),
          message: _redact(combined, maximumLength: 500),
        ),
      );
      _bound();
      await _persist();
    } on Object {
      // Diagnostics must never create a crash loop.
    }
  }

  Future<void> captureFlutterError(FlutterErrorDetails details) => record(
    LocalLogLevel.error,
    'flutter',
    details.context?.toDescription() ?? 'Flutter framework error',
    error: details.exception,
  );

  Future<void> captureUncaught(Object error) => record(
    LocalLogLevel.error,
    'uncaught',
    'Unhandled asynchronous error',
    error: error,
  );

  Future<void> clear() async {
    _records.clear();
    _loaded = true;
    final file = await _file();
    if (await file.exists()) await file.delete();
  }

  Future<String> redactedReport() async {
    await _load();
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'zanka-local-diagnostics',
      'records': _records.map((value) => value.toJson()).toList(),
    });
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final file = await _file();
      if (!await file.exists() || await file.length() > maximumBytes) return;
      final value = jsonDecode(await file.readAsString());
      if (value is List) {
        _records.addAll(
          value.whereType<Map<String, dynamic>>().map(
            DiagnosticRecord.fromJson,
          ),
        );
      }
      _bound();
    } on Object {
      _records.clear();
    }
  }

  void _bound() {
    while (_records.length > maximumRecords) {
      _records.removeAt(0);
    }
    while (_records.length > 1 &&
        utf8
                .encode(
                  jsonEncode(_records.map((value) => value.toJson()).toList()),
                )
                .length >
            maximumBytes) {
      _records.removeAt(0);
    }
  }

  Future<void> _persist() async {
    if (_writing) return;
    _writing = true;
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.partial');
      await temporary.writeAsString(
        jsonEncode(_records.map((value) => value.toJson()).toList()),
        flush: true,
      );
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    } finally {
      _writing = false;
    }
  }
}

String _redact(String value, {required int maximumLength}) {
  var result = value
      .replaceAll(
        RegExp(
          r'([?&](?:token|key|sig|auth|password)=)[^&\s]+',
          caseSensitive: false,
        ),
        r'$1[redacted]',
      )
      .replaceAll(
        RegExp(r'https?://[^\s?#]+[^\s]*', caseSensitive: false),
        '[url redacted]',
      )
      .replaceAll(
        RegExp(r'(?:/Users/|/home/|[A-Za-z]:\\)[^\s]+'),
        '[path redacted]',
      )
      .replaceAll(
        RegExp(r'Bearer\s+\S+', caseSensitive: false),
        'Bearer [redacted]',
      );
  if (result.length > maximumLength) {
    result = '${result.substring(0, maximumLength)}…';
  }
  return result;
}
