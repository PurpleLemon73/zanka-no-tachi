import 'dart:convert';
import 'dart:typed_data';

import 'package:html/parser.dart' as html_parser;

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../live_provider/provider_registry.dart';
import '../reader/reader_domain.dart';
import '../reader/reader_source.dart';
import 'live_media_transport.dart';
import 'live_media_diagnostics.dart';

const mangaWorldProviderId = ProviderId('mangaworld');

class MangaWorldReaderSource
    implements ReaderSourceResolver, FreshReaderManifestRetry {
  MangaWorldReaderSource({
    required ProviderConfig config,
    required this.transport,
  }) : _config = (() => config);
  MangaWorldReaderSource.fromRegistry({
    required ProviderRegistry registry,
    required this.transport,
  }) : _config = (() => registry.require(mangaWorldProviderId));

  final ProviderConfig Function() _config;
  final LiveMediaTransport transport;
  ProviderConfig get config => _config();
  @override
  ProviderId get providerId => mangaWorldProviderId;

  @override
  ReaderSourceCapability capability(ChapterSourceBinding binding) {
    if (!config.enabled || binding.relativeLocator == null) {
      return ReaderSourceCapability.temporarilyUnavailable;
    }
    return switch (LiveMediaDiagnostics.instance
        .forBinding(providerId, binding.externalId)
        .state) {
      LiveManifestState.unsupported => ReaderSourceCapability.unsupported,
      LiveManifestState.networkFailure || LiveManifestState.parserMismatch =>
        ReaderSourceCapability.temporarilyUnavailable,
      _ => ReaderSourceCapability.readerCapable,
    };
  }

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    final binding = request.binding;
    if (!config.enabled ||
        binding == null ||
        binding.providerId != providerId ||
        binding.relativeLocator == null) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'This MangaWorld chapter is unavailable.',
      );
    }
    final chapterUri = config.resolve(binding.relativeLocator!);
    LiveMediaResponse response;
    try {
      response = await transport.get(chapterUri);
    } on Object catch (error) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.networkFailure,
        'Chapter document could not be reached',
        externalId: binding.externalId,
      );
      throw ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'MangaWorld could not be reached.',
        error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.networkFailure,
        'Chapter document returned HTTP ${response.statusCode}',
        externalId: binding.externalId,
      );
      throw ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'MangaWorld returned HTTP ${response.statusCode}.',
      );
    }
    List<Uri> pageUris;
    try {
      pageUris = parseMangaWorldPages(response.body, response.finalUri);
    } on ReaderException {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.parserMismatch,
        'Reader page markers changed',
        externalId: binding.externalId,
      );
      rethrow;
    }
    LiveMediaDiagnostics.instance.record(
      providerId,
      LiveManifestState.available,
      '${pageUris.length} public image page(s) resolved',
      externalId: binding.externalId,
      mediaType: 'image',
    );
    final recovery = _MangaWorldPageRecovery(
      source: this,
      binding: binding,
      chapterUri: chapterUri,
      referrer: response.finalUri,
      pageUris: pageUris,
    );
    return ReaderManifest(
      sourceName: 'MangaWorld',
      binding: binding,
      pages: [
        for (var index = 0; index < pageUris.length; index++)
          ReaderPage(
            id: '${binding.externalId}:$index',
            index: index,
            displayLocator: 'MangaWorld page ${index + 1}',
            loadBytes: () => recovery.load(index),
          ),
      ],
    );
  }

  Future<({List<Uri> pages, Uri referrer})> _refreshPages(
    ChapterSourceBinding binding,
    Uri chapterUri,
  ) async {
    LiveMediaResponse response;
    try {
      response = await transport.get(chapterUri);
    } on Object catch (error) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.networkFailure,
        'Fresh chapter manifest could not be reached',
        externalId: binding.externalId,
      );
      throw ReaderException(
        ReaderErrorKind.pageUnavailable,
        'The chapter could not be refreshed.',
        error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.networkFailure,
        'Fresh chapter manifest returned HTTP ${response.statusCode}',
        externalId: binding.externalId,
      );
      throw ReaderException(
        ReaderErrorKind.pageUnavailable,
        'The chapter refresh returned HTTP ${response.statusCode}.',
      );
    }
    try {
      return (
        pages: parseMangaWorldPages(response.body, response.finalUri),
        referrer: response.finalUri,
      );
    } on ReaderException {
      LiveMediaDiagnostics.instance.record(
        providerId,
        LiveManifestState.parserMismatch,
        'Fresh reader page markers changed',
        externalId: binding.externalId,
      );
      rethrow;
    }
  }

  Future<Uint8List> _loadPage(Uri uri, Uri referrer) async {
    try {
      final response = await transport.get(
        uri,
        headers: {'Referer': referrer.toString()},
      );
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          !(response.headers['content-type'] ?? '').toLowerCase().startsWith(
            'image/',
          )) {
        throw const ReaderException(
          ReaderErrorKind.pageUnavailable,
          'A MangaWorld page image is unavailable.',
        );
      }
      return response.bytes;
    } on ReaderException {
      rethrow;
    } on Object catch (error) {
      throw ReaderException(
        ReaderErrorKind.pageUnavailable,
        'A MangaWorld page image could not be loaded.',
        error,
      );
    }
  }
}

class _MangaWorldPageRecovery {
  _MangaWorldPageRecovery({
    required this.source,
    required this.binding,
    required this.chapterUri,
    required this.referrer,
    required this.pageUris,
  });

  final MangaWorldReaderSource source;
  final ChapterSourceBinding binding;
  final Uri chapterUri;
  Uri referrer;
  List<Uri> pageUris;
  bool refreshed = false;

  Future<Uint8List> load(int index) async {
    try {
      return await source._loadPage(pageUris[index], referrer);
    } on ReaderException {
      if (refreshed) rethrow;
      refreshed = true;
      final fresh = await source._refreshPages(binding, chapterUri);
      if (index >= fresh.pages.length) {
        throw const ReaderException(
          ReaderErrorKind.pageUnavailable,
          'This page is no longer present in the refreshed chapter.',
        );
      }
      pageUris = fresh.pages;
      referrer = fresh.referrer;
      final bytes = await source._loadPage(pageUris[index], referrer);
      LiveMediaDiagnostics.instance.record(
        source.providerId,
        LiveManifestState.available,
        'Fresh chapter manifest recovered one page request',
        externalId: binding.externalId,
        mediaType: 'image',
        freshRetryRecovered: true,
      );
      return bytes;
    }
  }
}

List<Uri> parseMangaWorldPages(String html, Uri chapterUri) {
  final document = html_parser.parse(html);
  final firstImage =
      document.querySelector('#reader img') ??
      document.querySelector('img.img-fluid');
  String? first;
  for (final attribute in const [
    'src',
    'data-src',
    'data-lazy-src',
    'data-original',
  ]) {
    final value = firstImage?.attributes[attribute]?.trim();
    if (value != null && value.isNotEmpty) {
      first = value;
      break;
    }
  }
  final firstUri = first == null ? null : chapterUri.resolve(first);
  final pagesKey = html.indexOf('"pages"');
  final pagesStart = pagesKey < 0 ? -1 : html.indexOf('[', pagesKey);
  final pagesEnd = pagesStart < 0 ? -1 : html.indexOf(']', pagesStart);
  if (firstUri == null || pagesStart < 0 || pagesEnd <= pagesStart) {
    throw const ReaderException(
      ReaderErrorKind.manifestInvalid,
      'MangaWorld reader markers changed.',
    );
  }
  Object? decoded;
  try {
    decoded = jsonDecode(html.substring(pagesStart, pagesEnd + 1));
  } on FormatException {
    decoded = null;
  }
  final references = decoded is List
      ? decoded.whereType<String>()
      : const Iterable<String>.empty();
  final pages = <Uri>[];
  final seen = <String>{};
  for (final reference in references) {
    final trimmed = reference.trim();
    if (trimmed.codeUnits.any((value) => value < 0x20)) continue;
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null ||
        !RegExp(
          r'\.(?:jpe?g|png|webp|gif)$',
          caseSensitive: false,
        ).hasMatch(parsed.path)) {
      continue;
    }
    final resolved = firstUri.resolve(trimmed);
    if (!{'http', 'https'}.contains(resolved.scheme)) continue;
    if (seen.add(resolved.toString())) pages.add(resolved);
  }
  if (pages.isEmpty || pages.length > 500) {
    throw const ReaderException(
      ReaderErrorKind.manifestInvalid,
      'MangaWorld returned an invalid page list.',
    );
  }
  return List.unmodifiable(pages);
}
