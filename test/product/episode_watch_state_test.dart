import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/player/playback_source.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/episode_watch_actions.dart';
import 'package:zanka_no_tachi/product/ui/media_details_screen.dart';
import 'package:zanka_no_tachi/product_maturity/maturity_domain.dart';
import 'package:zanka_no_tachi/tv/tv_media_details_screen.dart';

const _media = CanonicalMediaId('original-anime');
const _source = ProviderId('original-source');
const _alternate = ProviderId('alternate-source');
CanonicalEpisodeId _id(int number) => CanonicalEpisodeId('episode-$number');
Key _actionKey(int number) => Key('episode-actions-${_id(number).value}');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'manual watched and unwatched preserve canonical and both exact resumes',
    () async {
      final f = await _fixture();
      final now = DateTime.utc(2026, 9, 15);
      await f.db.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: _media,
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await f.db.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: _media,
          episodeId: _id(2),
          position: const Duration(seconds: 37),
          duration: const Duration(minutes: 2),
          updatedAt: now,
        ),
      );
      for (final (provider, seconds) in [(_source, 43), (_alternate, 65)]) {
        await f.db.saveEpisodeBinding(
          EpisodeSourceBinding(
            canonicalId: _id(2),
            providerId: provider,
            externalId: 'encode-2',
          ),
        );
        await f.db.saveAnimeSourcePlaybackResume(
          AnimeSourcePlaybackResume(
            mediaId: _media,
            episodeId: _id(2),
            providerId: provider,
            episodeExternalId: 'encode-2',
            position: Duration(seconds: seconds),
            duration: const Duration(minutes: 3),
            updatedAt: now,
          ),
        );
      }
      var current = (await f.repo.details(_media))!;
      f.controller.persisted = [current.summary];
      f.controller.loadingLocal = false;
      var notifications = 0;
      f.controller.addListener(() => notifications++);
      for (final watched in [true, false]) {
        current = await f.controller.setEpisodeWatchState(current, [
          _id(2),
        ], watched: watched);
        expect(
          current.episodeCompletions.map((e) => e.episodeId),
          watched ? [_id(2)] : isEmpty,
        );
        expect(current.summary.progressCompleted, watched);
        expect(f.controller.persisted.single.progressCompleted, watched);
        expect(f.controller.loadingLocal, isFalse);
        final canonical = (await f.db.animeProgress(_media))!;
        expect(canonical.episodeId, _id(2));
        expect(canonical.position, const Duration(seconds: 37));
        expect(canonical.duration, const Duration(minutes: 2));
        expect(canonical.updatedAt.toUtc(), now);
        for (final (provider, seconds) in [(_source, 43), (_alternate, 65)]) {
          final resume = (await f.db.animeSourcePlaybackResume(
            provider,
            'encode-2',
          ))!;
          expect(resume.position, Duration(seconds: seconds));
          expect(resume.duration, const Duration(minutes: 3));
          expect(resume.updatedAt.toUtc(), now);
        }
        expect(await f.db.episodeBindingsFor(_id(2)), hasLength(2));
        expect((await f.db.libraryEntry(_media))!.isFavorite, isTrue);
        expect((await f.db.libraryEntry(_media))!.updatedAt.toUtc(), now);
      }
      expect(notifications, 2);
      expect(f.repo.detailLoads, 1);
      expect(f.repo.libraryLoads, 0);
    },
  );

  test(
    'canonical navigation, edited order, decimals and unavailable specials define the same prefix',
    () async {
      final f = await _fixture();
      await f.db.saveEpisode(
        CanonicalEpisode(
          id: _id(4),
          mediaId: _media,
          label: const EpisodeLabel(rawLabel: 'OVA bonus'),
        ),
      );
      await f.db.saveEpisode(
        CanonicalEpisode(
          id: _id(5),
          mediaId: _media,
          label: const EpisodeLabel(rawLabel: 'Episode 12.5', number: 12.5),
        ),
      );
      await f.db.saveEpisodeUserEdit(
        EpisodeUserEdit(
          episodeId: _id(4),
          rawLabel: 'ZZ edited special 999',
          kind: AnimeInstallmentKind.ova,
          explicitOrder: 1.5,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await f.db.saveEpisodeUserEdit(
        EpisodeUserEdit(
          episodeId: _id(2),
          rawLabel: 'AA misleading display label 100',
          kind: AnimeInstallmentKind.standard,
          number: 100,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await f.db.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: _id(4),
          providerId: const ProviderId('metadata-only'),
          externalId: 'ova',
        ),
      );
      final playback = f.playback;
      final ordered = (await playback.episodes(
        _media,
      )).map((e) => e.episode.id).toList();
      expect(ordered, [_id(1), _id(4), _id(2), _id(3), _id(5)]);
      final details = (await f.repo.details(_media))!;
      expect(details.episodes.map((e) => e.episode.id), ordered);
      final updated = await f.repo.setEpisodeWatchState(
        details,
        ordered.take(2),
        watched: true,
        previousOf: _id(2),
      );
      expect(
        updated.episodeCompletions.map((e) => e.episodeId),
        unorderedEquals([_id(1), _id(4)]),
      );
      expect(
        updated.episodeCompletions.every(
          (e) => e.origin == CompletionOrigin.manual,
        ),
        isTrue,
      );
      expect(await f.db.animeProgress(_media), isNull);
      expect(await f.db.select(f.db.animeSourcePlaybackResumes).get(), isEmpty);
    },
  );

  test(
    'opening and naturally completing episode 100 never infers earlier history',
    () async {
      final f = await _fixture(count: 101);
      await f.db.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: _id(100),
          providerId: _source,
          externalId: 'encode-100',
        ),
      );
      final session = await f.playback.open(
        PlaybackSessionRequest(mediaId: _media, episodeId: _id(100)),
      );
      expect(await f.db.episodeCompletionsFor(_media), isEmpty);
      await f.playback.savePosition(
        session,
        const Duration(seconds: 40),
        const Duration(seconds: 100),
      );
      expect(await f.db.episodeCompletionsFor(_media), isEmpty);
      await f.playback.savePosition(
        session,
        const Duration(seconds: 100),
        const Duration(seconds: 100),
      );
      expect(
        (await f.db.episodeCompletionsFor(_media)).map((e) => e.episodeId),
        [_id(100)],
      );
      final details = (await f.repo.details(_media))!;
      await f.repo.setEpisodeWatchState(
        details,
        details.episodes.take(99).map((e) => e.episode.id),
        watched: true,
        previousOf: _id(100),
      );
      final completions = await f.db.episodeCompletionsFor(_media);
      expect(completions, hasLength(100));
      expect(
        completions.singleWhere((e) => e.episodeId == _id(100)).origin,
        CompletionOrigin.automatic,
      );
      expect(completions.any((e) => e.episodeId == _id(101)), isFalse);
      expect(
        (await f.db.animeSourcePlaybackResume(_source, 'encode-100'))!.position,
        const Duration(seconds: 100),
      );
      expect(
        await f.db.select(f.db.animeSourcePlaybackResumes).get(),
        hasLength(1),
      );
    },
  );

  test(
    'mixed ownership and a stale confirmed prefix fail without partial writes',
    () async {
      final f = await _fixture();
      await f.db.saveMedia(
        const CanonicalAnime(
          id: CanonicalMediaId('other'),
          format: AnimeFormat.unknown,
          title: SourcedValue(
            value: 'Other',
            provenance: FieldProvenance(providerId: _source),
          ),
        ),
      );
      await f.db.saveEpisode(
        CanonicalEpisode(
          id: _id(4),
          mediaId: const CanonicalMediaId('other'),
          label: const EpisodeLabel(rawLabel: 'Other episode', number: 1),
        ),
      );
      await expectLater(
        f.db.setEpisodesWatched(_media, [_id(1), _id(4)], watched: true),
        throwsStateError,
      );
      await expectLater(
        f.db.setEpisodesWatched(_media, [_id(1), _id(99)], watched: true),
        throwsStateError,
      );
      final details = (await f.repo.details(_media))!;
      await f.db.saveEpisode(
        CanonicalEpisode(
          id: _id(5),
          mediaId: _media,
          label: const EpisodeLabel(rawLabel: 'New special', number: 1.5),
        ),
      );
      await expectLater(
        f.repo.setEpisodeWatchState(
          details,
          [_id(1), _id(2)],
          watched: true,
          previousOf: _id(3),
        ),
        throwsStateError,
      );
      expect(await f.db.episodeCompletionsFor(_media), isEmpty);
    },
  );

  test('a mid-batch storage failure rolls back every new completion', () async {
    final f = await _fixture();
    await f.db.setEpisodeCompleted(_id(3), origin: CompletionOrigin.automatic);
    final existing = (await f.db.episodeCompletionsFor(_media)).single;
    await f.db.customStatement(
      "CREATE TEMP TRIGGER fail_watch BEFORE INSERT ON episode_completion_records WHEN NEW.episode_id = 'episode-2' BEGIN SELECT RAISE(ABORT, 'synthetic storage failure'); END",
    );
    await expectLater(
      f.db.setEpisodesWatched(_media, [_id(1), _id(2), _id(3)], watched: true),
      throwsA(isA<Exception>()),
    );
    final after = await f.db.episodeCompletionsFor(_media);
    expect(after, hasLength(1));
    expect(after.single.episodeId, _id(3));
    expect(after.single.completedAt, existing.completedAt);
    expect(after.single.origin, CompletionOrigin.automatic);
  });

  for (final count in [100, 500, 1200]) {
    test(
      '$count-episode bulk operation is atomic, idempotent and bounded',
      () async {
        final f = await _fixture(count: count);
        final ordered = await f.db.orderedEpisodesFor(_media);
        final selected = ordered.take(count - 1).map((e) => e.id).toList();
        await f.db.setEpisodeCompleted(
          _id(1),
          origin: CompletionOrigin.automatic,
        );
        final original = (await f.db.episodeCompletionsFor(_media)).single;
        final snapshots = <int>[];
        final first = Completer<void>();
        final finalSnapshot = Completer<void>();
        final subscription = f.db
            .select(f.db.episodeCompletionRecords)
            .watch()
            .listen((rows) {
              snapshots.add(rows.length);
              if (!first.isCompleted) first.complete();
              if (rows.length == count - 1 && !finalSnapshot.isCompleted) {
                finalSnapshot.complete();
              }
            });
        addTearDown(subscription.cancel);
        await first.future;
        final timer = Stopwatch()..start();
        final completions = await f.db.setEpisodesWatched(
          _media,
          selected,
          watched: true,
          previousOf: _id(count),
        );
        timer.stop();
        await finalSnapshot.future.timeout(const Duration(seconds: 5));
        expect(snapshots, [1, count - 1]);
        expect(completions, hasLength(count - 1));
        expect(completions.any((e) => e.episodeId == _id(count)), isFalse);
        final again = await f.db.setEpisodesWatched(
          _media,
          selected,
          watched: true,
          previousOf: _id(count),
        );
        expect(again, hasLength(count - 1));
        expect(
          again.singleWhere((e) => e.episodeId == _id(1)).origin,
          CompletionOrigin.automatic,
        );
        expect(
          again.singleWhere((e) => e.episodeId == _id(1)).completedAt,
          original.completedAt,
        );
        expect(
          await f.db.select(f.db.animeSourcePlaybackResumes).get(),
          isEmpty,
        );
        expect(await f.db.animeProgress(_media), isNull);
        expect(timer.elapsed, lessThan(const Duration(seconds: 5)));
        // ignore: avoid_print
        print(
          'Episode watched guard: $count episodes, ${timer.elapsedMilliseconds}ms, one atomic update',
        );
        await f.db.setEpisodesWatched(_media, selected, watched: false);
        expect(await f.db.episodeCompletionsFor(_media), isEmpty);
      },
    );
  }

  for (final layout in [
    (
      name: 'narrow large text',
      size: const Size(320, 740),
      scale: 2.0,
      tv: false,
    ),
    (name: 'phone', size: const Size(390, 844), scale: 1.0, tv: false),
    (name: 'tablet', size: const Size(1100, 900), scale: 1.5, tv: false),
    (name: 'TV', size: const Size(1280, 900), scale: 1.3, tv: true),
  ]) {
    testWidgets(
      '${layout.name}: single actions and confirmed bulk update Details in place',
      (tester) async {
        final f = await _fixture();
        await _openDetails(
          tester,
          f,
          tv: layout.tv,
          size: layout.size,
          scale: layout.scale,
        );
        await _showActions(tester, 3, tv: layout.tv);
        await tester.tap(find.text('Mark as watched'));
        await tester.pumpAndSettle();
        expect(
          (await f.db.episodeCompletionsFor(_media)).map((e) => e.episodeId),
          [_id(3)],
        );
        expect(find.textContaining('Watched'), findsWidgets);
        await _showActions(tester, 3, tv: layout.tv);
        await tester.tap(find.text('Mark as unwatched'));
        await tester.pumpAndSettle();
        expect(await f.db.episodeCompletionsFor(_media), isEmpty);
        await _showActions(tester, 3, tv: layout.tv);
        await tester.tap(find.text('Mark previous 2 episodes as watched'));
        await tester.pumpAndSettle();
        expect(
          find.text('Mark 2 previous episodes as watched?'),
          findsOneWidget,
        );
        expect(await f.db.episodeCompletionsFor(_media), isEmpty);
        final cancel = find.byKey(const Key('cancel-episode-watched'));
        await tester.ensureVisible(cancel);
        await tester.pumpAndSettle();
        expect(cancel.hitTestable(), findsOneWidget);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(await f.db.episodeCompletionsFor(_media), isEmpty);
        await _showActions(tester, 3, tv: layout.tv);
        await tester.tap(find.text('Mark previous 2 episodes as watched'));
        await tester.pumpAndSettle();
        final confirm = find.byKey(const Key('confirm-episode-watched'));
        await tester.ensureVisible(confirm);
        await tester.pumpAndSettle();
        expect(confirm.hitTestable(), findsOneWidget);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(
          (await f.db.episodeCompletionsFor(_media)).map((e) => e.episodeId),
          unorderedEquals([_id(1), _id(2)]),
        );
        expect(
          find.text('2 previous episodes are now watched.'),
          findsOneWidget,
        );
        await _dismissFeedback(tester);
        expect(find.byKey(_actionKey(3)).hitTestable(), findsOneWidget);
        expect(
          f.repo.detailLoads,
          1,
          reason: 'No Details reload after any action',
        );
        expect(f.repo.libraryLoads, 0);
        expect(await f.db.animeProgress(_media), isNull);
        expect(
          await f.db.select(f.db.animeSourcePlaybackResumes).get(),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'TV D-pad selects, confirmation starts on Cancel, Back restores opener, Enter confirms',
    (tester) async {
      final f = await _fixture();
      await _openDetails(tester, f, tv: true);
      await _revealAction(tester, 3, tv: true);
      // Reach the rail with only remote directions, then move across actions.
      for (var i = 0; i < 12 && !_focusWithin(_actionKey(1)); i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
      }
      expect(_focusWithin(_actionKey(1)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_focusWithin(_actionKey(2)), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_focusWithin(_actionKey(3)), isTrue);
      for (final confirm in [false, true]) {
        await tester.sendKeyEvent(LogicalKeyboardKey.select);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          find.text('Mark 2 previous episodes as watched?'),
          findsOneWidget,
        );
        expect(_focusWithin(const Key('cancel-episode-watched')), isTrue);
        if (confirm) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(_focusWithin(const Key('confirm-episode-watched')), isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.select);
        } else {
          await tester.binding.handlePopRoute();
        }
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(_focusWithin(_actionKey(3)), isTrue);
        expect(
          await f.db.episodeCompletionsFor(_media),
          hasLength(confirm ? 2 : 0),
        );
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Open Details').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('failed action leaves indicators truthful and can be retried', (
    tester,
  ) async {
    final f = await _fixture();
    await _openDetails(tester, f);
    f.repo.failWatch = true;
    await _showActions(tester, 1);
    expect(
      tester
          .widget<PopupMenuItem<dynamic>>(
            find.ancestor(
              of: find.text('Mark previous 0 episodes as watched'),
              matching: find.byWidgetPredicate((w) => w is PopupMenuItem),
            ),
          )
          .enabled,
      isFalse,
    );
    await tester.tap(find.text('Mark as watched'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Could not update watched state. Reopen Details and try again.',
      ),
      findsOneWidget,
    );
    expect(await f.db.episodeCompletionsFor(_media), isEmpty);
    f.repo.failWatch = false;
    await _showActions(tester, 1);
    await tester.tap(find.text('Mark as watched'));
    await tester.pumpAndSettle();
    expect((await f.db.episodeCompletionsFor(_media)).map((e) => e.episodeId), [
      _id(1),
    ]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'leaving Details during a pending mutation never focuses a disposed action',
    (tester) async {
      final f = await _fixture();
      await _openDetails(tester, f, tv: true);
      f.repo.watchGate = Completer<void>();
      await _showActions(tester, 1, tv: true);
      await tester.tap(find.text('Mark as watched'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Open Details').hitTestable(), findsOneWidget);
      f.repo.watchGate!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(EpisodeWatchActions), findsNothing);
      expect(
        (await f.db.episodeCompletionsFor(_media)).map((e) => e.episodeId),
        [_id(1)],
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Future<_Fixture> _fixture({int count = 3}) async {
  final db = CanonicalDatabase(NativeDatabase.memory());
  final live = LiveProviderRepository(
    database: db,
    registry: ProviderRegistry([]),
    transport: _NoNetwork(),
  );
  final playback = PlaybackRepository(
    database: db,
    sources: PlaybackSourceRegistry([_Resolver()]),
    preferencesStore: PlaybackPreferencesStore(),
  );
  final repo = _Repository(live, playback: playback);
  final controller = ProductController(repo);
  addTearDown(() async {
    controller.dispose();
    await live.dispose();
  });
  await db.saveMedia(
    const CanonicalAnime(
      id: _media,
      format: AnimeFormat.tv,
      title: SourcedValue(
        value: 'An original anime',
        provenance: FieldProvenance(providerId: _source),
      ),
    ),
  );
  // Reversed insertion deliberately proves list position isn't provider/SQL order.
  await db.batch(
    (batch) => batch.insertAll(db.canonicalEpisodeRecords, [
      for (var i = count; i >= 1; i--)
        CanonicalEpisodeRecordsCompanion.insert(
          id: _id(i).value,
          mediaId: _media.value,
          rawLabel: 'Episode $i',
          number: Value(i.toDouble()),
        ),
    ]),
  );
  return _Fixture(db, repo, controller, playback);
}

class _Fixture {
  const _Fixture(this.db, this.repo, this.controller, this.playback);
  final CanonicalDatabase db;
  final _Repository repo;
  final ProductController controller;
  final PlaybackRepository playback;
}

class _Repository extends ProductRepository {
  _Repository(super.live, {super.playback});
  int detailLoads = 0, libraryLoads = 0;
  bool failWatch = false;
  Completer<void>? watchGate;
  @override
  Future<ProductMediaDetails?> details(CanonicalMediaId id) {
    detailLoads++;
    return super.details(id);
  }

  @override
  Future<List<ProductMediaSummary>> persisted() {
    libraryLoads++;
    return super.persisted();
  }

  @override
  Future<ProductMediaDetails> setEpisodeWatchState(
    ProductMediaDetails current,
    Iterable<CanonicalEpisodeId> ids, {
    required bool watched,
    CanonicalEpisodeId? previousOf,
  }) async {
    if (failWatch) throw StateError('Synthetic write failure');
    await watchGate?.future;
    return super.setEpisodeWatchState(
      current,
      ids,
      watched: watched,
      previousOf: previousOf,
    );
  }
}

class _NoNetwork implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Watched management must stay offline');
  @override
  void close() {}
}

class _Resolver implements PlaybackSourceResolver {
  @override
  ProviderId get providerId => _source;
  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      PlaybackSourceCapability.playbackCapable;
  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async =>
      PlaybackManifest(
        sourceName: 'Original fixture',
        binding: request.binding!,
        uri: Uri.file('/synthetic-not-downloaded.mp4'),
      );
}

Future<void> _openDetails(
  WidgetTester tester,
  _Fixture f, {
  bool tv = false,
  Size size = const Size(1280, 900),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final details = (await f.repo.details(_media))!;
  await tester.pumpWidget(
    MaterialApp(
      theme: zankaTheme(Brightness.dark),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            child: const Text('Open Details'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => tv
                    ? TvMediaDetailsScreen(
                        controller: f.controller,
                        mediaId: _media,
                        initialDetails: details,
                      )
                    : MediaDetailsScreen(
                        controller: f.controller,
                        mediaId: _media,
                        initialDetails: details,
                      ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Details'));
  await tester.pumpAndSettle();
}

Future<void> _revealAction(
  WidgetTester tester,
  int number, {
  bool tv = false,
}) async {
  final action = find.byKey(_actionKey(number));
  if (tv) {
    await tester.ensureVisible(action);
  } else {
    await tester.scrollUntilVisible(
      action,
      350,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('media-details')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.pumpAndSettle();
  expect(action.hitTestable(), findsOneWidget);
}

Future<void> _showActions(
  WidgetTester tester,
  int number, {
  bool tv = false,
}) async {
  await _dismissFeedback(tester);
  await _revealAction(tester, number, tv: tv);
  await tester.tap(find.byKey(_actionKey(number)));
  await tester.pumpAndSettle();
}

Future<void> _dismissFeedback(WidgetTester tester) async {
  if (find.byType(SnackBar).evaluate().isNotEmpty) {
    // Acknowledge the transient success/error feedback before the next action;
    // on small screens the bottom snackbar can cover the final episode row.
    await tester.drag(find.byType(SnackBar), const Offset(0, 120));
    await tester.pumpAndSettle();
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
