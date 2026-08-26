import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../live_provider/provider_registry.dart';
import '../player/playback_domain.dart';
import '../player/playback_source.dart';
import 'live_media_transport.dart';
import 'live_media_diagnostics.dart';

const animeWorldProviderId = ProviderId('animeworld');

class AnimeWorldPlaybackSource implements PlaybackSourceResolver {
  AnimeWorldPlaybackSource({
    required ProviderConfig config,
    required this.transport,
  }) : _config = (() => config);
  AnimeWorldPlaybackSource.fromRegistry({
    required ProviderRegistry registry,
    required this.transport,
  }) : _config = (() => registry.require(animeWorldProviderId));
  final ProviderConfig Function() _config;
  final LiveMediaTransport transport;
  ProviderConfig get config => _config();
  @override
  ProviderId get providerId => animeWorldProviderId;

  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      config.enabled && binding.relativeLocator != null
      ? PlaybackSourceCapability.playbackCapable
      : PlaybackSourceCapability.temporarilyUnavailable;

  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async {
    final binding = request.binding;
    if (binding == null ||
        binding.providerId != providerId ||
        binding.relativeLocator == null) {
      throw const PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'This AnimeWorld episode is unavailable.',
      );
    }
    try {
      final pageUri = config.resolve(binding.relativeLocator!);
      final page = await transport.get(pageUri);
      _requireSuccess(page, 'episode page');
      final document = html_parser.parse(page.body);
      final csrf = document
          .querySelector('meta[name="csrf-token"]')
          ?.attributes['content'];
      final episodeToken =
          document
              .querySelector(
                '.episode a.active, a.episode.active, .episodes a[data-id="${binding.externalId}"]',
              )
              ?.attributes['data-id'] ??
          binding.externalId;
      if (csrf == null || csrf.isEmpty || episodeToken.isEmpty) {
        throw const PlaybackException(
          PlaybackErrorKind.manifestInvalid,
          'AnimeWorld episode markers changed.',
        );
      }
      final infoUri = config.baseUrl
          .resolve('/api/episode/info')
          .replace(queryParameters: {'id': episodeToken, 'alt': '0'});
      final info = await transport.get(
        infoUri,
        headers: {
          'CSRF-Token': csrf,
          'Accept': 'application/json',
          'Referer': pageUri.toString(),
        },
      );
      _requireSuccess(info, 'episode manifest');
      final decoded = jsonDecode(info.body);
      if (decoded is! Map || decoded['target'] is! String) {
        throw const PlaybackException(
          PlaybackErrorKind.manifestInvalid,
          'AnimeWorld episode manifest changed.',
        );
      }
      final playerUri = config.baseUrl.resolve(decoded['target'] as String);
      final player = await transport.get(
        playerUri,
        headers: {'Referer': pageUri.toString()},
      );
      _requireSuccess(player, 'player document');
      final media = parseAnimeWorldMedia(player.body, player.finalUri);
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.available,
        'Public ${media.contentType} media resolved',
      );
      return PlaybackManifest(
        sourceName: 'AnimeWorld',
        binding: binding,
        uri: media.uri,
        isLocalFile: false,
        httpHeaders: {'Referer': player.finalUri.toString()},
      );
    } on PlaybackException catch (error) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        error.kind == PlaybackErrorKind.sourceUnavailable
            ? LiveManifestState.networkFailure
            : error.kind == PlaybackErrorKind.unsupportedFormat
            ? LiveManifestState.unsupported
            : LiveManifestState.parserMismatch,
        'Playback delivery ${error.kind.name}',
      );
      rethrow;
    } on FormatException catch (error) {
      throw PlaybackException(
        PlaybackErrorKind.manifestInvalid,
        'AnimeWorld returned malformed player data.',
        error,
      );
    } on Object catch (error) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.networkFailure,
        'Playback resolution could not reach its next stage',
      );
      throw PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'AnimeWorld could not be reached.',
        error,
      );
    }
  }

  void _requireSuccess(LiveMediaResponse response, String stage) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'AnimeWorld $stage returned HTTP ${response.statusCode}.',
      );
    }
  }
}

class AnimeWorldMediaReference {
  const AnimeWorldMediaReference(this.uri, this.contentType);
  final Uri uri;
  final String contentType;
}

AnimeWorldMediaReference parseAnimeWorldMedia(String html, Uri playerUri) {
  final document = html_parser.parse(html);
  final source = document.querySelector('video source[src]');
  final raw = source?.attributes['src'];
  final type = source?.attributes['type']?.toLowerCase() ?? '';
  if (raw == null || raw.isEmpty) {
    throw const PlaybackException(
      PlaybackErrorKind.manifestInvalid,
      'AnimeWorld player media markers changed.',
    );
  }
  final uri = playerUri.resolve(raw);
  if (!{'http', 'https'}.contains(uri.scheme)) {
    throw const PlaybackException(
      PlaybackErrorKind.unsupportedFormat,
      'AnimeWorld returned an unsupported media locator.',
    );
  }
  final supported =
      type == 'video/mp4' ||
      type == 'application/x-mpegurl' ||
      type == 'application/vnd.apple.mpegurl' ||
      type == 'application/dash+xml';
  if (!supported) {
    throw const PlaybackException(
      PlaybackErrorKind.unsupportedFormat,
      'AnimeWorld returned an unsupported public media format.',
    );
  }
  return AnimeWorldMediaReference(uri, type);
}
