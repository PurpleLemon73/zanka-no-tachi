/// Device-local playback implementation preference.
///
/// Automatic deliberately resolves to the production [videoPlayer] engine.
/// Experimental engines must always be selected explicitly.
enum PlaybackEnginePreference {
  automatic,
  videoPlayer,
  betterPlayerExperimental;

  static PlaybackEnginePreference parse(Object? value) =>
      PlaybackEnginePreference.values
          .where((item) => item.name == value)
          .firstOrNull ??
      PlaybackEnginePreference.automatic;
}
