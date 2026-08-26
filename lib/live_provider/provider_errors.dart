import '../canonical/domain/identifiers.dart';

sealed class ProviderException implements Exception {
  const ProviderException(this.providerId, this.message, {this.cause});

  final ProviderId providerId;
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType(${providerId.value}): $message';
}

class ProviderNetworkException extends ProviderException {
  const ProviderNetworkException(
    super.providerId,
    super.message, {
    super.cause,
  });
}

class ProviderHttpException extends ProviderException {
  const ProviderHttpException(
    super.providerId,
    super.message, {
    required this.statusCode,
  });
  final int statusCode;
}

class ProviderParserException extends ProviderException {
  const ProviderParserException(super.providerId, super.message, {super.cause});
}

class ProviderConfigurationException extends ProviderException {
  const ProviderConfigurationException(super.providerId, super.message);
}

class ProviderDisabledException extends ProviderException {
  const ProviderDisabledException(ProviderId providerId)
    : super(providerId, 'Provider is disabled');
}
