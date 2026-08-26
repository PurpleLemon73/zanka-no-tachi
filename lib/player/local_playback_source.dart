import 'dart:io';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import 'playback_domain.dart';
import 'playback_source.dart';

const localVideoProviderId = ProviderId('local-video');
const localVideoAlternateProviderId = ProviderId('local-video-alternate');

class LocalVideoPlaybackSource implements PlaybackSourceResolver {
  const LocalVideoPlaybackSource(this.providerId, this.sourceName);
  @override
  final ProviderId providerId;
  final String sourceName;

  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) {
    final path = binding.relativeLocator;
    if (path == null || !File(path).existsSync()) {
      return PlaybackSourceCapability.temporarilyUnavailable;
    }
    final extension = path.split('.').last.toLowerCase();
    return const {'mp4', 'webm', 'mkv', 'mov'}.contains(extension)
        ? PlaybackSourceCapability.playbackCapable
        : PlaybackSourceCapability.unsupported;
  }

  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async {
    final binding = request.binding;
    if (binding == null || binding.providerId != providerId) {
      throw const PlaybackException(
        PlaybackErrorKind.manifestInvalid,
        'The selected playback binding is invalid.',
      );
    }
    final path = binding.relativeLocator;
    if (path == null || !await File(path).exists()) {
      throw const PlaybackException(
        PlaybackErrorKind.localFileMissing,
        'The local video file is missing.',
      );
    }
    return PlaybackManifest(
      sourceName: sourceName,
      binding: binding,
      uri: File(path).uri,
      audioTracks: const [PlaybackTrack(id: 'default', label: 'Default audio')],
    );
  }
}
