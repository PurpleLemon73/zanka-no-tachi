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
    this.summary,
  });
  final LiveManifestState state;
  final DateTime? checkedAt;
  final String? summary;
}

class LiveMediaDiagnostics {
  LiveMediaDiagnostics._();
  static final instance = LiveMediaDiagnostics._();
  final Map<ProviderId, LiveManifestDiagnostic> _values = {};

  LiveManifestDiagnostic forProvider(ProviderId id) =>
      _values[id] ??
      const LiveManifestDiagnostic(state: LiveManifestState.neverResolved);

  void record(ProviderId id, LiveManifestState state, String summary) {
    _values[id] = LiveManifestDiagnostic(
      state: state,
      checkedAt: DateTime.now().toUtc(),
      summary: summary,
    );
  }
}
