import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/user_state.dart';
import '../player/playback_repository.dart';
import '../reader/reader_repository.dart';

enum SmartResumeAction {
  startReading,
  resumeReading,
  readNextChapter,
  startWatching,
  resumeEpisode,
  watchNextEpisode,
  completed,
  unavailable,
}

class SmartResumeTarget {
  const SmartResumeTarget({
    required this.action,
    this.chapterId,
    this.episodeId,
    this.chapterBinding,
    this.episodeBinding,
    this.pageResume,
    this.playbackResume,
    this.reason,
  });

  final SmartResumeAction action;
  final CanonicalChapterId? chapterId;
  final CanonicalEpisodeId? episodeId;
  final ChapterSourceBinding? chapterBinding;
  final EpisodeSourceBinding? episodeBinding;
  final MangaSourcePageResume? pageResume;
  final AnimeSourcePlaybackResume? playbackResume;
  final String? reason;

  bool get hasAction => !{
    SmartResumeAction.completed,
    SmartResumeAction.unavailable,
  }.contains(action);

  String get label => switch (action) {
    SmartResumeAction.startReading => 'Start reading',
    SmartResumeAction.resumeReading => 'Resume reading',
    SmartResumeAction.readNextChapter => 'Read next chapter',
    SmartResumeAction.startWatching => 'Start watching',
    SmartResumeAction.resumeEpisode => 'Resume episode',
    SmartResumeAction.watchNextEpisode => 'Watch next episode',
    SmartResumeAction.completed => 'Completed',
    SmartResumeAction.unavailable => 'Currently unavailable',
  };
}

typedef MangaResumeLookup =
    Future<MangaSourcePageResume?> Function(ChapterSourceBinding binding);
typedef AnimeResumeLookup =
    Future<AnimeSourcePlaybackResume?> Function(EpisodeSourceBinding binding);

/// The single continuation policy used by every product surface.
///
/// Canonical completion selects the installment. Exact offsets only influence
/// source selection inside that installment and are never copied across
/// bindings.
abstract final class SmartResumePolicy {
  static Future<SmartResumeTarget> manga({
    required List<ReaderChapterAvailability> chapters,
    required Set<CanonicalChapterId> completed,
    required CanonicalMangaProgress? progress,
    required ProviderId? preferredProvider,
    required MangaResumeLookup resumeFor,
  }) async {
    if (chapters.isEmpty) {
      return const SmartResumeTarget(
        action: SmartResumeAction.unavailable,
        reason: 'No chapters are available yet.',
      );
    }
    if (completed.length >= chapters.length &&
        chapters.every((item) => completed.contains(item.chapter.id))) {
      return const SmartResumeTarget(action: SmartResumeAction.completed);
    }

    final currentIndex = progress == null
        ? -1
        : chapters.indexWhere((item) => item.chapter.id == progress.chapterId);
    if (currentIndex >= 0 &&
        !completed.contains(chapters[currentIndex].chapter.id)) {
      final current = chapters[currentIndex];
      final choice = await _mangaBinding(current, preferredProvider, resumeFor);
      if (choice != null) {
        return SmartResumeTarget(
          action: SmartResumeAction.resumeReading,
          chapterId: current.chapter.id,
          chapterBinding: choice.$1,
          pageResume: choice.$2,
        );
      }
    }

    final start = currentIndex < 0 ? 0 : currentIndex + 1;
    for (var index = start; index < chapters.length; index++) {
      final item = chapters[index];
      if (completed.contains(item.chapter.id)) continue;
      final choice = await _mangaBinding(item, preferredProvider, resumeFor);
      if (choice == null) continue;
      return SmartResumeTarget(
        action: currentIndex < 0
            ? SmartResumeAction.startReading
            : SmartResumeAction.readNextChapter,
        chapterId: item.chapter.id,
        chapterBinding: choice.$1,
        pageResume: currentIndex < 0 ? choice.$2 : null,
      );
    }
    return const SmartResumeTarget(
      action: SmartResumeAction.unavailable,
      reason: 'Unread chapters have no readable source right now.',
    );
  }

  static Future<SmartResumeTarget> anime({
    required List<PlaybackEpisodeAvailability> episodes,
    required Set<CanonicalEpisodeId> completed,
    required CanonicalAnimeProgress? progress,
    required ProviderId? preferredProvider,
    required AnimeResumeLookup resumeFor,
  }) async {
    if (episodes.isEmpty) {
      return const SmartResumeTarget(
        action: SmartResumeAction.unavailable,
        reason: 'No episodes are available yet.',
      );
    }
    if (completed.length >= episodes.length &&
        episodes.every((item) => completed.contains(item.episode.id))) {
      return const SmartResumeTarget(action: SmartResumeAction.completed);
    }
    final currentIndex = progress == null
        ? -1
        : episodes.indexWhere((item) => item.episode.id == progress.episodeId);
    if (currentIndex >= 0 &&
        !completed.contains(episodes[currentIndex].episode.id)) {
      final current = episodes[currentIndex];
      final choice = await _animeBinding(current, preferredProvider, resumeFor);
      if (choice != null) {
        return SmartResumeTarget(
          action: SmartResumeAction.resumeEpisode,
          episodeId: current.episode.id,
          episodeBinding: choice.$1,
          playbackResume: choice.$2,
        );
      }
    }
    final start = currentIndex < 0 ? 0 : currentIndex + 1;
    for (var index = start; index < episodes.length; index++) {
      final item = episodes[index];
      if (completed.contains(item.episode.id)) continue;
      final choice = await _animeBinding(item, preferredProvider, resumeFor);
      if (choice == null) continue;
      return SmartResumeTarget(
        action: currentIndex < 0
            ? SmartResumeAction.startWatching
            : SmartResumeAction.watchNextEpisode,
        episodeId: item.episode.id,
        episodeBinding: choice.$1,
        playbackResume: currentIndex < 0 ? choice.$2 : null,
      );
    }
    return const SmartResumeTarget(
      action: SmartResumeAction.unavailable,
      reason: 'Unwatched episodes have no playable source right now.',
    );
  }

  static Future<(ChapterSourceBinding, MangaSourcePageResume?)?> _mangaBinding(
    ReaderChapterAvailability chapter,
    ProviderId? preferred,
    MangaResumeLookup resumeFor,
  ) async {
    final bindings = chapter.openableBindings;
    if (bindings.isEmpty) return null;
    final resumes = <(ChapterSourceBinding, MangaSourcePageResume)>[];
    for (final binding in bindings) {
      final resume = await resumeFor(binding);
      if (resume != null && resume.chapterId == chapter.chapter.id) {
        resumes.add((binding, resume));
      }
    }
    resumes.sort((a, b) => b.$2.updatedAt.compareTo(a.$2.updatedAt));
    if (resumes.isNotEmpty) return resumes.first;
    return (
      bindings.where((item) => item.providerId == preferred).firstOrNull ??
          bindings.first,
      null,
    );
  }

  static Future<(EpisodeSourceBinding, AnimeSourcePlaybackResume?)?>
  _animeBinding(
    PlaybackEpisodeAvailability episode,
    ProviderId? preferred,
    AnimeResumeLookup resumeFor,
  ) async {
    final bindings = episode.openableBindings;
    if (bindings.isEmpty) return null;
    final resumes = <(EpisodeSourceBinding, AnimeSourcePlaybackResume)>[];
    for (final binding in bindings) {
      final resume = await resumeFor(binding);
      if (resume != null && resume.episodeId == episode.episode.id) {
        resumes.add((binding, resume));
      }
    }
    resumes.sort((a, b) => b.$2.updatedAt.compareTo(a.$2.updatedAt));
    if (resumes.isNotEmpty) return resumes.first;
    return (
      bindings.where((item) => item.providerId == preferred).firstOrNull ??
          bindings.first,
      null,
    );
  }
}
