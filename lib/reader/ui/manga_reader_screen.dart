import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  _ContinuityScrollController? scrollController;
  Timer? persistDebounce;
  bool controlsVisible = true;
  final Map<(CanonicalChapterId, int), GlobalKey> verticalPageKeys = {};
  final Map<CanonicalChapterId, GlobalKey> chapterSliverKeys = {};
  final Map<CanonicalChapterId, GlobalKey> chapterBoundaryKeys = {};
  final List<ReaderSession> chapterWindow = [];
  final GlobalKey viewportKey = GlobalKey();
  int generation = 0;
  bool preparingNext = false;
  bool preparationFailed = false;
  CanonicalChapterId? preparationAttempt;
  Future<void> pendingSave = Future<void>.value();
  bool trimScheduled = false;
  bool visibleUpdateScheduled = false;
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
      chapterWindow.add(initial);
      currentPage = initial.startPage;
      pageController = PageController(initialPage: currentPage);
      scrollController = _ContinuityScrollController();
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
    final ticket = ++generation;
    await _flush();
    if (!mounted || ticket != generation) return;
    activeRequest = request;
    setState(() {
      session = null;
      error = null;
      chapterNavigation = const [];
      completedChapters = const {};
      canonicalProgress = null;
      completionVisible = false;
      completionHandled = false;
      chapterWindow.clear();
      preparingNext = false;
      preparationFailed = false;
      preparationAttempt = null;
    });
    try {
      final value = await widget.repository.open(request);
      if (!mounted || ticket != generation) return;
      currentPage = value.startPage;
      verticalTrackingReady = false;
      verticalPageKeys.clear();
      chapterSliverKeys.clear();
      chapterBoundaryKeys.clear();
      pagedZoomed = false;
      zoomResetGeneration++;
      pageController?.dispose();
      scrollController?.dispose();
      pageController = PageController(initialPage: currentPage);
      scrollController = _ContinuityScrollController();
      cache.clear();
      cache.prefetch(value.manifest, currentPage);
      setState(() {
        session = value;
        chapterWindow.add(value);
      });
      await _refreshNavigation(value.mediaId);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreVerticalPage(),
      );
    } on Object catch (value) {
      if (mounted && ticket == generation) setState(() => error = value);
    }
  }

  Future<void> _refreshNavigation(CanonicalMediaId mediaId) async {
    final ticket = generation;
    final chapters = await widget.repository.chapters(mediaId);
    final completed = await widget.repository.completedChapters(mediaId);
    final progress = await widget.repository.progress(mediaId);
    if (!mounted || ticket != generation || session?.mediaId != mediaId) return;
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
    _prepareNext();
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

  int get _windowPageCount => chapterWindow.fold(
    0,
    (count, chapter) => count + chapter.manifest.pages.length,
  );

  (ReaderSession, int) _windowPage(int index) {
    for (final chapter in chapterWindow) {
      if (index < chapter.manifest.pages.length) return (chapter, index);
      index -= chapter.manifest.pages.length;
    }
    throw RangeError.index(index, chapterWindow);
  }

  int get _activeWindowPage {
    var index = currentPage;
    for (final chapter in chapterWindow) {
      if (chapter.chapter.id == session?.chapter.id) break;
      index += chapter.manifest.pages.length;
    }
    return index;
  }

  // Resolution uses exactly the normal preferred-readable source policy, but
  // never an explicit binding (which would write the preferred provider).
  // A prepared session is not active and must never be flushed to persistence.
  Future<void> _prepareNext({bool retry = false}) async {
    final active = session;
    final next = _chapterAtOffset(1);
    if (active == null ||
        currentPage < active.manifest.pages.length - 2 ||
        next == null ||
        next.openableBindings.isEmpty ||
        chapterWindow.any((item) => item.chapter.id == next.chapter.id) ||
        chapterWindow.length >= 3 ||
        preparingNext ||
        (!retry && preparationAttempt == next.chapter.id)) {
      return;
    }
    final ticket = generation;
    setState(() {
      preparingNext = true;
      preparationFailed = false;
      preparationAttempt = next.chapter.id;
    });
    try {
      final prepared = await widget.repository.open(
        ReaderSessionRequest(
          mediaId: active.mediaId,
          chapterId: next.chapter.id,
          startAtBeginning: true,
        ),
      );
      if (!mounted || ticket != generation || session != active) return;
      setState(() {
        chapterWindow.add(prepared);
        preparingNext = false;
      });
      // Only the first next-chapter image is warmed, not its whole chapter.
      cache.load(prepared.manifest.pages.first).ignore();
    } on Object {
      if (!mounted || ticket != generation || session != active) return;
      setState(() {
        preparingNext = false;
        preparationFailed = true;
      });
    }
  }

  void _pageChanged(int page, [ReaderSession? chapter]) {
    final value = chapter ?? session;
    if (value == null) return;
    final changedChapter = value.chapter.id != session?.chapter.id;
    if (!changedChapter && page == currentPage) return;
    if (changedChapter) {
      // Queue the old position before changing ownership. A slow old write may
      // not race a new chapter's progress write and move canonical Continue back.
      final old = session!;
      final forwards =
          chapterWindow.indexWhere(
            (item) => item.chapter.id == value.chapter.id,
          ) >
          chapterWindow.indexWhere((item) => item.chapter.id == old.chapter.id);
      if (forwards && !completionHandled) {
        unawaited(_completeChapter(old));
      } else {
        unawaited(_flush());
      }
      generation++;
    }
    setState(() {
      if (changedChapter) {
        session = ReaderSession(
          mediaId: value.mediaId,
          chapter: value.chapter,
          manifest: value.manifest,
          startPage: page,
          preferences: session!.preferences,
          resume: value.resume,
        );
        activeRequest = ReaderSessionRequest(
          mediaId: value.mediaId,
          chapterId: value.chapter.id,
          binding: value.manifest.binding,
          startAtBeginning: true,
        );
        completionVisible = false;
        completionHandled = false;
        preparingNext = false;
        preparationFailed = false;
        preparationAttempt = null;
      }
      currentPage = page;
      pagedZoomed = false;
      if (page != value.manifest.pages.length - 1) completionVisible = false;
    });
    cache.prefetch(value.manifest, page);
    persistDebounce?.cancel();
    if (page == value.manifest.pages.length - 1 && !completionHandled) {
      completionHandled = true;
      unawaited(_completeChapter(value));
    } else {
      persistDebounce = Timer(const Duration(milliseconds: 300), _flush);
    }
    unawaited(_prepareNext());
  }

  Future<void> _completeChapter(ReaderSession value) async {
    persistDebounce?.cancel();
    await _savePosition(value, value.manifest.pages.length - 1);
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
    final target =
        verticalPageKeys[(value!.chapter.id, currentPage)]?.currentContext;
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
    final viewport =
        viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + viewport.size.height;
    final center = (viewportTop + viewportBottom) / 2;
    (CanonicalChapterId, int)? best;
    var distance = double.infinity;
    for (final entry in verticalPageKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      if (bottom <= viewportTop || top >= viewportBottom) continue;
      // Prefer the page under the reading line, not the nearest page centre:
      // a tall page remains active until its bottom actually crosses the line.
      final candidate = center < top
          ? top - center
          : center > bottom
          ? center - bottom
          : 0.0;
      if (candidate < distance) {
        distance = candidate;
        best = entry.key;
      }
    }
    if (best != null) {
      final chapter = chapterWindow
          .where((item) => item.chapter.id == best!.$1)
          .firstOrNull;
      if (chapter != null) _pageChanged(best.$2, chapter);
    }
    _scheduleTrim();
  }

  void _scheduleVisiblePageUpdate() {
    if (visibleUpdateScheduled) return;
    visibleUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visibleUpdateScheduled = false;
      _updateVisiblePage();
    });
  }

  Future<void> _savePosition(ReaderSession value, int page) {
    final write = pendingSave.then(
      (_) => widget.repository.savePosition(value, page),
    );
    pendingSave = write.catchError((Object _) {});
    return write;
  }

  void _scheduleTrim() {
    if (trimScheduled || chapterWindow.length < 2) return;
    trimScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trimScheduled = false;
      if (!mounted || session == null) return;
      final activeIndex = chapterWindow.indexWhere(
        (item) => item.chapter.id == session!.chapter.id,
      );
      if (activeIndex <= 0) return;
      var removeCount = 0;
      var removedExtent = 0.0;
      if (session!.preferences.mode == ReaderMode.vertical) {
        final viewport =
            viewportKey.currentContext?.findRenderObject() as RenderBox?;
        if (viewport == null) return;
        final top = viewport.localToGlobal(Offset.zero).dy;
        for (final chapter in chapterWindow.take(activeIndex)) {
          final boundary =
              chapterBoundaryKeys[chapter.chapter.id]?.currentContext
                      ?.findRenderObject()
                  as RenderBox?;
          final sliver =
              chapterSliverKeys[chapter.chapter.id]?.currentContext
                      ?.findRenderObject()
                  as RenderSliver?;
          if (boundary == null ||
              sliver?.geometry == null ||
              boundary.localToGlobal(Offset.zero).dy + boundary.size.height >
                  top) {
            break;
          }
          removedExtent +=
              sliver!.geometry!.scrollExtent + boundary.size.height;
          removeCount++;
        }
        if (removeCount == 0) return;
        // Correct during the next layout, before paint. Dropping a wholly-read
        // sliver must not visually move the remaining page or reset to the top.
        scrollController!.removeLeadingExtent(removedExtent);
      } else {
        if (pageController?.hasClients != true ||
            pageController!.position.isScrollingNotifier.value) {
          return;
        }
        removeCount = activeIndex;
      }
      final discarded = chapterWindow
          .take(removeCount)
          .map((item) => item.chapter.id)
          .toSet();
      setState(() {
        chapterWindow.removeRange(0, removeCount);
        verticalPageKeys.removeWhere((key, _) => discarded.contains(key.$1));
        chapterSliverKeys.removeWhere((key, _) => discarded.contains(key));
        chapterBoundaryKeys.removeWhere((key, _) => discarded.contains(key));
      });
      if (session!.preferences.mode == ReaderMode.paged) {
        // Rebase the existing position together with the delegate, before the
        // next frame. A new controller would absorb the old absolute page.
        pageController!.jumpToPage(currentPage);
      }
      unawaited(_prepareNext());
    });
  }

  Future<void> _flush() async {
    persistDebounce?.cancel();
    final value = session;
    if (value != null) await _savePosition(value, currentPage);
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
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_flush());
    persistDebounce?.cancel();
    pageController?.dispose();
    scrollController?.dispose();
    cache.clear();
    chapterWindow.clear();
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
      generation++;
      preparingNext = false;
      preparationAttempt = null;
      preparationFailed = false;
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
      pageController = PageController(initialPage: _activeWindowPage);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVerticalPage());
    unawaited(_prepareNext());
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

  Widget _verticalBoundary(ReaderSession chapter) {
    final windowIndex = chapterWindow.indexOf(chapter);
    if (windowIndex + 1 < chapterWindow.length) {
      final nextId = chapterWindow[windowIndex + 1].chapter.id;
      final next = chapterNavigation.firstWhere(
        (item) => item.chapter.id == nextId,
      );
      return Text(
        [
          next.displayLabel,
          if (next.volumeLabel != null) next.volumeLabel!,
        ].join(' · '),
        key: const Key('reader-chapter-boundary'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      );
    }
    // Never resolve a successor of a merely prepared chapter. Its tail is
    // passive until the reading line actually enters that chapter.
    if (chapter.chapter.id != session?.chapter.id) {
      return const SizedBox.shrink();
    }
    return _ChapterCompletionOverlay(
      inline: true,
      previousChapter: _chapterAtOffset(-1),
      nextChapter: _chapterAtOffset(1),
      onDismiss: () => setState(() => completionVisible = false),
      onNext: () => _adjacent(1),
      onPrevious: () => _adjacent(-1),
      preparing: preparingNext,
      failed: preparationFailed,
      retry: () => _prepareNext(retry: true),
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
                key: viewportKey,
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () =>
                        setState(() => controlsVisible = !controlsVisible),
                    child: value.preferences.mode == ReaderMode.paged
                        ? NotificationListener<ScrollEndNotification>(
                            onNotification: (_) {
                              _scheduleTrim();
                              return false;
                            },
                            child: PageView.builder(
                              key: const Key('paged-reader'),
                              controller: pageController,
                              physics: pagedZoomed
                                  ? const NeverScrollableScrollPhysics()
                                  : const PageScrollPhysics(),
                              reverse:
                                  value.preferences.direction ==
                                  ReaderDirection.rightToLeft,
                              itemCount: _windowPageCount,
                              findChildIndexCallback: (key) {
                                if (key
                                    is! ValueKey<
                                      (CanonicalChapterId, int, int)
                                    >) {
                                  return null;
                                }
                                final (id, page, zoomGeneration) = key.value;
                                if (zoomGeneration != zoomResetGeneration) {
                                  return null;
                                }
                                var offset = 0;
                                for (final chapter in chapterWindow) {
                                  if (chapter.chapter.id == id) {
                                    return offset + page;
                                  }
                                  offset += chapter.manifest.pages.length;
                                }
                                return null;
                              },
                              onPageChanged: (index) {
                                final (chapter, page) = _windowPage(index);
                                _pageChanged(page, chapter);
                              },
                              itemBuilder: (_, index) {
                                final (chapter, page) = _windowPage(index);
                                final active =
                                    chapter.chapter.id == value.chapter.id &&
                                    page == currentPage;
                                return _ZoomableReaderPage(
                                  key: ValueKey((
                                    chapter.chapter.id,
                                    page,
                                    zoomResetGeneration,
                                  )),
                                  active: active,
                                  onZoomChanged: (zoomed) {
                                    if (active && pagedZoomed != zoomed) {
                                      setState(() => pagedZoomed = zoomed);
                                    }
                                  },
                                  child: _ReaderPageView(
                                    key: ValueKey((chapter.chapter.id, page)),
                                    page: chapter.manifest.pages[page],
                                    cache: cache,
                                    fit: value.preferences.fit,
                                  ),
                                );
                              },
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              _scheduleVisiblePageUpdate();
                              return false;
                            },
                            child: CustomScrollView(
                              key: const Key('vertical-reader'),
                              controller: scrollController,
                              scrollCacheExtent: const ScrollCacheExtent.pixels(
                                200,
                              ),
                              slivers: [
                                for (final chapter in chapterWindow) ...[
                                  SliverList.builder(
                                    key: chapterSliverKeys.putIfAbsent(
                                      chapter.chapter.id,
                                      GlobalKey.new,
                                    ),
                                    itemCount: chapter.manifest.pages.length,
                                    itemBuilder: (_, index) => KeyedSubtree(
                                      key: verticalPageKeys.putIfAbsent((
                                        chapter.chapter.id,
                                        index,
                                      ), GlobalKey.new),
                                      child: _ReaderPageView(
                                        key: ValueKey((
                                          chapter.chapter.id,
                                          index,
                                        )),
                                        page: chapter.manifest.pages[index],
                                        cache: cache,
                                        fit: value.preferences.fit,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: ValueKey(
                                      'boundary-${chapter.chapter.id.value}',
                                    ),
                                    child: Padding(
                                      key: chapterBoundaryKeys.putIfAbsent(
                                        chapter.chapter.id,
                                        GlobalKey.new,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 12,
                                      ),
                                      child: _verticalBoundary(chapter),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                  ),
                  if (completionVisible &&
                      value.preferences.mode == ReaderMode.paged)
                    _ChapterCompletionOverlay(
                      previousChapter: previousChapter,
                      nextChapter: nextChapter,
                      onDismiss: () =>
                          setState(() => completionVisible = false),
                      onNext: () => _adjacent(1),
                      onPrevious: () => _adjacent(-1),
                      preparing: preparingNext,
                      failed: preparationFailed,
                      retry: () => _prepareNext(retry: true),
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
    required this.preparing,
    required this.failed,
    required this.retry,
    this.inline = false,
  });

  final ReaderChapterAvailability? previousChapter;
  final ReaderChapterAvailability? nextChapter;
  final VoidCallback onDismiss;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final bool preparing;
  final bool failed;
  final VoidCallback retry;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final next = nextChapter;
    final nextReadable = next?.openableBindings.isNotEmpty == true;
    final previousReadable =
        previousChapter?.openableBindings.isNotEmpty == true;
    final content = Material(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chapter complete',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              failed
                  ? 'The next chapter could not be prepared. Your current chapter is still available.'
                  : preparing
                  ? 'Preparing next chapter…'
                  : next == null
                  ? 'End of available chapters'
                  : nextReadable
                  ? 'Next: ${next.displayLabel}'
                  : 'The next chapter has no readable source.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (!inline)
                  OutlinedButton(
                    key: const Key('dismiss-chapter-completion'),
                    onPressed: onDismiss,
                    child: const Text('Stay on chapter'),
                  ),
                if (failed)
                  FilledButton.icon(
                    key: const Key('reader-continuation-retry'),
                    onPressed: retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry next chapter'),
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
    );
    return inline
        ? content
        : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(padding: const EdgeInsets.all(8), child: content),
          );
  }
}

/// Compensates only for fully offscreen, discarded leading chapter slivers.
/// Flutter relayouts immediately on false, so no intermediate jump is painted.
class _ContinuityScrollController extends ScrollController {
  void removeLeadingExtent(double extent) {
    (position as _ContinuityScrollPosition).leadingCorrection += extent;
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _ContinuityScrollPosition(
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

class _ContinuityScrollPosition extends ScrollPositionWithSingleContext {
  _ContinuityScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
  });
  double leadingCorrection = 0;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (leadingCorrection != 0) {
      correctPixels(
        (pixels - leadingCorrection).clamp(minScrollExtent, maxScrollExtent),
      );
      leadingCorrection = 0;
      return false;
    }
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
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
    super.key,
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
  void didUpdateWidget(covariant _ReaderPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) bytes = widget.cache.load(widget.page);
  }

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
