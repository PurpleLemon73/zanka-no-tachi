import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/app_preferences.dart';
import 'package:zanka_no_tachi/app/local_diagnostics.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/local_library/local_asset.dart';
import 'package:zanka_no_tachi/local_library/local_library_service.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/about_screen.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/local_media_screen.dart';
import 'package:zanka_no_tachi/product/ui/onboarding_screen.dart';
import 'package:zanka_no_tachi/product/ui/settings_visuals.dart';

const _layouts = [
  (name: 'narrow', size: Size(320, 740), scale: 1.5, tv: false),
  (name: 'phone', size: Size(390, 844), scale: 1.0, tv: false),
  (name: 'large-phone', size: Size(480, 960), scale: 1.3, tv: false),
  (name: 'landscape-phone', size: Size(844, 390), scale: 1.5, tv: false),
  (name: 'portrait-tablet', size: Size(800, 1100), scale: 1.5, tv: false),
  (name: 'landscape-tablet', size: Size(1280, 800), scale: 1.3, tv: false),
  (name: 'TV-logical-4K', size: Size(1280, 720), scale: 1.5, tv: true),
  (name: 'TV-1080', size: Size(1920, 1080), scale: 1.3, tv: true),
];

void main() {
  for (final layout in _layouts) {
    testWidgets(
      '${layout.name}: appearance and introduction actions remain reachable',
      (tester) async {
        _viewport(tester, layout.size);
        final changes = <(ZankaThemeMode, ZankaAccent)>[];
        await tester.pumpWidget(
          _app(
            scale: layout.scale,
            child: AppearanceSettingsPage(
              tv: layout.tv,
              appearance: const AppPreferences(),
              onAppearanceChanged: (mode, accent) async =>
                  changes.add((mode, accent)),
            ),
          ),
        );
        for (final key in ['theme-dark', 'accent-purple', 'theme-system']) {
          await _activate(tester, find.byKey(Key(key)));
          expect(tester.takeException(), isNull);
        }
        expect(changes.last, (ZankaThemeMode.system, ZankaAccent.purple));
        var completed = 0;
        await tester.pumpWidget(
          _app(
            scale: layout.scale,
            child: OnboardingScreen(onComplete: () async => completed++),
          ),
        );
        await tester.pumpAndSettle();
        for (var page = 0; page < 4; page++) {
          expect(
            find.bySemanticsLabel('Onboarding page ${page + 1} of 4'),
            findsOneWidget,
          );
          await _activate(tester, find.byKey(const Key('onboarding-next')));
          expect(tester.takeException(), isNull);
        }
        expect(completed, 1);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '${layout.name}: About help, diagnostics and Back respect safe areas',
      (tester) async {
        _viewport(tester, layout.size);
        final diagnostics = _MemoryDiagnostics();
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.pumpWidget(
          _app(
            scale: layout.scale,
            child: AboutZankaScreen(diagnostics: diagnostics),
          ),
        );
        await tester.pumpAndSettle();
        await _activate(tester, find.byKey(const Key('reopen-onboarding')));
        expect(find.byType(OnboardingScreen), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await _activate(tester, find.byKey(const Key('copy-diagnostics')));
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(copied, 'Original local diagnostic fixture');
        expect(find.text('Redacted diagnostics copied.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    if (!layout.tv) {
      testWidgets(
        '${layout.name}: local file selection and cancellation fit without changing assets',
        (tester) async {
          _viewport(tester, layout.size);
          final db = CanonicalDatabase(NativeDatabase.memory());
          final local = _LocalLibrary(db);
          final live = LiveProviderRepository(
            database: db,
            registry: ProviderRegistry([]),
            transport: _Offline(),
          );
          final controller = ProductController(
            ProductRepository(live),
            localLibrary: local,
          );
          final picker = FilePickerPlatform.instance;
          final batchFile = (await tester.runAsync(() async {
            final directory = await Directory.systemTemp.createTemp(
              'zanka-layout-',
            );
            addTearDown(() => directory.delete(recursive: true));
            final file = File(
              '${directory.path}/Original chapter with a long reviewed label.cbz',
            );
            // Metadata-only archive probe: no page decoding or import occurs.
            await file.writeAsBytes(
              ZipEncoder().encode(
                Archive()..addFile(ArchiveFile('page.png', 3, [1, 2, 3])),
              ),
            );
            return file;
          }))!;
          FilePickerPlatform.instance = _Picker(batchUri: batchFile.uri);
          addTearDown(() => FilePickerPlatform.instance = picker);
          addTearDown(() async {
            controller.dispose();
            await live.dispose();
          });
          await tester.pumpWidget(
            _app(
              scale: layout.scale,
              child: LocalMediaScreen(controller: controller),
            ),
          );
          await tester.pumpAndSettle();
          for (final label in ['Import video', 'Import CBZ']) {
            await _activate(tester, find.widgetWithText(FilledButton, label));
            expect(find.byType(AlertDialog), findsOneWidget);
            final title = find.widgetWithText(TextField, 'Title');
            await tester.ensureVisible(title);
            await tester.enterText(title, 'An original long reviewed title');
            tester.view.viewInsets = const FakeViewPadding(bottom: 150);
            await tester.pumpAndSettle();
            await _activate(tester, find.widgetWithText(TextButton, 'Cancel'));
            tester.view.viewInsets = FakeViewPadding.zero;
            await tester.pumpAndSettle();
          }
          await _activate(tester, find.byKey(const Key('batch-import-cbz')));
          for (
            var attempt = 0;
            attempt < 30 && find.byType(AlertDialog).evaluate().isEmpty;
            attempt++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();
          expect(find.text('Review chapter batch'), findsOneWidget);
          expect(tester.takeException(), isNull);
          final batchTitle = find.widgetWithText(
            TextField,
            'Reviewed canonical title',
          );
          await tester.ensureVisible(batchTitle);
          await tester.enterText(batchTitle, 'Reviewed batch title');
          tester.view.viewInsets = const FakeViewPadding(bottom: 150);
          await tester.pumpAndSettle();
          await _activate(tester, find.widgetWithText(TextButton, 'Cancel'));
          tester.view.viewInsets = FakeViewPadding.zero;
          await tester.pumpAndSettle();
          final tile = find.widgetWithText(ListTile, _fileName);
          await tester.scrollUntilVisible(
            tile,
            240,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.longPress(tile);
          await tester.pumpAndSettle();
          await _activate(tester, find.text('Remove sources…'));
          expect(find.text('Remove 1 local sources?'), findsOneWidget);
          await _activate(tester, find.widgetWithText(TextButton, 'Cancel'));
          expect(local.removals, 0);
          expect(find.text('1 selected'), findsOneWidget);
          await _activate(tester, find.widgetWithText(TextButton, 'Clear'));
          await tester.ensureVisible(tile);
          await tester.pumpAndSettle();
          await _activate(
            tester,
            find.descendant(
              of: tile,
              matching: find.byType(PopupMenuButton<String>),
            ),
          );
          await _activate(tester, find.text('Remove local source…'));
          expect(find.text('Remove local source?'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(local.removals, 0);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'onboarding remote Next advances without swiping and Back closes reopened help',
    (tester) async {
      _viewport(tester, const Size(1280, 720));
      await tester.pumpWidget(
        _app(
          scale: 1.5,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                autofocus: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OnboardingScreen(
                      reopened: true,
                      onComplete: () async {},
                    ),
                  ),
                ),
                child: const Text('Help'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<FilledButton>()
            ?.key,
        const Key('onboarding-next'),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Onboarding page 2 of 4'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Help'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

void _viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Widget _app({required double scale, required Widget child}) => MaterialApp(
  theme: zankaTheme(Brightness.dark),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
      viewPadding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: 24,
      ),
    ),
    child: child!,
  ),
  home: child,
);

Future<void> _activate(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'After activating $finder');
}

const _fileName =
    'An original long filename for an episode recorded locally with a descriptive title.mp4';

class _LocalLibrary extends LocalLibraryService {
  _LocalLibrary(super.database);
  int removals = 0;
  @override
  Future<List<LocalAsset>> refreshStates() async => [
    LocalAsset(
      id: const LocalAssetId('asset'),
      kind: LocalAssetKind.video,
      ownership: LocalAssetOwnership.appOwnedCopy,
      state: LocalAssetState.missing,
      providerId: importedVideoProviderId,
      bindingExternalId: 'original',
      mediaId: const CanonicalMediaId('anime'),
      installmentId: 'episode',
      originalName: _fileName,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];
  @override
  Future<LocalStorageSummary> storageSummary() async =>
      const LocalStorageSummary(
        mangaBytes: 0,
        videoBytes: 0,
        assetCount: 1,
        missingCount: 1,
      );
  @override
  Future<void> removeSource(
    LocalAsset asset, {
    required bool deletePhysical,
  }) async {
    removals++;
  }
}

class _Offline implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Responsive tests stay offline');
  @override
  void close() {}
}

class _MemoryDiagnostics extends LocalDiagnostics {
  @override
  Future<List<DiagnosticRecord>> records() async => const [];
  @override
  Future<String> redactedReport() async => 'Original local diagnostic fixture';
  @override
  Future<void> clear() async {}
}

class _Picker extends FilePickerPlatform {
  _Picker({required this.batchUri});
  final Uri batchUri;
  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => [_PickedFile('cbz', fixtureUri: batchUri)];
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _PickedFile(allowedExtensions!.first);
}

final class _PickedFile extends PlatformFile {
  _PickedFile(this.extensionName, {this.fixtureUri});
  final String extensionName;
  final Uri? fixtureUri;
  @override
  String get name => 'Original.$extensionName';
  @override
  Uri get uri => fixtureUri ?? Uri.file('/synthetic/$name');
  @override
  Never get xFile => throw StateError('Layout tests must not import content');
  @override
  Never length() => throw StateError('Layout tests must not import content');
  @override
  Never readAsBytes() =>
      throw StateError('Layout tests must not import content');
  @override
  Never readAsByteStream() =>
      throw StateError('Layout tests must not import content');
}
