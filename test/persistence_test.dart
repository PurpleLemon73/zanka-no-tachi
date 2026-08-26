import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/data/app_database.dart';
import 'package:zanka_no_tachi/domain/models.dart';

void main() {
  test('library and manga/anime progress survive a database restart', () async {
    final directory = await Directory.systemTemp.createTemp('zanka-test-');
    final file = File('${directory.path}/state.sqlite');
    final updatedAt = DateTime(2026, 8, 25);
    var database = AppDatabase(NativeDatabase(file));
    await database.saveLibraryEntry(
      LibraryEntry(
        mediaId: 'stable-media-id',
        mediaType: MediaType.manga,
        status: LibraryStatus.inProgress,
        isFavorite: true,
        addedAt: updatedAt,
      ),
    );
    await database.saveMangaProgress(
      MangaProgress(
        mediaId: 'stable-media-id',
        chapterId: 'chapter-7',
        page: 12,
        updatedAt: updatedAt,
      ),
    );
    await database.saveAnimeProgress(
      AnimeProgress(
        mediaId: 'stable-anime-id',
        episodeId: 'episode-3',
        position: const Duration(minutes: 8, seconds: 4),
        updatedAt: updatedAt,
      ),
    );
    await database.saveSourceBinding(
      const SourceBinding(
        mediaId: 'stable-media-id',
        providerKey: 'replaceable-provider',
        providerMediaId: 'remote-99',
        url: 'https://example.invalid/item',
      ),
    );
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    final library = await database.watchLibrary().first;
    expect(library.single.mediaId, 'stable-media-id');
    expect(library.single.isFavorite, isTrue);
    expect((await database.mangaProgress('stable-media-id'))?.page, 12);
    expect(
      (await database.animeProgress('stable-anime-id'))?.position,
      const Duration(minutes: 8, seconds: 4),
    );
    await database.close();
    await directory.delete(recursive: true);
  });
}
