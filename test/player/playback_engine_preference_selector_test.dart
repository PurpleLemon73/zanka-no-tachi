import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine_preference.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/ui/playback_engine_preference_selector.dart';
import 'package:zanka_no_tachi/player/video_display_mode.dart';

void main() {
  late _MemoryPlaybackPreferencesStore store;

  setUp(() {
    store = _MemoryPlaybackPreferencesStore();
  });

  testWidgets('shows truthful device-local options and next-session notice', (
    tester,
  ) async {
    await _pumpSelector(tester, store);

    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('video_player'), findsOneWidget);
    expect(find.text('Better Player (Experimental)'), findsOneWidget);
    expect(find.text('Basic MP4 evaluation only'), findsOneWidget);
    expect(
      find.text('Changes apply to the next playback session.'),
      findsOneWidget,
    );
    expect(
      _option(tester, PlaybackEnginePreferenceSelector.automaticKey).selected,
      isTrue,
    );
  });

  testWidgets('persists only engine choice while preserving preferences', (
    tester,
  ) async {
    const original = PlaybackPreferences(
      seekStepSeconds: 30,
      autoplay: false,
      autoplayNext: true,
      speed: 1.25,
      preferredAudioLanguage: 'ja',
      preferredSubtitleLanguage: 'it',
      videoDisplayMode: VideoDisplayMode(
        fit: VideoDisplayFit.fitWidth,
        aspectPreset: VideoAspectPreset.twentyOneNine,
      ),
    );
    store.value = original;
    await _pumpSelector(tester, store);

    await tester.tap(
      find.byKey(PlaybackEnginePreferenceSelector.betterPlayerKey),
    );
    await tester.pumpAndSettle();

    final saved = await store.load();
    expect(
      saved.enginePreference,
      PlaybackEnginePreference.betterPlayerExperimental,
    );
    expect(saved.seekStepSeconds, original.seekStepSeconds);
    expect(saved.autoplay, original.autoplay);
    expect(saved.autoplayNext, original.autoplayNext);
    expect(saved.speed, original.speed);
    expect(saved.preferredAudioLanguage, original.preferredAudioLanguage);
    expect(saved.preferredSubtitleLanguage, original.preferredSubtitleLanguage);
    expect(saved.videoDisplayMode, original.videoDisplayMode);
  });

  testWidgets('selected radio takes focus and D-pad arrows persist selection', (
    tester,
  ) async {
    await _pumpSelector(tester, store);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(
      (await store.load()).enginePreference,
      PlaybackEnginePreference.videoPlayer,
    );
    expect(
      _option(tester, PlaybackEnginePreferenceSelector.videoPlayerKey).selected,
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(
      (await store.load()).enginePreference,
      PlaybackEnginePreference.betterPlayerExperimental,
    );
    expect(
      _option(
        tester,
        PlaybackEnginePreferenceSelector.betterPlayerKey,
      ).selected,
      isTrue,
    );
  });

  testWidgets('save failure restores the truthful persisted selection', (
    tester,
  ) async {
    await _pumpSelector(tester, store);
    store.failNextSave = true;

    await tester.tap(
      find.byKey(PlaybackEnginePreferenceSelector.betterPlayerKey),
    );
    await tester.pumpAndSettle();

    expect(
      _option(tester, PlaybackEnginePreferenceSelector.automaticKey).selected,
      isTrue,
    );
    expect(
      find.text('Could not save the playback engine preference.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpSelector(
  WidgetTester tester,
  PlaybackPreferencesStore store,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PlaybackEnginePreferenceSelector(preferencesStore: store),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

RadioListTile<PlaybackEnginePreference> _option(WidgetTester tester, Key key) =>
    tester.widget<RadioListTile<PlaybackEnginePreference>>(find.byKey(key));

class _MemoryPlaybackPreferencesStore extends PlaybackPreferencesStore {
  PlaybackPreferences value = const PlaybackPreferences();
  bool failNextSave = false;

  @override
  Future<PlaybackPreferences> load() async => value;

  @override
  Future<void> save(PlaybackPreferences value) async {
    if (failNextSave) {
      failNextSave = false;
      throw StateError('Synthetic save failure');
    }
    this.value = value;
  }
}
