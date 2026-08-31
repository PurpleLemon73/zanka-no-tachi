import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';

import 'canonical/domain/bindings.dart';
import 'canonical/domain/identifiers.dart';
import 'player/media_kit_playback_engine.dart';
import 'player/playback_domain.dart';
import 'player/playback_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MaterialApp(home: _PlaybackProbe()));
}

class _PlaybackProbe extends StatefulWidget {
  const _PlaybackProbe();

  @override
  State<_PlaybackProbe> createState() => _PlaybackProbeState();
}

class _PlaybackProbeState extends State<_PlaybackProbe>
    with WidgetsBindingObserver {
  late final MediaKitPlaybackEngine engine = MediaKitPlaybackEngine();
  late final VideoController video = VideoController(engine.experimentalPlayer);
  PlaybackEngineTracks tracks = const PlaybackEngineTracks();
  StreamSubscription<PlaybackEngineTracks>? trackSubscription;
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<String>? errorSubscription;
  Duration position = Duration.zero;
  String status = 'Preparing original fixtures…';
  Directory? fixtureDirectory;
  HttpServer? fixtureServer;

  static const assets = [
    'multi_audio.mp4',
    'external_en.srt',
    'hls/master.m3u8',
    'hls/segment_00.ts',
    'hls/segment_01.ts',
    'dash/manifest.mpd',
    'dash/init-stream0.m4s',
    'dash/init-stream1.m4s',
    'dash/chunk-stream0-00001.m4s',
    'dash/chunk-stream0-00002.m4s',
    'dash/chunk-stream1-00001.m4s',
    'dash/chunk-stream1-00002.m4s',
    'dash/chunk-stream1-00003.m4s',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    trackSubscription = engine.tracks.listen((value) {
      debugPrint(
        'M16_PROBE tracks audio=${value.audio.length} '
        'subtitles=${value.subtitles.length}',
      );
      if (mounted) setState(() => tracks = value);
    });
    positionSubscription = engine.position.listen((value) {
      if (mounted) setState(() => position = value);
    });
    errorSubscription = engine.experimentalPlayer.stream.error.listen((value) {
      debugPrint(
        'M16_PROBE engineError=${value.replaceAll(RegExp(r'[/\\][^ ]+'), '<path>')}',
      );
    });
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/zanka_m16_playback_probe',
    );
    for (final relative in assets) {
      final target = File('${root.path}/$relative');
      await target.parent.create(recursive: true);
      final data = await rootBundle.load('assets/m16_playback_probe/$relative');
      await target.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }
    fixtureDirectory = root;
    fixtureServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(_serveFixtures(fixtureServer!));
    await _open('multi_audio.mp4');
    unawaited(_runAutomatedComparison());
  }

  Future<void> _runAutomatedComparison() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final discoveredAudio = engine.experimentalPlayer.state.tracks.audio;
    if (discoveredAudio.length > 1) {
      await engine.selectAudio(discoveredAudio.last.id);
      debugPrint('M16_PROBE audioSwitch=pass');
    }
    await _externalSubtitle();
    debugPrint('M16_PROBE externalSubtitle=pass');
    await engine.seek(const Duration(seconds: 7));
    await Future<void>.delayed(const Duration(seconds: 1));
    debugPrint('M16_PROBE seekMs=${position.inMilliseconds}');
    await _open('multi_audio.mp4', start: const Duration(seconds: 7));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    debugPrint('M16_PROBE exactResumeMs=${position.inMilliseconds}');
    await _open('hls/master.m3u8', serveOverHttp: true);
    debugPrint('M16_PROBE hlsAdvance=${await _advances()}');
    await _open('dash/manifest.mpd', serveOverHttp: true);
    debugPrint('M16_PROBE dashAdvance=${await _advances()}');
    await _open('missing.invalid');
  }

  Future<bool> _advances() async {
    try {
      await engine.position
          .firstWhere((value) => value > const Duration(milliseconds: 500))
          .timeout(const Duration(seconds: 3));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _serveFixtures(HttpServer server) async {
    await for (final request in server) {
      final relative = request.uri.pathSegments.join('/');
      final file = assets.contains(relative)
          ? File('${fixtureDirectory!.path}/$relative')
          : null;
      if (file == null || !await file.exists()) {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        if (relative.endsWith('.m3u8')) {
          request.response.headers.contentType = ContentType(
            'application',
            'vnd.apple.mpegurl',
          );
        } else if (relative.endsWith('.mpd')) {
          request.response.headers.contentType = ContentType(
            'application',
            'dash+xml',
          );
        }
        await request.response.addStream(file.openRead());
      }
      await request.response.close();
    }
  }

  PlaybackManifest _manifest(String relative, {bool serveOverHttp = false}) =>
      PlaybackManifest(
        sourceName: 'M16 original fixture',
        binding: const EpisodeSourceBinding(
          canonicalId: CanonicalEpisodeId('m16-probe'),
          providerId: ProviderId('m16-probe'),
          externalId: 'm16-probe',
        ),
        uri: serveOverHttp
            ? Uri.parse('http://127.0.0.1:${fixtureServer!.port}/$relative')
            : File('${fixtureDirectory!.path}/$relative').uri,
        isLocalFile: !serveOverHttp,
      );

  Future<void> _open(
    String relative, {
    Duration start = Duration.zero,
    bool serveOverHttp = false,
  }) async {
    setState(() => status = 'Opening $relative');
    try {
      await engine.open(
        _manifest(relative, serveOverHttp: serveOverHttp),
        startPosition: start,
      );
      debugPrint(
        'M16_PROBE ready=$relative positionMs='
        '${engine.experimentalPlayer.state.position.inMilliseconds}',
      );
      await engine.play();
      debugPrint('M16_PROBE opened=$relative startMs=${start.inMilliseconds}');
      if (mounted) setState(() => status = 'Playing $relative');
    } on Object catch (error) {
      debugPrint('M16_PROBE failure kind=${error.runtimeType}');
      if (mounted) setState(() => status = 'Failed safely: $error');
    }
  }

  Future<void> _externalSubtitle() async {
    await engine.addExternalSubtitle(
      File('${fixtureDirectory!.path}/external_en.srt').uri,
      label: 'External English',
      language: 'en',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint(
      'M16_PROBE lifecycle=${state.name} positionMs=${position.inMilliseconds}',
    );
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(engine.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(trackSubscription?.cancel());
    unawaited(positionSubscription?.cancel());
    unawaited(errorSubscription?.cancel());
    unawaited(fixtureServer?.close(force: true));
    unawaited(engine.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('M16 playback engine probe')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Video(controller: video),
        ),
        const SizedBox(height: 12),
        Text('$status · ${position.inMilliseconds} ms'),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: fixtureDirectory == null
                  ? null
                  : () => _open('multi_audio.mp4'),
              child: const Text('MP4 + tracks'),
            ),
            FilledButton(
              onPressed: fixtureDirectory == null
                  ? null
                  : () => _open('hls/master.m3u8', serveOverHttp: true),
              child: const Text('HLS'),
            ),
            FilledButton(
              onPressed: fixtureDirectory == null
                  ? null
                  : () => _open('dash/manifest.mpd', serveOverHttp: true),
              child: const Text('DASH'),
            ),
            OutlinedButton(
              onPressed: () => engine.seek(const Duration(seconds: 7)),
              child: const Text('Seek 7s'),
            ),
            OutlinedButton(
              onPressed: fixtureDirectory == null
                  ? null
                  : () => _open(
                      'multi_audio.mp4',
                      start: const Duration(seconds: 7),
                    ),
              child: const Text('Reopen at 7s'),
            ),
            OutlinedButton(
              onPressed: fixtureDirectory == null ? null : _externalSubtitle,
              child: const Text('External subtitle'),
            ),
            OutlinedButton(
              onPressed: fixtureDirectory == null
                  ? null
                  : () => _open('missing.invalid'),
              child: const Text('Invalid source'),
            ),
          ],
        ),
        const Divider(),
        Text('Audio tracks (${tracks.audio.length})'),
        for (final track in tracks.audio)
          ListTile(
            title: Text(track.label),
            subtitle: Text(track.language ?? 'unknown language'),
            onTap: () => engine.selectAudio(track.id),
          ),
        Text('Subtitle tracks (${tracks.subtitles.length})'),
        for (final track in tracks.subtitles)
          ListTile(
            title: Text(track.label),
            subtitle: Text(track.language ?? 'unknown language'),
            onTap: () => engine.selectSubtitle(track.id),
          ),
        if (tracks.hasSubtitleChoices)
          TextButton(
            onPressed: () => engine.selectSubtitle(null),
            child: const Text('Subtitles off'),
          ),
      ],
    ),
  );
}
