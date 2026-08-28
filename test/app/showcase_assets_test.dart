import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expectedAssets = <String, (int, int)>{
    'assets/showcase/ashen_blade/cover.png': (1024, 1536),
    'assets/showcase/ashen_blade/page-01.png': (1024, 1536),
    'assets/showcase/ashen_blade/page-02.png': (1024, 1536),
    'assets/showcase/ashen_blade/page-03.png': (1024, 1536),
    'assets/showcase/nova_pulse/poster.png': (1024, 1536),
    'assets/showcase/nova_pulse/hero.png': (1672, 941),
    'assets/showcase/nova_pulse/still-01.png': (1672, 941),
    'assets/showcase/nova_pulse/still-02.png': (1672, 941),
  };

  test(
    'original showcase raster assets are bundled at expected dimensions',
    () async {
      for (final entry in expectedAssets.entries) {
        final bytes = await rootBundle.load(entry.key);
        expect(bytes.lengthInBytes, greaterThan(10 * 1024), reason: entry.key);

        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(
          (frame.image.width, frame.image.height),
          entry.value,
          reason: entry.key,
        );
        frame.image.dispose();
        codec.dispose();
      }
    },
  );
}
