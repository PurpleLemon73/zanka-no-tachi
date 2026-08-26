import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../source_contracts.dart';
import 'animeworld_dtos.dart';

class AnimeWorldParser
    implements SourceParser<AnimeWorldCatalogPageDto, AnimeWorldTitleDto> {
  const AnimeWorldParser({
    required this.config,
    this.normalizer = const SourceTextNormalizer(),
  });

  final SourceConfig config;
  final SourceTextNormalizer normalizer;

  @override
  AnimeWorldCatalogPageDto parseCatalog(String html) => _parseListing(html);
  @override
  AnimeWorldCatalogPageDto parseSearch(String html) => _parseListing(html);

  AnimeWorldCatalogPageDto _parseListing(String html) {
    final document = html_parser.parse(html);
    final items = document
        .querySelectorAll('.film-list .item, .film-list .film')
        .map((entry) {
          final link = entry.querySelector('a.name, .name a');
          final url = _uri(link?.attributes['href'])!;
          return AnimeWorldCatalogItemDto(
            sourceId: _seriesId(url),
            sourceUrl: url,
            title: normalizer.text(link?.attributes['title'] ?? link?.text),
            alternateTitle: _nullableText(link?.attributes['data-jtitle']),
            coverUrl: _uri(entry.querySelector('img')?.attributes['src']),
            format: _field(entry, 'Tipo:'),
            status: _field(entry, 'Stato:'),
            audioLanguage: _field(entry, 'Audio:'),
            isDubbed: entry.querySelector('.dub, .badge-dub') != null,
            episodeCountLabel: _field(entry, 'Episodi:'),
          );
        })
        .toList();
    final pagination = document.querySelector(
      '.pagination, [data-current-page]',
    );
    return AnimeWorldCatalogPageDto(
      items: items,
      currentPage: normalizer.integer(
        pagination?.attributes['data-current-page'] ??
            pagination?.querySelector('.current')?.text,
      ),
      totalPages: normalizer.integer(
        pagination?.attributes['data-total-pages'] ??
            pagination?.querySelector('.total')?.text,
      ),
    );
  }

  @override
  AnimeWorldTitleDto parseTitle(String html, {required Uri sourceUrl}) {
    final document = html_parser.parse(html);
    final info = document.querySelector(
      '.anime-info, #anime-info, .widget.info .info',
    );
    final episodeTotalLabel = _field(info, 'Episodi:');
    final episodes = document
        .querySelectorAll('.server .episodes a, .episode-list a, a.episode')
        .map((link) {
          final url = _uri(link.attributes['href'])!;
          final label = normalizer.text(link.text);
          return AnimeWorldEpisodeDto(
            sourceId: _episodeId(url),
            sourceUrl: url,
            label: label,
            number: normalizer.decimal(
              link.attributes['data-episode-num'] ?? label,
            ),
            title: _nullableText(link.attributes['data-title']),
            displayDate: _nullableText(link.attributes['data-date']),
          );
        })
        .toList();
    return AnimeWorldTitleDto(
      sourceId: _seriesId(sourceUrl),
      sourceUrl: _seriesUrl(sourceUrl),
      title: normalizer.text(
        document.querySelector('#anime-title, .anime-title, h1')?.text,
      ),
      alternateTitle: _nullableText(
        document
            .querySelector('#anime-title, .anime-title, h1')
            ?.attributes['data-jtitle'],
      ),
      coverUrl: _uri(
        document
                .querySelector(
                  '#thumbnail-watch img, .anime-cover img, .poster img',
                )
                ?.attributes['src'] ??
            document
                .querySelector('meta[property="og:image"]')
                ?.attributes['content'],
      ),
      description: _nullableText(
        document
            .querySelector(
              '.widget.info .desc, .anime-description, .description',
            )
            ?.text,
      ),
      format: _field(info, 'Categoria:') ?? _field(info, 'Tipo:'),
      status: _field(info, 'Stato:'),
      audioLanguage: _field(info, 'Audio:'),
      subtitleMode: _field(info, 'Sottotitoli:'),
      releaseDateLabel: _field(info, 'Data di Uscita:'),
      airingSeasonLabel: _field(info, 'Stagione:'),
      studio: _field(info, 'Studio:'),
      score: normalizer.decimal(_field(info, 'Voto:')),
      durationLabel: _field(info, 'Durata:'),
      episodeCount: episodeTotalLabel == '??'
          ? null
          : normalizer.integer(episodeTotalLabel),
      episodeCountLabel: episodeTotalLabel,
      views: normalizer.integer(_field(info, 'Visualizzazioni:')),
      genres:
          info
              ?.querySelectorAll(
                '.genres a, [data-field="genres"] a, dl.meta dd a[href*="genre/"]',
              )
              .map((e) => normalizer.text(e.text))
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      episodes: episodes,
    );
  }

  String? _field(Element? root, String label) {
    if (root == null) return null;
    for (final term in root.querySelectorAll('dl.meta dt, dl dt')) {
      if (normalizer.text(term.text) == label) {
        return _nullableText(term.nextElementSibling?.text);
      }
    }
    for (final element in root.querySelectorAll(
      '.field, .meta-row, dl > div',
    )) {
      final key = normalizer.text(element.querySelector('dt, .label')?.text);
      if (key == label) {
        return _nullableText(element.querySelector('dd, .value')?.text);
      }
      final text = normalizer.text(element.text);
      if (text.startsWith(label)) {
        return _nullableText(text.substring(label.length));
      }
    }
    return null;
  }

  Uri? _uri(String? value) => value == null ? null : config.resolve(value);
  String _seriesId(Uri url) =>
      RegExp(r'/play/[^/]+\.([^/]+)').firstMatch(url.path)?.group(1) ??
      url.pathSegments.last;
  String _episodeId(Uri url) =>
      url.pathSegments.where((e) => e.isNotEmpty).length > 2
      ? url.pathSegments.where((e) => e.isNotEmpty).last
      : _seriesId(url);
  Uri _seriesUrl(Uri url) {
    final parts = url.pathSegments.where((e) => e.isNotEmpty).take(2).join('/');
    return url.replace(path: '/$parts', query: null, fragment: null);
  }

  String? _nullableText(String? value) {
    final result = normalizer.text(value);
    return result.isEmpty ? null : result;
  }
}
