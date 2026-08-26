import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/media.dart';
import '../../canonical/domain/user_state.dart';
import '../../canonical/reconciliation/source_availability.dart';
import '../product_controller.dart';
import '../product_models.dart';
import 'design_system.dart';
import '../../reader/reader_domain.dart';
import '../../reader/reader_repository.dart';
import '../../reader/ui/manga_reader_screen.dart';
import '../../player/playback_domain.dart';
import '../../player/playback_repository.dart';
import '../../player/ui/anime_player_screen.dart';
import '../../product_maturity/maturity_domain.dart';
import '../../local_library/local_asset.dart';
import '../../adapter_platform/adapter_sdk.dart';
import '../smart_resume.dart';

class MediaDetailsScreen extends StatefulWidget {
  const MediaDetailsScreen({
    super.key,
    required this.controller,
    required this.mediaId,
    this.initialDetails,
  });
  final ProductController controller;
  final CanonicalMediaId mediaId;
  final ProductMediaDetails? initialDetails;

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  ProductMediaDetails? details;
  Object? error;
  bool refreshing = false;

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

  Future<void> _refreshSources() async {
    if (refreshing) return;
    setState(() => refreshing = true);
    try {
      final value = await widget.controller.refreshDetails(widget.mediaId);
      if (!mounted) return;
      setState(() => details = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source details refreshed.')),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Source details could not be refreshed. Your saved state is unchanged.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => refreshing = false);
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

  Future<void> _editMetadata() async {
    final current = details;
    if (current == null) return;
    final media = current.summary.media;
    final title = TextEditingController(text: media.title.value);
    final alternates = TextEditingController(
      text: media.alternateTitles.map((value) => value.value).join(', '),
    );
    final genres = TextEditingController(
      text: media.genres.map((value) => value.value).join(', '),
    );
    final description = TextEditingController(
      text: media.description?.value ?? '',
    );
    final creator = TextEditingController(
      text: current.metadataOverride?.creatorOrStudio ?? '',
    );
    final cover = TextEditingController(text: media.coverLocator ?? '');
    var status = media.status;
    var format = media is CanonicalAnime ? media.format : AnimeFormat.unknown;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Edit media'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Display title'),
                ),
                TextField(
                  controller: alternates,
                  decoration: const InputDecoration(
                    labelText: 'Alternate titles (comma separated)',
                  ),
                ),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: genres,
                  decoration: const InputDecoration(
                    labelText: 'Genres/tags (comma separated)',
                  ),
                ),
                TextField(
                  controller: cover,
                  decoration: const InputDecoration(
                    labelText: 'Cover URL or local path',
                  ),
                ),
                DropdownButtonFormField<CanonicalMediaStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: CanonicalMediaStatus.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) update(() => status = value);
                  },
                ),
                if (media is CanonicalAnime)
                  DropdownButtonFormField<AnimeFormat>(
                    initialValue: format,
                    decoration: const InputDecoration(labelText: 'Format'),
                    items: AnimeFormat.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) update(() => format = value);
                    },
                  ),
                TextField(
                  controller: creator,
                  decoration: InputDecoration(
                    labelText: media is CanonicalAnime
                        ? 'Studio (optional)'
                        : 'Creator (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'These user-owned values take priority over provider refresh and enrichment.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Clear all edits'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (accepted == null && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear all metadata edits?'),
          content: const Text(
            'Provider or enrichment values will show again. Your Library and progress are unchanged.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear edits'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        final updated = await widget.controller.clearMetadataOverrides(current);
        if (mounted) setState(() => details = updated);
      }
    }
    if (accepted == true) {
      List<String> split(String value) => value
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      final updated = await widget.controller.saveMetadataOverride(
        current,
        displayTitle: title.text,
        alternateTitles: split(alternates.text),
        genres: split(genres.text),
        coverLocator: cover.text.trim().isEmpty ? null : cover.text.trim(),
        description: description.text.trim().isEmpty
            ? null
            : description.text.trim(),
        status: status,
        animeFormat: media is CanonicalAnime ? format : null,
        creatorOrStudio: creator.text.trim().isEmpty
            ? null
            : creator.text.trim(),
      );
      if (mounted) setState(() => details = updated);
    }
    title.dispose();
    alternates.dispose();
    genres.dispose();
    description.dispose();
    creator.dispose();
    cover.dispose();
  }

  Future<void> _enrich() async {
    final current = details;
    if (current == null) return;
    final updated = await widget.controller.enrichReviewed(current);
    if (mounted) {
      setState(() => details = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reviewed deterministic enrichment attached with provenance.',
          ),
        ),
      );
    }
  }

  Future<void> _repairAsset(LocalAsset asset) async {
    final local = widget.controller.localLibrary;
    if (local == null) return;
    final extensions = asset.kind == LocalAssetKind.video
        ? const ['mp4', 'webm', 'mkv', 'mov']
        : const ['cbz'];
    final path = (await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: 'Choose replacement file',
    ))?.files.single.path;
    if (path == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repair local source?'),
        content: const Text(
          'The same media, installment, progress, and resume are retained. Only the missing file is replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Repair'),
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
        title: Text(value?.summary.media.title.value ?? 'Media details'),
        actions: [
          if (value != null)
            IconButton(
              key: const Key('refresh-source-details'),
              tooltip: 'Refresh source details',
              onPressed: refreshing ? null : _refreshSources,
              icon: refreshing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          if (value != null)
            IconButton(
              key: const Key('edit-metadata'),
              tooltip: 'Edit display metadata',
              onPressed: _editMetadata,
              icon: const Icon(Icons.edit_outlined),
            ),
          if (value != null)
            PopupMenuButton<MetadataOverrideField>(
              tooltip: 'Reset one metadata edit',
              icon: const Icon(Icons.undo),
              onSelected: (field) async {
                final updated = await widget.controller
                    .clearMetadataOverrideField(value, field);
                if (mounted) setState(() => details = updated);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: MetadataOverrideField.displayTitle,
                  child: Text('Reset title'),
                ),
                PopupMenuItem(
                  value: MetadataOverrideField.description,
                  child: Text('Reset description'),
                ),
                PopupMenuItem(
                  value: MetadataOverrideField.cover,
                  child: Text('Reset cover'),
                ),
                PopupMenuItem(
                  value: MetadataOverrideField.genres,
                  child: Text('Reset genres/tags'),
                ),
                PopupMenuItem(
                  value: MetadataOverrideField.status,
                  child: Text('Reset status'),
                ),
                PopupMenuItem(
                  value: MetadataOverrideField.format,
                  child: Text('Reset format'),
                ),
              ],
            ),
          if (value != null)
            IconButton(
              key: const Key('enrich-metadata'),
              tooltip: 'Attach reviewed enrichment',
              onPressed: _enrich,
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
        ],
      ),
      body: error != null
          ? ProductEmptyState(
              icon: Icons.error_outline,
              title: 'Details unavailable',
              message:
                  'The saved item is still safe. Try loading its local details again.',
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
          child: Padding(
            padding: const EdgeInsets.all(ZankaSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoverArt(
                      locator: media.coverLocator,
                      width: 112,
                      height: 160,
                    ),
                    const SizedBox(width: ZankaSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.title.value,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: ZankaSpace.sm),
                          Text(_metadata(media)),
                          Text(
                            'Title source: ${_origin(media.title.provenance.providerId)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: ZankaSpace.md),
                          FilledButton.icon(
                            key: const Key('toggle-library'),
                            onPressed: () => onLibrary(saved: !summary.isSaved),
                            icon: Icon(
                              summary.isSaved
                                  ? Icons.bookmark_remove
                                  : Icons.bookmark_add,
                            ),
                            label: Text(
                              summary.isSaved
                                  ? 'Remove from Library'
                                  : 'Add to Library',
                            ),
                          ),
                          IconButton(
                            key: const Key('toggle-favorite'),
                            tooltip: summary.isFavorite
                                ? 'Remove favorite'
                                : 'Favorite',
                            onPressed: () =>
                                onLibrary(favorite: !summary.isFavorite),
                            icon: Icon(
                              summary.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ZankaSpace.lg),
                _SmartResumeCard(
                  details: details,
                  readerRepository: readerRepository,
                  playbackRepository: playbackRepository,
                  onClosed: onReaderClosed,
                ),
                if (media.description case final description?) ...[
                  const SizedBox(height: ZankaSpace.lg),
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
                if (media.alternateTitles.isNotEmpty ||
                    media.genres.isNotEmpty ||
                    details.metadataOverride?.creatorOrStudio != null)
                  ExpansionTile(
                    key: const Key('optional-metadata'),
                    initiallyExpanded: metadataExpanded,
                    onExpansionChanged: (value) =>
                        setState(() => metadataExpanded = value),
                    tilePadding: EdgeInsets.zero,
                    title: const Text('More information'),
                    children: [
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
                ZankaSectionTitle(
                  media is CanonicalManga ? 'Chapters' : 'Episodes',
                ),
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
      child: Card.filled(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          key: const Key('smart-resume-cta'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ZankaSpace.md,
            vertical: ZankaSpace.sm,
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
            style: Theme.of(context).textTheme.titleLarge,
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
  showDragHandle: true,
  builder: (context) => Padding(
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
);

Future<void> _editChapterDialog(
  BuildContext context,
  CanonicalChapterId id,
  ChapterUserEdit? current,
  String fallback,
  Future<void> Function(ChapterUserEdit) save,
) async {
  final label = TextEditingController(text: current?.rawLabel ?? fallback);
  final volume = TextEditingController(text: current?.volumeLabel ?? '');
  final order = TextEditingController(
    text: current?.explicitOrder?.toString() ?? '',
  );
  final sourceLabel = TextEditingController(
    text: current?.sourceDisplayLabel ?? '',
  );
  var kind = current?.kind ?? MangaInstallmentKind.standard;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('Edit chapter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                decoration: const InputDecoration(labelText: 'Chapter label'),
              ),
              DropdownButtonFormField<MangaInstallmentKind>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Type'),
                items: MangaInstallmentKind.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => update(() => kind = value!),
              ),
              TextField(
                controller: volume,
                decoration: const InputDecoration(
                  labelText: 'Volume (optional)',
                ),
              ),
              TextField(
                controller: order,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Order (optional)',
                ),
              ),
              TextField(
                controller: sourceLabel,
                decoration: const InputDecoration(
                  labelText: 'Local source label (optional)',
                ),
              ),
              const Text(
                'This changes your display metadata, not the original source fact.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: label.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  if (accepted == true) {
    await save(
      ChapterUserEdit(
        chapterId: id,
        rawLabel: label.text.trim(),
        kind: kind,
        volumeLabel: volume.text.trim().isEmpty ? null : volume.text.trim(),
        explicitOrder: double.tryParse(order.text.trim()),
        sourceDisplayLabel: sourceLabel.text.trim().isEmpty
            ? null
            : sourceLabel.text.trim(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
  label.dispose();
  volume.dispose();
  order.dispose();
  sourceLabel.dispose();
}

Future<void> _editEpisodeDialog(
  BuildContext context,
  CanonicalEpisodeId id,
  EpisodeUserEdit? current,
  String fallback,
  Future<void> Function(EpisodeUserEdit) save,
) async {
  final label = TextEditingController(text: current?.rawLabel ?? fallback);
  final number = TextEditingController(text: current?.number?.toString() ?? '');
  final season = TextEditingController(
    text: current?.narrativeSeason?.toString() ?? '',
  );
  final order = TextEditingController(
    text: current?.explicitOrder?.toString() ?? '',
  );
  final sourceLabel = TextEditingController(
    text: current?.sourceDisplayLabel ?? '',
  );
  var kind = current?.kind ?? AnimeInstallmentKind.standard;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('Edit episode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                decoration: const InputDecoration(labelText: 'Episode label'),
              ),
              TextField(
                controller: number,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Episode number (optional)',
                ),
              ),
              DropdownButtonFormField<AnimeInstallmentKind>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AnimeInstallmentKind.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) => update(() => kind = value!),
              ),
              TextField(
                controller: season,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Narrative season (optional)',
                ),
              ),
              TextField(
                controller: order,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Order (optional)',
                ),
              ),
              TextField(
                controller: sourceLabel,
                decoration: const InputDecoration(
                  labelText: 'Local source label (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  if (accepted == true && label.text.trim().isNotEmpty) {
    await save(
      EpisodeUserEdit(
        episodeId: id,
        rawLabel: label.text.trim(),
        number: double.tryParse(number.text.trim()),
        kind: kind,
        narrativeSeason: int.tryParse(season.text.trim()),
        explicitOrder: double.tryParse(order.text.trim()),
        sourceDisplayLabel: sourceLabel.text.trim().isEmpty
            ? null
            : sourceLabel.text.trim(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
  label.dispose();
  number.dispose();
  season.dispose();
  order.dispose();
  sourceLabel.dispose();
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
