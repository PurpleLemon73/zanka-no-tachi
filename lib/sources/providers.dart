import '../domain/models.dart';

abstract interface class MangaProvider {
  String get key;
  Future<List<Manga>> featured();
  Future<List<Manga>> search(String query);
}

abstract interface class AnimeProvider {
  String get key;
  Future<List<Anime>> featured();
  Future<List<Anime>> search(String query);
}

class MockMangaProvider implements MangaProvider {
  @override
  String get key => 'mock-manga';

  static const items = [
    Manga(
      id: 'manga-ember-blade',
      title: 'Ember Blade',
      description:
          'A wandering smith inherits a sword that remembers every duel.',
      coverColor: 0xFFB23A2A,
      chapters: [
        Chapter(id: 'ember-c1', number: 1, title: 'Ashes'),
        Chapter(id: 'ember-c2', number: 2, title: 'The Red Forge'),
      ],
    ),
    Manga(
      id: 'manga-moonlit-garden',
      title: 'Moonlit Garden',
      description:
          'Two rivals tend a garden whose flowers reveal lost memories.',
      coverColor: 0xFF5361A8,
      chapters: [Chapter(id: 'moon-c1', number: 1, title: 'Night Bloom')],
    ),
  ];

  @override
  Future<List<Manga>> featured() async => items;

  @override
  Future<List<Manga>> search(String query) async => _filter(items, query);
}

class MockAnimeProvider implements AnimeProvider {
  @override
  String get key => 'mock-anime';

  static const items = [
    Anime(
      id: 'anime-sky-courier',
      title: 'Sky Courier',
      description:
          'A rookie pilot delivers impossible parcels above the clouds.',
      coverColor: 0xFF287FA1,
      episodes: [
        Episode(
          id: 'sky-e1',
          number: 1,
          title: 'First Flight',
          duration: Duration(minutes: 24),
        ),
        Episode(
          id: 'sky-e2',
          number: 2,
          title: 'Storm Post',
          duration: Duration(minutes: 24),
        ),
      ],
    ),
    Anime(
      id: 'anime-neon-kitchen',
      title: 'Neon Kitchen',
      description:
          'Midnight chefs settle old scores with spectacular street food.',
      coverColor: 0xFF8D3B8F,
      episodes: [
        Episode(
          id: 'neon-e1',
          number: 1,
          title: 'Opening Rush',
          duration: Duration(minutes: 22),
        ),
      ],
    ),
  ];

  @override
  Future<List<Anime>> featured() async => items;

  @override
  Future<List<Anime>> search(String query) async => _filter(items, query);
}

List<T> _filter<T extends Media>(List<T> items, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return items;
  return items
      .where((item) => item.title.toLowerCase().contains(normalized))
      .toList();
}
