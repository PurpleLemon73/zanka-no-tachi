import 'dart:collection';
import 'dart:typed_data';

import 'reader_domain.dart';

class ReaderPageCache {
  ReaderPageCache({this.maximumPages = 3});
  final int maximumPages;
  final LinkedHashMap<String, Future<Uint8List>> _values = LinkedHashMap();

  Future<Uint8List> load(ReaderPage page) {
    final existing = _values.remove(page.id);
    final value = existing ?? page.loadBytes();
    _values[page.id] = value;
    while (_values.length > maximumPages) {
      _values.remove(_values.keys.first);
    }
    return value;
  }

  void retry(ReaderPage page) => _values.remove(page.id);

  void prefetch(ReaderManifest manifest, int current) {
    for (final index in [current - 1, current + 1]) {
      if (index >= 0 && index < manifest.pages.length) {
        load(manifest.pages[index]).ignore();
      }
    }
  }

  void clear() => _values.clear();

  int get length => _values.length;
}
