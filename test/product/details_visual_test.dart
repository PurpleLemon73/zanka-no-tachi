import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/smart_resume.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/media_details_screen.dart';
import 'package:zanka_no_tachi/tv/tv_media_details_screen.dart';

const _mediaId = CanonicalMediaId('visual-original-nova-pulse');
const _title =
    'Nova Pulse: A Journey Beyond the Last Light of the Outer Cities';
const _description =
    'An original showcase story about a courier mapping the light between distant cities. '
    'The route changes each night, but the promise to return remains. '
    'This deliberately long synopsis checks that the reading surface can expand without hiding its controls. '
    'No live provider, copyrighted artwork, or playback engine is used in this layout test.';

void main() {
  for (final layout in [
    (size: const Size(360, 780), brightness: Brightness.dark),
    (size: const Size(360, 780), brightness: Brightness.light),
    (size: const Size(1100, 800), brightness: Brightness.light),
    (size: const Size(844, 390), brightness: Brightness.dark),
    (size: const Size(800, 1100), brightness: Brightness.dark),
  ]) {
    testWidgets(
      'Details ${layout.size.width.toInt()} remains usable in ${layout.brightness.name} with large text',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = layout.size;
        addTearDown(tester.view.reset);
        final fixture = await _fixture();
        await tester.pumpWidget(
          MaterialApp(
            theme: zankaTheme(layout.brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
            home: MediaDetailsScreen(
              controller: fixture.controller,
              mediaId: _mediaId,
              initialDetails: fixture.details,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text(_title), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('smart-resume-cta')));
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byKey(const Key('smart-resume-cta'))).width,
          lessThanOrEqualTo(600),
        );
        expect(
          find.text('Currently unavailable').hitTestable(),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const Key('toggle-library')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('toggle-library')));
        await tester.pumpAndSettle();
        expect(
          (await fixture.live.database.libraryEntry(_mediaId))?.isSaved,
          isTrue,
        );

        await tester.ensureVisible(find.byKey(const Key('description-toggle')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('description-toggle')));
        await tester.pumpAndSettle();
        expect(tester.widget<Text>(find.text(_description)).maxLines, isNull);
        expect(find.text('Show less'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        fixture.controller.dispose();
        await fixture.live.dispose();
      },
    );
  }

  for (final layout in [
    (size: const Size(960, 540), brightness: Brightness.dark, scale: 1.2),
    (size: const Size(1280, 720), brightness: Brightness.light, scale: 1.0),
  ]) {
    testWidgets(
      'TV Details ${layout.size.width.toInt()} keeps resume focus and remote Library action',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = layout.size;
        addTearDown(tester.view.reset);
        final fixture = await _fixture();
        // This test supplies the application-owned action target to isolate focus
        // presentation; activating real playback is covered by player tests.
        final details = ProductMediaDetails(
          summary: fixture.details.summary,
          chapters: fixture.details.chapters,
          episodes: fixture.details.episodes,
          smartResume: const SmartResumeTarget(
            action: SmartResumeAction.startWatching,
            episodeId: CanonicalEpisodeId('original-nova-episode-1'),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: zankaTheme(layout.brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(layout.scale)),
              child: child!,
            ),
            home: TvMediaDetailsScreen(
              controller: fixture.controller,
              mediaId: _mediaId,
              initialDetails: details,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(_focusWithin(const Key('tv-smart-resume')), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(_focusWithin(const Key('tv-smart-resume')), isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.select);
        await tester.pumpAndSettle();
        expect(
          (await fixture.live.database.libraryEntry(_mediaId))?.isSaved,
          isTrue,
        );
        expect(find.text('Remove from Library'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        fixture.controller.dispose();
        await fixture.live.dispose();
      },
    );
  }
}

bool _focusWithin(Key key) {
  var found = false;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((element) {
    if (element.widget.key == key) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

Future<
  ({
    LiveProviderRepository live,
    ProductController controller,
    ProductMediaDetails details,
  })
>
_fixture() async {
  final live = LiveProviderRepository(
    registry: ProviderRegistry([]),
    database: CanonicalDatabase(NativeDatabase.memory()),
    transport: _NoNetwork(),
  );
  const provenance = FieldProvenance(
    providerId: ProviderId('original-showcase'),
  );
  await live.database.saveMedia(
    const CanonicalAnime(
      id: _mediaId,
      title: SourcedValue(value: _title, provenance: provenance),
      description: SourcedValue(value: _description, provenance: provenance),
      format: AnimeFormat.ona,
    ),
  );
  final controller = ProductController(ProductRepository(live));
  return (
    live: live,
    controller: controller,
    details: (await controller.details(_mediaId))!,
  );
}

class _NoNetwork implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Layout test must remain offline');
  @override
  void close() {}
}
