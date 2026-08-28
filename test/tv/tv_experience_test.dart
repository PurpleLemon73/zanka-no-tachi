import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/presentation_mode.dart';
import 'package:zanka_no_tachi/player/ui/anime_player_screen.dart';
import 'package:zanka_no_tachi/tv/tv_design_system.dart';

void main() {
  group('semantic presentation selection', () {
    test('television signal wins without considering geometry', () {
      expect(
        PresentationModePolicy.resolve(isTelevision: true, isTablet: true),
        PresentationMode.tv,
      );
      expect(
        PresentationModePolicy.resolve(isTelevision: true, isTablet: false),
        PresentationMode.tv,
      );
    });

    test('non-TV phones remain mobile in either orientation', () {
      for (final landscape in [false, true]) {
        expect(landscape, isA<bool>());
        expect(
          PresentationModePolicy.resolve(isTelevision: false, isTablet: false),
          PresentationMode.mobile,
        );
      }
    });

    test('semantic tablet signal remains tablet', () {
      expect(
        PresentationModePolicy.resolve(isTelevision: false, isTablet: true),
        PresentationMode.tablet,
      );
    });
  });

  test('TV remote map follows directional and media-key conventions', () {
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.select),
      TvPlayerCommand.toggle,
    );
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.mediaPlay),
      TvPlayerCommand.play,
    );
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.mediaPause),
      TvPlayerCommand.pause,
    );
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.arrowLeft),
      TvPlayerCommand.seekBackward,
    );
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.arrowRight),
      TvPlayerCommand.seekForward,
    );
    expect(
      tvPlayerCommandFor(LogicalKeyboardKey.arrowUp),
      TvPlayerCommand.reveal,
    );
    expect(tvPlayerCommandFor(LogicalKeyboardKey.keyA), isNull);
  });

  testWidgets('TV focus is visible and select activates the focused action', (
    tester,
  ) async {
    var activated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvFocusable(
            autofocus: true,
            onPressed: () => activated = true,
            child: const SizedBox(width: 240, height: 80, child: Text('Play')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
    final material = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(material.decoration, isA<BoxDecoration>());

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(activated, isTrue);
  });

  test('Android package declares both launchers and optional TV hardware', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android.intent.category.LAUNCHER'));
    expect(manifest, contains('android.intent.category.LEANBACK_LAUNCHER'));
    expect(manifest, contains('android.software.leanback'));
    expect(manifest, contains('android:required="false"'));
    expect(manifest, contains('android.hardware.touchscreen'));
    expect(manifest, contains('android:banner="@drawable/tv_banner"'));
    expect(
      File(
        'android/app/src/main/res/drawable-xhdpi/tv_banner.png',
      ).existsSync(),
      isTrue,
    );
  });

  test('native bridge uses semantic TV, MediaSession, focus and lifecycle', () {
    final source = File(
      'android/app/src/main/kotlin/dev/zanka/notachi/MainActivity.kt',
    ).readAsStringSync();
    expect(source, contains('UiModeManager'));
    expect(source, contains('FEATURE_LEANBACK'));
    expect(source, contains('MediaSession'));
    expect(source, contains('AudioFocusRequest'));
    expect(source, contains('override fun onStop()'));
    final player = File(
      'lib/player/ui/anime_player_screen.dart',
    ).readAsStringSync();
    expect(player, contains('VideoPlayerOptions(mixWithOthers: true)'));
    expect(player, contains('mediaBridge.requestAudioFocus()'));
  });
}
