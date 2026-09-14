import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../canonical/domain/media.dart';
import '../product_models.dart';

/// A content-sized Details modal. The entire form, including its actions, can
/// scroll inside the space left by SafeArea and the keyboard. No fixed height.
class DetailsDialog extends StatelessWidget {
  const DetailsDialog({
    super.key,
    required this.title,
    required this.children,
    required this.actions,
    this.tv = false,
  });
  final String title;
  final List<Widget> children, actions;
  final bool tv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tv ? 760 : 600),
        child: Theme(
          data: theme.copyWith(
            textTheme: tv
                ? theme.textTheme.apply(fontSizeFactor: 1.25)
                : theme.textTheme,
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: Shortcuts(
              shortcuts: tv
                  ? const {
                      SingleActivator(LogicalKeyboardKey.arrowDown):
                          NextFocusIntent(),
                      SingleActivator(LogicalKeyboardKey.arrowUp):
                          PreviousFocusIntent(),
                    }
                  : const {},
              child: SingleChildScrollView(
                key: const Key('details-dialog-scroll'),
                padding: EdgeInsets.all(tv ? 32 : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: tv ? 30 : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final child in children) ...[
                      child,
                      const SizedBox(height: 20),
                    ],
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: actions,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InstallmentEditResult {
  const InstallmentEditResult(this.values, this.kind);
  final Map<String, String> values;
  final String kind;
}

/// The two existing installment edit forms share layout/controller ownership,
/// but their callers retain the existing chapter/episode parsing semantics.
class InstallmentEditDialog extends StatefulWidget {
  const InstallmentEditDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.kinds,
    required this.kind,
  });
  final String title, kind;
  final Map<String, ({String label, String value, bool numeric})> fields;
  final List<String> kinds;
  @override
  State<InstallmentEditDialog> createState() => _InstallmentEditDialogState();
}

class _InstallmentEditDialogState extends State<InstallmentEditDialog> {
  late final Map<String, TextEditingController> fields;
  late String kind;
  @override
  void initState() {
    super.initState();
    kind = widget.kind;
    fields = {
      for (final entry in widget.fields.entries)
        entry.key: TextEditingController(text: entry.value.value),
    };
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DetailsDialog(
    title: widget.title,
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('installment-save'),
        onPressed: fields['label']!.text.trim().isEmpty
            ? null
            : () => Navigator.pop(
                context,
                InstallmentEditResult({
                  for (final entry in fields.entries)
                    entry.key: entry.value.text,
                }, kind),
              ),
        child: const Text('Save'),
      ),
    ],
    children: [
      for (final entry in widget.fields.entries)
        DetailsField(
          label: entry.value.label,
          child: TextField(
            key: Key('installment-${entry.key}'),
            controller: fields[entry.key],
            autofocus: entry.key == 'label',
            keyboardType: entry.value.numeric ? TextInputType.number : null,
            onChanged: entry.key == 'label' ? (_) => setState(() {}) : null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      DetailsField(
        label: 'Type',
        child: DropdownButtonFormField<String>(
          initialValue: kind,
          isExpanded: true,
          itemHeight: null,
          items: widget.kinds
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => kind = v);
          },
        ),
      ),
      const Text(
        'Only your display information changes. Original source information and progress are kept.',
      ),
    ],
  );
}

/// Persistent labels wrap outside the filled field instead of being compressed
/// into a floating InputDecorator label on a narrow dialog.
class DetailsField extends StatelessWidget {
  const DetailsField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Semantics(label: label, child: child),
    ],
  );
}

enum MetadataEditAction { save, clear }

class MetadataEditResult {
  const MetadataEditResult.clear()
    : action = MetadataEditAction.clear,
      values = const {},
      status = CanonicalMediaStatus.unknown,
      format = AnimeFormat.unknown;
  const MetadataEditResult.save(this.values, this.status, this.format)
    : action = MetadataEditAction.save;
  final MetadataEditAction action;
  final Map<String, String> values;
  final CanonicalMediaStatus status;
  final AnimeFormat format;
}

class MetadataEditDialog extends StatefulWidget {
  const MetadataEditDialog({super.key, required this.details, this.tv = false});
  final ProductMediaDetails details;
  final bool tv;
  @override
  State<MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<MetadataEditDialog> {
  late final Map<String, TextEditingController> fields;
  late CanonicalMediaStatus status;
  late AnimeFormat format;
  @override
  void initState() {
    super.initState();
    final media = widget.details.summary.media;
    fields = {
      'title': TextEditingController(text: media.title.value),
      'alternates': TextEditingController(
        text: media.alternateTitles.map((v) => v.value).join(', '),
      ),
      'description': TextEditingController(
        text: media.description?.value ?? '',
      ),
      'genres': TextEditingController(
        text: media.genres.map((v) => v.value).join(', '),
      ),
      'cover': TextEditingController(text: media.coverLocator ?? ''),
      'creator': TextEditingController(
        text: widget.details.metadataOverride?.creatorOrStudio ?? '',
      ),
    };
    status = media.status;
    format = media is CanonicalAnime ? media.format : AnimeFormat.unknown;
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Widget field(String id, String label, {int maxLines = 1}) => DetailsField(
    label: label,
    child: TextField(
      key: Key('metadata-$id'),
      controller: fields[id],
      autofocus: id == 'title',
      minLines: 1,
      maxLines: maxLines,
      onChanged: id == 'title' ? (_) => setState(() {}) : null,
      decoration: const InputDecoration(contentPadding: EdgeInsets.all(16)),
    ),
  );

  @override
  Widget build(BuildContext context) => DetailsDialog(
    title: 'Edit details',
    tv: widget.tv,
    actions: [
      TextButton(
        key: const Key('metadata-cancel'),
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        key: const Key('metadata-clear'),
        onPressed: widget.details.metadataOverride?.isEmpty == false
            ? () => Navigator.pop(context, const MetadataEditResult.clear())
            : null,
        child: const Text('Clear all edits'),
      ),
      FilledButton(
        key: const Key('metadata-save'),
        onPressed: fields['title']!.text.trim().isEmpty
            ? null
            : () => Navigator.pop(
                context,
                MetadataEditResult.save(
                  {
                    for (final entry in fields.entries)
                      entry.key: entry.value.text,
                  },
                  status,
                  format,
                ),
              ),
        child: const Text('Save'),
      ),
    ],
    children: [
      field('title', 'Display title'),
      field('alternates', 'Alternate titles (comma separated)'),
      field('description', 'Description', maxLines: 4),
      field('genres', 'Genres / tags (comma separated)'),
      field('cover', 'Cover URL or local path'),
      DetailsField(
        label: 'Status',
        child: DropdownButtonFormField<CanonicalMediaStatus>(
          key: const Key('metadata-status'),
          initialValue: status,
          isExpanded: true,
          itemHeight: null,
          items: CanonicalMediaStatus.values
              .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => status = v);
          },
        ),
      ),
      if (widget.details.summary.media is CanonicalAnime)
        DetailsField(
          label: 'Format',
          child: DropdownButtonFormField<AnimeFormat>(
            key: const Key('metadata-format'),
            initialValue: format,
            isExpanded: true,
            itemHeight: null,
            items: AnimeFormat.values
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => format = v);
            },
          ),
        ),
      field(
        'creator',
        widget.details.summary.media is CanonicalAnime
            ? 'Studio (optional)'
            : 'Creator (optional)',
      ),
      const Text(
        'Your edits take priority over source updates and enrichment. Library and reading or watching progress are unchanged.',
      ),
    ],
  );
}
