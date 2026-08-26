import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';

enum ProviderHealthState {
  available,
  unreachable,
  unexpectedResponse,
  parserMismatch,
  disabled,
}

class ProviderHealth {
  const ProviderHealth({required this.state, this.diagnostic});

  final ProviderHealthState state;
  final String? diagnostic;
}

class ProviderConfig {
  const ProviderConfig({
    required this.id,
    required this.displayName,
    required this.baseUrl,
    required this.mediaKind,
    this.enabled = true,
  });

  final ProviderId id;
  final String displayName;
  final Uri baseUrl;
  final CanonicalMediaKind mediaKind;
  final bool enabled;

  ProviderConfig copyWith({Uri? baseUrl, bool? enabled}) => ProviderConfig(
    id: id,
    displayName: displayName,
    baseUrl: baseUrl ?? this.baseUrl,
    mediaKind: mediaKind,
    enabled: enabled ?? this.enabled,
  );

  Uri resolve(String relative) => baseUrl.resolve(relative);
}

class ProviderRegistry {
  ProviderRegistry(Iterable<ProviderConfig> providers)
    : _providers = {for (final provider in providers) provider.id: provider};

  factory ProviderRegistry.defaults() => ProviderRegistry([
    ProviderConfig(
      id: const ProviderId('mangaworld'),
      displayName: 'MangaWorld',
      baseUrl: Uri.parse('https://www.mangaworld.mx/'),
      mediaKind: CanonicalMediaKind.manga,
    ),
    ProviderConfig(
      id: const ProviderId('animeworld'),
      displayName: 'AnimeWorld',
      baseUrl: Uri.parse('https://www.animeworld.ac/'),
      mediaKind: CanonicalMediaKind.anime,
    ),
  ]);

  final Map<ProviderId, ProviderConfig> _providers;

  List<ProviderConfig> get all => List.unmodifiable(_providers.values);

  ProviderConfig require(ProviderId id) {
    final provider = _providers[id];
    if (provider == null) throw StateError('Unknown provider: ${id.value}');
    return provider;
  }

  void replace(ProviderConfig config) => _providers[config.id] = config;
}
