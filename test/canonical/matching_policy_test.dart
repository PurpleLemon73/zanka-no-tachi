import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/matching.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';

void main() {
  const policy = MatchingPolicy();

  test('title equality proposes review but never auto-merges', () {
    final candidate = policy.evaluate(
      _manga('left', 'Berserk', 'provider-a'),
      _manga('right', 'Berserk', 'provider-b'),
    );
    expect(candidate.confidence, MatchConfidence.ambiguousCandidate);
    expect(candidate.requiresReview, isTrue);
    expect(candidate.mayAutoMerge, isFalse);
  });

  test('conflicting media kind is not a match', () {
    final candidate = policy.evaluate(
      _manga('left', 'Same', 'provider-a'),
      const CanonicalAnime(
        id: CanonicalMediaId('right'),
        title: SourcedValue(
          value: 'Same',
          provenance: FieldProvenance(providerId: ProviderId('provider-b')),
        ),
        format: AnimeFormat.tv,
      ),
    );
    expect(candidate.confidence, MatchConfidence.notAMatch);
    expect(candidate.evidence.single.strong, isTrue);
  });

  test('strong anime format conflict rejects candidate', () {
    final candidate = policy.evaluate(
      _anime('left', AnimeFormat.movie),
      _anime('right', AnimeFormat.tv),
    );
    expect(candidate.confidence, MatchConfidence.notAMatch);
    expect(
      candidate.evidence.any(
        (item) => item.kind == MatchEvidenceKind.animeFormat && item.strong,
      ),
      isTrue,
    );
  });

  test('explicit mapping is the only currently auto-mergeable evidence', () {
    final candidate = policy.evaluate(
      _manga('left', 'Provider title A', 'provider-a'),
      _manga('right', 'Provider title B', 'provider-b'),
      explicitMapping: true,
    );
    expect(candidate.confidence, MatchConfidence.exactExplicit);
    expect(candidate.requiresReview, isFalse);
    expect(candidate.mayAutoMerge, isTrue);
  });

  test(
    'title plus compatible format and airing year is high confidence only',
    () {
      const window = AiringWindow(
        season: AiringSeason.spring,
        year: 2024,
        rawLabel: 'Spring 2024',
      );
      final candidate = policy.evaluate(
        _anime('left', AnimeFormat.tv, airingWindow: window),
        _anime('right', AnimeFormat.tv, airingWindow: window),
      );
      expect(candidate.confidence, MatchConfidence.highConfidenceCandidate);
      expect(candidate.requiresReview, isTrue);
      expect(candidate.mayAutoMerge, isFalse);
    },
  );
}

CanonicalManga _manga(String id, String title, String provider) =>
    CanonicalManga(
      id: CanonicalMediaId(id),
      title: SourcedValue(
        value: title,
        provenance: FieldProvenance(providerId: ProviderId(provider)),
      ),
    );

CanonicalAnime _anime(
  String id,
  AnimeFormat format, {
  AiringWindow? airingWindow,
}) => CanonicalAnime(
  id: CanonicalMediaId(id),
  title: SourcedValue(
    value: 'Same',
    provenance: const FieldProvenance(providerId: ProviderId('provider')),
  ),
  format: format,
  airingWindow: airingWindow,
);
