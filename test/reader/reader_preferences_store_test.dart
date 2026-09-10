import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'zanka-reader-preferences-',
    );
    file = File('${directory.path}/reader-settings.json');
  });

  tearDown(() => directory.delete(recursive: true));

  void expectDefault(ReaderPreferences preferences) {
    expect(preferences.mode, ReaderMode.paged);
    expect(preferences.direction, ReaderDirection.rightToLeft);
    expect(preferences.fit, ReaderFit.width);
  }

  test('fresh model defaults to Paged RTL with unchanged width fit', () {
    expectDefault(const ReaderPreferences());
  });

  test(
    'missing file defaults to Paged RTL without creating or saving it',
    () async {
      expectDefault(await ReaderPreferencesStore(file: file).load());
      expectDefault(await ReaderPreferencesStore(file: file).load());
      expect(await file.exists(), isFalse);
    },
  );

  for (final mode in ReaderMode.values) {
    for (final direction in ReaderDirection.values) {
      for (final fit in ReaderFit.values) {
        test(
          'saved ${mode.name}/${direction.name}/${fit.name} survives reload unchanged',
          () async {
            // Model the existing on-disk format independently of the defaults.
            final stored =
                '{ "mode": "${mode.name}", '
                '"direction": "${direction.name}", "fit": "${fit.name}" }\n';
            await file.writeAsString(stored);
            final expected = {
              'mode': mode.name,
              'direction': direction.name,
              'fit': fit.name,
            };
            final firstLoad = await ReaderPreferencesStore(file: file).load();
            final afterRestart = await ReaderPreferencesStore(
              file: file,
            ).load();
            expect(firstLoad.toJson(), expected);
            expect(afterRestart.toJson(), expected);
            expect(
              await file.readAsString(),
              stored,
              reason: 'Loading is not a migration or rewrite.',
            );

            // Explicit settings remain editable and persist through another
            // store instance. Changing only fit must not reset mode/direction.
            final newFit = fit == ReaderFit.width
                ? ReaderFit.contain
                : ReaderFit.width;
            await ReaderPreferencesStore(
              file: file,
            ).save(afterRestart.copyWith(fit: newFit));
            expect((await ReaderPreferencesStore(file: file).load()).toJson(), {
              ...expected,
              'fit': newFit.name,
            });
          },
        );
      }
    }
  }

  test(
    'user can replace the fresh default with Vertical LTR and reload it',
    () async {
      final store = ReaderPreferencesStore(file: file);
      final fresh = await store.load();
      await store.save(
        fresh.copyWith(
          mode: ReaderMode.vertical,
          direction: ReaderDirection.leftToRight,
        ),
      );
      final reloaded = await ReaderPreferencesStore(file: file).load();
      expect(reloaded.mode, ReaderMode.vertical);
      expect(reloaded.direction, ReaderDirection.leftToRight);
    },
  );

  const malformed = {
    'empty file': '',
    'invalid JSON': '{broken',
    'null root': 'null',
    'non-object root': '[]',
    'missing fields': '{}',
    'missing mode': '{"direction":"leftToRight","fit":"width"}',
    'missing direction': '{"mode":"vertical","fit":"width"}',
    'missing fit': '{"mode":"vertical","direction":"leftToRight"}',
    'unknown mode':
        '{"mode":"invalid","direction":"leftToRight","fit":"width"}',
    'unknown direction':
        '{"mode":"vertical","direction":"invalid","fit":"width"}',
    'unknown fit':
        '{"mode":"vertical","direction":"leftToRight","fit":"invalid"}',
    'wrong field type': '{"mode":4,"direction":"leftToRight","fit":"width"}',
  };
  for (final entry in malformed.entries) {
    test(
      '${entry.key} uses the existing safe fallback without rewriting data',
      () async {
        await file.writeAsString(entry.value);
        expectDefault(await ReaderPreferencesStore(file: file).load());
        expectDefault(await ReaderPreferencesStore(file: file).load());
        expect(await file.readAsString(), entry.value);
      },
    );
  }
}
