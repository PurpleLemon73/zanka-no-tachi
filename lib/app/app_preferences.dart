import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ZankaThemeMode { system, light, dark }

enum ZankaAccent { defaultRed, orange, green, teal, blue, indigo, purple }

class AppPreferences {
  const AppPreferences({
    this.onboardingComplete = false,
    this.themeMode = ZankaThemeMode.system,
    this.accent = ZankaAccent.defaultRed,
  });
  final bool onboardingComplete;
  final ZankaThemeMode themeMode;
  final ZankaAccent accent;

  Map<String, Object?> toJson() => {
    'version': 2,
    'onboardingComplete': onboardingComplete,
    'themeMode': themeMode.name,
    'accent': accent.name,
  };

  AppPreferences copyWith({
    bool? onboardingComplete,
    ZankaThemeMode? themeMode,
    ZankaAccent? accent,
  }) => AppPreferences(
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    themeMode: themeMode ?? this.themeMode,
    accent: accent ?? this.accent,
  );
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
        themeMode:
            ZankaThemeMode.values
                .where((item) => item.name == value['themeMode'])
                .firstOrNull ??
            ZankaThemeMode.system,
        accent:
            ZankaAccent.values
                .where((item) => item.name == value['accent'])
                .firstOrNull ??
            ZankaAccent.defaultRed,
      );
    } on Object {
      return const AppPreferences();
    }
  }

  Future<void> completeOnboarding() async {
    final current = await load();
    await save(current.copyWith(onboardingComplete: true));
  }

  Future<void> saveAppearance({
    required ZankaThemeMode themeMode,
    required ZankaAccent accent,
  }) async {
    final current = await load();
    await save(current.copyWith(themeMode: themeMode, accent: accent));
  }

  Future<void> save(AppPreferences value) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.partial');
    await temporary.writeAsString(jsonEncode(value.toJson()), flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }
}
