class SourceConfig {
  const SourceConfig({required this.providerId, required this.baseUrl});

  final String providerId;
  final Uri baseUrl;

  Uri resolve(String reference) => baseUrl.resolve(reference);
}

abstract interface class SourceHttpClient {
  Future<String> get(Uri url);
}

abstract interface class SourceParser<TCatalog, TTitle> {
  TCatalog parseCatalog(String html);
  TCatalog parseSearch(String html);
  TTitle parseTitle(String html, {required Uri sourceUrl});
}

class SourcePage<T> {
  const SourcePage({required this.items, this.currentPage, this.totalPages});

  final List<T> items;
  final int? currentPage;
  final int? totalPages;
}

class SourceRetriever {
  const SourceRetriever({required this.config, required this.client});

  final SourceConfig config;
  final SourceHttpClient client;

  Future<String> fetch(String pathAndQuery) =>
      client.get(config.resolve(pathAndQuery));
}

class SourceTextNormalizer {
  const SourceTextNormalizer();

  String text(String? value) =>
      (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

  int? integer(String? value) {
    final digits = text(value).replaceAll(RegExp(r'[^0-9-]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  double? decimal(String? value) {
    final match = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(text(value));
    return match == null
        ? null
        : double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }
}
