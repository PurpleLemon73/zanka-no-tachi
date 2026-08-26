import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import 'reader_domain.dart';
import 'reader_preferences_store.dart';
import 'reader_source.dart';
import '../product_maturity/maturity_domain.dart';

class ReaderChapterAvailability {
  const ReaderChapterAvailability({
    required this.chapter,
    required this.bindings,
    required this.capabilities,
  });
  final CanonicalChapter chapter;
  final List<ChapterSourceBinding> bindings;
  final Map<ProviderId, ReaderSourceCapability> capabilities;
  List<ChapterSourceBinding> get readableBindings => bindings
      .where(
        (binding) =>
            capabilities[binding.providerId] ==
            ReaderSourceCapability.readerCapable,
      )
      .toList();
  List<ChapterSourceBinding> get retryableBindings => bindings
      .where(
        (binding) =>
            capabilities[binding.providerId] ==
            ReaderSourceCapability.temporarilyUnavailable,
      )
      .toList();
  List<ChapterSourceBinding> get openableBindings => [
    ...readableBindings,
    ...retryableBindings,
  ];
}

class ReaderRepository {
  const ReaderRepository({
    required this.database,
    required this.sources,
    required this.preferencesStore,
  });
  final CanonicalDatabase database;
  final ReaderSourceRegistry sources;
  final ReaderPreferencesStore preferencesStore;

  Future<List<ReaderChapterAvailability>> chapters(
    CanonicalMediaId requestedId,
  ) async {
    final mediaId = await database.resolveCanonicalId(requestedId);
    final chapters = await database.chaptersFor(mediaId);
    final edits = await database.chapterUserEditsFor(mediaId);
    chapters.sort((left, right) {
      final l = edits[left.id]?.explicitOrder;
      final r = edits[right.id]?.explicitOrder;
      if (l != null || r != null) {
        final compared = (l ?? _chapterOrder(left)).compareTo(
          r ?? _chapterOrder(right),
        );
        if (compared != 0) return compared;
      }
      return _compareChapters(left, right);
    });
    return Future.wait(
      chapters.map((chapter) async {
        final bindings = await database.chapterBindingsFor(chapter.id);
        return ReaderChapterAvailability(
          chapter: chapter,
          bindings: bindings,
          capabilities: {
            for (final binding in bindings)
              binding.providerId: sources.capability(binding),
          },
        );
      }),
    );
  }

  Future<ReaderSession> open(ReaderSessionRequest request) async {
    final mediaId = await database.resolveCanonicalId(request.mediaId);
    final chapter = await database.chapter(request.chapterId);
    if (chapter == null || chapter.mediaId != mediaId) {
      throw const ReaderException(
        ReaderErrorKind.manifestInvalid,
        'The selected chapter does not belong to this manga.',
      );
    }
    final bindings = await database.chapterBindingsFor(chapter.id);
    ChapterSourceBinding? binding = request.binding;
    if (binding != null) {
      final requested = binding;
      binding = bindings
          .where(
            (item) =>
                item.providerId == requested.providerId &&
                item.externalId == requested.externalId,
          )
          .firstOrNull;
    }
    binding ??= await _preferredReadable(mediaId, bindings);
    if (binding == null ||
        !{
          ReaderSourceCapability.readerCapable,
          ReaderSourceCapability.temporarilyUnavailable,
        }.contains(sources.capability(binding))) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'No readable source is configured for this chapter.',
      );
    }
    if (request.binding != null) {
      await database.setPreferredProvider(mediaId, binding.providerId);
    }
    final resolver = sources.resolver(binding.providerId);
    if (resolver == null) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'The reader adapter for this source is unavailable.',
      );
    }
    final resolvedRequest = ReaderSessionRequest(
      mediaId: mediaId,
      chapterId: chapter.id,
      binding: binding,
    );
    ReaderManifest manifest;
    try {
      manifest = await resolver.resolve(resolvedRequest);
    } on ReaderException catch (error) {
      if (error.kind != ReaderErrorKind.sourceUnavailable ||
          resolver is! FreshReaderManifestRetry) {
        rethrow;
      }
      manifest = await resolver.resolve(resolvedRequest);
    }
    if (manifest.pages.isEmpty ||
        manifest.pages.indexed.any((entry) => entry.$1 != entry.$2.index)) {
      throw const ReaderException(
        ReaderErrorKind.manifestInvalid,
        'The reader manifest has invalid page ordering.',
      );
    }
    final resume = await database.mangaSourcePageResume(
      binding.providerId,
      binding.externalId,
    );
    final startPage = resume == null
        ? 0
        : resume.pageIndex.clamp(0, manifest.pages.length - 1);
    return ReaderSession(
      mediaId: mediaId,
      chapter: chapter,
      manifest: manifest,
      startPage: startPage,
      preferences: await preferencesStore.load(),
      resume: resume,
    );
  }

  Future<ChapterSourceBinding?> _preferredReadable(
    CanonicalMediaId mediaId,
    List<ChapterSourceBinding> bindings,
  ) async {
    final readable = bindings
        .where(
          (binding) =>
              sources.capability(binding) ==
              ReaderSourceCapability.readerCapable,
        )
        .toList();
    final retryable = bindings
        .where(
          (binding) =>
              sources.capability(binding) ==
              ReaderSourceCapability.temporarilyUnavailable,
        )
        .toList();
    final preferred = await database.preferredProvider(mediaId);
    for (final binding in readable) {
      if (binding.providerId == preferred) return binding;
    }
    readable.sort((a, b) => a.providerId.value.compareTo(b.providerId.value));
    retryable.sort((a, b) => a.providerId.value.compareTo(b.providerId.value));
    return readable.firstOrNull ?? retryable.firstOrNull;
  }

  Future<void> savePosition(ReaderSession session, int pageIndex) async {
    final bounded = pageIndex.clamp(0, session.manifest.pages.length - 1);
    final now = DateTime.now().toUtc();
    await database.transaction(() async {
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: session.mediaId,
          chapterId: session.chapter.id,
          pageIndex: bounded,
          totalPages: session.manifest.pages.length,
          updatedAt: now,
        ),
      );
      await database.saveMangaSourcePageResume(
        MangaSourcePageResume(
          mediaId: session.mediaId,
          chapterId: session.chapter.id,
          providerId: session.manifest.binding.providerId,
          chapterExternalId: session.manifest.binding.externalId,
          pageIndex: bounded,
          totalPages: session.manifest.pages.length,
          updatedAt: now,
        ),
      );
      if (bounded == session.manifest.pages.length - 1) {
        await database.setChapterCompleted(
          session.chapter.id,
          origin: CompletionOrigin.automatic,
        );
      }
    });
  }

  Future<void> markRead(CanonicalChapterId chapterId) =>
      database.setChapterCompleted(chapterId, origin: CompletionOrigin.manual);

  Future<void> markUnread(CanonicalChapterId chapterId) =>
      database.setChapterUnread(chapterId);

  Future<void> savePreferences(ReaderPreferences value) =>
      preferencesStore.save(value);

  Future<ReaderChapterAvailability?> adjacent(
    ReaderSession session,
    int direction,
  ) async {
    final values = await chapters(session.mediaId);
    final index = values.indexWhere(
      (item) => item.chapter.id == session.chapter.id,
    );
    final next = index + direction;
    return index < 0 || next < 0 || next >= values.length ? null : values[next];
  }
}

double _chapterOrder(CanonicalChapter value) =>
    double.tryParse(value.number.normalizedNumber ?? '') ?? double.infinity;

int _compareChapters(CanonicalChapter left, CanonicalChapter right) {
  if (left.number.isNumeric != right.number.isNumeric) {
    return left.number.isNumeric ? -1 : 1;
  }
  final number = left.number.compareTo(right.number);
  return number != 0 ? number : left.id.value.compareTo(right.id.value);
}
