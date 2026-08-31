import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/user_state.dart';
import '../../product/ui/design_system.dart';
import '../reader_domain.dart';
import '../reader_page_cache.dart';
import '../reader_repository.dart';

class MangaReaderScreen extends StatefulWidget {
  const MangaReaderScreen({
    super.key,
    required this.repository,
    required this.request,
    this.initialSession,
  });
  final ReaderRepository repository;
  final ReaderSessionRequest request;
  final ReaderSession? initialSession;

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen>
    with WidgetsBindingObserver {
  final cache = ReaderPageCache(maximumPages: 3);
  ReaderSession? session;
  Object? error;
  int currentPage = 0;
  PageController? pageController;
  ScrollController? scrollController;
  Timer? persistDebounce;
  bool controlsVisible = true;
  final Map<int, GlobalKey> verticalPageKeys = {};
  bool verticalTrackingReady = false;
  bool pagedZoomed = false;
  int zoomResetGeneration = 0;
  List<ReaderChapterAvailability> chapterNavigation = const [];
  Set<CanonicalChapterId> completedChapters = const {};
  CanonicalMangaProgress? canonicalProgress;
  bool completionVisible = false;
  bool completionHandled = false;
  late ReaderSessionRequest activeRequest;

  @override
  void initState() {
    super.initState();
    activeRequest = widget.request;
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialSession case final initial?) {
      session = initial;
      currentPage = initial.startPage;
      pageController = PageController(initialPage: currentPage);
      scrollController = ScrollController();
      cache.prefetch(initial.manifest, currentPage);
      unawaited(_refreshNavigation(initial.mediaId));
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreVerticalPage(),
      );
    } else {
      _open(widget.request);
    }
  }

  Future<void> _open(ReaderSessionRequest request) async {
    await _flush();
    if (!mounted) return;
    activeRequest = request;
    setState(() {
      session = null;
      error = null;
      chapterNavigation = const [];
      completedChapters = const {};
      canonicalProgress = null;
      completionVisible = false;
      completionHandled = false;
    });
    try {
      final value = await widget.repository.open(request);
      currentPage = value.startPage;
      verticalTrackingReady = false;
      verticalPageKeys.clear();
      pagedZoomed = false;
      zoomResetGeneration++;
      pageController?.dispose();
      scrollController?.dispose();
      pageController = PageController(initialPage: currentPage);
      scrollController = ScrollController();
      cache.clear();
      cache.prefetch(value.manifest, currentPage);
      if (mounted) setState(() => session = value);
      await _refreshNavigation(value.mediaId);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreVerticalPage(),
      );
    } on Object catch (value) {
      if (mounted) setState(() => error = value);
    }
  }

  Future<void> _refreshNavigation(CanonicalMediaId mediaId) async {
    final chapters = await widget.repository.chapters(mediaId);
    final completed = await widget.repository.completedChapters(mediaId);
    final progress = await widget.repository.progress(mediaId);
    if (!mounted || session?.mediaId != mediaId) return;
    final current = session!;
    final atEnd = currentPage == current.manifest.pages.length - 1;
    final completeSinglePage =
        current.manifest.pages.length == 1 &&
        !completed.contains(current.chapter.id);
    setState(() {
      chapterNavigation = chapters;
      completedChapters = completed;
      canonicalProgress = progress;
      if (atEnd && completed.contains(current.chapter.id)) {
        completionVisible = true;
        completionHandled = true;
      }
    });
    if (completeSinglePage && !completionHandled) {
      completionHandled = true;
      unawaited(_completeChapter(current));
    }
  }

  int get _currentChapterIndex => chapterNavigation.indexWhere(
    (value) => value.chapter.id == session?.chapter.id,
  );

  ReaderChapterAvailability? _chapterAtOffset(int direction) {
    final index = _currentChapterIndex;
    final target = index + direction;
    return index < 0 || target < 0 || target >= chapterNavigation.length
        ? null
        : chapterNavigation[target];
  }

  ReaderChapterAvailability? get _currentAvailability {
    final index = _currentChapterIndex;
    return index < 0 ? null : chapterNavigation[index];
  }

  void _pageChanged(int page) {
    if (page == currentPage) return;
    setState(() {
      currentPage = page;
      pagedZoomed = false;
    });
    final value = session;
    if (value != null) cache.prefetch(value.manifest, page);
    persistDebounce?.cancel();
    if (value != null &&
        page == value.manifest.pages.length - 1 &&
        !completionHandled) {
      completionHandled = true;
      unawaited(_completeChapter(value));
    } else {
      persistDebounce = Timer(const Duration(milliseconds: 300), _flush);
    }
  }

  Future<void> _completeChapter(ReaderSession value) async {
    persistDebounce?.cancel();
    await widget.repository.savePosition(
      value,
      value.manifest.pages.length - 1,
    );
    final completed = await widget.repository.completedChapters(value.mediaId);
    if (!mounted || session?.chapter.id != value.chapter.id) return;
    setState(() {
      completedChapters = completed;
      completionVisible = true;
    });
  }

  void _restoreVerticalPage() {
    final value = session;
    if (!mounted || value?.preferences.mode != ReaderMode.vertical) return;
    final target = verticalPageKeys[currentPage]?.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target, alignment: 0, duration: Duration.zero);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) verticalTrackingReady = true;
      });
    });
  }

  void _updateVisiblePage() {
    if (!mounted || !verticalTrackingReady) return;
    final viewport = context.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final center = viewport.size.height / 2;
    int? best;
    var distance = double.infinity;
    for (final entry in verticalPageKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      if (bottom <= 0 || top >= viewport.size.height) continue;
      final pageCenter = (top + bottom) / 2;
      final candidate = (pageCenter - center).abs();
      if (candidate < distance) {
        distance = candidate;
        best = entry.key;
      }
    }
    if (best != null) _pageChanged(best);
  }

  Future<void> _flush() async {
    persistDebounce?.cancel();
    final value = session;
    if (value != null) await widget.repository.savePosition(value, currentPage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_flush());
    persistDebounce?.cancel();
    pageController?.dispose();
    scrollController?.dispose();
    cache.clear();
    super.dispose();
  }

  Future<void> _settings() async {
    final value = session;
    if (value == null) return;
    var preferences = value.preferences;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SingleChildScrollView(
          padding: const EdgeInsets.all(ZankaSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reader settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: ZankaSpace.md),
              SegmentedButton<ReaderMode>(
                segments: const [
                  ButtonSegment(
                    value: ReaderMode.vertical,
                    label: Text('Vertical'),
                  ),
                  ButtonSegment(value: ReaderMode.paged, label: Text('Paged')),
                ],
                selected: {preferences.mode},
                onSelectionChanged: (value) => update(
                  () => preferences = preferences.copyWith(mode: value.first),
                ),
              ),
              const SizedBox(height: ZankaSpace.md),
              SegmentedButton<ReaderDirection>(
                segments: const [
                  ButtonSegment(
                    value: ReaderDirection.leftToRight,
                    label: Text('LTR'),
                  ),
                  ButtonSegment(
                    value: ReaderDirection.rightToLeft,
                    label: Text('RTL'),
                  ),
                ],
                selected: {preferences.direction},
                onSelectionChanged: (value) => update(
                  () => preferences = preferences.copyWith(
                    direction: value.first,
                  ),
                ),
              ),
              const SizedBox(height: ZankaSpace.md),
              SegmentedButton<ReaderFit>(
                segments: const [
                  ButtonSegment(
                    value: ReaderFit.width,
                    label: Text('Fit width'),
                  ),
                  ButtonSegment(
                    value: ReaderFit.contain,
                    label: Text('Contain'),
                  ),
                ],
                selected: {preferences.fit},
                onSelectionChanged: (value) => update(
                  () => preferences = preferences.copyWith(fit: value.first),
                ),
              ),
              const SizedBox(height: ZankaSpace.lg),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('save-reader-settings'),
                  onPressed: () async {
                    await widget.repository.savePreferences(preferences);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || preferences == value.preferences) return;
    setState(() {
      verticalTrackingReady = false;
      session = ReaderSession(
        mediaId: value.mediaId,
        chapter: value.chapter,
        manifest: value.manifest,
        startPage: currentPage,
        preferences: preferences,
        resume: value.resume,
      );
      pageController?.dispose();
      pageController = PageController(initialPage: currentPage);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVerticalPage());
  }

  Future<void> _sources() async {
    final value = session;
    if (value == null) return;
    final chapters = await widget.repository.chapters(value.mediaId);
    final chapter = chapters.firstWhere(
      (item) => item.chapter.id == value.chapter.id,
    );
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(ZankaSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading source',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'Each scan keeps its own page resume. A new source starts at page 1; exact page equivalence is not assumed.',
            ),
            ...chapter.openableBindings.map(
              (binding) => ListTile(
                selected:
                    binding.providerId == value.manifest.binding.providerId &&
                    binding.externalId == value.manifest.binding.externalId,
                leading: Icon(
                  binding.providerId == value.manifest.binding.providerId &&
                          binding.externalId ==
                              value.manifest.binding.externalId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(_sourceName(binding.providerId)),
                onTap: () {
                  Navigator.pop(context);
                  _open(
                    ReaderSessionRequest(
                      mediaId: value.mediaId,
                      chapterId: value.chapter.id,
                      binding: binding,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjacent(int direction) async {
    final value = session;
    if (value == null) return;
    final chapter = _currentChapterIndex < 0
        ? await widget.repository.adjacent(value, direction)
        : _chapterAtOffset(direction);
    if (!mounted) return;
    if (chapter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            direction < 0
                ? 'This is the first chapter.'
                : 'This is the last chapter.',
          ),
        ),
      );
    } else if (chapter.openableBindings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The adjacent chapter has no readable source configured.',
          ),
        ),
      );
    } else {
      await _open(
        ReaderSessionRequest(
          mediaId: value.mediaId,
          chapterId: chapter.chapter.id,
          startAtBeginning: direction > 0,
        ),
      );
    }
  }

  Future<void> _picker() async {
    final value = session;
    if (value == null) return;
    await _flush();
    var chapters = chapterNavigation;
    if (chapters.isEmpty) {
      chapters = await widget.repository.chapters(value.mediaId);
    }
    final completed = await widget.repository.completedChapters(value.mediaId);
    final progress = await widget.repository.progress(value.mediaId);
    if (!mounted || session?.chapter.id != value.chapter.id) return;
    setState(() {
      chapterNavigation = chapters;
      completedChapters = completed;
      canonicalProgress = progress;
    });
    final volumeLabels = <String>[];
    for (final chapter in chapters) {
      final label = chapter.volumeLabel;
      if (label != null && !volumeLabels.contains(label)) {
        volumeLabels.add(label);
      }
    }
    final currentVolume = _currentAvailability?.volumeLabel;
    final volumeIndex = currentVolume == null
        ? -1
        : volumeLabels.indexOf(currentVolume);
    ReaderChapterAvailability firstInVolume(String label) =>
        chapters.firstWhere((chapter) => chapter.volumeLabel == label);

    final chosen = await showModalBottomSheet<ReaderChapterAvailability>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, controller) => SafeArea(
          child: Column(
            children: [
              ListTile(
                title: const Text('Chapters'),
                subtitle: Text(
                  currentVolume == null
                      ? '${chapters.length} canonical chapters'
                      : '$currentVolume · ${chapters.length} canonical chapters',
                ),
                leading: IconButton(
                  key: const Key('previous-volume'),
                  tooltip: 'Previous volume',
                  onPressed: volumeIndex > 0
                      ? () => Navigator.pop(
                          context,
                          firstInVolume(volumeLabels[volumeIndex - 1]),
                        )
                      : null,
                  icon: const Icon(Icons.first_page),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (volumeLabels.isNotEmpty)
                      PopupMenuButton<String>(
                        key: const Key('volume-picker'),
                        tooltip: 'Jump to volume',
                        onSelected: (label) =>
                            Navigator.pop(context, firstInVolume(label)),
                        itemBuilder: (context) => [
                          for (final label in volumeLabels)
                            PopupMenuItem(value: label, child: Text(label)),
                        ],
                        icon: const Icon(Icons.library_books_outlined),
                      ),
                    IconButton(
                      key: const Key('next-volume'),
                      tooltip: 'Next volume',
                      onPressed:
                          volumeIndex >= 0 &&
                              volumeIndex < volumeLabels.length - 1
                          ? () => Navigator.pop(
                              context,
                              firstInVolume(volumeLabels[volumeIndex + 1]),
                            )
                          : null,
                      icon: const Icon(Icons.last_page),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  key: const Key('chapter-picker-list'),
                  controller: controller,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    final previousVolume = index == 0
                        ? null
                        : chapters[index - 1].volumeLabel;
                    final volume = chapter.volumeLabel;
                    final progress = canonicalProgress;
                    final progressText =
                        progress?.chapterId == chapter.chapter.id
                        ? progress!.totalPages == null
                              ? 'Page ${progress.pageIndex + 1}'
                              : 'Page ${progress.pageIndex + 1} of ${progress.totalPages}'
                        : null;
                    final available = chapter.openableBindings.isNotEmpty;
                    final sourceText = chapter.readableBindings.isNotEmpty
                        ? '${chapter.readableBindings.length} readable source(s)'
                        : chapter.retryableBindings.isNotEmpty
                        ? '${chapter.retryableBindings.length} source(s) to retry'
                        : 'No readable source';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (volume != null && volume != previousVolume)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                            child: Text(
                              volume,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ListTile(
                          key: ValueKey(
                            'chapter-picker-${chapter.chapter.id.value}',
                          ),
                          enabled: available,
                          selected: chapter.chapter.id == value.chapter.id,
                          leading: Icon(
                            completedChapters.contains(chapter.chapter.id)
                                ? Icons.check_circle
                                : chapter.chapter.id == value.chapter.id
                                ? Icons.menu_book
                                : Icons.circle_outlined,
                          ),
                          title: Text(chapter.displayLabel),
                          subtitle: Text(
                            progressText == null
                                ? sourceText
                                : '$progressText · $sourceText',
                          ),
                          onTap: available
                              ? () => Navigator.pop(context, chapter)
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null || !mounted || chosen.chapter.id == value.chapter.id) {
      return;
    }
    if (chosen.openableBindings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That chapter has no readable source configured.'),
        ),
      );
      return;
    }
    await _open(
      ReaderSessionRequest(
        mediaId: value.mediaId,
        chapterId: chosen.chapter.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = session;
    final currentAvailability = _currentAvailability;
    final previousChapter = _chapterAtOffset(-1);
    final nextChapter = _chapterAtOffset(1);
    return PopScope(
      onPopInvokedWithResult: (_, _) => unawaited(_flush()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: controlsVisible
            ? AppBar(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAvailability?.displayLabel ??
                          value?.chapter.number.rawLabel ??
                          'Manga reader',
                    ),
                    if (currentAvailability?.volumeLabel case final volume?)
                      Text(
                        volume,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    key: const Key('reader-source'),
                    tooltip: 'Switch source',
                    onPressed: value == null ? null : _sources,
                    icon: const Icon(Icons.source),
                  ),
                  IconButton(
                    key: const Key('reader-settings'),
                    tooltip: 'Reader settings',
                    onPressed: value == null ? null : _settings,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              )
            : null,
        body: error != null
            ? _ReaderError(
                error: error!,
                retry: () => _open(activeRequest),
                alternate: _openAlternate,
              )
            : value == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () =>
                        setState(() => controlsVisible = !controlsVisible),
                    child: value.preferences.mode == ReaderMode.paged
                        ? PageView.builder(
                            key: const Key('paged-reader'),
                            controller: pageController,
                            physics: pagedZoomed
                                ? const NeverScrollableScrollPhysics()
                                : const PageScrollPhysics(),
                            reverse:
                                value.preferences.direction ==
                                ReaderDirection.rightToLeft,
                            itemCount: value.manifest.pages.length,
                            onPageChanged: _pageChanged,
                            itemBuilder: (_, index) => _ZoomableReaderPage(
                              key: ValueKey(
                                'zoom-page-$index-$zoomResetGeneration',
                              ),
                              active: index == currentPage,
                              onZoomChanged: (zoomed) {
                                if (index == currentPage &&
                                    pagedZoomed != zoomed) {
                                  setState(() => pagedZoomed = zoomed);
                                }
                              },
                              child: _ReaderPageView(
                                page: value.manifest.pages[index],
                                cache: cache,
                                fit: value.preferences.fit,
                              ),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              _updateVisiblePage();
                              return false;
                            },
                            child: ListView.builder(
                              key: const Key('vertical-reader'),
                              controller: scrollController,
                              itemCount: value.manifest.pages.length,
                              itemBuilder: (_, index) => KeyedSubtree(
                                key: verticalPageKeys.putIfAbsent(
                                  index,
                                  GlobalKey.new,
                                ),
                                child: _ReaderPageView(
                                  page: value.manifest.pages[index],
                                  cache: cache,
                                  fit: value.preferences.fit,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (completionVisible)
                    _ChapterCompletionOverlay(
                      previousChapter: previousChapter,
                      nextChapter: nextChapter,
                      onDismiss: () =>
                          setState(() => completionVisible = false),
                      onNext: () => _adjacent(1),
                      onPrevious: () => _adjacent(-1),
                    ),
                ],
              ),
        bottomNavigationBar: controlsVisible && value != null
            ? BottomAppBar(
                color: Colors.black87,
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('previous-chapter'),
                      tooltip: 'Previous chapter',
                      color: Colors.white,
                      disabledColor: Colors.white38,
                      onPressed: previousChapter == null
                          ? null
                          : () => _adjacent(-1),
                      icon: Icon(
                        Icons.skip_previous,
                        color: previousChapter == null
                            ? Colors.white38
                            : Colors.white,
                      ),
                    ),
                    IconButton(
                      key: const Key('chapter-picker'),
                      tooltip: 'Chapter picker',
                      color: Colors.white,
                      onPressed: _picker,
                      icon: const Icon(Icons.list),
                    ),
                    Expanded(
                      child: Text(
                        '${currentPage + 1} / ${value.manifest.pages.length} · ${value.manifest.sourceName}',
                        key: const Key('reader-counter'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (pagedZoomed)
                      IconButton(
                        key: const Key('reset-page-zoom'),
                        tooltip: 'Reset page zoom',
                        color: Colors.white,
                        onPressed: () => setState(() {
                          pagedZoomed = false;
                          zoomResetGeneration++;
                        }),
                        icon: const Icon(Icons.zoom_out_map),
                      ),
                    IconButton(
                      key: const Key('next-chapter'),
                      tooltip: 'Next chapter',
                      color: Colors.white,
                      disabledColor: Colors.white38,
                      onPressed: nextChapter == null
                          ? null
                          : () => _adjacent(1),
                      icon: Icon(
                        Icons.skip_next,
                        color: nextChapter == null
                            ? Colors.white38
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _openAlternate() async {
    final chapters = await widget.repository.chapters(activeRequest.mediaId);
    final chapter = chapters
        .where((value) => value.chapter.id == activeRequest.chapterId)
        .firstOrNull;
    final current = activeRequest.binding;
    final alternate = chapter?.openableBindings
        .where(
          (value) =>
              current == null ||
              value.providerId != current.providerId ||
              value.externalId != current.externalId,
        )
        .firstOrNull;
    if (alternate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No alternate source is available.')),
        );
      }
      return;
    }
    await _open(
      ReaderSessionRequest(
        mediaId: activeRequest.mediaId,
        chapterId: activeRequest.chapterId,
        binding: alternate,
        startAtBeginning: activeRequest.startAtBeginning,
      ),
    );
  }
}

class _ChapterCompletionOverlay extends StatelessWidget {
  const _ChapterCompletionOverlay({
    required this.previousChapter,
    required this.nextChapter,
    required this.onDismiss,
    required this.onNext,
    required this.onPrevious,
  });

  final ReaderChapterAvailability? previousChapter;
  final ReaderChapterAvailability? nextChapter;
  final VoidCallback onDismiss;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;

  @override
  Widget build(BuildContext context) {
    final next = nextChapter;
    final nextReadable = next?.openableBindings.isNotEmpty == true;
    final previousReadable =
        previousChapter?.openableBindings.isNotEmpty == true;
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 52),
              const SizedBox(height: 12),
              const Text(
                'Chapter complete',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? 'End of available chapters'
                    : nextReadable
                    ? 'Next: ${next.displayLabel}'
                    : 'The next chapter has no readable source.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    key: const Key('dismiss-chapter-completion'),
                    onPressed: onDismiss,
                    child: const Text('Stay on chapter'),
                  ),
                  if (previousChapter != null)
                    OutlinedButton.icon(
                      key: const Key('completion-previous-chapter'),
                      onPressed: previousReadable ? onPrevious : null,
                      icon: const Icon(Icons.skip_previous),
                      label: const Text('Previous Chapter'),
                    ),
                  if (next != null)
                    FilledButton.icon(
                      key: const Key('completion-next-chapter'),
                      onPressed: nextReadable ? onNext : null,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Next Chapter'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomableReaderPage extends StatefulWidget {
  const _ZoomableReaderPage({
    super.key,
    required this.child,
    required this.active,
    required this.onZoomChanged,
  });
  final Widget child;
  final bool active;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableReaderPage> createState() => _ZoomableReaderPageState();
}

class _ZoomableReaderPageState extends State<_ZoomableReaderPage> {
  final TransformationController transformation = TransformationController();
  bool zoomed = false;

  @override
  void initState() {
    super.initState();
    transformation.addListener(_transformChanged);
  }

  void _transformChanged() =>
      _setZoomed(transformation.value.getMaxScaleOnAxis() > 1.01);

  @override
  void didUpdateWidget(covariant _ZoomableReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) _reset(notify: false);
  }

  void _setZoomed(bool value) {
    if (zoomed == value) return;
    setState(() => zoomed = value);
    widget.onZoomChanged(value);
  }

  void _reset({bool notify = true}) {
    transformation.value = Matrix4.identity();
    if (zoomed) {
      setState(() => zoomed = false);
      if (notify) widget.onZoomChanged(false);
    }
  }

  void _doubleTap() {
    if (zoomed) {
      _reset();
    } else {
      transformation.value = Matrix4.diagonal3Values(2.5, 2.5, 1);
      _setZoomed(true);
    }
  }

  @override
  void dispose() {
    transformation.removeListener(_transformChanged);
    transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: const Key('paged-zoom-surface'),
    behavior: HitTestBehavior.opaque,
    onDoubleTap: _doubleTap,
    child: InteractiveViewer(
      transformationController: transformation,
      minScale: 1,
      maxScale: 4,
      panEnabled: zoomed,
      scaleEnabled: true,
      clipBehavior: Clip.hardEdge,
      onInteractionEnd: (_) {
        if (transformation.value.getMaxScaleOnAxis() <= 1.01) _reset();
      },
      child: SizedBox.expand(child: widget.child),
    ),
  );
}

class _ReaderPageView extends StatefulWidget {
  const _ReaderPageView({
    required this.page,
    required this.cache,
    required this.fit,
  });
  final ReaderPage page;
  final ReaderPageCache cache;
  final ReaderFit fit;
  @override
  State<_ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<_ReaderPageView> {
  late Future<Uint8List> bytes = widget.cache.load(widget.page);
  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: bytes,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return SizedBox(
          height: 360,
          child: Center(
            child: FilledButton.icon(
              onPressed: () => setState(() {
                widget.cache.retry(widget.page);
                bytes = widget.cache.load(widget.page);
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry page'),
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 360,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Center(
        child: Image.memory(
          snapshot.data!,
          key: ValueKey('reader-page-${widget.page.index}'),
          width: widget.fit == ReaderFit.width ? double.infinity : null,
          fit: widget.fit == ReaderFit.width ? BoxFit.fitWidth : BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(
            height: 360,
            child: Center(
              child: Text(
                'Page image is invalid',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({
    required this.error,
    required this.retry,
    required this.alternate,
  });
  final Object error;
  final VoidCallback retry;
  final VoidCallback alternate;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(ZankaSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: ZankaSpace.md),
          Text(
            _readerErrorMessage(error),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: ZankaSpace.md),
          FilledButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry reader'),
          ),
          TextButton.icon(
            onPressed: alternate,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Try another source'),
          ),
        ],
      ),
    ),
  );
}

String _readerErrorMessage(Object error) => switch (error) {
  ReaderException(kind: ReaderErrorKind.sourceUnavailable) =>
    'This source is temporarily unreachable. Retry, or choose another source.',
  ReaderException(kind: ReaderErrorKind.manifestInvalid) =>
    'This chapter page has changed and cannot be read right now. Retry later or choose another source.',
  ReaderException(kind: ReaderErrorKind.unsupportedFormat) =>
    'This chapter uses a format Zanka cannot read on this device.',
  ReaderException(kind: ReaderErrorKind.localFileMissing) =>
    'The local chapter file is missing. Repair it from Media Details.',
  _ =>
    'The reader could not open this chapter. Retry or choose another source.',
};

String _sourceName(ProviderId id) => id.value
    .split('-')
    .map(
      (word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    )
    .join(' ');
