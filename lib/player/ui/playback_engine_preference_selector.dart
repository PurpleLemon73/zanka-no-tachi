import 'dart:async';

import 'package:flutter/material.dart';
import '../../app/build_profile.dart';

import '../playback_domain.dart';
import '../playback_engine_preference.dart';
import '../playback_preferences_store.dart';

/// Device-local playback-engine selection for the Advanced/Developer surface.
///
/// Changing this preference never replaces an active engine. The player reads
/// the saved value when it creates the next playback session.
class PlaybackEnginePreferenceSelector extends StatefulWidget {
  const PlaybackEnginePreferenceSelector({
    super.key,
    required this.preferencesStore,
  });

  static const selectorKey = Key('playback-engine-selector');
  static const automaticKey = Key('playback-engine-automatic');
  static const videoPlayerKey = Key('playback-engine-video-player');
  static const betterPlayerKey = Key(
    'playback-engine-better-player-experimental',
  );
  static const statusKey = Key('playback-engine-save-status');

  final PlaybackPreferencesStore preferencesStore;

  @override
  State<PlaybackEnginePreferenceSelector> createState() =>
      _PlaybackEnginePreferenceSelectorState();
}

class _PlaybackEnginePreferenceSelectorState
    extends State<PlaybackEnginePreferenceSelector> {
  PlaybackPreferences? _preferences;
  Future<void> _saveQueue = Future<void>.value();
  int _saveRevision = 0;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (BuildProfile.current.allowsExperimentalEngines) unawaited(_load());
  }

  Future<void> _load() async {
    final preferences = await widget.preferencesStore.load();
    if (!mounted) return;
    setState(() => _preferences = preferences);
  }

  void _select(PlaybackEnginePreference? preference) {
    final current = _preferences;
    if (preference == null || current == null) return;
    if (current.enginePreference == preference) return;

    final updated = current.copyWith(enginePreference: preference);
    final revision = ++_saveRevision;
    setState(() {
      _preferences = updated;
      _saving = true;
      _error = null;
    });

    final operation = _saveQueue.then(
      (_) => widget.preferencesStore.save(updated),
    );
    _saveQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    unawaited(_finishSave(operation, revision));
  }

  Future<void> _finishSave(Future<void> operation, int revision) async {
    try {
      await operation;
      if (!mounted || revision != _saveRevision) return;
      setState(() => _saving = false);
    } on Object {
      PlaybackPreferences? persisted;
      try {
        persisted = await widget.preferencesStore.load();
      } on Object {
        // Keep the last known value if even the device-local reload fails.
      }
      if (!mounted || revision != _saveRevision) return;
      setState(() {
        if (persisted != null) _preferences = persisted;
        _saving = false;
        _error = 'Could not save the playback engine preference.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!BuildProfile.current.allowsExperimentalEngines) {
      return const SizedBox.shrink();
    }
    final preferences = _preferences;
    if (preferences == null) {
      return const Card(
        key: PlaybackEnginePreferenceSelector.selectorKey,
        child: ListTile(
          title: Text('Playback engine'),
          subtitle: Text('Loading device preference…'),
        ),
      );
    }

    final selected = preferences.enginePreference;
    return Card(
      key: PlaybackEnginePreferenceSelector.selectorKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Playback engine',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Choose which engine new playback sessions use on this device.',
              ),
            ),
            RadioGroup<PlaybackEnginePreference>(
              groupValue: selected,
              onChanged: _select,
              child: Column(
                children: [
                  _EngineOption(
                    optionKey: PlaybackEnginePreferenceSelector.automaticKey,
                    value: PlaybackEnginePreference.automatic,
                    title: 'Automatic',
                    subtitle: 'Recommended · uses video_player',
                    selected: selected == PlaybackEnginePreference.automatic,
                  ),
                  _EngineOption(
                    optionKey: PlaybackEnginePreferenceSelector.videoPlayerKey,
                    value: PlaybackEnginePreference.videoPlayer,
                    title: 'video_player',
                    subtitle: 'Production engine',
                    selected: selected == PlaybackEnginePreference.videoPlayer,
                  ),
                  _EngineOption(
                    optionKey: PlaybackEnginePreferenceSelector.betterPlayerKey,
                    value: PlaybackEnginePreference.betterPlayerExperimental,
                    title: 'Better Player (Experimental)',
                    subtitle: 'Basic MP4 evaluation only',
                    selected:
                        selected ==
                        PlaybackEnginePreference.betterPlayerExperimental,
                  ),
                ],
              ),
            ),
            Padding(
              key: PlaybackEnginePreferenceSelector.statusKey,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _error ??
                    (_saving
                        ? 'Saving… Changes apply to the next playback session.'
                        : 'Changes apply to the next playback session.'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _error == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineOption extends StatelessWidget {
  const _EngineOption({
    required this.optionKey,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final Key optionKey;
  final PlaybackEnginePreference value;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) => RadioListTile<PlaybackEnginePreference>(
    key: optionKey,
    value: value,
    title: Text(title),
    subtitle: Text(subtitle),
    selected: selected,
    autofocus: selected,
  );
}
