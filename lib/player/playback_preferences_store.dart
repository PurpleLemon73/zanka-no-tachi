import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'playback_domain.dart';

class PlaybackPreferencesStore {
  PlaybackPreferencesStore({File? file}) : _file = file;
  final File? _file;

  Future<File> _target() async =>
      _file ??
      File(
        '${(await getApplicationSupportDirectory()).path}/player-settings.json',
      );

  Future<PlaybackPreferences> load() async {
    try {
      final file = await _target();
      if (!await file.exists()) return const PlaybackPreferences();
      return PlaybackPreferences.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } on Object {
      return const PlaybackPreferences();
    }
  }

  Future<void> save(PlaybackPreferences value) async {
    final file = await _target();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(value.toJson()), flush: true);
  }
}
