import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/media.dart';
import '../../canonical/domain/user_state.dart';
import '../../canonical/reconciliation/source_availability.dart';
import '../product_controller.dart';
import '../product_models.dart';
import '../product_repository.dart';
import 'design_system.dart';
import '../../reader/reader_domain.dart';
import '../../reader/reader_repository.dart';
import '../../reader/ui/manga_reader_screen.dart';
import '../../player/playback_domain.dart';
import '../../player/playback_repository.dart';
import '../../player/ui/anime_player_screen.dart';
import '../../product_maturity/maturity_domain.dart';
import '../../local_library/local_asset.dart';
import 'details_actions.dart';
import 'details_dialogs.dart';
import '../smart_resume.dart';

class MediaDetailsScreen extends StatefulWidget {
  const MediaDetailsScreen({
    super.key,
    required this.controller,
    required this.mediaId,
    this.initialDetails,
    this.searchResult,
  }) : assert(mediaId != null || searchResult != null);
  final ProductController controller;
  final CanonicalMediaId? mediaId;
  final ProductMediaDetails? initialDetails;
  final ProductSearchResult? searchResult;

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  ProductMediaDetails? details;
  Object? error;
  bool refreshing = false;
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
  void didUpdateWidget(covariant MediaDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId ||
        oldWidget.searchResult != widget.searchResult ||
        oldWidget.controller != widget.controller) {
      _loadGeneration++;
      _pendingLoad = null;
      details = widget.initialDetails;
      error = null;
      loading = false;
      refreshing = false;
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
      refreshing = false;
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

  Future<void> _refreshSources() async {
    final id = details?.summary.media.id;
    if (refreshing || loading || id == null) return;
    final ticket = ++_loadGeneration;
    setState(() => refreshing = true);
    try {
      final value = await widget.controller.refreshDetails(id);
      if (!mounted || ticket != _loadGeneration) return;
      setState(() => details = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source details refreshed.')),
      );
    } on Object {
      if (!mounted || ticket != _loadGeneration) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Source details could not be refreshed. Your saved state is unchanged.',
          ),
        ),
      );
    } finally {
      if (mounted && ticket == _loadGeneration) {
        setState(() => refreshing = false);
      }
    }
  }

  Future<void> _library({
    bool? saved,
    bool? favorite,
    CanonicalLibraryStatus? status,
  }) async {
    final current = details;
    if (current == null) return;
    final updated = await widget.controller.updateLibrary(
      current,
      saved: saved,
      favorite: favorite,
      status: status,
    );
    if (mounted) setState(() => details = updated);
  }

  Future<void> _preference(ProviderId? provider) async {
    final current = details;
    if (current == null) return;
    final updated = await widget.controller.setPreferredProvider(
      current,
      provider,
    );
    if (mounted) setState(() => details = updated);
  }

  Future<void> _repairAsset(LocalAsset asset) async {
    final local = widget.controller.localLibrary;
    if (local == null) return;
    final extensions = asset.kind == LocalAssetKind.video
        ? const ['mp4', 'webm', 'mkv', 'mov']
        : const ['cbz'];
    final path = (await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: 'Choose replacement file',
    ))?.path;
    if (path == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DetailsDialog(
        title: 'Repair local source?',
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Repair'),
          ),
        ],
        children: const [
          Text(
            'The same media, installment, progress, and resume are retained. Only the missing file is replaced.',
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await local.repair(asset, path);
      await widget.controller.refreshLocal();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = details;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: .9),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (value != null)
            DetailsActions(
              key: ValueKey(value.summary.media.id),
              controller: widget.controller,
              details: value,
              enabled: !loading && !refreshing,
              refreshing: refreshing,
              onRefresh: _refreshSources,
              onChanged: (updated) {
                if (mounted) setState(() => details = updated);
              },
            ),
        ],
      ),
      body: error != null || (!loading && value == null)
          ? ProductEmptyState(
              icon: Icons.error_outline,
              title: 'Details unavailable',
              message: error == null
                  ? 'This item is no longer available on this device.'
                  : ProductRepository.describeFailure(error!),
              action: FilledButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            )
          : value == null
          ? const Center(child: CircularProgressIndicator())
          : _DetailsBody(
              details: value,
              onLibrary: _library,
              onPreference: _preference,
              readerRepository: widget.controller.repository.reader,
              playbackRepository: widget.controller.repository.playback,
              onReaderClosed: _load,
              onRefresh: _load,
              onEditChapter: (edit) async {
                await widget.controller.editChapter(edit);
                await _load();
              },
              onEditEpisode: (edit) async {
                await widget.controller.editEpisode(edit);
                await _load();
              },
              onRepair: _repairAsset,
            ),
    );
  }
}

class _DetailsBody extends StatefulWidget {
  const _DetailsBody({
    required this.details,
    required this.onLibrary,
    required this.onPreference,
    required this.readerRepository,
    required this.onReaderClosed,
    required this.playbackRepository,
    required this.onRefresh,
    required this.onEditChapter,
    required this.onEditEpisode,
    required this.onRepair,
  });
  final ProductMediaDetails details;
  final Future<void> Function({
    bool? saved,
    bool? favorite,
    CanonicalLibraryStatus? status,
  })
  onLibrary;
  final Future<void> Function(ProviderId? provider) onPreference;
  final ReaderRepository? readerRepository;
  final Future<void> Function() onReaderClosed;
  final PlaybackRepository? playbackRepository;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ChapterUserEdit) onEditChapter;
  final Future<void> Function(EpisodeUserEdit) onEditEpisode;
  final Future<void> Function(LocalAsset) onRepair;

  @override
  State<_DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<_DetailsBody> {
  String? expandedChapterGroup;
  bool descriptionExpanded = false;
  bool metadataExpanded = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final onLibrary = widget.onLibrary;
    final onPreference = widget.onPreference;
    final readerRepository = widget.readerRepository;
    final onReaderClosed = widget.onReaderClosed;
    final playbackRepository = widget.playbackRepository;
    final onRefresh = widget.onRefresh;
    final onEditChapter = widget.onEditChapter;
    final onEditEpisode = widget.onEditEpisode;
    final onRepair = widget.onRepair;
    final summary = details.summary;
    final media = summary.media;
    final installments = media is CanonicalManga
        ? details.chapters.length
        : details.episodes.length;
    final chapterGroups = _chapterGroups(details);
    expandedChapterGroup ??= _smartChapterGroup(
      chapterGroups,
      details.smartResume?.chapterId,
    );
    final chapterRows = <Object>[];
    for (final group in chapterGroups) {
      chapterRows.add(group);
      if (group.key == expandedChapterGroup) chapterRows.addAll(group.items);
    }
    return CustomScrollView(
      key: const Key('media-details'),
      slivers: [
        SliverToBoxAdapter(
          child: _DetailsHero(
            details: details,
            action: _SmartResumeCard(
              details: details,
              readerRepository: readerRepository,
              playbackRepository: playbackRepository,
              onClosed: onReaderClosed,
            ),
            onLibrary: () => onLibrary(saved: !summary.isSaved),
            onFavorite: () => onLibrary(favorite: !summary.isFavorite),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ZankaSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (media.description case final description?) ...[
                  const ZankaPageHeading(
                    eyebrow: 'THE STORY',
                    title: 'Overview',
                  ),
                  const SizedBox(height: ZankaSpace.md),
                  Semantics(
                    expanded: descriptionExpanded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description.value,
                          maxLines: descriptionExpanded ? null : 3,
                          overflow: descriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        TextButton.icon(
                          key: const Key('description-toggle'),
                          onPressed: () => setState(
                            () => descriptionExpanded = !descriptionExpanded,
                          ),
                          icon: Icon(
                            descriptionExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          label: Text(
                            descriptionExpanded ? 'Show less' : 'Show more',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ExpansionTile(
                  key: const Key('optional-metadata'),
                  initiallyExpanded: metadataExpanded,
                  onExpansionChanged: (value) =>
                      setState(() => metadataExpanded = value),
                  tilePadding: EdgeInsets.zero,
                  title: const Text('More information'),
                  children: [
                    ListTile(
                      title: const Text('Title source'),
                      subtitle: Text(
                        _origin(media.title.provenance.providerId),
                      ),
                    ),
                    if (details.metadataOverride?.creatorOrStudio
                        case final creator?)
                      ListTile(
                        title: Text(
                          media is CanonicalAnime ? 'Studio' : 'Creator',
                        ),
                        subtitle: Text(creator),
                      ),
                    if (media.alternateTitles.isNotEmpty)
                      ListTile(
                        title: const Text('Also known as'),
                        subtitle: Text(
                          media.alternateTitles
                              .map((item) => item.value)
                              .join(', '),
                        ),
                      ),
                    if (media.genres.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ZankaSpace.sm),
                        child: Wrap(
                          spacing: ZankaSpace.sm,
                          children: media.genres
                              .map((genre) => Chip(label: Text(genre.value)))
                              .toList(),
                        ),
                      ),
                  ],
                ),
                if (summary.hasProgress) ...[
                  const ZankaSectionTitle('Current progress'),
                  Text(_progressText(summary)),
                ],
                if (details.localAssets.any(
                  (asset) => asset.state != LocalAssetState.available,
                )) ...[
                  const ZankaSectionTitle('Local file needs attention'),
                  for (final asset in details.localAssets.where(
                    (asset) => asset.state != LocalAssetState.available,
                  ))
                    ListTile(
                      leading: const Icon(Icons.link_off),
                      title: Text(asset.originalName),
                      subtitle: const Text(
                        'The saved item and progress are safe.',
                      ),
                      trailing: FilledButton(
                        onPressed: () => onRepair(asset),
                        child: const Text('Repair'),
                      ),
                    ),
                ],
                if (media is CanonicalManga && details.chapters.isNotEmpty)
                  Text(
                    '${details.chapterCompletions.length} of ${details.chapters.length} read',
                  ),
                if (media is CanonicalAnime && details.episodes.isNotEmpty)
                  Text(
                    '${details.episodeCompletions.length} of ${details.episodes.length} watched',
                  ),
                const ZankaSectionTitle('Available from'),
                if (summary.bindings.isEmpty)
                  const Text(
                    'No source is currently attached. Local library data remains available.',
                  )
                else
                  Wrap(
                    spacing: ZankaSpace.sm,
                    children: summary.bindings
                        .map(
                          (binding) => ChoiceChip(
                            key: ValueKey('source-${binding.providerId.value}'),
                            label: Text(_providerName(binding.providerId)),
                            selected:
                                details.preferredProvider == binding.providerId,
                            onSelected: (_) => onPreference(binding.providerId),
                          ),
                        )
                        .toList(),
                  ),
                if (summary.bindings.length > 1 &&
                    details.preferredProvider == null)
                  const Padding(
                    padding: EdgeInsets.only(top: ZankaSpace.sm),
                    child: Text(
                      'Choose a preferred source, or select one when opening an installment.',
                    ),
                  ),
                if (details.preferredProvider case final preferred?
                    when !summary.bindings.any(
                      (binding) => binding.providerId == preferred,
                    ))
                  Padding(
                    padding: const EdgeInsets.only(top: ZankaSpace.sm),
                    child: Text(
                      'Preferred source ${_providerName(preferred)} is currently unavailable. '
                      'Choose another available source.',
                    ),
                  ),
                if (summary.library case final library?) ...[
                  const ZankaSectionTitle('Library status'),
                  DropdownButton<CanonicalLibraryStatus>(
                    key: const Key('library-status'),
                    value: library.status,
                    items: CanonicalLibraryStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(_statusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (status) {
                      if (status != null) {
                        onLibrary(status: status, saved: true);
                      }
                    },
                  ),
                ],
                const SizedBox(height: ZankaSpace.xl),
                ZankaPageHeading(
                  eyebrow: 'CONTENTS',
                  title: media is CanonicalManga ? 'Chapters' : 'Episodes',
                  description:
                      '$installments ${media is CanonicalManga ? 'chapters' : 'episodes'}',
                ),
                const SizedBox(height: ZankaSpace.md),
                if (installments == 0)
                  const Text(
                    'No public installment metadata is available yet.',
                  ),
              ],
            ),
          ),
        ),
        if (media is CanonicalManga)
          SliverList.builder(
            itemCount: chapterRows.length,
            itemBuilder: (context, index) {
              final row = chapterRows[index];
              if (row is _ChapterGroup) {
                final read = row.items
                    .where(
                      (item) => details.chapterCompletions.any(
                        (value) => value.chapterId == item.chapter.id,
                      ),
                    )
                    .length;
                final expanded = row.key == expandedChapterGroup;
                return Semantics(
                  expanded: expanded,
                  child: ListTile(
                    key: ValueKey('chapter-group-${row.key}'),
                    title: Text(row.label),
                    subtitle: Text('$read / ${row.items.length} read'),
                    trailing: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () => setState(
                      () => expandedChapterGroup = expanded ? null : row.key,
                    ),
                  ),
                );
              }
              final chapter = row as ReaderChapterAvailability;
              final availability = details.chapters
                  .where((item) => item.chapter.id == chapter.chapter.id)
                  .first;
              return _ChapterTile(
                availability: availability,
                readerAvailability: chapter,
                preferred: details.preferredProvider,
                mediaId: media.id,
                readerRepository: readerRepository,
                onReaderClosed: onReaderClosed,
                isRead: details.chapterCompletions.any(
                  (value) => value.chapterId == chapter.chapter.id,
                ),
                onChanged: onRefresh,
                edit: details.chapterEdits[chapter.chapter.id],
                onEdit: onEditChapter,
                isSmartTarget:
                    details.smartResume?.chapterId == chapter.chapter.id,
              );
            },
          )
        else
          SliverList.builder(
            itemCount: details.episodes.length,
            itemBuilder: (context, index) => _EpisodeTile(
              availability: details.episodes[index],
              playbackAvailability: details.playbackEpisodes
                  .where(
                    (item) =>
                        item.episode.id == details.episodes[index].episode.id,
                  )
                  .firstOrNull,
              preferred: details.preferredProvider,
              mediaId: media.id,
              playbackRepository: playbackRepository,
              onPlayerClosed: onReaderClosed,
              isWatched: details.episodeCompletions.any(
                (value) =>
                    value.episodeId == details.episodes[index].episode.id,
              ),
              onChanged: onRefresh,
              edit: details.episodeEdits[details.episodes[index].episode.id],
              onEdit: onEditEpisode,
              isSmartTarget:
                  details.smartResume?.episodeId ==
                  details.episodes[index].episode.id,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: ZankaSpace.xl)),
      ],
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({
    required this.details,
    required this.action,
    required this.onLibrary,
    required this.onFavorite,
  });

  final ProductMediaDetails details;
  final Widget action;
  final VoidCallback onLibrary;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = details.summary.media;
    return Stack(
      key: const Key('details-artwork-hero'),
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .35, .7, 1],
                colors: [
                  scheme.surface.withValues(alpha: .4),
                  scheme.surface.withValues(alpha: .6),
                  scheme.surface.withValues(alpha: .96),
                  scheme.surface,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            ZankaSpace.lg,
            92,
            ZankaSpace.lg,
            ZankaSpace.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${media is CanonicalManga ? 'MANGA' : 'ANIME'} / '
                '${details.summary.isSaved ? 'IN YOUR LIBRARY' : 'IN FOCUS'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                media.title.value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _metadata(media),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: action,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const Key('toggle-library'),
                    onPressed: onLibrary,
                    icon: Icon(
                      details.summary.isSaved
                          ? Icons.bookmark_remove_outlined
                          : Icons.bookmark_add_outlined,
                    ),
                    label: Text(
                      details.summary.isSaved
                          ? 'Remove from Library'
                          : 'Add to Library',
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const Key('toggle-favorite'),
                    tooltip: details.summary.isFavorite
                        ? 'Remove favorite'
                        : 'Favorite',
                    onPressed: onFavorite,
                    icon: Icon(
                      details.summary.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChapterGroup {
  const _ChapterGroup(this.key, this.label, this.items);
  final String key;
  final String label;
  final List<ReaderChapterAvailability> items;
}

List<_ChapterGroup> _chapterGroups(ProductMediaDetails details) {
  final result = <_ChapterGroup>[];
  final volumes = <String, List<ReaderChapterAvailability>>{};
  final ungrouped = <ReaderChapterAvailability>[];
  for (final item in details.readerChapters) {
    final volume = item.chapter.volumeLabel?.trim();
    if (volume == null || volume.isEmpty) {
      ungrouped.add(item);
    } else {
      (volumes[volume] ??= []).add(item);
    }
  }
  for (final entry in volumes.entries) {
    result.add(_ChapterGroup('volume:${entry.key}', entry.key, entry.value));
  }
  for (var start = 0; start < ungrouped.length; start += 100) {
    final end = (start + 100).clamp(0, ungrouped.length);
    final values = ungrouped.sublist(start, end);
    final first = values.first.chapter.number.rawLabel;
    final last = values.last.chapter.number.rawLabel;
    result.add(
      _ChapterGroup(
        'range:$start',
        values.length == 1 ? first : '$first – $last',
        values,
      ),
    );
  }
  return result;
}

String? _smartChapterGroup(
  List<_ChapterGroup> groups,
  CanonicalChapterId? chapterId,
) {
  if (groups.isEmpty) return null;
  if (chapterId != null) {
    for (final group in groups) {
      if (group.items.any((item) => item.chapter.id == chapterId)) {
        return group.key;
      }
    }
  }
  return groups.length == 1 ? groups.first.key : null;
}

class _SmartResumeCard extends StatelessWidget {
  const _SmartResumeCard({
    required this.details,
    required this.readerRepository,
    required this.playbackRepository,
    required this.onClosed,
  });
  final ProductMediaDetails details;
  final ReaderRepository? readerRepository;
  final PlaybackRepository? playbackRepository;
  final Future<void> Function() onClosed;

  @override
  Widget build(BuildContext context) {
    final target = details.smartResume;
    if (target == null) return const SizedBox.shrink();
    final subtitle = _smartResumeSubtitle(details, target);
    return Semantics(
      button: target.hasAction,
      label: [target.label, if (subtitle.isNotEmpty) subtitle].join(', '),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          key: const Key('smart-resume-cta'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ZankaSpace.lg,
            vertical: 12,
          ),
          leading: Icon(
            target.action == SmartResumeAction.completed
                ? Icons.check_circle
                : details.summary.media is CanonicalManga
                ? Icons.menu_book
                : Icons.play_circle,
            size: 34,
          ),
          title: Text(
            target.label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: subtitle.isEmpty ? null : Text(subtitle),
          trailing: target.hasAction ? const Icon(Icons.arrow_forward) : null,
          onTap: target.hasAction ? () => _open(context, target) : null,
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, SmartResumeTarget target) async {
    if (target.chapterId case final chapterId?) {
      if (readerRepository == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MangaReaderScreen(
            repository: readerRepository!,
            request: ReaderSessionRequest(
              mediaId: details.summary.media.id,
              chapterId: chapterId,
              binding: target.chapterBinding,
            ),
          ),
        ),
      );
    } else if (target.episodeId case final episodeId?) {
      if (playbackRepository == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnimePlayerScreen(
            repository: playbackRepository!,
            request: PlaybackSessionRequest(
              mediaId: details.summary.media.id,
              episodeId: episodeId,
              binding: target.episodeBinding,
            ),
          ),
        ),
      );
    }
    await onClosed();
  }
}

String _smartResumeSubtitle(
  ProductMediaDetails details,
  SmartResumeTarget target,
) {
  if (target.chapterId case final id?) {
    final chapter = details.readerChapters
        .where((item) => item.chapter.id == id)
        .firstOrNull
        ?.chapter;
    final resume = target.pageResume;
    return [
      chapter?.number.rawLabel ?? 'Chapter',
      if (resume != null)
        'Page ${resume.pageIndex + 1}${resume.totalPages == null ? '' : ' / ${resume.totalPages}'}',
    ].join(' · ');
  }
  if (target.episodeId case final id?) {
    final episode = details.playbackEpisodes
        .where((item) => item.episode.id == id)
        .firstOrNull
        ?.episode;
    final position = target.playbackResume?.position;
    return [
      episode?.label.rawLabel ?? 'Episode',
      if (position != null) _duration(position),
    ].join(' · ');
  }
  return target.reason ?? '';
}

String _duration(Duration value) =>
    '${value.inMinutes}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.availability,
    required this.preferred,
    required this.mediaId,
    required this.readerAvailability,
    required this.readerRepository,
    required this.onReaderClosed,
    required this.isRead,
    required this.onChanged,
    required this.edit,
    required this.onEdit,
    this.isSmartTarget = false,
  });
  final CanonicalChapterAvailability availability;
  final ProviderId? preferred;
  final CanonicalMediaId mediaId;
  final ReaderChapterAvailability? readerAvailability;
  final ReaderRepository? readerRepository;
  final Future<void> Function() onReaderClosed;
  final bool isRead;
  final Future<void> Function() onChanged;
  final ChapterUserEdit? edit;
  final Future<void> Function(ChapterUserEdit) onEdit;
  final bool isSmartTarget;
  @override
  Widget build(BuildContext context) {
    final chapter = availability.chapter;
    final bindings = availability.sourceBindings;
    final readable = readerAvailability?.readableBindings ?? const [];
    final retryable = readerAvailability?.retryableBindings ?? const [];
    final openable = readerAvailability?.openableBindings ?? const [];
    return ListTile(
      key: ValueKey('chapter-${chapter.id.value}'),
      title: Text(edit?.rawLabel ?? chapter.number.rawLabel),
      dense: true,
      tileColor: isSmartTarget
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      subtitle: Text(
        [
          if (isRead) 'Read' else if (isSmartTarget) 'Up next',
          if (readable.isNotEmpty) '${readable.length} readable',
          if (retryable.isNotEmpty) '${retryable.length} retryable',
          if (readable.isEmpty && retryable.isEmpty) 'Unavailable',
          'Sources: ${bindings.map((item) => _providerName(item.providerId)).join(', ')}',
        ].join(' · '),
      ),
      onLongPress: () => _editChapterDialog(
        context,
        chapter.id,
        edit,
        chapter.number.rawLabel,
        onEdit,
      ),
      trailing: IconButton(
        tooltip: isRead ? 'Mark unread' : 'Mark read',
        icon: Icon(isRead ? Icons.check_circle : Icons.circle_outlined),
        onPressed: readerRepository == null
            ? null
            : () async {
                isRead
                    ? await readerRepository!.markUnread(chapter.id)
                    : await readerRepository!.markRead(chapter.id);
                await onChanged();
              },
      ),
      onTap: openable.isEmpty || readerRepository == null
          ? () => _placeholder(
              context,
              title: chapter.number.rawLabel,
              warning:
                  'No readable source is configured. Pages can differ between sources. Page equivalence is not assumed.',
              providers: bindings.map((item) => item.providerId).toList(),
              preferred: preferred,
            )
          : () async {
              final chosen = openable
                  .where((binding) => binding.providerId == preferred)
                  .firstOrNull;
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: RouteSettings(
                    name: '/reader/${mediaId.value}/${chapter.id.value}',
                  ),
                  builder: (_) => MangaReaderScreen(
                    repository: readerRepository!,
                    request: ReaderSessionRequest(
                      mediaId: mediaId,
                      chapterId: chapter.id,
                      binding: chosen,
                    ),
                  ),
                ),
              );
              await onReaderClosed();
            },
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.availability,
    required this.preferred,
    required this.mediaId,
    required this.playbackAvailability,
    required this.playbackRepository,
    required this.onPlayerClosed,
    required this.isWatched,
    required this.onChanged,
    required this.edit,
    required this.onEdit,
    this.isSmartTarget = false,
  });
  final CanonicalEpisodeAvailability availability;
  final ProviderId? preferred;
  final CanonicalMediaId mediaId;
  final PlaybackEpisodeAvailability? playbackAvailability;
  final PlaybackRepository? playbackRepository;
  final Future<void> Function() onPlayerClosed;
  final bool isWatched;
  final Future<void> Function() onChanged;
  final EpisodeUserEdit? edit;
  final Future<void> Function(EpisodeUserEdit) onEdit;
  final bool isSmartTarget;
  @override
  Widget build(BuildContext context) {
    final episode = availability.episode;
    final bindings = availability.sourceBindings;
    final playable = playbackAvailability?.playableBindings ?? const [];
    final retryable = playbackAvailability?.retryableBindings ?? const [];
    final openable = playbackAvailability?.openableBindings ?? const [];
    return ListTile(
      key: ValueKey('episode-${episode.id.value}'),
      title: Text(edit?.rawLabel ?? episode.label.rawLabel),
      dense: true,
      visualDensity: VisualDensity.compact,
      tileColor: isSmartTarget
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      subtitle: Text(
        [
          if (isWatched) 'Watched' else if (isSmartTarget) 'Up next',
          if (playable.isNotEmpty) '${playable.length} playable',
          if (retryable.isNotEmpty) '${retryable.length} retryable',
          if (playable.isEmpty && retryable.isEmpty) 'Unavailable',
          'Sources: ${bindings.map((item) => _providerName(item.providerId)).join(', ')}',
        ].join(' · '),
      ),
      onLongPress: () => _editEpisodeDialog(
        context,
        episode.id,
        edit,
        episode.label.rawLabel,
        onEdit,
      ),
      trailing: IconButton(
        tooltip: isWatched ? 'Mark unwatched' : 'Mark watched',
        icon: Icon(isWatched ? Icons.check_circle : Icons.circle_outlined),
        onPressed: playbackRepository == null
            ? null
            : () async {
                isWatched
                    ? await playbackRepository!.markUnwatched(episode.id)
                    : await playbackRepository!.markWatched(episode.id);
                await onChanged();
              },
      ),
      onTap: openable.isEmpty || playbackRepository == null
          ? () => _placeholder(
              context,
              title: episode.label.rawLabel,
              warning:
                  'No playback-capable source is configured. Playback positions may be approximate across different encodes.',
              providers: bindings.map((item) => item.providerId).toList(),
              preferred: preferred,
            )
          : () async {
              final chosen = openable
                  .where((binding) => binding.providerId == preferred)
                  .firstOrNull;
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: RouteSettings(
                    name: '/player/${mediaId.value}/${episode.id.value}',
                  ),
                  builder: (_) => AnimePlayerScreen(
                    repository: playbackRepository!,
                    request: PlaybackSessionRequest(
                      mediaId: mediaId,
                      episodeId: episode.id,
                      binding: chosen,
                    ),
                  ),
                ),
              );
              await onPlayerClosed();
            },
    );
  }
}

Future<void> _placeholder(
  BuildContext context, {
  required String title,
  required String warning,
  required List<ProviderId> providers,
  required ProviderId? preferred,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(ZankaSpace.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: ZankaSpace.sm),
            const Text('This installment can’t be opened right now.'),
            const SizedBox(height: ZankaSpace.sm),
            Text(warning),
            const SizedBox(height: ZankaSpace.md),
            Wrap(
              spacing: ZankaSpace.sm,
              children: providers
                  .map(
                    (provider) => SourceBadge(
                      _providerName(provider),
                      selected: provider == preferred,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: ZankaSpace.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('close-placeholder'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

Future<void> _editChapterDialog(
  BuildContext context,
  CanonicalChapterId id,
  ChapterUserEdit? current,
  String fallback,
  Future<void> Function(ChapterUserEdit) save,
) async {
  final result = await showDialog<InstallmentEditResult>(
    context: context,
    builder: (_) => InstallmentEditDialog(
      title: 'Edit chapter',
      kind: (current?.kind ?? MangaInstallmentKind.standard).name,
      kinds: MangaInstallmentKind.values.map((v) => v.name).toList(),
      fields: {
        'label': (
          label: 'Chapter label',
          value: current?.rawLabel ?? fallback,
          numeric: false,
        ),
        'volume': (
          label: 'Volume (optional)',
          value: current?.volumeLabel ?? '',
          numeric: false,
        ),
        'order': (
          label: 'Order (optional)',
          value: current?.explicitOrder?.toString() ?? '',
          numeric: true,
        ),
        'source': (
          label: 'Local source label (optional)',
          value: current?.sourceDisplayLabel ?? '',
          numeric: false,
        ),
      },
    ),
  );
  if (result == null || !context.mounted) return;
  final values = result.values;
  await save(
    ChapterUserEdit(
      chapterId: id,
      rawLabel: values['label']!.trim(),
      kind: MangaInstallmentKind.values.byName(result.kind),
      volumeLabel: values['volume']!.trim().isEmpty
          ? null
          : values['volume']!.trim(),
      explicitOrder: double.tryParse(values['order']!.trim()),
      sourceDisplayLabel: values['source']!.trim().isEmpty
          ? null
          : values['source']!.trim(),
      updatedAt: DateTime.now().toUtc(),
    ),
  );
}

Future<void> _editEpisodeDialog(
  BuildContext context,
  CanonicalEpisodeId id,
  EpisodeUserEdit? current,
  String fallback,
  Future<void> Function(EpisodeUserEdit) save,
) async {
  final result = await showDialog<InstallmentEditResult>(
    context: context,
    builder: (_) => InstallmentEditDialog(
      title: 'Edit episode',
      kind: (current?.kind ?? AnimeInstallmentKind.standard).name,
      kinds: AnimeInstallmentKind.values.map((v) => v.name).toList(),
      fields: {
        'label': (
          label: 'Episode label',
          value: current?.rawLabel ?? fallback,
          numeric: false,
        ),
        'number': (
          label: 'Episode number (optional)',
          value: current?.number?.toString() ?? '',
          numeric: true,
        ),
        'season': (
          label: 'Narrative season (optional)',
          value: current?.narrativeSeason?.toString() ?? '',
          numeric: true,
        ),
        'order': (
          label: 'Order (optional)',
          value: current?.explicitOrder?.toString() ?? '',
          numeric: true,
        ),
        'source': (
          label: 'Local source label (optional)',
          value: current?.sourceDisplayLabel ?? '',
          numeric: false,
        ),
      },
    ),
  );
  if (result == null || !context.mounted) return;
  final values = result.values;
  await save(
    EpisodeUserEdit(
      episodeId: id,
      rawLabel: values['label']!.trim(),
      number: double.tryParse(values['number']!.trim()),
      kind: AnimeInstallmentKind.values.byName(result.kind),
      narrativeSeason: int.tryParse(values['season']!.trim()),
      explicitOrder: double.tryParse(values['order']!.trim()),
      sourceDisplayLabel: values['source']!.trim().isEmpty
          ? null
          : values['source']!.trim(),
      updatedAt: DateTime.now().toUtc(),
    ),
  );
}

String _metadata(CanonicalMedia media) => switch (media) {
  CanonicalManga() => 'Manga · ${media.status.name}',
  CanonicalAnime(:final format, :final airingWindow) => [
    format.name.toUpperCase(),
    media.status.name,
    if (airingWindow != null) airingWindow.rawLabel,
    if (media.narrativeSeason != null)
      'Narrative season ${media.narrativeSeason!.value}',
  ].join(' · '),
};

String _providerName(ProviderId id) => switch (id.value) {
  'mangaworld' => 'MangaWorld',
  'animeworld' => 'AnimeWorld',
  final value =>
    value
        .split('-')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' '),
};

String _origin(ProviderId id) => switch (id.value) {
  'user-override' => 'Your edit',
  'deterministic-enrichment' => 'Enrichment',
  _ => 'Source metadata',
};

String _statusLabel(CanonicalLibraryStatus status) => switch (status) {
  CanonicalLibraryStatus.inProgress => 'In progress',
  _ => '${status.name[0].toUpperCase()}${status.name.substring(1)}',
};

String _progressText(ProductMediaSummary summary) {
  if (summary.mangaProgress case final progress?) {
    final total = progress.totalPages;
    return '${summary.progressLabel ?? 'Chapter'} · page ${progress.pageIndex + 1}'
        '${total == null ? '' : ' of $total'}';
  }
  final progress = summary.animeProgress!;
  final minutes = progress.position.inMinutes;
  final seconds = progress.position.inSeconds
      .remainder(60)
      .toString()
      .padLeft(2, '0');
  return '${summary.progressLabel ?? 'Episode'} · $minutes:$seconds watched';
}
