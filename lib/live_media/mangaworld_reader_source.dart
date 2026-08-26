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

class MangaWorldReaderSource implements ReaderSourceResolver {
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
  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      config.enabled && binding.relativeLocator != null
      ? ReaderSourceCapability.readerCapable
      : ReaderSourceCapability.temporarilyUnavailable;

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    final binding = request.binding;
    if (binding == null ||
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
      );
      rethrow;
    }
    LiveMediaDiagnostics.instance.record(
      providerId,
      LiveManifestState.available,
      '${pageUris.length} public image page(s) resolved',
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
            loadBytes: () => _loadPage(pageUris[index], chapterUri),
          ),
      ],
    );
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

List<Uri> parseMangaWorldPages(String html, Uri chapterUri) {
  final document = html_parser.parse(html);
  final first =
      document.querySelector('#reader img')?.attributes['src'] ??
      document.querySelector('img.img-fluid')?.attributes['src'];
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
  final names =
      RegExp(r'"([^"/\\]+\.(?:jpe?g|png|webp|gif))"', caseSensitive: false)
          .allMatches(html.substring(pagesStart + 1, pagesEnd))
          .map((value) => value.group(1)!)
          .toList();
  if (names.isEmpty || names.length > 500) {
    throw const ReaderException(
      ReaderErrorKind.manifestInvalid,
      'MangaWorld returned an invalid page list.',
    );
  }
  final base = firstUri.resolve('.');
  return names.map(base.resolve).toList(growable: false);
}
