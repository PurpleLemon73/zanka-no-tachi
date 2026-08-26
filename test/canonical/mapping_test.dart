import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/mapping/animeworld_canonical_mapper.dart';
import 'package:zanka_no_tachi/canonical/mapping/mangaworld_canonical_mapper.dart';
import 'package:zanka_no_tachi/reconnaissance/animeworld/animeworld_dtos.dart';
import 'package:zanka_no_tachi/reconnaissance/animeworld/animeworld_parser.dart';
import 'package:zanka_no_tachi/reconnaissance/mangaworld/mangaworld_parser.dart';
import 'package:zanka_no_tachi/reconnaissance/source_contracts.dart';

void main() {
  final config = SourceConfig(
    providerId: 'fixture',
    baseUrl: Uri.parse('https://old-host.invalid'),
  );

  test('MangaWorld maps DTO facts without adopting provider IDs', () {
    final dto = MangaWorldParser(config: config).parseTitle(
      File(
        'fixtures/mangaworld/manga_detail_decimal_chapters.html',
      ).readAsStringSync(),
      sourceUrl: config.resolve('/manga/4000/the-angel-next-door'),
    );
    final result = const MangaWorldCanonicalMapper().mapTitle(
      dto: dto,
      mediaId: const CanonicalMediaId('canonical-manga'),
      chapterIdFor: (chapter) =>
          CanonicalChapterId('canonical-${chapter.sourceId}'),
    );
    expect(result.media.id.value, 'canonical-manga');
    expect(result.mediaBinding.externalId, '4000');
    expect(
      result.mediaBinding.relativeLocator,
      '/manga/4000/the-angel-next-door',
    );
    expect(result.chapters.first.number.normalizedNumber, '30.2');
    expect(result.chapters.last.number.isSpecial, isTrue);
    expect(result.chapters.last.volumeLabel, 'Volume 07');
    expect(result.chapterBindings.first.externalId, 'c30-2');
    expect(
      result.media.title.provenance.providerId,
      const ProviderId('mangaworld'),
    );
  });

  test(
    'AnimeWorld maps unknown total, format, and airing window independently',
    () {
      final dto = AnimeWorldParser(config: config).parseTitle(
        File(
          'fixtures/animeworld/anime_detail_ona_irregular.html',
        ).readAsStringSync(),
        sourceUrl: config.resolve('/play/dungeons-and-television.amhXs'),
      );
      final result = const AnimeWorldCanonicalMapper().mapTitle(
        dto: dto,
        mediaId: const CanonicalMediaId('canonical-anime'),
        episodeIdFor: (episode) =>
            CanonicalEpisodeId('canonical-${episode.sourceId}'),
      );
      expect(result.media.format, AnimeFormat.ona);
      expect(result.media.knownEpisodeTotal, isNull);
      expect(result.media.rawEpisodeTotal, '??');
      expect(result.media.airingWindow?.season, AiringSeason.summer);
      expect(result.media.narrativeSeason, isNull);
      expect(result.mediaBinding.externalId, 'amhXs');
    },
  );

  test(
    'AnimeWorld handles movie, OVA, and special without pretending they are TV seasons',
    () {
      const mapper = AnimeWorldCanonicalMapper();
      AnimeWorldTitleDto dto(String format) => AnimeWorldTitleDto(
        sourceId: format,
        sourceUrl: Uri.parse('https://provider.invalid/play/title.$format'),
        title: format,
        format: format,
        episodes: const [],
      );
      final formats = {
        'Movie': AnimeFormat.movie,
        'OVA': AnimeFormat.ova,
        'Special': AnimeFormat.special,
      };
      for (final entry in formats.entries) {
        final result = mapper.mapTitle(
          dto: dto(entry.key),
          mediaId: CanonicalMediaId('media-${entry.key}'),
          episodeIdFor: (_) => throw UnimplementedError(),
        );
        expect(result.media.format, entry.value);
        expect(result.media.narrativeSeason, isNull);
      }
    },
  );

  test(
    'relative bindings resolve through a replacement SourceConfig base URL',
    () {
      final locator = '/play/title.Token';
      final oldConfig = SourceConfig(
        providerId: 'anime',
        baseUrl: Uri.parse('https://old.invalid'),
      );
      final newConfig = SourceConfig(
        providerId: 'anime',
        baseUrl: Uri.parse('https://new.invalid'),
      );
      expect(oldConfig.resolve(locator).host, 'old.invalid');
      expect(newConfig.resolve(locator).host, 'new.invalid');
      expect(newConfig.resolve(locator).path, oldConfig.resolve(locator).path);
    },
  );

  test('missing optional provider metadata remains absent after mapping', () {
    final dto = AnimeWorldTitleDto(
      sourceId: 'minimal',
      sourceUrl: Uri(path: '/play/minimal.Token'),
      title: 'Minimal',
      episodes: [],
    );
    final result = const AnimeWorldCanonicalMapper().mapTitle(
      dto: dto,
      mediaId: const CanonicalMediaId('minimal-canonical'),
      episodeIdFor: (_) => throw UnimplementedError(),
    );
    expect(result.media.description, isNull);
    expect(result.media.airingWindow, isNull);
    expect(result.media.knownEpisodeTotal, isNull);
    expect(result.media.format, AnimeFormat.unknown);
  });
}
