import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/product/smart_resume.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';

void main() {
  const mediaId = CanonicalMediaId('media');
  const providerA = ProviderId('a');
  const providerB = ProviderId('b');
  final now = DateTime.utc(2026);

  ReaderChapterAvailability chapter(int number, {bool available = true}) {
    final value = CanonicalChapter(
      id: CanonicalChapterId('chapter-$number'),
      mediaId: mediaId,
      number: ChapterNumber.parse('Chapter $number'),
    );
    final binding = ChapterSourceBinding(
      canonicalId: value.id,
      providerId: providerA,
      externalId: 'a-$number',
    );
    return ReaderChapterAvailability(
      chapter: value,
      bindings: [binding],
      capabilities: {
        providerA: available
            ? ReaderSourceCapability.readerCapable
            : ReaderSourceCapability.metadataOnly,
      },
    );
  }

  PlaybackEpisodeAvailability episode(int number, {bool available = true}) {
    final value = CanonicalEpisode(
      id: CanonicalEpisodeId('episode-$number'),
      mediaId: mediaId,
      label: EpisodeLabel.parse('Episode $number'),
    );
    final binding = EpisodeSourceBinding(
      canonicalId: value.id,
      providerId: providerA,
      externalId: 'a-$number',
    );
    return PlaybackEpisodeAvailability(
      episode: value,
      bindings: [binding],
      capabilities: {
        providerA: available
            ? PlaybackSourceCapability.playbackCapable
            : PlaybackSourceCapability.metadataOnly,
      },
    );
  }

  test('manga Start, Resume, Next, skip unavailable and Completed', () async {
    final chapters = [chapter(1), chapter(2, available: false), chapter(3)];
    final start = await SmartResumePolicy.manga(
      chapters: chapters,
      completed: {},
      progress: null,
      preferredProvider: providerA,
      resumeFor: (_) async => null,
    );
    expect(start.action, SmartResumeAction.startReading);
    expect(start.chapterId, chapters.first.chapter.id);

    final resume = MangaSourcePageResume(
      mediaId: mediaId,
      chapterId: chapters.first.chapter.id,
      providerId: providerA,
      chapterExternalId: 'a-1',
      pageIndex: 8,
      totalPages: 12,
      updatedAt: now,
    );
    final current = await SmartResumePolicy.manga(
      chapters: chapters,
      completed: {},
      progress: CanonicalMangaProgress(
        mediaId: mediaId,
        chapterId: chapters.first.chapter.id,
        pageIndex: 8,
        totalPages: 12,
        updatedAt: now,
      ),
      preferredProvider: providerB,
      resumeFor: (binding) async =>
          binding.providerId == providerA ? resume : null,
    );
    expect(current.action, SmartResumeAction.resumeReading);
    expect(current.pageResume, same(resume));

    final next = await SmartResumePolicy.manga(
      chapters: chapters,
      completed: {chapters.first.chapter.id},
      progress: CanonicalMangaProgress(
        mediaId: mediaId,
        chapterId: chapters.first.chapter.id,
        pageIndex: 11,
        updatedAt: now,
      ),
      preferredProvider: providerA,
      resumeFor: (_) async => null,
    );
    expect(next.action, SmartResumeAction.readNextChapter);
    expect(next.chapterId, chapters.last.chapter.id);

    final completed = await SmartResumePolicy.manga(
      chapters: chapters,
      completed: chapters.map((item) => item.chapter.id).toSet(),
      progress: null,
      preferredProvider: null,
      resumeFor: (_) async => null,
    );
    expect(completed.action, SmartResumeAction.completed);
    expect(completed.hasAction, isFalse);
  });

  test('anime Start, Resume, Next and Completed', () async {
    final episodes = [episode(1), episode(2)];
    final start = await SmartResumePolicy.anime(
      episodes: episodes,
      completed: {},
      progress: null,
      preferredProvider: providerA,
      resumeFor: (_) async => null,
    );
    expect(start.action, SmartResumeAction.startWatching);

    final exact = AnimeSourcePlaybackResume(
      mediaId: mediaId,
      episodeId: episodes.first.episode.id,
      providerId: providerA,
      episodeExternalId: 'a-1',
      position: const Duration(minutes: 12, seconds: 34),
      updatedAt: now,
    );
    final resume = await SmartResumePolicy.anime(
      episodes: episodes,
      completed: {},
      progress: CanonicalAnimeProgress(
        mediaId: mediaId,
        episodeId: episodes.first.episode.id,
        position: exact.position,
        updatedAt: now,
      ),
      preferredProvider: providerB,
      resumeFor: (_) async => exact,
    );
    expect(resume.action, SmartResumeAction.resumeEpisode);
    expect(resume.playbackResume, same(exact));

    final next = await SmartResumePolicy.anime(
      episodes: episodes,
      completed: {episodes.first.episode.id},
      progress: CanonicalAnimeProgress(
        mediaId: mediaId,
        episodeId: episodes.first.episode.id,
        position: const Duration(minutes: 24),
        updatedAt: now,
      ),
      preferredProvider: providerA,
      resumeFor: (_) async => null,
    );
    expect(next.action, SmartResumeAction.watchNextEpisode);
    expect(next.episodeId, episodes.last.episode.id);

    final completed = await SmartResumePolicy.anime(
      episodes: episodes,
      completed: episodes.map((item) => item.episode.id).toSet(),
      progress: null,
      preferredProvider: null,
      resumeFor: (_) async => null,
    );
    expect(completed.action, SmartResumeAction.completed);
  });

  test('exact resume is never copied to another source binding', () async {
    final value = chapter(1);
    final other = ChapterSourceBinding(
      canonicalId: value.chapter.id,
      providerId: providerB,
      externalId: 'b-1',
    );
    final availability = ReaderChapterAvailability(
      chapter: value.chapter,
      bindings: [other],
      capabilities: {providerB: ReaderSourceCapability.readerCapable},
    );
    final result = await SmartResumePolicy.manga(
      chapters: [availability],
      completed: {},
      progress: CanonicalMangaProgress(
        mediaId: mediaId,
        chapterId: value.chapter.id,
        pageIndex: 8,
        updatedAt: now,
      ),
      preferredProvider: providerB,
      resumeFor: (_) async => null,
    );
    expect(result.chapterBinding, other);
    expect(result.pageResume, isNull);
  });
}
