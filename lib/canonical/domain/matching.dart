import 'identifiers.dart';
import 'media.dart';

enum MatchConfidence {
  exactExplicit,
  highConfidenceCandidate,
  ambiguousCandidate,
  notAMatch,
}

enum MatchEvidenceKind {
  explicitUserDecision,
  trustedMetadataId,
  mediaKind,
  normalizedTitle,
  alternateTitle,
  animeFormat,
  airingYear,
  providerMetadata,
  conflict,
}

class MatchEvidence {
  const MatchEvidence({
    required this.kind,
    required this.description,
    required this.supportsMatch,
    this.strong = false,
  });
  final MatchEvidenceKind kind;
  final String description;
  final bool supportsMatch;
  final bool strong;
}

class MatchCandidate {
  const MatchCandidate({
    required this.leftId,
    required this.rightId,
    required this.confidence,
    required this.evidence,
    required this.requiresReview,
  });
  final CanonicalMediaId leftId;
  final CanonicalMediaId rightId;
  final MatchConfidence confidence;
  final List<MatchEvidence> evidence;
  final bool requiresReview;
  bool get mayAutoMerge =>
      confidence == MatchConfidence.exactExplicit && !requiresReview;
}

enum MergeReason { reviewedUserDecision, trustedMetadataIdentity }

class MatchingPolicy {
  const MatchingPolicy();

  MatchCandidate evaluate(
    CanonicalMedia left,
    CanonicalMedia right, {
    bool explicitMapping = false,
    bool trustedMetadataIdEqual = false,
  }) {
    if (left.kind != right.kind) {
      return MatchCandidate(
        leftId: left.id,
        rightId: right.id,
        confidence: MatchConfidence.notAMatch,
        requiresReview: true,
        evidence: const [
          MatchEvidence(
            kind: MatchEvidenceKind.mediaKind,
            description: 'Canonical media kinds conflict',
            supportsMatch: false,
            strong: true,
          ),
        ],
      );
    }
    final normalizedLeft = _normalizeTitle(left.title.value);
    final normalizedRight = _normalizeTitle(right.title.value);
    final titleEqual = normalizedLeft == normalizedRight;
    final evidence = <MatchEvidence>[
      MatchEvidence(
        kind: MatchEvidenceKind.mediaKind,
        description: 'Media kinds agree: ${left.kind.name}',
        supportsMatch: true,
        strong: true,
      ),
      MatchEvidence(
        kind: MatchEvidenceKind.normalizedTitle,
        description: titleEqual
            ? 'Normalized primary titles agree'
            : 'Normalized primary titles differ',
        supportsMatch: titleEqual,
      ),
    ];
    if (explicitMapping || trustedMetadataIdEqual) {
      evidence.add(
        MatchEvidence(
          kind: explicitMapping
              ? MatchEvidenceKind.explicitUserDecision
              : MatchEvidenceKind.trustedMetadataId,
          description: explicitMapping
              ? 'An explicit reviewed identity mapping exists'
              : 'A trusted external canonical identifier agrees',
          supportsMatch: true,
          strong: true,
        ),
      );
    }
    var supportingStrongMetadata = false;
    if (left case CanonicalAnime(:final format)) {
      final rightAnime = right as CanonicalAnime;
      final rightFormat = rightAnime.format;
      final compatible =
          format == rightFormat ||
          format == AnimeFormat.unknown ||
          rightFormat == AnimeFormat.unknown;
      evidence.add(
        MatchEvidence(
          kind: MatchEvidenceKind.animeFormat,
          description: compatible
              ? 'Anime formats are compatible'
              : 'Anime formats conflict: ${format.name}/${rightFormat.name}',
          supportsMatch: compatible,
          strong: !compatible,
        ),
      );
      if (!compatible) {
        return MatchCandidate(
          leftId: left.id,
          rightId: right.id,
          confidence: MatchConfidence.notAMatch,
          evidence: evidence,
          requiresReview: true,
        );
      }
      final leftYear = left.airingWindow?.year;
      final rightYear = rightAnime.airingWindow?.year;
      if (leftYear != null && rightYear != null) {
        final sameYear = leftYear == rightYear;
        evidence.add(
          MatchEvidence(
            kind: MatchEvidenceKind.airingYear,
            description: sameYear
                ? 'Observed airing years agree: $leftYear'
                : 'Observed airing years conflict: $leftYear/$rightYear',
            supportsMatch: sameYear,
            strong: !sameYear,
          ),
        );
        if (!sameYear) {
          return MatchCandidate(
            leftId: left.id,
            rightId: right.id,
            confidence: MatchConfidence.notAMatch,
            evidence: evidence,
            requiresReview: true,
          );
        }
        supportingStrongMetadata = format == rightFormat;
      }
    }
    if (explicitMapping || trustedMetadataIdEqual) {
      return MatchCandidate(
        leftId: left.id,
        rightId: right.id,
        confidence: MatchConfidence.exactExplicit,
        evidence: evidence,
        requiresReview: false,
      );
    }
    return MatchCandidate(
      leftId: left.id,
      rightId: right.id,
      confidence: titleEqual
          ? supportingStrongMetadata
                ? MatchConfidence.highConfidenceCandidate
                : MatchConfidence.ambiguousCandidate
          : MatchConfidence.notAMatch,
      evidence: evidence,
      requiresReview: true,
    );
  }

  String _normalizeTitle(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

enum MergeConflictKind {
  title,
  provenance,
  libraryStatus,
  mangaProgress,
  animeProgress,
  duplicateProviderBinding,
  ambiguousInstallment,
}

class MergeConflict {
  const MergeConflict({required this.kind, required this.description});
  final MergeConflictKind kind;
  final String description;
}

class MergeResult {
  const MergeResult({
    required this.auditId,
    required this.survivingId,
    required this.retiredId,
    required this.conflicts,
  });
  final String auditId;
  final CanonicalMediaId survivingId;
  final CanonicalMediaId retiredId;
  final List<MergeConflict> conflicts;
}
