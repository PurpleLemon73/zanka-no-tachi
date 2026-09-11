import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/media_details_screen.dart';
import 'package:zanka_no_tachi/product/ui/product_shell.dart';
import 'package:zanka_no_tachi/tv/tv_media_details_screen.dart';
import 'package:zanka_no_tachi/tv/tv_product_shell.dart';
import 'package:zanka_no_tachi/tv/tv_design_system.dart';

const _id = CanonicalMediaId('details-loading-test');
const _newId = CanonicalMediaId('details-new-selection');

void main() {
  for (final tv in [false, true]) {
    final surface = tv ? 'TV' : 'phone';
    for (final kind in CanonicalMediaKind.values) {
      testWidgets('$surface ${kind.name} success exits loading', (
        tester,
      ) async {
        final controller = _fixture(tester);
        final repository = controller.repository as _ControlledRepository;
        await tester.pumpWidget(_app(tv, controller, _id));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        repository.pending.single.complete(_details(_id, kind));
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('${kind.name} ${_id.value}'), findsOneWidget);
      });
    }

    testWidgets('$surface completed null lookup is unavailable, not pending', (
      tester,
    ) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _ControlledRepository;
      await tester.pumpWidget(_app(tv, controller, _id));
      repository.pending.single.complete(null);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Details unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      '$surface retry clears the old error and deduplicates pending loads',
      (tester) async {
        final controller = _fixture(tester);
        final repository = controller.repository as _ControlledRepository;
        await tester.pumpWidget(_app(tv, controller, _id));
        repository.pending.single.completeError(StateError('source failed'));
        await tester.pumpAndSettle();
        expect(find.text('Details unavailable'), findsOneWidget);
        final retry = tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Retry'))
            .onPressed!;
        retry();
        retry();
        await tester.pump();
        expect(repository.pending, hasLength(2));
        repository.pending.last.complete(
          _details(_id, CanonicalMediaKind.manga),
        );
        await tester.pumpAndSettle();
        expect(find.text('Details unavailable'), findsNothing);
        expect(find.text('manga ${_id.value}'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('$surface stale request cannot replace a newer selection', (
      tester,
    ) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _ControlledRepository;
      await tester.pumpWidget(_app(tv, controller, _id));
      await tester.pumpWidget(_app(tv, controller, _newId));
      expect(repository.ids, [_id, _newId]);
      repository.pending.last.complete(
        _details(_newId, CanonicalMediaKind.anime),
      );
      await tester.pumpAndSettle();
      repository.pending.first.complete(
        _details(_id, CanonicalMediaKind.manga),
      );
      await tester.pumpAndSettle();
      expect(find.text('anime ${_newId.value}'), findsOneWidget);
      expect(find.text('manga ${_id.value}'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('$surface disposal and reopen ignore old errors', (
      tester,
    ) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _ControlledRepository;
      await tester.pumpWidget(_app(tv, controller, _id));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_app(tv, controller, _id));
      repository.pending.last.complete(_details(_id, CanonicalMediaKind.manga));
      await tester.pumpAndSettle();
      repository.pending.first.completeError(
        StateError('cancelled old request'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('manga ${_id.value}'), findsOneWidget);
      expect(find.text('Details unavailable'), findsNothing);
    });

    testWidgets(
      '$surface search route owns loading, rejects duplicate activation and ignores cancellation',
      (tester) async {
        final controller = _fixture(tester);
        final repository = controller.repository as _ControlledRepository;
        controller.searchQuery = 'test';
        controller.searchResults = [
          _result('Old result'),
          _result('New result'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: tv
                  ? TvSearchScreen(controller: controller)
                  : SearchScreen(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final oldTitle = find.text('Old result');
        final VoidCallback open = tv
            ? tester
                  .widget<TvFocusable>(
                    find.ancestor(
                      of: oldTitle,
                      matching: find.byType(TvFocusable),
                    ),
                  )
                  .onPressed!
            : tester
                  .widget<ListTile>(
                    find.ancestor(
                      of: oldTitle,
                      matching: find.byType(ListTile),
                    ),
                  )
                  .onTap!;
        open();
        open();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(repository.resultRequests, hasLength(1));
        expect(repository.localReads, 0);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('New result'), findsOneWidget);
        await tester.tap(find.text('New result'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(repository.resultRequests, hasLength(2));
        repository.resultRequests.last.complete(
          _details(_newId, CanonicalMediaKind.anime),
        );
        await tester.pumpAndSettle();
        repository.resultRequests.first.completeError(
          StateError('old source failed'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('anime ${_newId.value}'), findsOneWidget);
        expect(find.text('Details unavailable'), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Old result'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  }

  testWidgets(
    'selected details and source refresh do not depend on a full-library scan',
    (tester) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _ControlledRepository;
      final open = controller.openResult(_result('Selected title'));
      repository.resultRequests.single.complete(
        _details(_id, CanonicalMediaKind.manga),
      );
      expect((await open).summary.media.id, _id);
      final refresh = controller.refreshDetails(_id);
      repository.pending.single.complete(
        _details(_id, CanonicalMediaKind.manga),
      );
      expect((await refresh).summary.media.id, _id);
      expect(repository.localReads, 0);
    },
  );

  testWidgets(
    'stale source refresh cannot overwrite a new canonical selection',
    (tester) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _ControlledRepository;
      await tester.pumpWidget(_app(false, controller, _id));
      repository.pending.single.complete(
        _details(_id, CanonicalMediaKind.manga),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('refresh-source-details')));
      await tester.pump();
      await tester.pumpWidget(_app(false, controller, _newId));
      repository.pending.last.complete(
        _details(_newId, CanonicalMediaKind.anime),
      );
      await tester.pumpAndSettle();
      repository.pending[1].complete(_details(_id, CanonicalMediaKind.manga));
      await tester.pumpAndSettle();
      expect(find.text('anime ${_newId.value}'), findsOneWidget);
      expect(find.text('Source details refreshed.'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}

ProductSearchResult _result(String title) => ProductSearchResult(
  title: title,
  kind: CanonicalMediaKind.manga,
  sources: [
    ProviderListingItem(
      providerId: const ProviderId('synthetic'),
      externalId: title,
      title: title,
      relativeLocator: '/metadata',
      mediaKind: CanonicalMediaKind.manga,
    ),
  ],
);

ProductController _fixture(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 900);
  addTearDown(tester.view.reset);
  final live = LiveProviderRepository(
    registry: ProviderRegistry([]),
    database: CanonicalDatabase(NativeDatabase.memory()),
    transport: _NoNetwork(),
  );
  final controller = ProductController(_ControlledRepository(live));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await live.dispose();
  });
  return controller;
}

Widget _app(bool tv, ProductController controller, CanonicalMediaId id) =>
    MaterialApp(
      home: tv
          ? TvMediaDetailsScreen(controller: controller, mediaId: id)
          : MediaDetailsScreen(controller: controller, mediaId: id),
    );

ProductMediaDetails _details(CanonicalMediaId id, CanonicalMediaKind kind) {
  final title = SourcedValue(
    value: '${kind.name} ${id.value}',
    provenance: const FieldProvenance(providerId: ProviderId('synthetic')),
  );
  return ProductMediaDetails(
    summary: ProductMediaSummary(
      media: kind == CanonicalMediaKind.manga
          ? CanonicalManga(id: id, title: title)
          : CanonicalAnime(id: id, title: title, format: AnimeFormat.tv),
      bindings: const [],
    ),
    chapters: const [],
    episodes: const [],
  );
}

class _ControlledRepository extends ProductRepository {
  _ControlledRepository(super.live);
  final pending = <Completer<ProductMediaDetails?>>[];
  final ids = <CanonicalMediaId>[];
  final resultRequests = <Completer<ProductMediaDetails>>[];
  int localReads = 0;
  @override
  Future<List<ProductMediaSummary>> persisted() async {
    localReads++;
    return [];
  }

  @override
  Future<ProductMediaDetails> openSearchResult(ProductSearchResult result) {
    final request = Completer<ProductMediaDetails>();
    resultRequests.add(request);
    return request.future;
  }

  @override
  Future<ProductMediaDetails> refreshDetails(CanonicalMediaId id) async =>
      (await details(id))!;
  @override
  Future<ProductMediaDetails?> details(CanonicalMediaId id) {
    ids.add(id);
    final request = Completer<ProductMediaDetails?>();
    pending.add(request);
    return request.future;
  }
}

class _NoNetwork implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Unexpected network request');
  @override
  void close() {}
}
