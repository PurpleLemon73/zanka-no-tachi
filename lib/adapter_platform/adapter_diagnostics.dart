import '../live_provider/live_provider_repository.dart';
import 'adapter_descriptor.dart';
import 'adapter_state.dart';
import '../live_media/live_media_diagnostics.dart';

class AdapterDiagnosticEntry {
  const AdapterDiagnosticEntry({
    required this.descriptor,
    this.configuration,
    this.reliability,
    this.liveManifest,
  });

  final AdapterDescriptor descriptor;
  final PersistedAdapterConfiguration? configuration;
  final AdapterReliability? reliability;
  final LiveManifestDiagnostic? liveManifest;

  bool get paginationEnabled =>
      descriptor.supports(AdapterCapability.pagination);
}

class AdapterDiagnosticsService {
  const AdapterDiagnosticsService(this.repository);
  final LiveProviderRepository repository;

  Future<List<AdapterDiagnosticEntry>> snapshot() async {
    final configurations = {
      for (final value in await repository.database.allAdapterConfigurations())
        value.adapterId: value,
    };
    final reliability = {
      for (final value in await repository.database.allAdapterReliability())
        value.adapterId: value,
    };
    return repository.adapters.descriptors
        .map(
          (descriptor) => AdapterDiagnosticEntry(
            descriptor: descriptor,
            configuration: configurations[descriptor.id],
            reliability: reliability[descriptor.id],
            liveManifest:
                descriptor.supports(AdapterCapability.readerManifest) ||
                    descriptor.supports(AdapterCapability.playbackManifest)
                ? LiveMediaDiagnostics.instance.forProvider(
                    descriptor.id.providerId,
                  )
                : null,
          ),
        )
        .toList();
  }
}
