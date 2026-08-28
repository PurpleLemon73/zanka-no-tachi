import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/app_identity.dart';
import 'package:zanka_no_tachi/app/app_preferences.dart';
import 'package:zanka_no_tachi/app/local_diagnostics.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/main.dart';
import 'package:zanka_no_tachi/product/ui/onboarding_screen.dart';

void main() {
  test('Android production signing stays external and fails closed', () {
    final rootIgnore = File('.gitignore').readAsStringSync();
    final androidIgnore = File('android/.gitignore').readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final releaseTool = File(
      'tool/build_release_candidate.sh',
    ).readAsStringSync();

    expect(rootIgnore, contains('key.properties'));
    expect(rootIgnore, contains('*.jks'));
    expect(androidIgnore, contains('key.properties'));
    expect(androidIgnore, contains('**/*.jks'));
    expect(gradle, contains('rootProject.file("key.properties")'));
    expect(gradle, contains('signingConfigs.findByName("release")'));
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(releaseTool, contains('Git working tree is not clean'));
    expect(releaseTool, contains('apksigner'));
    expect(releaseTool, contains('aapt dump badging'));
    expect(releaseTool, contains('3F4A86F7F4DDA398E04DD059DD33D7FC'));
    expect(releaseTool, isNot(contains('storePassword=')));
    expect(releaseTool, isNot(contains('keyPassword=')));
  });

  test('public identity matches package version metadata', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(AppIdentity.displayName, 'Zanka no Tachi');
    expect(
      pubspec,
      contains('version: ${AppIdentity.version}+${AppIdentity.buildNumber}'),
    );
    expect(AppIdentity.disclaimer, contains('does not grant permission'));
  });

  test(
    'structured diagnostics redact private data and remain bounded',
    () async {
      final directory = await Directory.systemTemp.createTemp('zanka-logs-');
      final file = File('${directory.path}/diagnostics.json');
      final diagnostics = LocalDiagnostics(file: file, maximumRecords: 3);
      for (var index = 0; index < 6; index++) {
        await diagnostics.record(
          LocalLogLevel.warning,
          'provider',
          'request https://example.test/page?token=secret-$index '
              'from /Users/private/media.cbz Bearer credential',
        );
      }
      final records = await diagnostics.records();
      expect(records, hasLength(3));
      final report = await diagnostics.redactedReport();
      expect(report, isNot(contains('secret-')));
      expect(report, isNot(contains('/Users/private')));
      expect(report, isNot(contains('credential')));
      expect(report, contains('[url redacted]'));
      await directory.delete(recursive: true);
    },
  );

  test('global error capture stores only a small typed diagnostic', () async {
    final directory = await Directory.systemTemp.createTemp('zanka-errors-');
    final diagnostics = LocalDiagnostics(
      file: File('${directory.path}/diagnostics.json'),
    );
    await diagnostics.captureUncaught(StateError('private title or locator'));
    final record = (await diagnostics.records()).single;
    expect(record.area, 'uncaught');
    expect(record.message, contains('StateError'));
    expect(record.message, isNot(contains('private title')));
    await diagnostics.clear();
    expect(await diagnostics.records(), isEmpty);
    await directory.delete(recursive: true);
  });

  test('first-run onboarding state persists atomically', () async {
    final directory = await Directory.systemTemp.createTemp(
      'zanka-onboarding-',
    );
    final preferences = AppPreferencesStore(
      file: File('${directory.path}/settings.json'),
    );
    await preferences.completeOnboarding();
    expect((await preferences.load()).onboardingComplete, isTrue);
    await directory.delete(recursive: true);
  });

  testWidgets('first-run onboarding explains the product and can be skipped', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () async => completed = true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Your library, independent of sources'), findsOneWidget);
    await tester.tap(find.byKey(const Key('skip-onboarding')));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets('About and onboarding help are reachable from Settings', (
    tester,
  ) async {
    final repository = _repository();
    await tester.pumpWidget(
      ZankaApp(repository: repository, enableOnboarding: false),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Settings').last);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-about')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('open-about')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('About & Help'), findsOneWidget);
    expect(find.textContaining(AppIdentity.version), findsOneWidget);
    expect(find.textContaining('independent, unofficial'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('reopen-onboarding')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('reopen-onboarding')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Your library, independent of sources'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repository.dispose();
  });
}

LiveProviderRepository _repository() => LiveProviderRepository(
  registry: ProviderRegistry.defaults(),
  database: CanonicalDatabase(NativeDatabase.memory()),
  transport: const _OfflineTransport(),
);

class _OfflineTransport implements ProviderTransport {
  const _OfflineTransport();
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw const SocketException('offline');
  @override
  void close() {}
}
