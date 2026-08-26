import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SearchHistoryStore {
  SearchHistoryStore({File? file, this.limit = 12})
    : _file = file,
      _persistent = true;
  SearchHistoryStore.memory({this.limit = 12})
    : _file = null,
      _persistent = false;
  final File? _file;
  final int limit;
  final bool _persistent;
  final List<String> _memory = [];

  Future<File> _target() async =>
      _file ??
      File(
        '${(await getApplicationSupportDirectory()).path}/search-history.json',
      );

  Future<List<String>> load() async {
    if (!_persistent) return List.of(_memory);
    try {
      final file = await _target();
      if (!await file.exists()) return const [];
      return (jsonDecode(await file.readAsString()) as List).cast<String>();
    } on Object {
      return const [];
    }
  }

  Future<List<String>> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return load();
    final values = (await load()).toList();
    values.removeWhere((value) => value.toLowerCase() == trimmed.toLowerCase());
    values.insert(0, trimmed);
    if (values.length > limit) values.removeRange(limit, values.length);
    if (!_persistent) {
      _memory
        ..clear()
        ..addAll(values);
      return values;
    }
    final file = await _target();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(values), flush: true);
    return values;
  }

  Future<void> clear() async {
    if (!_persistent) {
      _memory.clear();
      return;
    }
    final file = await _target();
    if (await file.exists()) await file.delete();
  }
}
