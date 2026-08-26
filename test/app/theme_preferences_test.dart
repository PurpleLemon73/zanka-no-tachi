import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/app_preferences.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';

void main() {
  test('theme mode and accent persist, restart and reset safely', () async {
    final directory = await Directory.systemTemp.createTemp('zanka-theme-');
    addTearDown(() => directory.delete(recursive: true));
    final store = AppPreferencesStore(
      file: File('${directory.path}/settings.json'),
    );
    await store.saveAppearance(
      themeMode: ZankaThemeMode.dark,
      accent: ZankaAccent.teal,
    );
    final reopened = await store.load();
    expect(reopened.themeMode, ZankaThemeMode.dark);
    expect(reopened.accent, ZankaAccent.teal);

    await store.saveAppearance(
      themeMode: ZankaThemeMode.system,
      accent: ZankaAccent.defaultRed,
    );
    expect((await store.load()).themeMode, ZankaThemeMode.system);
    expect((await store.load()).accent, ZankaAccent.defaultRed);
  });

  test(
    'accent generates distinct readable light and dark Material 3 schemes',
    () {
      final red = zankaTheme(Brightness.light);
      final blue = zankaTheme(Brightness.light, accent: ZankaAccent.blue);
      final dark = zankaTheme(Brightness.dark, accent: ZankaAccent.blue);
      expect(red.useMaterial3, isTrue);
      expect(red.colorScheme.primary, isNot(blue.colorScheme.primary));
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(dark.colorScheme.onPrimary, isNot(dark.colorScheme.primary));
    },
  );
}
