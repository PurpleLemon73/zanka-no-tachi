import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/media.dart';
import '../../local_library/local_asset.dart';
import '../../local_library/local_library_service.dart';
import '../../adapter_platform/local_media_tools.dart';
import '../../adapter_platform/adapter_sdk.dart';
import '../product_controller.dart';
import 'design_system.dart';
import 'media_details_screen.dart';

enum _AssetFilter { all, manga, video, missing, available }

enum _AssetSort { title, size, recent, missing }

class LocalMediaScreen extends StatefulWidget {
  const LocalMediaScreen({super.key, required this.controller});
  final ProductController controller;
  @override
  State<LocalMediaScreen> createState() => _LocalMediaScreenState();
}

class _LocalMediaScreenState extends State<LocalMediaScreen> {
  List<LocalAsset> assets = const [];
  LocalStorageSummary? summary;
  bool busy = false;
  String query = '';
  _AssetFilter filter = _AssetFilter.all;
  _AssetSort sort = _AssetSort.recent;
  final Set<LocalAssetId> selected = {};

  List<LocalAsset> get visibleAssets {
    final titles = {
      for (final item in widget.controller.persisted)
        item.media.id: item.media.title.value,
    };
    final values = assets.where((asset) {
      final matchesQuery =
          query.isEmpty ||
          asset.originalName.toLowerCase().contains(query.toLowerCase()) ||
          (titles[asset.mediaId] ?? '').toLowerCase().contains(
            query.toLowerCase(),
          );
      final matchesFilter = switch (filter) {
        _AssetFilter.all => true,
        _AssetFilter.manga => asset.kind != LocalAssetKind.video,
        _AssetFilter.video => asset.kind == LocalAssetKind.video,
        _AssetFilter.missing => asset.state != LocalAssetState.available,
        _AssetFilter.available => asset.state == LocalAssetState.available,
      };
      return matchesQuery && matchesFilter;
    }).toList();
    values.sort(
      (left, right) => switch (sort) {
        _AssetSort.title => left.originalName.toLowerCase().compareTo(
          right.originalName.toLowerCase(),
        ),
        _AssetSort.size => (right.sizeBytes ?? 0).compareTo(
          left.sizeBytes ?? 0,
        ),
        _AssetSort.recent => right.createdAt.compareTo(left.createdAt),
        _AssetSort.missing =>
          left.state == right.state
              ? left.originalName.compareTo(right.originalName)
              : left.state == LocalAssetState.available
              ? 1
              : -1,
      },
    );
    return values;
  }

  LocalLibraryService get local => widget.controller.localLibrary!;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final nextAssets = await local.refreshStates();
    final nextSummary = await local.storageSummary();
    if (mounted) {
      setState(() {
        assets = nextAssets;
        summary = nextSummary;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
      await widget.controller.refreshLocal();
      await _reload();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<_ImportMetadata?> _metadata(
    CanonicalMediaKind kind,
    String path,
  ) async {
    final title = TextEditingController(text: _nameWithoutExtension(path));
    final label = TextEditingController(
      text: kind == CanonicalMediaKind.manga ? 'Chapter 1' : 'Episode 1',
    );
    CanonicalMediaId? attachment;
    final candidates = widget.controller.persisted
        .where((item) => item.media.kind == kind)
        .toList();
    final result = await showDialog<_ImportMetadata>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            kind == CanonicalMediaKind.manga ? 'Import manga' : 'Import video',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: label,
                  decoration: InputDecoration(
                    labelText: kind == CanonicalMediaKind.manga
                        ? 'Chapter label'
                        : 'Episode label',
                  ),
                ),
                DropdownButtonFormField<CanonicalMediaId?>(
                  initialValue: attachment,
                  decoration: const InputDecoration(
                    labelText: 'Attach to existing (reviewed)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Create new canonical media'),
                    ),
                    ...candidates.map(
                      (item) => DropdownMenuItem(
                        value: item.media.id,
                        child: Text(item.media.title.value),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => attachment = value),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Zanka will create an app-owned copy. The original file is not modified.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _ImportMetadata(
                  title: title.text.trim(),
                  label: label.text.trim(),
                  attachment: attachment,
                ),
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    label.dispose();
    return result;
  }

  Future<void> _importManga({bool folder = false}) async {
    final path = folder
        ? await FilePicker.getDirectoryPath(dialogTitle: 'Choose image folder')
        : (await FilePicker.pickFiles(
            type: FileType.custom,
            allowedExtensions: const ['cbz'],
            dialogTitle: 'Choose lawful CBZ',
          ))?.files.single.path;
    if (path == null || !mounted) return;
    final metadata = await _metadata(CanonicalMediaKind.manga, path);
    if (metadata == null || metadata.title.isEmpty || metadata.label.isEmpty) {
      return;
    }
    await _run(() async {
      final request = LocalImportRequest(
        sourcePath: path,
        title: metadata.title,
        installmentLabel: metadata.label,
        attachToMediaId: metadata.attachment,
      );
      folder
          ? await local.importMangaFolder(request)
          : await local.importManga(request);
    });
  }

  Future<void> _importVideo() async {
    final path = (await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'webm', 'mkv', 'mov'],
      dialogTitle: 'Choose lawful local video',
    ))?.files.single.path;
    if (path == null || !mounted) return;
    final metadata = await _metadata(CanonicalMediaKind.anime, path);
    if (metadata == null || metadata.title.isEmpty || metadata.label.isEmpty) {
      return;
    }
    await _run(
      () async => local.importVideo(
        LocalImportRequest(
          sourcePath: path,
          title: metadata.title,
          installmentLabel: metadata.label,
          attachToMediaId: metadata.attachment,
        ),
      ),
    );
  }

  Future<void> _batchImport(CanonicalMediaKind kind) async {
    final extensions = kind == CanonicalMediaKind.manga
        ? const ['cbz']
        : const ['mp4', 'webm', 'mkv', 'mov'];
    final selection = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: kind == CanonicalMediaKind.manga
          ? 'Choose lawful CBZ chapters'
          : 'Choose lawful local episodes',
    );
    final paths = selection?.files
        .map((value) => value.path)
        .whereType<String>()
        .toList();
    if (paths == null || paths.isEmpty || !mounted) return;
    final batch = LocalBatchImportService(
      local,
      const LocalMediaProbeService(),
    );
    var items = await batch.preview(paths);
    if (!mounted) return;
    final title = TextEditingController(
      text: _nameWithoutExtension(paths.first),
    );
    CanonicalMediaId? attachment;
    final candidates = widget.controller.persisted
        .where((value) => value.media.kind == kind)
        .toList();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            kind == CanonicalMediaKind.manga
                ? 'Review chapter batch'
                : 'Review episode batch',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Reviewed canonical title',
                    ),
                  ),
                  DropdownButtonFormField<CanonicalMediaId?>(
                    initialValue: attachment,
                    decoration: const InputDecoration(
                      labelText: 'Attach to existing (reviewed)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Create new canonical media'),
                      ),
                      ...candidates.map(
                        (value) => DropdownMenuItem(
                          value: value.media.id,
                          child: Text(value.media.title.value),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => attachment = value),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < items.length; index++)
                    Card(
                      child: ListTile(
                        title: Text(
                          _nameWithoutExtension(items[index].sourcePath),
                        ),
                        subtitle: Text(
                          '${items[index].warning == null ? 'Ready' : items[index].warning!}\n'
                          '${items[index].probe.pageCount == null ? '${items[index].probe.container} · ${_bytes(items[index].probe.sizeBytes)}' : '${items[index].probe.pageCount} pages · ${items[index].probe.imageFormats.join(', ')}'}',
                        ),
                        trailing: SizedBox(
                          width: 90,
                          child: TextFormField(
                            initialValue: items[index].label,
                            decoration: const InputDecoration(
                              labelText: 'Label',
                            ),
                            onChanged: (value) => items[index] = items[index]
                                .copyWith(label: value),
                          ),
                        ),
                      ),
                    ),
                  const Text(
                    'Filename order is only a preview. Review the canonical title and every label before commit.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import batch'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && title.text.trim().isNotEmpty) {
      await _run(() async {
        final mediaId = kind == CanonicalMediaKind.manga
            ? await batch.importManga(
                reviewedTitle: title.text,
                items: items,
                attachTo: attachment,
              )
            : await batch.importVideos(
                reviewedTitle: title.text,
                items: items,
                attachTo: attachment,
              );
        if (kind == CanonicalMediaKind.manga) {
          final cache = LocalThumbnailService(
            Directory('${(await local.root).path}/thumbnail-cache'),
          );
          final thumbnail = await cache.cbzThumbnail(
            items.first.sourcePath,
            mediaId.value,
          );
          await widget.controller.repository.saveMetadataOverride(
            MetadataOverride(mediaId: mediaId, coverLocator: thumbnail.path),
          );
        }
      });
    }
    title.dispose();
  }

  Future<void> _repair(LocalAsset asset) async {
    final extensions = asset.kind == LocalAssetKind.video
        ? const ['mp4', 'webm', 'mkv', 'mov']
        : const ['cbz'];
    final path = (await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: 'Choose replacement file',
    ))?.files.single.path;
    if (path != null) await _run(() => local.repair(asset, path));
  }

  Future<void> _reattach(LocalAsset asset) async {
    final installments = asset.kind == LocalAssetKind.video
        ? (await widget.controller.repository.live.database.episodesFor(
            asset.mediaId,
          )).map((value) => (value.id.value, value.label.rawLabel)).toList()
        : (await widget.controller.repository.live.database.chaptersFor(
            asset.mediaId,
          )).map((value) => (value.id.value, value.number.rawLabel)).toList();
    if (!mounted) return;
    final target = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attach file to installment'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Review carefully. The file and its exact resume move; canonical media and progress are not rewritten.',
              ),
              for (final value in installments)
                ListTile(
                  selected: value.$1 == asset.installmentId,
                  leading: Icon(
                    value.$1 == asset.installmentId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(value.$2),
                  onTap: value.$1 == asset.installmentId
                      ? null
                      : () => Navigator.pop(context, value.$1),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm attachment change'),
        content: const Text(
          'The local file source will move to the reviewed installment. This can be changed again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move source'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => local.reattach(asset, targetInstallmentId: target));
    }
  }

  Future<void> _remove(LocalAsset asset) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove local source?'),
        content: const Text(
          'Library state, canonical metadata, and progress remain. Choose whether to also delete Zanka’s app-owned file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep physical file'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete copy and source'),
          ),
        ],
      ),
    );
    if (delete != null) {
      await _run(() => local.removeSource(asset, deletePhysical: delete));
    }
  }

  Future<void> _removeSelected() async {
    final targets = assets
        .where((asset) => selected.contains(asset.id))
        .toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${targets.length} local sources?'),
        content: const Text(
          'The app-owned files will be kept. Library entries, media metadata, and progress are unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove sources'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      for (final asset in targets) {
        await local.removeSource(asset, deletePhysical: false);
      }
      selected.clear();
    });
  }

  Future<void> _backup() async {
    await _run(() async {
      final temporary = await widget.controller.backup!.exportDataOnly(
        File('${(await local.root).path}/zanka-data-backup.zip'),
      );
      await FilePicker.saveFile(
        dialogTitle: 'Save Zanka data backup',
        fileName: 'zanka-data.zanka-backup.zip',
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        bytes: await temporary.readAsBytes(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data-only backup created. Local media files are excluded.',
            ),
          ),
        );
      }
    });
  }

  Future<void> _restore() async {
    final path = (await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      dialogTitle: 'Choose Zanka backup',
    ))?.files.single.path;
    if (path == null || !mounted) return;
    final preview = await widget.controller.backup!.preview(File(path));
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore data non-destructively?'),
        content: Text(
          '${preview.mediaCount} media · ${preview.libraryCount} library records · ${preview.localAssetCount} excluded local assets. Current data will be kept and merged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() async {
        final result = await widget.controller.backup!.restore(File(path));
        if (mounted && result.conflicts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Restored with ${result.conflicts.length} binding conflict(s).',
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _cleanup() async {
    await _run(() async {
      final result = await local.clearRegenerableData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed ${result.filesRemoved} cache/temporary file(s), freeing ${_bytes(result.bytesFreed)}. Imported media and progress were not changed.',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local media')),
    body: ListView(
      padding: const EdgeInsets.all(ZankaSpace.md),
      children: [
        if (busy) const LinearProgressIndicator(),
        Text('Import', style: Theme.of(context).textTheme.titleLarge),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: busy ? null : _importManga,
              icon: const Icon(Icons.book),
              label: const Text('Import CBZ'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _importManga(folder: true),
              icon: const Icon(Icons.folder),
              label: const Text('Import image folder'),
            ),
            FilledButton.icon(
              onPressed: busy ? null : _importVideo,
              icon: const Icon(Icons.movie),
              label: const Text('Import video'),
            ),
            OutlinedButton.icon(
              key: const Key('batch-import-cbz'),
              onPressed: busy
                  ? null
                  : () => _batchImport(CanonicalMediaKind.manga),
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Batch CBZ'),
            ),
            OutlinedButton.icon(
              key: const Key('batch-import-video'),
              onPressed: busy
                  ? null
                  : () => _batchImport(CanonicalMediaKind.anime),
              icon: const Icon(Icons.video_library_outlined),
              label: const Text('Batch video'),
            ),
          ],
        ),
        const ZankaSectionTitle('Backup and portability'),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Create data-only backup'),
          subtitle: const Text(
            'Portable canonical state and preferences; local media files excluded.',
          ),
          onTap: busy ? null : _backup,
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore backup'),
          subtitle: const Text(
            'Validates and merges without deleting current data.',
          ),
          onTap: busy ? null : _restore,
        ),
        const ZankaSectionTitle('Tracked storage'),
        Text(
          '${summary?.assetCount ?? 0} assets · ${summary?.missingCount ?? 0} missing',
        ),
        Text(
          'Manga ${_bytes(summary?.mangaBytes ?? 0)} · Video ${_bytes(summary?.videoBytes ?? 0)}',
        ),
        const ZankaSectionTitle('Your files'),
        TextField(
          key: const Key('local-media-search'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search local media',
          ),
          onChanged: (value) => setState(() => query = value.trim()),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            DropdownButton<_AssetFilter>(
              value: filter,
              items: _AssetFilter.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(switch (value) {
                        _AssetFilter.all => 'All files',
                        _AssetFilter.manga => 'Manga',
                        _AssetFilter.video => 'Videos',
                        _AssetFilter.missing => 'Needs repair',
                        _AssetFilter.available => 'Available',
                      }),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => filter = value!),
            ),
            DropdownButton<_AssetSort>(
              value: sort,
              items: _AssetSort.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('Sort: ${value.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => sort = value!),
            ),
          ],
        ),
        if (selected.isNotEmpty)
          ListTile(
            title: Text('${selected.length} selected'),
            trailing: Wrap(
              children: [
                TextButton(
                  onPressed: () => setState(selected.clear),
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: busy ? null : _removeSelected,
                  child: const Text('Remove sources…'),
                ),
              ],
            ),
          ),
        if (visibleAssets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No local media matches these filters.'),
          ),
        for (final asset in visibleAssets)
          Card(
            child: ListTile(
              selected: selected.contains(asset.id),
              onLongPress: () => setState(() => selected.add(asset.id)),
              onTap: selected.isNotEmpty
                  ? () => setState(
                      () => selected.contains(asset.id)
                          ? selected.remove(asset.id)
                          : selected.add(asset.id),
                    )
                  : () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MediaDetailsScreen(
                            controller: widget.controller,
                            mediaId: asset.mediaId,
                          ),
                        ),
                      );
                      await _reload();
                    },
              title: Text(asset.originalName),
              subtitle: Text(
                '${asset.kind == LocalAssetKind.video ? 'Video' : 'Manga'} · '
                '${asset.state == LocalAssetState.available ? 'Available' : 'Needs repair'} · '
                '${_bytes(asset.sizeBytes ?? 0)}',
              ),
              leading: Icon(
                asset.state == LocalAssetState.available
                    ? Icons.check_circle_outline
                    : Icons.link_off,
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'repair') _repair(asset);
                  if (value == 'attach') _reattach(asset);
                  if (value == 'remove') _remove(asset);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'attach',
                    child: Text('Attach to another installment…'),
                  ),
                  PopupMenuItem(
                    value: 'repair',
                    child: Text('Repair / replace'),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove local source…'),
                  ),
                ],
              ),
            ),
          ),
        const ZankaSectionTitle('Maintenance'),
        ListTile(
          key: const Key('scan-missing-assets'),
          leading: const Icon(Icons.find_in_page_outlined),
          title: const Text('Scan for missing local media'),
          subtitle: const Text(
            'Checks tracked files without deleting Library state or progress.',
          ),
          onTap: busy ? null : () => _run(() async {}),
        ),
        ListTile(
          key: const Key('clear-regenerable-data'),
          leading: const Icon(Icons.cleaning_services_outlined),
          title: const Text('Clear thumbnails and temporary files'),
          subtitle: const Text(
            'Only regenerable cache and orphan preparation files are removed.',
          ),
          onTap: busy ? null : _cleanup,
        ),
      ],
    ),
  );
}

class _ImportMetadata {
  const _ImportMetadata({
    required this.title,
    required this.label,
    this.attachment,
  });
  final String title;
  final String label;
  final CanonicalMediaId? attachment;
}

String _nameWithoutExtension(String path) {
  final name = path.split(Platform.pathSeparator).last;
  final dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}

String _bytes(int value) => value < 1024 * 1024
    ? '${(value / 1024).toStringAsFixed(1)} KB'
    : '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
