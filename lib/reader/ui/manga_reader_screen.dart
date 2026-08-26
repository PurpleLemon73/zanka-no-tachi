import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialSession case final initial?) {
      session = initial;
      currentPage = initial.startPage;
      pageController = PageController(initialPage: currentPage);
      scrollController = ScrollController();
      cache.prefetch(initial.manifest, currentPage);
    } else {
      _open(widget.request);
    }
  }

  Future<void> _open(ReaderSessionRequest request) async {
    await _flush();
    setState(() {
      session = null;
      error = null;
    });
    try {
      final value = await widget.repository.open(request);
      currentPage = value.startPage;
      verticalTrackingReady = false;
      pageController?.dispose();
      scrollController?.dispose();
      pageController = PageController(initialPage: currentPage);
      scrollController = ScrollController();
      cache.clear();
      cache.prefetch(value.manifest, currentPage);
      if (mounted) setState(() => session = value);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreVerticalPage(),
      );
    } on Object catch (value) {
      if (mounted) setState(() => error = value);
    }
  }

  void _pageChanged(int page) {
    if (page == currentPage) return;
    setState(() => currentPage = page);
    final value = session;
    if (value != null) cache.prefetch(value.manifest, page);
    persistDebounce?.cancel();
    persistDebounce = Timer(const Duration(milliseconds: 300), _flush);
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
            ...chapter.readableBindings.map(
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
    final chapter = await widget.repository.adjacent(value, direction);
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
    } else if (chapter.readableBindings.isEmpty) {
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
        ),
      );
    }
  }

  Future<void> _picker() async {
    final value = session;
    if (value == null) return;
    final chapters = await widget.repository.chapters(value.mediaId);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: chapters
              .map(
                (chapter) => ListTile(
                  title: Text(chapter.chapter.number.rawLabel),
                  subtitle: Text(
                    '${chapter.readableBindings.length} readable source(s)',
                  ),
                  enabled: chapter.readableBindings.isNotEmpty,
                  selected: chapter.chapter.id == value.chapter.id,
                  onTap: () {
                    Navigator.pop(context);
                    _open(
                      ReaderSessionRequest(
                        mediaId: value.mediaId,
                        chapterId: chapter.chapter.id,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = session;
    return PopScope(
      onPopInvokedWithResult: (_, _) => unawaited(_flush()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: controlsVisible
            ? AppBar(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                title: Text(value?.chapter.number.rawLabel ?? 'Manga reader'),
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
            ? _ReaderError(error: error!, retry: () => _open(widget.request))
            : value == null
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => controlsVisible = !controlsVisible),
                child: value.preferences.mode == ReaderMode.paged
                    ? PageView.builder(
                        key: const Key('paged-reader'),
                        controller: pageController,
                        reverse:
                            value.preferences.direction ==
                            ReaderDirection.rightToLeft,
                        itemCount: value.manifest.pages.length,
                        onPageChanged: _pageChanged,
                        itemBuilder: (_, index) => _ReaderPageView(
                          page: value.manifest.pages[index],
                          cache: cache,
                          fit: value.preferences.fit,
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
        bottomNavigationBar: controlsVisible && value != null
            ? BottomAppBar(
                color: Colors.black87,
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('previous-chapter'),
                      tooltip: 'Previous chapter',
                      color: Colors.white,
                      onPressed: () => _adjacent(-1),
                      icon: const Icon(Icons.skip_previous),
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
                    IconButton(
                      key: const Key('next-chapter'),
                      tooltip: 'Next chapter',
                      color: Colors.white,
                      onPressed: () => _adjacent(1),
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
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
  const _ReaderError({required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;
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
            error is ReaderException
                ? (error as ReaderException).message
                : 'The reader could not open this chapter. Check the local file or choose another source.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: ZankaSpace.md),
          FilledButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry reader'),
          ),
        ],
      ),
    ),
  );
}

String _sourceName(ProviderId id) => id.value
    .split('-')
    .map(
      (word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    )
    .join(' ');
