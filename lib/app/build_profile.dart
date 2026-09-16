/// Compile-time product policy. Flutter supplies FLUTTER_APP_FLAVOR from
/// --flavor; the same value selects Android identity and bundled assets.
/// Missing/unknown values fail closed to production, including plain tests.
enum BuildProfile {
  development,
  production;

  static const current =
      String.fromEnvironment('FLUTTER_APP_FLAVOR') == 'development'
      ? development
      : production;

  static BuildProfile parse(String? value) =>
      value == 'development' ? development : production;

  bool get allowsDemoContent => this == development;
  bool get allowsDeveloperTools => this == development;
  bool get allowsExperimentalEngines => this == development;
  bool get allowsLocalDiagnostics => this == development;

  static const seedShowcase =
      current == development && bool.fromEnvironment('ZANKA_SHOWCASE');
  static const forceShowcaseTv =
      current == development && bool.fromEnvironment('ZANKA_SHOWCASE_TV');
}
