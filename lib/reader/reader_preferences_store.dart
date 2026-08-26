import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'reader_domain.dart';

class ReaderPreferencesStore {
  ReaderPreferencesStore({File? file}) : _injectedFile = file;
  final File? _injectedFile;

  Future<File> _file() async =>
      _injectedFile ??
      File(
        '${(await getApplicationSupportDirectory()).path}/reader-settings.json',
      );

  Future<ReaderPreferences> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const ReaderPreferences();
      return ReaderPreferences.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } on Object {
      return const ReaderPreferences();
    }
  }

  Future<void> save(ReaderPreferences preferences) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(preferences.toJson()), flush: true);
  }
}
