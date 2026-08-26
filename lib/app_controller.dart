import 'dart:async';

import 'package:flutter/foundation.dart';

import 'data/app_database.dart' show AppDatabase;
import 'domain/models.dart';
import 'sources/providers.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.database,
    required this.mangaProvider,
    required this.animeProvider,
  });
  final AppDatabase database;
  final MangaProvider mangaProvider;
  final AnimeProvider animeProvider;
  List<Media> media = const [];
  List<LibraryEntry> library = const [];
  bool loading = true;
  StreamSubscription<List<LibraryEntry>>? _librarySubscription;

  Future<void> initialize() async {
    _librarySubscription = database.watchLibrary().listen((entries) {
      library = entries;
      notifyListeners();
    });
    final results = await Future.wait([
      mangaProvider.featured(),
      animeProvider.featured(),
    ]);
    media = [...results[0], ...results[1]];
    loading = false;
    notifyListeners();
  }

  bool isInLibrary(String mediaId) =>
      library.any((entry) => entry.mediaId == mediaId);

  Future<void> toggleLibrary(Media item) async {
    if (isInLibrary(item.id)) {
      await database.removeLibraryEntry(item.id);
      return;
    }
    await database.saveLibraryEntry(
      LibraryEntry(
        mediaId: item.id,
        mediaType: item.type,
        status: LibraryStatus.planning,
        isFavorite: true,
        addedAt: DateTime.now(),
      ),
    );
    await database.saveSourceBinding(
      SourceBinding(
        mediaId: item.id,
        providerKey: item is Manga ? mangaProvider.key : animeProvider.key,
        providerMediaId: item.id,
      ),
    );
  }

  Future<List<Media>> search(String query) async {
    final results = await Future.wait([
      mangaProvider.search(query),
      animeProvider.search(query),
    ]);
    return [...results[0], ...results[1]];
  }

  Media? mediaById(String id) {
    for (final item in media) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  void dispose() {
    _librarySubscription?.cancel();
    database.close();
    super.dispose();
  }
}
