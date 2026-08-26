import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/reconnaissance/mangaworld/mangaworld_parser.dart';
import 'package:zanka_no_tachi/reconnaissance/source_contracts.dart';

void main() {
  final config = SourceConfig(
    providerId: 'mangaworld',
    baseUrl: Uri(scheme: 'https', host: 'fixture.invalid'),
  );
  final parser = MangaWorldParser(config: config);

  test('parses catalog identity, metadata, latest chapter, and pagination', () {
    final page = parser.parseCatalog(_fixture('catalog_page.html'));
    expect(page.items, hasLength(2));
    expect(page.currentPage, 1);
    expect(page.totalPages, 42);
    expect(page.items.first.sourceId, '3693');
    expect(page.items.first.sourceUrl.host, 'fixture.invalid');
    expect(page.items.first.title, 'MAD');
    expect(page.items.first.type, 'Manga');
    expect(page.items.first.latestChapterLabel, 'Capitolo 46.5');
    expect(page.items.first.genres, ['Horror', 'Sci-fi']);
    expect(page.items.last.status, 'Finito');
  });

  test('search uses the same typed listing boundary', () {
    final page = parser.parseSearch(_fixture('search_results.html'));
    expect(page.items.single.sourceId, '3693');
    expect(page.items.single.title, 'MAD');
  });

  test(
    'parses current ungrouped chapter wrappers without inventing a volume',
    () {
      final title = parser.parseTitle(
        _fixture('manga_detail_ungrouped_chapters.html'),
        sourceUrl: config.resolve('/manga/2906/wooden-test'),
      );
      expect(title.chapters, hasLength(1));
      expect(title.chapters.single.sourceId, 'chapter-token');
      expect(title.chapters.single.label, 'Capitolo 15');
      expect(title.chapters.single.volumeLabel, isNull);
    },
  );

  test('parses ongoing title metadata and chapter dates', () {
    final title = parser.parseTitle(
      _fixture('manga_detail_ongoing.html'),
      sourceUrl: config.resolve('/manga/3693/mad'),
    );
    expect(title.sourceId, '3693');
    expect(title.author, 'OOTORI Yuusuke');
    expect(title.artist, 'OOTORI Yuusuke');
    expect(title.status, 'In corso');
    expect(title.views, 474855);
    expect(title.year, 2024);
    expect(title.genres, ['Horror', 'Sci-fi', 'Shounen']);
    expect(title.chapters.first.number, 46.5);
    expect(title.chapters.first.volumeLabel, 'Volume 08');
    expect(title.chapters.first.displayDate, '03 Giugno 2026');
  });

  test('parses completed state and missing optional artist', () {
    final title = parser.parseTitle(
      _fixture('manga_detail_completed.html'),
      sourceUrl: config.resolve('/manga/290/solo-leveling'),
    );
    expect(title.status, 'Finito');
    expect(title.artist, isNull);
    expect(title.chapters.single.number, 179);
  });

  test('preserves volume association across multiple groups', () {
    final title = parser.parseTitle(
      _fixture('manga_detail_volumes.html'),
      sourceUrl: config.resolve('/manga/2050/world-customize-creator'),
    );
    expect(title.chapters.map((chapter) => chapter.volumeLabel), [
      'Volume 06',
      'Volume 05',
    ]);
  });

  test('decimal numbers parse and non-numeric special remains unknown', () {
    final title = parser.parseTitle(
      _fixture('manga_detail_decimal_chapters.html'),
      sourceUrl: config.resolve('/manga/4000/the-angel-next-door'),
    );
    expect(title.chapters.map((chapter) => chapter.number), [30.2, 30.1, null]);
    expect(title.chapters.last.label, 'Extra estivo');
    expect(title.chapters.last.title, 'Speciale');
  });

  test('handles an empty chapter list', () {
    final title = parser.parseTitle(
      '<div class="comic-info"><h1 class="name">Empty</h1></div>',
      sourceUrl: config.resolve('/manga/999/empty'),
    );
    expect(title.chapters, isEmpty);
  });
}

String _fixture(String name) =>
    File('fixtures/mangaworld/$name').readAsStringSync();
