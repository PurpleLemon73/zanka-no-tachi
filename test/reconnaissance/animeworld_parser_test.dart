import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/reconnaissance/animeworld/animeworld_parser.dart';
import 'package:zanka_no_tachi/reconnaissance/source_contracts.dart';

void main() {
  final config = SourceConfig(
    providerId: 'animeworld',
    baseUrl: Uri(scheme: 'https', host: 'fixture.invalid'),
  );
  final parser = AnimeWorldParser(config: config);

  test('parses catalog alternate title, dub badge, and pagination', () {
    final page = parser.parseCatalog(_fixture('catalog_page.html'));
    expect(page.items, hasLength(2));
    expect(page.currentPage, 1);
    expect(page.totalPages, 101);
    expect(page.items.first.sourceId, 'a7LQj');
    expect(page.items.first.episodeCountLabel, '24');
    expect(page.items.last.sourceId, 'Ge2kM');
    expect(page.items.last.alternateTitle, 'Hagane no Renkinjutsushi');
    expect(page.items.last.isDubbed, isTrue);
    expect(page.items.last.audioLanguage, 'Italiano');
  });

  test('search uses the same typed listing boundary', () {
    final page = parser.parseSearch(_fixture('search_results.html'));
    expect(page.items.single.sourceId, 'Ge2kM');
    expect(page.items.single.isDubbed, isTrue);
  });

  test('parses dubbed TV metadata and episode tokens', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_tv.html'),
      sourceUrl: config.resolve('/play/fullmetal-alchemist.Ge2kM/lC-0o'),
    );
    expect(title.sourceId, 'Ge2kM');
    expect(title.sourceUrl.path, '/play/fullmetal-alchemist.Ge2kM');
    expect(title.format, 'Anime');
    expect(title.audioLanguage, 'Italiano');
    expect(title.subtitleMode, 'Doppiato');
    expect(title.airingSeasonLabel, 'Autunno 2003');
    expect(title.studio, 'Bones');
    expect(title.score, 7.84);
    expect(title.episodeCount, 51);
    expect(title.views, 711849);
    expect(title.episodes.first.sourceId, 'lC-0o');
    expect(title.episodes.first.number, 1);
  });

  test('completed page permits missing optional metadata', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_completed.html'),
      sourceUrl: config.resolve('/play/akame-ga-kill.a7LQj'),
    );
    expect(title.status, 'Finito');
    expect(title.releaseDateLabel, isNull);
    expect(title.episodeCount, 24);
  });

  test('dub metadata is distinct from format', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_dubbed.html'),
      sourceUrl: config.resolve('/play/fullmetal-alchemist.Ge2kM'),
    );
    expect(title.format, 'Anime');
    expect(title.audioLanguage, 'Italiano');
    expect(title.subtitleMode, 'Doppiato');
  });

  test('movie keeps hour-form duration and one episode', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_movie.html'),
      sourceUrl: config.resolve('/play/5-cm-al-secondo.44HCI'),
    );
    expect(title.format, 'Movie');
    expect(title.durationLabel, '1h e 02 min');
    expect(title.episodeCount, 1);
    expect(title.airingSeasonLabel, 'Inverno 2007');
  });

  test('unknown ongoing ONA total is preserved rather than invented', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_ona_irregular.html'),
      sourceUrl: config.resolve('/play/dungeons-and-television.amhXs'),
    );
    expect(title.format, 'ONA');
    expect(title.episodeCountLabel, '??');
    expect(title.episodeCount, isNull);
    expect(title.studio, 'Sconosciuto');
  });

  test('OVA remains a provider format and handles a single episode', () {
    final title = parser.parseTitle(
      _fixture('anime_detail_ova.html'),
      sourceUrl: config.resolve('/play/witch-craft-works.wkPOQ'),
    );
    expect(title.format, 'OVA');
    expect(title.episodes, hasLength(1));
  });

  test('handles an empty episode list', () {
    final title = parser.parseTitle(
      '<h1 class="anime-title">Empty</h1><div id="anime-info"></div>',
      sourceUrl: config.resolve('/play/empty.Empty1'),
    );
    expect(title.episodes, isEmpty);
  });
}

String _fixture(String name) =>
    File('fixtures/animeworld/$name').readAsStringSync();
