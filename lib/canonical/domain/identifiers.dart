abstract base class CanonicalId {
  const CanonicalId(this.value) : assert(value != '');
  final String value;
  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType &&
      other is CanonicalId &&
      value == other.value;
  @override
  int get hashCode => Object.hash(runtimeType, value);
  @override
  String toString() => value;
  String toJson() => value;
}

final class CanonicalMediaId extends CanonicalId {
  const CanonicalMediaId(super.value);
  factory CanonicalMediaId.fromJson(String value) => CanonicalMediaId(value);
}

final class CanonicalChapterId extends CanonicalId {
  const CanonicalChapterId(super.value);
  factory CanonicalChapterId.fromJson(String value) =>
      CanonicalChapterId(value);
}

final class CanonicalEpisodeId extends CanonicalId {
  const CanonicalEpisodeId(super.value);
  factory CanonicalEpisodeId.fromJson(String value) =>
      CanonicalEpisodeId(value);
}

final class ProviderId {
  const ProviderId(this.value) : assert(value != '');
  final String value;
  @override
  bool operator ==(Object other) => other is ProviderId && value == other.value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
  String toJson() => value;
  factory ProviderId.fromJson(String value) => ProviderId(value);
}
