import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';

void main() {
  test('canonical IDs are typed, equal, and serializable', () {
    const media = CanonicalMediaId('same-text');
    const chapter = CanonicalChapterId('same-text');
    expect(media, CanonicalMediaId.fromJson(media.toJson()));
    expect(media == chapter, isFalse);
    expect(const ProviderId('provider'), ProviderId.fromJson('provider'));
  });

  test('chapter numbering preserves exact decimal and special labels', () {
    final decimal = ChapterNumber.parse('Capitolo 30.10');
    final special = ChapterNumber.parse('Extra estivo');
    expect(decimal.normalizedNumber, '30.10');
    expect(decimal.rawLabel, 'Capitolo 30.10');
    expect(special.normalizedNumber, isNull);
    expect(special.isSpecial, isTrue);
    expect(ChapterNumber.parse('30.2').compareTo(decimal), greaterThan(0));
    expect(ChapterNumber.parse('30.1').compareTo(decimal), 0);
  });

  test('airing window and narrative season are distinct types', () {
    const anime = CanonicalAnime(
      id: CanonicalMediaId('anime'),
      title: SourcedValue(
        value: 'Title',
        provenance: FieldProvenance(providerId: ProviderId('provider')),
      ),
      format: AnimeFormat.tv,
      airingWindow: AiringWindow(
        season: AiringSeason.fall,
        year: 2003,
        rawLabel: 'Autunno 2003',
      ),
      narrativeSeason: NarrativeSeasonNumber(2),
    );
    expect(anime.airingWindow?.year, 2003);
    expect(anime.narrativeSeason?.value, 2);
  });
}
