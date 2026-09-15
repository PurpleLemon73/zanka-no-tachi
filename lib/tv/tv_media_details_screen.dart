import 'package:flutter/material.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../player/playback_domain.dart';
import '../player/playback_repository.dart';
import '../player/ui/anime_player_screen.dart';
import '../product/product_controller.dart';
import '../product/product_models.dart';
import '../product/product_repository.dart';
import '../product/smart_resume.dart';
import '../product/ui/design_system.dart';
import '../product/ui/details_actions.dart';
import '../product/ui/details_dialogs.dart';
import '../product/ui/episode_watch_actions.dart';
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
    this.searchResult,
    this.autofocusResume = true,
  }) : assert(mediaId != null || searchResult != null);

  final ProductController controller;
  final CanonicalMediaId? mediaId;
  final ProductMediaDetails? initialDetails;
  final ProductSearchResult? searchResult;
  final bool autofocusResume;

  @override
  State<TvMediaDetailsScreen> createState() => _TvMediaDetailsScreenState();
}

class _TvMediaDetailsScreenState extends State<TvMediaDetailsScreen> {
  ProductMediaDetails? details;
  Object? error;
  bool loading = false;
  int _loadGeneration = 0;
  Future<void>? _pendingLoad;

  @override
  void initState() {
    super.initState();
    details = widget.initialDetails;
    if (details == null) _load();
  }

  @override
  void didUpdateWidget(covariant TvMediaDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId ||
        oldWidget.searchResult != widget.searchResult ||
        oldWidget.controller != widget.controller) {
      _loadGeneration++;
      _pendingLoad = null;
      details = widget.initialDetails;
      error = null;
      loading = false;
      if (details == null) _load();
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    super.dispose();
  }

  Future<void> _load() {
    if (_pendingLoad case final pending?) return pending;
    final ticket = ++_loadGeneration;
    setState(() {
      loading = true;
      error = null;
    });
    return _pendingLoad = _performLoad(ticket);
  }

  Future<void> _performLoad(int ticket) async {
    try {
      final id = details?.summary.media.id ?? widget.mediaId;
      final value = id != null
          ? await widget.controller.details(id)
          : await widget.controller.openResult(widget.searchResult!);
      if (mounted && ticket == _loadGeneration) setState(() => details = value);
    } on Object catch (value) {
      if (mounted && ticket == _loadGeneration) setState(() => error = value);
    } finally {
      if (mounted && ticket == _loadGeneration) {
        _pendingLoad = null;
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = details;
    return Scaffold(
      key: const Key('tv-media-details'),
      body: SafeArea(
        child: error != null || (!loading && value == null)
            ? ProductEmptyState(
                icon: Icons.error_outline,
                title: 'Details unavailable',
                message: error == null
                    ? 'This item is no longer available on this device.'
                    : ProductRepository.describeFailure(error!),
                action: FilledButton(
                  autofocus: true,
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
                      title: const Text('Details'),
                      surfaceTintColor: Colors.transparent,
                      actions: [
                        DetailsActions(
                          key: ValueKey(value.summary.media.id),
                          controller: widget.controller,
                          details: value,
                          tv: true,
                          enabled: !loading,
                          onChanged: (updated) {
                            if (mounted) setState(() => details = updated);
                          },
                        ),
                      ],
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
                            _TvEpisodes(
                              details: value,
                              onOpen: _openEpisode,
                              episodeActions: (id) => EpisodeWatchActions(
                                key: ValueKey(id),
                                controller: widget.controller,
                                details: value,
                                episodeId: id,
                                tv: true,
                                onChanged: (updated) {
                                  if (mounted) {
                                    setState(() => details = updated);
                                  }
                                },
                              ),
                            )
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
      final firstChoice = episode.openableBindings.firstWhere(
        (item) => item.providerId == value.preferredProvider,
        orElse: () => episode.openableBindings.first,
      );
      binding = await showDialog<EpisodeSourceBinding>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => DetailsDialog(
          tv: true,
          title: 'Choose source',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
          children: [
            const Text(
              'Your saved playback position stays separate for each source.',
            ),
            for (final item in episode.openableBindings)
              OutlinedButton(
                autofocus: item == firstChoice,
                onPressed: () => Navigator.pop(dialogContext, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(item.providerId.value),
                ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ClipRRect(
      key: const Key('tv-details-artwork-hero'),
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CoverArt(
                locator: media.coverLocator,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0, .55, 1],
                  colors: [
                    scheme.surfaceContainerLow,
                    scheme.surfaceContainerLow.withValues(alpha: .94),
                    scheme.surfaceContainerLow.withValues(alpha: .6),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media is CanonicalAnime
                      ? 'ANIME / IN FOCUS'
                      : 'MANGA / IN FOCUS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 2,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  media.title.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  media is CanonicalAnime
                      ? '${media.format.name.toUpperCase()} · ${details.playbackEpisodes.length} episode(s) · ${media.status.name}'
                      : '${details.readerChapters.length} chapter(s) · ${media.status.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Text(
                    media.description?.value ?? 'No description available.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 18,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 330,
                      child: TvFocusable(
                        key: const Key('tv-smart-resume'),
                        autofocus: autofocusResume,
                        onPressed: target?.hasAction == true ? onResume : null,
                        semanticLabel: target?.label ?? 'Currently unavailable',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                  color: scheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    target?.label ?? 'Currently unavailable',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                const SizedBox(height: 16),
                Text(
                  '${details.summary.bindings.length} source(s) · Choose a source when opening ${media is CanonicalAnime ? 'an episode' : 'a chapter'}',
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

// Horizontal rails need a cross-axis extent. Derive it from scaled text
// metrics rather than clipping accessible labels to a fixed 126-pixel card.
double _installmentRailHeight(BuildContext context, {required bool chapter}) {
  final theme = Theme.of(context).textTheme;
  double height(TextStyle? style, int lines) {
    final painter = TextPainter(
      text: TextSpan(text: List.filled(lines, 'Ag').join('\n'), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final result = painter.height;
    painter.dispose();
    return result;
  }

  // Card padding, focus border, title/status gap, and bounded secondary text.
  return 32 +
      2 * TvTokens.focusBorder +
      8 +
      height(chapter ? theme.bodyMedium : theme.titleMedium, chapter ? 2 : 1) +
      height(theme.bodyMedium, 3);
}

class _TvEpisodes extends StatelessWidget {
  const _TvEpisodes({
    required this.details,
    required this.onOpen,
    required this.episodeActions,
  });
  final ProductMediaDetails details;
  final Widget Function(CanonicalEpisodeId) episodeActions;
  final void Function(ProductMediaDetails, PlaybackEpisodeAvailability) onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TvSectionTitle('Episodes'),
      SizedBox(
        height:
            _installmentRailHeight(context, chapter: false) +
            kMinInteractiveDimension,
        child: ListView.separated(
          key: const Key('tv-episode-rail'),
          scrollDirection: Axis.horizontal,
          itemCount: details.episodes.length,
          itemBuilder: (context, index) {
            final episode = details.episodes[index].episode;
            final item = details.playbackEpisodes
                .where((value) => value.episode.id == episode.id)
                .firstOrNull;
            final openable = item?.openableBindings ?? const [];
            final watched = details.episodeCompletions.any(
              (value) => value.episodeId == episode.id,
            );
            final highlighted = details.smartResume?.episodeId == episode.id;
            return SizedBox(
              width: 180,
              child: Column(
                children: [
                  Expanded(
                    child: TvFocusable(
                      onPressed: openable.isEmpty
                          ? null
                          : () => onOpen(details, item!),
                      semanticLabel:
                          '${episode.label.rawLabel}, ${watched
                              ? 'watched'
                              : highlighted
                              ? 'up next'
                              : 'unwatched'}, ${openable.isEmpty ? 'unavailable' : '${openable.length} playable source(s)'}',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              episode.label.rawLabel,
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
                                  : openable.isEmpty
                                  ? 'Unavailable'
                                  : '${openable.length} source(s)',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kMinInteractiveDimension,
                    child: episodeActions(episode.id),
                  ),
                ],
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
        height: _installmentRailHeight(context, chapter: true),
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
                semanticLabel:
                    '${item.chapter.number.rawLabel}, ${item.openableBindings.isEmpty ? 'unavailable' : '${item.openableBindings.length} readable source(s)'}',
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
