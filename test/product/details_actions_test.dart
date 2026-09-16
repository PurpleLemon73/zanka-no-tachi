import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/details_dialogs.dart';
import 'package:zanka_no_tachi/product/ui/media_details_screen.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/player/playback_source.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';
import 'package:zanka_no_tachi/reader/reader_source.dart';
import 'package:zanka_no_tachi/tv/tv_media_details_screen.dart';

const _id = CanonicalMediaId('details-action-original');
const _chapter = CanonicalChapterId('details-action-chapter');
const _episode = CanonicalEpisodeId('details-action-episode');
const _source = ProviderId('original');
const _title =
    'An Original Journey with a Very Long Title Beyond the Last Light of the Outer Cities';
const _description =
    'An original description with long metadata and enough words to require wrapping on a narrow screen. ';

void main() {
  for (final layout in [
    (
      name: 'narrow',
      size: const Size(320, 700),
      scale: 2.0,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'phone',
      size: const Size(390, 844),
      scale: 1.0,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'large-phone',
      size: const Size(480, 960),
      scale: 1.5,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'phone-landscape',
      size: const Size(844, 390),
      scale: 1.5,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'tablet-portrait',
      size: const Size(800, 1100),
      scale: 1.5,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'tablet-landscape',
      size: const Size(1280, 800),
      scale: 1.5,
      dpr: 1.0,
      tv: false,
    ),
    (
      name: 'TV-1080',
      size: const Size(1920, 1080),
      scale: 1.5,
      dpr: 1.0,
      tv: true,
    ),
    (
      name: 'TV-4K',
      size: const Size(3840, 2160),
      scale: 1.5,
      dpr: 3.0,
      tv: true,
    ),
  ]) {
    for (final anime in [false, true]) {
      testWidgets(
        '${layout.name} ${anime ? 'anime' : 'manga'} editor fits, scrolls, saves and respects keyboard',
        (tester) async {
          final fixture = await _fixture(tester, anime: anime);
          tester.view.physicalSize = layout.size;
          tester.view.devicePixelRatio = layout.dpr;
          await _open(tester, fixture, tv: layout.tv, scale: layout.scale);
          expect(tester.takeException(), isNull);
          for (final key in [
            'edit-metadata',
            'details-more-actions',
            if (!layout.tv) 'refresh-source-details',
          ]) {
            expect(find.byKey(Key(key)).hitTestable(), findsOneWidget);
          }
          await tester.tap(find.byKey(const Key('edit-metadata')));
          await tester.pumpAndSettle();
          expect(find.text('Edit details'), findsOneWidget);
          final dialog = tester.getRect(
            find.descendant(
              of: find.byType(Dialog),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Material && widget.type == MaterialType.card,
              ),
            ),
          );
          final logicalSize = layout.size / layout.dpr;
          expect(dialog.left, greaterThanOrEqualTo(16));
          expect(dialog.right, lessThanOrEqualTo(logicalSize.width - 16));
          expect(dialog.width, lessThanOrEqualTo(layout.tv ? 760 : 600));
          await tester.enterText(
            find.byKey(const Key('metadata-title')),
            'My original ${anime ? 'anime' : 'manga'}',
          );
          await tester.pump();
          for (final key in [
            'alternates',
            'description',
            'genres',
            'cover',
            'creator',
          ]) {
            final field = find.byKey(Key('metadata-$key'));
            await tester.ensureVisible(field);
            await tester.pumpAndSettle();
            expect(field.hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
          // Labels live above their inputs; they cannot overlap floating borders.
          for (final element in find.byType(DetailsField).evaluate()) {
            final widget = element.widget as DetailsField;
            final label = find.descendant(
              of: find.byWidget(widget),
              matching: find.text(widget.label),
            );
            final input = find.byWidget(widget.child);
            expect(
              tester.getBottomLeft(label).dy,
              lessThanOrEqualTo(tester.getTopLeft(input).dy),
            );
          }
          for (final (key, selection) in [
            ('metadata-status', 'completed'),
            if (anime) ('metadata-format', 'MOVIE'),
          ]) {
            await tester.ensureVisible(find.byKey(Key(key)));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(Key(key)));
            await tester.pumpAndSettle();
            final option = find.text(selection).last;
            await tester.ensureVisible(option);
            await tester.pumpAndSettle();
            await tester.tap(option);
            await tester.pumpAndSettle();
          }
          if (!layout.tv) {
            tester.view.viewInsets = FakeViewPadding(bottom: 250 * layout.dpr);
            await tester.pumpAndSettle();
          }
          final save = find.byKey(const Key('metadata-save'));
          await tester.ensureVisible(save);
          await tester.pumpAndSettle();
          expect(save.hitTestable(), findsOneWidget);
          expect(
            tester.getBottomRight(save).dy,
            lessThanOrEqualTo(logicalSize.height - (layout.tv ? 0 : 250)),
          );
          expect(tester.takeException(), isNull);
          await tester.tap(save);
          tester.view.viewInsets = FakeViewPadding.zero;
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing);
          expect(
            (await fixture.db.metadataOverride(_id))?.displayTitle,
            'My original ${anime ? 'anime' : 'manga'}',
          );
          expect((await fixture.db.libraryEntry(_id))?.isSaved, isTrue);
          expect((await fixture.db.media(_id))?.title.value, _title);
          expect(
            (await fixture.db.metadataOverride(_id))?.status,
            CanonicalMediaStatus.completed,
          );
          expect(
            (await fixture.db.metadataOverride(_id))?.animeFormat,
            anime ? AnimeFormat.movie : isNull,
          );
          expect(
            (await fixture.db.mangaProgress(_id))?.pageIndex,
            anime ? isNull : 3,
          );
          expect(
            (await fixture.db.animeProgress(_id))?.position,
            anime ? const Duration(seconds: 37) : isNull,
          );
          expect(
            (await fixture.db.mangaSourcePageResume(
              _source,
              'chapter-encode',
            ))?.pageIndex,
            anime ? isNull : 7,
          );
          expect(
            (await fixture.db.animeSourcePlaybackResume(
              _source,
              'episode-encode',
            ))?.position,
            anime ? const Duration(seconds: 43) : isNull,
          );
          await tester.tap(find.byKey(const Key('details-more-actions')));
          await tester.pumpAndSettle();
          expect(find.text('Reset title').hitTestable(), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('edit-metadata')).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final tv in [false, true]) {
    testWidgets(
      '${tv ? 'TV' : 'phone'} Back and Cancel never request Clear; explicit Clear confirms and resets',
      (tester) async {
        final fixture = await _fixture(tester, override: true);
        await _open(tester, fixture, tv: tv);
        await tester.tap(find.byKey(const Key('edit-metadata')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('metadata-title')),
          'Unsaved draft',
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(
          (await fixture.db.metadataOverride(_id))?.displayTitle,
          'Saved edit',
        );
        expect(
          find.byKey(Key(tv ? 'tv-media-details' : 'media-details')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('edit-metadata')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('metadata-clear')));
        await tester.tap(find.byKey(const Key('metadata-clear')));
        await tester.pumpAndSettle();
        expect(find.text('Clear all metadata edits?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(
          (await fixture.db.metadataOverride(_id))?.displayTitle,
          'Saved edit',
        );
        await tester.tap(find.byKey(const Key('edit-metadata')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('metadata-clear')));
        await tester.tap(find.byKey(const Key('metadata-clear')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear edits'));
        await tester.pumpAndSettle();
        expect(await fixture.db.metadataOverride(_id), isNull);
        expect(find.text(_title), findsOneWidget);
        expect((await fixture.db.mangaProgress(_id))?.pageIndex, 3);
      },
    );
  }

  testWidgets(
    'header refresh/reset/demo actions are labeled, guarded and truthful',
    (tester) async {
      final fixture = await _fixture(tester, override: true);
      await _open(tester, fixture);
      expect(find.byTooltip('Refresh source details'), findsOneWidget);
      expect(find.byTooltip('Edit display information'), findsOneWidget);
      expect(find.byTooltip('More Details actions'), findsOneWidget);
      await tester.tap(find.byKey(const Key('refresh-source-details')));
      await tester.pumpAndSettle();
      expect(fixture.repo.refreshes, 1);
      expect(find.text('Source details refreshed.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('details-more-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset title'));
      await tester.pumpAndSettle();
      expect((await fixture.db.metadataOverride(_id))?.displayTitle, isNull);
      expect(
        (await fixture.db.metadataOverride(_id))?.description,
        'Saved description',
      );
      await tester.tap(find.byKey(const Key('details-more-actions')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PopupMenuItem<Object>>(
              find.widgetWithText(PopupMenuItem<Object>, 'Reset title'),
            )
            .enabled,
        isFalse,
      );
      await tester.tap(find.byKey(const Key('enrich-metadata')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('does not look up live information'),
        findsOneWidget,
      );
      await tester.tap(find.text('Apply demo metadata'));
      await tester.pumpAndSettle();
      expect(find.text('Demo metadata applied.'), findsOneWidget);
      expect(
        (await fixture.db.effectiveMedia(
          _id,
        ))?.alternateTitles.map((v) => v.value),
        contains('$_title · enriched'),
      );
      expect((await fixture.db.mangaProgress(_id))?.pageIndex, 3);
    },
  );

  testWidgets(
    'failed Details command reports failure and allows a successful retry',
    (tester) async {
      final fixture = await _fixture(tester);
      await _open(tester, fixture);
      fixture.repo.failDemo = true;
      Future<void> applyDemo() async {
        await tester.tap(find.byKey(const Key('details-more-actions')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('enrich-metadata')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply demo metadata'));
        await tester.pumpAndSettle();
      }

      await applyDemo();
      expect(
        find.text('The change could not be completed. Please try again.'),
        findsOneWidget,
      );
      expect((await fixture.db.effectiveMedia(_id))!.alternateTitles, isEmpty);
      fixture.repo.failDemo = false;
      await applyDemo();
      expect(find.text('Demo metadata applied.'), findsOneWidget);
      expect(
        (await fixture.db.effectiveMedia(_id))!.alternateTitles,
        isNotEmpty,
      );
      expect(
        (await fixture.db.mangaSourcePageResume(
          _source,
          'chapter-encode',
        ))!.pageIndex,
        7,
      );
    },
  );

  for (final preferred in [false, true]) {
    testWidgets(
      'TV source chooser focuses ${preferred ? 'preferred' : 'first'} source and Back restores Details',
      (tester) async {
        final fixture = await _fixture(tester, anime: true, playable: true);
        if (preferred) {
          await fixture.db.setPreferredProvider(
            _id,
            const ProviderId('second-original'),
          );
        }
        // Reload the seeded initial Details snapshot after setting the preference.
        final refreshed = _Fixture(
          fixture.db,
          fixture.repo,
          fixture.controller,
          (await fixture.controller.details(_id))!,
        );
        tester.view.physicalSize = const Size(1280, 720);
        await _open(tester, refreshed, tv: true, scale: 1.3);
        final episode = find.descendant(
          of: find.byKey(const Key('tv-episode-rail')),
          matching: find.text('Episode 1'),
        );
        await tester.ensureVisible(episode);
        await tester.pumpAndSettle();
        await tester.tap(episode);
        await tester.pumpAndSettle();
        expect(find.text('Choose source'), findsOneWidget);
        final first = find.widgetWithText(
          OutlinedButton,
          preferred ? 'second-original' : 'original',
        );
        expect(
          Focus.of(
            tester.element(
              find.descendant(of: first, matching: find.byType(Text)),
            ),
          ).hasFocus,
          isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(FocusManager.instance.primaryFocus?.context, isNotNull);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(FocusManager.instance.primaryFocus?.context?.mounted, isTrue);
        expect(find.byKey(const Key('tv-media-details')), findsOneWidget);
        expect(
          (await fixture.db.animeSourcePlaybackResume(
            _source,
            'episode-encode',
          ))?.position,
          const Duration(seconds: 43),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'TV D-pad visits all editor controls and Back restores its header opener',
    (tester) async {
      final fixture = await _fixture(tester, anime: true);
      await _open(tester, fixture, tv: true, scale: 1.5);
      for (
        var attempt = 0;
        attempt < 12 && !_focusWithin(const Key('edit-metadata'));
        attempt++
      ) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
      }
      expect(_focusWithin(const Key('edit-metadata')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(_focusWithin(const Key('metadata-title')), isTrue);
      final visited = <String>{'title'};
      for (var step = 0; step < 18 && !visited.contains('save'); step++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        for (final field in [
          'alternates',
          'description',
          'genres',
          'cover',
          'status',
          'format',
          'creator',
          'cancel',
          'save',
        ]) {
          if (_focusWithin(Key('metadata-$field'))) visited.add(field);
        }
      }
      expect(
        visited,
        containsAll([
          'title',
          'alternates',
          'description',
          'genres',
          'cover',
          'status',
          'format',
          'creator',
          'cancel',
          'save',
        ]),
      );
      expect(
        find.byKey(const Key('metadata-save')).hitTestable(),
        findsOneWidget,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(_focusWithin(const Key('edit-metadata')), isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Open Details').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final anime in [false, true]) {
    testWidgets(
      '${anime ? 'episode' : 'chapter'} editing saves the same ID and validates a cleared label live',
      (tester) async {
        final fixture = await _fixture(tester, anime: anime);
        tester.view.physicalSize = const Size(360, 780);
        await _open(tester, fixture, scale: 1.5);
        final tile = find.byKey(
          Key(
            anime ? 'episode-${_episode.value}' : 'chapter-${_chapter.value}',
          ),
        );
        await tester.scrollUntilVisible(
          tile,
          400,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('media-details')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.longPress(tile);
        await tester.pumpAndSettle();
        expect(
          find.text(anime ? 'Edit episode' : 'Edit chapter'),
          findsOneWidget,
        );
        await tester.enterText(find.byKey(const Key('installment-label')), '');
        await tester.pump();
        expect(
          tester
              .widget<FilledButton>(find.byKey(const Key('installment-save')))
              .onPressed,
          isNull,
        );
        await tester.enterText(
          find.byKey(const Key('installment-label')),
          'My installment',
        );
        // Settle the focused text field's own caret reveal before scrolling
        // to the form action, as a person does after finishing typing.
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('installment-save')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('installment-save')).hitTestable(),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('installment-save')));
        await tester.pumpAndSettle();
        final refreshed = (await fixture.controller.details(_id))!;
        expect(
          anime
              ? refreshed.episodeEdits[_episode]?.rawLabel
              : refreshed.chapterEdits[_chapter]?.rawLabel,
          'My installment',
        );
        expect(refreshed.summary.media.id, _id);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _open(
  WidgetTester tester,
  _Fixture fixture, {
  bool tv = false,
  double scale = 1,
}) async {
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
                        controller: fixture.controller,
                        mediaId: _id,
                        initialDetails: fixture.details,
                      )
                    : MediaDetailsScreen(
                        controller: fixture.controller,
                        mediaId: _id,
                        initialDetails: fixture.details,
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

Future<_Fixture> _fixture(
  WidgetTester tester, {
  bool anime = false,
  bool override = false,
  bool playable = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 900);
  addTearDown(tester.view.reset);
  final db = CanonicalDatabase(NativeDatabase.memory());
  final live = LiveProviderRepository(
    database: db,
    registry: ProviderRegistry([]),
    transport: _NoNetwork(),
  );
  final repo = _Repository(
    live,
    reader: ReaderRepository(
      database: db,
      sources: ReaderSourceRegistry([]),
      preferencesStore: ReaderPreferencesStore(),
    ),
    playback: PlaybackRepository(
      database: db,
      sources: PlaybackSourceRegistry(
        playable
            ? [
                _NeverOpen(_source),
                _NeverOpen(const ProviderId('second-original')),
              ]
            : [],
      ),
      preferencesStore: PlaybackPreferencesStore(),
    ),
  );
  final controller = ProductController(repo);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await live.dispose();
  });
  const title = SourcedValue(
    value: _title,
    provenance: FieldProvenance(providerId: ProviderId('original')),
  );
  final description = SourcedValue(
    value: _description * 8,
    provenance: const FieldProvenance(providerId: ProviderId('original')),
  );
  await db.saveMedia(
    anime
        ? CanonicalAnime(
            id: _id,
            title: title,
            description: description,
            format: AnimeFormat.ona,
          )
        : CanonicalManga(id: _id, title: title, description: description),
  );
  final now = DateTime.utc(2026, 9, 14);
  await db.saveLibraryEntry(
    CanonicalLibraryEntry(
      mediaId: _id,
      isSaved: true,
      isFavorite: false,
      status: CanonicalLibraryStatus.inProgress,
      createdAt: now,
      updatedAt: now,
    ),
  );
  if (anime) {
    await db.saveEpisode(
      CanonicalEpisode(
        id: _episode,
        mediaId: _id,
        label: EpisodeLabel.parse('Episode 1'),
      ),
    );
    await db.saveAnimeProgress(
      CanonicalAnimeProgress(
        mediaId: _id,
        episodeId: _episode,
        position: const Duration(seconds: 37),
        updatedAt: now,
      ),
    );
    await db.saveEpisodeBinding(
      const EpisodeSourceBinding(
        canonicalId: _episode,
        providerId: _source,
        externalId: 'episode-encode',
      ),
    );
    await db.saveAnimeSourcePlaybackResume(
      AnimeSourcePlaybackResume(
        mediaId: _id,
        episodeId: _episode,
        providerId: _source,
        episodeExternalId: 'episode-encode',
        position: const Duration(seconds: 43),
        updatedAt: now,
      ),
    );
    if (playable) {
      for (final source in [_source, const ProviderId('second-original')]) {
        await db.saveEpisodeBinding(
          EpisodeSourceBinding(
            canonicalId: _episode,
            providerId: source,
            externalId: 'episode-encode',
          ),
        );
      }
    }
  } else {
    await db.saveChapter(
      CanonicalChapter(
        id: _chapter,
        mediaId: _id,
        number: ChapterNumber.parse('Chapter 1'),
      ),
    );
    await db.saveMangaProgress(
      CanonicalMangaProgress(
        mediaId: _id,
        chapterId: _chapter,
        pageIndex: 3,
        updatedAt: now,
      ),
    );
    await db.saveChapterBinding(
      const ChapterSourceBinding(
        canonicalId: _chapter,
        providerId: _source,
        externalId: 'chapter-encode',
      ),
    );
    await db.saveMangaSourcePageResume(
      MangaSourcePageResume(
        mediaId: _id,
        chapterId: _chapter,
        providerId: _source,
        chapterExternalId: 'chapter-encode',
        pageIndex: 7,
        updatedAt: now,
      ),
    );
  }
  if (override) {
    await db.saveMetadataOverride(
      const MetadataOverride(
        mediaId: _id,
        displayTitle: 'Saved edit',
        description: 'Saved description',
      ),
    );
  }
  return _Fixture(db, repo, controller, (await controller.details(_id))!);
}

class _Fixture {
  _Fixture(this.db, this.repo, this.controller, this.details);
  final CanonicalDatabase db;
  final _Repository repo;
  final ProductController controller;
  final ProductMediaDetails details;
}

class _Repository extends ProductRepository {
  _Repository(super.live, {super.reader, super.playback});
  int refreshes = 0;
  bool failDemo = false;
  @override
  Future<void> enrichWithDeterministicProof(CanonicalMediaId id) async {
    if (failDemo) throw StateError('synthetic failure');
    await super.enrichWithDeterministicProof(id);
  }

  @override
  Future<ProductMediaDetails> refreshDetails(CanonicalMediaId id) async {
    refreshes++;
    return (await details(id))!;
  }
}

class _NeverOpen implements PlaybackSourceResolver {
  _NeverOpen(this.providerId);
  @override
  final ProviderId providerId;
  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      PlaybackSourceCapability.playbackCapable;
  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) =>
      throw StateError('Details source chooser must not open playback');
}

class _NoNetwork implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Details editing must remain offline');
  @override
  void close() {}
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
