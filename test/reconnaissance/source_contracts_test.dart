import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/reconnaissance/source_contracts.dart';

void main() {
  test(
    'retrieval receives configured URLs without coupling parser to a host',
    () async {
      final client = _RecordingClient();
      final retriever = SourceRetriever(
        config: SourceConfig(
          providerId: 'example',
          baseUrl: Uri(scheme: 'https', host: 'mirror.invalid', path: '/root/'),
        ),
        client: client,
      );
      expect(await retriever.fetch('catalog?page=2'), '<html></html>');
      expect(
        client.lastUrl,
        Uri.parse('https://mirror.invalid/root/catalog?page=2'),
      );
    },
  );

  test('normalization is a separate explicit boundary', () {
    const normalizer = SourceTextNormalizer();
    expect(normalizer.text('  Volume\n  08 '), 'Volume 08');
    expect(normalizer.decimal('Capitolo 46,5'), 46.5);
    expect(normalizer.decimal('Speciale'), isNull);
  });
}

class _RecordingClient implements SourceHttpClient {
  Uri? lastUrl;
  @override
  Future<String> get(Uri url) async {
    lastUrl = url;
    return '<html></html>';
  }
}
