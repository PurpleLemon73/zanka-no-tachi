import 'identifiers.dart';

class ChapterNumber implements Comparable<ChapterNumber> {
  const ChapterNumber._({
    required this.rawLabel,
    this.whole,
    this.fractionDigits,
  });

  factory ChapterNumber.parse(String rawLabel) {
    final normalized = rawLabel.trim();
    final match = RegExp(
      r'(?:capitolo\s*)?(\d+)(?:[.,](\d+))?',
      caseSensitive: false,
    ).firstMatch(normalized);
    return ChapterNumber._(
      rawLabel: normalized,
      whole: match == null ? null : int.parse(match.group(1)!),
      fractionDigits: match?.group(2),
    );
  }

  final String rawLabel;
  final int? whole;
  final String? fractionDigits;
  bool get isNumeric => whole != null;
  bool get isSpecial => !isNumeric;
  String? get normalizedNumber => whole == null
      ? null
      : fractionDigits == null
      ? '$whole'
      : '$whole.$fractionDigits';

  @override
  int compareTo(ChapterNumber other) {
    if (whole == null || other.whole == null) {
      return rawLabel.compareTo(other.rawLabel);
    }
    final wholeComparison = whole!.compareTo(other.whole!);
    if (wholeComparison != 0) return wholeComparison;
    final left = fractionDigits ?? '';
    final right = other.fractionDigits ?? '';
    final width = left.length > right.length ? left.length : right.length;
    final leftValue = int.tryParse(left.padRight(width, '0')) ?? 0;
    final rightValue = int.tryParse(right.padRight(width, '0')) ?? 0;
    return leftValue.compareTo(rightValue);
  }
}

class CanonicalChapter {
  const CanonicalChapter({
    required this.id,
    required this.mediaId,
    required this.number,
    this.title,
    this.volumeLabel,
  });
  final CanonicalChapterId id;
  final CanonicalMediaId mediaId;
  final ChapterNumber number;
  final String? title;
  final String? volumeLabel;
}

class EpisodeLabel {
  const EpisodeLabel({required this.rawLabel, this.number});
  factory EpisodeLabel.parse(String rawLabel) {
    final normalized = rawLabel.trim();
    final match = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(normalized);
    return EpisodeLabel(
      rawLabel: normalized,
      number: match == null
          ? null
          : double.tryParse(match.group(0)!.replaceAll(',', '.')),
    );
  }
  final String rawLabel;
  final double? number;
  bool get isStandardNumbered => number != null;
}

class CanonicalEpisode {
  const CanonicalEpisode({
    required this.id,
    required this.mediaId,
    required this.label,
    this.title,
    this.narrativeSeason,
  });
  final CanonicalEpisodeId id;
  final CanonicalMediaId mediaId;
  final EpisodeLabel label;
  final String? title;
  final int? narrativeSeason;
}

/// Natural presentation ordering for provider/user volume labels. Raw labels
/// remain untouched; only their relative order is derived.
int compareNaturalVolumeLabels(String? left, String? right) {
  if (left == right) return 0;
  if (left == null || left.trim().isEmpty) return 1;
  if (right == null || right.trim().isEmpty) return -1;
  final leftNumber = _volumeNumber(left);
  final rightNumber = _volumeNumber(right);
  if (leftNumber != null && rightNumber != null) {
    final compared = leftNumber.compareTo(rightNumber);
    if (compared != 0) return compared;
  } else if (leftNumber != null) {
    return -1;
  } else if (rightNumber != null) {
    return 1;
  }
  final folded = left.toLowerCase().compareTo(right.toLowerCase());
  return folded != 0 ? folded : left.compareTo(right);
}

double? _volumeNumber(String value) {
  final match = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(value);
  return match == null
      ? null
      : double.tryParse(match.group(0)!.replaceAll(',', '.'));
}
