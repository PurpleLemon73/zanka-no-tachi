import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../product_controller.dart';
import '../product_models.dart';
import 'details_dialogs.dart';

enum _WatchAction { toggle, previous }

/// One discoverable action per episode, also available for metadata-only rows.
/// The snapshot names exact canonical IDs; storage revalidates a bulk prefix.
class EpisodeWatchActions extends StatefulWidget {
  const EpisodeWatchActions({
    super.key,
    required this.controller,
    required this.details,
    required this.episodeId,
    required this.onChanged,
    this.tv = false,
  });
  final ProductController controller;
  final ProductMediaDetails details;
  final CanonicalEpisodeId episodeId;
  final ValueChanged<ProductMediaDetails> onChanged;
  final bool tv;

  @override
  State<EpisodeWatchActions> createState() => _EpisodeWatchActionsState();
}

class _EpisodeWatchActionsState extends State<EpisodeWatchActions> {
  final opener = FocusNode(debugLabel: 'Episode actions');
  bool busy = false;

  @override
  void dispose() {
    opener.dispose();
    super.dispose();
  }

  Future<void> apply(_WatchAction action) async {
    if (busy) return;
    final current = widget.details;
    final id = widget.episodeId;
    final index = current.episodes.indexWhere((item) => item.episode.id == id);
    if (index < 0) return;
    final previous = action == _WatchAction.previous;
    final ids = previous
        ? current.episodes.take(index).map((item) => item.episode.id).toList()
        : [id];
    if (ids.isEmpty) return;
    final watched =
        previous ||
        !current.episodeCompletions.any((value) => value.episodeId == id);
    setState(() => busy = true);
    try {
      if (previous) {
        final label =
            current.episodeEdits[id]?.rawLabel ??
            current.episodes[index].episode.label.rawLabel;
        final accepted = await showDialog<bool>(
          context: context,
          builder: (context) => DetailsDialog(
            tv: widget.tv,
            title:
                'Mark ${ids.length} previous ${ids.length == 1 ? 'episode' : 'episodes'} as watched?',
            actions: [
              TextButton(
                key: const Key('cancel-episode-watched'),
                autofocus: true,
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('confirm-episode-watched'),
                onPressed: () => Navigator.pop(context, true),
                child: Text('Mark ${ids.length} watched'),
              ),
            ],
            children: [
              Text(
                'All episodes before “$label” in the episode order, including unavailable episodes. “$label” is not included. Existing playback positions are kept.',
              ),
            ],
          ),
        );
        if (accepted != true || !mounted) return;
      }
      final updated = await widget.controller.setEpisodeWatchState(
        current,
        ids,
        watched: watched,
        previousOf: previous ? id : null,
      );
      if (!mounted) return;
      widget.onChanged(updated);
      feedback(
        previous
            ? '${ids.length} previous episodes are now watched.'
            : watched
            ? 'Episode marked as watched.'
            : 'Episode marked as unwatched.',
      );
    } on Object {
      if (mounted) {
        feedback(
          'Could not update watched state. Reopen Details and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              widget.tv &&
              ModalRoute.of(context)?.isCurrent == true) {
            final button = opener.traversalDescendants.firstOrNull;
            button?.requestFocus();
          }
        });
      }
    }
  }

  void feedback(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final watched = widget.details.episodeCompletions.any(
      (value) => value.episodeId == widget.episodeId,
    );
    final index = widget.details.episodes.indexWhere(
      (value) => value.episode.id == widget.episodeId,
    );
    return Focus(
      focusNode: opener,
      skipTraversal: true,
      canRequestFocus: false,
      child: PopupMenuButton<_WatchAction>(
        key: ValueKey('episode-actions-${widget.episodeId.value}'),
        tooltip: 'Episode actions',
        enabled: !busy && index >= 0,
        icon: const Icon(Icons.more_horiz),
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(CircleBorder()),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
        ),
        onSelected: apply,
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _WatchAction.toggle,
            child: Text(
              watched ? 'Mark as unwatched' : 'Mark as watched',
              style: widget.tv ? const TextStyle(fontSize: 20) : null,
            ),
          ),
          PopupMenuItem(
            value: _WatchAction.previous,
            enabled: index > 0,
            child: Text(
              'Mark previous ${index < 0 ? 0 : index} episodes as watched',
              style: widget.tv ? const TextStyle(fontSize: 20) : null,
            ),
          ),
        ],
      ),
    );
  }
}
