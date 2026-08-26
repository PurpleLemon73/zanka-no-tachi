import 'adapter_descriptor.dart';

class PersistedAdapterConfiguration {
  const PersistedAdapterConfiguration({
    required this.adapterId,
    required this.enabled,
    required this.baseUrl,
    required this.order,
    required this.updatedAt,
  });
  final AdapterId adapterId;
  final bool enabled;
  final Uri? baseUrl;
  final int order;
  final DateTime updatedAt;
}

class AdapterReliability {
  const AdapterReliability({
    required this.adapterId,
    this.lastCheckedAt,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.consecutiveFailures = 0,
    this.lastParserMismatchAt,
    this.lastError,
  });
  final AdapterId adapterId;
  final DateTime? lastCheckedAt;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final int consecutiveFailures;
  final DateTime? lastParserMismatchAt;
  final String? lastError;
}
