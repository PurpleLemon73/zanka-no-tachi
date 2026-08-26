import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../source_contracts.dart';
import 'mangaworld_dtos.dart';

class MangaWorldParser
    implements SourceParser<MangaWorldCatalogPageDto, MangaWorldTitleDto> {
  const MangaWorldParser({
    required this.config,
    this.normalizer = const SourceTextNormalizer(),
  });

  final SourceConfig config;
  final SourceTextNormalizer normalizer;

  @override
  MangaWorldCatalogPageDto parseCatalog(String html) => _parseListing(html);

  @override
  MangaWorldCatalogPageDto parseSearch(String html) => _parseListing(html);

  MangaWorldCatalogPageDto _parseListing(String html) {
    final document = html_parser.parse(html);
    final items = document.querySelectorAll('.comics-grid .entry').map((entry) {
      final link = entry.querySelector('.manga-title');
      final sourceUrl = _uri(link?.attributes['href'])!;
      return MangaWorldCatalogItemDto(
        sourceId: _mediaId(sourceUrl),
        sourceUrl: sourceUrl,
        title: normalizer.text(link?.text),
        coverUrl: _uri(entry.querySelector('.thumb img')?.attributes['src']),
        type: _field(entry, 'Tipo:'),
        status: _field(entry, 'Stato:'),
        year: normalizer.integer(_field(entry, 'Anno:')),
        latestChapterLabel: _nullableText(
          entry.querySelector('.latest-chapter, .chapter')?.text,
        ),
        genres: entry
            .querySelectorAll('.genre a, .genres a')
            .map((node) => normalizer.text(node.text))
            .where((value) => value.isNotEmpty)
            .toList(),
      );
    }).toList();
    final page = document.querySelector('[data-current-page]');
    return MangaWorldCatalogPageDto(
      items: items,
      currentPage: normalizer.integer(page?.attributes['data-current-page']),
      totalPages: normalizer.integer(page?.attributes['data-total-pages']),
    );
  }

  @override
  MangaWorldTitleDto parseTitle(String html, {required Uri sourceUrl}) {
    final document = html_parser.parse(html);
    final info = document.querySelector('.comic-info');
    final chapters = <MangaWorldChapterDto>[];
    for (final volume in document.querySelectorAll('.volume-element')) {
      final volumeLabel = _nullableText(
        volume.querySelector('.volume-name')?.text,
      );
      for (final row in volume.querySelectorAll('.chapter')) {
        final link = row.querySelector('a.chap, a.chapter-link, a[href]');
        if (link == null) continue;
        final url = _uri(link.attributes['href']);
        if (url == null) continue;
        final label = normalizer.text(
          row.querySelector('.chapter-title, .name, span')?.text ?? link.text,
        );
        chapters.add(
          MangaWorldChapterDto(
            sourceId: _lastSegment(url),
            sourceUrl: url,
            label: label,
            number: normalizer.decimal(label),
            volumeLabel: volumeLabel,
            displayDate: _nullableText(
              row.querySelector('.chap-date, .chapter-date, .date')?.text,
            ),
            title: _nullableText(row.querySelector('.chapter-subtitle')?.text),
          ),
        );
      }
    }
    if (chapters.isEmpty) {
      for (final row in document.querySelectorAll(
        '.chapters-wrapper .chapter, .volume-chapters > .chapter',
      )) {
        final chapter = _chapter(row, volumeLabel: null);
        if (chapter != null) chapters.add(chapter);
      }
    }
    return MangaWorldTitleDto(
      sourceId: _mediaId(sourceUrl),
      sourceUrl: sourceUrl,
      title: normalizer.text(info?.querySelector('.name')?.text),
      coverUrl: _uri(info?.querySelector('.thumb img')?.attributes['src']),
      description: _nullableText(
        document
            .querySelector(
              '#noidungm, .comic-description .description, .comic-description p',
            )
            ?.text,
      ),
      type: _field(info, 'Tipo:'),
      status: _field(info, 'Stato:'),
      author: _field(info, 'Autore:'),
      artist: _field(info, 'Artista:'),
      year: normalizer.integer(_field(info, 'Anno di uscita:')),
      views: normalizer.integer(_field(info, 'Visualizzazioni:')),
      fansub: _field(info, 'Fansub:'),
      genres:
          info
              ?.querySelectorAll('.genres a, [href*="genre="]')
              .map((e) => normalizer.text(e.text))
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      alternateTitles: document
          .querySelectorAll('.alternate-title')
          .map((e) => normalizer.text(e.text))
          .where((e) => e.isNotEmpty)
          .toList(),
      chapters: chapters,
    );
  }

  MangaWorldChapterDto? _chapter(Element row, {required String? volumeLabel}) {
    final link = row.querySelector('a.chap, a.chapter-link, a[href]');
    if (link == null) return null;
    final url = _uri(link.attributes['href']);
    if (url == null) return null;
    final label = normalizer.text(
      row.querySelector('.chapter-title, .name, span')?.text ?? link.text,
    );
    return MangaWorldChapterDto(
      sourceId: _lastSegment(url),
      sourceUrl: url,
      label: label,
      number: normalizer.decimal(label),
      volumeLabel: volumeLabel,
      displayDate: _nullableText(
        row.querySelector('.chap-date, .chapter-date, .date')?.text,
      ),
      title: _nullableText(row.querySelector('.chapter-subtitle')?.text),
    );
  }

  String? _field(Element? root, String label) {
    if (root == null) return null;
    for (final element in root.querySelectorAll(
      '.field, .col-12, .genre, .status, .author, .artist, .genres, .story',
    )) {
      final text = normalizer.text(element.text);
      if (text.startsWith(label)) {
        return _nullableText(text.substring(label.length));
      }
    }
    return null;
  }

  Uri? _uri(String? value) => value == null ? null : config.resolve(value);
  String _mediaId(Uri url) =>
      RegExp(r'/manga/(\d+)').firstMatch(url.path)?.group(1) ??
      _lastSegment(url);
  String _lastSegment(Uri url) =>
      url.pathSegments.where((e) => e.isNotEmpty).last;
  String? _nullableText(String? value) {
    final result = normalizer.text(value);
    return result.isEmpty ? null : result;
  }
}
