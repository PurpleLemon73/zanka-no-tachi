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

class _DetailsBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final summary = details.summary;
    final media = summary.media;
    final installments = media is CanonicalManga
        ? details.chapters.length
        : details.episodes.length;
    final volumes =
        details.chapters
            .map((item) => item.chapter.volumeLabel)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
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
                if (media.description case final description?) ...[
                  const SizedBox(height: ZankaSpace.lg),
                  Text(description.value),
                ],
                if (details.metadataOverride?.creatorOrStudio
                    case final creator?)
                  Padding(
                    padding: const EdgeInsets.only(top: ZankaSpace.sm),
                    child: Text(
                      '${media is CanonicalAnime ? 'Studio' : 'Creator'}: $creator · Your edit',
                    ),
                  ),
                if (media.alternateTitles.isNotEmpty) ...[
                  const SizedBox(height: ZankaSpace.md),
                  Text(
                    'Also known as ${media.alternateTitles.map((item) => item.value).join(', ')}',
                  ),
                ],
                if (media.genres.isNotEmpty) ...[
                  const SizedBox(height: ZankaSpace.md),
                  Wrap(
                    spacing: ZankaSpace.sm,
                    children: media.genres
                        .map((genre) => Chip(label: Text(genre.value)))
                        .toList(),
                  ),
                ],
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
                if (volumes.isNotEmpty) ...[
                  const ZankaSectionTitle('Volumes'),
                  Wrap(
                    spacing: ZankaSpace.sm,
                    children: volumes
                        .map((volume) => Chip(label: Text(volume)))
                        .toList(),
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
            itemCount: details.chapters.length,
            itemBuilder: (context, index) => _ChapterTile(
              availability: details.chapters[index],
              readerAvailability: details.readerChapters
                  .where(
                    (item) =>
                        item.chapter.id == details.chapters[index].chapter.id,
                  )
                  .firstOrNull,
              preferred: details.preferredProvider,
              mediaId: media.id,
              readerRepository: readerRepository,
              onReaderClosed: onReaderClosed,
              isRead: details.chapterCompletions.any(
                (value) =>
                    value.chapterId == details.chapters[index].chapter.id,
              ),
              onChanged: onRefresh,
              edit: details.chapterEdits[details.chapters[index].chapter.id],
              onEdit: onEditChapter,
            ),
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
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: ZankaSpace.xl)),
      ],
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    final chapter = availability.chapter;
    final bindings = availability.sourceBindings;
    final readable = readerAvailability?.readableBindings ?? const [];
    return ListTile(
      key: ValueKey('chapter-${chapter.id.value}'),
      title: Text(edit?.rawLabel ?? chapter.number.rawLabel),
      subtitle: Text(
        [
          if (chapter.volumeLabel != null) chapter.volumeLabel!,
          'Sources: ${bindings.map((item) => _providerName(item.providerId)).join(', ')}',
          if (readable.isEmpty) 'No readable source configured',
          if (readable.isNotEmpty) '${readable.length} readable source(s)',
          if (edit != null) '${edit!.kind.name} · Your edit',
          'Hold to edit',
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
      onTap: readable.isEmpty || readerRepository == null
          ? () => _placeholder(
              context,
              title: chapter.number.rawLabel,
              warning:
                  'No readable source is configured. Pages can differ between sources. Page equivalence is not assumed.',
              providers: bindings.map((item) => item.providerId).toList(),
              preferred: preferred,
            )
          : () async {
              final chosen = readable
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
  @override
  Widget build(BuildContext context) {
    final episode = availability.episode;
    final bindings = availability.sourceBindings;
    final playable = playbackAvailability?.playableBindings ?? const [];
    return ListTile(
      key: ValueKey('episode-${episode.id.value}'),
      title: Text(edit?.rawLabel ?? episode.label.rawLabel),
      subtitle: Text(
        [
          'Sources: ${bindings.map((item) => _providerName(item.providerId)).join(', ')}',
          playable.isEmpty
              ? 'No playback-capable source configured'
              : '${playable.length} playable source(s)',
          if (edit != null) '${edit!.kind.name} · Your edit',
          'Hold to edit',
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
      onTap: playable.isEmpty || playbackRepository == null
          ? () => _placeholder(
              context,
              title: episode.label.rawLabel,
              warning:
                  'No playback-capable source is configured. Playback positions may be approximate across different encodes.',
              providers: bindings.map((item) => item.providerId).toList(),
              preferred: preferred,
            )
          : () async {
              final chosen = playable
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
