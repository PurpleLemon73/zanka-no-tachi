import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../reconnaissance/animeworld/animeworld_dtos.dart';
import '../reconnaissance/animeworld/animeworld_parser.dart';
import '../reconnaissance/mangaworld/mangaworld_dtos.dart';
import '../reconnaissance/mangaworld/mangaworld_parser.dart';
import '../reconnaissance/source_contracts.dart';
import 'provider_errors.dart';
import 'provider_registry.dart';
import 'provider_transport.dart';

class ProviderListingItem {
  const ProviderListingItem({
    required this.providerId,
    required this.externalId,
    required this.title,
    required this.relativeLocator,
    required this.mediaKind,
    this.subtitle,
    this.coverUrl,
  });

  final ProviderId providerId;
  final String externalId;
  final String title;
  final String relativeLocator;
  final CanonicalMediaKind mediaKind;
  final String? subtitle;
  final Uri? coverUrl;
}

class ProviderListingPage {
  const ProviderListingPage({
    required this.items,
    this.currentPage,
    this.totalPages,
  });
  final List<ProviderListingItem> items;
  final int? currentPage;
  final int? totalPages;
}

sealed class ProviderTitleResult {
  const ProviderTitleResult();
}

class MangaWorldTitleResult extends ProviderTitleResult {
  const MangaWorldTitleResult(this.dto);
  final MangaWorldTitleDto dto;
}

class AnimeWorldTitleResult extends ProviderTitleResult {
  const AnimeWorldTitleResult(this.dto);
  final AnimeWorldTitleDto dto;
}

abstract interface class LiveProviderAdapter {
  ProviderConfig get config;
  Future<ProviderHealth> checkHealth();
  Future<ProviderListingPage> catalog({int page = 1});
  Future<ProviderListingPage> search(String query, {int page = 1});
  Future<ProviderTitleResult> detail(ProviderListingItem item);
}

abstract class _BaseAdapter implements LiveProviderAdapter {
  const _BaseAdapter({required this.config, required this.transport});

  @override
  final ProviderConfig config;
  final ProviderTransport transport;

  Future<String> fetch(String relative) async {
    if (!config.enabled) throw ProviderDisabledException(config.id);
    if (config.baseUrl.scheme != 'http' && config.baseUrl.scheme != 'https') {
      throw ProviderConfigurationException(
        config.id,
        'Base URL must use HTTP or HTTPS',
      );
    }
    ProviderResponse response;
    try {
      response = await transport.get(config.resolve(relative));
    } on ProviderException {
      rethrow;
    } on Object catch (error) {
      throw ProviderNetworkException(
        config.id,
        'Request failed for $relative',
        cause: error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProviderHttpException(
        config.id,
        'Unexpected HTTP ${response.statusCode} for $relative',
        statusCode: response.statusCode,
      );
    }
    return response.body;
  }

  Future<ProviderHealth> healthFrom(
    Future<ProviderListingPage> Function() load,
  ) async {
    if (!config.enabled) {
      return const ProviderHealth(state: ProviderHealthState.disabled);
    }
    try {
      final page = await load();
      if (page.items.isEmpty) {
        return const ProviderHealth(
          state: ProviderHealthState.parserMismatch,
          diagnostic: 'Reachable page contained no recognized catalog items',
        );
      }
      return ProviderHealth(
        state: ProviderHealthState.available,
        diagnostic: '${page.items.length} catalog markers recognized',
      );
    } on ProviderParserException catch (error) {
      return ProviderHealth(
        state: ProviderHealthState.parserMismatch,
        diagnostic: error.message,
      );
    } on ProviderHttpException catch (error) {
      return ProviderHealth(
        state: ProviderHealthState.unexpectedResponse,
        diagnostic: error.message,
      );
    } on ProviderNetworkException catch (error) {
      return ProviderHealth(
        state: ProviderHealthState.unreachable,
        diagnostic: error.message,
      );
    } on ProviderConfigurationException catch (error) {
      return ProviderHealth(
        state: ProviderHealthState.unexpectedResponse,
        diagnostic: error.message,
      );
    }
  }

  String locator(Uri uri) =>
      uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
}

class MangaWorldLiveAdapter extends _BaseAdapter {
  MangaWorldLiveAdapter({required super.config, required super.transport})
    : parser = MangaWorldParser(
        config: SourceConfig(
          providerId: config.id.value,
          baseUrl: config.baseUrl,
        ),
      );

  final MangaWorldParser parser;

  @override
  Future<ProviderHealth> checkHealth() => healthFrom(catalog);

  @override
  Future<ProviderListingPage> catalog({int page = 1}) async {
    final uri = Uri(
      path: '/archive',
      queryParameters: page > 1 ? {'page': '$page'} : null,
    );
    final html = await fetch(uri.toString());
    return _listing(html, parser.parseCatalog, requireItems: true);
  }

  @override
  Future<ProviderListingPage> search(String query, {int page = 1}) async {
    final uri = Uri(
      path: '/archive',
      queryParameters: {'keyword': query.trim(), if (page > 1) 'page': '$page'},
    );
    final html = await fetch(uri.toString());
    return _listing(html, parser.parseSearch);
  }

  ProviderListingPage _listing(
    String html,
    MangaWorldCatalogPageDto Function(String) parse, {
    bool requireItems = false,
  }) {
    try {
      final page = parse(html);
      if ((requireItems && page.items.isEmpty) ||
          (!html.contains('comics-grid') && page.items.isEmpty)) {
        throw ProviderParserException(
          config.id,
          'MangaWorld catalog markers are missing',
        );
      }
      return ProviderListingPage(
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        items: page.items
            .map(
              (item) => ProviderListingItem(
                providerId: config.id,
                externalId: item.sourceId,
                title: item.title,
                relativeLocator: locator(item.sourceUrl),
                mediaKind: CanonicalMediaKind.manga,
                subtitle: item.latestChapterLabel,
                coverUrl: item.coverUrl,
              ),
            )
            .toList(),
      );
    } on ProviderParserException {
      rethrow;
    } on Object catch (error) {
      throw ProviderParserException(
        config.id,
        'MangaWorld listing parser rejected reachable HTML',
        cause: error,
      );
    }
  }

  @override
  Future<ProviderTitleResult> detail(ProviderListingItem item) async {
    final html = await fetch(item.relativeLocator);
    try {
      final dto = parser.parseTitle(
        html,
        sourceUrl: config.resolve(item.relativeLocator),
      );
      if (dto.title.isEmpty || !html.contains('comic-info')) {
        throw ProviderParserException(
          config.id,
          'MangaWorld detail markers are missing',
        );
      }
      return MangaWorldTitleResult(dto);
    } on ProviderParserException {
      rethrow;
    } on Object catch (error) {
      throw ProviderParserException(
        config.id,
        'MangaWorld detail parser rejected reachable HTML',
        cause: error,
      );
    }
  }
}

class AnimeWorldLiveAdapter extends _BaseAdapter {
  AnimeWorldLiveAdapter({required super.config, required super.transport})
    : parser = AnimeWorldParser(
        config: SourceConfig(
          providerId: config.id.value,
          baseUrl: config.baseUrl,
        ),
      );

  final AnimeWorldParser parser;

  @override
  Future<ProviderHealth> checkHealth() => healthFrom(catalog);

  @override
  Future<ProviderListingPage> catalog({int page = 1}) async {
    final uri = Uri(
      path: '/animes',
      queryParameters: page > 1 ? {'page': '$page'} : null,
    );
    final html = await fetch(uri.toString());
    return _listing(html, parser.parseCatalog, requireItems: true);
  }

  @override
  Future<ProviderListingPage> search(String query, {int page = 1}) async {
    final uri = Uri(
      path: '/search',
      queryParameters: {'keyword': query.trim(), if (page > 1) 'page': '$page'},
    );
    final html = await fetch(uri.toString());
    return _listing(html, parser.parseSearch);
  }

  ProviderListingPage _listing(
    String html,
    AnimeWorldCatalogPageDto Function(String) parse, {
    bool requireItems = false,
  }) {
    try {
      final page = parse(html);
      if ((requireItems && page.items.isEmpty) ||
          (!html.contains('film-list') && page.items.isEmpty)) {
        throw ProviderParserException(
          config.id,
          'AnimeWorld catalog markers are missing',
        );
      }
      return ProviderListingPage(
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        items: page.items
            .map(
              (item) => ProviderListingItem(
                providerId: config.id,
                externalId: item.sourceId,
                title: item.title,
                relativeLocator: locator(item.sourceUrl),
                mediaKind: CanonicalMediaKind.anime,
                subtitle: item.alternateTitle,
                coverUrl: item.coverUrl,
              ),
            )
            .toList(),
      );
    } on ProviderParserException {
      rethrow;
    } on Object catch (error) {
      throw ProviderParserException(
        config.id,
        'AnimeWorld listing parser rejected reachable HTML',
        cause: error,
      );
    }
  }

  @override
  Future<ProviderTitleResult> detail(ProviderListingItem item) async {
    final html = await fetch(item.relativeLocator);
    try {
      final dto = parser.parseTitle(
        html,
        sourceUrl: config.resolve(item.relativeLocator),
      );
      if (dto.title.isEmpty ||
          !(html.contains('anime-info') || html.contains('widget info'))) {
        throw ProviderParserException(
          config.id,
          'AnimeWorld detail markers are missing',
        );
      }
      return AnimeWorldTitleResult(dto);
    } on ProviderParserException {
      rethrow;
    } on Object catch (error) {
      throw ProviderParserException(
        config.id,
        'AnimeWorld detail parser rejected reachable HTML',
        cause: error,
      );
    }
  }
}
