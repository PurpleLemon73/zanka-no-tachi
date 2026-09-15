import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/player/video_display_mode.dart';

void main() {
  test(
    'TV Auto resolves to intrinsic Fit without migrating explicit preferences',
    () {
      for (final mode in [
        VideoDisplayMode.automatic,
        VideoDisplayMode.fromJson(null),
        VideoDisplayMode.fromJson(VideoDisplayMode.automatic.toJson()),
      ]) {
        final before = mode.toJson();
        final resolved = mode.forPresentation(isTv: true);
        expect(resolved.fit, VideoDisplayFit.fit);
        expect(resolved.aspectPreset, VideoAspectPreset.original);
        expect(resolved.effectiveAspectRatio(4 / 3), 4 / 3);
        expect(mode.toJson(), before);
        expect(mode.forPresentation(isTv: false).isAutomatic, isTrue);
      }
      for (final fit in VideoDisplayFit.values.where(
        (value) => value != VideoDisplayFit.autoOriginal,
      )) {
        for (final preset in VideoAspectPreset.values) {
          final explicit = VideoDisplayMode(
            fit: fit,
            aspectPreset: preset,
            customAspectRatio: preset == VideoAspectPreset.custom ? 2.39 : null,
          );
          final saved = VideoDisplayMode.fromJson(explicit.toJson());
          expect(saved.forPresentation(isTv: true).toJson(), explicit.toJson());
        }
      }
    },
  );

  testWidgets('TV Fit upscales a 1080p-sized child to the 4K surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(3840, 2160));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: VideoDisplaySurface(
          mode: VideoDisplayMode.automatic.forPresentation(isTv: true),
          intrinsicAspectRatio: 16 / 9,
          child: const SizedBox(
            key: Key('source-sized-surface'),
            width: 1920,
            height: 1080,
            child: ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('video-content-frame'))),
      const Size(3840, 2160),
    );
    expect(
      tester.getSize(find.byKey(const Key('source-sized-surface'))),
      const Size(3840, 2160),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'letterbox, pillarbox and pending video paint black over a colored host',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 180));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final ratio in <double?>[4 / 3, 2.39, null]) {
        await tester.pumpWidget(
          MaterialApp(
            home: RepaintBoundary(
              key: const Key('pixels'),
              child: ColoredBox(
                color: Colors.green,
                child: VideoDisplaySurface(
                  mode: VideoDisplayMode.automatic.forPresentation(isTv: true),
                  intrinsicAspectRatio: ratio,
                  child: const ColoredBox(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        final frame = tester.getSize(
          find.byKey(const Key('video-content-frame')),
        );
        if (ratio != null) expect(frame.aspectRatio, closeTo(ratio, 0.0001));
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('pixels')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          List<int> pixel(int x, int y) => List.generate(
            4,
            (channel) => bytes.getUint8((y * image.width + x) * 4 + channel),
          );
          expect(pixel(0, 0), [0, 0, 0, 255]);
          expect(pixel(319, 179), [0, 0, 0, 255]);
          expect(
            pixel(160, 90),
            ratio == null ? [0, 0, 0, 255] : [255, 255, 255, 255],
          );
          image.dispose();
        });
      }
    },
  );

  test('fresh and reset modes preserve the intrinsic video ratio', () {
    const mode = VideoDisplayMode();
    expect(mode.isAutomatic, isTrue);
    expect(mode.effectiveAspectRatio(4 / 3), closeTo(4 / 3, 0.0001));
    expect(mode.effectiveAspectRatio(16 / 9), closeTo(16 / 9, 0.0001));
    expect(mode.effectiveAspectRatio(9 / 16), closeTo(9 / 16, 0.0001));
    expect(mode.effectiveAspectRatio(null), isNull);
  });

  test('presets and unusual custom ratios are represented exactly', () {
    const original = VideoDisplayMode(fit: VideoDisplayFit.fit);
    final cases = <VideoAspectPreset, double>{
      VideoAspectPreset.fourThree: 4 / 3,
      VideoAspectPreset.sixteenNine: 16 / 9,
      VideoAspectPreset.sixteenTen: 16 / 10,
      VideoAspectPreset.twentyOneNine: 21 / 9,
      VideoAspectPreset.square: 1,
      VideoAspectPreset.threeTwo: 3 / 2,
      VideoAspectPreset.fiveFour: 5 / 4,
    };
    for (final entry in cases.entries) {
      expect(
        original.withAspect(entry.key).effectiveAspectRatio(9 / 16),
        closeTo(entry.value, 0.0001),
      );
    }
    for (final value in ['2.39:1', '18:9', '32:9', '9:16', '7.25:3']) {
      final parsed = parseVideoAspectRatio(value);
      expect(parsed, isNotNull, reason: value);
      expect(
        original
            .withAspect(VideoAspectPreset.custom, customRatio: parsed)
            .effectiveAspectRatio(4 / 3),
        parsed,
      );
    }
  });

  test('invalid custom aspect input fails safely', () {
    for (final value in [
      '',
      '16',
      '16/9',
      '0:1',
      '1:0',
      '-1:2',
      '2:-1',
      'a:b',
      '1:2:3',
      'Infinity:1',
    ]) {
      expect(parseVideoAspectRatio(value), isNull, reason: value);
    }
    expect(validVideoAspectRatio(double.nan), isNull);
    expect(validVideoAspectRatio(double.infinity), isNull);
  });

  test('fit geometry never distorts unless stretch is explicit', () {
    const viewport = Size(1920, 1080);
    for (final ratio in [4 / 3, 16 / 9, 21 / 9, 2.39, 1.0, 9 / 16]) {
      for (final fit in [
        VideoDisplayFit.autoOriginal,
        VideoDisplayFit.fit,
        VideoDisplayFit.fillCrop,
        VideoDisplayFit.fitWidth,
        VideoDisplayFit.fitHeight,
      ]) {
        final size = videoDisplayFrameSize(
          viewport: viewport,
          aspectRatio: ratio,
          fit: fit,
        );
        expect(size.width / size.height, closeTo(ratio, 0.0001));
      }
    }
    expect(
      videoDisplayFrameSize(
        viewport: viewport,
        aspectRatio: 4 / 3,
        fit: VideoDisplayFit.stretch,
      ),
      viewport,
    );
    expect(
      videoDisplayFrameSize(
        viewport: viewport,
        aspectRatio: null,
        fit: VideoDisplayFit.autoOriginal,
      ),
      Size.zero,
    );
  });

  testWidgets('rendered overflow modes preserve the selected frame ratio', (
    tester,
  ) async {
    Future<Size> render(VideoDisplayFit fit, double ratio) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: VideoDisplaySurface(
                mode: VideoDisplayMode(
                  fit: fit,
                  aspectPreset: VideoAspectPreset.custom,
                  customAspectRatio: ratio,
                ),
                intrinsicAspectRatio: 4 / 3,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byKey(const Key('video-content-frame')));
    }

    for (final fit in [
      VideoDisplayFit.fit,
      VideoDisplayFit.fillCrop,
      VideoDisplayFit.fitWidth,
      VideoDisplayFit.fitHeight,
    ]) {
      final frame = await render(fit, 21 / 9);
      expect(frame.aspectRatio, closeTo(21 / 9, 0.0001), reason: fit.name);
    }
    expect(await render(VideoDisplayFit.fillCrop, 4 / 3), const Size(300, 225));
    expect(
      await render(VideoDisplayFit.fitHeight, 21 / 9),
      const Size(466.6666666666667, 200),
    );
    expect(await render(VideoDisplayFit.stretch, 4 / 3), const Size(300, 200));
  });

  test('display preferences migrate safely and reject corrupt custom data', () {
    const selected = VideoDisplayMode(
      fit: VideoDisplayFit.fillCrop,
      aspectPreset: VideoAspectPreset.custom,
      customAspectRatio: 2.39,
    );
    final restored = VideoDisplayMode.fromJson(selected.toJson());
    expect(restored.fit, VideoDisplayFit.fillCrop);
    expect(restored.aspectPreset, VideoAspectPreset.custom);
    expect(restored.customAspectRatio, 2.39);
    expect(VideoDisplayMode.fromJson(null).isAutomatic, isTrue);
    expect(
      VideoDisplayMode.fromJson({
        'fit': 'unknown',
        'aspectPreset': 'custom',
        'customAspectRatio': -1,
      }).isAutomatic,
      isTrue,
    );
  });
}
