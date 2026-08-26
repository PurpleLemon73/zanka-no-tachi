import '../canonical/domain/identifiers.dart';

enum LiveManifestState {
  neverResolved,
  available,
  networkFailure,
  parserMismatch,
  unsupported,
}

class LiveManifestDiagnostic {
  const LiveManifestDiagnostic({
    required this.state,
    this.checkedAt,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.lastParserMismatchAt,
    this.summary,
    this.failureClass,
    this.mediaType,
    this.freshRetryRecovered = false,
  });
  final LiveManifestState state;
  final DateTime? checkedAt;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final DateTime? lastParserMismatchAt;
  final String? summary;
  final String? failureClass;
  final String? mediaType;
  final bool freshRetryRecovered;
}

class LiveMediaDiagnostics {
  LiveMediaDiagnostics._();
  static final instance = LiveMediaDiagnostics._();
  final Map<ProviderId, LiveManifestDiagnostic> _providers = {};
  final Map<_BindingKey, LiveManifestDiagnostic> _bindings = {};

  LiveManifestDiagnostic forProvider(ProviderId id) =>
      _providers[id] ??
      const LiveManifestDiagnostic(state: LiveManifestState.neverResolved);

  LiveManifestDiagnostic forBinding(ProviderId id, String externalId) =>
      _bindings[_BindingKey(id, externalId)] ??
      const LiveManifestDiagnostic(state: LiveManifestState.neverResolved);

  void record(
    ProviderId id,
    LiveManifestState state,
    String summary, {
    String? externalId,
    String? mediaType,
    bool freshRetryRecovered = false,
  }) {
    final now = DateTime.now().toUtc();
    final previous = externalId == null
        ? forProvider(id)
        : forBinding(id, externalId);
    final value = LiveManifestDiagnostic(
      state: state,
      checkedAt: now,
      lastSuccessAt: state == LiveManifestState.available
          ? now
          : previous.lastSuccessAt,
      lastFailureAt: state != LiveManifestState.available
          ? now
          : previous.lastFailureAt,
      lastParserMismatchAt: state == LiveManifestState.parserMismatch
          ? now
          : previous.lastParserMismatchAt,
      summary: _sanitizeSummary(summary),
      failureClass: state == LiveManifestState.available ? null : state.name,
      mediaType: mediaType ?? previous.mediaType,
      freshRetryRecovered:
          freshRetryRecovered ||
          (state == LiveManifestState.available &&
              previous.state != LiveManifestState.neverResolved &&
              previous.state != LiveManifestState.available),
    );
    _providers[id] = value;
    if (externalId != null) _bindings[_BindingKey(id, externalId)] = value;
  }

  void clearForTests() {
    _providers.clear();
    _bindings.clear();
  }
}

String _sanitizeSummary(String value) => value
    .replaceAll(RegExp(r'https?://[^\s]+', caseSensitive: false), '[remote]')
    .replaceAllMapped(
      RegExp(r'(token|csrf|cookie)=?[^\s,;]*', caseSensitive: false),
      (match) => '${match.group(1)}=[redacted]',
    );

class _BindingKey {
  const _BindingKey(this.providerId, this.externalId);
  final ProviderId providerId;
  final String externalId;

  @override
  bool operator ==(Object other) =>
      other is _BindingKey &&
      other.providerId == providerId &&
      other.externalId == externalId;

  @override
  int get hashCode => Object.hash(providerId, externalId);
}
