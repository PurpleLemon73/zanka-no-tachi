import 'adapter_descriptor.dart';

sealed class AdapterException implements Exception {
  const AdapterException(this.adapterId, this.message, {this.cause});
  final AdapterId adapterId;
  final String message;
  final Object? cause;
  @override
  String toString() => '$runtimeType(${adapterId.value}): $message';
}

class AdapterConfigurationError extends AdapterException {
  const AdapterConfigurationError(super.id, super.message, {super.cause});
}

class AdapterNetworkError extends AdapterException {
  const AdapterNetworkError(super.id, super.message, {super.cause});
}

class AdapterHttpError extends AdapterException {
  const AdapterHttpError(super.id, super.message, {required this.statusCode});
  final int statusCode;
}

class AdapterParseError extends AdapterException {
  const AdapterParseError(super.id, super.message, {super.cause});
}

class AdapterRateLimitError extends AdapterException {
  const AdapterRateLimitError(super.id, super.message, {super.cause});
}

class AdapterUnsupportedCapability extends AdapterException {
  const AdapterUnsupportedCapability(super.id, super.message);
}

class AdapterUnavailable extends AdapterException {
  const AdapterUnavailable(super.id, super.message, {super.cause});
}

class AdapterEnrichmentConflict extends AdapterException {
  const AdapterEnrichmentConflict(super.id, super.message);
}
