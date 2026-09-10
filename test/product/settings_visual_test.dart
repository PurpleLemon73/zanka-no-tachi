import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/app_preferences.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/settings_visuals.dart';
import 'package:zanka_no_tachi/tv/tv_product_shell.dart';

void main() {
  testWidgets(
    'appearance commits real selections without resetting the other preference',
    (tester) async {
      final changes = <(ZankaThemeMode, ZankaAccent)>[];
      final firstSave = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          theme: zankaTheme(Brightness.light),
          home: AppearanceSettingsPage(
            appearance: const AppPreferences(),
            onAppearanceChanged: (mode, accent) async {
              changes.add((mode, accent));
              if (changes.length == 1) await firstSave.future;
            },
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('theme-dark')));
      await tester.pump();
      expect(changes, [(ZankaThemeMode.dark, ZankaAccent.defaultRed)]);
      await tester.tap(find.byKey(const ValueKey('theme-light')));
      await tester.pump();
      expect(changes, [(ZankaThemeMode.dark, ZankaAccent.defaultRed)]);
      firstSave.complete();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('accent-blue')));
      await tester.tap(find.byKey(const ValueKey('accent-blue')));
      await tester.pumpAndSettle();
      expect(changes.last, (ZankaThemeMode.dark, ZankaAccent.blue));
      await tester.ensureVisible(find.byKey(const ValueKey('theme-system')));
      await tester.tap(find.byKey(const ValueKey('theme-system')));
      await tester.pumpAndSettle();
      expect(changes.last, (ZankaThemeMode.system, ZankaAccent.blue));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('appearance fits a narrow phone with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final changes = <(ZankaThemeMode, ZankaAccent)>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: zankaTheme(Brightness.dark),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.5)),
          child: child!,
        ),
        home: AppearanceSettingsPage(
          appearance: const AppPreferences(),
          onAppearanceChanged: (mode, accent) async =>
              changes.add((mode, accent)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('accent-purple')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('accent-purple')));
    await tester.pumpAndSettle();
    expect(changes, [(ZankaThemeMode.system, ZankaAccent.purple)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance can close while a preference save is pending', (
    tester,
  ) async {
    final save = Completer<void>();
    var saves = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AppearanceSettingsPage(
                    appearance: const AppPreferences(),
                    onAppearanceChanged: (_, _) {
                      saves++;
                      return save.future;
                    },
                  ),
                ),
              ),
              child: const Text('Open appearance'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pump();
    expect(saves, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    save.complete();
    await tester.pumpAndSettle();
    expect(find.text('Open appearance'), findsOneWidget);
    expect(find.byType(AppearanceSettingsPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'TV settings category is remote-accessible and Back returns to landing',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final changes = <(ZankaThemeMode, ZankaAccent)>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: zankaTheme(Brightness.dark),
          home: Scaffold(
            body: TvSettingsScreen(
              appearance: const AppPreferences(),
              onAppearanceChanged: (mode, accent) async =>
                  changes.add((mode, accent)),
              aboutBuilder: (_) =>
                  const Scaffold(body: Text('About destination')),
              developerBuilder: (_) =>
                  const Scaffold(body: Text('Developer destination')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.byType(AppearanceSettingsPage), findsOneWidget);
      // First traversal stop is Back, then System. Directional right reaches Light.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(changes, [(ZankaThemeMode.light, ZankaAccent.defaultRed)]);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings-appearance')), findsOneWidget);
      expect(find.byType(AppearanceSettingsPage), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('open-developer-tools')));
      await tester.tap(find.byKey(const Key('open-developer-tools')));
      await tester.pumpAndSettle();
      expect(find.text('Developer destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
