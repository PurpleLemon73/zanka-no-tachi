import 'package:flutter/material.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../player/playback_domain.dart';
import '../player/playback_repository.dart';
import '../player/ui/anime_player_screen.dart';
import '../product/product_controller.dart';
import '../product/product_models.dart';
import '../product/smart_resume.dart';
import '../product/ui/design_system.dart';
import '../reader/reader_domain.dart';
import '../reader/reader_repository.dart';
import '../reader/ui/manga_reader_screen.dart';
import 'tv_design_system.dart';

class TvMediaDetailsScreen extends StatefulWidget {
  const TvMediaDetailsScreen({
    super.key,
    required this.controller,
    required this.mediaId,
    this.initialDetails,
    this.autofocusResume = true,
  });

  final ProductController controller;
  final CanonicalMediaId mediaId;
  final ProductMediaDetails? initialDetails;
  final bool autofocusResume;

  @override
  State<TvMediaDetailsScreen> createState() => _TvMediaDetailsScreenState();
}

class _TvMediaDetailsScreenState extends State<TvMediaDetailsScreen> {
  ProductMediaDetails? details;
  Object? error;

  @override
  void initState() {
    super.initState();
    details = widget.initialDetails;
    if (details == null) _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.controller.details(widget.mediaId);
      if (mounted) setState(() => details = value);
    } on Object catch (value) {
      if (mounted) setState(() => error = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = details;
    return Scaffold(
      key: const Key('tv-media-details'),
      body: SafeArea(
        child: error != null
            ? ProductEmptyState(
                icon: Icons.error_outline,
                title: 'Details unavailable',
                message: 'Your saved state is unchanged.',
                action: FilledButton(
                  onPressed: _load,
                  child: const Text('Retry'),
                ),
              )
            : value == null
            ? const Center(child: CircularProgressIndicator())
            : FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      title: Text(value.summary.media.title.value),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        TvTokens.safeHorizontal,
                        24,
                        TvTokens.safeHorizontal,
                        TvTokens.safeVertical,
                      ),
                      sliver: SliverList.list(
                        children: [
                          _TvDetailsHero(
                            details: value,
                            autofocusResume: widget.autofocusResume,
                            onResume: () => _openSmart(value),
                            onLibrary: () => _toggleLibrary(value),
                          ),
                          const SizedBox(height: 30),
                          if (value.summary.media is CanonicalAnime)
                            _TvEpisodes(details: value, onOpen: _openEpisode)
                          else
                            _TvChapters(details: value, onOpen: _openChapter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _toggleLibrary(ProductMediaDetails value) async {
    final updated = await widget.controller.updateLibrary(
      value,
      saved: !value.summary.isSaved,
    );
    if (mounted) setState(() => details = updated);
  }

  Future<void> _openSmart(ProductMediaDetails value) async {
    final target = value.smartResume;
    if (target == null || !target.hasAction) return;
    if (target.episodeId case final episodeId?) {
      final playback = widget.controller.repository.playback;
      if (playback == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnimePlayerScreen(
            repository: playback,
            request: PlaybackSessionRequest(
              mediaId: value.summary.media.id,
              episodeId: episodeId,
              binding: target.episodeBinding,
            ),
            isTv: true,
          ),
        ),
      );
    } else if (target.chapterId case final chapterId?) {
      final reader = widget.controller.repository.reader;
      if (reader == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MangaReaderScreen(
            repository: reader,
            request: ReaderSessionRequest(
              mediaId: value.summary.media.id,
              chapterId: chapterId,
              binding: target.chapterBinding,
            ),
          ),
        ),
      );
    }
    await _load();
    await widget.controller.refreshLocal();
  }

  Future<void> _openEpisode(
    ProductMediaDetails value,
    PlaybackEpisodeAvailability episode,
  ) async {
    final playback = widget.controller.repository.playback;
    if (playback == null || episode.openableBindings.isEmpty) return;
    EpisodeSourceBinding? binding;
    if (episode.openableBindings.length == 1) {
      binding = episode.openableBindings.single;
    } else {
      binding = await showDialog<EpisodeSourceBinding>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Choose source'),
          content: SizedBox(
            width: 520,
            child: ListView(
              shrinkWrap: true,
              children: episode.openableBindings
                  .map(
                    (item) => ListTile(
                      autofocus: item.providerId == value.preferredProvider,
                      title: Text(item.providerId.value),
                      subtitle: const Text(
                        'Exact timestamps remain separate for each encode.',
                      ),
                      onTap: () => Navigator.pop(dialogContext, item),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
    if (binding == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimePlayerScreen(
          repository: playback,
          request: PlaybackSessionRequest(
            mediaId: value.summary.media.id,
            episodeId: episode.episode.id,
            binding: binding,
          ),
          isTv: true,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openChapter(
    ProductMediaDetails value,
    ReaderChapterAvailability chapter,
  ) async {
    final reader = widget.controller.repository.reader;
    final binding = chapter.openableBindings.firstOrNull;
    if (reader == null || binding == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MangaReaderScreen(
          repository: reader,
          request: ReaderSessionRequest(
            mediaId: value.summary.media.id,
            chapterId: chapter.chapter.id,
            binding: binding,
          ),
        ),
      ),
    );
    await _load();
  }
}

class _TvDetailsHero extends StatelessWidget {
  const _TvDetailsHero({
    required this.details,
    required this.autofocusResume,
    required this.onResume,
    required this.onLibrary,
  });
  final ProductMediaDetails details;
  final bool autofocusResume;
  final VoidCallback onResume;
  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    final media = details.summary.media;
    final target = details.smartResume;
    return SizedBox(
      height: 330,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(locator: media.coverLocator, width: 210, height: 310),
          const SizedBox(width: 34),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.title.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  media is CanonicalAnime
                      ? '${media.format.name.toUpperCase()} · ${details.playbackEpisodes.length} episode(s) · ${media.status.name}'
                      : '${details.readerChapters.length} chapter(s) · ${media.status.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  media.description?.value ?? 'No description available.',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: 330,
                      child: TvFocusable(
                        key: const Key('tv-smart-resume'),
                        autofocus: autofocusResume,
                        onPressed: target?.hasAction == true ? onResume : null,
                        semanticLabel: target?.label ?? 'Currently unavailable',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                target?.action == SmartResumeAction.completed
                                    ? Icons.check_circle
                                    : Icons.play_arrow,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  target?.label ?? 'Currently unavailable',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 240,
                      child: TvFocusable(
                        onPressed: onLibrary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                          child: Text(
                            details.summary.isSaved
                                ? 'Remove from Library'
                                : 'Add to Library',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${details.summary.bindings.length} media source(s) · source choice remains available per episode',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TvEpisodes extends StatelessWidget {
  const _TvEpisodes({required this.details, required this.onOpen});
  final ProductMediaDetails details;
  final void Function(ProductMediaDetails, PlaybackEpisodeAvailability) onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TvSectionTitle('Episodes'),
      SizedBox(
        height: 126,
        child: ListView.separated(
          key: const Key('tv-episode-rail'),
          scrollDirection: Axis.horizontal,
          itemCount: details.playbackEpisodes.length,
          itemBuilder: (context, index) {
            final item = details.playbackEpisodes[index];
            final watched = details.episodeCompletions.any(
              (value) => value.episodeId == item.episode.id,
            );
            final highlighted =
                details.smartResume?.episodeId == item.episode.id;
            return SizedBox(
              width: 180,
              child: TvFocusable(
                onPressed: item.openableBindings.isEmpty
                    ? null
                    : () => onOpen(details, item),
                semanticLabel:
                    '${item.episode.label.rawLabel}, ${watched
                        ? 'watched'
                        : highlighted
                        ? 'up next'
                        : 'unwatched'}, ${item.openableBindings.isEmpty ? 'unavailable' : '${item.openableBindings.length} playable source(s)'}',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.episode.label.rawLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        watched
                            ? 'Watched'
                            : highlighted
                            ? 'Resume / next'
                            : item.openableBindings.isEmpty
                            ? 'Unavailable'
                            : '${item.openableBindings.length} source(s)',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 18),
        ),
      ),
    ],
  );
}

class _TvChapters extends StatelessWidget {
  const _TvChapters({required this.details, required this.onOpen});
  final ProductMediaDetails details;
  final void Function(ProductMediaDetails, ReaderChapterAvailability) onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TvSectionTitle('Chapters'),
      SizedBox(
        height: 126,
        child: ListView.separated(
          key: const Key('tv-chapter-rail'),
          scrollDirection: Axis.horizontal,
          itemCount: details.readerChapters.length,
          itemBuilder: (context, index) {
            final item = details.readerChapters[index];
            return SizedBox(
              width: 200,
              child: TvFocusable(
                onPressed: item.openableBindings.isEmpty
                    ? null
                    : () => onOpen(details, item),
                semanticLabel: item.chapter.number.rawLabel,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.chapter.number.rawLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.openableBindings.isEmpty
                            ? 'Unavailable'
                            : '${item.openableBindings.length} readable source(s)',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 18),
        ),
      ),
    ],
  );
}
