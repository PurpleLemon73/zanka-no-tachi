import 'package:flutter/material.dart';
import '../../app/build_profile.dart';

import '../../adapter_platform/adapter_sdk.dart';
import '../../canonical/domain/media.dart';
import '../product_controller.dart';
import '../product_models.dart';
import 'details_dialogs.dart';

enum _ExtraAction { demo }

/// Details-owned presentation of existing application commands; shared by the
/// touch and semantic TV headers. No source, progress or persistence policy.
class DetailsActions extends StatefulWidget {
  const DetailsActions({
    super.key,
    required this.controller,
    required this.details,
    required this.onChanged,
    this.onRefresh,
    this.enabled = true,
    this.refreshing = false,
    this.tv = false,
  });
  final ProductController controller;
  final ProductMediaDetails details;
  final ValueChanged<ProductMediaDetails> onChanged;
  final Future<void> Function()? onRefresh;
  final bool enabled, refreshing, tv;
  @override
  State<DetailsActions> createState() => _DetailsActionsState();
}

class _DetailsActionsState extends State<DetailsActions> {
  bool busy = false;
  bool get enabled => widget.enabled && !busy;

  Future<void> run(Future<void> Function() action) async {
    if (!enabled) return;
    final opener = FocusManager.instance.primaryFocus;
    setState(() => busy = true);
    try {
      await action();
    } on Object {
      if (mounted) {
        feedback('The change could not be completed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              ModalRoute.of(context)?.isCurrent == true &&
              opener?.context?.mounted == true &&
              opener!.canRequestFocus) {
            opener.requestFocus();
          }
        });
      }
    }
  }

  void feedback(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<bool> confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => DetailsDialog(
          tv: widget.tv,
          title: title,
          actions: [
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
          children: [Text(message)],
        ),
      ) ==
      true;

  Future<void> edit() => run(() async {
    final current = widget.details;
    final result = await showDialog<MetadataEditResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MetadataEditDialog(details: current, tv: widget.tv),
    );
    if (!mounted || result == null) return;
    ProductMediaDetails updated;
    if (result.action == MetadataEditAction.clear) {
      if (!await confirm(
            'Clear all metadata edits?',
            'Source or enrichment values will show again. Your Library and progress are unchanged.',
            'Clear edits',
          ) ||
          !mounted) {
        return;
      }
      updated = await widget.controller.clearMetadataOverrides(current);
    } else {
      final values = result.values;
      List<String> split(String key) => values[key]!
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();
      String? optional(String key) =>
          values[key]!.trim().isEmpty ? null : values[key]!.trim();
      updated = await widget.controller.saveMetadataOverride(
        current,
        displayTitle: values['title']!,
        alternateTitles: split('alternates'),
        genres: split('genres'),
        coverLocator: optional('cover'),
        description: optional('description'),
        status: result.status,
        animeFormat: current.summary.media is CanonicalAnime
            ? result.format
            : null,
        creatorOrStudio: optional('creator'),
      );
    }
    if (!mounted) return;
    widget.onChanged(updated);
    feedback(
      result.action == MetadataEditAction.clear
          ? 'Your edits were cleared.'
          : 'Your edits were saved.',
    );
  });

  Future<void> extra(Object action) => run(() async {
    final current = widget.details;
    ProductMediaDetails updated;
    if (action is MetadataOverrideField) {
      updated = await widget.controller.clearMetadataOverrideField(
        current,
        action,
      );
    } else {
      if (!BuildProfile.current.allowsDemoContent) return;
      if (!await confirm(
            'Apply demo metadata?',
            'This adds a demonstration alternate title. It does not look up live information. Your edits keep priority.',
            'Apply demo metadata',
          ) ||
          !mounted) {
        return;
      }
      updated = await widget.controller.enrichReviewed(current);
    }
    if (!mounted) return;
    widget.onChanged(updated);
    feedback(
      action is MetadataOverrideField
          ? 'The edited field was reset.'
          : 'Demo metadata applied.',
    );
  });

  @override
  Widget build(BuildContext context) {
    final override = widget.details.metadataOverride;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onRefresh != null)
          IconButton(
            key: const Key('refresh-source-details'),
            tooltip: 'Refresh source details',
            onPressed: enabled ? () => run(widget.onRefresh!) : null,
            icon: widget.refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        IconButton(
          key: const Key('edit-metadata'),
          tooltip: 'Edit display information',
          onPressed: enabled ? edit : null,
          icon: const Icon(Icons.edit_outlined),
        ),
        PopupMenuButton<Object>(
          key: const Key('details-more-actions'),
          tooltip: 'More Details actions',
          enabled: enabled,
          icon: const Icon(Icons.more_vert),
          onSelected: extra,
          itemBuilder: (_) => [
            for (final (field, label, available) in [
              (
                MetadataOverrideField.displayTitle,
                'Reset title',
                override?.displayTitle != null,
              ),
              (
                MetadataOverrideField.description,
                'Reset description',
                override?.description != null,
              ),
              (
                MetadataOverrideField.cover,
                'Reset cover',
                override?.coverLocator != null,
              ),
              (
                MetadataOverrideField.genres,
                'Reset genres / tags',
                override?.genres.isNotEmpty == true,
              ),
              (
                MetadataOverrideField.status,
                'Reset status',
                override?.status != null,
              ),
              (
                MetadataOverrideField.format,
                'Reset format',
                widget.details.summary.media is CanonicalAnime &&
                    override?.animeFormat != null,
              ),
            ])
              PopupMenuItem(
                value: field,
                enabled: available,
                child: Text(
                  label,
                  style: widget.tv ? const TextStyle(fontSize: 20) : null,
                ),
              ),
            if (BuildProfile.current.allowsDemoContent) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                key: const Key('enrich-metadata'),
                value: _ExtraAction.demo,
                child: Text(
                  'Apply demo metadata…',
                  style: widget.tv ? const TextStyle(fontSize: 20) : null,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
