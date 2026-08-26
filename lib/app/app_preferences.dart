import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppPreferences {
  const AppPreferences({this.onboardingComplete = false});
  final bool onboardingComplete;

  Map<String, Object?> toJson() => {
    'version': 1,
    'onboardingComplete': onboardingComplete,
  };
}

class AppPreferencesStore {
  AppPreferencesStore({File? file}) : _injectedFile = file;
  final File? _injectedFile;

  Future<File> _file() async =>
      _injectedFile ??
      File(
        '${(await getApplicationSupportDirectory()).path}/app-settings.json',
      );

  Future<AppPreferences> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const AppPreferences();
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, dynamic>) return const AppPreferences();
      return AppPreferences(
        onboardingComplete: value['onboardingComplete'] == true,
      );
    } on Object {
      return const AppPreferences();
    }
  }

  Future<void> completeOnboarding() async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.partial');
    await temporary.writeAsString(
      jsonEncode(const AppPreferences(onboardingComplete: true).toJson()),
      flush: true,
    );
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }
}
