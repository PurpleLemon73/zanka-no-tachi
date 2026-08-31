import 'package:media_kit/media_kit.dart' as mk;

import 'playback_domain.dart';
import 'playback_engine.dart';

/// Experimental M16 adapter. It is never selected by the production player.
class MediaKitPlaybackEngine implements PlaybackEngine {
  MediaKitPlaybackEngine() : _player = mk.Player();

  final mk.Player _player;

  /// Rendering hook for the isolated M16 probe; not used by product UI.
  mk.Player get experimentalPlayer => _player;

  @override
  PlaybackEngineKind get kind => PlaybackEngineKind.mediaKitExperimental;

  @override
  Stream<Duration> get position => _player.stream.position;

  @override
  Stream<Duration> get duration => _player.stream.duration;

  @override
  Stream<bool> get playing => _player.stream.playing;

  @override
  Stream<PlaybackEngineTracks> get tracks => _player.stream.tracks.map(
    (value) => PlaybackEngineTracks(
      audio: value.audio
          .where((track) => track.id != 'no' && track.id != 'auto')
          .map(_audioTrack)
          .toList(),
      subtitles: value.subtitle
          .where((track) => track.id != 'no' && track.id != 'auto')
          .map(_subtitleTrack)
          .toList(),
    ),
  );

  @override
  Future<void> open(
    PlaybackManifest manifest, {
    Duration startPosition = Duration.zero,
  }) async {
    // Observe the reset-to-zero followed by the new medium's duration. The
    // package's open future may complete while the previous duration is still
    // visible, which is not a truthful readiness signal.
    final ready = _player.stream.duration
        .skipWhile((value) => value > Duration.zero)
        .firstWhere((value) => value > Duration.zero)
        .timeout(const Duration(seconds: 5));
    await _player.open(
      mk.Media(manifest.uri.toString(), httpHeaders: manifest.httpHeaders),
      play: false,
    );
    final duration = await ready;
    final bounded = boundedPlaybackStart(startPosition, duration);
    if (bounded > Duration.zero) {
      final positioned = _player.stream.position
          .firstWhere(
            (value) =>
                (value - bounded).abs() <= const Duration(milliseconds: 300),
          )
          .timeout(const Duration(seconds: 2));
      await _player.seek(bounded);
      await positioned;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setRate(speed);

  @override
  Future<void> selectAudio(String id) async {
    final match = _player.state.tracks.audio.where((track) => track.id == id);
    if (match.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Unknown audio track');
    }
    await _player.setAudioTrack(match.first);
  }

  @override
  Future<void> selectSubtitle(String? id) async {
    if (id == null) {
      await _player.setSubtitleTrack(mk.SubtitleTrack.no());
      return;
    }
    final match = _player.state.tracks.subtitle.where(
      (track) => track.id == id,
    );
    if (match.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Unknown subtitle track');
    }
    await _player.setSubtitleTrack(match.first);
  }

  @override
  Future<void> addExternalSubtitle(
    Uri uri, {
    String? label,
    String? language,
  }) => _player.setSubtitleTrack(
    mk.SubtitleTrack.uri(uri.toString(), title: label, language: language),
  );

  @override
  Future<void> dispose() => _player.dispose();

  static PlaybackEngineTrack _audioTrack(mk.AudioTrack track) =>
      PlaybackEngineTrack(
        id: track.id,
        label: track.title ?? track.language ?? 'Audio ${track.id}',
        language: track.language,
        isExternal: track.uri,
      );

  static PlaybackEngineTrack _subtitleTrack(mk.SubtitleTrack track) =>
      PlaybackEngineTrack(
        id: track.id,
        label: track.title ?? track.language ?? 'Subtitle ${track.id}',
        language: track.language,
        isExternal: track.uri || track.data,
      );
}
